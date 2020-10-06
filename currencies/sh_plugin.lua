PLUGIN.name = "Currencies"
PLUGIN.author = "Vex"
PLUGIN.description = "A plugin that adds support for both multiable currencies as well as item based currencies."

ix.currencies = ix.currencies or {}

ix.util.Include("sh_config.lua")
ix.util.Include("sh_meta.lua")

function PLUGIN:InitializedPlugins()
	for i, v in pairs(ix.currencies.config.currencies) do
		local ITEM = ix.item.Register("currency_"..i, "base_currency", false, nil, true)
			ITEM.name 				= v.name or "NoName"
			ITEM.description 	= v.description or "NoDescription"
			ITEM.unitweight 	= v.weight or 0.001
			ITEM.model				= v.model or "models/props_lab/box01a.mdl"
			ITEM.currency			= i
	end
end

function ix.currencies.IsValid(currency)
	if (ix.currencies.config.currencies[currency]) then
		return true
	else
		return false
	end
end

function ix.currencies.GetValue(currency, value)
	if (!ix.currencies.config.currencies[currency]) then
		currency = "default"
	end

	return ix.currencies.config.currencies[currency][value]
end

-- DO NOT CHANGE: REFER TO sh_config INSTEAD --
ix.currency.Set("$", "money", "money")

function ix.currency.Get(amount, currency)
	if (!currency or (currency and !ix.currencies.IsValid(currency))) then
		currency = "default"
	end

	local default = ix.currencies.config.currencies["default"]
	currency = ix.currencies.config.currencies[currency]

	local symbol, singular, plural = currency.symbol or default.symbol, currency.singular or default.singular, currency.plural or default.plural

	if (amount == 1) then
		return "one "..singular
	else
		return ix.util.IntergerToWord(amount).." "..plural
	end
end

function ix.currency.Spawn(pos, amount, angle, currency)
	if (!amount or amount < 0) then
		print("[Helix] Can't create currency entity: Invalid Amount of money")
		return
	end

	local currency = currency or "default"

	if (!ix.currencies.IsValid(currency)) then
		print("[Helix] Can't create currency entity: Invalid currency provided")
		return
	end

	if (ix.currencies.GetValue(currency, "physical")) then
		ix.item.Spawn("currency_"..currency, pos, function(item, entity)
			item:SetAmount(math.Round(math.abs(amount)))
			return entity
		end)
	else
		local money = ents.Create("ix_money")
		money:Spawn()

		if (IsValid(pos) and pos:IsPlayer()) then
			pos = pos:GetItemDropPos(money)
		elseif (!isvector(pos)) then
			print("[Helix] Can't create currency entity: Invalid Position")

			money:Remove()
			return
		end

		money:SetPos(pos)
		-- double check for negative.
		money:SetAmount(math.Round(math.abs(amount)))
		money:SetCurrency(currency)
		money:SetAngles(angle or angle_zero)
		money:Activate()

		return money
	end
end

function PLUGIN:OnPickupMoney(client, moneyEntity)
	if (IsValid(moneyEntity)) then
		local amount = moneyEntity:GetAmount()
		local currency = moneyEntity:GetCurrency()

		client:GetCharacter():GiveMoney(amount, nil, currency)
	end
end

hook.Add("InitializedConfig", "ixMoneyCommands", function()
	ix.command.list["givemoney"] = nil
	ix.command.list["charsetmoney"] = nil
	ix.command.list["dropmoney"] = nil

	ix.command.Add("GiveMoney", {
		alias = {"GiveMoney"},
		description = "@cmdGiveMoney",
		arguments = {
			ix.type.number,
			bit.bor(ix.type.string, ix.type.optional)
		},
		OnRun = function(self, client, amount, currency)
			amount = math.floor(amount)

			if (amount <= 0) then
				return L("invalidArg", client, 1)
			end

			local currency = currency or "default"

			if (currency and !ix.currencies.IsValid(currency)) then
				return "@invalidArg", 2
			end

			local data = {}
				data.start = client:GetShootPos()
				data.endpos = data.start + client:GetAimVector() * 96
				data.filter = client
			local target = util.TraceLine(data).Entity

			if (IsValid(target) and target:IsPlayer() and target:GetCharacter()) then
				if (!client:GetCharacter():HasMoney(amount)) then
					return
				end

				target:GetCharacter():GiveMoney(amount, nil, currency)
				client:GetCharacter():TakeMoney(amount, nil, currency)

				target:NotifyLocalized("moneyTaken", ix.currency.Get(amount, currency))
				client:NotifyLocalized("moneyGiven", ix.currency.Get(amount, currency))
			end
		end
	})

	ix.command.Add("CharGiveMoney", {
		alias = {"CharGiveMoney"},
		description = "@cmdCharGiveMoney",
		superAdminOnly = true,
		arguments = {
			ix.type.character,
			ix.type.number,
			bit.bor(ix.type.string, ix.type.optional)
		},
		OnRun = function(self, client, target, amount, currency)
			amount = math.Round(amount)

			if (amount <= 0) then
				return "@invalidArg", 2
			end

			local currency = currency or "default"

			if (currency and !ix.currencies.IsValid(currency)) then
				return "@invalidArg", 3
			end

			target:GiveMoney(amount, nil, currency)
			client:NotifyLocalized("giveMoney", target:GetName(), ix.currency.Get(amount, currency))
		end
	})

	ix.command.Add("DropMoney", {
		alias = {"DropMoney"},
		description = "@cmdDropMoney",
		arguments = {
			ix.type.number,
			bit.bor(ix.type.string, ix.type.optional)
		},
		OnRun = function(self, client, amount, currency)
			amount = math.Round(amount)

			if (amount <= 0) then
				return "@invalidArg", 1
			end

			local currency = currency or "default"

			if (currency and !ix.currencies.IsValid(currency)) then
				return "@invalidArg", 2
			end

			if (!client:GetCharacter():HasMoney(amount, currency)) then
				return "@insufficientMoney"
			end

			client:GetCharacter():TakeMoney(amount, nil, currency)

			local money = ix.currency.Spawn(client, amount, nil, currency)
			if (money) then
				money.ixCharID = client:GetCharacter():GetID()
				money.ixSteamID = client:SteamID()
			end
		end
	})
end)
