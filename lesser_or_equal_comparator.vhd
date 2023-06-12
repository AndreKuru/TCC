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
signal subtractor_result, operand0_extended, operand1_extended  : std_logic_vector(size downto 0);
signal is_greater, overflow                                     : std_logic;
begin
    operand0_extended <= '0' & operand0;
    operand1_extended <= '0' & operand1;

    Subtractor : entity work.subtractor
        generic map(size => size + 1)
        port map(
            operand0 => operand1_extended,
            operand1 => operand0_extended,
            y        => subtractor_result,
            overflow => overflow
        );
    
    is_greater <= subtractor_result(size); --operando0 is greater than operand1
    is_lesser_or_equal <= is_greater xor overflow;
    
end arch;