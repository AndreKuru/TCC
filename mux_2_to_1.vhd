library ieee;
use ieee.std_logic_1164.all;

entity mux_2_to_1 is
    generic(n : natural);
    port(
        a, b        : in  std_logic_vector(n-1 downto 0);
        selector    : in  std_logic;
        y           : out std_logic_vector(n-1 downto 0)
    );
end mux_2_to_1;

architecture arch of mux_2_to_1 is
begin
    with selector select
        y <= b when '1',
             a when others;
end arch;