ix.option.Add("chatIndicators", ix.type.bool, true, {
	category = "Better Chat"
})

local typing = false
local command = ""

local symbolPattern = "[~`!@#$%%%^&*()_%+%-={}%[%]|;:'\",%./<>?]"

local function GetTypingIndicator(text)
	local prefix = text:utf8sub(1, 1)

	if (!prefix:find(symbolPattern) and text:utf8len() > 1) then
		return "ic"
	else
		local chatType = ix.chat.Parse(nil, text)

		if (chatType and chatType != "ic") then
			return chatType
		end

		local start, _, commandName = text:find("/(%S+)%s")

		if (start == 1) then
			for uniqueID, _ in pairs(ix.command.list) do
				if (commandName == uniqueID) then
					return uniqueID
				end
			end
		end
	end
end

function PLUGIN:ChatTextChanged(text)
	if (text == "") then
		typing = false
		command = ""
	else
		typing = true
		command = GetTypingIndicator(text)
	end
end

function PLUGIN:FinishChat()
	typing = false
	command = ""
end

function PLUGIN:PostDrawTranslucentRenderables()
	if (!typing or !ix.option.Get("chatIndicators", true)) then return end

	local radius = 0

	if (ix.command.list[command] and ix.command.list[command]["range"]) then
		radius = ix.command.list[command]["range"]
	elseif (ix.chat.classes[command] and ix.chat.classes[command]["range"]) then
		radius = math.sqrt(ix.chat.classes[command]["range"])
	end

	if (radius == 0) then return end

	local pos = LocalPlayer():GetPos()

	render.DrawWireframeSphere(pos, radius, 12, 12, Color(184, 65, 57), true)

	render.SetColorMaterial()

	render.DrawSphere(pos, -radius, 12, 12, Color(184, 65, 57, 25))
	render.DrawSphere(pos, radius, 12, 12, Color(184, 65, 57, 25))
end