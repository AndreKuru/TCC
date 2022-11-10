library ieee;
use ieee.std_logic_1164.all;

entity shiftBy1 is
  generic(n:natural);
  port(x : in  std_logic_vector(n-1 downto 0);
      y  : out std_logic_vector(n-1 downto 0));
end shiftBy1;

architecture arch of shiftBy1 is
begin
  y <= x << 1;
end arch;