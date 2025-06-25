local modenv = env
GLOBAL.setfenv(1, GLOBAL)

AddModRPCHandler("glutton", "StartSprint", function(inst)
    inst.components.sprinter:SetIsSprinting(true)
end)

AddModRPCHandler("glutton", "StopSprint", function(inst)
    inst.components.sprinter:SetIsSprinting(false)
end)

AddShardModRPCHandler("glutton", "StartGlutton", function(shardid)
    Shard_StartGlutton()
end)

AddShardModRPCHandler("glutton", "SyncGlutton", function(shardid, game_state, game_timer, total_calories)
    Shard_SyncGlutton(game_state, game_timer, total_calories)
end)
