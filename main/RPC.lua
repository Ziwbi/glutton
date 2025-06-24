local modenv = env
GLOBAL.setfenv(1, GLOBAL)

AddModRPCHandler("glutton", "StartSprint", function(inst)
    inst.components.sprinter:SetIsSprinting(true)
end)

AddModRPCHandler("glutton", "StopSprint", function(inst)
    inst.components.sprinter:SetIsSprinting(false)
end)
