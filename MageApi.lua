Mage_SaveData = nil;
if not Mage_Settings then Mage_Settings = {} end
Mage_Icons = nil;


function Mage_TargetBU(s) local P,i="target",1  while UnitBuff(P,i)   do if string.find(UnitBuff(P,i),s)   then return true; end i=i+1 end return false end
function Mage_TargetDeBU(s) local P,i="target",1  while UnitDebuff(P,i) do if string.find(UnitDebuff(P,i),s) then return true; end i=i+1 end return false end
function Mage_PlayerBU(s) local P,i="player",1  while UnitBuff(P,i)   do if string.find(UnitBuff(P,i),s)   then return true; end i=i+1 end return false end
function Mage_PlayerDeBU(s) local P,i="player",1  while UnitDebuff(P,i) do if string.find(UnitDebuff(P,i),s) then return true; end i=i+1 end return false end
function Mage_UnitTargetBU(unit,s) local P,i=unit,1  while UnitBuff(P,i) do if string.find(UnitBuff(P,i),s) then return true; end i=i+1 end return false end
function Mage_UnitTargetDeBU(unit,s) local P,i=unit,1  while UnitDebuff(P,i) do if string.find(UnitDebuff(P,i),s) then return true; end i=i+1 end return false end


-- 检查目标是否有玩家自己施放的特定 Debuff
function Mage_UnitTargetDeBU_ByPlayer(unit, spellName)
    local i = 1
    while true do
        -- 现代 API 第 7 个参数是 source
        local name, _, _, _, _, _, source = UnitDebuff(unit, i)
        if not name then break end
        if string.find(name, spellName) and source == "player" then
            return true
        end
        i = i + 1
    end
    return false
end


-- 检查目标是否有玩家自己施放的特定 buff
function Mage_UnitTargetBU_ByPlayer(unit, spellName)
    local i = 1
    while true do
        -- 现代 API 第 7 个参数是 source
        local name, _, _, _, _, _, source = UnitBuff(unit, i)
        if not name then break end
        if string.find(name, spellName) and source == "player" then
            return true
        end
        i = i + 1
    end
    return false
end

function Mage_GetPlayerCasting()
    -- 1. 检查普通读条 (圣光术、炉石等)
    local spellName = UnitCastingInfo("player")
    if spellName then
        return spellName
    end

    -- 2. 检查引导读条 (唤醒、奥术飞弹、急救绷带等)
    -- 如果不检查这个，打绷带或者唤醒时插件可能会误判为“没在施法”从而移动打断
    spellName = UnitChannelInfo("player")
    if spellName then
        return spellName
    end

    return nil
end


-- ==========================================================
-- 函数: Mage_GetBeaconTimeByName
-- 参数: unit (string) - 例如 "party1", "target", "focus"
-- 返回: number - 剩余秒数。如果没有道标，返回 0
-- ==========================================================
function Mage_GetBeaconTimeByName(unit,spellName)
    -- 遍历单位身上的 Buff (通常检查前40个足够了)
    for i = 1, 40 do
        -- 获取 Buff 信息
        -- 参数7 (source) 非常重要，必须是 "player"
        local name, icon, count, debuffType, duration, expirationTime, source = UnitBuff(unit, i)
        -- 如果没有 buff 了，提前结束循环
        if not name then break end

        -- 核心判断：名字匹配 + 来源是我自己
        if string.find(name,spellName) then
            -- expirationTime 是 buff 结束的时刻 (GetTime格式)
            -- 剩余时间 = 结束时刻 - 当前时刻
            local timeLeft = expirationTime - GetTime()
            -- 稍微修正一下，防止返回负数
            if timeLeft < 0 then timeLeft = 0 end
            return timeLeft
        end
    end
    return 0 -- 没找到
end

-- ==========================================================
-- 函数: Mage_GetDeBuffTimeByName
-- 参数: unit (string) - 例如 "party1", "target", "focus"
-- 返回: number - 剩余秒数。如果没有道标，返回 0
-- ==========================================================
function Mage_GetDeBuffTimeByName(unit,spellName)
    -- 遍历单位身上的 DeBuff (通常检查前40个足够了)
    for i = 1, 40 do
        -- 获取 Buff 信息
        local name, _, _, _, duration, expirationTime, source = UnitDebuff(unit, i)
        -- 如果没有 buff 了，提前结束循环
        if not name then break end

        -- 核心判断：名字匹配 + 来源是我自己
        if string.find(name,spellName) then
            -- expirationTime 是 buff 结束的时刻 (GetTime格式)
            -- 剩余时间 = 结束时刻 - 当前时刻
            local timeLeft = expirationTime - GetTime()
            -- 稍微修正一下，防止返回负数
            if timeLeft < 0 then timeLeft = 0 end
            return timeLeft
        end
    end
    return 0 -- 没找到
end

-- 获取指定单位当前施法/引导的剩余时间（秒）
-- 参数: unit (默认为 "player")
-- 返回:
-- 1. 剩余秒数 (如果没有施法，返回 0)
-- 2. 技能名称
-- 3. 类型 ("casting" 或 "channeling")
function Mage_GetCastRemainingTime(unit)
    if not unit then unit = "player" end

    local currentTime = GetTime() -- 获取当前系统时间(秒)

    -- 1. 检查普通读条 (UnitCastingInfo)
    -- 返回值: name, text, texture, startTime, endTime, ...
    local name, _, _, _, endTime = UnitCastingInfo(unit)

    if name and endTime then
        -- endTime 单位是毫秒，需要除以 1000 换算成秒
        local finishTime = endTime / 1000
        local remaining = finishTime - currentTime

        if remaining < 0 then remaining = 0 end
        return remaining, name, "casting"
    end

    -- 2. 检查通道法术 (UnitChannelInfo) - 比如暴风雪、唤醒
    local name, _, _, _, endTime = UnitChannelInfo(unit)

    if name and endTime then
        local finishTime = endTime / 1000
        local remaining = finishTime - currentTime

        if remaining < 0 then remaining = 0 end
        return remaining, name, "channeling"
    end

    -- 3. 当前没有施法
    return 0, nil, nil
end


-- 常见的减速 Buff 名单，如果目标已有这些，则不补减速术
local Mage_Common_Slow_Buffs = {
    ["减速"] = true,       -- 奥法自身
    ["断筋"] = true,         -- 战士
    ["强化断筋"] = true,      -- 战士
    ["减速药膏"] = true,     -- 盗贼
    ["冰冷触摸"] = true,     -- DK
    ["寒冰箭"] = true,       -- 法师通用
    ["冰霜新星"] = true,     -- 法师通用
    ["霜寒刺骨"] = true,
    ["深度冻结"] = true,
    ["冰锥术"] = true,       -- 法师通用
    ["地震术"] = true,       -- 萨满
    ["地缚图腾"] = true,     -- 萨满
    ["疲劳诅咒"] = true,     -- 术士
}
-- 检查目标是否已经处于某种减速状态
function Mage_TargetHasSlowEffect()
    if not UnitExists("target") then return false end
    local i = 1
    while true do
        local name = UnitDebuff("target", i)
        if not name then break end
        if Mage_Common_Slow_Buffs[name] then
            return true
        end
        i = i + 1
    end
    return false
end

-- 获取单位身上指定名称的堆叠层数 (兼容 Buff 和 Debuff)
function Mage_GetBuffStacks(unit, spellName)
    if not unit then unit = "player" end
    -- 1. 先从 Buff 中查找
    local i = 1
    while true do
        local name, _, count = UnitBuff(unit, i)
        if not name then break end
        if name == spellName then
            return (count and count > 0) and count or 1
        end
        i = i+1
    end
    -- 2. 如果 Buff 没找到，从 Debuff 中查找 (应对奥术冲击是 Debuff 的情况)
    i = 1
    while true do
        local name, _, count = UnitDebuff(unit, i)
        if not name then break end
        if name == spellName then
            return (count and count > 0) and count or 1
        end
        i = i+1
    end
    return 0
end

function Mage_GetSpellCooldown(spellname)
	local start, duration, enabled = GetSpellCooldown(spellname);
	if not start or enabled == 0 then
		 return 0;
	elseif ( start ~= nil and duration ~= nil and start > 0 and duration > 0) then
		 return (start + duration - GetTime());
	else
		 return 0;
	end
end

function Mage_GetSpellCooldownNoGcd(spellname)
	local start, duration, enabled = GetSpellCooldown(spellname)
    if not start or enabled == 0 then
        return 0
    end
    local _, gcdDuration = GetSpellCooldown(61304)
    if start > 0 and duration > gcdDuration then
        local cdLeft = start + duration - GetTime()
        return math.max(0, cdLeft)
    end
    return 0
end

function Mage_IsPetAttacking()

    local petTarget = "pettarget"

    -- 3. 检查目标是否存在
    if UnitExists(petTarget) then
        -- 4. 深度检查：
        -- a. 目标必须是可以攻击的 (UnitCanAttack 排除掉友方目标)
        -- b. 目标必须是活着的 (UnitIsDead 排除掉已经打死的尸体)
        if UnitCanAttack("pet", petTarget) and not UnitIsDead(petTarget) then
            return true
        end
    end

    return false
end


function Mage_HasSpell(spell)
	local actionid = Mage_all_GetActionID(spell);
	if actionid == 0 then return false; end;
	return true;
 end

function Mage_IsUsableSpell(spell)
   local actionid = Mage_GetActionID(spell);
   if actionid == 0 then return false; end;
   if not IsUsableAction(actionid) then return false; end;
   if Mage_GetActionCooldown(actionid) ~= 0 then return false; end;
   return true;
end

function Mage_IsManaEnough(spell)
   local actionid = Mage_GetActionID(spell);
   if actionid == 0 then return false; end;
   if not IsUsableAction(actionid) then return false; end;
   return true;
end


function Mage_IsAttack()
	local actionid  = Mage_all_GetActionID("攻击");
    if actionid == 0 then return false; end;
	if IsAttackAction(actionid) and IsCurrentAction(actionid) then return true; end;
	return false;
end;



function Mage_GetActionCooldown(i)
	local start, duration, enabled = GetActionCooldown(i);
	if enabled == 0 then
		 return 0;
	elseif ( start > 0 and duration > 0) then
		 return (start + duration - GetTime());
	else
		 return 0;
	end
	return duration;
end

function Mage_all_GetActionID(spellname)
	for i = 1, 120 do
    		 if HasAction(i) then
    			local type, globalID, subType = GetActionInfo(i);
    			if type == "spell" then
    				local name, _, _ = GetSpellInfo(globalID);
    				if  name == spellname then return i; end;
    			elseif type == "macro" then
    				local name, iconTexture, body, isLocal = GetMacroInfo(globalID);
    				if name == spellname then return i; end;
    			elseif type == "item" then
    				local name, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(globalID);
    				if name then
    					if  string.find(name, spellname) then return i; end;
    				end;
    			end
    		end
    	end
	return 0;
end

function Mage_A_GetActionID(spellname)
	for i = 73, 85 do
		 if ( HasAction(i) ) then
			local type, globalID, subType = GetActionInfo(i);
			if type == "spell" then
				local name, _, _ = GetSpellInfo(globalID);
				if  name == spellname then return i; end;
			elseif type == "macro" then
				local name, iconTexture, body, isLocal = GetMacroInfo(globalID);
				if name == spellname then return i; end;
			elseif type == "item" then
				local name, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(globalID);
				if name then
					if  string.find(name, spellname) then return i; end;
				end;
			end
		end
	end
	return 0;
end

function Mage_GetActionID(spellname)
	for i = 1, 120 do
		 if ( HasAction(i) ) and ( i < 48 or i > 60) then
			local type, globalID, subType = GetActionInfo(i);
			if type == "spell" then
				local name, _, _ = GetSpellInfo(globalID);
				---if  string.find(name, spellname) then return i; end;
				if  name == spellname then return i; end;
			elseif type == "macro" then
				local name, iconTexture, body, isLocal = GetMacroInfo(globalID);
				-- Mage_Default_AddMessage("____"..name.."______"..globalID.."____");
				if name == spellname then return i; end;
			elseif type == "item" then
				local name, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(globalID);
				if name then
					if  string.find(name, spellname) then return i; end;
				end;
			end
		end
	end
	return 0;
end


function Mage_CastSpell(spellname)
	local actionid = 0;
    if GetShapeshiftForm(true) == 1 or GetShapeshiftForm(true) == 2 then
	 	   actionid = Mage_A_GetActionID(spellname);
	 	   if actionid == 0 then actionid = Mage_GetActionID(spellname); end;
	else
		actionid = Mage_GetActionID(spellname);
    end;

   if actionid == 0 then return false; end;

   local _, globalid = GetActionInfo(actionid);

   if not IsUsableAction(actionid)  then return false; end;
   if Mage_GetActionCooldown(actionid) ~= 0 then return false; end;

   if actionid >= 1 and actionid <= 12 then
		Mage_SetText(spellname,actionid );	------ key = 1234567890-=
		return true;
   elseif actionid >= 73 and actionid <= 85 then
		Mage_SetText(spellname,actionid - 72);	------ key = 1234567890-=
		return true;
   elseif actionid >= 61 and actionid <= 72 then
		Mage_SetText(spellname,actionid - 48);	---------  F1 F2 F3 ] F5  ... F12
		return true;
   elseif actionid >= 25 and actionid <= 36 then
		Mage_SetText(spellname,actionid + 24);	-------------  key = SHIFT-F1 SHIFT-F2 SHIFT-F3 [ SHIFT-F5  ... SHIFT-F12
		return true;
    elseif actionid >= 37 and actionid <= 48 then
		Mage_SetText(spellname,actionid);	-------------  key = CTRL-F1 CTRL-F2 CTRL-F3 [ CTRL-F5  ... CTRL-F12
		return true;
    end;
   return false;
end



function Test_Target_IsMe()
	if UnitExists("playertargettarget") then
		if UnitIsUnit("playertargettarget", "player") then
			return true;
		end
	end
	return false;
end

function Test_Raid_Target_IsMe()
    if UnitInRaid("player") then
		for id=1, GetNumGroupMembers()  do
			local unit = "raid"..id;
			if  UnitExists(unit)  then
				if UnitExists(unit.."targettarget") and UnitLevel(unit.."target") >= 60 then
					if  UnitClassification(unit.."target") == "worldboss" or UnitClassification(unit.."target") == "elite"   then
						if UnitIsUnit(unit.."targettarget", "player") then
							return true;
						end
					end
				end
			end
		end
	else
		for id=1, GetNumGroupMembers() do
			local unit = "party"..id;
			if  UnitExists(unit)  then
				if UnitExists(unit.."targettarget") and UnitLevel(unit.."target") >= 60 then
					if  UnitClassification(unit.."target") == "worldboss" or UnitClassification(unit.."target") == "elite"   then
						if UnitIsUnit(unit.."targettarget", "player") then
							return true;
						end
					end
				end
			end
		end
	end
	return false;
end

function Mage_GetItemInfo(slotId)
	local mainHandLink = GetInventoryItemLink("player",slotId);
	local _, _, itemCode = strfind(mainHandLink, "(%d+):");
	local itemName, _, _, _, _, itemType = GetItemInfo(itemCode);
	return itemName;
end


function Mage_TestTrinket(TrinketName)
	if string.find(Mage_GetItemInfo(13),TrinketName) or string.find(Mage_GetItemInfo(14),TrinketName) then
		return true;
	end
	return false;
end

function Mage_GetMainHandType()
	local mainHandLink = GetInventoryItemLink("player",16);
	local _, _, itemCode = strfind(mainHandLink, "(%d+):");
	local itemName, _, _, _, _,_, itemType = GetItemInfo(itemCode);
	return itemType;
end

function Mage_Warning_AddMessage(str)
	if Messagestr ~= str then
		Messagestr = str;
		if (UnitInRaid("player")) then
			SendChatMessage(str,"Raid");
		else
			if GetNumGroupMembers() > 0 then
				SendChatMessage(str,"Party");
			else
				DEFAULT_CHAT_FRAME:AddMessage("|cffffff00战斗信息:|r |cff00ff00" .. str .. "|r");
			end;
		end
	end
end

function Mage_Test_Battlefield()
	-- IsInInstance() 返回两个值：
    -- 1. inInstance (boolean): 是否在副本/实例中
    -- 2. instanceType (string): 实例的类型
    local inInstance, instanceType = IsInInstance()
    -- instanceType 的返回值说明：
    -- "none"  = 野外
    -- "pvp"   = 战场 (战歌、阿拉希、奥山、远古海滩等)
    -- "arena" = 竞技场
    -- "party" = 5人本
    -- "raid"  = 团本
    if instanceType == "pvp" then
        return true;
    end
    return false;
end

function Mage_PlayerInArena()
    local inInstance, instanceType = IsInInstance()
    if instanceType == "arena" then
        return true;
    end
    return false;
end

function Mage_Default_AddMessage(str)
	if Messagestr ~= str then
		Messagestr = str;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00战斗信息:|r |cff00ff00" .. str .. "|r");
	end
end

function Mage_AddMessage(str)
	if Messagestr ~= str then
		Messagestr = str;
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff00战斗信息:|r |cff00ff00" .. str .. "|r");
	end
end

function Mage_Combat_AddMessage(str)
	if Noticestr ~= str then
		Noticestr = str;
		Blizzard_AddMessage(str,0.93,0.78,0.06,"crit");
	end
end


function Mage_SendChatMessage(message,name)
    if ChatMessagestr ~= message then
        ChatMessagestr = message;
        SendChatMessage(message,"WHISPER",nil,name);
    end
end

local lastYellTime = GetTime()

function Mage_SendYellMessage(message)
	if GetTime() - lastYellTime > 30 then
		lastYellTime = GetTime()
		SendChatMessage(message,"YELL")
	end
end

function Mage_SendPartyMessage(message)
	if PartyMessage ~= message then
		PartyMessage = message;
		if message ~= "" then
			SendChatMessage(message,"PARTY")
		end
	end
end


function Blizzard_AddMessage(text, r, g, b, sticky)
    -- 1. 检查并加载暴雪自带的浮动战斗信息插件
    if not IsAddOnLoaded("Blizzard_CombatText") then
        UIParentLoadAddOn("Blizzard_CombatText")
    end

    -- 2. 检查 CVar 设置是否开启 (比模拟点击按钮更安全)
    -- 如果当前设置为 "0" (关闭)，则强制设为 "1" (开启)
    if GetCVar("enableFloatingCombatText") == "0" then
        SetCVar("enableFloatingCombatText", "1")
    end

    -- 3. 发送信息
    if CombatText_AddMessage then
        -- 如果 sticky 为 true，则使用 "crit" (暴击) 样式，否则为 nil
        local scrollType = CombatText_StandardScroll -- 获取默认滚动方式
        local stickyType = sticky and "crit" or nil

        CombatText_AddMessage(text, scrollType, r, g, b, stickyType, false)
    end
end

function Mage_SetText(str,rgb)
	Mage_MSG_Text:SetText(str);
	local R = math.modf(rgb / 100) / 10 - 0.02
	local G = math.modf(rgb % 100 / 10) / 10 - 0.02
	local B = rgb % 10 / 10 - 0.02
--     Mage_AddMessage("spellname " .. str .." = " .. rgb .. "  => G:" .. G .." , R:" .. R .. ", B:" .. B );
	getglobal("MageCastColor"):SetColorTexture(R, G, B, 1);
end

function  Mage_GetUnitHealthPercent(unit)
	local health, healthmax  = UnitHealth(unit), UnitHealthMax(unit);
	local healthPercent = floor(health/healthmax*100+0.5);
	return healthPercent;
end

function  Mage_GetUnitLoseHealth(unit)
	local health, healthmax  = UnitHealth(unit), UnitHealthMax(unit);
	return healthmax - health;
end

function Mage_GetUnitManaPercent(unit)
	if UnitIsDeadOrGhost("player") then return 100; end
	local mana, manamax = UnitPower("player"), UnitPowerMax("player");
	local ManaPercent = floor(mana/manamax*100+0.5);
	return ManaPercent;
end




function GUIDToFriendUnit(GUID)
	if (not GUID) then
		return false;
	elseif (GUID == UnitGUID("player")) then
		return "player";
	elseif (GUID == UnitGUID("party1")) then
		return "party1";
	elseif (GUID == UnitGUID("party2")) then
		return "party2";
	elseif (GUID == UnitGUID("party3")) then
		return "party3";
	elseif (GUID == UnitGUID("party4")) then
		return "party4";
	elseif (GUID == UnitGUID("playerpet")) then
		return "playerpet";
	elseif (GUID == UnitGUID("party1pet")) then
		return "party1pet";
	elseif (GUID == UnitGUID("party2pet")) then
		return "party2pet";
	elseif (GUID == UnitGUID("party3pet")) then
		return "party3pet";
	elseif (GUID == UnitGUID("party4pet")) then
		return "party4pet";
	else
			for i=1, 40 do
				if GUID == UnitGUID("raid"..i) then
					return "raid"..i;
				end
			end
	end
	return false;
end


function Mage_Get_Target_Unit(name)
    if UnitInRaid("player") then
		for id=1, 40  do
			local unit = "raid"..id;
			if  UnitExists(unit)  then
				if UnitName("target",unit) == name then
					 return unit;
				end
			end
		end
	else
		for id=1, GetNumGroupMembers()  do
			local unit = "party"..id;
			if  UnitExists(unit)  then
				if UnitName("target",unit) == name  then
					 return unit;
				end
			end
		end
	end
	return "";
end


function Mage_Check_Dot_Debuff(unit)
    if  UnitExists(unit) then
        if UnitCanAttack("player",unit) then
            if Mage_UnitTargetDeBU(unit,"月火术")
            or Mage_UnitTargetDeBU(unit,"撕裂")
            or Mage_UnitTargetDeBU(unit,"腐蚀术")
            or Mage_UnitTargetDeBU(unit,"痛苦诅咒")
            or Mage_UnitTargetDeBU(unit,"吸取生命")
            or Mage_UnitTargetDeBU(unit,"献祭")
            or Mage_UnitTargetDeBU(unit,"火球术")
            or Mage_UnitTargetDeBU(unit,"点燃")
            or Mage_UnitTargetDeBU(unit,"燃烧")
            or Mage_UnitTargetDeBU(unit,"流血")
            or Mage_UnitTargetDeBU(unit,"活动炸弹")
            or Mage_UnitTargetDeBU(unit,"寒冰炸弹")
            or Mage_UnitTargetDeBU(unit,"虚空风暴")
            or Mage_UnitTargetDeBU(unit,"暗言术：痛")
            or Mage_UnitTargetDeBU(unit,"噬灵瘟疫")
            or Mage_UnitTargetDeBU(unit,"毒蛇钉刺")
            or Mage_UnitTargetDeBU(unit,"割裂")
            or Mage_UnitTargetDeBU(unit,"重伤")
            then
                return true;
            end
        end
	end
	return false;
end

function Mage_Test_Targert_Control(unit)
	if  UnitExists(unit) then
        if UnitCanAttack("player",unit) then
            if Mage_UnitTargetDeBU(unit,"媚惑")
            or Mage_UnitTargetDeBU(unit,"变形术")
            or Mage_UnitTargetDeBU(unit,"妖术")
            or Mage_UnitTargetDeBU(unit,"休眠")
            or Mage_UnitTargetDeBU(unit,"致盲")
            or Mage_UnitTargetDeBU(unit,"冰冻陷阱")
            or Mage_UnitTargetDeBU(unit,"忏悔")
            or Mage_UnitTargetDeBU(unit,"闷棍")
            or Mage_UnitTargetDeBU(unit,"恐吓野兽")
            or Mage_UnitTargetDeBU(unit,"驱散射击")
            or Mage_UnitTargetDeBU(unit,"心灵尖啸")
            or Mage_UnitTargetDeBU(unit,"精神控制")
            or Mage_UnitTargetDeBU(unit,"恐惧嚎叫")
            or Mage_UnitTargetDeBU(unit,"女妖媚惑")
            or Mage_UnitTargetDeBU(unit,"翼龙钉刺")
            or Mage_UnitTargetDeBU(unit,"凿击")
            or Mage_UnitTargetDeBU(unit,"肾击")
            or Mage_UnitTargetDeBU(unit,"冻结")
            or Mage_UnitTargetDeBU(unit,"深结")
            or Mage_UnitTargetDeBU(unit,"偷袭")
            or Mage_UnitTargetDeBU(unit,"突袭")
            or Mage_UnitTargetDeBU(unit,"猛击")
            then
                return true;
            end
        end
	end
	return false;
end


function Mage_Test_Target_Debuff(unit)
	if  UnitExists(unit) then
        if UnitCanAttack("player",unit) then
            if Mage_UnitTargetDeBU(unit,"媚惑")
            or Mage_UnitTargetDeBU(unit,"变形术")
            or Mage_UnitTargetDeBU(unit,"妖术")
            or Mage_UnitTargetDeBU(unit,"休眠")
            or Mage_UnitTargetDeBU(unit,"致盲")
            or Mage_UnitTargetDeBU(unit,"冰冻陷阱")
            or Mage_UnitTargetDeBU(unit,"忏悔")
            or Mage_UnitTargetDeBU(unit,"闷棍")
            or Mage_UnitTargetDeBU(unit,"恐吓野兽")
            or Mage_UnitTargetDeBU(unit,"驱散射击")
            or Mage_UnitTargetDeBU(unit,"心灵尖啸")
            or Mage_UnitTargetDeBU(unit,"精神控制")
            or Mage_UnitTargetDeBU(unit,"恐惧嚎叫")
            or Mage_UnitTargetDeBU(unit,"女妖媚惑")
            or Mage_UnitTargetDeBU(unit,"翼龙钉刺")
            or Mage_UnitTargetDeBU(unit,"忏悔")
            or Mage_UnitTargetDeBU(unit,"凿击")
            then
                return true;
            end
        end
	end
	return false;
end



local TimerDatas = {};

function StartTimer(id)
	for k, v in pairs(TimerDatas) do
		if(id == v["Name"]) then
			v["Time"] = GetTime();
			return ;
		end
	end
	table.insert(TimerDatas,
		{
		["Name"] = id,
		["Time"] = GetTime(),
		});
end

function GetTimer(id)
	for k, v in pairs(TimerDatas) do
		if(id == v["Name"]) then
			local now = GetTime();
			local startTime = v["Time"];
			return (now - startTime), startTime, now;
		end
	end
	return 999;
end
function EndTimer(id)
	for k, v in pairs(TimerDatas) do							
		if(id == v["Name"]) then
			table.remove(TimerDatas,k);
			return ;			
		end		
	end
end