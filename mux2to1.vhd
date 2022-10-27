library ieee;
use ieee.std_logic_1164.all;

entity mux2to1 is
  generic(n:natural);
  port(a, b     : in  std_logic_vector(n-1 downto 0);
      selector  : in  std_logic;
      y         : out std_logic_vector(n-1 downto 0));
end mux2to1;

architecture arch of mux2to1 is
begin
  with selector select
    y <= a when '1',
         b when others;
end arch;