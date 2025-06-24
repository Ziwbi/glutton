-- This information tells other players more about the mod
name = "Glutton Tournament Game Mode"
description = "Eat food, get points, work together.\
\
This is a cooperative tournament mode. The object is for your team to collect food and eat as many calories before the time runs out. Fire roasting and crock pot cooking will give a 3x and 6x bonus to calories. The more you eat the larger your personal glutton bonus multipler will climb. If stop eating for more than 10 seconds, your glutton bonus will start to drain away. Points are shared across the team, but the glutton bonus is individual, so work together to get the most points.\
\
Time is limited so you can hold shift to sprint, careful though, it will burn lots of calories.\
\
To enable this game mode on dedicated servers, set game_mode = glutton in the [network] section of your settings.ini file."

author = "Peter Andrews (peter_a_klei)"
version = "1.6"

-- This is the URL name of the mod's thread on the forum; the part after the index.php? and before the first & in the URL
-- Example:
-- http://forums.kleientertainment.com/index.php?/files/file/202-sample-mods/
-- becomes
-- /files/file/202-sample-mods/
forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

---- Can specify a custom icon for this mod!
icon_atlas = "modicon.xml"
icon = "modicon.tex"

--This lets the clients know that they need to download the mod before they can join a server that is using it.
all_clients_require_mod = true

--This lets the game know that this mod doesn't need to be listed in the server's mod listing
client_only_mod = false

--Let the mod system know that this mod is functional with Don't Starve Together
dst_compatible = true

--These tags allow the server running this mod to be found with filters from the server listing screen
server_filter_tags = {"gamemode", "game mode"}

game_modes =
{
	{
		name = "glutton",
		label = "Glutton",
		description = "This game mode is all about eating food as a team. Your glutton bonus multiplier is individual and increases as you eat more. Make sure you keep eating or your multiplier will drop!",
		settings =
		{
			ghost_sanity_drain = true,
			portal_rez = true,
			level_type = "LEVELTYPE_GLUTTON",
		},
	}
}

configuration_options =
{
	{
        name = "game_time",
        label = "Game Time",
        options = 
        {
            {description = "5 minutes", data = 5},
            {description = "10 minutes", data = 10},
            {description = "20 minutes", data = 20},
            {description = "40 minutes", data = 40},
            {description = "1 hour", data = 60},
        },
        default = 20,
    },
	{
        name = "map_gen",
        label = "Map Type",
        options = 
        {
            {description = "Random", data = "random", hover = "A random world is generated."},
            {description = "Fixed", data = "fixed", hover = "Uses a fixed map. Intended for tournament use."},
        },
        default = "random",
    },
	{
        name = "game_flow",
        label = "Game Flow",
		hover = "Controls when the game starts.\nDedicated servers can set this value to \"manual\"\nto control the flow in a LAN tournament.",
        options = 
        {
            {description = "Automatic", data = "auto"}
		},
        default = "auto",
    }
}