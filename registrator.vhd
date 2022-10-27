library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity registrator is
  generic(n: natural);
  port(clk, load  : in  std_logic
      d           : in  std_logic_vector(n-1 downto 0);
      q           : out std_logic_vector(n-1 downto 0));
  end registrator;

architecture arch of registrator is
begin
  process(clk, carga)
  begin
    if (rising_edge(clk) and load = '1') then
      q <= d;
    end if;
  end process;
end arch;