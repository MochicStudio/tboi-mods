local mod = RegisterMod("Drips", 1)
local game = Game()
local MIN_TEAR_DELAY = 5

-- Set Item ENUMS.
local DripId = {
	SALINE = Isaac.GetItemIdByName("Saline Drip"),
	POTASSIUM = Isaac.GetItemIdByName("Potassium Drip"),
	GLUCOSE = Isaac.GetItemIdByName("Glucose Drip"),
	DEW = Isaac.GetItemIdByName("Dew Drip"),
	HELIUM = Isaac.GetItemIdByName("Helium Drip"),
	SLUDGE = Isaac.GetItemIdByName("Sludge Drip")
}

-- This is for checking once in the game whether or
-- not the player has any of our items.
local HasDrip = {
	saline = false,
	potassium = false,
	glucose = false,
	dew = false,
	helium = false,
	sludge = false
}

-- This is the stat's changes that every item has to do
-- when the player picks it out.
local DripBonus = {
	SALINE = 3,
	POTASSIUM = 0.5,
	GLUCOSE_TEAR_HEIGHT = 1,
	GLUCOSE_FALL_SPEED = 1,
	GLUCOSE_SPEED = 0.5,
	DEW = 5,
	SLUDGE = 5
}

-- Update inventory
local function UpdateDrips(player)
	HasDrip.saline = player:HasCollectible(DripId.SALINE)
	HasDrip.potassium = player:HasCollectible(DripId.POTASSIUM)
	HasDrip.glucose = player:HasCollectible(DripId.GLUCOSE)
	HasDrip.dew = player:HasCollectible(DripId.DEW)
	HasDrip.helium = player:HasCollectible(DripId.HELIUM)
	HasDrip.sludge = player:HasCollectible(DripId.SLUDGE)
end

local function SpawnItems()
	-- Spawn items
	if game:GetFrameCount() == 1 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.SALINE, Vector(100, 250), Vector(0, 0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.POTASSIUM, Vector(150, 250), Vector(0, 0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.GLUCOSE, Vector(200, 250), Vector(0, 0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.DEW, Vector(250, 250), Vector(0, 0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.HELIUM, Vector(300, 250), Vector(0, 0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.SLUDGE, Vector(350, 250), Vector(0, 0), nil)
	end
end

-- When the run starts or continues
function mod:onPlayerInit(player)
	UpdateDrips(player)
end

-- When passive effects should update
function mod:onUpdate(player)
	SpawnItems()
	UpdateDrips(player)
end

-- Update the Cache
function mod:onCache(player, cacheFlag)
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		if player:HasCollectible(DripId.SALINE) and not HasDrip.saline then
			if player.MaxFireDelay >= MIN_TEAR_DELAY + DripBonus.SALINE then
				player.MaxFireDelay = player.MaxFireDelay - DripBonus.SALINE
			elseif player.MaxFireDelay >= MIN_TEAR_DELAY then
				player.MaxFireDelay = MIN_TEAR_DELAY
			end
		end
		if player:HasCollectible(DripId.SLUDGE) then
			player.Damage = player.Damage + DripBonus.SLUDGE
		end
	elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		if player:HasCollectible(DripId.POTASSIUM) then
			player.ShotSpeed = player.ShotSpeed + DripBonus.POTASSIUM
		end
	elseif cacheFlag == CacheFlag.CACHE_RANGE then
		if player:HasCollectible(DripId.GLUCOSE) then
			player.TearHeight = player.TearHeight + DripBonus.GLUCOSE_TEAR_HEIGHT
			player.TearFallingSpeed = player.TearFallingSpeed + DripBonus.GLUCOSE_FALL_SPEED
		end
	elseif cacheFlag == CacheFlag.CACHE_SPEED then
		if player:HasCollectible(DripId.GLUCOSE) then
			player.MoveSpeed = player.MoveSpeed + DripBonus.GLUCOSE_SPEED
		end
	elseif cacheFlag == CacheFlag.CACHE_LUCK then
		if player:HasCollectible(DripId.DEW) then
			player.Luck = player.Luck + DripBonus.DEW
		end
	elseif cacheFlag == CacheFlag.CACHE_FLYING then
		if player:HasCollectible(DripId.HELIUM) then
			player.CanFly = true
		end
	end
end

-- Callbacks
-- TODO Check how to use Item Pools and add the item there.
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.onPlayerInit)
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.onUpdate)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.onCache)
