--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ZooPetAnimationTemplate_OnLoad(self)
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		Oracle HUD Pet Battle database.
    -- @param zooPet    Meta information about a pet belonging inside a zoo.Object containing properties concerning the pet. 
    --                  Created by OracleHUD_PB_ZooTemplate:AdoptPet()
    -- @param zoo       The zoo in which pet is confined.
	function self:Configure(db, zooPet, zoo)
        if (db == nil or zooPet == nil or zoo == nil) then
            print("OracleHUD_PB_ZooPetAnimationTemplate:Configure(): Invalid arguments")
		end
        self.db = db
        self.zooPet = zooPet
        self.zoo = zoo
        self.chat = zoo.Chat
        self.topSkew = 0.6
        self:SetPetInfo(self.zooPet.petInfo)
        -- Increase the lighting of all zoo pets
        if (self.positions == nil) then
            self.positions = {}
        end
        if (self.positions.lighting == nil) then
            self.positions.lighting = { 
                omnidirection = false, 
                point = CreateVector3D(0, 0, 0), 
                ambientColor = CreateColor(1.0, 1.0, 1.0, 1.0), 
                ambientIntensity = 1.0	
            }
        end
        self.positions.lighting.ambientIntensity = self.positions.lighting.ambientIntensity * 1.25
    end
    ---------------------------------------------------------------------------
    --- Request that zoo increase the size of the pet.
    function self:SizeUp()
        self.zoo:RequestSizeUp(self.zooPet)
    end
    ---------------------------------------------------------------------------
    --- Request that zoo decrease the size of the pet.
    function self:SizeDown()
        self.zoo:RequestSizeDown(self.zooPet)
    end
    ---------------------------------------------------------------------------
    --- Display zoo themed tooltip.
    function self:DisplayZooTooltip()
        OracleHUD_PB_ZooTooltipPetInfo:ShowFull()
        OracleHUD_PB_ZooTooltipPetInfo:Configure(self.db, self.zooPet.petInfo, self.zooPet.user, self)
    end
    ---------------------------------------------------------------------------
    --- Capture mouse press and forward to handler.
    self:SetScript("OnMouseDown", function()
        self:DisplayZooTooltip()
    end)
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged_ZooPetAnimationTemplate()
        self:OnSizeChanged_PetAnimationTemplate()
    end
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_ZooPetAnimationTemplate()
    end)
end
