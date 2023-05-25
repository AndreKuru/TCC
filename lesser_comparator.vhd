library ieee;
use ieee.std_logic_1164.all;


entity lesser_comparator is
    generic(size : natural);
    port(
        operand0, operand1  : in  std_logic_vector(size - 1 downto 0);
        is_lesser           : out std_logic
    );
end lesser_comparator;

architecture arch of lesser_comparator is

begin
    Subtractor0 : entity work.subtractor
        generic map(size => size)
        port map(
            operand0 => operand0,
            operand1 => operand1,
            cout     => is_lesser
        );
end arch;