local prefab_postinits = {
    "player",
    "world_network",
}

for k, v in pairs(prefab_postinits) do
    modimport("postinit/prefabs/" .. v .. ".lua")
end
