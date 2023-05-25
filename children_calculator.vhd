library ieee;
use ieee.std_logic_1164.all;

entity children_calculator is
    generic(
        node_addresses_in_amount    : natural;
        node_addresses_size         : natural    -- levels_in_memory
    );
    port(
        parent_node                     : in  std_logic_vector(node_addresses_in_amount * node_addresses_size - 1 downto 0);
        children1_node, children2_node  : out std_logic_vector(node_addresses_in_amount * node_addresses_size - 1 downto 0)
    );
end children_calculator;

architecture arch of children_calculator is

begin

    Calculator_array : for i in 0 to node_addresses_in_amount - 1 generate
    
        Children1 : entity work.adder
            generic map(n => node_addresses_size)
            port map(
                a       => parent_node(node_addresses_size * (i + 1) - 2 downto node_addresses_size * i) & 0,
                b       => (0 => '1', others => '0'),
                cin     => '0',
                cout    => open,
                y       => children1_node(node_addresses_size * (i + 1) - 1 downto node_addresses_size * i)
            );
    
        Children2 : entity work.adder
            generic map(n => node_addresses_size)
            port map(
                a       => parent_node(node_addresses_size * (i + 1) - 2 downto node_addresses_size * i) & 0,
                b       => (1 => '1', others => '0'),
                cin     => '0',
                cout    => open,
                y       => children2_node(node_addresses_size * (i + 1) - 1 downto node_addresses_size * i)
            );

    end generate Calculator_array;

end arch;