library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity memory is
    generic (
        node_address_size   : natural;
        -- nodes_amount        : natural;
        node_size           : natural;
        nodes_in_parallel   : natural
        );
    port(
        clk             : in  std_logic; 
        -- write_in        : in  std_logic; 
        -- node_data_in    : in  std_logic_vector(nodes_amount * node_size - 1 downto 0); 
        node_addresses  : in  std_logic_vector(nodes_in_parallel * node_address_size - 1 downto 0);
        node_data_out   : out std_logic_vector(nodes_in_parallel * node_size - 1 downto 0)
    ); 
end memory;

architecture arch of memory is

type ram_array is array (0 to (2**node_address_size) - 1) of std_logic_vector (node_size - 1 downto 0);

signal ram_data: ram_array :=(
    b"001000000000000000",
    b"011000000000000000",
    b"011000000000000000",
    b"100000000000000000",
    b"100000000000000001",
    b"100000000000000001",
    b"100000000000000000",
    b"100000000000000000"
);

begin

    -- process(clk, write_in)
    -- begin
    --     if rising_edge(clk) and write_in = '1' then 
    --         Data_serialize : for i in 0 to nodes_amount - 1 loop
    --             ram_data(i) <= node_data_in(node_size * (i + 1) - 1 downto node_size * i);
    --         end loop Data_serialize;
    --     end if;
    -- end process;

    Data_fetch : for i in 0 to nodes_in_parallel - 1 generate

    constant node_data_end        : natural := node_size * (i + 1) - 1;
    constant node_data_start      : natural := node_size * i;

    begin
        node_data_out(node_data_end downto node_data_start) <= ram_data(to_integer(unsigned(node_addresses)));
    end generate Data_fetch;

end arch;
