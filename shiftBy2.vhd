library ieee;
use ieee.std_logic_1164.all;

entity shiftBy2 is
  generic(n:natural);
  port(x : in  std_logic_vector(n-1 downto 0);
      y  : out std_logic_vector(n-1 downto 0));
end shiftBy2;

architecture arch of shiftBy2 is
begin
  y <= x << 2;
end arch;