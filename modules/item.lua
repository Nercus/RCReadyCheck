---@class RCReadyCheck
local RCReadyCheck = select(2, ...)

---@class Item
local Item = RCReadyCheck:GetModule("Item")


local ITEM_CONTEXT_DIFFICULTY_MAPPING = {
    [3] = 14, --RaidNormal
    [4] = 17, --RaidFinder
    [5] = 15, --RaidHeroic
    [6] = 16, --RaidMythic
}


function Item:ParseItemLink(link)
    -- Parse the first elements that have no variable length
    local _, itemID, enchantID, gemID1, gemID2, gemID3, gemID4,
    suffixID, uniqueID, linkLevel, specializationID, modifiersMask,
    itemContext, rest = strsplit(":", link, 14) --[[@as string]]

    ---@type string, string
    local crafterGUID, extraEnchantID
    ---@type string, string[]
    local numBonusIDs, bonusIDs
    ---@type string, string[]
    local numModifiers, modifierIDs
    ---@type string, string[]
    local relic1NumBonusIDs, relic1BonusIDs
    ---@type string, string[]
    local relic2NumBonusIDs, relic2BonusIDs
    ---@type string, string[]
    local relic3NumBonusIDs, relic3BonusIDs

    if rest ~= nil then
        numBonusIDs, rest = strsplit(":", rest, 2) --[[@as string]]

        if numBonusIDs ~= "" then
            local splits = (tonumber(numBonusIDs)) + 1
            bonusIDs = strsplittable(":", rest, splits)
            rest = table.remove(bonusIDs, splits)
        end

        numModifiers, rest = strsplit(":", rest, 2) --[[@as string]]
        if numModifiers ~= "" then
            local splits = (tonumber(numModifiers) * 2) + 1
            modifierIDs = strsplittable(":", rest, splits)
            rest = table.remove(modifierIDs, splits)
        end

        relic1NumBonusIDs, rest = strsplit(":", rest, 2) --[[@as string]]
        if relic1NumBonusIDs ~= "" then
            local splits = (tonumber(relic1NumBonusIDs)) + 1
            relic1BonusIDs = strsplittable(":", rest, splits)
            rest = table.remove(relic1BonusIDs, splits)
        end

        relic2NumBonusIDs, rest = strsplit(":", rest, 2) --[[@as string]]
        if relic2NumBonusIDs ~= "" then
            local splits = (tonumber(relic2NumBonusIDs)) + 1
            relic2BonusIDs = strsplittable(":", rest, (tonumber(relic2NumBonusIDs)) + 1)
            rest = table.remove(relic2BonusIDs, splits)
        end

        relic3NumBonusIDs, rest = strsplit(":", rest, 2) --[[@as string]]
        if relic3NumBonusIDs ~= "" then
            local splits = (tonumber(relic3NumBonusIDs)) + 1
            relic3BonusIDs = strsplittable(":", rest, (tonumber(relic3NumBonusIDs)) + 1)
            rest = table.remove(relic3BonusIDs, splits)
        end

        ---@type string, string
        crafterGUID, extraEnchantID = strsplit(":", rest, 3)
    end

    return {
        itemID = tonumber(itemID),
        enchantID = enchantID,
        gemID1 = gemID1,
        gemID2 = gemID2,
        gemID3 = gemID3,
        gemID4 = gemID4,
        suffixID = suffixID,
        uniqueID = uniqueID,
        linkLevel = linkLevel,
        specializationID = specializationID,
        modifiersMask = modifiersMask,
        itemContext = itemContext,
        bonusIDs = bonusIDs or {},
        modifierIDs = modifierIDs or {},
        relic1BonusIDs = relic1BonusIDs or {},
        relic2BonusIDs = relic2BonusIDs or {},
        relic3BonusIDs = relic3BonusIDs or {},
        crafterGUID = crafterGUID or "",
        extraEnchantID = extraEnchantID or ""
    }
end

---@param itemLink string
---@return integer
function Item:GetItemDifficultyID(itemLink)
    local itemLinkData = self:ParseItemLink(itemLink)
    local itemContext = tonumber(itemLinkData.itemContext)
    return ITEM_CONTEXT_DIFFICULTY_MAPPING[itemContext]
end
