local Sprinter = Class(function(self, inst)
    self.inst = inst
	self.is_sprinting = false
	self.inst:StartUpdatingComponent(self)
end)

function Sprinter:OnUpdate(dt)
	local is_moving = self.inst.sg ~= nil and self.inst.sg:HasStateTag("moving")
	if self.is_sprinting and is_moving then
		self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "sprinter", TUNING.SPRINT_MULT)
		self.inst.components.hunger.burnrate = TUNING.SPRINT_HUNGER_MULT

		self.inst:PushEvent("sprinting")
	else
		self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "sprinter")
		self.inst.components.hunger.burnrate = 1
	end
end


return Sprinter