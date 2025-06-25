GLOBAL.setfenv(1, GLOBAL)

function Shard_StartGlutton()
    if Shard_IsMaster() then
        TheWorld.net.components.gluttonmanager:StartGame()
    else
        SendModRPCToShard(SHARD_MOD_RPC["glutton"]["StartGlutton"], SHARDID.MASTER)
    end
end

function Shard_SyncGlutton(data)
    TheWorld:PushEvent("gluttonupdate", data)
end
