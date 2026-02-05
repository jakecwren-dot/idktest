local Rarity = require(script.Parent.Rarity)

local RollLogic = {}

function RollLogic.roll(unlockedPower, luckMultiplier)
	local effectiveWeights = {}
	local totalWeight = 0
	local tiers = Rarity.Tiers
	local luck = luckMultiplier or 1

	for index, tier in ipairs(tiers) do
		if unlockedPower >= tier.UnlockAt then
			local tierBoost = 1
			if luck > 1 and #tiers > 1 then
				tierBoost = 1 + (luck - 1) * ((index - 1) / (#tiers - 1))
			end
			local weight = tier.Weight * tierBoost
			table.insert(effectiveWeights, { Tier = tier, Weight = weight })
			totalWeight += weight
		end
	end

	local roll = math.random() * totalWeight
	local cumulative = 0

	for _, entry in ipairs(effectiveWeights) do
		cumulative += entry.Weight
		if roll <= cumulative then
			return entry.Tier
		end
	end

	return Rarity.Tiers[1]
end

return RollLogic
