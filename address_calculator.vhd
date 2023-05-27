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
        next_nodes      : in  std_logic_vector(levels_in_parallel - 1 downto 0);
        node_addresses  : out std_logic_vector(node_address_size * addresses_to_fetch_amount - 1 downto 0)
    );
end address_calculator;

architecture arch of address_calculator is

 -- signal levels_to_calculate : natural := levels_in_parallel + prefetch;


constant last_level_addresses_amount  : natural := 2 ** levels_in_parallel; -- this addresses will not be fetched in this cycle
constant total_addresses_amount       : natural := addresses_to_fetch_amount + last_level_addresses_amount;
constant last_level_addresses_end     : natural := node_address_size * total_addresses_amount - 1;
constant last_level_addresses_start   : natural := node_address_size * total_addresses_amount - (node_address_size * last_level_addresses_amount);

signal all_addresses            : std_logic_vector(last_level_addresses_end downto 0);
signal last_level_addresses     : std_logic_vector(last_level_addresses_end downto last_level_addresses_start);
signal index_output, mux_output : std_logic_vector(node_address_size - 1 downto 0);

begin
    Index_registrator : entity work.registrator
        generic map(data_size => node_address_size)
        port map(
            clk         => clk,
            reset       => reset,
            load        => '1',
            data_in     => mux_output,
            data_out    => index_output
        );
    
    all_addresses(node_address_size - 1 downto 0) <= index_output;

    Calculators_array : for i in 0 to levels_in_parallel - 1 generate

    constant parents_start    : natural := node_address_size * ((2 ** i)       - 1);
    constant parents_end      : natural := node_address_size * ((2 ** (i + 1)) - 1) - 1;
    constant parents_size     : natural := parents_end - parents_start;

    constant childrens1_start  : natural := parents_end + 1;
    constant childrens1_end    : natural := childrens1_start + parents_size;
    constant childrens2_start  : natural := childrens1_end + 1;
    constant childrens2_end    : natural := childrens2_start + parents_size;

    signal parents_nodes_s, childrens1_nodes_s, childrens2_nodes_s : std_logic_vector(parents_size downto 0);

    begin

        parents_nodes_s <= all_addresses(parents_end downto parents_start);

        all_addresses(childrens1_end downto childrens1_start)   <= childrens1_nodes_s;
        all_addresses(childrens2_end downto childrens2_start)   <= childrens2_nodes_s;

        N_Children_calculator : entity work.children_calculator
            generic map(
                node_addresses_in_amount    => 2 ** i,
                node_addresses_size         => node_address_size
            )
            port map(
                parents_nodes     => parents_nodes_s,
                childrens1_nodes  => childrens1_nodes_s,
                childrens2_nodes  => childrens2_nodes_s
            );
    end generate Calculators_array;

    last_level_addresses <= all_addresses(last_level_addresses_end downto last_level_addresses_start);
    
    Mux_of_last_level : entity work.mux_n_unified_to_1
        generic map(
            elements_amount => last_level_addresses_amount,
            elements_size   => node_address_size,
            selector_size   => levels_in_parallel
        )
        port map(
            elements    => last_level_addresses,
            selector    => next_nodes,
            y           => mux_output
        );

    node_addresses <= all_addresses(last_level_addresses_start - 1 downto 0);

end arch;