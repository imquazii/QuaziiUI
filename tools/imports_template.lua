---@type table<string, string>
local L = QuaziiUI.L

--[[ ---@type table
QuaziiUI.imports.MDT = {
    ---@type table
    [1] = {
        ---@type string
        name = L["PUG 'Push W' Routes"],
        ---@type table<string>
        Routes = {
            "{MDT_W_ROUTES}"
        }
    },
    [2] = {
        ---@type string
        name = L["AdvRoutes"],
        ---@type table<string>
        Routes = {
            "{MDT_ADV_ROUTES}"
        }
    }
} ]]

---@type table
QuaziiUI.imports.ElvUI = {
    cell = {
        ---@type string
        data = "{CELL_IMPORT}"
    },
    ---@type table
    healer = {
        data = "{HEALER_IMPORT}"
    },
    ---@type table
    tankdps = {
        ---@type string
        data = "{TANK_DPS_IMPORT}"
    }
}

---@type table
QuaziiUI.imports.WAStrings = {
    ---@type table
    [0] = {
        ---@type string
        name = "Anchor WeakAuras",
        ---@type table<string>
        WAs = {
            "{ANCHOR_WA}"
        }
    },
    ---@type table
    [1] = {
        ---@type string
        name = L["ClassWA"],
        ---@type table<string>
        WAs = {
            "{CLASS_WA}"
        }
    },
    ---@type table
    [2] = {
        ---@type string
        name = L["NonClassWA"],
        ---@type table<string>
        WAs = {
            "{NON_CLASS_WA}"
        }
    }
}
---@type table
QuaziiUI.imports.BigWigs = {
    ---@type string
    data = "{BIGWIGS}"
}

---@type table
QuaziiUI.imports.OmniCD = {
    ---@type string
    data = "{OMNICD}"
}

---@type table
QuaziiUI.imports.OmniCDHealer = {
    ---@type string
    data = "{OMNICD-HEALS}"
}

---@type table
QuaziiUI.imports.Details = {
    ---@type string
    data = "{DETAILS}"
}

---@type table
QuaziiUI.imports.Plater = {
    ---@type string
    data = "{PLATER}"
}

---@type table
QuaziiUI.imports.Cell = {
    ---@type table
    tankdps = {
        ---@type string
        data = "{CELL_TANKDPS}"
    },
    ---@type table
    healer = {
        ---@type string
        data = "{CELL_HEALER}"
    }
}

---@type table
QuaziiUI.imports.BigWigsBosses = {
    ["BigWigs_Bosses_Ara-Kara, City of Echoes Trash"] = {
        [438877] = 966903,
        [434802] = 966903,
        [434793] = 966903,
        [453161] = 966903,
        [434824] = 966903,
        [465012] = 968951,
        [438826] = 966903,
        [433841] = 966903,
        [448248] = 966903,
        [433845] = 966903,
        [434252] = 966903
    },
    ["BigWigs_Bosses_City of Threads Trash"] = {
        [452162] = 966903,
        [436205] = 966903,
        [450784] = 966903,
        [443507] = 966903,
        [443430] = 966903,
        [441795] = 0,
        [446717] = 966903,
        [451543] = 966903,
        [451423] = 966903,
        [451222] = 966903,
        [445813] = 966903,
        [434137] = 966903,
        [443437] = 966903,
        [443500] = 966903,
        [447271] = 966903,
        [446086] = 966903
    },
    ["BigWigs_Bosses_The Stonevault Trash"] = {
        [426308] = 975095,
        [428703] = 966903,
        [447141] = 966903,
        [459210] = 967927,
        [429427] = 966903,
        [448640] = 966903,
        [445207] = 966903,
        [429545] = 966903,
        [425027] = 966903,
        [426771] = 968951,
        [426345] = 966903,
        [449130] = 966903,
        [449455] = 966903,
        [449154] = 968951,
        [425974] = 966903,
        [428879] = 966903,
        [429109] = 966903
    },
    ["BigWigs_Bosses_Mists of Tirna Scithe Trash"] = {
        [326046] = 975095,
        [324923] = 966903,
        [324776] = 966903,
        [340160] = 966903,
        [340300] = 970999,
        [460092] = 966903,
        [322569] = 967927,
        [340208] = 970999,
        [325418] = 967159,
        [324914] = 975095,
        [463248] = 967159,
        [463256] = 966903,
        [322557] = 975095,
        [340279] = 975095,
        [340289] = 970999,
        [322486] = 966903,
        [326090] = 975095,
        [340544] = 966903,
        [340304] = 966903,
        [326021] = 966903,
        [321968] = 966903,
        [325021] = 967159,
        [340305] = 966903,
        [340189] = 966903,
        [325224] = 966903,
        [322938] = 966903,
        [463217] = 970999
    },
    ["BigWigs_Bosses_The Dawnbreaker Trash"] = {
        [451117] = 966903,
        [450854] = 966903,
        [432448] = 966903,
        [431309] = 975095,
        [432565] = 966903,
        [431364] = 966903,
        [451119] = 967159,
        [431349] = 966903,
        [432520] = 966903,
        [450756] = 966903,
        [431304] = 966903,
        [451098] = 966903,
        [431491] = 967927,
        [451107] = 966903,
        [451102] = 966903,
        [451097] = 966903,
        [431494] = 966903
    },
    ["BigWigs_Bosses_The Necrotic Wake Trash"] = {
        [338353] = 966903,
        [327240] = 966903,
        [333479] = 966903,
        [327396] = 966903,
        [343470] = 966903,
        [338456] = 970999,
        [324372] = 966903,
        [345623] = 966903,
        [322756] = 966903,
        [338357] = 966903,
        [321780] = 966903,
        [324387] = 966903,
        [335141] = 966903,
        [338606] = 2015479,
        [323347] = 966903,
        [333477] = 966903,
        [320464] = 966903,
        [324293] = 966903,
        [335143] = 966903,
        [324394] = 967925,
        [327130] = 966903,
        [323471] = 966903,
        [320822] = 3064053,
        [334748] = 966903,
        [328667] = 966903
    }
}
