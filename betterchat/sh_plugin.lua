PLUGIN.name = "Better Chat"
PLUGIN.author = "Vex"
PLUGIN.description = "..."

ix.util.Include("cl_plugin.lua")

local flipper = 0
local decrease = 0.35

local function Flip(color)
	if (flipper == 0) then
		flipper = 1
		return color
	end

	local h, s, v = ColorToHSV(color)

	v = v - (v * decrease)

	flipper = 0

	return HSVToColor(h, s, v)
end

timer.Simple(30, function()
	print("Better Chat Initalized!")

	ix.chat.Register("ic", {
		format = "%s says \"%s\"",
		indicator = "chatTalking",
		GetColor = function(self, speaker, text)
			local color = ix.config.Get("chatColor")

			if (LocalPlayer():GetEyeTrace().Entity == speaker) then
				color = ix.config.Get("chatListenColor")
			end

			return Flip(color)
		end,
		CanHear = ix.config.Get("chatRange", 280)
	})

	ix.chat.Register("scream", {
		prefix = {"/Scream", "/S"},
		indicator = "chatYelling",
		CanHear = ix.config.Get("chatRange", 280) * 4,
		description = "Scream something.",
		OnChatAdd = function(self, speaker, text)
			local name = anonymous and L"someone" or hook.Run("GetCharacterName", speaker, "ic") or (IsValid(speaker) and speaker:Name() or "Console")

			local color = Color(200, 20, 20)

			chat.AddText(color, name, color, " screams \"" .. text .. "\"")
		end,
	})

	ix.chat.Register("it", {
		OnChatAdd = function(self, speaker, text)
			local color = Flip(Color(186, 255, 149))
			chat.AddText(color, "** " .. text)
		end,
		CanHear = ix.config.Get("chatRange", 280) * 1,
		prefix = {"/It"},
		description = "@cmdIt",
		indicator = "chatPerforming",
		deadCanChat = true
	})

	ix.chat.Register("itclose", {
		OnChatAdd = function(self, speaker, text)
			local color = Flip(Color(186, 255, 149))
			chat.AddText(color, "* " .. text)
		end,
		CanHear = ix.config.Get("chatRange", 280) * 0.25,
		prefix = {"/ItClose", "/ItC"},
		description = "@cmdIt",
		indicator = "chatPerforming",
		deadCanChat = true,
		GetColor = function(self, speaker, text)
			local color = ix.chat.classes.it:GetColor(speaker, text)

			color = Color(color.r - 35, color.g - 35, color.b - 35)

			return color
		end
	})

	ix.chat.Register("itfar", {
		OnChatAdd = function(self, speaker, text)
			local color = Flip(Color(186, 255, 149))
			chat.AddText(color, "*** " .. text)
		end,
		CanHear = ix.config.Get("chatRange", 280) * 2,
		prefix = {"/ItFar", "/ItF"},
		description = "@cmdIt",
		indicator = "chatPerforming",
		deadCanChat = true,
		GetColor = function(self, speaker, text)
			local color = ix.chat.classes.it:GetColor(speaker, text)

			color = Color(color.r + 35, color.g + 35, color.b + 35)

			return color
		end
	})

	ix.chat.Register("itfarfar", {
		OnChatAdd = function(self, speaker, text)
			local color = Flip(Color(186, 255, 149))
			chat.AddText(color, "**** " .. text)
		end,
		CanHear = ix.config.Get("chatRange", 280) * 4,
		prefix = {"/ItFarFar", "/ItFF"},
		description = "@cmdIt",
		indicator = "chatPerforming",
		deadCanChat = true,
		GetColor = function(self, speaker, text)
			local color = ix.chat.classes.it:GetColor(speaker, text)

			color = Color(color.r + 55, color.g + 55, color.b + 55)

			return color
		end
	})

	ix.chat.Register("me", {
		format = "** %s %s",
		CanHear = ix.config.Get("chatRange", 280) * 1,
		prefix = {"/Me", "/Action"},
		description = "@cmdMe",
		indicator = "chatPerforming",
		deadCanChat = true,
		GetColor = function(self, speaker, text)
			local color = Flip(Color(214, 255, 255))
			return color
		end
	})

	ix.chat.Register("meclose", {
		format = "* %s %s",
		CanHear = ix.config.Get("chatRange", 280) * 0.25,
		prefix = {"/MeClose", "/MeC"},
		description = "Preform an action closely.",
		indicator = "chatPerforming",
		deadCanChat = true,
		GetColor = function(self, speaker, text)
			local color = ix.chat.classes.me:GetColor(speaker, text)

			color = Color(color.r - 35, color.g - 35, color.b - 35)

			return color
		end
	})

	ix.chat.Register("mefar", {
		format = "*** %s %s",
		CanHear = ix.config.Get("chatRange", 280) * 2,
		prefix = {"/MeFar", "/MeF"},
		description = "Preform an action far away.",
		indicator = "chatPerforming",
		deadCanChat = true,
		GetColor = function(self, speaker, text)
			local color = ix.chat.classes.me:GetColor(speaker, text)

			color = Color(color.r + 35, color.g + 35, color.b + 35)

			return color
		end
	})

	ix.chat.Register("mefarfar", {
		format = "**** %s %s",
		CanHear = ix.config.Get("chatRange", 280) * 4,
		prefix = {"/MeFarFar", "/MeFF"},
		description = "Preform an action far away.",
		indicator = "chatPerforming",
		deadCanChat = true,
		GetColor = function(self, speaker, text)
			local color = ix.chat.classes.me:GetColor(speaker, text)

			color = Color(color.r + 55, color.g + 55, color.b + 55)

			return color
		end
	})

	ix.command.Add("Event", {
		description = "@cmdEvent",
		arguments = ix.type.text,
		adminOnly = true,
		OnRun = function(self, client, text)
			ix.chat.Send(client, "event", text)
		end
	})

	ix.chat.Register("lev", {
		prefix = {"/EventLocal", "/Levent", "/Lev"},
		CanHear = ix.config.Get("chatRange", 280) * 4,
		OnChatAdd = function(self, speaker, text)
			chat.AddText(Color(205, 100, 0), text)
		end,
		indicator = "chatPerforming",
		CanSay = function(self, speaker, text)
			return speaker:IsAdmin()
		end
	})
end)