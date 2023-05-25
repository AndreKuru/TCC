library ieee;
use ieee.std_logic_1164.all;

entity kernel is
    generic(threshold_size      :natural;
            nodes_in_parallel   :natural;
            levels_in_parallel  :natural
    );
    port(
        feature, threshold          : in  std_logic_vector(threshold_size * nodes_in_parallel - 1 downto 0);
        next_nodes                  : out std_logic_vector(levels_in_parallel - 1 downto 0)
    );
end kernel;

architecture arch of kernel is

signal middle_node          : natural := (nodes_in_parallel - 1) / 2;

signal comparators_output   : std_logic_vector(nodes_in_parallel - 1 downto 0);

begin
    
    Comparator_array : for i in 0 to nodes_in_parallel - 1 generate
        Comparator : entity work.lesser_comparator
        generic map(size => threshold_size)
        port map(
            operand0    => feature(threshold * (i + 1) - 1 downto threshold * i),
            operand1    => threshold(threshold * (i + 1) - 1 downto threshold * i),
            is_lesser   => comparators_output(i)
        );
    end generate Comparator_array;

    Next_nodes_mux : entity work.mux_n_bits_to_1_bit
    generic map(
        element_amount   => nodes_in_parallel - 1,
        selectors_amount => levels_in_parallel
    )
    port map(
        elements_a          => comparators_output(middle_node - 1 downto 0),
        elements_b          => comparators_output(nodes_in_parallel - 1 downto middle_node + 1),
        selector            => comparators_output(middle_node),
        selectors_output    => next_nodes
    );

end arch;