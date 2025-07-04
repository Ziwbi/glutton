local modenv = env
GLOBAL.setfenv(1, GLOBAL)

modenv.FrontEndAssets = {
    Asset("IMAGE", "images/world_seed.tex"),
    Asset("ATLAS", "images/world_seed.xml"),
}
modenv.ReloadFrontEndAssets()

STRINGS.UI.CUSTOMIZATIONSCREEN.WORLDSEED = STRINGS.UI.CUSTOMIZATIONSCREEN.WORLDSEED or "Leave blank for a random seed."
STRINGS.UI.CUSTOMIZATIONSCREEN.ICON_TITLES.WORLDSEED = STRINGS.UI.CUSTOMIZATIONSCREEN.ICON_TITLES.WORLDSEED or "World Seed"

modenv.AddCustomizeItem(LEVELCATEGORY.WORLDGEN, "misc", "worldseed", {desc = {}, order = -10, value = "", widget_type = "textentry", image = "world_seed.tex", atlas = "images/world_seed.xml", options_remap = {img = "blank_world.tex"}})

