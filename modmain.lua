local TheNet = GLOBAL.TheNet

local world_net_inst = nil

function GameSetup(inst)
	GLOBAL.ANNOUNCEMENT_LIFETIME = 3
	GLOBAL.ANNOUNCEMENT_FADE_TIME = 1
	GLOBAL.ANNOUNCEMENT_QUEUE_SIZE = 4

	if TheNet:GetServerGameMode() == "glutton" then
		print("### Glutton Mode ###")
		
		inst.game_flow = GetModConfigData("game_flow")
		inst.game_time = GetModConfigData("game_time")
		
		inst:AddComponent("GluttonGameLogic")
		world_net_inst = inst
	else
		print("Not enabling glutton because the server game mode isn't matching. To enable this for dedicated servers, set game_mode = glutton in the [network] section of your settings.ini file.")
	end
end
--Currently there is no support for a generic world_network postinit.
AddPrefabPostInit("cave_network", GameSetup)
AddPrefabPostInit("forest_network", GameSetup)


AddReplicableComponent( "sprinter" )

function PlayerComponents( inst )
	inst:AddComponent("GluttonBonus")
	
	if not GLOBAL.TheWorld.ismastersim then
		return
	end
	inst:AddComponent("sprinter")
	inst.components.health.RecalculatePenalty = function(forceupdatewidget) end	
end
AddPlayerPostInit( PlayerComponents )


GLOBAL.TUNING.SPRINT_MULT = 1.5
GLOBAL.TUNING.SPRINT_HUNGER_MULT = 8

GLOBAL.AddModRPCHandler( "glutton", "StartSprint", 
	function(inst)
        inst.components.sprinter.is_sprinting = true
    end )

GLOBAL.AddModRPCHandler( "glutton", "StopSprint", 
	function(inst)
        inst.components.sprinter.is_sprinting = false
    end )



GLOBAL.TUNING.BASE_COOK_TIME = 0
GLOBAL.TUNING.WILSON_HUNGER_RATE = GLOBAL.TUNING.WILSON_HUNGER_RATE * 1.5

local function StartGlutton()
	print("### StartGlutton ###")
	world_net_inst.components.GluttonGameLogic:StartGlutton()
end
GLOBAL.StartGlutton = StartGlutton