local BONUS_TIMER_ONEAT = 10 -- seconds
local BONUS_TIMER_DECAY = 0.99 -- lose 10% bonus per 0.99 seconds

local function OnGluttonBonusDirty(inst)
    inst.components.gluttonbonus.glutton_bonus = inst.components.gluttonbonus.net_glutton_bonus:value()
end
local function OnGluttonTimerDirty(inst)
    inst.components.gluttonbonus.glutton_timer = inst.components.gluttonbonus.net_glutton_timer:value()
end

local GluttonBonus = Class(function(self, inst)
    self.inst = inst

    self.glutton_bonus = 0
    self.net_glutton_bonus = net_float(self.inst.GUID, "glutton_bonus", "glutton_bonusdirty")

    self.glutton_timer = 0
    self.net_glutton_timer = net_float(self.inst.GUID, "glutton_timer", "glutton_timerdirty")

    --Client only code
    if not TheWorld.ismastersim then
        self.inst:ListenForEvent("glutton_bonusdirty", OnGluttonBonusDirty)
        self.inst:ListenForEvent("glutton_timerdirty", OnGluttonTimerDirty)
    end

    self.inst:StartUpdatingComponent(self)
end)

function GluttonBonus:SetBonus(new_glutton_bonus)
    self.glutton_bonus = math.max(1, new_glutton_bonus)
    self.net_glutton_bonus:set(self.glutton_bonus)
end

function GluttonBonus:SetGluttonBonusTimer(timer)
    self.glutton_timer = timer
    self.net_glutton_timer:set(self.glutton_timer)
end

function GluttonBonus:OnUpdate(dt)
    if not TheWorld.ismastersim then
        return
    end

    if (self.glutton_timer - dt) <= 0 then
        self:SetGluttonBonusTimer(BONUS_TIMER_DECAY)
        self:SetBonus(self.glutton_bonus - 0.1)
    else
        self:SetGluttonBonusTimer(self.glutton_timer - dt)
    end
end

function GluttonBonus:OnEat(calories)
    local bonus = math.ceil((calories / 20) + 0.01) * 0.1
    self:SetGluttonBonusTimer(BONUS_TIMER_ONEAT + BONUS_TIMER_DECAY)
    self:SetBonus(self.glutton_bonus + bonus)
end

return GluttonBonus
