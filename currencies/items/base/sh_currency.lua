ITEM.name = "Currency Base"
ITEM.description = "Currency Base"
ITEM.model = "models/props_lab/box01a.mdl"

ITEM.currency = "default"

ITEM.unitweight = 0.001

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		draw.SimpleText(item:GetData("money", 0), "DermaDefault", w - 5, h - 5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black)
	end
end

function ITEM:GetDescription()
	if (self:GetMoney() > 0) then
		return self.description.."\n\nThere are "..ix.currency.Get(self:GetMoney(), self.currency).."."
	else
		return self.description
	end
end

function ITEM:GetMoney()
	return self:GetData("money", 0)
end

function ITEM:GetWeight()
	return self.unitweight * self:GetMoney()
end

function ITEM:SetAmount(amount)
	self:SetData("money", amount)
end

function ITEM:GiveMoney(amount)
	local money = self:GetMoney()

	money = money + amount

	self:SetData("money", money)

	if (ix.weight) then
		self:UpdateWeight()
	end

	local client = self.player or self.entity or false

	if (client and ix.currencies.GetValue(self.currency, "pickup")) then
		client:EmitSound(ix.currencies.GetValue(self.currency, "pickup"), 75, 90, 0.35)
	end

	return true
end

function ITEM:TakeMoney(amount)
	local money = self:GetMoney()

	if ((money - amount) <= 0) then
		if (ix.weight) then
			self:DropWeight()
		end

		self:Remove()
	else
		self:SetAmount(money - amount)
	end

	local client = self.player or self.entity or false

	if (client and ix.currencies.GetValue(self.currency, "drop")) then
		client:EmitSound(ix.currencies.GetValue(self.currency, "drop"), 75, 90, 0.35)
	end

	return money
end

ITEM.functions.dropCurrency = {
	tip = "Drop Currency",
	icon = "icon16/money_delete.png",
	OnRun = function(item)
		local client = item.player

		local plural = ix.currencies.GetValue(item.currency, "plural")

		client:RequestString("How many?", "How many "..plural.." are you dropping?", function(number)
			number = tonumber(number)

			if (number) then
				number = math.Round(number, 0)

				if (number > item:GetMoney()) then
					client:NotifyLocalized("You can't drop that many "..plural..".")
				else
					if (number == item:GetMoney()) then
						item.functions.drop.OnRun(item)
					else
						ix.item.Spawn(item.uniqueID, client:GetPos() + Vector(0, 0, 16), nil, {money = number})

						item:TakeMoney(number)
						item:DropWeight(item.unitweight * number)
					end
				end
			else
				client:NotifyLocalized("You must provide a valid number.")
			end
		end, 0)

		return false
	end,
	OnCanRun = function(item)
		return item:GetMoney() > 0 and !item.entity
	end
}

ITEM.functions.mergeCurrency = {
	tip = "Merge Currency",
	icon = "icon16/box.png",
	OnRun = function(item)
		local client = item.player

		local inventory = client:GetCharacter():GetInventory()
		local items = inventory:GetItemsByUniqueID("currency_"..item.currency)
		local money = 0

		for i, v in pairs(items) do
			if (v != item) then
				money = money + v:GetMoney()
				v:Remove()
			end
		end

		item:GiveMoney(money)

		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		return !item.entity and #client:GetCharacter():GetInventory():GetItemsByUniqueID("currency_"..item.currency) > 1
	end
}

ITEM.functions.splitCurrency = {
	tip = "Split Currency",
	icon = "icon16/box.png",
	OnRun = function(item)
		local client = item.player

		local plural = ix.currencies.GetValue(item.currency, "plural")

		client:RequestString("How many?", "How many "..plural.." are you moving into a new stack?", function(number)
			number = tonumber(number)

			if (number) then
				number = math.Round(number, 0)

				if (item:GetMoney() > number) then
					local inventory = client:GetCharacter():GetInventory()

					local success, error = inventory:Add("currency_"..item.currency, 1, {money = number})

					if (success) then
						item:TakeMoney(number)
						client:NotifyLocalized(number.." "..plural.." has been moved into a new stack.")
					else
						client:NotifyLocalized("Failed to create new stack.")
					end
				else
					client:NotifyLocalized("You don't have enough to be able to do that.")
				end
			end
		end, 0)

		return false
	end,
	OnCanRun = function(item)
		return item:GetMoney() > 1 and !item.entity
	end
}

function ITEM:SetCurrency() -- This is just here to prevent errors with the ix.currencies.Spawn function.
	return
end
