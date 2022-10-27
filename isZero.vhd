library ieee;
use ieee.std_logic_1164.all;

entity isZero is
  generic(n:natural);
  port(x  : in  std_logic_vector(n-1 downto 0);
      y   : out std_logic_vector(n-1 downto 0));
end isZero;

architecture arch of isZero is
begin
  y <= '1' when x = 0 else '0';
end arch;