-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UFPR, BCC, ci210 2016-2 trabalho semestral, autor: Roberto Hexsel, 07out
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- display: exibe inteiro na saida padrao do simulador
--          NAO ALTERE ESTE MODELO
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use std.textio.all;
use work.p_wires.all;

entity display is
  port (rst,clk : in bit;
        enable  : in bit;
        data    : in reg32);
end display;

architecture functional of display is
  file output : text open write_mode is "STD_OUTPUT";
begin  -- functional

  U_WRITE_OUT: process(clk)
    variable msg : line;
  begin
    if falling_edge(clk) and enable = '1' then
      write ( msg, string'(BV32HEX(data)) );
      writeline( output, msg );
    end if;
  end process U_WRITE_OUT;

end functional;
-- ++ display ++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- MICO X
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_wires.all;

entity mico is
  port (rst,clk : in    bit);
end mico;

architecture functional of mico is

  component mux2vet16 is
    port (entr1, entr2: in reg16; sel: in bit; z: out reg16);
  end component mux2vet16;

  component mux2vet32 is
    port (entr1, entr2: in reg32; sel: in bit; z: out reg32);
  end component mux2vet32;

  component registrador16 is
    port(rel, rst, ld: in  bit;
        D:           in  reg16;
        Q:           out reg16);
  end component registrador16;

  component adder16 is
    port(inpA, inpB : in reg16;
       outC : out reg16;
       vem  : in bit;
       vai  : out bit);
  end component adder16;

	component IP_handler is
	port(E, ip : in  reg16;
	   A, B : in reg32;
	   op : in reg4;
	   saida : out reg16);
	end component IP_handler;

  component display is                  -- neste arquivo
    port (rst,clk : in bit;
          enable  : in bit;
          data    : in reg32);
  end component display;

  component mem_prog is                 -- no arquivo mem.vhd
    port (ender : in  reg6;
          instr : out reg32);
  end component mem_prog;
  

  component ULA is                      -- neste arquivo
    port (fun : in reg4;
          alfa,beta : in  reg32;
          gama      : out reg32);
  end component ULA;
 
  component R is                        -- neste arquivo
    port (clk         : in  bit;
          wr_en       : in  bit;
          r_a,r_b,r_c : in  reg4;
          A,B         : out reg32;
          C           : in  reg32);
  end component R;

 
  type t_control_type is record
    extZero  : bit;       -- estende com zero=1, com sinal=0
    selBeta  : bit;       -- seleciona fonte para entrada B da ULA
    wr_display: bit;      -- atualiza display=1
    selNxtIP : bit;       -- seleciona fonte do incremento do IP
    wr_reg   : bit;       -- atualiza registrador: R(c) <= C
  end record;

  type t_control_mem is array (0 to 15) of t_control_type;

  -- preencha esta tabela com os sinais de controle adequados
  -- a tabela eh indexada com o opcode da instrucao
  constant ctrl_table : t_control_mem := (
  --extZ sBeta wrD sIP wrR
    ('0','0', '0', '0','0'),            -- NOP
    ('0','0', '0', '0','1'),            -- ADD
    ('0','0', '0', '0','1'),            -- SUB
    ('0','0', '0', '0','1'),            -- MUL
    ('0','0', '0', '0','1'),            -- AND
    ('0','0', '0', '0','1'),            -- OR
    ('0','0', '0', '0','1'),            -- XOR
    ('0','0', '0', '0','1'),            -- NOT
    ('0','0', '0', '0','1'),            -- SLL
    ('0','0', '0', '0','1'),            -- SRL
    ('1','1', '0', '0','1'),            -- ORI
    ('0','1', '0', '0','1'),            -- ADDI
    ('0','0', '1', '0','0'),            -- SHOW
    ('0','0', '0', '1','0'),            -- JUMP
    ('0','0', '0', '1','0'),            -- BRANCH
    ('0','0', '0', '1','0'));           -- HALT

  signal extZero, selBeta, wr_display, selNxtIP, wr_reg : bit;

  signal instr, A, B, C, beta, extended : reg32;
  signal sinal : reg16;
  signal this  : t_control_type;
  signal const, ip : reg16;
  signal ip_add, ip_2, ip_3: reg16;
  signal opcode : reg4;
  signal i_opcode : natural range 0 to 15;
  
begin  -- functional

	adder1: adder16 port map (ip, x"0001", ip_add, '0', open);
	mux1: mux2vet16 port map (ip_add, const, selNxtIP, ip_2);
	r1: registrador16 port map (clk, rst, '1', ip_2, ip_3);
	ip(5 downto 0) <= ip_3(5 downto 0);

	-- memoria de programa contem somente 64 palavras
	U_mem_prog: mem_prog port map(ip(5 downto 0), instr);

	opcode <= instr(31 downto 28);
	i_opcode <= BV2INT4(opcode);          -- indice do vetor DEVE ser inteiro

	this <= ctrl_table(i_opcode);         -- sinais de controle

	extZero    <= this.extZero;
	selBeta    <= this.selBeta;
	wr_display <= this.wr_display;
	selNxtIP   <= this.selNxtIP;
	wr_reg     <= this.wr_reg;


	U_regs: R port map (clk, '1', instr(27 downto 24), instr(23 downto 20), instr(19 downto 16), A, B, C);

	extended (15 downto 0) <= instr (15 downto 0);
	sinal (15 downto 0) <= extended(15) & extended(15) & extended(15) & extended(15) & extended(15) & extended(15) & extended(15) & extended(15) & extended(15) & extended(15) & extended(15) & extended(15) & extended(15) & extended(15) & extended(15) & extended(15);
	mux_ext: mux2vet16 port map (sinal, x"0000", extZero, extended (31 downto 16));

	mux_beta: mux2vet32 port map (B, extended, selBeta, beta);

	U_ULA: ULA port map (opcode, A, beta, C);

	ip_h: IP_handler port map (instr(15 downto 0), ip, A, B, opcode, const);

	-- nao altere esta linha
	U_display: display port map (rst, clk, wr_display, A);
  
end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity ULA is
  port (fun : in reg4;
        alfa,beta : in  reg32;
        gama      : out reg32);
end ULA;

architecture behaviour of ULA is

	component mult32x32 is
		port(A, B : in  reg32;   -- entradas A,B
	   prod : out reg32);  -- produto
	end component mult32x32;

	component sub32 is
		port(entr1, entr2: in  reg32;
	   z    : out reg32);
	end component sub32;

	component and2vet32 is
		 port(entr1, entr2: in  reg32;
	   z    : out reg32);
	end component and2vet32;

	component or2vet32 is
		port(entr1, entr2: in  reg32;
	   z    : out reg32);
	end component or2vet32;

	component xor2vet32 is
		port(entr1, entr2: in  reg32;
	   z    : out reg32);
	end component xor2vet32;

	component invvet32 is
		port(entr: in  reg32;
	   z    : out reg32);
	end component invvet32;

	component shiftleft32 is
		port(entr: in  reg32;
	   s    : in reg32;
	   z    : out reg32);
	end component shiftleft32;

	component shiftright32 is
		port(entr: in  reg32;
	   s    : in reg32;
	   z    : out reg32);
	end component shiftright32;

	component adder32 is
			port(inpA, inpB : in reg32;
	   	outC : out reg32;
	   	vem  : in bit;
	   	vai  : out bit);
	end component adder32;

	component mux16vet32 is
		 port(entr1, entr2, entr3, entr4, entr5, entr6, entr7, entr8, 
	   entr9, entr10, entr11, entr12, entr13, entr14, entr15, entr16: in  reg32;
	   sel  : in  reg4;
	   z    : out reg32);
	end component mux16vet32;

	signal s0,s1,s2,s3,s4,s5,s6,s7 : reg32;
	signal s8,s9,s10,s11,s12,s13,s14,s15 : reg32;

begin  -- behaviour

	--0000 - nada
	--0001 - add
	--0010 - sub
	--0011 - mult
	--0100 - and
	--0101 - or
	--0110 - xor
	--0111 - complemento (not)
	--1000 - desloca esquerda
	--1001 - desloca direita
	--1010 - or
	--1011 - add
	--...     - nada
	--*1110 - condição if-else
	--1111 - nada

	s0 <= "00000000000000000000000000000000";
	Uf1:  adder32 port map (alfa, beta, s1, '0', open);
	Uf2:  sub32 port map (alfa, beta, s2);
	Uf3:  mult32x32 port map (alfa, beta, s3);
	Uf4:  and2vet32 port map (alfa, beta, s4);
	Uf5:  or2vet32 port map (alfa, beta, s5);
	Uf6:  xor2vet32 port map (alfa, beta, s6);
	Uf7:  invvet32 port map (alfa, s7);
	Uf8:  shiftleft32 port map (alfa, beta, s8);
	Uf9:  shiftright32 port map (alfa, beta, s9);
	Uf10: or2vet32 port map (alfa, beta, s10);
	Uf11: adder32 port map (alfa, beta, s11, '0', open);
	s12 <= alfa;
	s13 <= "00000000000000000000000000000000";
	s14 <= "00000000000000000000000000000000";
	s15 <= "00000000000000000000000000000000";

	saida: mux16vet32 port map (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15, fun, gama);


end behaviour;
-- -----------------------------------------------------------------------



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity R is
  port (clk         : in  bit;
        wr_en       : in  bit;          -- ativo em 1
        r_a,r_b,r_c : in  reg4;
        A,B         : out reg32;
        C           : in  reg32);
end R;

architecture rtl of R is

	component registrador32 is
	  port(rel, rst, ld: in  bit;
	        D:           in  reg32;
	        Q:           out reg32);
	end component registrador32;

	component mux16vet32 is
	  port(entr1, entr2, entr3, entr4, entr5, entr6, entr7, entr8, 
	       entr9, entr10, entr11, entr12, entr13, entr14, entr15, entr16: in reg32;
	       sel  : in  reg4;
	       z    : out reg32);
	end component mux16vet32;

	component demux16vet32 is
	  port(entr: in  reg32;
	   sel  : in  reg4;
	   z1,z2,z3,z4,z5,z6,z7,z8,z9,z10,z11,z12,z13,z14,z15,z16 : out reg32);
	end component demux16vet32;

	component demux16 is
			port(entr: in  bit;
	   	sel  : in  reg4;
	   	z1,z2,z3,z4,z5,z6,z7,z8,z9,z10,z11,z12,z13,z14,z15,z16 : out bit);
	end component demux16;

	signal d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15: reg32;
	signal q0,q1,q2,q3,q4,q5,q6,q7,q8,q9,q10,q11,q12,q13,q14,q15: reg32;
	signal en1,en2,en3,en4,en5,en6,en7,en8,en9,en10,en11,en12,en13,en14,en15: bit;

begin
	
	Udm1: demux16vet32 port map (C, r_c, d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15);

	Udm2: demux16 port map (wr_en, r_c, open,en1,en2,en3,en4,en5,en6,en7,en8,en9,en10,en11,en12,en13,en14,en15);

	Ur0:  registrador32 port map (clk, '0', '0',  d0,  q0);
	Ur1:  registrador32 port map (clk, '1', en1,  d1,  q1);
	Ur2:  registrador32 port map (clk, '1', en2,  d2,  q2);
	Ur3:  registrador32 port map (clk, '1', en3,  d3,  q3);
	Ur4:  registrador32 port map (clk, '1', en4,  d4,  q4);
	Ur5:  registrador32 port map (clk, '1', en5,  d5,  q5);
	Ur6:  registrador32 port map (clk, '1', en6,  d6,  q6);
	Ur7:  registrador32 port map (clk, '1', en7,  d7,  q7);
	Ur8:  registrador32 port map (clk, '1', en8,  d8,  q8);
	Ur9:  registrador32 port map (clk, '1', en9,  d9,  q9);
	Ur10: registrador32 port map (clk, '1', en10, d10, q10);
	Ur11: registrador32 port map (clk, '1', en11, d11, q11);
	Ur12: registrador32 port map (clk, '1', en12, d12, q12);
	Ur13: registrador32 port map (clk, '1', en13, d13, q13);
	Ur14: registrador32 port map (clk, '1', en14, d14, q14);
	Ur15: registrador32 port map (clk, '1', en15, d15, q15);

	Um1: mux16vet32 port map (q0,q1,q2,q3,q4,q5,q6,q7,q8,q9,q10,q11,q12,q13,q14,q15, r_a, A);
	Um2: mux16vet32 port map (q0,q1,q2,q3,q4,q5,q6,q7,q8,q9,q10,q11,q12,q13,q14,q15, r_b, B);
 
end rtl;
-- -----------------------------------------------------------------------
