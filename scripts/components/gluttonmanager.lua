--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local GameOverDialogScreen = require("screens/gameoverdialog")
local PopupDialogScreen 	= require("screens/popupdialog")
local BigPopupDialogScreen 	= require("screens/bigpopupdialog")
local GluttonUtil = require("main/glutton_util")

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
local _reset_time
local _spawned_extra_item = false

--Secondard simulation

--Network
local _net_game_state = net_ushortint(inst.GUID, "glutton.net_game_state", "game_state_dirty")
local _net_game_timer = net_float(inst.GUID, "glutton.net_game_timer", "game_timer_dirty")
local _net_total_calories = net_float(inst.GUID, "glutton.net_total_calories", "total_calories_dirty")
local _net_reset_time = net_smallbyte(self.inst.GUID, "reset_time", "reset_timedirty") -- 0-63

--------------------------------------------------------------------------
--[[ Private event listeners ]]
--------------------------------------------------------------------------

local OnEatCalories = _ismastersim and function(player, data)
    if _net_game_state:value() ~= GLUTTON_GAME_STATES.STARTED then
        return
    end

    local calories = math.max(data.base_calories, 1)

    local crock_pot_mult = data.food:HasTag("preparedfood") and TUNING.PREPARED_FOOD_MULT or 1
    local cooked_mult = string.find(data.food.prefab, "cooked") ~= nil and 3 or 1

    calories = calories * TUNING.GLUTTON_BASE_MULT * crock_pot_mult * cooked_mult
    local glutton_bonus = player.components.gluttonbonus.glutton_bonus
    local calories_with_bonus = calories * glutton_bonus
    player.components.gluttonbonus:OnEat(calories)

    local update_data = {total_calories = calories_with_bonus}
    _world:PushEvent("gluttonupdate", update_data)
    SendModRPCToShard(SHARD_MOD_RPC["glutton"]["SyncGlutton"], nil, update_data)

    local bonuses_plural = "Bonus"
    if crock_pot_mult > 1 or cooked_mult > 1 then
        bonuses_plural = "Bonuses"
    end
    local ate_annouce = player.name .. " ate " .. GluttonUtil.format_num(calories_with_bonus, 0) .. " calories. (" .. bonuses_plural .. " - Glutton: " .. string.format("x%.1f", glutton_bonus)
    if crock_pot_mult > 1 then
        ate_annouce = ate_annouce .. " Crock Pot: " .. string.format("x%i", crock_pot_mult)
    end
    if cooked_mult > 1 then
        ate_annouce = ate_annouce .. " Fire Roasted: " .. string.format("x%i", cooked_mult)
    end
    ate_annouce = ate_annouce .. ")"
    TheNet:Announce(ate_annouce, player.entity)
end

local OnPlayerEat = _ismastersim and function(player, data)
    OnEatCalories(player, {food = data.food, base_calories = data.food.components.edible:GetHunger(player)})
end or nil

local OnEatSoul = _ismastersim and function(player, data)
    OnEatCalories(player, {food = data.soul, base_calories = TUNING.CALORIES_MED * TUNING.SOULS_MULT})
end or nil

local OnPlayerSpawned = _ismastersim and function(src, player)
	if TUNING.GLUTTON_AUTO_RESET then
		self:StartGame()
	end
end or nil

local OnPlayerJoined = _ismastersim and function(src, player)
    _world:ListenForEvent("oneat", OnPlayerEat, player)
    _world:ListenForEvent("oneatsoul", OnEatSoul, player)

    if _game_state == GLUTTON_GAME_STATES.WAIT_TO_START then
        SetSimPause(true)
    end

    if _spawned_extra_item then
        return
    end

    -- I could put this in worldgen but I can't be bothered :3
    local spawn_items = {charcoal = 15, goldnugget = 5, rocks = 10}
    for prefab, count in pairs(spawn_items) do
        for i = 1, count do
            local attempts = 20 --try multiple times to get a spot on ground before giving up so we don't infinite loop
            while attempts > 0 do
                local angle = math.random() * 2 * PI
                local distance = math.random() * 30
                local spawn_pos = player:GetPosition() + Vector3(math.sin(angle), 0.0, math.cos(angle)) * distance
                if TheWorld.Map:IsAboveGroundAtPoint(spawn_pos:Get()) then
                    SpawnAt(prefab, spawn_pos)
                    break
                end
                attempts = attempts - 1
            end
        end
    end
    _spawned_extra_item = true
end or nil

local OnPlayerLeft = _ismastersim and function(src, player)
    _world:RemoveEventCallback("oneat", OnPlayerEat, player)
    _world:RemoveEventCallback("oneatsoul", OnEatSoul, player)
end or nil

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

local wait_on_screen_stack = false

local function IntroMessage()
    local text = "You've got ".. tostring(math.ceil(TUNING.GLUTTON_GAME_TIME/60)) .. " minutes for your team to eat as much as you can!\nYou get points for consuming calories. Boost your bonus multiplier by eating food with more calories. To keep your bonus multiplier from falling, you have to eat something every 10 seconds."

    local start_message = BigPopupDialogScreen( "I hope you're hungry!", text, {{text="Ok", cb =
        function()
            TheFrontEnd:PopScreen()

            if _game_state == GLUTTON_GAME_STATES.WAIT_TO_START then
                local wait_text = "The game will begin when everyone is ready and the admin starts the round."
                local wait_for_players = PopupDialogScreen("Waiting for the game to start...", wait_text, {})
                TheFrontEnd:PushScreen(wait_for_players)
                wait_on_screen_stack = true
            end
        end}} )
    start_message.bg:SetScale(1.15, 2.0)
    start_message.bg.fill:SetScale(1.05, 1)
    start_message.bg.fill:SetPosition(10, 25)
    start_message.menu:SetPosition(0, -115)
    start_message.text:SetRegionSize(600, 200)
    start_message.text:SetPosition(10, 20)
    TheFrontEnd:PushScreen(start_message)
end

--------------------------------------------------------------------------
--[[ Public methods ]]
--------------------------------------------------------------------------

self.SetGameState = _ismastershard and function(src, game_state)
    _game_state = game_state
    _net_game_state:set(game_state)

    local update_data = {game_state = game_state}
    SendModRPCToShard(SHARD_MOD_RPC["glutton"]["SyncGlutton"], nil, update_data)

    self.inst:DoTaskInTime(TUNING.GLUTTON_GAME_TIME - 5 * 60, function() TheNet:Announce("5 minutes left!") end)
    self.inst:DoTaskInTime(TUNING.GLUTTON_GAME_TIME - 1 * 60, function() TheNet:Announce("1 minute left!!") end)
    self.inst:DoTaskInTime(TUNING.GLUTTON_GAME_TIME - 10, function() TheNet:Announce("10 seconds left!!!") end)
end or nil

self.SetGameTimer = _ismastershard and function(src, game_timer)
    _game_timer = game_timer
    _net_game_timer:set(game_timer)

    local update_data = {game_timer = game_timer}
    SendModRPCToShard(SHARD_MOD_RPC["glutton"]["SyncGlutton"], nil, update_data)
end or nil

self.SetResetTimer = _ismastershard and function(src, reset_time)
    _reset_time = _reset_time
    _net_reset_time:set(reset_time)
end or nil

self.StartGame = _ismastershard and function(src)
    if _game_state ~= GLUTTON_GAME_STATES.WAIT_TO_START then
        return
    end

    SetSimPause(false)
    _world:PushEvent("ms_setautosaveenabled", false)

    self:SetGameState(GLUTTON_GAME_STATES.STARTED)
    self:SetGameTimer(TUNING.GLUTTON_GAME_TIME)
end or nil

self.StopGame = _ismastershard and function(src)
    if _game_state ~= GLUTTON_GAME_STATES.OVER_TIMESUP then
        self:SetGameTimer(0.0)
        self:SetGameState(GLUTTON_GAME_STATES.OVER_TIMESUP)
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
    self.inst:ListenForEvent("ms_playerspawn", OnPlayerSpawned, _world)
    self.inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, _world)
    self.inst:ListenForEvent("ms_playerleft", OnPlayerLeft, _world)
    self.inst:ListenForEvent("gluttonupdate", OnGluttonUpdate, _world)

    if not TheNet:IsDedicated() then
        self.inst:DoTaskInTime(5, function()
            if _net_game_state:value() == GLUTTON_GAME_STATES.WAIT_TO_START then
                SetSimPause(true)
            end
        end)
    end

    if not _ismastershard then
        return
    end

    _net_total_calories:set(0)

    if TUNING.GLUTTON_AUTO_RESET then
        _reset_time = 15
    else
        print("### call StartGlutton() to start the game ###")
        _reset_time = 0
    end

    _game_state = GLUTTON_GAME_STATES.WAIT_TO_START
    _game_timer = -1
end

self.inst:ListenForEvent("playeractivated", IntroMessage, TheWorld)

self.inst:StartUpdatingComponent(self)

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:OnUpdate(dt)
    --create client UI for reset screen
    if _game_state == GLUTTON_GAME_STATES.OVER_TIMESUP then
        if self.reset_dialog == nil then
            local title = "The game is over. The time is up."
            local message = "\nYour team ate a total of " .. _net_total_calories:value() .. " calories. Thanks for playing!"
            self.reset_dialog = GameOverDialogScreen(title, message)
            if _ismastershard then
                self:SetResetTimer(_reset_time)
            end
            self.reset_dialog:UpdateCountdown(_net_reset_time:value())
            TheFrontEnd:PushScreen(self.reset_dialog)
        end
    end

    if _net_game_state:value() == GLUTTON_GAME_STATES.STARTED then
        if wait_on_screen_stack then
            TheFrontEnd:PopScreen()
            wait_on_screen_stack = false
        end
    end

    if not _ismastershard then
        return
    end

    if _game_state == GLUTTON_GAME_STATES.OVER_TIMESUP then
        if not TUNING.GLUTTON_AUTO_RESET then
            return
        end

        local last_whole_time = math.ceil(_reset_time)
        _reset_time = _reset_time - dt
        if _reset_time < 0 then
            c_regenerateworld()
        end
        if math.ceil(_reset_time) < last_whole_time then
            self:SetResetTimer(math.ceil(_reset_time))
        end
    elseif _game_state == GLUTTON_GAME_STATES.STARTED then
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
