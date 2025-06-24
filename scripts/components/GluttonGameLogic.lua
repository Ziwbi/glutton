local PopupDialogScreen 	= require("screens/popupdialog")
local BigPopupDialogScreen 	= require("screens/bigpopupdialog")
local GameOverDialogScreen 	= require("screens/gameoverdialog")
local Widget				= require "widgets/widget"
local Text 					= require "widgets/text"

local _GluttonGameLogic = nil
local SpawnedExtraGroundItems = false 

--Modified from http://lua-users.org/wiki/FormattingNumbers
function comma_value(amount)
	local formatted = amount
	local k
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end
function round(val, decimal)
	if (decimal) then
		return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(val+0.5)
	end
end
function format_num(amount, decimal)
	local str_amount, formatted, famount, remain

	famount = math.abs(round(amount,decimal))
	famount = math.floor(famount)

	-- comma to separate the thousands
	formatted = comma_value(famount)
	
  return formatted
end



local GAME_STATE =
{
	WAIT_TO_START 	= 0,
	STARTED 		= 1,
	OVER_TIMESUP	= 2
}

local wait_on_screen_stack = false

function IntroMessage()
	local text = "You've got ".. tostring(_GluttonGameLogic.inst.game_time) .. " minutes for your team to eat as much as you can!\nYou get points for consuming calories. Boost your bonus multiplier by eating food with more calories. To keep your bonus multiplier from falling, you have to eat something every 10 seconds."

	local start_message = BigPopupDialogScreen( "I hope you're hungry!", text, {{text="Ok", cb = 
		function()
			TheFrontEnd:PopScreen()
			
			if _GluttonGameLogic.game_state == GAME_STATE.WAIT_TO_START then
				local wait_text = "The game will begin when everyone is ready and the admin starts the round."
				local wait_for_players = PopupDialogScreen( "Waiting for the game to start...", wait_text, {} )
				TheFrontEnd:PushScreen( wait_for_players )
				wait_on_screen_stack = true
			end
		end}} )
	start_message.bg:SetScale(1.15,2.0)
	start_message.bg.fill:SetScale(1.05,1)
	start_message.bg.fill:SetPosition(10,25)
	start_message.menu:SetPosition(0,-115)
	start_message.text:SetRegionSize(600, 200)
	start_message.text:SetPosition(10,20)
	TheFrontEnd:PushScreen( start_message )
end

local function OnCaloriesEatenDirty(inst)
    inst.components.GluttonGameLogic:AteCalories( inst.components.GluttonGameLogic.net_calories_eaten:value() )
end
local function OnGameStateDirty(inst)
	inst.components.GluttonGameLogic.game_state = inst.components.GluttonGameLogic.net_game_state:value()
end
local function OnGameTimerDirty(inst)
	inst.components.GluttonGameLogic:SetGameTimer( inst.components.GluttonGameLogic.net_game_timer:value() )
end
local function OnResetTimeDirty(inst)
	inst.components.GluttonGameLogic:SetResetTimer( inst.components.GluttonGameLogic.net_reset_time:value() )
end

local crock_pot_foods = require("preparedfoods")
local function OnPlayerEat( inst, data )
	print("OnPlayerEat")
	if inst:HasTag("player") then
		if _GluttonGameLogic.game_state == GAME_STATE.STARTED then
			local hunger_value = data.food.components.edible:GetHunger(inst)
			hunger_value = math.max( hunger_value, 1 )
			
			local calorie_convert = 3
			local crock_pot_bonus = 1
			if crock_pot_foods[data.food.prefab] ~= nil then
				crock_pot_bonus = 6
			end
			local cooked_bonus = 1
			if string.find( data.food.prefab, "cooked" ) ~= nil then
				cooked_bonus = 3
			end
			hunger_value = hunger_value * calorie_convert * crock_pot_bonus * cooked_bonus
			
			local glutton_bonus = inst.components.GluttonBonus.glutton_bonus
			local modified_hunger_value = hunger_value * glutton_bonus
			
			--add the new item
			inst.components.GluttonBonus:Ate(hunger_value)
			
			_GluttonGameLogic:AteCalories( _GluttonGameLogic.calories_eaten + modified_hunger_value )
			local bonuses_plural = "Bonus"
			if crock_pot_bonus > 1 or cooked_bonus > 1 then
				bonuses_plural = "Bonuses"
			end			
			local ate_annouce = inst.name .. " ate " .. format_num( modified_hunger_value, 0 ) .. " calories. (" .. bonuses_plural .. " - Glutton: " .. string.format("x%.1f", glutton_bonus) 
			if crock_pot_bonus > 1 then
				ate_annouce = ate_annouce .. " Crock Pot: " .. string.format("x%i", crock_pot_bonus)
			end
			if cooked_bonus > 1 then
				ate_annouce = ate_annouce .. " Fire Roasted: " .. string.format("x%i", cooked_bonus)
			end
			ate_annouce = ate_annouce .. ")"
			TheNet:Announce( ate_annouce, inst.entity )
		end
	end	
end

local function OnPlayerSpawn( inst, player )
	--print("player spawn")
	if TheWorld.ismastersim and _GluttonGameLogic.inst.game_flow == "auto" then
		_GluttonGameLogic:StartGlutton()
	end
end

local function OnPlayerJoined( inst, player )
	--print("player joined")
	_GluttonGameLogic.inst:ListenForEvent("oneat", OnPlayerEat, player)
	
	if _GluttonGameLogic.game_state == GAME_STATE.WAIT_TO_START then
		--print("OnPlayerJoined GAME_STATE.WAIT_TO_START pausing")
		SetSimPause(true)
	end
	
	if not SpawnedExtraGroundItems then
		local spawn_items = { ["charcoal"] = 15, ["goldnugget"]= 5, ["rocks"]=10}
		for prefab,count in pairs(spawn_items) do
			for i=1,count do
				local attempts = 20 --try multiple times to get a spot on ground before giving up so we don't infinite loop
				while attempts > 0 do
					local angle = math.random() * 2 * PI
					local distance = math.random() * 30
					local spawn_pos = player:GetPosition() + Vector3( math.sin(angle), 0.0, math.cos(angle) ) * distance
					if TheWorld.Map:IsAboveGroundAtPoint(spawn_pos:Get()) then
						local spawn = SpawnAt( prefab, spawn_pos )
						break
					end
					attempts = attempts - 1
				end
			end
		end
		SpawnedExtraGroundItems = true
	end
end

local GluttonGameLogic = Class(function(self, inst)
    _GluttonGameLogic = self
	self.inst = inst
	
	print("##### GluttonGameLogic Construction #####")
	
	self.calories_eaten = 0
	self.net_calories_eaten = net_float(self.inst.GUID, "calories_eaten", "calories_eatendirty" )

	self.game_state = GAME_STATE.WAIT_TO_START
	self.net_game_state = net_smallbyte(self.inst.GUID, "game_state", "game_statedirty" )

	self.net_game_timer = net_ushortint(self.inst.GUID, "game_timer", "game_timerdirty" )

	if self.inst.game_flow == "auto" then
		self.reset_time = 15
	else
		print("### call StartGlutton() to start the game ###")
		self.reset_time = 0
	end
	self.net_reset_time = net_smallbyte(self.inst.GUID, "reset_time", "reset_timedirty" )
	
	self.inst:ListenForEvent("playeractivated", IntroMessage, TheWorld)
	
	--Server only code
	if TheWorld.ismastersim then
		self.game_timer = -1
		self.inst:ListenForEvent("ms_playerspawn", OnPlayerSpawn, TheWorld)
		self.inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
		
		if not TheNet:IsDedicated() then
			self.inst:DoTaskInTime( 5,
				function()
					if self.game_state == GAME_STATE.WAIT_TO_START then
						--print("pause after 5 sec wait")
						SetSimPause(true)
					end
				end,
				"pause"
			)
		end
	end
	
	--Client only code
	if not TheWorld.ismastersim then
		self.inst:ListenForEvent("calories_eatendirty", OnCaloriesEatenDirty)
		self.inst:ListenForEvent("game_statedirty", OnGameStateDirty)
		self.inst:ListenForEvent("game_timerdirty", OnGameTimerDirty)
		self.inst:ListenForEvent("reset_timedirty", OnResetTimeDirty)
	end
	
	self.inst:StartUpdatingComponent(self)
end)

function GluttonGameLogic:StartGlutton()
	if self.game_state == GAME_STATE.WAIT_TO_START then
		self:GameStart()			
		SetSimPause(false)
		--print("StartGlutton unpause")
		TheWorld:PushEvent("ms_setautosaveenabled", false)
	end
end

function GluttonGameLogic:AteCalories( calories )
	self.calories_eaten = calories
	if self.calories_widget then
		local calorie_text = "Team's calories eaten: " .. format_num( self.calories_eaten, 0 )
		self.calories_widget:SetString(calorie_text)
	end
	if TheWorld.ismastersim then
		self.net_calories_eaten:set(self.calories_eaten)
	end	
end
function GluttonGameLogic:SetGameState( game_state )
	self.game_state = game_state
    self.net_game_state:set(game_state)
	
	self.inst:DoTaskInTime( (self.inst.game_time - 5) * 60, function() TheNet:Announce( "5 minutes left!" ) end, "5 min" )
	self.inst:DoTaskInTime( (self.inst.game_time - 1) * 60, function() TheNet:Announce( "1 minute left!!" ) end, "1 min" )
	self.inst:DoTaskInTime( (self.inst.game_time - 1) * 60 + 50, function() TheNet:Announce( "10 seconds left!!!" ) end, "10 secs" )
end
function GluttonGameLogic:SetGameTimer( game_timer )
	if self.time_widget then
		if game_timer >= 0 then
			local timer_text = "Time left to eat: " .. SecondsToTimeString(game_timer)
			self.time_widget:SetString(timer_text)
		else
			self.time_widget:SetString("Time left to eat: waiting to start")
		end
	end
	if TheWorld.ismastersim then
		self.net_game_timer:set(game_timer)
	end
end
function GluttonGameLogic:SetResetTimer( reset_time )
	if self.reset_dialog then
		self.reset_dialog:UpdateCountdown( reset_time )
	end
	if TheWorld.ismastersim then
		self.net_reset_time:set(reset_time)
	end
end

function GluttonGameLogic:GameStart()
	print("GluttonGameLogic GameStart")
	self:SetGameState( GAME_STATE.STARTED )
	self.game_timer = self.inst.game_time * 60
	self:SetGameTimer( self.game_timer )
end

function GluttonGameLogic:GameOver()
	if self.game_state ~= GAME_STATE.OVER_TIMESUP then
		print("### GluttonGameLogic GameOver ###")
		self:SetGameTimer( 0 )
		self:SetGameState( GAME_STATE.OVER_TIMESUP )
	end
end

function GluttonGameLogic:OnUpdate(dt)
	if ThePlayer ~= nil then
		--create client UI for timer
		if self.score_root == nil then
			self.score_root = ThePlayer.HUD.root:AddChild( Widget("root") )
			self.score_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
			self.score_root:SetVAnchor(ANCHOR_BOTTOM)
			self.score_root:SetHAnchor(ANCHOR_MIDDLE)
			
			self.calories_widget = self.score_root:AddChild( Text(UIFONT, 30) )
			self.calories_widget:SetPosition(0, 65)
			self:AteCalories( 0 )
			
			self.time_widget = self.score_root:AddChild( Text(UIFONT, 30) )
			self.time_widget:SetPosition(-300, 65)
			self:SetGameTimer( -1 )
			
			self.bonus_widget = self.score_root:AddChild( Text(UIFONT, 30) )
			self.bonus_widget:SetPosition(300, 65)
		end
		
		local bonus = ThePlayer.components.GluttonBonus.glutton_bonus
		local bonus_timer = ThePlayer.components.GluttonBonus.glutton_timer
		self.bonus_widget:SetString( "Your glutton bonus: " .. string.format("x%.1f ", bonus) .. string.format("(%is)", bonus_timer) )		
	end
	
	--create client UI for reset screen
	if self.game_state == GAME_STATE.OVER_TIMESUP then
		if self.reset_dialog == nil then
			local title = "The game is over. The time is up."
			local message = "\nYour team ate a total of " .. format_num(self.calories_eaten, 0) .. " calories. Thanks for playing!"

			self.reset_dialog = GameOverDialogScreen( title, message )
			self:SetResetTimer(self.reset_time)
			
			TheFrontEnd:PushScreen(self.reset_dialog)
			
			print("### Glutton team scored: " .. format_num(self.calories_eaten, 0) .. " ###")
		end
	end
	
	if self.game_state == GAME_STATE.STARTED then
		if wait_on_screen_stack then
			TheFrontEnd:PopScreen()
			wait_on_screen_stack = false
		end
	end
			
	if TheWorld.ismastersim then
		self:ServerOnUpdate(dt)
	end
end

function GluttonGameLogic:ServerOnUpdate(dt)
	if self.game_state == GAME_STATE.OVER_TIMESUP then
		if self.inst.game_flow == "auto" then	
			local last_whole_time = math.ceil(self.reset_time)
			self.reset_time = self.reset_time - dt
			if math.ceil(self.reset_time) < last_whole_time then
				self:SetResetTimer( math.ceil(self.reset_time) )
			end
			if self.reset_time < 0 then
				c_regenerateworld()
			end
		end
	else
		if self.game_state == GAME_STATE.STARTED then
			if self.game_timer >= 0 then
				local last_whole_time = math.ceil(self.game_timer)
				self.game_timer = self.game_timer - dt
				if math.ceil(self.game_timer) < last_whole_time then
					self:SetGameTimer( math.ceil(self.game_timer) )
				end	
				if self.game_timer < 0 then
					self:GameOver( "times_up" )
				end
			end
		end
	end
end

return GluttonGameLogic