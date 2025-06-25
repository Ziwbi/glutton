local modenv = env
GLOBAL.setfenv(1, GLOBAL)

local function GameSetup(inst)
    if TheNet:GetServerGameMode() == "glutton" then
        inst:AddComponent("gluttonmanager")
    else
        print("Not enabling glutton because the server game mode isn't matching. To enable this for dedicated servers, set game_mode = glutton in the [network] section of your settings.ini file.")
    end
end
--Currently there is no support for a generic world_network postinit.
modenv.AddPrefabPostInit("cave_network", GameSetup)
modenv.AddPrefabPostInit("forest_network", GameSetup)

function StartGlutton()
    if TheNet:GetServerGameMode() ~= "glutton" then
        print("Not enabling glutton because the server game mode isn't matching. To enable this for dedicated servers, set game_mode = glutton in the [network] section of your settings.ini file.")
        return
    end
    Shard_StartGlutton()
end
