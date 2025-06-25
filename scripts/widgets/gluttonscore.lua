local Widget = require("widgets/widget")
local Text = require("widgets/text")
local GluttonUtil = require("main/glutton_util")

local GluttonScore = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "GluttonScore")


    self.calories_widget = self:AddChild(Text(UIFONT, 30))
    self.calories_widget:SetPosition(0, 65)

    self.time_widget = self:AddChild(Text(UIFONT, 30))
    self.time_widget:SetPosition(-300, 65)

    self.bonus_widget = self:AddChild(Text(UIFONT, 30))
    self.bonus_widget:SetPosition(300, 65)

    self:StartUpdating()
end)

function GluttonScore:OnUpdate(dt)
    if not TheWorld.net or not TheWorld.net.components.gluttonmanager then
        return
    end

    local calorie_text = "Team's calories eaten: " .. GluttonUtil.format_num(TheWorld.net.components.gluttonmanager:GetTotalCalories(), 0)
    self.calories_widget:SetString(calorie_text)

    local time_left = TheWorld.net.components.gluttonmanager:GetGameTimer()
    local text
    if TheWorld.net.components.gluttonmanager:GetGameState() == GLUTTON_GAME_STATES.STARTED then
        text = "Time left to eat: " .. SecondsToTimeString(time_left)
    else
        text = "Waiting to start"
    end
    self.time_widget:SetString(text)

    local bonus = ThePlayer.components.gluttonbonus.glutton_bonus
    local bonus_timer = ThePlayer.components.gluttonbonus.glutton_timer
    self.bonus_widget:SetString("Your glutton bonus: " .. string.format("x%.1f ", bonus) .. string.format("(%is)", bonus_timer))
end

return GluttonScore
