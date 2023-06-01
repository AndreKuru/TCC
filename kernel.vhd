library ieee;
use ieee.std_logic_1164.all;

entity kernel is
    generic(threshold_size      :natural;
            nodes_in_parallel   :natural;
            levels_in_parallel  :natural
    );
    port(
        features, thresholds          : in  std_logic_vector(threshold_size * nodes_in_parallel - 1 downto 0);
        next_nodes                  : out std_logic_vector(levels_in_parallel - 1 downto 0)
    );
end kernel;

architecture arch of kernel is

signal middle_node          : natural := (nodes_in_parallel - 1) / 2;

signal comparators_output       : std_logic_vector(nodes_in_parallel - 1 downto 0);

begin
    
    Comparator_array : for i in 0 to nodes_in_parallel - 1 generate
        Comparator : entity work.lesser_or_equal_comparator
        generic map(size => threshold_size)
        port map(
            operand0            => features(threshold_size * (i + 1) - 1 downto threshold_size * i),
            operand1            => thresholds(threshold_size * (i + 1) - 1 downto threshold_size * i),
            is_lesser_or_equal  => comparators_output(i)
        );
    end generate Comparator_array;

    Multiple_comparators : if nodes_in_parallel > 1 generate

    signal elements_a, elements_b   : std_logic_vector(nodes_in_parallel / 2 - 1 downto 0);
    signal selector                 : std_logic;

    begin
        elements_a  <= comparators_output(middle_node - 1 downto 0);
        elements_b  <= comparators_output(nodes_in_parallel - 1 downto middle_node + 1);
        selector    <= comparators_output(middle_node);
        Next_nodes_mux : entity work.mux_n_bits_to_1_bit
        generic map(
            elements_amount   => nodes_in_parallel - 1,
            selectors_amount => levels_in_parallel
        )
        port map(
            elements_a          => elements_a,
            elements_b          => elements_b,
            selector            => selector,
            selectors_output    => next_nodes
        );
    end generate Multiple_comparators;

    Single_comparator: if nodes_in_parallel <= 1 generate
        next_nodes <= comparators_output;
    end generate Single_comparator;

end arch;