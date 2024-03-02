-------------------------------------------------------------------------------
--- Locate and size a frame based on relative percentages
-- @param frame The frame to locate and size
-- @param x Offset this percentage (0-1) from the top left of container
-- @param y Offset this percentage (0-1) from the top left of container
-- @param width Size frame as this percentage of width (0-1) of container
-- @param height Size frame as this percentage of height (0-1) of container
function OracleHUD_SetFramePercent(frame, x, y, width, height)
	OracleHUD_FrameSetSizePct(frame, width, height)
	frame:ClearAllPoints()
	frame:SetPoint(
		"TOPLEFT", 
		frame:GetParent(), 
		"TOPLEFT", 
		math.floor(frame:GetParent():GetWidth() * x),
		math.floor(frame:GetParent():GetHeight() * y * -1));
end
-------------------------------------------------------------------------------
--- Size of frame based on relative percentages of parent
-- @param frame		The frame to locate and size
-- @param width		Size frame as this percentage of width (0-1) of container
-- @param height	Size frame as this percentage of height (0-1) of container
-- @param parent	(Optional) Use this frame as size reference instead of frame:Parent()
function OracleHUD_FrameSetSizePct(frame, width, height, parent)
	local reference = frame:GetParent()
	if (parent ~= nil) then
		reference = parent
	end
	if (width ~= nil and width ~= 0) then
		frame:SetWidth(math.floor(reference:GetWidth() * width))
	end
	if (height ~= nil and height ~= 0) then
		frame:SetHeight(math.floor(reference:GetHeight() * height))
	end
end
-------------------------------------------------------------------------------
--- Size of frame based on relative percentages of parent
-- @param frame		The frame to locate and size
-- @param height	Size frame as this percentage of height (0-1) of container
-- @param parent	(Optional) Use this frame as size reference instead of frame:Parent()
function OracleHUD_FrameSetHeightPct(frame, height, parent)
	local referenceParent = frame:GetParent()
	if (parent ~= nil) then
		referenceParent = parent
	end
	if (height ~= nil and height ~= 0) then
		frame:SetHeight(math.floor(referenceParent:GetHeight() * height))
	end
end
-------------------------------------------------------------------------------
--- Size of frame based on relative percentages of parent
-- @param frame		The frame to locate and size
-- @param width		Size frame as this percentage of width (0-1) of container
-- @param parent	(Optional) Use this frame as size reference instead of frame:Parent()
function OracleHUD_FrameSetWidthPct(frame, width, parent)
	local referenceParent = frame:GetParent()
	if (parent ~= nil) then
		referenceParent = parent
	end
	if (width ~= nil and width ~= 0) then
		frame:SetWidth(math.floor(referenceParent:GetWidth() * width))
	end
end
-------------------------------------------------------------------------------
--- Size frame based on relative percentages. Frame height will be calculated
--- to always make a square
-- @param frame		The frame to locate and size
-- @param width		Size frame as this percentage of width (0-1) of container
-- @param parent	(Optional) Use this frame as size reference instead of frame:Parent()
function OracleHUD_FrameSetWidthSquarePct(frame, width, parent)
	local referenceParent = frame:GetParent()
	if (parent ~= nil) then
		referenceParent = parent
	end
	if (width ~= nil and width ~= 0) then
		-- Would the calculated height exceed the parent frame height?
		local newWidth = math.floor(referenceParent:GetWidth() * width)
		if (newWidth > frame:GetParent():GetHeight()) then
			newWidth = frame:GetParent():GetHeight()
		end
		frame:SetWidth(newWidth)
		frame:SetHeight(newWidth)
	end
end
-------------------------------------------------------------------------------
--- Size frame based on relative percentages. Frame width will be calculated
--- to always make a square
-- @param frame		The frame to locate and size
-- @param height	Size frame as this percentage of height (0-1) of container
-- @param parent	(Optional) Use this frame as size reference instead of frame:Parent()
function OracleHUD_FrameSetHeightSquarePct(frame, height, parent)
	if (parent == nil) then
		parent = frame:GetParent()
	end
	if (height ~= nil and height ~= 0) then
		-- Would the calculated width exceed the parent frame width?
		local newHeight = math.floor(parent:GetHeight() * height)
		if (newHeight > parent:GetWidth()) then
			newHeight = parent:GetWidth()
		end
		frame:SetWidth(newHeight)
		frame:SetHeight(newHeight)
	end
end
-------------------------------------------------------------------------------
--- Hide a frame and set size to a single pixel.
--- This will cause anchored frames to adjust their relative position.
-- @param self		Frame to be fully hidden
function OracleHUD_FrameHideFull(self)
	if (self:IsShown() == true) then
		self.width = self:GetWidth()
		self.height = self:GetHeight()
		self:SetWidth(1)
		self:SetHeight(1)
		self:Hide()
	end
end
-------------------------------------------------------------------------------
--- Show a frame and restore size to previously stored values.
--- This will cause anchored frames to adjust their relative position.
-- @param self		Frame to be fully shown
function OracleHUD_FrameShowFull(self)
	if (self:IsVisible() == false) then
		if (self.width ~= nil) then
			self:SetWidth(self.width)
			self:SetHeight(self.height)
		end
		self:Show()
	end
end


-------------------------------------------------------------------------------
--- Count the total number of child frames.
-- @param frame		Parent frame of which to count children.
function OracleHUD_CountChildFrames(frame)
	local count = 0
	for k, v in pairs(frame) do
		if (type(v) == "table") then
			count = count + 1
		end
	end
	return count
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- Relative Positioning of Center anchored child frame.
---------------------------------------------------------------------------
--
---------------------------------------------------------------------------
--- Transform X offset of child into percent (-1 left, +1 right) of 
--- reference (parent).
-- @param offsetX   	OffsetX of child.
-- @param refWidth		Width of the reference frame.
-- @param bounded		(Optional, defaults to true) Constrain result from
--						+1 to -1, regardless of actual position.
function OracleHUD_FramesGetXPercent(offsetX, refWidth, bounded)
	if (offsetX == nil or refWidth == nil) then
		error("OracleHUD_FramesGetXPercent(): Invalid arguments.")
	end
	if (bounded == nil) then bounded = true end
	local width = refWidth / 2
	local pct = OracleHUD_LinearFit(offsetX, width * -1, width, -1, 1, bounded)
	return pct
end
---------------------------------------------------------------------------
--- Transform Y offset of child into percent (+1 top, -1 bottom) of 
--- reference (parent).
-- @param offsetY   	OffsetY of child.
-- @param refHeight		Height of the reference frame.
-- @param bounded		(Optional, defaults to true) Constrain result from
--						+1 to -1, regardless of actual position.
function OracleHUD_FramesGetYPercent(offsetY, refHeight, bounded)
	if (offsetY == nil or refHeight == nil) then
		error("OracleHUD_FramesGetYPercent(): Invalid arguments.")
	end
	if (bounded == nil) then bounded = true end
	local height = refHeight / 2
	local pct = OracleHUD_LinearFit(offsetY, height * -1, height, -1, 1, bounded)
	return pct
end
---------------------------------------------------------------------------
--- Transform X offset of child into percent (+1.0 top / -1.0 bottom) of 
--- reference (parent).
-- @param child     Child frame.
-- @param reference (Optional, defaults to parent of child) Reference frame
--                  of child.
-- @param bounded   (Optional, defaults to true) Constrain result from -1
--                  to +1, regardless of actual position.
function OracleHUD_FramesGetXPct(child, reference, bounded)
	if (child == nil) then
		error("OracleHUD_FramesGetXPct(): Invalid arguments.")
	end
	if (reference == nil) then reference = child:GetParent() end
	if (bounded == nil) then bounded = true end
	local _, _, _, offsetX, _ = child:GetPoint()
	local pct = OracleHUD_FramesGetXPercent(offsetX, reference:GetWidth(), bounded)
	return pct
end
---------------------------------------------------------------------------
--- Transform Y offset of child into percent (+1.0 top / -1.0 bottom) of 
--- reference (parent).
-- @param child     Child frame.
-- @param reference (Optional, defaults to parent of child) Reference frame
--                  of child.
-- @param bounded   (Optional, defaults to true) Constrain result from +1
--                  to -1, regardless of actual position.
function OracleHUD_FramesGetYPct(child, reference, bounded)
	if (child == nil) then
		error("OracleHUD_FramesGetYPct(): Invalid arguments.")
	end
	if (reference == nil) then reference = child:GetParent() end
	if (bounded == nil) then bounded = true end
	local _, _, _, _, offsetY = child:GetPoint()
	local pct = OracleHUD_FramesGetYPercent(offsetY, reference:GetHeight(), bounded)
	return pct
end
---------------------------------------------------------------------------
--- For a top skewed frame, get left bound X percent of a child frame given 
---	the frames y offset percent.
-- @param yPct			(-1 to 1) Y Percent of child in reference frame.
-- @param topSkewPct	(0 to 1) Percentage of middle top reference frame 
--						that corresponds to full width of bottom of reference 
--						frame.
-- @param bounded   	(Optional, defaults to true) Constrain result from -1
--		                to -topSkewPct, regardless of actual yPct position.
function OracleHUD_FramesGetLeftBoundXPct(yPct, topSkewPct, bounded)
	if (yPct == nil or topSkewPct == nil) then
		error("OracleHUD_FramesGetLeftBoundXPct(): Invalid arguments.")
	end
	if (bounded) then
		yPct = min(max(yPct, -1), 1)
	end
	local leftBoundPct = OracleHUD_LinearFit(yPct, -1.0, 1.0, -1, topSkewPct * -1)
	return leftBoundPct
end
---------------------------------------------------------------------------
--- For a top skewed frame, get right bound X percent of a child frame given 
---	the frames y offset percent.
-- @param yPct			(-1 to 1) Y Percent of child in reference frame.
-- @param topSkewPct	(0 to 1) Percentage of middle top reference frame 
--						that corresponds to full width of bottom of reference 
--						frame.
-- @param bounded   	(Optional, defaults to true) Constrain result from -1
--		                to -topSkewPct, regardless of actual yPct position.
function OracleHUD_FramesGetRightBoundXPct(yPct, topSkewPct, bounded)
	if (yPct == nil or topSkewPct == nil) then
		error("OracleHUD_FramesGetRightBoundXPct(): Invalid arguments.")
	end
	if (bounded) then
		yPct = min(max(yPct, -1), 1)
	end
	local rightBoundPct = OracleHUD_LinearFit(yPct, -1.0, 1.0, 1, topSkewPct)
	return rightBoundPct
end
---------------------------------------------------------------------------
--- For a top skewed frame, get top bound Y percent of a child frame given 
---	the frames x offset percent.
-- @param xPct			(-1 to 1) X Percent of child in reference frame.
-- @param topSkewPct	(0 to 1) Percentage of middle top reference frame 
--						that corresponds to full width of bottom of reference 
--						frame.
-- @param bounded   	(Optional, defaults to true) Constrain result from -1
--		                to +1, regardless of actual xPct position.
function OracleHUD_FramesGetTopBoundYPct(xPct, topSkewPct, bounded)
	if (xPct == nil or topSkewPct == nil) then
		error("OracleHUD_FramesGetTopBoundYPct(): Invalid arguments.")
	end
	if (bounded) then
		xPct = min(max(xPct, -1), 1)
	end
	local xPctMin = -1
	local xPctMax = (topSkewPct) * -1
	local topBoundPct = OracleHUD_LinearFit(xPct, xPctMin, xPctMax, -1, 1)
	return topBoundPct
end
---------------------------------------------------------------------------
--- For a top skewed frame, get bottom bound Y percent of a child frame given 
---	the frames x offset percent.
-- @param xPct			(-1 to 1) X Percent of child in reference frame.
-- @param topSkewPct	(0 to 1) Percentage of middle top reference frame 
--						that corresponds to full width of bottom of reference 
--						frame.
-- @param bounded   	(Optional, defaults to true) Constrain result from -1
--		                to +1, regardless of actual xPct position.
function OracleHUD_FramesGetBottomBoundYPct(xPct, topSkewPct, bounded)
	if (xPct == nil or topSkewPct == nil) then
		error("OracleHUD_FramesGetBottomBoundYPct(): Invalid arguments.")
	end
	if (bounded) then
		xPct = min(max(xPct, -1), 1)
	end
	bottomBoundPct = -1
	return bottomBoundPct
end
