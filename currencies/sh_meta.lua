local character = ix.meta.character

function character:HasMoney(amount, currency)
	local currency = currency or "default"

	if (amount < 0) then
		print("Negative Money Check Received.")
	end

	return self:GetMoney(currency) >= amount
end

function character:GiveMoney(amount, bNoLog, currency)
	local currency = currency or "default"

	if (!ix.currencies.IsValid(currency)) then
		return false
	end

	amount = math.abs(amount)

	if (amount < 0) then
		return false
	end

	if (!bNoLog) then
		ix.log.Add(self:GetPlayer(), "money", amount)
	end

	if (ix.currencies.GetValue(currency, "physical")) then
		local items = self:GetInventory():GetItemsByUniqueID("currency_"..currency)

		if (table.Count(items) > 0) then
			items[1]:GiveMoney(amount)
		else
			local item, error = self:GetInventory():Add("currency_"..currency, 1, {money = amount})

			if (!item) then
				self:GetPlayer():ChatPrint("Looks like you accidentally dropped your "..ix.item.list["currency_"..currency].name.."!")
				ix.item.Spawn("currency_"..currency, client:GetPos() + Vector(0, 0, 12), nil, nil, {money = amount})
			end
		end
	else
		local currencies = self:GetData("currencies", {})
		currencies[currency] = (currencies[currency] or 0) + amount

		self:SetData("currencies", currencies)
	end

	if (ix.currencies.GetValue(currency, "pickup")) then
		self:GetPlayer():EmitSound(ix.currencies.GetValue(currency, "pickup"))
	end

	return true
end

function character:TakeMoney(amount, bNoLog, currency)
	local currency = currency or "default"

	if (!ix.currencies.IsValid(currency)) then
		return false
	end

	amount = math.abs(amount)

	if (amount < 0) then
		return false
	end

	if (!bNoLog) then
		ix.log.Add(self:GetPlayer(), "money", -amount)
	end

	local owing = amount

	local currencies = self:GetData("currencies", {})
	local digital = currencies[currency] or 0

	if (ix.currencies.GetValue(currency, "physical")) then -- We do this to deplete whatever type (physical or digital) that is not in use first.
		if (digital >= owing) then
			digital = digital - owing
			owing = 0
		else
			owing = owing - digital
			digital = 0
		end
	else
		local items = self:GetInventory():GetItemsByUniqueID("currency_"..currency)

		for i, v in pairs(items) do
			if (owing <= 0) then
				break
			end

			local taken = v:TakeMoney(owing)
			owing = owing - taken
		end
	end

	if (owing > 0) then
		if (ix.currencies.GetValue(currency, "physical")) then
			local items = self:GetInventory():GetItemsByUniqueID("currency_"..currency)

			for i, v in pairs(items) do
				if (owing <= 0) then
					break
				end

				local taken = v:TakeMoney(owing)
				owing = owing - taken
			end
		else
			if (digital >= owing) then
				digital = digital - owing
				owing = 0
			else
				owing = owing - digital
				digital = 0
			end
		end
	end

	currencies[currency] = digital
	self:SetData("currencies", currencies)

	if (ix.currencies.GetValue(currency, "drop")) then
		self:GetPlayer():EmitSound(ix.currencies.GetValue(currency, "drop"))
	end

	return true
end

function character:SetMoney(amount, currency) -- For technical reasons setting money directly will only effect digital, use GiveMoney() instead.
	local currency = currency or "default"

	if (!ix.currencies.IsValid(currency)) then
		return false
	end

	local currencies = self:GetData("currencies", {})

	currencies[currency] = amount

	self:SetData("currencies", currencies)

	return true
end

function character:GetMoney(currency)
	local currency = currency or "default"

	if (!ix.currencies.IsValid(currency)) then
		return false
	end

	local total = self:GetData("currencies", {})[currency] or 0

	local currencies = self:GetInventory():GetItemsByUniqueID("currency_"..currency)

	for i, v in pairs(currencies) do
		total = total + v:GetMoney()
	end

	return total
end

ix.meta.character = character
