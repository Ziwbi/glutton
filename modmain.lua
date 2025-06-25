---@diagnostic disable-next-line: undefined-global
local modenv = env
GLOBAL.setfenv(1, GLOBAL)

modenv.AddReplicableComponent("sprinter")

modenv.modimport("main/constants.lua")
modenv.modimport("main/postinit.lua")
modenv.modimport("main/RPC.lua")
modenv.modimport("main/shardnetworking.lua")
modenv.modimport("main/tuning.lua")
