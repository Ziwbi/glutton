local modenv = env
GLOBAL.setfenv(1, GLOBAL)

local function player_postinit(inst)
    inst:AddComponent("gluttonbonus")

    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("sprinter")
end

modenv.AddPlayerPostInit(player_postinit)
