-- Custom dropdown buttons are instantiated by some external system.
-- When calling UIDropDownMenu_AddButton that system sets info.customFrame to the instance of the frame it wants to place on the menu.
-- The dropdown menu creates its button for the entry as it normally would, but hides all elements.  The custom frame is then anchored
-- to that button and assumes responsibility for all relevant dropdown menu operations.
-- The hidden button will request a size that it should become from the custom frame.

OracleHUD_DropDownMenuButtonMixin = {}

function OracleHUD_DropDownMenuButtonMixin:OnEnter(...)
	ExecuteFrameScript(self:GetParent(), "OnEnter", ...);
end

function OracleHUD_DropDownMenuButtonMixin:OnLeave(...)
	ExecuteFrameScript(self:GetParent(), "OnLeave", ...);
end

function OracleHUD_DropDownMenuButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		OracleHUD_ToggleDropDownMenu(nil, nil, self:GetParent(), self:GetParent());
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

OracleHUD_LargeDropDownMenuButtonMixin = CreateFromMixins(OracleHUD_DropDownMenuButtonMixin);

function OracleHUD_LargeDropDownMenuButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		local parent = self:GetParent();
		OracleHUD_ToggleDropDownMenu(nil, nil, parent, parent, -8, 8);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

OracleHUD_DropDownExpandArrowMixin = {};

function OracleHUD_DropDownExpandArrowMixin:OnEnter()
	local level =  self:GetParent():GetParent():GetID() + 1;

	CloseDropDownMenus(level);

	if self:IsEnabled() then
		local listFrame = _G["DropDownList"..level];
		if ( not listFrame or not listFrame:IsShown() or select(2, listFrame:GetPoint(1)) ~= self ) then
			OracleHUD_ToggleDropDownMenu(level, self:GetParent().value, nil, nil, nil, nil, self:GetParent().menuList, self, nil, self:GetParent().menuListDisplayMode);
		end
	end
end

function OracleHUD_DropDownExpandArrowMixin:OnMouseDown(button)
	if self:IsEnabled() then
		OracleHUD_ToggleDropDownMenu(self:GetParent():GetParent():GetID() + 1, self:GetParent().value, nil, nil, nil, nil, self:GetParent().menuList, self, nil, self:GetParent().menuListDisplayMode);
	end
end

OracleHUD_UIDropDownCustomMenuEntryMixin = {};

function OracleHUD_UIDropDownCustomMenuEntryMixin:GetPreferredEntryWidth()
	return self:GetWidth();
end

function OracleHUD_UIDropDownCustomMenuEntryMixin:GetPreferredEntryHeight()
	return self:GetHeight();
end

function OracleHUD_UIDropDownCustomMenuEntryMixin:OnSetOwningButton()
	-- for derived objects to implement
end

function OracleHUD_UIDropDownCustomMenuEntryMixin:SetOwningButton(button)
	self:SetParent(button:GetParent());
	self.owningButton = button;
	self:OnSetOwningButton();
end

function OracleHUD_UIDropDownCustomMenuEntryMixin:GetOwningDropdown()
	return self.owningButton:GetParent();
end

function OracleHUD_UIDropDownCustomMenuEntryMixin:SetContextData(contextData)
	self.contextData = contextData;
end

function OracleHUD_UIDropDownCustomMenuEntryMixin:GetContextData()
	return self.contextData;
end

OracleHUD_ColorSwatchMixin = {}

function OracleHUD_ColorSwatchMixin:SetColor(color)
	self.Color:SetVertexColor(color:GetRGB());
end