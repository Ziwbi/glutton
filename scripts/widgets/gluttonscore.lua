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

    self.inst:ListenForEvent("total_calories_dirty", function(src)
        local calorie_text = "Team's calories eaten: " .. TheWorld.components.gluttonmanager:GetTotalCalories()
        self.calories_widget:SetString(calorie_text)
    end, TheWorld)

    self.inst:ListenForEvent("game_timer_dirty", function(src, data)
        local time_left = TheWorld.components.gluttonmanager:GetGameTimer()
        local text = TheWorld.components.gluttonmanager:GetGameState() == 1 and tostring(time_left) or "Waiting to start"
        self.time_widget:SetString(text)
    end)
end)

function GluttonScore:OnUpdate(dt)
    local bonus = ThePlayer.components.gluttonbonus.glutton_bonus
    local bonus_timer = ThePlayer.components.gluttonbonus.glutton_timer
    self.bonus_widget:SetString("Your glutton bonus: " .. string.format("x%.1f ", bonus) .. string.format("(%is)", bonus_timer))
end


-- local wait_on_screen_stack = false

-- function IntroMessage()
-- 	local text = "You've got ".. tostring(TUNING.GLUTTON_GAME_TIME) .. " minutes for your team to eat as much as you can!\nYou get points for consuming calories. Boost your bonus multiplier by eating food with more calories. To keep your bonus multiplier from falling, you have to eat something every 10 seconds."

-- 	local start_message = BigPopupDialogScreen( "I hope you're hungry!", text, {{text="Ok", cb =
-- 		function()
-- 			TheFrontEnd:PopScreen()

-- 			if _game_state == GAME_STATE.WAIT_TO_START then
-- 				local wait_text = "The game will begin when everyone is ready and the admin starts the round."
-- 				local wait_for_players = PopupDialogScreen( "Waiting for the game to start...", wait_text, {} )
-- 				TheFrontEnd:PushScreen( wait_for_players )
-- 				wait_on_screen_stack = true
-- 			end
-- 		end}} )
-- 	start_message.bg:SetScale(1.15,2.0)
-- 	start_message.bg.fill:SetScale(1.05,1)
-- 	start_message.bg.fill:SetPosition(10,25)
-- 	start_message.menu:SetPosition(0,-115)
-- 	start_message.text:SetRegionSize(600, 200)
-- 	start_message.text:SetPosition(10,20)
-- 	TheFrontEnd:PushScreen( start_message )
-- end


return GluttonScore
