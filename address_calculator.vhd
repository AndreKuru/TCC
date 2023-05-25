library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all; -- only power used

entity address_calculator is
    generic(
        levels_in_parallel          : natural; -- := 1;
        prefetch                    : natural; -- := 0;
        addresses_to_fetch_amount   : natural; -- nodes_in_parallel
        node_address_size           : natural  -- levels_in_memory
    );
    port(
        clk, reset      : in  std_logic;
        next_nodes      : in  std_logic_vector(levels_in_parallel - 2 downto 0);
        node_addresses  : out std_logic_vector(node_address_size * addresses_to_fetch_amount - 1 downto 0)
    );
end address_calculator;

architecture arch of address_calculator is

 -- signal levels_to_calculate : natural := levels_in_parallel + prefetch;

signal index_output, shifter_output, single_address1_output, single_address2_output, mux_output : std_logic_vector(node_address_size - 1 downto 0);

signal last_level_addresses_amount  : natural := 2 ** levels_in_parallel; -- this addresses will not be fetched in this cycle
signal total_addresses_amount       : natural := addresses_to_fetch_amount + last_level_addresses_amount;
signal last_level_addresses_start   : natural := node_address_size * total_addresses_amount - (node_address_size * total_addresses_amount);
signal last_level_addresses_end     : natural := node_address_size * total_addresses_amount - 1;

signal all_addresses    : std_logic_vector(last_level_addresses_end downto 0);
signal mux_output       : std_logic_vector(node_address_size - 1 downto 0);

begin
    Index_registrator : entity work.registrator
        generic map(n => node_address_size)
        port map(
          clk   => clk,
          load  => reset,
          d     => mux_output,
          q     => index_output
        );
    
    all_addresses(node_address_size - 1 downto 0) <= index_output;

    Calculators_array : for i in 0 to levels_in_parallel generate

    signal parents_start    : natural := node_address_size * ((2 ** i)       - 1);
    signal parents_end      : natural := node_address_size * ((2 ** (i + 1)) - 1) - 1;
    signal parents_size     : natural := parents_end - parents_start;

    begin

        N_Children_calculator : entity work.children_calculator
            generic map(
                node_addresses_in_amount    => 2 ** i,
                node_addresses_size         => node_address_size
            )
            port map(
                parent_node     => all_addresses(parents_end downto parents_start),
                children1_node  => all_adresses(     parents_size  + parents_end + 1 downto                parents_end + 1),
                children2_node  => all_adresses((2 * parents_size) + parents_end + 2 downto parents_size + parents_end + 2)
            );
    end generate Calculators_array;
    
    Mux_of_last_level : entity work.mux_n_unified_to_1
        generic map(
            elements_size   => node_address_size,
            elements_amount => last_level_addresses_amount,
            selector_size   => levels_in_parallel - 1
        )
        port map(
            elements    => all_addresses(last_level_addresses_end downto last_level_addresses_start),
            selector    => next_nodes,
            y           => mux_output
        );

    node_addresses <= all_addresses(last_level_addresses_start - 1 downto 0);

end arch;