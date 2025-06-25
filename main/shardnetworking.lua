function Shard_StartGlutton()
    if Shard_IsMaster() then
        TheWorld.components.gluttonmanager:StartGame()
    else
        SendModRPCToShard("glutton", "StartGlutton", SHARDID.MASTER)
    end
end

function Shard_SyncGlutton(data)
    TheWorld:PushEvent("gluttonupdate", data)
end
