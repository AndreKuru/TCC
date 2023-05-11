library ieee;
use ieee.std_logic_1164.all;

entity subtractor is
  generic(size : natural);
  port(operand0, operand1 : in  std_logic_vector(size - 1 downto 0);
      cout  : out std_logic;
      y     : out std_logic_vector(size - 1 downto 0));
end subtractor;

architecture arch of subtractor is
signal temp  : std_logic_vector(size  downto 0);

begin
  temp <= (operand0(size - 1) & operand0) - (operand1(size - 1) & operand1);
  cout <= temp(size); 
  y <= temp(size - 1 downto 0);
end arch;