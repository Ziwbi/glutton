---@diagnostic disable-next-line: undefined-global
local modenv = env
GLOBAL.setfenv(1, GLOBAL)

local world_net_inst = nil

function GameSetup(inst)
    ANNOUNCEMENT_LIFETIME = 3
    ANNOUNCEMENT_FADE_TIME = 1
    ANNOUNCEMENT_QUEUE_SIZE = 4

    if TheNet:GetServerGameMode() == "glutton" then
        print("### Glutton Mode ###")

        inst.game_flow = modenv.GetModConfigData("game_flow")
        inst.game_time = modenv.GetModConfigData("game_time")

        inst:AddComponent("GluttonGameLogic")
        world_net_inst = inst
    else
        print("Not enabling glutton because the server game mode isn't matching. To enable this for dedicated servers, set game_mode = glutton in the [network] section of your settings.ini file.")
    end
end
--Currently there is no support for a generic world_network postinit.
modenv.AddPrefabPostInit("cave_network", GameSetup)
modenv.AddPrefabPostInit("forest_network", GameSetup)


modenv.AddReplicableComponent( "sprinter" )


function StartGlutton()
    assert(world_net_inst ~= nil)
    print("### StartGlutton ###")
    world_net_inst.components.GluttonGameLogic:StartGlutton()
end


modenv.modimport("main/postinit.lua")
modenv.modimport("main/RPC.lua")
modenv.modimport("main/tuning.lua")
