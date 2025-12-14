
Mage_Auto_Follow_Hit = "普通模式"
Mage_Settings = nil
local Mage_Follow_PopMenu = nil
local Mage_follow = nil -- 跟随对象名字
local Mage_IsAuto_Follow = false
local Mage_follow_movement = false

-- 缓存的魔法水名称，按优先级排序
local Mage_Drinks = {"魔法晶水", "魔法苏打水", "魔法矿泉水", "魔法橘子"}

-- 计时器缓存，防止每一帧都创建新表
local updateTimer = 0
local drinkCheckTimer = 0


local lastPositions = {}

local function Mage_IsUnitMoving_Coords(unit)
    if not UnitExists(unit) then return false end
    local x, y = UnitPosition(unit)
    if not x or not y then return false end

    local guid = UnitGUID(unit)
    local isMoving = false

    if lastPositions[guid] then
        local lastX = lastPositions[guid].x
        local lastY = lastPositions[guid].y
        local dx = math.abs(x - lastX)
        local dy = math.abs(y - lastY)
        if dx > 0.001 or dy > 0.001 then
            isMoving = true
        end
    end
    lastPositions[guid] = { x = x, y = y }
    return isMoving
end

function Mage_Auto_Follow_OnLoad(self)
    if UnitClass("player") ~= "法师" then
        if MageFollowBtn then HideUIPanel(MageFollowBtn) end
        return
    end
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("AUTOFOLLOW_BEGIN")
    self:RegisterEvent("AUTOFOLLOW_END")
end

function Mage_Auto_Follow_OnEvent(self, event, arg1, arg2)
    if (event == "PLAYER_ENTERING_WORLD") then
        if (Mage_Settings == nil) then
            Mage_Settings = {}
            Mage_Settings["follow"] = ""
        end
        if Mage_Settings["follow"] ~= "" then
            Mage_follow = Mage_Settings["follow"]
            local unit = Mage_GetFollowUnit()
            if unit and UnitExists(unit) then
                Mage_AddMessage("**进入跟随模式，跟随目标>>" .. Mage_follow .. "<<**")
                Mage_Auto_Follow_Hit = "跟随模式【" .. Mage_follow .. "】"
                if MageTooltip then MageTooltip:SetText(Mage_Auto_Follow_Hit) end
            end
        end
    elseif (event == "GROUP_ROSTER_UPDATE") then
        Mage_Group_Update()
    elseif (event == "AUTOFOLLOW_END") then
        Mage_IsAuto_Follow = false
        Mage_AddMessage("停止自动跟随...")
    elseif (event == "AUTOFOLLOW_BEGIN") then
        Mage_IsAuto_Follow = true
        Mage_AddMessage("开始自动跟随...")
    end
end

-- 优化：获取跟随目标的 UnitID
function Mage_GetFollowUnit()
    if not Mage_follow or Mage_follow == "" then return nil end
    -- 合并团队和队伍遍历逻辑
    local prefix = UnitInRaid("player") and "raid" or "party"
    local count = UnitInRaid("player") and 40 or 4

    for id = 1, count do
        local unit = prefix .. id
        if UnitExists(unit) and UnitName(unit) == Mage_follow then
            return unit
        end
    end
    return nil
end


-- 核心逻辑：自动跟随
function Mage_AutoFollowUnit()
    if not Mage_follow then return false end

    -- 节流：每 0.5 秒只执行一次核心判断，防止 FPS 下降
    if GetTime() - updateTimer < 0.5 then return false end
    updateTimer = GetTime()

    -- 移动检查
    if not Mage_Check_Movement() then
        local unit = Mage_GetFollowUnit()
        if unit and UnitExists(unit) and Mage_IsUnitMoving_Coords(unit) then
            if Mage_IsAuto_Follow then
                Mage_IsAuto_Follow = false
            end
        end
    end

    if GetTimer("follow") < 3 then
        local unit = Mage_GetFollowUnit()
        if unit and UnitExists(unit) then
            if CheckInteractDistance(unit, 4) then
                if not Mage_IsAuto_Follow then
                    FollowUnit(unit)
                    Mage_SendFollowNotifyMessage("跟随...")
                    return false
                end
            else
                if GetTimer("AutoFollowUnit") > 5 then
                    StartTimer("AutoFollowUnit")
                    Blizzard_AddMessage("**距离太远，无法跟随**", 1, 0, 0, "crit")
                    Mage_SendFollowNotifyMessage("距离太远，无法跟随")
                end
            end
            return false
        end
    end

    -- 非喝水/进食状态下的逻辑
    if not Mage_PlayerBU("喝水") and not Mage_PlayerBU("进食") then
        local unit = Mage_GetFollowUnit()
        if unit and UnitExists(unit) then
            -- 上马逻辑
--             if Mage_UnitIsMounted(unit) then
--                 if IsMounted() and not Mage_IsAuto_Follow then
--                     -- 确保没有施法且不需要立刻施法
--                     if GetTimer("SPELLCASTSTOP") > 0.5 and GetTimer("SPELLCAST_START") > 3.5 and GetTimer("NeedMount") > 3.5 then
--                         FollowUnit(unit)
--                         return true
--                     end
--                 end
--                 return false
--             end

            -- 需要治疗时的打断逻辑
            if GetTimer("NeedCastHealSpell") < 2 and Mage_IsAuto_Follow then
                if Mage_StopFollowUnit() then return true end
            end

            -- 跟随距离与战斗逻辑
            if CheckInteractDistance(unit, 4) then
                if GetTimer("FAILED_LINE_OF_SIGHT") < 2 then
                    if not Mage_IsAuto_Follow then
                        FollowUnit(unit)
                        return false
                    end
                else
                    if UnitAffectingCombat(unit) or UnitAffectingCombat("player") then
                        -- 战斗中逻辑：距离过近则停止跟随
                        if not CheckInteractDistance(unit, 2) then -- 2 = Trade (11.11 yards)
                            if Mage_GetPlayerCasting == nil and not Mage_IsAuto_Follow and GetTimer("NeedCastHealSpell") > 0.2 and GetTimer("SPELLCASTSTOP") > 0.2 then
                                FollowUnit(unit)
                                return false
                            end
                        else
                            -- 距离过近 (Duel range approx 9.9 yds)
                            if CheckInteractDistance(unit, 3) then
                                if Mage_StopFollowUnit() then return true end
                            end
                        end
                    else
                        -- 非战斗逻辑
                        if Mage_IsUnitMoving_Coords(unit) then
                            if Mage_GetPlayerCasting == nil and not Mage_IsAuto_Follow and GetTimer("NeedCastHealSpell") > 0.2 and GetTimer("SPELLCASTSTOP") > 0.2 then
                                FollowUnit(unit)
                                return false
                            end
                        end
                    end
                end
            else
                -- 距离太远提示
                if GetTimer("AutoFollowUnit") > 5 then
                    StartTimer("AutoFollowUnit")
                    Blizzard_AddMessage("**距离太远，无法跟随**", 1, 0, 0, "crit")
                    Mage_SendFollowNotifyMessage("距离太远，无法跟随")
                end
            end
        end
    end
    return false
end

function Mage_StopFollowUnit()
    if Mage_IsAuto_Follow then
        Mage_SetText("停止跟随", 208)
        return true
    end
    return false
end



function Mage_SendFollowNotifyMessage(message)
    local unit = Mage_GetFollowUnit()
    if unit and UnitExists(unit) then
        -- 硬编码的白名单检测? 建议保留原逻辑
        -- if name == "老手" ... 这里原来的代码变量 name 未定义，可能是 bug
        -- 假设我们只发给跟随目标
--         if GetTimer("SendFollowChatMessage") > 3 then
--             StartTimer("SendFollowChatMessage")
--             SendChatMessage(message, "WHISPER", nil, Mage_follow)
--         end
    end
end

function Mage_Auto_Follow_OnUpdate()
    if UnitClass("player") ~= "法师" then return end

    -- 状态同步
    if Mage_follow == nil then
        if MageFollowBtn and MageFollowBtn:GetChecked() then
            MageFollowBtn:SetChecked(false)
        end
    else
        if MageFollowBtn and not MageFollowBtn:GetChecked() then
            MageFollowBtn:SetChecked(true)
        end
    end

    Mage_AutoFollowUnit()
end

function Mage_UnitInParty()
    if  IsInRaid() or IsInGroup() then
        return true;
    end
    return false;
end

-- 界面函数：点击按钮时的逻辑
function Mage_Auto_Follow_fun()
    -- 切换逻辑
    if MageFollowBtn:GetChecked() then
        if not Mage_UnitInParty() then
            FollowUnit("player") -- 停止跟随
            Mage_Settings["follow"] = ""
            Mage_follow = nil
            Mage_AddMessage("**进入普通模式**")
            Mage_Auto_Follow_Hit = "没有队友，无法设置跟随模式"
            if MageTooltip then MageTooltip:SetText(Mage_Auto_Follow_Hit) end
            MageFollowBtn:SetChecked(false)
        else
            Mage_AddMessage("**请选择跟随目标**")
            Mage_popuMenu()
        end
    else
        FollowUnit("player")
        Mage_Settings["follow"] = ""
        Mage_follow = nil
        Mage_AddMessage("**进入普通模式**")
        Blizzard_AddMessage("**进入普通模式**", 1, 0, 0, "crit")
        Mage_Auto_Follow_Hit = "普通模式"
        if MageTooltip then MageTooltip:SetText(Mage_Auto_Follow_Hit) end
    end
end

function Mage_Group_Update()
    if Mage_follow ~= nil then
        local unit = Mage_GetFollowUnit()
        -- 如果目标不存在（退队或下线）
        if not unit then
            Mage_follow = nil
            Mage_Settings["follow"] = ""
            Mage_AddMessage("**找不到跟随目标,进入普通模式**")
            Blizzard_AddMessage("**找不到跟随目标,进入普通模式**", 1, 0, 0, "crit")
            Mage_Auto_Follow_Hit = "普通模式"
            if MageTooltip then MageTooltip:SetText(Mage_Auto_Follow_Hit) end
            if MageFollowBtn then MageFollowBtn:SetChecked(false) end
        end
    end
end

-- 下拉菜单相关
function Mage_SetMode(self)
    local followname = self.value
    if Mage_Follow_PopMenu then Mage_Follow_PopMenu:Hide() end

    Mage_follow = followname
    local unit = Mage_GetFollowUnit()

    if unit and UnitExists(unit) then
        Mage_Settings["follow"] = followname
        Mage_AddMessage("**进入跟随模式，跟随目标>>" .. followname .. "<<**")
        Blizzard_AddMessage("**进入跟随模式，跟随目标>>" .. followname .. "<<**", 1, 0, 0, "crit")
        Mage_Auto_Follow_Hit = "跟随模式【" .. followname .. "】"

        -- 标记目标
        if GetRaidTargetIndex(unit) ~= 1 then SetRaidTargetIcon(unit, 1) end
        if GetRaidTargetIndex("player") ~= 3 then SetRaidTargetIcon("player", 3) end

        if MageTooltip then MageTooltip:SetText(Mage_Auto_Follow_Hit) end
    else
         Mage_AddMessage("设置失败：目标不在队伍中")
    end
end

function Mage_Follow_PopMenu_Initialize(level)
    if not level then return end
    local prefix = UnitInRaid("player") and "raid" or "party"
    local count = UnitInRaid("player") and 40 or 4
    for id = 1, count do
        local unit = prefix .. id
        if UnitExists(unit) and not UnitIsUnit(unit, "player") then
            local info = {}
            info.text = UnitName(unit) .. "(" .. UnitClass(unit) .. ")"
            info.value = UnitName(unit)
            info.checked = (UnitName(unit) == Mage_follow)
            info.func = Mage_SetMode
            UIDropDownMenu_AddButton(info, 1)
        end
    end
end

function Mage_popuMenu()
    if Mage_UnitInParty() then
        if not Mage_Follow_PopMenu then
            Mage_Follow_PopMenu = CreateFrame('Frame', 'MageFollowMenu', UIParent, 'UIDropDownMenuTemplate')
        end
        Mage_Follow_PopMenu.displayMode = "MENU"
        Mage_Follow_PopMenu.initialize = Mage_Follow_PopMenu_Initialize
        ToggleDropDownMenu(1, nil, Mage_Follow_PopMenu, "cursor")
    end
end

-- 链接解析
function Mage_Follow_breakLink(link)
    if (type(link) ~= 'string') then return end
    local _, _, itemID, enchant, randomProp, uniqID, name = string.find(link, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h")
    return tonumber(itemID or 0), tonumber(randomProp or 0), tonumber(enchant or 0), tonumber(uniqID or 0), name
end

-- 优化版：寻找魔法水
-- 增加缓存机制，避免每一帧都遍历背包
local drinkCount = 0

function Mage_FindDrink()
    -- 节流：每2秒检查一次背包，或者当背包事件触发时检查（需要额外注册BAG_UPDATE）
    -- 这里为了保持代码结构，使用简单的 Timer 节流
    if GetTime() - drinkCheckTimer < 2 then
        -- 如果没到时间，返回空或者上一次的结果（这里简化返回空字符串避免频繁喝水操作）
        return ""
    end
    drinkCheckTimer = GetTime()

    local bestDrink = ""
    local currentCount = 0
    local drinkBag, drinkSlot = -1, -1

    -- 优化遍历：找到最高优先级的饮料即可停止？或者统计所有数量
    for bag = 0, 4 do
        local numSlots = GetContainerNumSlots(bag)
        if numSlots > 0 then
            for slot = 1, numSlots do
                local link = GetContainerItemLink(bag, slot)
                if link then
                    local _, itemCount = GetContainerItemInfo(bag, slot)
                    local _, _, _, _, _, name = Mage_Follow_breakLink(link)

                    if name then
                        for _, dName in ipairs(Mage_Drinks) do
                            if name == dName then
                                currentCount = currentCount + itemCount
                                -- 简单的逻辑：只要找到一种水就记录位置
                                bestDrink = name
                                drinkBag = bag
                                drinkSlot = slot
                            end
                        end
                    end
                end
            end
        end
    end

    -- 逻辑保持原版：如果数量增加（可能刚造水），或者数量不变（可能没喝成），重置计时器
    -- 如果在转CD，则不喝
    if drinkBag ~= -1 then
         local startTime, duration, _ = GetContainerItemCooldown(drinkBag, drinkSlot)
         if startTime == 0 and duration == 0 then
            if currentCount >= drinkCount then
                 drinkCount = currentCount
                 StartTimer("Drink")
                 return bestDrink
            elseif drinkCount > currentCount then
                -- 数量减少了，说明可能喝掉了
                if GetTimer("Drink") > 3 then
                    StartTimer("Drink")
                    drinkCount = currentCount
                    return bestDrink
                else
                    return ""
                end
            end
         end
    end

    return ""
end

function Mage_GetUnitDistance(unit)
    if CheckInteractDistance(unit, 4) then
        return 0
    end
    return 999
end