return {
    ["water"] = {
        itemLabel = "Water Bottle",
        itemWeight = 0.1,
        itemType = "item",
        stackable = true,
        itemRarity = "uncommon",
        description = "A high-quality water bottle to keep you hydrated during your adventures.",
        closeOnUse = true,

    },
    ["burger"] = {
        itemLabel = "Burger",
        itemWeight = 0.1,
        itemType = "item",
        stackable = true,
        itemRarity = "uncommon",
        description = "A delicious burger that restores hunger and gives you energy.",
        closeOnUse = true,
    },
    ["bandage"] = {
        itemLabel = "Bandage",
        itemWeight = 0.05,
        itemType = "item",
        stackable = true,
        itemRarity = "common",
        description = "A simple bandage used for healing wounds and restoring health.",
        closeOnUse = true,
    },
    ["WEAPON_CARBINERIFLE"] = {
        itemLabel = "Carabine Rifle",
        itemWeight = 4.5,
        itemType = "weapon",
        stackable = false,
        itemRarity = "legendary",
        description = "A powerful carabine rifle effective in combat. It can be used a limited number of times.",
        closeOnUse = true,
        typeAmmo = "ammo-rifle2"
    },
    ["ammo-rifle2"] = {
        itemLabel = "Rifle Ammo",
        itemWeight = 0.1,
        itemType = "ammo",
        stackable = true,
        itemRarity = "rare",
        description = "Ammunition for the Carabine Rifle. Essential for sustained combat.",
        closeOnUse = false,
    },
    ["weed"] = {
        itemLabel = "Pineapple Chunk",
        itemWeight = 0.3,
        itemType = "item",
        stackable = true,
        itemRarity = "rare",
        description = "A rare strain of weed known for its relaxing effects and sweet pineapple aroma.",
        closeOnUse = false,
    },
    ["WEAPON_MOLOTOV"] = {
        itemLabel = "Molotov",
        itemWeight = 1.0,
        itemType = "weapon",
        stackable = true,
        itemRarity = "epic",
        description = "A highly flammable weapon that causes explosive damage upon impact.",
        closeOnUse = false,
    },
    ["clothing_hat"] = {
        itemLabel = "Explorer's Hat",
        itemWeight = 0.3,
        itemType = "item",
        stackable = false,
        itemRarity = "common",
        description = "A stylish hat for outdoor adventures.",
        closeOnUse = false,
        metadata = {
            maleDrawableId = 45
        }
    },
    ["clothing_pants"] = {
        itemLabel = "Pants",
        itemWeight = 1.0,
        itemType = "item",
        stackable = false,
        itemRarity = "uncommon",
        description = "Durable pants, perfect for outdoor work and exploration.",
        closeOnUse = false,
        metadata = {
            maleDrawableId = 3,
            femaleDrawableId = 3,
        }

    },
    ["clothing_shoes"] = {
        itemLabel = "Sneakers",
        itemWeight = 0.8,
        itemType = "item",
        stackable = false,
        itemRarity = "common",
        description = "Comfortable sneakers for walking and running.",
        closeOnUse = false,
        metadata = {
            maleDrawableId = 7,
            femaleDrawableId = 2,
        }

    },
    ["clothing_jacket"] = {
        itemLabel = "Felp Jacket",
        itemWeight = 1.2,
        itemType = "item",
        stackable = false,
        itemRarity = "rare",
        description = "A warm  jacket to keep you comfortable in cold climates.",
        closeOnUse = false,
        metadata = {
            maleDrawableId = 7,
            femaleDrawableId = 7,
        }

    },
    ["clothing_backpack"] = {
        itemLabel = "Backpack",
        itemWeight = 5.0,
        itemType = "item",
        stackable = false,
        itemRarity = "epic",
        description = "A large and sturdy backpack to carry your gear and supplies during long adventures.",
        closeOnUse = false,
        metadata = {
            maleDrawableId = 5,
            femaleDrawableId = 5,
        }
    },
    ["money"] = {
        itemLabel = "Money",
        itemWeight = 0.0,
        itemType = "item",
        stackable = true,
        itemRarity = "common",
        description = "Physical cash that can be used for purchases or traded.",
        closeOnUse = false,
    }
}
