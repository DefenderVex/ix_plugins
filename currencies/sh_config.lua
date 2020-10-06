ix.currencies.config = {
	currencies = {
		-- !! DEFAULT MUST BE INCLUDED !! --
		default = {
			-- NOTE: Switching this from true to false will cause any currency in character inventories to vanish.
			-- If this is switched from false to true the system will automatclly deplete their "digital" currency first before taking the physical.
			physical = true,
			-- The weight (for a single unit of currency), this only works with my Weight plugin. This is in kilograms.
			weight = 0.001,
			-- The default model for the default currency, also seconds as the fallback model for other currencies.
			model = "models/props_lab/box01a.mdl",
			-- The name of the currency.
			name = "United States Currency",
			-- The description of the currency.
			description = "Greenback, otherwise as it is commonly known, the United States dollar.",
			-- The symbol of the currency.
			symbol = "$",
			-- The currency in singular.
			singular = "dollar",
			-- The currency in plural.
			plural = "dollars",
			-- The sound that plays when this currency is picked up or gained.
			pickup = nil,
			-- The sound that plays with this currency is dropped or lost.
			drop = nil,
		},

		--[[drachma = {
			physical = true,
			weight = 0.005,
			model = "models/props_lab/box01a.mdl",
			name = "Drachma",
			description = "A currency and coin as old and as ancient as ancient history and recorded memory.",
			symbol = "D",
			singular = "drachma",
			plural = "drachma",
			pickup = nil,
			drop = nil,
		},]]--
	}
}

ix.lang.AddTable("english", {
	dropCurrency = "Drop Currency",
	mergeCurrency = "Merge Currency",
	splitCurrency = "Split Currency",

	giveMoney = "You have given %s money.",

	cmdCharGiveMoney = "Give money of a specified amount to the specified character.",
})
