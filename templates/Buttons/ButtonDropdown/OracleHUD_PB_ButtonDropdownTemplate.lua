--- https://wowpedia.fandom.com/wiki/Using_UIDropDownMenu
---
--- Create a dropdown button which uses callbacks as the executed functions on
--- click.
---
--- @example
--- local frame = CreateFrame("FRAME", "FrameName", UIParent", "OracleHUD_PB_ButtonDropdownTemplate")
--- frame.Configure(db)
--- frame.SetMenuItem("test", function(self, button) print("OK") end)
--- frame.Initialize()

--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ButtonDropdownTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
	self.ShowFull = OracleHUD_FrameShowFull
	self.menuItems = {}
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
	-- @param db		Oracle HUD Pet Battle database.
    function self:Configure(db)
		self.db = db
	end
	---------------------------------------------------------------------------
	--- Create a single menu item.
	-- @param text		The text to display.
	-- @param callback	The function to execute when text is clicked.
	function self:SetMenuItem(text, callback)
		table.insert(self.menuItems, { text = text, callback = callback })
	end
	---------------------------------------------------------------------------
	--- Provide callback to initialize the dropdown menu with configured values.
	function self:Initialize()
		OracleHUD_UIDropDownMenu_Initialize(self, function(frame, level, menuList)
			for i = 1, #self.menuItems do
				local item = self.menuItems[i]
				local info = UIDropDownMenu_CreateInfo();
				info.text = item.text;
				info.arg1 = self;
				info.func = item.callback;
				OracleHUD_UIDropDownMenu_AddButton(info, 1);
			end
		end)
	end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
	function self:OnSizeChanged_ButtonDropdownTemplate()
		self.Left:SetSize(self:GetWidth(), self:GetHeight());
		self.Button:SetSize(self:GetWidth(), self:GetHeight());
		self.Button.NormalTexture:SetSize(self:GetWidth(), self:GetHeight());
		self.Button.PushedTexture:SetSize(self:GetWidth(), self:GetHeight());
		self.Button.DisabledTexture:SetSize(self:GetWidth(), self:GetHeight());
		self.Button.HighlightTexture:SetSize(self:GetWidth(), self:GetHeight());
		self.Icon:SetSize(self:GetWidth(), self:GetHeight());
	end
	self:ClearPoint("TOPLEFT")
	self:SetScript("OnClick", function(self, button, down)
	end)
	self:RegisterForClicks("AnyDown")
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:SetScript("OnSizeChanged", function()
		self:OnSizeChanged_ButtonDropdownTemplate()
	end)
	OracleHUD_UIDropDownMenu_SetWidth(self, 1)
end
