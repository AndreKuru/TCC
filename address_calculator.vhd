library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all -- only power used

entity address_calculator is
    generic(
        levels_in_parallel  : natural; -- := 1;
        prefetch            : natural; -- := 0;
        node_address_size   : natural  -- levels_in_memory
    );
    port(
        clk, reset      : in  std_logic;
        next_nodes      : in  std_logic; --_vector(levels_in_parallel - 1 downto 0);
        node_addresses  : out std_logic_vector(node_address_size downto 0)
    );
end address_calculator;

architecture arch of address_calculator is

 -- signal levels_to_calculate : natural := levels_in_parallel + prefetch;

signal index_output, shifter_output, single_address1_output, single_address2_output, mux_output : std_logic_vector(node_address_size - 1 downto 0);

signal all_addresses : std_logic_vector(node_address_size * ((2 ** levels_in_parallel) - 1) downto 0)

begin
    Index_registrator : entity work.registrator
        generic map(n => node_address_size)
        port map(
          clk   => clk,
          load  => '1', --TODO
          d     => mux_output,
          q     => index_output
        );
    
    all_addresses(node_address_size - 1 downto 0) <= index_output

    Calculators : for i in 0 to levels_in_parallel - 1 generate

        signal elements_amount_start    : natural := (2 ** i)       - 1
        signal elements_amount_end      : natural := (2 ** (i + 1)) - 1
        signal elements_amount_size     : natural := elements_amount_end - elements_amount_start

        entity work.children_calculator
            generic map(
                node_addresses_in_amount    => 2 ** i,
                node_addresses_size         => node_address_size
            )
            port map(
                parent_node     => all_addresses(node_address_size * elements_amount_end - 1 downto node_address_size * elements_amount_start)
                children1_node  => --TODO
                children2_node  =>
            );
    end generate Calculators;
    

    Single_address_calculator0 : single_address_calculator
        generic map(node_address_size => node_address_size)
        port map(
            clk             => clk,
            next_node_left  => next_nodes, --(0),
            node_address_in => index_output,
            adder1_output   => single_address1_output,
            adder2_output   => single_address2_output
        );

    Mux_from_adders : mux_2_to_1
        generic map(n => node_address_size)
        port map(
            a           => single_address1_output,
            b           => single_address2_output,
            selector    => next_nodes, --(0),
            y           => mux_output
        );

    node_addresses <= index_output;

end arch;