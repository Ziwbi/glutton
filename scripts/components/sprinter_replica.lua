local sprinting = false

local Sprinter = Class(function(self, inst)
    self.inst = inst
	self.inst:StartUpdatingComponent(self)
end)

function Sprinter:OnUpdate(dt)
	if ThePlayer == self.inst then
		if not sprinting and TheInput:IsKeyDown(KEY_SHIFT) then
			SendModRPCToServer( MOD_RPC.glutton.StartSprint )
			--self.inst:PushEvent("sprinting")
			sprinting = true
		elseif sprinting and not TheInput:IsKeyDown(KEY_SHIFT) then
			SendModRPCToServer( MOD_RPC.glutton.StopSprint )
			sprinting = false
		end
	end
end

return Sprinter