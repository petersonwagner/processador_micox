-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UFPR, BCC, ci210 2016-2 trabalho semestral, autor: Roberto Hexsel, 07out
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- Acrescente modelos dos laboratorios a este arquivo


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- inversor
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity inv is
  generic (prop : time := t_inv);
  port(A : in bit;
       S : out bit);
end inv;

architecture comport of inv is 
begin
    S <= (not A) after prop;
end architecture comport;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- porta AND de 2 entradas
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity and2 is
  generic (prop : time := t_and2);
  port(A, B : in  bit;  -- entradas A,B
       S    : out bit); -- saida C
end and2;

architecture and2 of and2 is 
begin
    S <= A and B after prop;
end and2;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- porta OR de 2 entradas
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity or2 is
  generic (prop : time := t_or2);
  port(A,B : in bit;
       S   : out bit);
end or2;

architecture comport of or2 is 
begin
  S <= reject t_rej inertial (A or B) after prop;
end architecture comport;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- porta OR de 3 entradas
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity or3 is
  generic (prop : time := t_or3);
  port(A, B, C : in  bit;  -- entradas A,B,C
       S       : out bit); -- saida S 
end or3;

architecture or3 of or3 is 
begin
    S <= A or B or C after prop;
end or3;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- porta XOR de 2 entradas
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity xor2 is
  port(A,B : in bit;
       S   : out bit);
end xor2;

architecture comport of xor2 is 
begin
  S <= reject t_rej inertial (A xor B) after t_xor2;
end architecture comport;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- porta XOR de 3 entradas
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity xor3 is
  generic (prop : time := t_xor3);
  port(A, B, C : in  bit;   -- entradas A,B,C
       S       : out bit);  -- saida S 
end xor3;

architecture xor3 of xor3 is 
begin
    S <= A xor B xor C after prop;
end xor3;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux2(a,b,s,z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux2 is
  port(A,B : in  bit;
       S   : in  bit;
       Z   : out bit);
end mux2;

architecture estrut of mux2 is 
  component inv is
    generic (prop : time);
    port(A : in bit; S : out bit);
  end component inv;
  component and2 is
    generic (prop : time);
    port(A,B : in bit; S : out bit);
  end component and2;
  component or2 is
    generic (prop : time);
    port(A,B : in bit; S : out bit);
  end component or2;
  signal negs,f0,f1 : bit;
 begin

  Ui:  inv  generic map (t_inv)  port map(s,negs);
  Ua0: and2 generic map (t_and2) port map(a,negs,f0);
  Ua1: and2 generic map (t_and2) port map(b,s,f1);
  Uor: or2  generic map (t_or2)  port map(f0,f1,z);
    
end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- N-bit register, synchronous load active in '0', asynch reset
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use work.p_WIRES.all;

entity registerN is
  generic (NUM_BITS: integer := 16;
           INIT_VAL: bit_vector);
  port(clk, rst, ld: in  bit;
       D:            in  bit_vector(NUM_BITS-1 downto 0);
       Q:            out bit_vector(NUM_BITS-1 downto 0));
end registerN;

architecture functional of registerN is
begin
  process(clk, rst, ld)
    variable state: bit_vector(NUM_BITS-1 downto 0);
  begin
    if rst = '0' then
      state := INIT_VAL;
    elsif rising_edge(clk) then
      if ld = '0' then
        state := D;
      end if;
    end if;
    Q <= state;
  end process;
  
end functional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- contador de 32 bits, reset=0 assincrono, load=1, enable=1 sincrono
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
use work.p_WIRES.all;

entity count32up is
  port(rel, rst, ld, en: in  bit;
        D:               in  reg32;
        Q:               out reg32);
end count32up;

architecture funcional of count32up is
  signal count: reg32;
begin

  process(rel, rst, ld)
    variable num : integer;
  begin
    if rst = '0' then
      count <= x"00000000";
    elsif ld = '1' then
      count <= D;
    elsif en = '1' and rising_edge(rel) then
      num := BV2INT(count) + 1;
      count <= INT2BV32(num);
    end if;
  end process;

  Q <= count after t_FFD;
end funcional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- contador de 32 bits, reset=0 assincrono, load=1, enable=1 sincrono
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;
use work.p_WIRES.all;

entity count32dwn is
  port(rel, rst, ld, en: in  bit;
        D:               in  reg32;
        Q:               out reg32);
end count32dwn;

architecture funcional of count32dwn is
  signal count: reg32;
begin

  process(rel, rst, ld)
    variable num : integer;
  begin
    if rst = '0' then
      count <= x"00000000";
    elsif ld = '1' then
      count <= D;
    elsif en = '1' and rising_edge(rel) then
      num := BV2INT(count) - 1;
      count <= INT2BV32(num);
    end if;
  end process;

  Q <= count after t_FFD;
end funcional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- registrador de 32 bits, reset=0 assincrono, load=1 sincrono
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_WIRES.all;

entity registrador32 is
  port(rel, rst, ld: in  bit;
        D:           in  reg32;
        Q:           out reg32);
end registrador32;

architecture funcional of registrador32 is
  signal value: reg32;
begin

  process(rel, rst, ld)
  begin
    if rst = '0' then
      value <= x"00000000";
    elsif ld = '1' and rising_edge(rel) then
      value <= D;
    end if;
  end process;

  Q <= value after t_FFD;
end funcional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- registrador de 20 bits, reset=0 assincrono, load=1 sincrono
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_WIRES.all;

entity registrador20 is
  port(rel, rst, ld: in  bit;
        D:           in  reg20;
        Q:           out reg20);
end registrador20;

architecture funcional of registrador20 is
  signal value: reg20;
begin

  process(rel, rst, ld)
  begin
    if rst = '0' then
      value <= (others => '0');
    elsif ld = '1' and rising_edge(rel) then
      value <= D;
    end if;
  end process;

  Q <= value after t_FFD;
end funcional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- flip-flop tipo D com set,reset=0 assincronos
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_WIRES.all;
entity FFD is
  port(rel, rst, set : in bit;
        D : in  bit;
        Q : out bit);
end FFD;

architecture funcional of FFD is
  signal estado : bit := '0';
begin

  process(rel, rst, set)
  begin
    if rst = '0' then
      estado <= '0';
    elsif set = '0' then
      estado <= '1';
    elsif rising_edge(rel) then
      estado <= D;
    end if;
  end process;

  Q <= estado after t_FFD;

end funcional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- flip-flop tipo D com set,reset=0 assincronos, saidas Q e /Q
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_WIRES.all;
entity FFDQQ is
  port(rel, rst, set : in bit;
        D    : in  bit;
        Q, N : out bit);
end FFDQQ;

architecture funcional of FFDQQ is
  signal estado : bit := '0';
begin

  process(rel, rst, set)
  begin
    if rst = '0' then
      estado <= '0';
    elsif set = '0' then
      estado <= '1';
    elsif rising_edge(rel) then
      estado <= D;
    end if;
  end process;

  Q <= estado after t_FFD;
  N <= not estado after t_FFD;

end funcional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++







































































-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- somador completo de um bit, modelo estrutural
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all; use work.p_wires.all;

entity addBit is port(bitA, bitB, vem : in bit;    -- entradas A,B,vem-um
       soma, vai       : out bit);  -- saida C,vai-um
end addBit;

architecture estrutural of addBit is 
  component and2 is
                      port (A,B: in bit; S: out bit);
  end component and2;

  component or3 is
                      port (A,B,C: in bit; S: out bit);
  end component or3;

  component xor3 is
                      port (A,B,C: in bit; S: out bit);
  end component xor3;

  signal a1,a2,a3: bit;
begin
  U_xor:  xor3 port map ( bitA, bitB, vem, soma );

  U_and1: and2 port map ( bitA, bitB, a1 );
  U_and2: and2 port map ( bitA, vem,  a2 );
  U_and3: and2 port map ( vem,  bitB, a3 );
  U_or:   or3  port map ( a1, a2, a3, vai );

end estrutural;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- somador de 16 bits, sem adiantamento de vai-um
-- Secao 1.6+8.1.2 de RH
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all; use work.p_wires.all;

entity adder16 is
  port(inpA, inpB : in reg16;
       outC : out reg16;
       vem  : in bit;
       vai  : out bit
       );
end adder16;

architecture adder16 of adder16 is 
  component addBit port(bitA, bitB, vem : in bit;
                        soma, vai       : out bit);       
  end component addBit;

  signal v : reg16;                     -- cadeia de vai-um
  signal r : reg16;                     -- resultado parcial
begin

  -- entrada vem deve estar ligada em '0' para somar, em '1' para subtrair
  U_b0: addBit port map ( inpA(0), inpB(0), vem,  r(0), v(0) );
  U_b1: addBit port map ( inpA(1), inpB(1), v(0), r(1), v(1) );
  U_b2: addBit port map ( inpA(2), inpB(2), v(1), r(2), v(2) );
  U_b3: addBit port map ( inpA(3), inpB(3), v(2), r(3), v(3) );
  U_b4: addBit port map ( inpA(4), inpB(4), v(3), r(4), v(4) );
  U_b5: addBit port map ( inpA(5), inpB(5), v(4), r(5), v(5) );
  U_b6: addBit port map ( inpA(6), inpB(6), v(5), r(6), v(6) );
  U_b7: addBit port map ( inpA(7), inpB(7), v(6), r(7), v(7) );
  U_b8: addBit port map ( inpA(8), inpB(8), v(7), r(8), v(8) );
  U_b9: addBit port map ( inpA(9), inpB(9), v(8), r(9), v(9) );
  U_ba: addBit port map ( inpA(10),inpB(10),v(9), r(10),v(10) );
  U_bb: addBit port map ( inpA(11),inpB(11),v(10),r(11),v(11) );
  U_bc: addBit port map ( inpA(12),inpB(12),v(11),r(12),v(12) );
  U_bd: addBit port map ( inpA(13),inpB(13),v(12),r(13),v(13) );
  U_be: addBit port map ( inpA(14),inpB(14),v(13),r(14),v(14) );
  U_bf: addBit port map ( inpA(15),inpB(15),v(14),r(15),v(15) );
  
  vai <= v(15);
  outC <= r;
  
end adder16;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- somador de 32 bits, sem adiantamento de vai-um
-- Secao 1.6+8.1.2 de RH
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all; use work.p_wires.all;

entity adder32 is
  port(inpA, inpB : in reg32;
       outC : out reg32;
       vem  : in bit;
       vai  : out bit
       );
end adder32;

architecture adder32 of adder32 is 
  component addBit port(bitA, bitB, vem : in bit;
                        soma, vai       : out bit);       
  end component addBit;

  signal v : reg32;                     -- cadeia de vai-um
  signal r : reg32;                     -- resultado parcial
begin

  -- entrada vem deve estar ligada em '0' para somar, em '1' para subtrair
  U_b0: addBit port map ( inpA(0), inpB(0), vem,  r(0), v(0) );
  U_b1: addBit port map ( inpA(1), inpB(1), v(0), r(1), v(1) );
  U_b2: addBit port map ( inpA(2), inpB(2), v(1), r(2), v(2) );
  U_b3: addBit port map ( inpA(3), inpB(3), v(2), r(3), v(3) );
  U_b4: addBit port map ( inpA(4), inpB(4), v(3), r(4), v(4) );
  U_b5: addBit port map ( inpA(5), inpB(5), v(4), r(5), v(5) );
  U_b6: addBit port map ( inpA(6), inpB(6), v(5), r(6), v(6) );
  U_b7: addBit port map ( inpA(7), inpB(7), v(6), r(7), v(7) );
  U_b8: addBit port map ( inpA(8), inpB(8), v(7), r(8), v(8) );
  U_b9: addBit port map ( inpA(9), inpB(9), v(8), r(9), v(9) );
  U_b10: addBit port map ( inpA(10), inpB(10), v(9), r(10), v(10) );
  U_b11: addBit port map ( inpA(11), inpB(11), v(10), r(11), v(11) );
  U_b12: addBit port map ( inpA(12), inpB(12), v(11), r(12), v(12) );
  U_b13: addBit port map ( inpA(13), inpB(13), v(12), r(13), v(13) );
  U_b14: addBit port map ( inpA(14), inpB(14), v(13), r(14), v(14) );
  U_b15: addBit port map ( inpA(15), inpB(15), v(14), r(15), v(15) );
  U_b16: addBit port map ( inpA(16), inpB(16), v(15), r(16), v(16) );
  U_b17: addBit port map ( inpA(17), inpB(17), v(16), r(17), v(17) );
  U_b18: addBit port map ( inpA(18), inpB(18), v(17), r(18), v(18) );
  U_b19: addBit port map ( inpA(19), inpB(19), v(18), r(19), v(19) );
  U_b20: addBit port map ( inpA(20), inpB(20), v(19), r(20), v(20) );
  U_b21: addBit port map ( inpA(21), inpB(21), v(20), r(21), v(21) );
  U_b22: addBit port map ( inpA(22), inpB(22), v(21), r(22), v(22) );
  U_b23: addBit port map ( inpA(23), inpB(23), v(22), r(23), v(23) );
  U_b24: addBit port map ( inpA(24), inpB(24), v(23), r(24), v(24) );
  U_b25: addBit port map ( inpA(25), inpB(25), v(24), r(25), v(25) );
  U_b26: addBit port map ( inpA(26), inpB(26), v(25), r(26), v(26) );
  U_b27: addBit port map ( inpA(27), inpB(27), v(26), r(27), v(27) );
  U_b28: addBit port map ( inpA(28), inpB(28), v(27), r(28), v(28) );
  U_b29: addBit port map ( inpA(29), inpB(29), v(28), r(29), v(29) );
  U_b30: addBit port map ( inpA(30), inpB(30), v(29), r(30), v(30) );
  U_b31: addBit port map ( inpA(31), inpB(31), v(30), r(31), v(31) );

  
  vai <= v(31);
  outC <= r;
  
end adder32;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- porta NAND de 2 entradas
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity nand2 is
  port(A,B : in bit;
       S   : out bit);
end nand2;

architecture comport of nand2 is 
begin
    S <= (not(A and B));
end architecture comport;



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux2(a,b,s,z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux2 is
  port(a,b : in  bit;                   -- entradas de dados
       s   : in  bit;                   -- entrada de selecao
       z   : out bit);                  -- saida
end mux2;

architecture estrut of mux2 is 

  -- declara componentes que sao instanciados
  component inv is
    port(A : in bit; S : out bit);
  end component inv;

  component nand2 is
    port(A,B : in bit; S : out bit);
  end component nand2;

  signal r, p, q : bit;              -- sinais internos
  
begin  -- compare ligacoes dos sinais com diagrama das portas logicas

  Ui:  inv  port map(s, r);
  Ua0: nand2 port map(a, r, p);
  Ua1: nand2 port map(b, s, q);
  Uor: nand2 port map(p, q, z);
    
end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux4(a,b,c,d,s0,s1,z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux4 is
  port(a,b,c,d : in  bit;               -- quatro entradas de dados
       s0,s1   : in  bit;               -- dois sinais de selecao
       z       : out bit);              -- saida
end mux4;

architecture estrut of mux4 is 

  component mux2 is
    port(A,B : in  bit; S : in  bit; Z : out bit);
  end component mux2;

  signal p,q : bit;                     -- sinais internos
begin
  -- implemente usando tres mux2
  Um1: mux2 port map(a,b,s0,p);
  Um2: mux2 port map(c,d,s0,q);
  Um3: mux2 port map(p,q,s1,z);
  
end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux8(a,b,c,d,e,f,g,h,s0,s1,s2,z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux8 is
  port(a,b,c,d,e,f,g,h : in  bit;       -- oito entradas de dados
       s0,s1,s2        : in  bit;       -- tres sinais de controle
       z               : out bit);      -- saida
end mux8;

architecture estrut of mux8 is 

  component mux2 is
    port(A,B : in  bit; S : in  bit; Z : out bit);
  end component mux2;

  component mux4 is
    port(A,B,C,D : in  bit; S0,S1 : in  bit; Z : out bit);
  end component mux4;

  signal p,q : bit;                     -- sinais internos
  
begin
  -- implemente usando dois mux4 e um mux2
  Um1: mux4 port map(a,b,c,d,s0,s1,p);
  Um2: mux4 port map(e,f,g,h,s0,s1,q);
  Um3: mux2 port map(p,q,s2,z);

end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux16(entr(15downto0),sel(3downto0),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux16 is
  port(entr: in  reg16;
       sel  : in  reg4;
       z    : out bit);
end mux16;

architecture estrut of mux16 is 

  component mux8 is
    port(A,B,C,D,E,F,G,H : in bit; S0,S1,S2: in bit; Z: out bit);
  end component mux8;

  component mux2 is
    port(A,B : in  bit; S : in  bit; Z : out bit);
  end component mux2;

  signal p, q : bit;
  
begin

 -- implemente usando dois mux4 e um mux2
  Um1: mux8 port map (entr(7),entr(6),entr(5),entr(4),entr(3),entr(2),entr(1),entr(0), sel(2),sel(1),sel(0), p);
  Um2: mux8 port map (entr(15),entr(14),entr(13),entr(12),entr(11),entr(10),entr(9),entr(8), sel(2),sel(1),sel(0), q);
  Um3: mux2 port map(p,q,sel(3), z);

end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux2vet16(entr(15downto0),sel(3downto0),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux2vet16 is
  port(entr1, entr2: in  reg16;
       sel  : in  bit;
       z    : out reg16);
end mux2vet16;

architecture estrut of mux2vet16 is 

  component mux2 is
    port(A,B : in  bit; S : in  bit; Z : out bit);
  end component mux2;
  
begin

 -- implemente usando dois mux4 e um mux2
  Um0: mux2 port map(entr1(0 ), entr2(0 ), sel, z(0));
  Um1: mux2 port map(entr1(1 ), entr2(1 ), sel, z(1));
  Um2: mux2 port map(entr1(2 ), entr2(2 ), sel, z(2));
  Um3: mux2 port map(entr1(3 ), entr2(3 ), sel, z(3));
  Um4: mux2 port map(entr1(4 ), entr2(4 ), sel, z(4));
  Um5: mux2 port map(entr1(5 ), entr2(5 ), sel, z(5));
  Um6: mux2 port map(entr1(6 ), entr2(6 ), sel, z(6));
  Um7: mux2 port map(entr1(7 ), entr2(7 ), sel, z(7));
  Um8: mux2 port map(entr1(8 ), entr2(8 ), sel, z(8));
  Um9: mux2 port map(entr1(9 ), entr2(9 ), sel, z(9));
  Um10: mux2 port map(entr1(10), entr2(10), sel, z(10));
  Um11: mux2 port map(entr1(11), entr2(11), sel, z(11));
  Um12: mux2 port map(entr1(12), entr2(12), sel, z(12));
  Um13: mux2 port map(entr1(13), entr2(13), sel, z(13));
  Um14: mux2 port map(entr1(14), entr2(14), sel, z(14));
  Um15: mux2 port map(entr1(15), entr2(15), sel, z(15));


end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux2vet32(entr(15downto0),sel(3downto0),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux2vet32 is
  port(entr1, entr2: in  reg32;
       sel  : in  bit;
       z    : out reg32);
end mux2vet32;

architecture estrut of mux2vet32 is 

  component mux2 is
    port(A,B : in  bit; S : in  bit; Z : out bit);
  end component mux2;
  
begin

 -- implemente usando dois mux4 e um mux2
  Um0: mux2 port map(entr1(0), entr2(0), sel, z(0));
  Um1: mux2 port map(entr1(1), entr2(1), sel, z(1));
  Um2: mux2 port map(entr1(2), entr2(2), sel, z(2));
  Um3: mux2 port map(entr1(3), entr2(3), sel, z(3));
  Um4: mux2 port map(entr1(4), entr2(4), sel, z(4));
  Um5: mux2 port map(entr1(5), entr2(5), sel, z(5));
  Um6: mux2 port map(entr1(6), entr2(6), sel, z(6));
  Um7: mux2 port map(entr1(7), entr2(7), sel, z(7));
  Um8: mux2 port map(entr1(8), entr2(8), sel, z(8));
  Um9: mux2 port map(entr1(9), entr2(9), sel, z(9));
  Um10: mux2 port map(entr1(10), entr2(10), sel, z(10));
  Um11: mux2 port map(entr1(11), entr2(11), sel, z(11));
  Um12: mux2 port map(entr1(12), entr2(12), sel, z(12));
  Um13: mux2 port map(entr1(13), entr2(13), sel, z(13));
  Um14: mux2 port map(entr1(14), entr2(14), sel, z(14));
  Um15: mux2 port map(entr1(15), entr2(15), sel, z(15));
  Um16: mux2 port map(entr1(16), entr2(16), sel, z(16));
  Um17: mux2 port map(entr1(17), entr2(17), sel, z(17));
  Um18: mux2 port map(entr1(18), entr2(18), sel, z(18));
  Um19: mux2 port map(entr1(19), entr2(19), sel, z(19));
  Um20: mux2 port map(entr1(20), entr2(20), sel, z(20));
  Um21: mux2 port map(entr1(21), entr2(21), sel, z(21));
  Um22: mux2 port map(entr1(22), entr2(22), sel, z(22));
  Um23: mux2 port map(entr1(23), entr2(23), sel, z(23));
  Um24: mux2 port map(entr1(24), entr2(24), sel, z(24));
  Um25: mux2 port map(entr1(25), entr2(25), sel, z(25));
  Um26: mux2 port map(entr1(26), entr2(26), sel, z(26));
  Um27: mux2 port map(entr1(27), entr2(27), sel, z(27));
  Um28: mux2 port map(entr1(28), entr2(28), sel, z(28));
  Um29: mux2 port map(entr1(29), entr2(29), sel, z(29));
  Um30: mux2 port map(entr1(30), entr2(30), sel, z(30));
  Um31: mux2 port map(entr1(31), entr2(31), sel, z(31));


end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux16vet16(entr(15downto0),sel(3downto0),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux16vet16 is
  port(entr1, entr2, entr3, entr4, entr5, entr6, entr7, entr8, 
       entr9, entr10, entr11, entr12, entr13, entr14, entr15, entr16: in  reg16;
       sel  : in  reg4;
       z    : out reg16);
end mux16vet16;

architecture estrut of mux16vet16 is 

component mux2vet16 is
  port(entr1, entr2: in  reg16;
       sel  : in  bit;
       z    : out reg16);
end component mux2vet16;

  signal a0, a1, a2, a3, a4, a5, a6, a7, b0, b1, b2, b3, c0, c1 : reg16;

begin

  Um00: mux2vet16 port map (entr1, entr2, sel(0), a0);
  Um01: mux2vet16 port map (entr3, entr4, sel(0), a1);
  Um02: mux2vet16 port map (entr5, entr6, sel(0), a2);
  Um03: mux2vet16 port map (entr7, entr8, sel(0), a3);
  Um04: mux2vet16 port map (entr9, entr10, sel(0), a4);
  Um05: mux2vet16 port map (entr11, entr12, sel(0), a5);
  Um06: mux2vet16 port map (entr13, entr14, sel(0), a6);
  Um07: mux2vet16 port map (entr15, entr16, sel(0), a7);

  Um10: mux2vet16 port map (a0, a1, sel(1), b0);
  Um11: mux2vet16 port map (a2, a3, sel(1), b1);
  Um12: mux2vet16 port map (a4, a5, sel(1), b2);
  Um13: mux2vet16 port map (a6, a7, sel(1), b3);

  Um20: mux2vet16 port map (b0, b1, sel(2), c0);
  Um21: mux2vet16 port map (b2, b3, sel(2), c1);

  Um30: mux2vet16 port map (c0, c1, sel(3), z);

end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- mux16vet32(entr(31downto0),sel(3downto0),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity mux16vet32 is
  port(entr1, entr2, entr3, entr4, entr5, entr6, entr7, entr8, 
       entr9, entr10, entr11, entr12, entr13, entr14, entr15, entr16: in  reg32;
       sel  : in  reg4;
       z    : out reg32);
end mux16vet32;

architecture estrut of mux16vet32 is 

  component mux2vet32 is
    port(entr1, entr2: in  reg32;
         sel  : in  bit;
         z    : out reg32);
  end component mux2vet32;

  signal a0, a1, a2, a3, a4, a5, a6, a7, b0, b1, b2, b3, c0, c1 : reg32;

begin

  Um00: mux2vet32 port map (entr1, entr2, sel(0), a0);
  Um01: mux2vet32 port map (entr3, entr4, sel(0), a1);
  Um02: mux2vet32 port map (entr5, entr6, sel(0), a2);
  Um03: mux2vet32 port map (entr7, entr8, sel(0), a3);
  Um04: mux2vet32 port map (entr9, entr10, sel(0), a4);
  Um05: mux2vet32 port map (entr11, entr12, sel(0), a5);
  Um06: mux2vet32 port map (entr13, entr14, sel(0), a6);
  Um07: mux2vet32 port map (entr15, entr16, sel(0), a7);

  Um10: mux2vet32 port map (a0, a1, sel(1), b0);
  Um11: mux2vet32 port map (a2, a3, sel(1), b1);
  Um12: mux2vet32 port map (a4, a5, sel(1), b2);
  Um13: mux2vet32 port map (a6, a7, sel(1), b3);

  Um20: mux2vet32 port map (b0, b1, sel(2), c0);
  Um21: mux2vet32 port map (b2, b3, sel(2), c1);

  Um30: mux2vet32 port map (c0, c1, sel(3), z);

end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- registrador de 16 bits, reset=0 assincrono, load=1 sincrono
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_WIRES.all;

entity registrador16 is
  port(rel, rst, ld: in  bit;
        D:           in  reg16;
        Q:           out reg16);
end registrador16;

architecture funcional of registrador16 is
  signal value: reg16;
begin

  process(rel, rst, ld)
  begin
    if rst = '0' then
      value <= (others => '0');
    elsif ld = '1' and rising_edge(rel) then
      value <= D;
    end if;
  end process;

  Q <= value;
end funcional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- or2vet32(entr(31downto0),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity or2vet32 is
  port(entr1, entr2: in  reg32;
       z    : out reg32);
end or2vet32;

architecture estrut of or2vet32 is 

  component or2 is
    port(A,B : in  bit; S : out bit);
  end component or2;
  
begin

 -- implemente usando dois mux4 e um mux2
  Um0:  or2 port map(entr1(0),  entr2(0),  z(0));
  Um1:  or2 port map(entr1(1),  entr2(1),  z(1));
  Um2:  or2 port map(entr1(2),  entr2(2),  z(2));
  Um3:  or2 port map(entr1(3),  entr2(3),  z(3));
  Um4:  or2 port map(entr1(4),  entr2(4),  z(4));
  Um5:  or2 port map(entr1(5),  entr2(5),  z(5));
  Um6:  or2 port map(entr1(6),  entr2(6),  z(6));
  Um7:  or2 port map(entr1(7),  entr2(7),  z(7));
  Um8:  or2 port map(entr1(8),  entr2(8),  z(8));
  Um9:  or2 port map(entr1(9),  entr2(9),  z(9));
  Um10: or2 port map(entr1(10), entr2(10), z(10));
  Um11: or2 port map(entr1(11), entr2(11), z(11));
  Um12: or2 port map(entr1(12), entr2(12), z(12));
  Um13: or2 port map(entr1(13), entr2(13), z(13));
  Um14: or2 port map(entr1(14), entr2(14), z(14));
  Um15: or2 port map(entr1(15), entr2(15), z(15));
  Um16: or2 port map(entr1(16), entr2(16), z(16));
  Um17: or2 port map(entr1(17), entr2(17), z(17));
  Um18: or2 port map(entr1(18), entr2(18), z(18));
  Um19: or2 port map(entr1(19), entr2(19), z(19));
  Um20: or2 port map(entr1(20), entr2(20), z(20));
  Um21: or2 port map(entr1(21), entr2(21), z(21));
  Um22: or2 port map(entr1(22), entr2(22), z(22));
  Um23: or2 port map(entr1(23), entr2(23), z(23));
  Um24: or2 port map(entr1(24), entr2(24), z(24));
  Um25: or2 port map(entr1(25), entr2(25), z(25));
  Um26: or2 port map(entr1(26), entr2(26), z(26));
  Um27: or2 port map(entr1(27), entr2(27), z(27));
  Um28: or2 port map(entr1(28), entr2(28), z(28));
  Um29: or2 port map(entr1(29), entr2(29), z(29));
  Um30: or2 port map(entr1(30), entr2(30), z(30));
  Um31: or2 port map(entr1(31), entr2(31), z(31));


end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- and2vet32(entr(31downto0),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity and2vet32 is
  port(entr1, entr2: in  reg32;
       z    : out reg32);
end and2vet32;

architecture estrut of and2vet32 is 

  component and2 is
    port(A,B : in  bit; S : out bit);
  end component and2;
  
begin

 -- implemente usando dois mux4 e um mux2
  Um0:  and2 port map(entr1(0),  entr2(0),  z(0));
  Um1:  and2 port map(entr1(1),  entr2(1),  z(1));
  Um2:  and2 port map(entr1(2),  entr2(2),  z(2));
  Um3:  and2 port map(entr1(3),  entr2(3),  z(3));
  Um4:  and2 port map(entr1(4),  entr2(4),  z(4));
  Um5:  and2 port map(entr1(5),  entr2(5),  z(5));
  Um6:  and2 port map(entr1(6),  entr2(6),  z(6));
  Um7:  and2 port map(entr1(7),  entr2(7),  z(7));
  Um8:  and2 port map(entr1(8),  entr2(8),  z(8));
  Um9:  and2 port map(entr1(9),  entr2(9),  z(9));
  Um10: and2 port map(entr1(10), entr2(10), z(10));
  Um11: and2 port map(entr1(11), entr2(11), z(11));
  Um12: and2 port map(entr1(12), entr2(12), z(12));
  Um13: and2 port map(entr1(13), entr2(13), z(13));
  Um14: and2 port map(entr1(14), entr2(14), z(14));
  Um15: and2 port map(entr1(15), entr2(15), z(15));
  Um16: and2 port map(entr1(16), entr2(16), z(16));
  Um17: and2 port map(entr1(17), entr2(17), z(17));
  Um18: and2 port map(entr1(18), entr2(18), z(18));
  Um19: and2 port map(entr1(19), entr2(19), z(19));
  Um20: and2 port map(entr1(20), entr2(20), z(20));
  Um21: and2 port map(entr1(21), entr2(21), z(21));
  Um22: and2 port map(entr1(22), entr2(22), z(22));
  Um23: and2 port map(entr1(23), entr2(23), z(23));
  Um24: and2 port map(entr1(24), entr2(24), z(24));
  Um25: and2 port map(entr1(25), entr2(25), z(25));
  Um26: and2 port map(entr1(26), entr2(26), z(26));
  Um27: and2 port map(entr1(27), entr2(27), z(27));
  Um28: and2 port map(entr1(28), entr2(28), z(28));
  Um29: and2 port map(entr1(29), entr2(29), z(29));
  Um30: and2 port map(entr1(30), entr2(30), z(30));
  Um31: and2 port map(entr1(31), entr2(31), z(31));


end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- xor2vet32(entr(31downto0),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity xor2vet32 is
  port(entr1, entr2: in  reg32;
       z    : out reg32);
end xor2vet32;

architecture estrut of xor2vet32 is 

  component xor2 is
    port(A,B : in  bit; S : out bit);
  end component xor2;
  
begin

 -- implemente usando dois mux4 e um mux2
  Um0:  xor2 port map(entr1(0),  entr2(0),  z(0));
  Um1:  xor2 port map(entr1(1),  entr2(1),  z(1));
  Um2:  xor2 port map(entr1(2),  entr2(2),  z(2));
  Um3:  xor2 port map(entr1(3),  entr2(3),  z(3));
  Um4:  xor2 port map(entr1(4),  entr2(4),  z(4));
  Um5:  xor2 port map(entr1(5),  entr2(5),  z(5));
  Um6:  xor2 port map(entr1(6),  entr2(6),  z(6));
  Um7:  xor2 port map(entr1(7),  entr2(7),  z(7));
  Um8:  xor2 port map(entr1(8),  entr2(8),  z(8));
  Um9:  xor2 port map(entr1(9),  entr2(9),  z(9));
  Um10: xor2 port map(entr1(10), entr2(10), z(10));
  Um11: xor2 port map(entr1(11), entr2(11), z(11));
  Um12: xor2 port map(entr1(12), entr2(12), z(12));
  Um13: xor2 port map(entr1(13), entr2(13), z(13));
  Um14: xor2 port map(entr1(14), entr2(14), z(14));
  Um15: xor2 port map(entr1(15), entr2(15), z(15));
  Um16: xor2 port map(entr1(16), entr2(16), z(16));
  Um17: xor2 port map(entr1(17), entr2(17), z(17));
  Um18: xor2 port map(entr1(18), entr2(18), z(18));
  Um19: xor2 port map(entr1(19), entr2(19), z(19));
  Um20: xor2 port map(entr1(20), entr2(20), z(20));
  Um21: xor2 port map(entr1(21), entr2(21), z(21));
  Um22: xor2 port map(entr1(22), entr2(22), z(22));
  Um23: xor2 port map(entr1(23), entr2(23), z(23));
  Um24: xor2 port map(entr1(24), entr2(24), z(24));
  Um25: xor2 port map(entr1(25), entr2(25), z(25));
  Um26: xor2 port map(entr1(26), entr2(26), z(26));
  Um27: xor2 port map(entr1(27), entr2(27), z(27));
  Um28: xor2 port map(entr1(28), entr2(28), z(28));
  Um29: xor2 port map(entr1(29), entr2(29), z(29));
  Um30: xor2 port map(entr1(30), entr2(30), z(30));
  Um31: xor2 port map(entr1(31), entr2(31), z(31));


end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- invvet32(entr(31downto0),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity invvet32 is
  port(entr: in  reg32;
       z    : out reg32);
end invvet32;

architecture estrut of invvet32 is 

  component inv is
    port(A : in bit; S : out bit);
  end component inv;
  
begin

 -- implemente usando dois mux4 e um mux2
  Um0:  inv port map(entr(0),  z(0));
  Um1:  inv port map(entr(1),  z(1));
  Um2:  inv port map(entr(2),  z(2));
  Um3:  inv port map(entr(3),  z(3));
  Um4:  inv port map(entr(4),  z(4));
  Um5:  inv port map(entr(5),  z(5));
  Um6:  inv port map(entr(6),  z(6));
  Um7:  inv port map(entr(7),  z(7));
  Um8:  inv port map(entr(8),  z(8));
  Um9:  inv port map(entr(9),  z(9));
  Um10: inv port map(entr(10), z(10));
  Um11: inv port map(entr(11), z(11));
  Um12: inv port map(entr(12), z(12));
  Um13: inv port map(entr(13), z(13));
  Um14: inv port map(entr(14), z(14));
  Um15: inv port map(entr(15), z(15));
  Um16: inv port map(entr(16), z(16));
  Um17: inv port map(entr(17), z(17));
  Um18: inv port map(entr(18), z(18));
  Um19: inv port map(entr(19), z(19));
  Um20: inv port map(entr(20), z(20));
  Um21: inv port map(entr(21), z(21));
  Um22: inv port map(entr(22), z(22));
  Um23: inv port map(entr(23), z(23));
  Um24: inv port map(entr(24), z(24));
  Um25: inv port map(entr(25), z(25));
  Um26: inv port map(entr(26), z(26));
  Um27: inv port map(entr(27), z(27));
  Um28: inv port map(entr(28), z(28));
  Um29: inv port map(entr(29), z(29));
  Um30: inv port map(entr(30), z(30));
  Um31: inv port map(entr(31), z(31));


end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- shiftleft32(entr(31downto0),z(31downto0))
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity shiftleft32 is
  port(entr: in  reg32;
       s    : in reg32;
       z    : out reg32);
end shiftleft32;

architecture estrut of shiftleft32 is 
  
  component mux2vet32 is
    port(entr1, entr2: in  reg32;
       sel  : in  bit;
       z    : out reg32);
  end component mux2vet32;

  component or2 is
    port(A,B : in  bit; S : out bit);
  end component or2;

  signal s1, s2, s3, s4, s5, s6, s7, s8, s9, s10 : reg32;
  signal q1,q2,q3,q4,q5,q6,q7,q8,q9,q10,q11,q12,q13 : bit;
  signal q14,q15,q16,q17,q18,q19,q20,q21,q22,q23,q24,q25,q26 : bit;
begin

  s1(0) <= '0';
  s1(31 downto 1) <= entr(30 downto 0);
  Um0: mux2vet32 port map (entr, s1, s(0), s2);

  s3(1 downto 0) <= "00";
  s3(31 downto 2) <= s2(29 downto 0);
  Um1: mux2vet32 port map (s2, s3, s(1), s4);

  s5(3 downto 0) <= "0000";
  s5(31 downto 4) <= s4(27 downto 0);
  Um2: mux2vet32 port map (s4, s5, s(2), s6);

  s7(7 downto 0) <= "00000000";
  s7(31 downto 8) <= s6(23 downto 0);
  Um3: mux2vet32 port map (s6, s7, s(3), s8);

  s9(15 downto 0) <= "0000000000000000";
  s9(31 downto 16) <= s8(15 downto 0);
  Um4: mux2vet32 port map (s8, s9, s(4), s10);

  Uo0: or2 port map (s(31), s(30), q1);
  Uo1: or2 port map (q1, s(29), q2);
  Uo2: or2 port map (q2, s(28), q3);
  Uo3: or2 port map (q3, s(27), q4);
  Uo4: or2 port map (q4, s(26), q5);
  Uo5: or2 port map (q5, s(25), q6);
  Uo6: or2 port map (q6, s(24), q7);
  Uo7: or2 port map (q7, s(23), q8);
  Uo8: or2 port map (q8, s(22), q9);
  Uo9: or2 port map (q9, s(21), q10);
  Uo10: or2 port map (q10, s(20), q11);
  Uo11: or2 port map (q11, s(19), q12);
  Uo12: or2 port map (q12, s(18), q13);
  Uo13: or2 port map (q13, s(17), q14);
  Uo14: or2 port map (q14, s(16), q15);
  Uo15: or2 port map (q15, s(15), q16);
  Uo16: or2 port map (q16, s(14), q17);
  Uo17: or2 port map (q17, s(13), q18);
  Uo18: or2 port map (q18, s(12), q19);
  Uo19: or2 port map (q19, s(11), q20);
  Uo20: or2 port map (q20, s(10), q21);
  Uo21: or2 port map (q21, s(9), q22);
  Uo22: or2 port map (q22, s(8), q23);
  Uo23: or2 port map (q23, s(7), q24);
  Uo24: or2 port map (q24, s(6), q25);
  Uo25: or2 port map (q25, s(5), q26);

  Um5: mux2vet32 port map (s10, "00000000000000000000000000000000", q26, z);

end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- shiftright32(entr(31downto0),z(31downto0))
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity shiftright32 is
  port(entr: in  reg32;
       s    : in reg32;
       z    : out reg32);
end shiftright32;

architecture estrut of shiftright32 is 
  
  component mux2vet32 is
    port(entr1, entr2: in  reg32;
       sel  : in  bit;
       z    : out reg32);
  end component mux2vet32;

  component or2 is
    port(A,B : in  bit; S : out bit);
  end component or2;

  signal s1, s2, s3, s4, s5, s6, s7, s8, s9, s10: reg32;
  signal q1,q2,q3,q4,q5,q6,q7,q8,q9,q10,q11,q12,q13 : bit;
  signal q14,q15,q16,q17,q18,q19,q20,q21,q22,q23,q24,q25,q26 : bit;
begin

  s1(31) <= '0';
  s1(30 downto 0) <= entr (31 downto 1);
  Um0: mux2vet32 port map (entr, s1, s(0), s2);

  s3(31 downto 30) <= "00";
  s3(29 downto 0) <= s2 (31 downto 2);
  Um1: mux2vet32 port map (s2, s3, s(1), s4);

  s5(31 downto 28) <= "0000";
  s5(27 downto 0) <= s4 (31 downto 4);
  Um2: mux2vet32 port map (s4, s5, s(2), s6);

  s7(31 downto 24) <= "00000000";
  s7(23 downto 0) <= s6 (31 downto 8);
  Um3: mux2vet32 port map (s6, s7, s(3), s8);

  s9(31 downto 16) <= "0000000000000000";
  s9(15 downto 0) <= s8 (31 downto 16);
  Um4: mux2vet32 port map (s8, s9, s(4), s10);


  Uo0: or2 port map (s(31), s(30), q1);
  Uo1: or2 port map (q1, s(29), q2);
  Uo2: or2 port map (q2, s(28), q3);
  Uo3: or2 port map (q3, s(27), q4);
  Uo4: or2 port map (q4, s(26), q5);
  Uo5: or2 port map (q5, s(25), q6);
  Uo6: or2 port map (q6, s(24), q7);
  Uo7: or2 port map (q7, s(23), q8);
  Uo8: or2 port map (q8, s(22), q9);
  Uo9: or2 port map (q9, s(21), q10);
  Uo10: or2 port map (q10, s(20), q11);
  Uo11: or2 port map (q11, s(19), q12);
  Uo12: or2 port map (q12, s(18), q13);
  Uo13: or2 port map (q13, s(17), q14);
  Uo14: or2 port map (q14, s(16), q15);
  Uo15: or2 port map (q15, s(15), q16);
  Uo16: or2 port map (q16, s(14), q17);
  Uo17: or2 port map (q17, s(13), q18);
  Uo18: or2 port map (q18, s(12), q19);
  Uo19: or2 port map (q19, s(11), q20);
  Uo20: or2 port map (q20, s(10), q21);
  Uo21: or2 port map (q21, s(9), q22);
  Uo22: or2 port map (q22, s(8), q23);
  Uo23: or2 port map (q23, s(7), q24);
  Uo24: or2 port map (q24, s(6), q25);
  Uo25: or2 port map (q25, s(5), q26);


  Um5: mux2vet32 port map (s10, "00000000000000000000000000000000", q26, z);



end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- multiplica por 1: A(31..0)*B(i) => S(32..0)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all; use work.p_wires.all;

entity m_p_1 is
  port(A,B : in  reg32;                 -- entradas A,B
       S : in bit;                      -- bit por multiplicar
       R : out reg33);                  -- produto parcial
end m_p_1;

architecture funcional of m_p_1 is 

  component adder32 is port(inpA, inpB : in reg32;
                          outC : out reg32;
                          vem  : in  bit;
                          vai  : out bit);
  end component adder32;

  signal somaAB : reg33;

begin

  U_soma: adder32 port map(A, B , somaAB(31 downto 0), '0', somaAB(32)); 

  R <= somaAB when S = '1' else ('0' & B);

end funcional;
-- -------------------------------------------------------------------

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- multiplicador combinacional
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all; use IEEE.numeric_std.all;
use work.p_wires.all;

entity mult32x32 is
  port(A, B : in  reg32;   -- entradas A,B
       prod : out reg32);  -- produto
end mult32x32;

architecture estrutural of mult32x32 is 
 
   component m_p_1 is port(A,B : in  reg32;
                           S   : in  bit;
                           R   : out reg33);
   end component m_p_1;
 
   signal p01,p02,p03,p04,p05,p06,p07,p08: reg33;
   signal p09,p10,p11,p12,p13,p14,p15,p16,p17: reg33;
   signal p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32: reg33;
 
  begin
    
    U_00: m_p_1 port map (A, "00000000000000000000000000000000", B(0), p01);
        prod(0) <= p01(0);
    U_01: m_p_1 port map (A, p01(32 downto 1), B(1), p02);
        prod(1) <= p02(0);
    U_02: m_p_1 port map (A, p02(32 downto 1), B(2), p03);
        prod(2) <= p03(0);
    U_03: m_p_1 port map (A, p03(32 downto 1), B(3), p04);
        prod(3) <= p04(0);
    U_04: m_p_1 port map (A, p04(32 downto 1), B(4), p05);
        prod(4) <= p05(0);
    U_05: m_p_1 port map (A, p05(32 downto 1), B(5), p06);
        prod(5) <= p06(0);
    U_06: m_p_1 port map (A, p06(32 downto 1), B(6), p07);
        prod(6) <= p07(0);
    U_07: m_p_1 port map (A, p07(32 downto 1), B(7), p08);
        prod(7) <= p08(0);
    U_08: m_p_1 port map (A, p08(32 downto 1), B(8), p09);
        prod(8) <= p09(0);
    U_09: m_p_1 port map (A, p09(32 downto 1), B(9), p10);
        prod(9) <= p10(0);
    U_10: m_p_1 port map (A, p10(32 downto 1), B(10), p11);
        prod(10) <= p11(0);
    U_11: m_p_1 port map (A, p11(32 downto 1), B(11), p12);
        prod(11) <= p12(0);
    U_12: m_p_1 port map (A, p12(32 downto 1), B(12), p13);
        prod(12) <= p13(0);
    U_13: m_p_1 port map (A, p13(32 downto 1), B(13), p14);
        prod(13) <= p14(0);
    U_14: m_p_1 port map (A, p14(32 downto 1), B(14), p15);
        prod(14) <= p15(0);
    U_15: m_p_1 port map (A, p15(32 downto 1), B(15), p16);
        prod(15) <= p16(0);
    U_16: m_p_1 port map (A, p16(32 downto 1), B(16), p17);
        prod(16) <= p17(0);
    U_17: m_p_1 port map (A, p17(32 downto 1), B(17), p18);
        prod(17) <= p18(0);
    U_18: m_p_1 port map (A, p18(32 downto 1), B(18), p19);
        prod(18) <= p19(0);
    U_19: m_p_1 port map (A, p19(32 downto 1), B(19), p20);
        prod(19) <= p20(0);
    U_20: m_p_1 port map (A, p20(32 downto 1), B(20), p21);
        prod(20) <= p21(0);
    U_21: m_p_1 port map (A, p21(32 downto 1), B(21), p22);
        prod(21) <= p22(0);
    U_22: m_p_1 port map (A, p22(32 downto 1), B(22), p23);
        prod(22) <= p23(0);
    U_23: m_p_1 port map (A, p23(32 downto 1), B(23), p24);
        prod(23) <= p24(0);
    U_24: m_p_1 port map (A, p24(32 downto 1), B(24), p25);
        prod(24) <= p25(0);
    U_25: m_p_1 port map (A, p25(32 downto 1), B(25), p26);
        prod(25) <= p26(0);
    U_26: m_p_1 port map (A, p26(32 downto 1), B(26), p27);
        prod(26) <= p27(0);
    U_27: m_p_1 port map (A, p27(32 downto 1), B(27), p28);
        prod(27) <= p28(0);
    U_28: m_p_1 port map (A, p28(32 downto 1), B(28), p29);
        prod(28) <= p29(0);
    U_29: m_p_1 port map (A, p29(32 downto 1), B(29), p30);
        prod(29) <= p30(0);
    U_30: m_p_1 port map (A, p30(32 downto 1), B(30), p31);
        prod(30) <= p31(0);
    U_31: m_p_1 port map (A, p31(32 downto 1), B(31), p32);
        prod(31) <= p32(0);
   
 end estrutural;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- sub32(entr1(31downto0),entr2(31downto0),z(31downto0))
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity sub32 is
  port(entr1, entr2: in  reg32;
       z    : out reg32);
end sub32;

architecture estrut of sub32 is 
  
  component adder32 is
    port(inpA, inpB : in reg32;
       outC : out reg32;
       vem  : in bit;
       vai  : out bit);
  end component adder32;

  component invvet32 is
    port(entr: in  reg32;
         z    : out reg32);
  end component invvet32;

  signal a : reg32;

begin

  Ui1: invvet32 port map (entr2, a);
  Ua1: adder32 port map (entr1, a, z, '1', open);
  
end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- demux2(d,s,p,q)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity demux2 is
  port(D : in  bit;
       S   : in  bit;
       P, Q   : out bit);
end demux2;

architecture estrut of demux2 is 
  component inv is
    port(A : in bit; S : out bit);
  end component inv;

  component and2 is
    port(A,B : in bit; S : out bit);
  end component and2;

  signal negs,f0,f1 : bit;

 begin

  Ui:  inv  port map(s,negs);
  Ua1: and2 port map(D,negs,P);
  Ua2: and2 port map(D,s,Q);
    
end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- demux2vet32(entr(31downto0),sel(4downto0),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity demux2vet32 is
  port(entr: in  reg32;
       sel  : in  bit;
       p, q    : out reg32);
end demux2vet32;

architecture estrut of demux2vet32 is 

  component demux2 is
    port(D : in  bit; S : in  bit; P, Q : out bit);
  end component demux2;
  
begin

  Um0:  demux2 port map(entr(0),  sel, p(0),  q(0));
  Um1:  demux2 port map(entr(1),  sel, p(1),  q(1));
  Um2:  demux2 port map(entr(2),  sel, p(2),  q(2));
  Um3:  demux2 port map(entr(3),  sel, p(3),  q(3));
  Um4:  demux2 port map(entr(4),  sel, p(4),  q(4));
  Um5:  demux2 port map(entr(5),  sel, p(5),  q(5));
  Um6:  demux2 port map(entr(6),  sel, p(6),  q(6));
  Um7:  demux2 port map(entr(7),  sel, p(7),  q(7));
  Um8:  demux2 port map(entr(8),  sel, p(8),  q(8));
  Um9:  demux2 port map(entr(9),  sel, p(9),  q(9));
  Um10: demux2 port map(entr(10), sel, p(10), q(10));
  Um11: demux2 port map(entr(11), sel, p(11), q(11));
  Um12: demux2 port map(entr(12), sel, p(12), q(12));
  Um13: demux2 port map(entr(13), sel, p(13), q(13));
  Um14: demux2 port map(entr(14), sel, p(14), q(14));
  Um15: demux2 port map(entr(15), sel, p(15), q(15));
  Um16: demux2 port map(entr(16), sel, p(16), q(16));
  Um17: demux2 port map(entr(17), sel, p(17), q(17));
  Um18: demux2 port map(entr(18), sel, p(18), q(18));
  Um19: demux2 port map(entr(19), sel, p(19), q(19));
  Um20: demux2 port map(entr(20), sel, p(20), q(20));
  Um21: demux2 port map(entr(21), sel, p(21), q(21));
  Um22: demux2 port map(entr(22), sel, p(22), q(22));
  Um23: demux2 port map(entr(23), sel, p(23), q(23));
  Um24: demux2 port map(entr(24), sel, p(24), q(24));
  Um25: demux2 port map(entr(25), sel, p(25), q(25));
  Um26: demux2 port map(entr(26), sel, p(26), q(26));
  Um27: demux2 port map(entr(27), sel, p(27), q(27));
  Um28: demux2 port map(entr(28), sel, p(28), q(28));
  Um29: demux2 port map(entr(29), sel, p(29), q(29));
  Um30: demux2 port map(entr(30), sel, p(30), q(30));
  Um31: demux2 port map(entr(31), sel, p(31), q(31));

end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- demux16vet32(entr(32downto0),sel(3downto0),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity demux16vet32 is
  port(entr: in  reg32;
       sel  : in  reg4;
       z1,z2,z3,z4,z5,z6,z7,z8,z9,z10,z11,z12,z13,z14,z15,z16 : out reg32);
end demux16vet32;

architecture estrut of demux16vet32 is 

  component demux2vet32 is
    port(entr: in  reg32;
       sel  : in  bit;
       p, q    : out reg32);
  end component demux2vet32;

  signal a0, a1, a2, a3, a4, a5, a6, a7, b0, b1, b2, b3, c0, c1 : reg32;

begin

  Udm00: demux2vet32 port map (entr, sel(3), c0, c1);

  Udm10: demux2vet32 port map (c0, sel(2), b0, b1);
  Udm11: demux2vet32 port map (c1, sel(2), b2, b3);

  Udm20: demux2vet32 port map (b0, sel(1), a0, a1);
  Udm21: demux2vet32 port map (b1, sel(1), a2, a3);
  Udm22: demux2vet32 port map (b2, sel(1), a4, a5);
  Udm23: demux2vet32 port map (b3, sel(1), a6, a7);

  Udm30: demux2vet32 port map (a0, sel(0), z1, z2);
  Udm31: demux2vet32 port map (a1, sel(0), z3, z4);
  Udm32: demux2vet32 port map (a2, sel(0), z5, z6);
  Udm33: demux2vet32 port map (a3, sel(0), z7, z8);
  Udm34: demux2vet32 port map (a4, sel(0), z9, z10);
  Udm35: demux2vet32 port map (a5, sel(0), z11, z12);
  Udm36: demux2vet32 port map (a6, sel(0), z13, z14);
  Udm37: demux2vet32 port map (a7, sel(0), z15, z16);


end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- demux16(entr,sel(3downto0),z1..z16)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity demux16 is
  port(entr: in  bit;
       sel  : in  reg4;
       z1,z2,z3,z4,z5,z6,z7,z8,z9,z10,z11,z12,z13,z14,z15,z16 : out bit);
end demux16;

architecture estrut of demux16 is 

  component demux2 is
    port(D : in  bit; S : in  bit; P, Q : out bit);
  end component demux2;

  signal a0, a1, a2, a3, a4, a5, a6, a7, b0, b1, b2, b3, c0, c1 : bit;

begin

  Udm00: demux2 port map (entr, sel(3), c0, c1);

  Udm10: demux2 port map (c0, sel(2), b0, b1);
  Udm11: demux2 port map (c1, sel(2), b2, b3);

  Udm20: demux2 port map (b0, sel(1), a0, a1);
  Udm21: demux2 port map (b1, sel(1), a2, a3);
  Udm22: demux2 port map (b2, sel(1), a4, a5);
  Udm23: demux2 port map (b3, sel(1), a6, a7);

  Udm30: demux2 port map (a0, sel(0), z1, z2);
  Udm31: demux2 port map (a1, sel(0), z3, z4);
  Udm32: demux2 port map (a2, sel(0), z5, z6);
  Udm33: demux2 port map (a3, sel(0), z7, z8);
  Udm34: demux2 port map (a4, sel(0), z9, z10);
  Udm35: demux2 port map (a5, sel(0), z11, z12);
  Udm36: demux2 port map (a6, sel(0), z13, z14);
  Udm37: demux2 port map (a7, sel(0), z15, z16);


end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- comparator(entr1(31downto0),entr2(31downto0),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity comparator is
  port(entr1, entr2: in  reg32;
       saida : out bit);
end comparator;

architecture estrut of comparator is 

  component xor2vet32 is
    port(entr1, entr2: in  reg32;
         z    : out reg32);
  end component xor2vet32;

  component inv is
    port(A : in bit;
       S : out bit);
  end component inv;

  component or2 is
    port(A,B : in bit;
       S   : out bit);
  end component or2;

  signal s : reg32;
  signal q1,q2,q3,q4,q5,q6,q7,q8,q9,q10,q11,q12,q13,q14,q15,q16 : bit;
  signal q17,q18,q19,q20,q21,q22,q23,q24,q25,q26,q27,q28,q29,q30,q31, diferente: bit;

begin


  Ux1: xor2vet32 port map (entr1, entr2, s);

  Uo0:  or2 port map(s(31),s(30), q1);
  Uo1:  or2 port map (q1,  s(29), q2);
  Uo2:  or2 port map (q2,  s(28), q3);
  Uo3:  or2 port map (q3,  s(27), q4);
  Uo4:  or2 port map (q4,  s(26), q5);
  Uo5:  or2 port map (q5,  s(25), q6);
  Uo6:  or2 port map (q6,  s(24), q7);
  Uo7:  or2 port map (q7,  s(23), q8);
  Uo8:  or2 port map (q8,  s(22), q9);
  Uo9:  or2 port map (q9,  s(21), q10);
  Uo10: or2 port map (q10, s(20), q11);
  Uo11: or2 port map (q11, s(19), q12);
  Uo12: or2 port map (q12, s(18), q13);
  Uo13: or2 port map (q13, s(17), q14);
  Uo14: or2 port map (q14, s(16), q15);
  Uo15: or2 port map (q15, s(15), q16);
  Uo16: or2 port map (q16, s(14), q17);
  Uo17: or2 port map (q17, s(13), q18);
  Uo18: or2 port map (q18, s(12), q19);
  Uo19: or2 port map (q19, s(11), q20);
  Uo20: or2 port map (q20, s(10), q21);
  Uo21: or2 port map (q21, s(9),  q22);
  Uo22: or2 port map (q22, s(8),  q23);
  Uo23: or2 port map (q23, s(7),  q24);
  Uo24: or2 port map (q24, s(6),  q25);
  Uo25: or2 port map (q25, s(5),  q26);
  Uo26: or2 port map (q26, s(4),  q27);
  Uo27: or2 port map (q27, s(3),  q28);
  Uo28: or2 port map (q28, s(3),  q29);
  Uo29: or2 port map (q29, s(2),  q30);
  Uo30: or2 port map (q30, s(1),  q31);
  Uo31: or2 port map (q31, s(0),  diferente);


  Ui1: inv port map (diferente, saida);

end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- IP_handler(entr1(31downto0),entr2(31downto0),z)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use work.p_wires.all;

entity IP_handler is
  port(E, ip : in  reg16;
       A, B : in reg32;
       op : in reg4;
       saida : out reg16);
end IP_handler;

architecture estrut of IP_handler is 

  component comparator is
  port(entr1, entr2: in  reg32;
       saida : out bit);
  end component comparator;

  component adder16 is
  port(inpA, inpB : in reg16;
       outC : out reg16;
       vem  : in bit;
       vai  : out bit);
  end component adder16;

  component mux2vet16 is
  port(entr1, entr2: in  reg16;
       sel  : in  bit;
       z    : out reg16);
  end component mux2vet16;

  component mux16vet16 is
  port(entr1, entr2, entr3, entr4, entr5, entr6, entr7, entr8, 
       entr9, entr10, entr11, entr12, entr13, entr14, entr15, entr16: in  reg16;
       sel  : in  reg4;
       z    : out reg16);
  end component mux16vet16;

  signal ip_plus1, bran, jump, halt, zero: reg16;
  signal sel_bran : bit;

begin

  jump <= E;

  bran1: adder16 port map (ip, x"0001", ip_plus1, '0', open);
  bran2: comparator port map (A, B, sel_bran);
  bran3: mux2vet16 port map (ip_plus1, E, sel_bran, bran);

  halt <= IP;

  zero <= x"0000";
  m1: mux16vet16 port map (zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,
                            jump, bran, halt, op, saida);


end architecture estrut;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++