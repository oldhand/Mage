-- 缓存表：[物品名] = {bag=0, slot=1}
local Mage_ItemCache = {}
if UnitClass("player") == "法师" then
    local bagFrame = CreateFrame("Frame")
    -- ========================================================
    --  执行逻辑
    -- ========================================================
    bagFrame:RegisterEvent("BAG_UPDATE")
    bagFrame:SetScript("OnEvent", function()
        Mage_RefreshItemCache();
    end)
end
-- 刷新缓存函数
function Mage_RefreshItemCache()
    Mage_ItemCache = {} -- 清空旧缓存
    -- 遍历玩家随身背包（0-4为常规背包栏，时光服通用）
    for bagID = 0, 4 do
        -- 替代旧API：获取背包总栏位
        local slotCount = C_Container.GetContainerNumSlots(bagID)
        if slotCount and slotCount > 0 then -- 跳过未装备的空背包
            for slotID = 1, slotCount do
                -- 替代旧API：获取物品链接
                local itemLink = C_Container.GetContainerItemLink(bagID, slotID)
                if itemLink then
                    -- 获取物品名称（兼容物品链接的延迟加载）
                    local itemName = GetItemInfo(itemLink)
                    if itemName then
                        -- 优化：避免同名物品覆盖（存储为数组）
                        if not Mage_ItemCache[itemName] then
                            Mage_ItemCache[itemName] = {}
                        end
                        table.insert(Mage_ItemCache[itemName], {
                            bag = bagID,
                            slot = slotID
                        })
                    end
                end
            end
        end
    end
end

-- 优化后的查找函数，直接读缓存，不再遍历背包
function Mage_FindItemInBag(targetName)
    local data = Mage_ItemCache[targetName]
    if data then
        -- 再次校验物品是否真的还在（防止缓存未及时更新的极端情况）
        local link = GetContainerItemLink(data.bag, data.slot)
        if link and GetItemInfo(link) == targetName then
            return data.bag, data.slot
        end
    end
    return nil,nil;
end

function Mage_CheckItemIsReady(bag, slot)
    if (not bag or not slot) then
        return false;
    end
    -- 3. 获取冷却信息
    -- startTime: 冷却开始时间 (0表示无冷却)
    -- duration: 冷却总时长 (0表示无冷却)
    -- isEnabled: 物品是否已启用 (1表示启用)
    local startTime, duration, isEnabled = GetContainerItemCooldown(bag, slot)

    -- 只有当 开始时间为0 且 持续时间为0 且 物品处于启用状态 时，才算可用
    if (startTime == 0 and duration == 0 and isEnabled == 1) then
        return true;
    else
        return false;
    end
end

