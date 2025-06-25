--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local GAME_STATE = {
    WAIT_TO_START = 0,
    STARTED = 1,
    OVER_TIMESUP = 2
}

--------------------------------------------------------------------------
--[[ GluttonManager class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastersim = _world.ismastersim
local _ismastershard = _world.ismastershard

--Master simulation
local _game_state
local _game_timer

--Secondard simulation

--Network
local _net_game_state = net_ushortint(inst.GUID, "glutton.net_game_state", "game_state_dirty")
local _net_game_timer = net_float(inst.GUID, "glutton.net_game_timer", "game_timer_dirty")
local _net_total_calories = net_float(inst.GUID, "glutton.net_total_calories", "total_calories_dirty")
-- local net_reset_time = net_smallbyte(self.inst.GUID, "reset_time", "reset_timedirty" )


--[[
local PopupDialogScreen 	= require("screens/popupdialog")
local BigPopupDialogScreen 	= require("screens/bigpopupdialog")
local GameOverDialogScreen 	= require("screens/gameoverdialog")
local Widget				= require "widgets/widget"
local Text 					= require "widgets/text"

]]


--------------------------------------------------------------------------
--[[ Private event listeners ]]
--------------------------------------------------------------------------

-- local function OnResetTimeDirty(inst)
-- 	inst.components.gluttonmanager:SetResetTimer( inst.components.gluttonmanager.net_reset_time:value() )
-- end

local function CalculateCalories(food)
    local calories = math.max(food.components.edible:GetHunger(inst), 1)

    local crock_pot_mult = food:HasTag("preparedfoods") and TUNING.PREPARED_FOOD_MULT or 1
    local cooked_mult = string.find(food.prefab, "cooked") ~= nil and 3 or 1
    local souls_mult = food:HasTag("soul") and 0.5 or 1

    return calories * TUNING.GLUTTON_BASE_MULT * crock_pot_mult * cooked_mult * souls_mult
end

local function BuildAnnouceString(player, calories)
    --[[
        local bonuses_plural = "Bonus"
    if crock_pot_bonus > 1 or cooked_bonus > 1 then
        bonuses_plural = "Bonuses"
    end			
    local ate_annouce = player.name .. " ate " .. format_num( modified_hunger_value, 0 ) .. " calories. (" .. bonuses_plural .. " - Glutton: " .. string.format("x%.1f", glutton_bonus) 
    if crock_pot_bonus > 1 then
        ate_annouce = ate_annouce .. " Crock Pot: " .. string.format("x%i", crock_pot_bonus)
    end
    if cooked_bonus > 1 then
        ate_annouce = ate_annouce .. " Fire Roasted: " .. string.format("x%i", cooked_bonus)
    end
    ate_annouce = ate_annouce .. ")"
    ]]
    return string.format("%s ate %f", player.name, calories)
end

local function OnPlayerEat(player, data)
    if _net_game_state:value() ~= GAME_STATE.STARTED then
        return
    end

    local hunger_value = CalculateCalories(data.food)
    local modified_hunger_value = hunger_value * player.components.gluttonbonus.glutton_bonus

    player.components.gluttonbonus:OnEat(hunger_value)
    SendModRPCToShard(SHARD_MOD_RPC["glutton"]["SyncGlutton"], nil, {total_calories = modified_hunger_value})

    local annouce_string = BuildAnnouceString(player, modified_hunger_value)
    TheNet:Announce(annouce_string, player.entity)
end

local function OnPlayerJoined(src, player)
    _world:ListenForEvent("oneat", OnPlayerEat, player)

    if _game_state == GAME_STATE.WAIT_TO_START then
        SetSimPause(true)
    end

    -- TODO put this in worldgen
    --[[
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
    
    ]]
end

local function OnPlayerLeft(src, player)
    _world:RemoveEventCallback("oneat", OnPlayerEat, player)
end



local OnGluttonUpdate = _ismastersim and function(src, data)
    if _ismastershard then
        _game_state = data.game_state or _game_state
        _game_timer = data.game_timer or _game_timer
    end

    if data.game_state then
        _net_game_state:set(data.game_state)
    end
    if data.game_timer then
        _net_game_timer:set(data.game_timer)
    end
    if data.total_calories then
         _net_total_calories:set(data.total_calories)
    end
end or nil


--------------------------------------------------------------------------
--[[ Public methods ]]
--------------------------------------------------------------------------

self.SetGameState = _ismastershard and function(src, game_state)
    _game_state = game_state
    _net_game_state:set(game_state)

    self.inst:DoTaskInTime((TUNING.GLUTTON_GAME_TIME - 5) * 60, function() TheNet:Announce( "5 minutes left!" ) end, "5 min")
    self.inst:DoTaskInTime((TUNING.GLUTTON_GAME_TIME - 1) * 60, function() TheNet:Announce( "1 minute left!!" ) end, "1 min")
    self.inst:DoTaskInTime((TUNING.GLUTTON_GAME_TIME - 1) * 60 + 50, function() TheNet:Announce( "10 seconds left!!!" ) end, "10 secs")
end or nil

self.SetGameTimer = _ismastershard and function(src, game_timer)
    _game_timer = game_timer
    _net_game_timer:set(game_timer)
end or nil

self.SetResetTimer = _ismastersim and function(src, reset_time)
    -- if self.reset_dialog then
    --     self.reset_dialog:UpdateCountdown(reset_time)
    -- end
    if _ismastersim then
        self.net_reset_time:set(reset_time)
    end
end or nil

self.StartGame = _ismastershard and function(src)
    if _game_state ~= GAME_STATE.WAIT_TO_START then
        return
    end

    SetSimPause(false)
    _world:PushEvent("ms_setautosaveenabled", false)

    self:SetGameState(GAME_STATE.STARTED)
    self:SetGameTimer(TUNING.GLUTTON_GAME_TIME)
end or nil

self.StopGame = _ismastershard and function(src)
    if _game_state ~= GAME_STATE.OVER_TIMESUP then
        self:SetGameTimer(0.0)
        self:SetGameState(GAME_STATE.OVER_TIMESUP)
    end
end or nil

---@return number
function self:GetTotalCalories()
    return _net_total_calories:value()
end

---@return number
function self:GetGameTimer()
    return _net_game_timer:value()
end

---@return integer
function self:GetGameState()
    return _net_game_state:value()
end


--------------------------------------------------------------------------
--[[ Initialisation ]]
--------------------------------------------------------------------------

if _ismastersim then
    self.inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, _world)
    self.inst:ListenForEvent("ms_playerleft", OnPlayerLeft, _world)
    self.inst:ListenForEvent("gluttonupdate", OnGluttonUpdate, _world)

    if not _ismastershard then
        return
    end
    _net_total_calories:set(0)

    	-- 	if not TheNet:IsDedicated() then
		-- 	self.inst:DoTaskInTime( 5,
		-- 		function()
		-- 			if self.game_state == GAME_STATE.WAIT_TO_START then
		-- 				--print("pause after 5 sec wait")
		-- 				SetSimPause(true)
		-- 			end
		-- 		end,
		-- 		"pause"
		-- 	)
		-- end
end

-- if self.inst.game_flow == "auto" then
--     self.reset_time = 15
-- else
--     print("### call StartGlutton() to start the game ###")
--     self.reset_time = 0
-- end

if _ismastershard then
    _game_state = GAME_STATE.WAIT_TO_START
    _game_timer = -1
end


-- self.inst:ListenForEvent("playeractivated", IntroMessage, TheWorld)

self.inst:StartUpdatingComponent(self)

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:OnUpdate(dt)
    --create client UI for reset screen
    if _game_state == GAME_STATE.OVER_TIMESUP then
        if self.reset_dialog == nil then
            local title = "The game is over. The time is up."
            local message = "\nYour team ate a total of " .. _net_total_calories:value() .. " calories. Thanks for playing!"

            self.reset_dialog = GameOverDialogScreen( title, message )
            self:SetResetTimer(self.reset_time)

            TheFrontEnd:PushScreen(self.reset_dialog)
        end
    end

    if self.game_state == GAME_STATE.STARTED then
        if wait_on_screen_stack then
            TheFrontEnd:PopScreen()
            wait_on_screen_stack = false
        end
    end


    if not _ismastershard then
        return
    end

    if _game_state == GAME_STATE.OVER_TIMESUP then
        -- if _world.game_flow == "auto" then
        --     local last_whole_time = math.ceil(self.reset_time)
        --     self.reset_time = self.reset_time - dt
        --     if math.ceil(self.reset_time) < last_whole_time then
        --         self:SetResetTimer( math.ceil(self.reset_time) )
        --     end
        --     if self.reset_time < 0 then
        --         c_regenerateworld()
        --     end
        -- end
    elseif _game_state == GAME_STATE.STARTED then
        if _game_timer < 0 then
            return
        end

        local last_whole_time = math.ceil(_game_timer)
        _game_timer = _game_timer - dt
        if math.ceil(_game_timer) < last_whole_time then
            self:SetGameTimer(math.ceil(_game_timer)) -- no need to sync netvar every update
        end
        if _game_timer < 0 then
            self:StopGame()
        end
    end
end

end)
