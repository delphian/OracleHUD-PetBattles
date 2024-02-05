--- Tooltip that displays generic pet species information.
--- @class	OracleHUD_PB_TooltipPetInfoContent : OracleHUD_PB_TooltipPetInfoId
--- @field	Left			any			Inherited from mixin XML frame.
--- @field	Content			any			Inherited from mixin XML frame.
OracleHUD_PB_TooltipPetInfoContentMixin = CreateFromMixins({})
OracleHUD_PB_TooltipPetInfoContentMixin._class = "OracleHUD_PB_TooltipPetInfoContentMixin"
--- No supers, we are using composition instead of inheritence.
---------------------------------------------------------------------------
--- Configure mixin with required data.
--- @param db 			OracleHUD_PB_DB	OracleHUD Pet Battles Database.
function OracleHUD_PB_TooltipPetInfoContentMixin:Configure(db)
	if (db == nil) then
		error(self._class":Configure(): Invalid arguments.")
	end
	self.db = db
	self.Left:Configure(db)
	self.Content.EditBox:Configure(db)
	-- Hijack a whole bunch of stuff to simulate an integrated tooltip.
	self.Left.NineSlice:Hide()
	self.Left:SetScript("OnMouseDown", function()
		self:StartMoving()
	end)
	self.Left:SetScript("OnMouseUp", function()
		self:StopMovingOrSizing()
	end)
	self.Left.CloseButton:Hide()
	self.Left.PetType:ClearAllPoints()
	self.Left.PetType:SetPoint("TOPRIGHT", self.Left, "TOPRIGHT", 0, -12)
	--
	self:SetBackdropColor(0, 0, 0, 0.8)
end

function OracleHUD_PB_TooltipPetInfoContentMixin:serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end


---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_TooltipPetInfoContentMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Pet Info Content Tooltip") end
	self.Content.EditBox:SetSubmitCallback(function(editbox, content)
		local emotesTable = json.parse(content)
		if (emotesTable ~= nil) then
			self.petInfo.content.emotes = emotesTable
		end
		self:PrintPetInfo()
	end)
	self.Content.EditBox:SetCancelCallback(function(editbox, content)
		print("CANCEL")
	end)
	self.Left:Initialize(function()
		self.Content.EditBox:Initialize(callback)
	end)
end
-------------------------------------------------------------------------------
--- Set pet information to be displayed.
--- @param petInfo OracleHUD_PB_PetInfo
function OracleHUD_PB_TooltipPetInfoContentMixin:SetPetInfo(petInfo)
	self.petInfo = petInfo
	self.Left:SetPetInfo(petInfo)
	self:PrintPetInfo()
	self:OnSizeChanged()
end
-------------------------------------------------------------------------------
--- Copy pet information into fields that are displayed by tooltip.
function OracleHUD_PB_TooltipPetInfoContentMixin:PrintPetInfo()
	self.Left:PrintPetInfo()
	if (self.petInfo.content ~= nil and self.petInfo.content.emotes ~= nil) then
		self.Content.EditBox.Scroll.Box:SetText(json.stringify(self.petInfo.content.emotes))
	else
		self.Content.EditBox.Scroll.Box:SetText("")
	end
end
---------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
function OracleHUD_PB_TooltipPetInfoContentMixin:OnSizeChanged()
	OracleHUD_FrameSetWidthPct(self.Left, 0.4)
	OracleHUD_FrameSetWidthPct(self.Content, 0.6)
end
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TooltipPetInfoContentMixin:OnLoad()
	self:OnSizeChanged()
end
