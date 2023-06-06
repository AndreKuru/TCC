package accelerator_pkg is
    constant FEATURES_AMOUNT            : natural := 13;        -- f
    constant FEATURES_AMOUNT_REMAINING  : natural := 3;
    constant FEATURE_INDEX_SIZE         : natural := 4;         -- lf
    constant THRESHOLD_SIZE             : natural := 26;        -- t
    constant THRESHOLD_SIZE_COMPLEMENT  : natural := 0;
    constant CLASS_SIZE                 : natural := 2;         -- c
    constant CLASS_SIZE_COMPLEMENT      : natural := 28;
    constant NODES_AMOUNT               : natural := 63;        -- n = 2**m - 1
    constant NODE_SIZE                  : natural := 31;        -- s = max(c, (lf + t)) + 1
    constant LEVELS_IN_MEMORY           : natural := 6;         -- m = p * i
    constant LEVELS_IN_PARALLEL         : natural := 6;         -- p
    constant PREFETCH                   : natural := 0;
    constant NODES_TO_WRITE             : natural := 2;
 -- constants for the tree serialized in the file: wine

end package accelerator_pkg;
