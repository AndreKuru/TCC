library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tree is
    generic(addressSize     : 5,    
            dataElementSize : 8);
    port(--isLesserOrEqual            : in  std_logic;
        feature, constantFromMemory : in  std_logic_vector(n-1 downto 0);
        isNextLeft                  : out std_logic);
        --                          : out std_logic_vector(n-1 downto 0));
end tree;

architecture arch of tree is

component address_calculator is
  generic(n : natural);
  port(clk, reset, isNextLeft   : in  std_logic;
      adress0, adress1, adress2 : out std_logic_vector(n-1 downto 0));
end component;

component kernel is
    generic(n : natural);
    port(--isLesserOrEqual            : in  std_logic;
        feature, constantFromMemory : in  std_logic_vector(n-1 downto 0);
        isNextLeft                  : out std_logic);
end component;

component memory is
  generic (addressSize, dataElementSize : natural)
  port(
    clock, write_in                       : in  std_logic; 
    address0, address1, address2          : in  std_logic_vector(addressSize-1 downto 0);     
    data_in0, data_in1, data_in2          : in  std_logic_vector(dataElementSize-1 downto 0);
    data_out0, data_out1, data_out2       : out std_logic_vector(dataElementSize-1 downto 0)
  ); 
end component;
 
signal sIsNextLeft                                        : std_logic;
signal sAdress0, sAdress1, sAdress2, sConstantFromMemory  : std_logic_vector(n-1 downto 0);
	
begin
  AdressCalculator : address_calculator
    generic map(addressSize => n)
    port map(
      clk           => clk,
      reset         => reset,
      sIsNextLeft   => isNextLeft,
      sAdress0      => adress0,
      sAdress1      => adress1,
      sAdress2      => adress2
    );
  
  Kernel : kernel
    generic map(dataElementSize => n)
    port map(
      sIsLesserOrEqual    => isLesserOrEqual,
      feature             => feature,
      sConstantFromMemory => ConstantFromMemory,
      sIsNextLeft         => isNextLeft
    );

  Memory : memory
    generic(addressSize     => addressSize,
            dataElementSize => dataElementSize)
    port map(
      clk                => clk,
      write_in           => write_in,
      sAdress0           => address0,
      sAdress1           => address1,
      sAdress2           => address2,
      data_in0            => data_in0,
      data_in1            => data_in1,
      data_in2            => data_in2,
      sCostantFromMemory => data_out0
    );

end arch;