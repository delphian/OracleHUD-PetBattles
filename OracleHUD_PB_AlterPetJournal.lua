-------------------------------------------------------------------------------
--- Insert a context drop down button on each pet row inside the pet journal.
function OracleHUD_PB_AlterPetJournal(slot, db, zoo, petInfoSvc, options)
	ScrollUtil.AddInitializedFrameCallback(
		PetJournal.ScrollBox, 
		function(o, frame, elementData)
			if (elementData.petID ~= nil) then
				local petInfo = petInfoSvc:GetPetInfoByPetId(elementData.petID)
				local i = elementData.index
				if (i ~= nil) then
					if (frame.Button == nil and petInfo ~= nil) then
						frame.Button = CreateFrame("Button", "OracleHUD_PB_PetJournalButton"..i, frame, "OracleHUD_PB_ButtonDropdownTemplate")
						frame.Button.petInfo = petInfo
						frame.Button:Configure(db)
						frame.Button:SetMenuItem("Send to Zoo", function(self, button)
							options:SetZooShow(true)
							zoo:RequestAdoptPet(button.petInfo)
						end)
						frame.Button:Initialize()
						frame.Button:SetSize(20, 20)
						frame.Button:ClearAllPoints()
						frame.Button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
						frame.Button:Show()
						frame.Button:ShowFull()
					else
						frame.Button.petInfo = petInfo
						frame.Button:Show()
					end
				end
			else
				if (frame.Button ~= nil) then
					frame.Button:Hide()
				end
			end
		end, 
		nil, 
		nil
	)
	-- Force AddInitializedFrameCallback to fire _now_.
	PetJournal:Hide()
	PetJournal:Show()
end
-- Poll for the existence of the PetJournal, which does not exist until it's first opened.
local myTimer = C_Timer.NewTicker(2, function(myTimer) 
	if (_G["PetJournal"] ~= nil) then
		myTimer:Cancel()
		OracleHUD_PB_AlterPetJournal(
			1, 
			OracleHUD_PB_DB, 
			OracleHUD_PB.Zoo, 
			OracleHUD_PB_PetInfoService,
			OracleHUD_PB_InterfaceOptions)
	end
end)
