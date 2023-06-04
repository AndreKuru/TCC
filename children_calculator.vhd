library ieee;
use ieee.std_logic_1164.all;

entity children_calculator is
    generic(
        node_addresses_in_amount    : natural;
        node_addresses_size         : natural    -- levels_in_memory
    );
    port(
        parents_nodes   : in  std_logic_vector(    node_addresses_in_amount * node_addresses_size - 1 downto 0);
        children_nodes  : out std_logic_vector(2 * node_addresses_in_amount * node_addresses_size - 1 downto 0)
    );
end children_calculator;

architecture arch of children_calculator is

begin

    Children_calculator_array : for i in 0 to node_addresses_in_amount - 1 generate

    constant child1         : natural := 2 * i;
    constant child1_start   : natural := node_addresses_size * child1;
    constant child1_end     : natural := node_addresses_size * (child1 + 1) - 1;
    constant child2         : natural := 2 * i + 1;
    constant child2_start   : natural := node_addresses_size * child2;
    constant child2_end     : natural := node_addresses_size * (child2 + 1) - 1;


    signal parent_shifted, child1_node, child2_node : std_logic_vector(node_addresses_size - 1 downto 0);

    begin

        parent_shifted <= parents_nodes(node_addresses_size * (i + 1) - 2 downto node_addresses_size * i) & '0';

        Child1_adder : entity work.adder
            generic map(n => node_addresses_size)
            port map(
                a       => parent_shifted,
                b       => (0 => '1', others => '0'),
                cin     => '0',
                cout    => open,
                y       => child1_node
            );
        children_nodes(child1_end downto child1_start) <= child1_node; -- better for debug
        Child2_adder : entity work.adder
            generic map(n => node_addresses_size)
            port map(
                a       => parent_shifted,
                b       => (1 => '1', others => '0'),
                cin     => '0',
                cout    => open,
                y       => child2_node
            );
        children_nodes(child2_end downto child2_start) <= child2_node; -- better for debug
    end generate Children_calculator_array;

end arch;