GLOBAL.setfenv(1, GLOBAL)

function Shard_StartGlutton()
    if Shard_IsMaster() then
        TheWorld.net.components.gluttonmanager:StartGame()
    else
        print("secondary Shard_StartGlutton")
        SendModRPCToShard(SHARD_MOD_RPC["glutton"]["StartGlutton"], SHARDID.MASTER)
    end
end

function Shard_SyncGlutton(game_state, game_timer, total_calories)
    TheWorld:PushEvent("gluttonupdate", {game_state = game_state, game_timer = game_timer, total_calories = total_calories})
end
