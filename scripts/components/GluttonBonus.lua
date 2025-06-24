

local function OnGluttonBonusDirty(inst)
	inst.components.GluttonBonus.glutton_bonus = inst.components.GluttonBonus.net_glutton_bonus:value()
end
local function OnGluttonTimerDirty(inst)
	inst.components.GluttonBonus.glutton_timer = inst.components.GluttonBonus.net_glutton_timer:value()
end

local GluttonBonus = Class(function(self, inst)
    self.inst = inst
		
	self.glutton_bonus = 0
	self.net_glutton_bonus = net_float(self.inst.GUID, "glutton_bonus", "glutton_bonusdirty" )
	
	self.glutton_timer = 0
	self.net_glutton_timer = net_float(self.inst.GUID, "glutton_timer", "glutton_timerdirty" )
	
	--Server only code
	if TheWorld.ismastersim then
		--self.glutton_timer = 0
	end
	
	--Client only code
	if not TheWorld.ismastersim then
		self.inst:ListenForEvent("glutton_bonusdirty", OnGluttonBonusDirty)
		self.inst:ListenForEvent("glutton_timerdirty", OnGluttonTimerDirty)
	end
	
	self.inst:StartUpdatingComponent(self)
end)


function GluttonBonus:SetBonus( new_glutton_bonus )
	self.glutton_bonus = new_glutton_bonus
	if self.glutton_bonus < 1 then
		self.glutton_bonus = 1
	end
	self.net_glutton_bonus:set(self.glutton_bonus)
end

function GluttonBonus:SetGluttonBonusTimer(timer)
	self.glutton_timer = timer
	self.net_glutton_timer:set(self.glutton_timer)
end
	
function GluttonBonus:OnUpdate(dt)
	if TheWorld.ismastersim then
		if (self.glutton_timer - dt) <= 0 then
			self:SetGluttonBonusTimer(0.99)
			self:SetBonus( self.glutton_bonus - 0.1 )
		else
			self:SetGluttonBonusTimer(self.glutton_timer - dt)
		end
	end
end

function GluttonBonus:Ate(calories)
	local bonus = math.ceil( (calories / 20) + 0.01) * 0.1
	self:SetGluttonBonusTimer(10.99)
	self:SetBonus( self.glutton_bonus + bonus )
end

return GluttonBonus