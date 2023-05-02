library ieee;
use ieee.std_logic_1164.all;

entity tree_accelerator_tb is
end tree_accelerator_tb;

architecture tb of tree_accelerator_tb is
    signal feature, constantFromMemory : std_logic_vector(n-1 downto 0); -- inputs
    signal isNextLeft                  : std_logic; -- outputs
begin
    UUT: entity work.tree port map(
        feature => feature,
        constantFromMemory => constantFromMemory,
        isNextLeft => isNextLeft
    );


end tb;