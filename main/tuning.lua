GLOBAL.setfenv(1, GLOBAL)

local wilson_hunger_rate = TUNING.WILSON_HUNGER_RATE

local tune = {
    SPRINT_MULT = 1.5,
    SPRINT_HUNGER_MULT = 8,

    BASE_COOK_TIME = 0,
    WILSON_HUNGER_RATE = wilson_hunger_rate * 1.5,
}

for k, v in pairs(tune) do
    TUNING[k] = v
end
