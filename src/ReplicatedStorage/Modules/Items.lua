local Items = {}

Items.ByRarity = {
	Common = { "Spark Pebble", "Plain Core", "Dust Shard", "Soft Glow", "Cracked Sigil" },
	Uncommon = { "Leaf Rune", "Mossy Charm", "River Spark", "Amber Thread", "Glint Scale" },
	Rare = { "Storm Lens", "Frost Band", "Lunar Chip", "Nova Dust", "Echo Prism" },
	Epic = { "Astral Crown", "Void Needle", "Crimson Crest", "Dawn Thread", "Night Bloom" },
	Legendary = { "Solar Crest", "Dragon Heart", "Star Relic", "Celestial Horn", "Phoenix Crest" },
	Mythic = { "Mythic Halo", "Aether Prism", "Eclipse Seal", "Spirit Bloom", "Oracle Core" },
	Divine = { "Divine Mantle", "Seraph Wing", "Halo Fragment", "Radiant Eye", "Sanctum Key" },
	Celestial = { "Celestial Bloom", "Orbit Stone", "Galaxy Seed", "Comet Halo", "Skyfire Rune" },
	Cosmic = { "Cosmic Ripple", "Nebula Shard", "Starlight Forge", "Void Comet", "Gravity Well" },
	Ethereal = { "Ethereal Veil", "Dream Circuit", "Spectral Bloom", "Whisper Sigil", "Soul Thread" },
	Void = { "Void Heart", "Abyss Lens", "Null Prism", "Hollow Crest", "Darkmatter Coil" },
	Omniversal = { "Omni Crown", "Reality Spark", "Genesis Core", "Infinity Shard", "Prime Seal" },
	Paragon = { "Paragon Crest", "Radiant Apex", "Horizon Coil", "Everlight Sigil", "Valor Prism" },
	Eternal = { "Eternal Ember", "Timebound Crest", "Evergreen Halo", "Celestine Relic", "Aeon Shard" },
	Prismatic = { "Prismatic Arc", "Spectrum Crown", "Aurora Core", "Lumin Shard", "Chromatic Bloom" },
	Apex = { "Apex Fang", "Summit Sigil", "Peak Relic", "Zenith Core", "Apex Prism" },
	Singularity = { "Singularity Core", "Eventide Shard", "Nullpoint Halo", "Gravity Seal", "Collapse Prism" },
	Hyperion = { "Hyperion Crest", "Solar Apex", "Blazing Coil", "Radiant Drift", "Helios Shard" },
	Abyssal = { "Abyssal Lens", "Void Lantern", "Darkwake Crest", "Nightfall Prism", "Depth Sigil" },
	Zenithal = { "Zenithal Halo", "Summit Crown", "Skyspire Core", "Peakstone Shard", "Horizon Relic" },
	Empyrean = { "Empyrean Wing", "Celestine Crest", "Skybound Prism", "Cloudfire Sigil", "Aether Flame" },
	Astralite = { "Astralite Bloom", "Starlit Crest", "Orbit Coil", "Nebula Prism", "Lumen Shard" },
	Chronos = { "Chronos Dial", "Timeglass Core", "Epoch Seal", "Temporal Prism", "Moment Shard" },
	Nebulon = { "Nebulon Drift", "Gaslight Coil", "Nova Crest", "Cosmic Veil", "Starlight Prism" },
	Infinity = { "Infinity Loop", "Endless Core", "Everflow Sigil", "Boundless Shard", "Limitless Prism" },
	Omega = { "Omega Fang", "Final Crest", "Endseal Core", "Lastlight Shard", "Omega Prism" },
	Transcendent = { "Transcendent Sigil", "Ascendant Core", "Halo Crest", "Ethereal Prism", "Spirit Shard" },
	Sovereign = { "Sovereign Crest", "Regal Core", "Crown Shard", "Throne Prism", "Majestic Sigil" },
	Eclipse = { "Eclipse Crown", "Shadowflare Core", "Twilight Shard", "Umbra Prism", "Nightstar Sigil" },
	Genesis = { "Genesis Seed", "Origin Core", "Firstlight Crest", "Dawn Prism", "Creation Shard" },
	Oblivion = { "Oblivion Crest", "Nullwave Core", "Fadestone Shard", "Blackout Prism", "Voidmark Sigil" },
	Elysian = { "Elysian Bloom", "Paradise Crest", "Haven Core", "Serene Shard", "Sanctuary Prism" },
	Titan = { "Titan Crest", "Goliath Core", "Colossal Shard", "Forge Prism", "Ironheart Sigil" },
	Colossus = { "Colossus Crest", "Atlas Core", "Mountain Shard", "Monolith Prism", "Titanic Sigil" },
	Aeon = { "Aeon Crest", "Timeless Core", "Age Shard", "Eon Prism", "Chronicle Sigil" },
	Primordial = { "Primordial Crest", "Firststone Core", "Ancient Shard", "Origin Prism", "Elder Sigil" },
	Eternity = { "Eternity Crest", "Infinite Core", "Evernight Shard", "Forever Prism", "Perpetual Sigil" },
}

function Items.getItem(rarityName, rollIndex)
	local list = Items.ByRarity[rarityName]
	if not list then
		return "Unknown Relic"
	end
	local index = rollIndex or math.random(1, #list)
	return list[((index - 1) % #list) + 1]
end

return Items
