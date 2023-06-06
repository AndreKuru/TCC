library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity memory is
    generic (
        node_address_size   : natural;
        node_size           : natural;
        nodes_to_write      : natural;
        nodes_in_parallel   : natural
    );
    port(
        clk, write_in           : in  std_logic; 
        node_data_write         : in  std_logic_vector(nodes_to_write * node_size - 1 downto 0); 
        node_addresses_write    : in  std_logic_vector(node_address_size - 1 downto 0);
        node_addresses_read     : in  std_logic_vector(nodes_in_parallel * node_address_size - 1 downto 0);
        node_data_read          : out std_logic_vector(nodes_in_parallel * node_size - 1 downto 0)
    ); 
end memory;

architecture arch of memory is

type ram_array is array (0 to (2**node_address_size) - 2) of std_logic_vector (node_size - 1 downto 0);

signal ram_data: ram_array :=(
    b"0110010111100110000000000000000",
    b"0101100000000100001110101110000",
    b"0011000000000100010101000111101",
    b"0101000000000001110111101011100",
    b"0011000000000001100101110000101",
    b"0000100000000100001010111000010",
    b"0010000100001111000000000000000",
    b"0011000000000011001010001111010",
    b"0000000000011011000001111010111",
    b"1000000000000000000000000000010",
    b"0000000000011010010110011001100",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000000",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000001",
    b"0010000011000101000000000000000",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000000",
    b"1000000000000000000000000000000",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000000",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000010",
    b"1000000000000000000000000000000",
    b"1000000000000000000000000000000",
    b"1000000000000000000000000000000",
    b"1000000000000000000000000000000",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001",
    b"1000000000000000000000000000001"
);

begin

    process(clk, write_in)
    begin
        if rising_edge(clk) and write_in = '1' then 
            Data_serialize : for i in 0 to nodes_to_write - 1 loop
                ram_data(to_integer((i * node_address_size) + unsigned(node_addresses_write(node_address_size - 1 downto 0)))) 
                        <= 
                        node_data_write(node_size * (i + 1) - 1 downto node_size * i);
            end loop Data_serialize;
        end if;
    end process;

    Data_fetch : for i in 0 to nodes_in_parallel - 1 generate

    constant node_data_end        : natural := node_size * (i + 1) - 1;
    constant node_data_start      : natural := node_size * i;
    constant node_address_end        : natural := node_address_size * (i + 1) - 1;
    constant node_address_start      : natural := node_address_size * i;

    begin
        node_data_read(node_data_end downto node_data_start) <= ram_data(to_integer(unsigned(node_addresses_read(node_address_end downto node_address_start))));
    end generate Data_fetch;

end arch;
