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

constant middle_node        : natural := (nodes_in_parallel - 1) / 2;

signal comparators_output   : std_logic_vector(nodes_in_parallel - 1 downto 0);

begin
    
    Comparators_array : for i in 0 to nodes_in_parallel - 1 generate
        Comparator : entity work.lesser_or_equal_comparator
        generic map(size => threshold_size)
        port map(
            operand0            => features(threshold_size * (i + 1) - 1 downto threshold_size * i),
            operand1            => thresholds(threshold_size * (i + 1) - 1 downto threshold_size * i),
            is_lesser_or_equal  => comparators_output(i)
        );
    end generate Comparators_array;

    Multiple_comparators : if levels_in_parallel > 1 generate
    constant last_level_answers_amount : natural := 2**(levels_in_parallel - 1);
    constant last_level_answers_start  : natural := last_level_answers_amount - 1;
    constant last_level_answers_end    : natural := last_level_answers_start + last_level_answers_amount - 1;

    signal last_level_answers  : std_logic_vector(last_level_answers_amount - 1 downto 0);
    signal previous_answers    : std_logic_vector(last_level_answers_amount - 2 downto 0);
    begin
        last_level_answers  <= comparators_output(last_level_answers_end downto last_level_answers_start);
        previous_answers    <= comparators_output(last_level_answers_start - 1 downto 0);

        Top_answers_mux : entity work.answers_mux
        generic map(level_to_compute    => levels_in_parallel)
        port map(
            previous_answers    => previous_answers,
            answers_to_select   => last_level_answers,
            answers_selected    => next_nodes
        );
    end generate Multiple_comparators;

    Single_comparator: if levels_in_parallel = 1 generate
        next_nodes <= comparators_output;
    end generate Single_comparator;

end arch;