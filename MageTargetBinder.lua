local addonName, ns = ...
local f = CreateFrame("Frame")

-- ========================================================
--  配置区域
-- ========================================================
local config = {

    -- [1] 选择自己
    targetSelf = "ALT-1",

    -- [2] 选择小队 (API 指令)
    party = {
        "ALT-2",   -- 队友1
        "ALT-3",   -- 队友2
        "ALT-4",   -- 队友3
        "ALT-5"    -- 队友4
    },

   targetFocus = "ALT-6",

   interactTarget = "ALT-7", -- 与目标互动

    -- [3] 选择团队 (虚拟宏)
    raid = {
        [1]="CTRL-1", [2]="CTRL-2", [3]="CTRL-3", [4]="CTRL-4", [5]="CTRL-5",
        [6]="CTRL-6", [7]="CTRL-7", [8]="CTRL-8", [9]="CTRL-9", [10]="CTRL-0",
        [11]="SHIFT-1", [12]="SHIFT-2", [13]="SHIFT-3", [14]="SHIFT-4", [15]="SHIFT-5",
        [16]="SHIFT-6", [17]="SHIFT-7", [18]="SHIFT-8", [19]="SHIFT-9", [20]="SHIFT-0",
        [21]="CTRL-ALT-1", [22]="CTRL-ALT-2", [23]="CTRL-ALT-3", [24]="CTRL-ALT-4", [25]="CTRL-ALT-5",
        [26]="CTRL-ALT-6", [27]="CTRL-ALT-7", [28]="CTRL-ALT-8", [29]="CTRL-ALT-9", [30]="CTRL-ALT-0",
        [31]="CTRL-SHIFT-1", [32]="CTRL-SHIFT-2", [33]="CTRL-SHIFT-3", [34]="CTRL-SHIFT-4", [35]="CTRL-SHIFT-5",
        [36]="CTRL-SHIFT-6", [37]="CTRL-SHIFT-7", [38]="CTRL-SHIFT-8", [39]="CTRL-SHIFT-9", [40]="CTRL-SHIFT-0"
    }
}

-- ========================================================
--  执行逻辑
-- ========================================================
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    if InCombatLockdown() then
        print("|cffff0000[TargetBinder] 战斗中无法绑定，请脱战后 /reload|r")
        return
    end

   if UnitClass("player") ~= "法师" then
        return
    end

    if config.interactTarget then
        SetBinding(config.interactTarget, "INTERACTTARGET")
    end

    -- 2. 绑定自己
    if config.targetSelf then
        SetBinding(config.targetSelf, "TARGETSELF")
    end

    -- 3. 绑定小队
    for i, key in ipairs(config.party) do
        if key then
            SetBinding(key, "TARGETPARTYMEMBER"..i)
        end
    end

    -- 4. 绑定团队 (虚拟宏 + 文字提示)
    for i = 1, 40 do
        local key = config.raid[i]
        if key then
            local btnName = "TB_RaidBtn"..i
            local btn = _G[btnName] or CreateFrame("Button", btnName, UIParent, "SecureActionButtonTemplate")

            local targetCmd = "/tar raid"..i
            -- |cffFFFF00 是黄色代码，你可以改成其他颜色
            local printCmd = "/run print('|cffFFFF00>> 选择团队成员: "..i.."|r')"

            -- 合并成一个宏字符串
            local fullMacro = targetCmd .. "\n" .. printCmd

            btn:SetAttribute("type", "macro")
            btn:SetAttribute("macrotext", fullMacro)
            SetBinding(key)
            SetBindingClick(key, btnName)
        end
    end

    -- 5. 保存绑定
    SaveBindings(2)

end)

function Mage_SelectTarget(unit)
    Mage_AddMessage("选择目标>>" .. UnitName(unit).."<<");
    if unit == "player" then
        return Mage_TargetPlayer();
    end
    if unit == "focus" then
        return Mage_TargetFocus();
    end
    local partyMatched = string.match(unit, "party%d+");
    if partyMatched then
        return Mage_TargetParty(unit);
    end

    local raidMatched = string.match(unit, "raid%d+");
    if raidMatched then
        return Mage_TargetRaid(unit);
    end
    return false;
end


function Mage_TargetFocus()
    Mage_SetText("目标焦点",305);
    return true;
end

function Mage_TargetPlayer()
    Mage_SetText("目标自己",300);
    return true;
end

function Mage_TargetParty(unit)
    if UnitExists(unit)  then
        if UnitIsUnit("target", unit) then
            return false;
        end
        local indexStr = string.match(unit, "party(%d+)");
        if indexStr then
           local index = tonumber(indexStr);
           local textId = 300 + index;
           Mage_SetText("目标队友" .. UnitName(unit), textId);
           return true;
        end
    end
    return false;
end


function Mage_TargetRaid(unit)
    if UnitExists(unit)  then
        if UnitIsUnit("target", unit) then
            return false;
        end
       local indexStr = string.match(unit, "raid(%d+)");
       if indexStr then
           local index = tonumber(indexStr);
           local textId = 309 + index;
           Mage_SetText("目标团队" .. UnitName(unit), textId);
           return true;
       end
    end
    return false;
end