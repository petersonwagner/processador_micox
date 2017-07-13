-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UFPR, BCC, ci210 2016-2 trabalho semestral, autor: Roberto Hexsel, 07out
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

use work.p_wires.all;

entity mem_prog is
  port (ender : in  reg6;
        instr : out reg32);

  type t_prog_mem is array (0 to 63) of reg32;

  -- memoria de programa contem somente 64 palavras
  constant program : t_prog_mem := (
    --r1 = n
    --r2 = result

    --op, a, b, c, const
    x"00000000",                        -- nop

    x"b0010005",                        -- addi r1,r0,num    |  n = num;
    x"b0020001",                        -- addi r2,r0,1      |  result = 1;
    x"c1000000",                        -- display r1        |  printf("%d", n);

    x"e1000009",                        -- bran r1, 0, FIM   |  if (n == 0) goto fim;

    --INICIO:
    x"32120000",                        -- mul r2,r2,r1      |  result = result * n;
    x"b101ffff",                        -- addi r1,r1,-1     |  n = n + (-1);

    x"e1000009",                        -- bran r2, 0, FIM   |  if (n == 0) goto fim;
    x"d1000005",                        -- jump INICIO       |  goto inicio;

    --FIM:
    x"c2000000",                        -- display r2        |  printf("%d", result);

    x"f0000000",                        -- halt
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000",
    x"00000000");

  function BV2INT6(S: reg6) return integer is
    variable result: integer;
  begin
    if S(5) = '1' then result := -63; else result := 0; end if;
    for i in S'range loop
      result := result * 2;
      if S(i) = '1' then
        result := result + 1;
      end if;
    end loop;
    return result;
  end BV2INT6;
  
end mem_prog;

-- nao altere esta arquitetura
architecture tabela of mem_prog is
begin  -- tabela

  instr <= program( BV2INT6(ender) );

end tabela;

