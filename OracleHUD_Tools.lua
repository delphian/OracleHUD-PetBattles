
function OracleHUD_UUID()
	local random = math.random
	local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	return string.gsub(template, '[xy]', function (c)
		local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
		return string.format('%x', v)
	end)
end

function OracleHUD_Dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. OracleHUD_Dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end
-------------------------------------------------------------------------------
--- Copy a lua table (avoid pass by reference)
-- @param table		Table to make copy of.
function OracleHUD_TableCopy(table)
	function copy(obj, seen)
		if type(obj) ~= 'table' then return obj end
		if seen and seen[obj] then return seen[obj] end
		local s = seen or {}
		local res = setmetatable({}, getmetatable(obj))
		s[obj] = res
		for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
		return res
	end
	local copiedTable = copy(table)
	return copiedTable
end
-------------------------------------------------------------------------------
--- Get the length of a table, meaning the number of items in the table.
-- @param table		Table to get length of.
function OracleHUD_TableGetLength(table)
	local count = 0
	for _ in pairs(table) do count = count + 1 end
	return count
end
-------------------------------------------------------------------------------
--- Split wow formated text into individual lines
-- @param text		Original text to split into lines based on |n
function OracleHUD_StringSplitWOWText(text)
	local lines = {}
	local cleanLines = OracleHUD_StringSplit(text, "|n")
	for k, v in pairs(cleanLines) do
		cleanLines2 = OracleHUD_StringSplit(v, "\n")
		for k, v in pairs(cleanLines2) do
			table.insert(lines, v)
		end
	end
	return lines
end
-------------------------------------------------------------------------------
--- Split a string into multiple parts based on a character or substring.
-- @param text		Original text to be split into pieces.
-- @param separator	Seperator string or character to split text up with.
function OracleHUD_StringSplit(text, separator)
	local splitText = {}
	local index = string.find(text, separator)
	while (index ~= nil) do
		table.insert(splitText, string.sub(text, 1, index - string.len(separator)))
		text = string.sub(text, index + string.len(separator))
		index = string.find(text, separator)
	end
	table.insert(splitText, text)
	return splitText
end
-------------------------------------------------------------------------------
--- Remove wow color formatting from text string.
-- @param text		Original text with wow color formatting.
function OracleHUD_StringRemoveWOWColor(text)
	local cleanText = text
	if (text ~= nil and text ~= "") then
		cleanText = string.gsub(text, "(|c[0-9A-F]+)", function(match)
			local replace = match
			if (string.len(match) == 10) then
				replace = ""
			end
			if (string.len(match) > 10) then
				replace = string.sub(match, 11, string.len(match))
			end
			return replace
		end)
	end
	return cleanText
end
-------------------------------------------------------------------------------
--- Replace any occurance of a WOW new line or carriage return.
-- @param text		Original text with WOW CR or LF.
-- @param sub		(Optional) substitute this value instead. Defaults to empty string.
function OracleHUD_StringReplaceWOWCrLf(text, sub)
	local cleanText = text
	if (text ~= nil and text ~= "") then
		if (sub == nil) then
			sub = ""
		end
		cleanText = string.gsub(text, "(|[r,n])", function(match)
			return sub
		end)
	end
	return cleanText
end


function OracleHUD_StringGetBytes(text)
	local newString = ""
	for i = 1, string.len(text) do
		local char = string.sub(text, i, i)
		if (char ~= nil) then
			local charByte = string.byte(char)
			if (charByte == nil) then charByte = "" end
			newString = newString .. char .. ":" .. charByte .. ","
		end
	end
	return newString
end

---------------------------------------------------------------------------
--- Map a value from primary range into a secondary range.
--- Example: map range from 1 to 3 into 75 to 120: LinearFit(value, 1, 3 75, 120)
-- @param value     Value located in primary range.
-- @param valueLow  Low end of primary range.
-- @param valueHigh High end of primary range.
-- @param fitLow    Low end of secondary range.
-- @param fitHigh   High end of secondary range.
-- @param bounded   (Optional, defaults to true) Constrain result to the 
--                  limits of the secondary range.
function OracleHUD_LinearFit(value, valueLow, valueHigh, fitLow, fitHigh, bounded)
	if (bounded == nil) then bounded = true end
	if (bounded) then
		if (value < valueLow) then value = valueLow end
		if (value > valueHigh) then value = valueHigh end
	end
	local valueRange = valueHigh - valueLow
	local fitRange = fitHigh - fitLow
	local valuePct = (value - valueLow) / valueRange
	local nominalFit = fitRange * valuePct
	local fit = nominalFit + fitLow
	return fit
end
