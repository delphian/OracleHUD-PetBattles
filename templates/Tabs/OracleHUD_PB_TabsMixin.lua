--- Display, manage cooldowns, and execution of a single pet ability when clicked.
--- @class OracleHUD_PB_Tabs : Frame
--- @field Background           any         Inherited from mixin XML frame.
--- @field Border               any         Inherited from Mixin XML frame.
--- @field Menu		            any         Inherited from Mixin XML frame.
--- @field Body		            any         Inherited from Mixin XML frame.
OracleHUD_PB_TabsMixin = CreateFromMixins({})
OracleHUD_PB_TabsMixin._class = "OracleHUD_PB_TabsMixin"
-------------------------------------------------------------------------------
--- Configure mixin with required data.
--- @param  db 		    OracleHUD_PB_DB	    OracleHUD Pet Battles Database.
function OracleHUD_PB_TabsMixin:Configure(db)
	if (db == nil) then
		error(self._class..":Configure(): Invalid arguments")
	end
	self.db = db
	self.tabs = {}
	self.index = 0
end
-------------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_TabsMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Tabs") end
	-- Pull in any XML defined tabs.
	local children = { self:GetChildren() };
	for _, child in ipairs(children) do
		local name = child:GetName()
		if (name ~= self:GetName().."Menu" and name ~= self:GetName().."Body") then
			if (self:TabExists(child:GetName()) == false) then
				self:AddTab(child.name, child)
			end
		end
	end
	-- Now look for lua tabs.
	for i = 1, #self.tabs do
		self.tabs[i]:Initialize()
	end
	if (callback ~= nil) then
		callback()
	end
end
-------------------------------------------------------------------------------
--- Check if a tab already exists with this name.
--- @param	name	string	Frame's unique global name.
--- @return boolean
function OracleHUD_PB_TabsMixin:TabExists(name)
	local exists = false
	for i = 1, #self.tabs do
		if (self.tabs[i]:GetName() == name) then
			exists = true
			break
		end
	end
	return exists
end
-------------------------------------------------------------------------------
--- Create a new tab and call configure on it.
--- @param	name	string		Name of tab.
--- @param	panel	any?		(Optional) Already existing frame to use as the tab's panel.
--- @return	any	Frame			Frame of newly created tab.
function OracleHUD_PB_TabsMixin:AddTab(name, panel)
	if (panel == nil) then
		panel = CreateFrame("Frame", "$parent"..name.."Panel", self.Body, "OracleHUD_PB_TabPanelTemplate")
	end
	panel:SetParent(self.Body)
	panel:ClearAllPoints()
	panel:SetPoint("TOPLEFT", self.Body, "TOPLEFT", 0, 0)
	panel:SetPoint("BOTTOMRIGHT", self.Body, "BOTTOMRIGHT", 0, 0)
	--- @type OracleHUD_PB_TabButton
	---@diagnostic disable-next-line: assign-type-mismatch
	local tab = CreateFrame("Button", "$parent"..name.."Tab", self.Menu, "OracleHUD_PB_TabButtonTemplate")
	tab:Configure(self.db, name, panel)
	if (self.index == 0) then
		tab:SetPoint("TOPLEFT", self.Menu, "TOPLEFT", 0, 0)
	else
		tab:SetPoint("TOPLEFT", self.tabs[self.index], "TOPRIGHT", 2, 0)
	end
	tab:SetCallback(function(button)
		self:SetFocus(button)
	end)
	self.index = self.index + 1
	self.tabs[self.index] = tab
	return tab
end
-------------------------------------------------------------------------------
--- Switch to a tab.
--- @param	tab	OracleHUD_PB_TabButton	Tab button to focus on.
function OracleHUD_PB_TabsMixin:SetFocus(tab)
	tab:Focus()
	for i = 1, #self.tabs do
		if (self.tabs[i].name ~= tab.name) then
			self.tabs[i]:FocusLost()
		end
	end
end
-------------------------------------------------------------------------------
--- Get a tab frame by it's name.
--- @param	name	string		Text displayed on tab.
function OracleHUD_PB_TabsMixin:GetTabByName(name)
	local tab = nil
	for i = 1, #self.tabs do
		if (self.tabs[i].name == name) then
			tab = self.tabs[i]
			break
		end
	end
	return tab
end
-------------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TabsMixin:OnSizeChanged()
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TabsMixin:OnLoad()
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:HookScript("OnSizeChanged", function()
		self:OnSizeChanged()
	end)
end