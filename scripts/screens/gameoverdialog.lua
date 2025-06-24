local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/templates"

local GameOverDialogScreen = Class(Screen, function(self, title, text)
	Screen._ctor(self, "GameOverDialogScreen")

	--darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)	
    
	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	--throw up the background
    self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(130, 150, 1, 2, 68, -40))
    self.bg.fill = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
    self.bg.fill:SetScale(.92, 1)
    self.bg.fill:SetPosition(10,25)
	
	--title	
    self.title = self.proot:AddChild(Text(BUTTONFONT, 50))
    self.title:SetPosition(0, 130, 0)
    self.title:SetString(title)
    self.title:SetColour(0,0,0,1)

	--text
    self.text = self.proot:AddChild(Text(BUTTONFONT, 28))
	
	self.base_test = text
	
    self.text:SetPosition(0, -10, 0)
    self.text:SetString(self.base_test)
    self.text:EnableWordWrap(true)
    self.text:SetRegionSize(500, 150)
    self.text:SetColour(0,0,0,1)
end)

function GameOverDialogScreen:UpdateCountdown( reset_time )
	if reset_time == 0 then
		self.text:SetString( self.base_test )
	else
		self.text:SetString( self.base_test .. "\n\nReset in " .. reset_time )
	end
end

return GameOverDialogScreen