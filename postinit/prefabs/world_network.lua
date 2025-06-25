local modenv = env
GLOBAL.setfenv(1, GLOBAL)

function GameSetup(inst)
    ANNOUNCEMENT_LIFETIME = 3
    ANNOUNCEMENT_FADE_TIME = 1
    ANNOUNCEMENT_QUEUE_SIZE = 4

    if TheNet:GetServerGameMode() == "glutton" then
        print("### Glutton Mode ###")

        inst.game_flow = modenv.GetModConfigData("game_flow")
        inst.game_time = modenv.GetModConfigData("game_time")

        inst:AddComponent("gluttonmanager")
    else
        print("Not enabling glutton because the server game mode isn't matching. To enable this for dedicated servers, set game_mode = glutton in the [network] section of your settings.ini file.")
    end
end
--Currently there is no support for a generic world_network postinit.
modenv.AddPrefabPostInit("cave_network", GameSetup)
modenv.AddPrefabPostInit("forest_network", GameSetup)

function StartGlutton()
    Shard_StartGlutton()
end
