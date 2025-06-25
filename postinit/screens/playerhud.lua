local modenv = env
GLOBAL.setfenv(1, GLOBAL)

local GluttonScore = require("widgets/gluttonscore")

modenv.AddClassPostConstruct("screens/playerhud", function(self)
    self.root.gluttonscore = self.root:AddChild(GluttonScore())
    self.root.gluttonscore:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root.gluttonscore:SetVAnchor(ANCHOR_BOTTOM)
    self.root.gluttonscore:SetHAnchor(ANCHOR_MIDDLE)
end)
