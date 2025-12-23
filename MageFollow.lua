
Mage_Auto_Follow_Hit = "普通模式"
Mage_Settings = nil
local Mage_Follow_PopMenu = nil
local Mage_follow = nil -- 跟随对象名字
local Mage_IsAuto_Follow = false
local Mage_follow_movement = false


-- 计时器缓存，防止每一帧都创建新表
local updateTimer = 0
local drinkCheckTimer = 0


-- 存储每个队友上一次的距离档位
local lastDistanceTiers = {}

function Mage_IsUnitMoving_NoCoords(unit)
    if not UnitExists(unit) or UnitIsUnit(unit, "player") then return false end

    local guid = UnitGUID(unit)
    -- 定义距离档位：4=约28码, 3=约10码, 2=约11码, 1=约10码
    -- 结合圣光术(40码)作为最外层档位
    local currentTier = 0

    if CheckInteractDistance(unit, 3) then
        currentTier = 1 -- 极近 (10码内)
    elseif CheckInteractDistance(unit, 4) then
        currentTier = 2 -- 中距 (约28码内)
    elseif IsSpellInRange("圣光术", unit) == 1 then
        currentTier = 3 -- 远距 (40码内)
    else
        currentTier = 4 -- 超出范围
    end

    local isMoving = false
    if lastDistanceTiers[guid] then
        -- 如果档位发生变化，说明目标一定在移动
        if lastDistanceTiers[guid] ~= currentTier then
            isMoving = true
        end
    end

    -- 更新缓存
    lastDistanceTiers[guid] = currentTier
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
        if unit and UnitExists(unit) and Mage_IsUnitMoving_NoCoords(unit) then
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

    -- 2. 状态检查：喝水、进食或正在读条时，严禁发起跟随
    if Mage_PlayerBU("喝水") or Mage_PlayerBU("进食") or UnitCastingInfo("player") or UnitChannelInfo("player") then
        return false
    end

    -- 3. 需要治疗时的打断逻辑：如果治疗模块需要施法，停止跟随以防转身失败
    if GetTimer("NeedCastHealSpell") < 1.5 and Mage_IsAuto_Follow then
        return Mage_StopFollowUnit()
    end

    local unit = Mage_GetFollowUnit();
    if not unit or not UnitExists(unit) then
        return false
    end
    -- 4. 距离与跟随控制逻辑
    if CheckInteractDistance(unit, 4) then -- 目标在 28 码有效跟随范围内
        -- 情况 A：非战斗状态，且目标正在移动，发起跟随
        if not UnitAffectingCombat(unit) and not UnitAffectingCombat("player") then
            if Mage_IsUnitMoving_NoCoords(unit) and not Mage_IsAuto_Follow then
                FollowUnit(unit)
                return true
            end

        -- 情况 B：战斗状态逻辑
        else
            -- 距离保护：如果离目标太近（约10码内），停止跟随以便于战斗转向
            if CheckInteractDistance(unit, 3) then
                if Mage_IsAuto_Follow then
                    return Mage_StopFollowUnit()
                end
            else
                -- 距离适中（11-28码）：如果未处于跟随状态，且没有卡视野，尝试跟随
                if not Mage_IsAuto_Follow and GetTimer("FAILED_LINE_OF_SIGHT") > 2 then
                    if GetTimer("NeedCastHealSpell") > 0.5 and GetTimer("SPELLCASTSTOP") > 0.5 then
                        FollowUnit(unit)
                        return true
                    end
                end
            end
        end
    else
        -- 5. 距离太远提示：超出 28 码无法开启跟随
        if GetTimer("AutoFollowUnit") > 5 then
            StartTimer("AutoFollowUnit")
            Blizzard_AddMessage("**距离太远，无法跟随 >>" .. Mage_follow .. "<<**", 1, 0, 0, "crit")
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
        if GetTimer("SendFollowChatMessage") > 3 then
            StartTimer("SendFollowChatMessage")
            SendChatMessage(message, "WHISPER", nil, Mage_follow)
        end
    end
end

function Mage_Auto_Follow_OnUpdate()
    if UnitClass("player") ~= "法师" then return end
    if GetTimer("Follow_OnUpdate") < 0.5 then return false; end
    StartTimer("Follow_OnUpdate");
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


function Mage_GetUnitDistance(unit)
    if CheckInteractDistance(unit, 4) then
        return 0
    end
    return 999
end