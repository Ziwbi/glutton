print("### Glutton Mod World Gen Main ###")


local map_type = GetModConfigData( "map_gen" )
if map_type == "fixed" then
	print("Setting world gen random seed")
	math.randomseed(83445)
end


AddLevel( "LEVELTYPE_GLUTTON", {
		id = "GLUTTON",
		name = "Glutton preset",
		desc = "Glutton preset description!",
        location = "forest",
        version = 2,
        overrides={
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