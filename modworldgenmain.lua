local modenv = env
GLOBAL.setfenv(1, GLOBAL)

local seed = 83445 -- change this if you want to try a different map

local map_type = modenv.GetModConfigData("map_gen")
if map_type == "fixed" then
    print("Setting world gen random seed")
    -- SetWorldGenSeed is not defined yet :/
    math.randomseed(seed)
	math.random()
    SEED = seed
end

modenv.AddLevel(LEVELTYPE.SURVIVAL, {
    id = "GLUTTON",
    name = "Glutton preset",
    desc = "Glutton preset description!",
    location = "forest",
    version = 2,
    overrides = {
        flint = "often",
        grass = "often",
        sapling = "often",
        carrot = "often",
        mushroom = "often",
        spiders = "often",
        bees = "often",
        birds = "often",
        butterfly = "always",
        ponds = "often",
        pigs = "often",
        rock = "often",
        rabbits = "always",
    },
})
