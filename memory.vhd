library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity memory is
  generic (addressSize, dataElementSize : natural)
  port(
    clk, write_in                         : in  std_logic; 
    address0, address1, address2          : in  std_logic_vector(addressSize-1 downto 0);     
    data_in0, data_in1, data_in2          : in  std_logic_vector(dataElementSize-1 downto 0);
    data_out0, data_out1, data_out2       : out std_logic_vector(dataElementSize-1 downto 0)
  ); 
end memory;

architecture arch of memory is

type ram_array is array (0 to (2**addressSize)-1) of std_logic_vector (dataElementSize-1 downto 0);

signal ram_data: ram_array :=(
  b"10000000",b"01001101",x"77",x"67",
  x"99",x"25",x"00",x"1a", 
  x"00",x"00",x"00",x"00",
  x"00",x"00",x"00",x"00",
  x"00",x"0f",x"00",x"00",
  x"00",x"00",b"00111100",x"00",
  x"00",x"00",x"00",x"00",
  x"00",x"00",x"00",x"1f"
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