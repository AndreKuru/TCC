library ieee;
use ieee.std_logic_1164.all;


entity kernel is
    generic(threshold_size      :natural;
            nodes_in_parallel   :natural);
    port(
        feature, threshold          : in  std_logic_vector(threshold_size * nodes_in_parallel - 1 downto 0);
        next_nodes                  : out std_logic --_vector(nodes_in_parallel - 1 downto 0)
        );
end kernel;

architecture arch of kernel is
component lesser_comparator is
    generic(size :natural);
    port(
        operand0, operand1  : in  std_logic_vector(size - 1 downto 0);
        is_lesser           : out std_logic
    );
end component;
begin
    Comparator0 : lesser_comparator
    generic map(size => threshold_size)
    port map(
        operand0    => feature,
        operand1    => threshold,
        is_lesser   => next_nodes
    );
end arch;