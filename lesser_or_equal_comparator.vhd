library ieee;
use ieee.std_logic_1164.all;


entity lesser_or_equal_comparator is
    generic(size : natural);
    port(
        operand0, operand1  : in  std_logic_vector(size - 1 downto 0);
        is_lesser_or_equal  : out std_logic
    );
end lesser_or_equal_comparator;

architecture arch of lesser_or_equal_comparator is
signal subtractor_result    : std_logic_vector(size - 1 downto 0);
signal is_greater, overflow : std_logic;
-- signal is_lesser, is_equal  : std_logic;
begin
    Subtractor0 : entity work.subtractor
        generic map(size => size)
        port map(
            operand0 => operand1,
            operand1 => operand0,
            y        => subtractor_result,
            overflow => overflow
        );
    
    is_greater <= subtractor_result(size - 1);
    is_lesser_or_equal <= is_greater xor overflow;
    
--    Equal : entity work.is_zero
--        generic map(size => size)
--        port map(
--            number  => subtractor_result,
--            is_zero => is_equal
--        );
--    
--    is_lesser_or_equal <=   '1' when is_lesser = '1' or is_equal = '1' else
--                            '0';
end arch;