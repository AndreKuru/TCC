library ieee;
use ieee.std_logic_1164.all;

entity children_calculator is
    generic(
        node_addresses_in_amount    : natural;
        node_addresses_size         : natural    -- levels_in_memory
    );
    port(
        parents_nodes                       : in  std_logic_vector(node_addresses_in_amount * node_addresses_size - 1 downto 0);
        childrens1_nodes, childrens2_nodes  : out std_logic_vector(node_addresses_in_amount * node_addresses_size - 1 downto 0)
    );
end children_calculator;

architecture arch of children_calculator is

begin

    Calculator_array : for i in 0 to node_addresses_in_amount - 1 generate

    signal parent_shifted : std_logic_vector(node_addresses_in_amount * node_addresses_size - 1 downto 0) 
    := parents_nodes(node_addresses_size * (i + 1) - 2 downto node_addresses_size * i) & '0';

    begin

        Children1 : entity work.adder
            generic map(n => node_addresses_size)
            port map(
                a       => parent_shifted,
                b       => (0 => '1', others => '0'),
                cin     => '0',
                cout    => open,
                y       => childrens1_nodes(node_addresses_size * (i + 1) - 1 downto node_addresses_size * i)
            );
    
        Children2 : entity work.adder
            generic map(n => node_addresses_size)
            port map(
                a       => parent_shifted,
                b       => (1 => '1', others => '0'),
                cin     => '0',
                cout    => open,
                y       => childrens2_nodes(node_addresses_size * (i + 1) - 1 downto node_addresses_size * i)
            );

    end generate Calculator_array;

end arch;