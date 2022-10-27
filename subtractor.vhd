library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity subtractor is
  generic(n:natural);
  port(a, b : in  std_logic_vector(n-1 downto 0);
      cout  : out std_logic;
      y     : out std_logic_vector(n-1 downto 0));
end subtractor;

architecture arch of subtractor is
signal temp  : std_logic_vector(n downto 0);

begin
  temp <= ('0' & a) - ('0' & b);
  cout <= temp(n); 
  y <= temp(n-1 downto 0);
end arch;