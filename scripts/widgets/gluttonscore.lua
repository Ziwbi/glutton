local Widget = require("widgets/widget")
local Text = require("widgets/text")


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
    local calorie_text = "Team's calories eaten: " .. TheWorld.net.components.gluttonmanager:GetTotalCalories()
    self.calories_widget:SetString(calorie_text)

    local time_left = TheWorld.net.components.gluttonmanager:GetGameTimer()
    local text = TheWorld.net.components.gluttonmanager:GetGameState() == 1 and tostring(time_left) or "Waiting to start"
    self.time_widget:SetString(text)

    local bonus = ThePlayer.components.gluttonbonus.glutton_bonus
    local bonus_timer = ThePlayer.components.gluttonbonus.glutton_timer
    self.bonus_widget:SetString("Your glutton bonus: " .. string.format("x%.1f ", bonus) .. string.format("(%is)", bonus_timer))
end

return GluttonScore
