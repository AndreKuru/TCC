package accelerator_pkg is
    constant FEATURES_AMOUNT            : natural := 13;
    constant FEATURES_AMOUNT_REMAINING  : natural := 3;
    constant FEATURE_INDEX_SIZE         : natural := 4;
    constant THRESHOLD_SIZE             : natural := 26;
    constant THRESHOLD_SIZE_COMPLEMENT  : natural := 0;
    constant CLASS_SIZE                 : natural := 2;
    constant CLASS_SIZE_COMPLEMENT      : natural := 28;
    constant NODES_AMOUNT               : natural := 64;
    constant NODE_SIZE                  : natural := 31;
    constant LEVELS_IN_MEMORY           : natural := 6;
    constant LEVELS_IN_PARALLEL         : natural := 1;
    constant PREFETCH                   : natural := 0;
 -- constants for the tree serialized in the file: wine

    function Bit_length (
        x : positive)
        return natural;

end package accelerator_pkg;

-- Package Body Section
package body accelerator_pkg is
    function Bit_length (
        x : positive) 
    return natural is
        variable i : natural;
    begin
        i := 0;  
        while (2**i < x) and i < 63 loop
            i := i + 1;
        end loop;
            i := i + 1;
        return i;
    end function;

end package body accelerator_pkg;
