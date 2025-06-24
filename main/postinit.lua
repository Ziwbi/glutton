local prefab_postinits = {
    "player",
}

for k, v in pairs(prefab_postinits) do
    modimport("postinit/prefabs/" .. v .. ".lua")
end
