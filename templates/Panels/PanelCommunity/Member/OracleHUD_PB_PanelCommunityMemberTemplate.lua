--- @class OracleHUD_PB_PanelCommunityMemberTemplate
--- @field  Configure   function    

--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_PanelCommunityMemberTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
	self.ShowFull = OracleHUD_FrameShowFull
    -- Emulate inheritence even though we are composition.
    function self:SetPetInfo(...) self.Pet:SetPetInfo(...) end
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db			Oracle HUD Pet Battle database.
	--- @param  display     OracleHUD_PB_Display
	-- @param petInfoSvc	Oracle HUD Pet Information Service.
    function self:Configure(db, display, petInfoSvc, networkSvc)
        if (db == nil or display == nil or petInfoSvc == nil) then
            error("OracleHUD_PB_PanelCommunityMemberTemplate:Configure(): Invalid arguments.")
		end
		self.db = db
        self.display = display
		self.petInfoSvc = petInfoSvc
        self.networkSvc = networkSvc
--        local font, size, flags = self.Name.font:GetFont()
--        self.Name.font:SetFont(font, fontSize, flags)
        self.Pet:Configure(db, display)
	end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    function self:Initialize()
        self.Pet:Initialize()
	end
    ---------------------------------------------------------------------------
    --- Set the name of the member.
    -- @param name      Name of member.
    function self:SetName(name)
        self.Name:SetText(name)
    end
    ---------------------------------------------------------------------------
    --- Draw attention to this member by glowing the border.
    function self:Notify()
        self.borderHighlight:SetAlpha(0)
        self.borderHighlight:Show()
        UIFrameFadeOut(self.border, 2, 1.0, 0.0)
        UIFrameFadeIn(self.borderHighlight, 2, 0.0, 0.8)
        C_Timer.After(8, function()
            UIFrameFadeOut(self.borderHighlight, 2, 0.8, 0.0)
            UIFrameFadeIn(self.border, 2, 0.0, 1.0)
        end)
    end
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
	end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
	function self:OnSizeChanged_PanelCommunityMemberTemplate()
        self.Pet:SetWidth(self.Pet:GetHeight())
	end
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:SetScript("OnSizeChanged", function()
		self:OnSizeChanged_PanelCommunityMemberTemplate()
	end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
