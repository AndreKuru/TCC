library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity memory is
    generic (node_address_size  :natural;
            node_size           :natural;
            nodes_in_parallel   :natural := 3);
    port(
        clk, write_in   : in  std_logic; 
        -- node_addresses  : in  std_logic_vector(nodes_in_parallel * node_address_size - 1 downto 0);
        -- node_data_in    : in  std_logic_vector(nodes_in_parallel * node_size - 1 downto 0); 
        -- node_data_out   : out std_logic_vector(nodes_in_parallel * node_size - 1 downto 0)
        address0, address1, address2          : in  std_logic_vector(node_address_size-1 downto 0);     
        data_in0, data_in1, data_in2          : in  std_logic_vector(node_size-1 downto 0);
        data_out0, data_out1, data_out2       : out std_logic_vector(node_size-1 downto 0)
    ); 
  -- generic (addressSize, dataElementSize : natural);
  -- port(
  --   clk, write_in                         : in  std_logic; 
  --   address0, address1, address2          : in  std_logic_vector(addressSize-1 downto 0);     
  --   data_in0, data_in1, data_in2          : in  std_logic_vector(dataElementSize-1 downto 0);
  --   data_out0, data_out1, data_out2       : out std_logic_vector(dataElementSize-1 downto 0)
  -- ); 
end memory;

architecture arch of memory is

type ram_array is array (0 to (2**node_address_size)-1) of std_logic_vector (node_size-1 downto 0);

signal ram_data: ram_array :=(
    b"1000000000000011000000010111100110000000000000000",
    b"1000000000000010110000000000000100001110101110000",
    b"1000000000000001100000000000000100010101000111101",
    b"1000000000000010100000000000000001110111101011100",
    b"1000000000000001100000000000000001100101110000101",
    b"1000000000000000010000000000000100001010111000010",
    b"1000000000000010010000000000000110110111101011100",
    b"1000000000000001100000000000000011001010001111010",
    b"1000000000000010010000000000001011101000010100011",
    b"1100000000000000000000000000000000000000000000000",
    b"1000000000000000000000000000011010010110011001100",
    b"1100000000000000000000000000000000000000000000000",
    b"1100000000000000000000000000000000000000000000000",
    b"1100000000000000000000000000000000000000000000000",
    b"1100000000000000000000000000000000000000000000000",
    b"1100000000000000000000000000000000000000000000000",
    b"1100000000000000000000000000000000000000000000000",
    b"1100000000000000000000000000000000000000000000000",
    b"1100000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"1100000000000000000000000000000000000000000000000",
    b"1000000000000010010000000000001000000111101011100",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"1100000000000000000000000000000000000000000000000",
    b"1100000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000",
    b"0000000000000000000000000000000000000000000000000"
);

begin

    process(clock)
    begin
        if(rising_edge(clock)) then
        if(write_in='1') then 
            ram_data(to_integer(unsigned(address0))) <= data_in0;
            ram_data(to_integer(unsigned(address1))) <= data_in1;
            ram_data(to_integer(unsigned(address2))) <= data_in2;
        end if;
        end if;
    end process;

    data_out0 <= ram_data(to_integer(unsigned(address0)));
    data_out1 <= ram_data(to_integer(unsigned(address1)));
    data_out2 <= ram_data(to_integer(unsigned(address2)));

end arch;