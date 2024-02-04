-- Character Model Base: https://warcraft.wiki.gg/wiki/UIOBJECT_CharacterModelBase

--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_PetAnimationTemplate_OnLoad(self)
    self.config = {
        speak = false
    }
    self.speakToken = nil
    self.debug = false
	self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    self.ENUM = ORACLEHUD_PB_DB_PET_ANIMATION_ENUM
    self.animationId = nil
    self.spellId = nil
    self.facing = 0
    self.uiWorldScale = nil
    self.uiScaleRatio = nil
    self.uiScaleMult = nil
    self.coords = {
        percent = {
            x = nil,
            y = nil
        }
    }
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
	-- @param db			Oracle HUD Pet Battle database.
	--- @param  display     OracleHUD_PB_Display
    -- @param topSkew       (Optional) Top of frame is proportional width to bottom.
	function self:Configure(db, display, topSkew)
        if (topSkew == nil) then topSkew = 1.0 end
        if (db == nil or display == nil) then
        	error("OracleHUD_PB_PetAnimationTemplate:Configure(): Invalid arguments.")
		end
		self.db = db
        self.display = display
        self.topSkew = topSkew
    end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded, use it.
    function self:Initialize()
        self:SetSpeak(self.config.speak)
        self.origWidth = self:GetWidth()
        self.origHeight = self:GetHeight()
        self.coreRatio = 1.0
        if (self.topSkew ~= nil and self.topSkew ~= 1.0) then
--            local ratio = self:LinearFit(self.coords.percent.y, -1.0, 1.0, 0.2, 1.0)
--            self:ScaleByOrig(ratio)
        end
    end
    ---------------------------------------------------------------------------
    --- Set frame offset by percent relative to parent
    -- @param xPct      X Percent (-1.0 left / +1.0 right) of reference.
    -- @param yPct      Y Percent (+1.0 top / -1.0 bottom) of reference.
    -- @param cage      (Optional, defaults to parent) reference frame to 
    --                  cage pet within.
    -- @param scale     (Optional, defaults to false) Auto scale image based on Y position.
    function self:SetOffsetByPct(xPct, yPct, cage, scale)
        if (cage == nil) then cage = self:GetParent() end
        if (scale == nil) then scale = false end
        local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint()
        if (point ~= "CENTER") then
            error("OracleHUD_PB_PetAnimationTemplate: Frame anchor point must be CENTER.")
        end
        local xPctMin = OracleHUD_FramesGetLeftBoundXPct(self:GetYPct(cage), self.topSkew)
        local xPctMax = OracleHUD_FramesGetRightBoundXPct(self:GetYPct(cage), self.topSkew)
        local yPctMax = OracleHUD_FramesGetTopBoundYPct(self:GetXPct(cage), self.topSkew)
        local yPctMin = OracleHUD_FramesGetBottomBoundYPct(self:GetXPct(cage), self.topSkew)
        if (xPct < xPctMin) then xPct = xPctMin end
        if (xPct > xPctMax) then xPct = xPctMax end
        if (yPct < yPctMin) then yPct = yPctMin end
        if (yPct > yPctMax) then yPct = yPctMax end
        local refWidth = cage:GetWidth() / 2
        local refHeight = cage:GetHeight() / 2
        local newOffsetX = OracleHUD_LinearFit(xPct, -1, 1, refWidth * -1, refWidth)
        local newOffsetY = OracleHUD_LinearFit(yPct, -1, 1, refHeight * -1, refHeight)
        self:ClearAllPoints()
        self:SetPoint(point, relativeTo, relativePoint, newOffsetX, newOffsetY)
        if (scale) then
            local ratio = OracleHUD_LinearFit(self:GetYPct(cage, true), -1.0, 1.0, 1.0, 0.2)
            self:ScaleByOrig(ratio)
        end
    end
    ---------------------------------------------------------------------------
    --- Switch pet speaking on or off.
    -- @param speak     (True or False). Enable or disable pet being able to speak.
    function self:SetSpeak(speak)
        if (self.speakToken) then
            self.speakToken:Cancel()
            self.speakToken = nil
        end
        if (speak) then
            local period = math.random(60, 600)
            self.speakToken = C_Timer.NewTicker(period, function()
                local random = math.random(1, 2)
                if (random == 1) then
                    self:Speak(ORACLEHUD_PB_CONTENTEMOTE_ENUM.SPEAK)
                end
            end)
            self.config.speak = true
        else
            self.config.speak = false
            if (self.speakToken) then self.speakToken = nil end
        end
    end
    ---------------------------------------------------------------------------
	--- Set all pet information. Will automatically disseminate info to other 
	--- methods when required.
	--- @param petInfo	OracleHUD_PB_PetInfo		OracleHUD_PB Uniform pet table.
	function self:SetPetInfo(petInfo)
        self.petInfo = petInfo
        if (self.petInfo ~= nil) then
            if (self.debug) then print(GetTime(), self.petInfo.name, "SPECIES ID", self.petInfo.speciesId) end
            self.positions = OracleHUD_PB_DB_AnimationGetPosition(self.petInfo.speciesId)
            local positions = nil
            local lighting = nil
            if (self.positions ~= nil) then positions = self.positions.default end
            if (self.positions ~= nil) then lighting = self.positions.lighting end
            if (self.positions ~= nil and self.positions.default ~= nil) then
                if (self.debug) then print("POSITIONED", self.petInfo.name) end
                self.raw = false
                self.AnimationRaw:Hide()
                self.AnimationPositioned:Show()
                self:_SetDisplayInfo(self.AnimationPositioned, self.petInfo.displayId, positions, lighting)
            else
                self.raw = true
                self.AnimationPositioned:Hide()
                self.AnimationRaw:Show()
                self:_SetDisplayInfo(self.AnimationRaw, self.petInfo.displayId, positions, lighting)
            end
            if (self.petInfo.health == 0) then
                self:SetAnimation(self.ENUM.DEAD)
            else
                self:SetAnimation(self.ENUM.STAND)
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Play a specific animation sequence.
    -- @param animationId   @see OracleHUD_PB_DB_PetAnimation
    -- @param style         (Optional, defaults to 'default') Array key in
    --                      positions to get orientation configuration from.
    function self:SetAnimation(animationId, style)
        if (style == nil) then style = "default" end
        if (self.petInfo == nil) then
            error("OracleHUD_PB_PetAnimationTemplate:SetAnimation(): SetPetInfo() must be called first.")
        end
        if (self.raw) then
            self.AnimationRaw:SetAnimation(tonumber(animationId))
        else
            self.AnimationPositioned:SetAnimation(tonumber(animationId))
        end
        self.animationId = animationId
        self.style = style
    end
    ---------------------------------------------------------------------------
    --- Play a specific spell.
    -- @param spellId       @see OracleHUD_PB_DB_Spells
    -- @param once          (Optional, defaults to false) Do not loop spell.
    function self:SetSpell(spellId, once)
        if (once == nil) then once = false end
        if (spellId == nil) then
        	error("OracleHUD_PB_PetAnimationTemplate:Configure(): Invalid arguments.")
        end
        if (self.petInfo == nil) then
            error("OracleHUD_PB_PetAnimationTemplate:SetAnimation(): SetPetInfo() must be called first.")
        end
        if (self.raw) then
            self.AnimationRaw:ApplySpellVisualKit(tonumber(spellId), once)
        else
            self.AnimationPositioned:ApplySpellVisualKit(tonumber(spellId), once)
        end
        self.spellId = spellId
    end
    ---------------------------------------------------------------------------
    --- Set the background color and transparency.
    -- @param r     red component (0-1)
    -- @param g     green component (0-1)
    -- @param b     blue component (0-1)
    -- @param a     alpha component (0-1)
    function self:SetBackgroundColor(r, b, g, a)
        self.color:SetColorTexture(r, b, g, a)
    end
    ---------------------------------------------------------------------------
    --- Set the model display and animation type.
    -- @param model         The model aniamtion frame.
    -- @param displayId     Display identifier of the pet.
    -- @param positions     (Optional) x, y, z offset positioning of animation.
    -- @param lighting      (Optional) SetLight() parameter.
    function self:_SetDisplayInfo(model, displayId, positions, lighting)
        model:ClearModel()
        model:RefreshCamera()
        model:SetDisplayInfo(displayId)
        model:SetKeepModelOnHide(true)
        if (positions ~= nil) then
            self:_PositionCameras(positions)
        end
        self.displayId = displayId
        if (lighting ~= nil) then
            model:SetLight(false, lighting)
            model:SetLight(true, lighting)
        end
        -- Crop animation based on ratio.
        self:OnSizeChanged_PetAnimationTemplate()
    end
    ---------------------------------------------------------------------------
    --- Orient the model cameras and zoom to frame the image correctly.
    -- @param positions     (Optional) x, y, z offset positioning of animation.
    function self:_PositionCameras(positions)
        if (self:_SetCustomCamera(self.AnimationPositioned) == true) then
            self.AnimationPositioned:UseModelCenterToTransform(true)
            if (self.uiWorldScale == nil) then
                self.uiWorldScale = self.AnimationPositioned:GetWorldScale()
            end
            self.uiScaleRatio = self.uiWorldScale / 0.6972603
            self.uiScaleMult = 1 / self.uiScaleRatio
            self.AnimationPositioned:SetModelScale(self.uiScaleMult)
            self.AnimationPositioned:SetFacing(self.facing)
            self.AnimationPositioned:SetPosition(1, 1, 1)
            self.AnimationPositioned:SetCameraTarget(positions.camTar.x, positions.camTar.y, positions.camTar.z);
            self.AnimationPositioned:SetCameraPosition(positions.camPos.x, positions.camPos.y, positions.camPos.z);
        end
    end
    ---------------------------------------------------------------------------
    --- If model is not already in custom camera mode then make it so.
    function self:_SetCustomCamera(model)
        local success = true
        if (model:HasCustomCamera() == false) then
            model:MakeCurrentCameraCustom()
        end
        model:SetCustomCamera(1)
        if (model:HasCustomCamera() == false) then
            -- Unusual behavior. Sometimes Fluxfire Feline sets this off.
            print("FAIL ON "..self.petInfo.name.." CUSTOM CAMERA!")
            success = false
        end
        return success
    end
    ---------------------------------------------------------------------------
    --- Transition from current anchor to new anchor without changing position 
    --- on screen
    -- @param newFrame      New frame to anchor to.
    function self:TransitionToFrame(newFrame)
        local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint()
        -- if pet loadout frame is invisible (and zero size) this will fail.
        local adjustX = newFrame:GetLeft() - self:GetLeft()
        local adjustY = newFrame:GetTop() - self:GetTop()
        self:SetParent(newFrame)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", newFrame, "TOPLEFT", adjustX * -1, adjustY * -1)
    end
    ---------------------------------------------------------------------------
    --- Instantly grow or shrink the size of the animation.
    -- @param ratio     Multiplier to new size (1.0 = same size)
    function self:ScaleByOrig(ratio)
        local targetWidth = self.origWidth * (self.coreRatio * ratio)
        local targetHeight = self.origHeight * (self.coreRatio * ratio)
        self:SetWidth(targetWidth)
        self:SetHeight(targetHeight)
        -- Hmm, why??
        self:OnSizeChanged_PetAnimationTemplate()
    end
    ---------------------------------------------------------------------------
    --- Grow or shrink the size of the animation.
    --- Method will attempt to run as fast as possible (interval = 0).
    -- @param ratio     Multiplier to new size (1.0 = same size)
    -- @param time      How long size modification should take.
    -- @param callback  (Optional) Execute callback when scale is finished.
    function self:Scale(ratio, time, callback)
        local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint()
        local targetWidth = self:GetWidth() * ratio
        local targetHeight = self:GetHeight() * ratio
        local startWidth = self:GetWidth()
        local startHeight = self:GetHeight()
        local targetOffsetX = offsetX + ((startWidth - targetWidth) / 2)
        local targetOffsetY = offsetY - ((startHeight - targetHeight) / 2)
        local interval = 0.0
        local startTime = GetTime()
        C_Timer.NewTicker(interval, function(timer)
            local pctTime = (GetTime() - startTime) / time
            if (pctTime >= 1) then
                timer:Cancel()
                self:SetWidth(targetWidth)
                self:SetHeight(targetHeight)
                self.coreRatio = self.coreRatio * ratio
                self:SetPoint(point, relativeTo, relativePoint, targetOffsetX, targetOffsetY)
                if (self.debug) then print(GetTime(), self.petInfo.name, "SCALE FINISHED") end
                if (callback ~= nil) then
                    callback()
                end
            else
                local addWidth = (targetWidth - startWidth) * pctTime
                local addHeight = (targetHeight - startHeight) * pctTime
                local addOffsetX = ((targetOffsetX - offsetX) * pctTime)
                local addOffsetY = ((targetOffsetY - offsetY) * pctTime)
                if (targetWidth > startWidth and (startWidth + addWidth) >= targetWidth) then addWidth = 0 end
                if (targetWidth < startWidth and (startWidth + addWidth) <= targetWidth) then addWidth = 0 end
                if (targetHeight > startHeight and (startHeight + addHeight) >= targetHeight) then addHeight = 0 end
                if (targetHeight < startHeight and (startHeight + addHeight) <= targetHeight) then addHeight = 0 end
                self:SetWidth(startWidth + addWidth)
                self:SetHeight(startHeight + addHeight)
                self:SetPoint(point, relativeTo, relativePoint, offsetX + addOffsetX, offsetY + addOffsetY)
            end
        end)
    end
    -------------------------------------------------------------------------------
    --- Get a random emote from the pet.
    --- @param type     ORACLEHUD_PB_CONTENTEMOTE_ENUM
    --- @return string|nil emote
    function self:GetEmote(type)
        local emote = nil
        if (self.petInfo ~= nil) then
            emote = self.petInfo:GetEmote(type)
        end
        return emote
    end
    ---------------------------------------------------------------------------
    --- Speak a random emote into the display.
    --- @param type     ORACLEHUD_PB_CONTENTEMOTE_ENUM
    function self:Speak(type)
        if (self.display ~= nil) then
            local emote = self:GetEmote(type)
            if (emote ~= nil) then
                self.display:Print(emote)
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Reports if the pet can emote.
    --- @param type     ORACLEHUD_PB_CONTENTEMOTE_ENUM
    function self:CanSpeak(type)
        local canSpeak = false
        local emote = self:GetEmote(type)
        if (emote ~= nil) then
            canSpeak = true
        end
        return canSpeak
    end
    ---------------------------------------------------------------------------
    --- Calculate the proper width of the animation after applying aspect 
    --- ratio adjustment.
    function self:GetRatioWidth()
        local ratioWidth = self:GetWidth()
        if (self.positions ~= nil and self.positions[self.style] ~= nil) then
            local pos = self.positions[self.style]
            if (pos.ratio ~= nil and pos.ratio < 1.0) then
                ratioWidth = ratioWidth * pos.ratio
            end
        end
        return ratioWidth
    end
    ---------------------------------------------------------------------------
    --- Calculate the proper height of the animation after applying aspect 
    --- ratio adjustment.
    function self:GetRatioHeight()
        local ratioHeight = self:GetWidth()
        if (self.positions ~= nil and self.positions[self.style] ~= nil) then
            local pos = self.positions[self.style]
            if (pos.ratio ~= nil and pos.ratio > 1.0) then
                ratioHeight = ratioHeight / pos.ratio
            end
        end
        return ratioHeight
    end
    ---------------------------------------------------------------------------
    --- Transform X offset of child into percent (+1.0 top / -1.0 bottom) of 
    --- reference (parent).
    -- @param reference (Optional, defaults to parent of child) Reference frame
    --                  of child.
    -- @param bounded   (Optional, defaults to true) Constrain result from -1
    --                  to +1, regardless of actual position.
    function self:GetXPct(reference, bounded)
        return OracleHUD_FramesGetXPct(self, reference, bounded)
    end
    ---------------------------------------------------------------------------
    --- Transform Y offset of child into percent (+1.0 top / -1.0 bottom) of 
    --- reference (parent).
    -- @param reference (Optional, defaults to parent of child) Reference frame
    --                  of child.
    -- @param bounded   (Optional, defaults to true) Constrain result from +1
    --                  to -1, regardless of actual position.
    function self:GetYPct(reference, bounded)
        return OracleHUD_FramesGetYPct(self, reference, bounded)
    end
    ---------------------------------------------------------------------------
    --- Walk a pet forward.
    -- @param distance      How far the pet should move. (0-1, percent of 
    --                      parentFrame when not bounded, percent of distance
    --                      to wall when bounded)
    -- @param time          Total amount of time movement should take.
    -- @param bounded       (Optional, defaults to true) Pet must stay bounded
    --                      within parent container.
    -- @param cage          (Optional, defaults to parent) reference frame to 
    --                      cage pet within.
    -- @param callback      (Optional) Execute callback when walk is finished
    function self:PlatformWalkUp(distance, time, bounded, cage, callback)
        if (bounded == nil) then bounded = true end
        if (cage == nil) then cage = self:GetParent() end
        self:PlatformFaceBackward()
        self:SetAnimation(OracleHUD_PB_DB_AnimationGetId(self.ENUM.WALK, self.petInfo.id), self.style)
        local startPct = self:GetYPct(cage, bounded)
        local destPct = startPct + (distance * 2.0)
        if (bounded) then
            destPct = startPct + (distance * (1.0 - startPct))
        end
        local startTime = GetTime()
        C_Timer.NewTicker(0.0, function(timer)
            local pctTime = (GetTime() - startTime) / time
            if (pctTime >= 1) then
                timer:Cancel()
                self:SetAnimation(OracleHUD_PB_DB_AnimationGetId(self.ENUM.STAND, self.petInfo.id), self.style)
                if (callback ~= nil) then
                    callback()
                end
            end
            local yPct = ((destPct - startPct) * pctTime) + startPct
            self:SetOffsetByPct(self:GetXPct(cage, bounded), yPct, cage, true)
        end)
    end
    ---------------------------------------------------------------------------
    --- Walk a pet backward.
    -- @param distance      How far the pet should move. (0-1, percent of 
    --                      cage when not bounded, percent of distance
    --                      to wall when bounded)
    -- @param time          Total amount of time movement should take.
    -- @param bounded       (Optional, defaults to true) Pet must stay bounded
    --                      within parent container.
    -- @param cage          (Optional, defaults to parent) reference frame to 
    --                      cage pet within.
    -- @param callback      (Optional) Execute callback when walk is finished
    function self:PlatformWalkDown(distance, time, bounded, cage, callback)
        if (bounded == nil) then bounded = true end
        if (cage == nil) then cage = self:GetParent() end
        self:PlatformFaceForward()
        self:SetAnimation(OracleHUD_PB_DB_AnimationGetId(self.ENUM.WALK, self.petInfo.id), self.style)
        local startPct = self:GetYPct(cage, bounded)
        local destPct = startPct + (distance * -2.0)
        if (bounded) then
            destPct = startPct + (distance * (-1.0 - startPct))
        end
        local startTime = GetTime()
        C_Timer.NewTicker(0.0, function(timer)
            local pctTime = (GetTime() - startTime) / time
            if (pctTime >= 1) then
                timer:Cancel()
                self:SetAnimation(OracleHUD_PB_DB_AnimationGetId(self.ENUM.STAND, self.petInfo.id), self.style)
                if (callback ~= nil) then
                    callback()
                end
            end
            local yPct = ((destPct - startPct) * pctTime) + startPct
            self:SetOffsetByPct(self:GetXPct(cage, bounded), yPct, cage, true)
        end)
    end
    ---------------------------------------------------------------------------
    --- Walk a pet leftward.
    -- @param distance      How far the pet should move. (0-1, percent of 
    --                      cage when not bounded, percent of distance
    --                      to wall when bounded)
    -- @param time          Total amount of time movement should take.
    -- @param bounded       (Optional, defaults to true) Pet must stay bounded
    --                      within parent container.
    -- @param cage          (Optional, defaults to parent) reference frame to 
    --                      cage pet within.
    -- @param callback      (Optional) Execute callback when walk is finished
    function self:PlatformWalkLeft(distance, time, bounded, cage, callback)
        if (bounded == nil) then bounded = true end
        if (cage == nil) then cage = self:GetParent() end
        self:PlatformFaceLeft()
        self:SetAnimation(OracleHUD_PB_DB_AnimationGetId(self.ENUM.WALK, self.petInfo.id), self.style)
        local startPct = self:GetXPct(cage, bounded)
        local destPct = startPct + (distance * -2.0)
        if (bounded) then
            destPct = startPct + (distance * (-1.0 - startPct))
        end
        local startTime = GetTime()
        C_Timer.NewTicker(0.0, function(timer)
            local pctTime = (GetTime() - startTime) / time
            if (pctTime >= 1) then
                timer:Cancel()
                self:SetAnimation(OracleHUD_PB_DB_AnimationGetId(self.ENUM.STAND, self.petInfo.id), self.style)
                if (callback ~= nil) then
                    callback()
                end
            end
            local xPct = ((destPct - startPct) * pctTime) + startPct
            self:SetOffsetByPct(xPct, self:GetYPct(cage, bounded), cage, true)
        end)
    end
    ---------------------------------------------------------------------------
    --- Walk a pet rightward.
    -- @param distance      How far the pet should move. (0-1, percent of 
    --                      cage when not bounded, percent of distance
    --                      to wall when bounded)
    -- @param time          Total amount of time movement should take.
    -- @param bounded       (Optional, defaults to true) Pet must stay bounded
    --                      within parent container.
    -- @param cage          (Optional, defaults to parent) reference frame to 
    --                      cage pet within.
    -- @param callback      (Optional) Execute callback when walk is finished
    function self:PlatformWalkRight(distance, time, bounded, cage, callback)
        if (bounded == nil) then bounded = true end
        if (cage == nil) then cage = self:GetParent() end
        self:PlatformFaceRight()
        self:SetAnimation(OracleHUD_PB_DB_AnimationGetId(self.ENUM.WALK, self.petInfo.id), self.style)
        local startPct = self:GetXPct(cage, bounded)
        local destPct = startPct + (distance * 2.0)
        if (bounded) then
            destPct = startPct + (distance * (1.0 - startPct))
        end
        local startTime = GetTime()
        C_Timer.NewTicker(0.0, function(timer)
            local pctTime = (GetTime() - startTime) / time
            if (pctTime >= 1) then
                timer:Cancel()
                self:SetAnimation(OracleHUD_PB_DB_AnimationGetId(self.ENUM.STAND, self.petInfo.id), self.style)
                if (callback ~= nil) then
                    callback()
                end
            end
            local xPct = ((destPct - startPct) * pctTime) + startPct
            self:SetOffsetByPct(xPct, self:GetYPct(cage, bounded), cage, true)
        end)
    end
    ---------------------------------------------------------------------------
    --- Rotate the pet on a horizontal platform to be facing left.
    function self:PlatformFaceLeft()
        self:PlatformFaceEighths(6)
    end
    ---------------------------------------------------------------------------
    --- Rotate the pet on a horizontal platform to be facing right.
    function self:PlatformFaceRight()
        self:PlatformFaceEighths(2)
    end
    ---------------------------------------------------------------------------
    --- Rotate the pet on a horizontal platform to be facing forwards toward
    --- the screen.
    function self:PlatformFaceForward()
        self:PlatformFaceEighths(0)
    end
    ---------------------------------------------------------------------------
    --- Rotate the pet on a horizontal platform to be facing backwards away
    --- from the screen.
    function self:PlatformFaceBackward()
        self:PlatformFaceEighths(4)
    end
    ---------------------------------------------------------------------------
    --- Rotate the facing angle of a pet. Angle 0 is facing at camera.
    ---   -------------
    ---   | 5   4   3 |
    ---   |           |
    ---   | 6   o   2 |
    ---   |           |
    ---   | 7   0   1 |
    ---   -------------
    -- @param eighth     The eighth angle to set pet facing (0-7)
    function self:PlatformFaceEighths(eighth)
        local positionsFaceForward = 0
        if (self.positions ~= nil and self.positions.facing ~= nil) then
            positionsFaceForward = self.positions.facing
        end
        self.facing = positionsFaceForward + ((2 * math.pi) / 8) * eighth
        self.AnimationRaw:SetFacing(self.facing)
        self.AnimationPositioned:SetFacing(self.facing)
    end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged_PetAnimationTemplate()
        self.color:SetSize(self:GetWidth(), self:GetHeight());
        self.AnimationRaw:SetWidth(self:GetRatioWidth())
        self.AnimationRaw:SetHeight(self:GetRatioHeight())
        self.AnimationPositioned:SetWidth(self:GetRatioWidth())
        self.AnimationPositioned:SetHeight(self:GetRatioHeight())
    end
    ---------------------------------------------------------------------------
    --- Set pet to default standing animation after current animation ends.
    --- This is done because some animations do not loop.
    function self:OnAnimFinished()
        local lastAnimation = self.animationId
        if (self.petInfo ~= nil and self.petInfo.health ~= nil and self.petInfo.health <= 0) then
            if (lastAnimation ~= self.ENUM.DEAD and lastAnimation ~= self.ENUM.DEATH) then
                self:SetAnimation(self.ENUM.DEATH, self.style)
            end
        else
            if (lastAnimation == self.ENUM.WALK) then
                self:SetAnimation(lastAnimation, self.style)
            end
            if (lastAnimation == self.ENUM.STANDWOUND or
                lastAnimation == self.ENUM.COMBATWOUND or
                lastAnimation == self.ENUM.COMBATWOUND or
                lastAnimation == self.ENUM.COMBATCRITICAL or
                lastAnimation == self.ENUM.ATTACKUNARMED)
            then
                self:SetAnimation(self.ENUM.STAND, self.style)
            end
        end
    end
    self.AnimationRaw:SetScript("OnAnimFinished", function()
        self:OnAnimFinished()
    end)
    self.AnimationPositioned:SetScript("OnAnimFinished", function()
        self:OnAnimFinished()
    end)
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_PetAnimationTemplate()
    end)
end