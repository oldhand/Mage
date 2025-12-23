
-- ==========================================
-- 配置区：80级保命物品优先级列表
-- 将你想用的物品按优先级从高到低排列
-- ==========================================
local Mage_Survival_Items = {
    -- [优先级 1] 术士的糖 (不占药水CD，优先吃)
    "邪能治疗石",       -- WotLK 80级 术士糖 (回血最多)
    "大师级治疗石",     -- 70级 糖 (备用)

    -- [优先级 2] 炼金/工程专用 (无限使用或特殊效果)
    "无尽治疗药水",     -- 炼金师专用 (无限喝，回血量中等)
    "治疗注射器",       -- 工程学专用 (回血，不占公用CD，如果你是工程)
    "疯狂炼金师药水",   -- 炼金师专用 (随机效果，包含回血)

    -- [优先级 3] 常规药水 (WotLK 标准)
    "符文治疗药水",     -- 80级 顶级红药 (回 2700-4500)
    "符文法力药水",     -- (如果你想在这里顺便判断蓝药，也可以加，但建议分开)

    -- [优先级 4] 低级/备用药水 (TBC/旧世剩余)
    "超级治疗药水",     -- 70级 红药
    "强效治疗药水",     -- 60级 红药
}

function Mage_playerSelectSelf()
    if not UnitExists("target") then return true; end
    if UnitCanAttack("player","target") then return true; end
    if UnitIsUnit("target", "player") then return true; end
    return false;
end


function Mage_playerSafe()

    if Mage_GetUnitHealthPercent("player") < 20 and UnitAffectingCombat("player") and not Mage_Test_Battlefield() and not Mage_PlayerBU("圣盾术") then
        -- 检测防抖定时器 (防止瞬间重复按键)
        if GetTimer("PotionRecovery") < 0.2 or GetTimer("PotionRecovery") > 3 then
            for _, itemName in ipairs(Mage_Survival_Items) do
               if Mage_FindItemInBag(itemName) and Mage_CheckItemIsReady(itemName) then
                  if Mage_CastSpell(itemName) then StartTimer("PotionRecovery"); return true; end;
              end
           end
       end
    end



    if Mage_HasSpell("奥术智慧") and not Mage_PlayerBU("奥术智慧") and not Mage_PlayerBU("奥术光辉") and not Mage_PlayerBU("邪能智力") then
         if Mage_playerSelectSelf() then
                if Mage_CastSpell("奥术智慧") then  return true; end;
                Mage_SetText(">奥术智慧",0);
                return true;
         else
             if Mage_TargetPlayer() then return true; end;
         end
    end


   	if Mage_HasSpell("寒冰屏障") and Mage_GetActiveMeleeCount() > 2 and not Mage_PlayerDeBU("低温") and not Mage_PlayerBU("保护之手") then
   		if Mage_GetUnitHealthPercent("player") < 30 and UnitAffectingCombat("player") then
   			if Mage_GetSpellCooldown("寒冰屏障") == 0 then
   				if Mage_CastSpell("寒冰屏障") then return true; end;
   			end
   		end
   	end

--        local AttackMeNpcName = GetActiveMeleeCount();
--        if AttackMeNpcName and  AttackMeNpcName >= 6 and UnitIsPlayer("target")  and not Mage_HasBattleFlag() then
--    		if not Mage_PlayerDeBU("低温") and Mage_GetSpellCooldown("寒冰屏障") == 0 then
--    			if Mage_CastSpell("寒冰屏障") then
--    				Mage_Default_AddMessage("**"..AttackMeNpcName.."个目标正在攻击我,被集火了,使用冰箱...**");
--    				Mage_Combat_AddMessage("**"..AttackMeNpcName.."个目标正在攻击我,被集火了,使用冰箱...**");
--    				return true;
--    			end;
--    		end;
--    	end;

   	if UnitAffectingCombat("player") then
   		if  IsInInstance() then
   			if  UnitClassification("target") == "worldboss" or UnitClassification("target") == "elite" then
   					if Test_Target_IsMe() and UnitLevel("target") > UnitLevel("player")  then
   						if  not Mage_PlayerDeBU("低温") and Mage_GetSpellCooldown("寒冰屏障") == 0 and not Mage_PlayerBU("保护之手") then
   							if Mage_CastSpell("寒冰屏障") then
   								Mage_Default_AddMessage("**OT了,使用冰箱...**");
   								Mage_Combat_AddMessage("**OT了,使用冰箱...**");
   								return true;
   							end;
   						end;
   					end;
   			end;
   			if Test_Raid_Target_IsMe() then
   				if not Mage_PlayerDeBU("低温") and Mage_GetSpellCooldown("寒冰屏障") == 0 and not Mage_PlayerBU("保护之手") then
   					if Mage_CastSpell("寒冰屏障") then
   						Mage_Default_AddMessage("**OT了,使用冰箱...**");
   						Mage_Combat_AddMessage("**OT了,使用冰箱...**");
   						return true;
   					end;
   				end;
   			end;
   		end
   	end;

    -- ========================================================
    -- 隐形术保命/清仇恨逻辑
    -- ========================================================
    if UnitAffectingCombat("player") and Mage_HasSpell("隐形术") and Mage_GetSpellCooldown("隐形术") == 0 then
        -- 1. OT 清仇恨逻辑
        -- 如果在副本中，目标是强力怪，且目标正在看我
        if  Mage_PlayerDeBU("低温") and IsInInstance() and Test_Target_IsMe() and not Mage_PlayerBU("保护之手") then
             local targetType = UnitClassification("target");
             if targetType == "worldboss" or targetType == "elite" then
                 if Mage_CastSpell("隐形术") then
                     Mage_Default_AddMessage("**检测到OT且无法冰箱 (目标看我)，使用隐形术清仇恨...**");
                     Mage_Combat_AddMessage("**检测到OT且无法冰箱，隐形术启动!**");
                     return true;
                 end
             end
        end

        -- 2. 残血保命逻辑 (优先级低于冰箱，但作为备选)
        -- 如果血量低于 20% 且 冰箱在冷却(或者有低温BUFF)
        if Mage_GetUnitHealthPercent("player") < 20 then
            if Mage_PlayerDeBU("低温") or Mage_GetSpellCooldown("寒冰屏障") > 0 and not Mage_PlayerBU("保护之手") then
                 if Mage_CastSpell("隐形术") then
                     Mage_Default_AddMessage("**血量危急且无法冰箱，使用隐形术跑路...**");
                     Mage_Combat_AddMessage("**血量危急且无法冰箱，使用隐形术跑路...**");
                     return true;
                 end
            end
        end
    end

   	if   Mage_PlayerDeBU("肾击")
   	   or  Mage_PlayerDeBU("偷袭")
   	   or  Mage_PlayerDeBU("突袭")
   	   or  Mage_PlayerDeBU("割碎")
   	   or  Mage_PlayerDeBU("寒冰箭")
   	   or  Mage_PlayerDeBU("冲锋")
   	   or  Mage_PlayerDeBU("饥饿之寒")
   	   or  Mage_PlayerDeBU("暗影之怒")
   	   or  Mage_PlayerDeBU("蛮力猛击")
   	   or  Mage_PlayerDeBU("死亡之握")
   	   or  Mage_PlayerDeBU("反手一击")
   	   or  Mage_PlayerDeBU("窒息")
   	   or  Mage_PlayerDeBU("震荡波")
   	   or  Mage_PlayerDeBU("风暴之锤")
   	   or  Mage_PlayerDeBU("扫堂腿")
   	   or  Mage_PlayerDeBU("制裁之拳")
   	   or  Mage_PlayerDeBU("制裁之锤")
   	   or  Mage_PlayerDeBU("混乱新星")
   			   then
   				   if Mage_GetSpellCooldown("闪现术") == 0 then
   		   				if Mage_CastSpell("闪现术") then
   		   					Mage_Default_AddMessage("**因为昏迷使用闪现术...**");
   		   					return true;
   		   				end;
   					else
   						if not Mage_PlayerDeBU("低温") and Mage_GetSpellCooldown("寒冰屏障") == 0 then
   							if Mage_CastSpell("寒冰屏障") then return true; end;
   						end;
   				   end

   	end;

   	if IsInInstance() then
   		if not Mage_PlayerBU("寒冰护体") and not UnitAffectingCombat("player") then
   			if Mage_CastSpell("寒冰护体") then  return true; end;
   		end;
   	end

    if Mage_GetMageSpec() == 1 then
        if not Mage_PlayerBU("熔岩护甲") then
            if Mage_CastSpell("熔岩护甲") then  return true; end;
        end
    elseif Mage_GetMageSpec() == 0 then
        if not Mage_PlayerBU("霜甲术") and not Mage_PlayerBU("冰甲术") and not Mage_PlayerBU("法师护甲") and not UnitAffectingCombat("player") then
            if Mage_Test_Battlefield() or Mage_PlayerInArena() then
               if Mage_HasSpell("冰甲术") then
                  if Mage_CastSpell("冰甲术") then  return true; end;
               else
                  if Mage_CastSpell("霜甲术") then  return true; end;
              end
            else
                if Mage_HasSpell("法师护甲") then
                      if Mage_CastSpell("法师护甲") then  return true; end;
                else
                      if Mage_CastSpell("霜甲术") then  return true; end;
                end
            end
        end;
    end



--    	if not UnitExists("target") or UnitIsUnit("target", "player") or UnitCanAttack("player","target")  then
--    		if not Mage_PlayerBU("魔法抑制") and not UnitAffectingCombat("player") and not Test_HasCurer() then
--    			if Mage_CastSpell("魔法抑制") then  return true; end;
--    		end;
--    	end

   	if UnitExists("target")  and UnitIsPlayer("target") then
   		 if UnitClass("target") == "法师" and IsSpellInRange("寒冰箭","target") == 1 and Mage_HasSpell("防护冰霜结界") then
   			  if Test_Target_IsMe() and UnitCanAttack("player","target") then
   				   if Mage_CastSpell("防护冰霜结界") then  return true; end;
   			  end
   		 end
   		 if not Mage_PlayerBU("寒冰护体") and UnitCanAttack("player","target") then
   			if Mage_CastSpell("寒冰护体") then  return true; end;
   			if Mage_GetSpellCooldown("寒冰护体") > 1 and GetTimer("HasSwingRange_Damage") > 3 and UnitAffectingCombat("player") and not Mage_PlayerBU("法力护盾") then
   				if Mage_CastSpell("法力护盾") then  return true; end;
   			end
   		 end;
   	else
   		if UnitExists("target") then
   			 if not UnitAffectingCombat("player") and UnitCanAttack("player","target") and Mage_HasSpell("寒冰护体") then
   				if not Mage_PlayerBU("寒冰护体") and UnitCanAttack("player","target") then
   					if Mage_CastSpell("寒冰护体") then  return true; end;
   				end;
   			 end;
   			 if Test_Target_IsMe() and UnitCanAttack("player","target") and Mage_HasSpell("寒冰护体") then
   				if not Mage_PlayerBU("寒冰护体") then
   					if Mage_CastSpell("寒冰护体") then return true; end;
   					if Mage_GetSpellCooldown("寒冰护体") > 1 and GetTimer("HasSwingRange_Damage") > 3 and UnitAffectingCombat("player") and not Mage_PlayerBU("法力护盾") then
   						if Mage_CastSpell("法力护盾") then  return true; end;
   					end
   				end;
   			end;
   		end;
   	end;


   	local counts = Mage_DecursiveScanUnit("player");
   	if counts["Curse"] > 0 then
        if Mage_HasSpell("解除诅咒") then
            if Mage_playerSelectSelf() then
                if Mage_CastSpell("解除诅咒") then return true; end;
                Mage_SetText(">解除诅咒",0);
                return true;
            else
                if Mage_TargetPlayer() then return true; end;
            end
        end
    end

    if Mage_AutoCreateManaGem() then  return true; end;

    if Mage_AutoUseManaGem() then  return true; end;

    if Mage_AutoCheckPartyBuff() then  return true; end;

	return false;
end


function  Mage_AutoCheckPartyBuff()
	if not UnitAffectingCombat("player") and Mage_HasSpell("奥术光辉") and Mage_UnitInParty() then
        local needArcaneWisdom = 0;
        for index=1, 4 do
            local unit = "party"..index;
            if  UnitExists(unit)  then
                if UnitIsVisible(unit) and
                    not UnitIsDeadOrGhost(unit) and
                    not Mage_UnitTargetBU(unit,"奥术智慧") and
                    not Mage_UnitTargetBU(unit,"奥术光辉") and
                    not Mage_UnitTargetBU(unit,"邪能智力") and
                    IsSpellInRange("奥术光辉",unit) == 1 then
                       needArcaneWisdom = needArcaneWisdom + 1;
                end
            end
        end
        if needArcaneWisdom > 1 then
             if Mage_playerSelectSelf() then
                    if Mage_CastSpell("奥术光辉") then  return true; end;
                    Mage_SetText(">奥术光辉",0);
                    return true;
             else
                 if Mage_TargetPlayer() then return true; end;
             end
        elseif needArcaneWisdom == 1 then
            for index=1, 4 do
                local unit = "party"..index;
                if  UnitExists(unit)  then
                    if UnitIsVisible(unit) and
                        not UnitIsDeadOrGhost(unit) and
                        not Mage_UnitTargetBU(unit,"奥术智慧") and
                        not Mage_UnitTargetBU(unit,"奥术光辉") and
                        not Mage_UnitTargetBU(unit,"邪能智力") and
                        IsSpellInRange("奥术光辉",unit) == 1 then
                           if Mage_playerSelectUnit(unit) then
                                if Mage_CastSpell("奥术智慧") then  return true; end;
                                Mage_SetText(">奥术智慧",0);
                                return true;
                           else
                               if Mage_TargetUnit(unit) then return true; end;
                           end
                    end
                end
            end
        end
    end
	return false;
end


-- ==========================================
-- 修复版：通过扫描鼠标提示获取法力宝石真实次数
-- ==========================================
function Mage_GetManaGemCharges(itemName)
    local bag, slot = Mage_FindItemInBag(itemName)
    if not bag or not slot then return 0 end

    -- 使用插件里已有的 MageBufftip 或 MageTooltip 进行扫描
    local scanner = MageBufftip or MageTooltip
    scanner:SetOwner(UIParent, "ANCHOR_NONE")
    scanner:ClearLines()
    scanner:SetBagItem(bag, slot)

    -- 遍历提示信息的每一行，寻找包含 "次数" 或 "次" 的文本
    -- WLK 中通常显示为 "3 次使用机会" 或类似的格式
    for i = 1, scanner:NumLines() do
        local text = _G[scanner:GetName().."TextLeft"..i]:GetText()
        if text then
            -- 尝试匹配数字，例如 "3 次使用" 中的 3
            local charges = string.match(text, "(%d+)%s*次")
            if charges then
                scanner:Hide()
                return tonumber(charges)
            end
        end
    end

    scanner:Hide()
    -- 如果没扫描到次数，但物品确实在包里，说明可能是满次数状态（某些客户端不显示满次数）
    -- 或者该物品已经用完。为了保险，返回 1 诱发重造（如果是为了保持2次以上）
    return 1
end


function Mage_AutoCreateManaGem()
    -- 如果正在移动、正在施法、或在战斗中，则不制造
    if Mage_Check_Movement() or Mage_GetPlayerCasting() or UnitAffectingCombat("player") then
        return false
    end

    -- 检查法力宝石（WLK版本主要是法力红宝石，这里根据不同等级可以扩充）
    local gemNames = {"法力青玉","法力红宝石", "法力黄水晶", "法力翡翠", "法力玛瑙"}
    local hasGem = false
    local gemName = ""

    for _, name in ipairs(gemNames) do
        if Mage_FindItemInBag(name) then
            hasGem = true
            gemName = name;
            break
        end
    end
    -- 如果包里没有宝石，则尝试制造当前最高等级的宝石
    if not hasGem then
        if Mage_HasSpell("制造法力宝石") then
            if Mage_CastSpell("制造法力宝石") then
                Mage_Combat_AddMessage("**包里没宝石，正在制造法力宝石...**")
                return true
            end
        end
    else
        if gemName ~= "" then
            local charges = Mage_GetManaGemCharges(gemName);
            if charges < 2 then
                if Mage_HasSpell("制造法力宝石") then
                    if Mage_CastSpell("制造法力宝石") then
                        Mage_Combat_AddMessage("**法力宝石次数不足("..charges..")，正在重新制造...**")
                        return true
                    end
                end
            end
        end
    end
    return false
end


function Mage_AutoUseManaGem()
    -- 仅在战斗中且蓝量低于 30% 时使用
    if not UnitAffectingCombat("player") or Mage_GetUnitManaPercent("player") > 30 then
        return false
    end


    local gemNames = {"法力青玉","法力红宝石", "法力黄水晶", "法力翡翠", "法力玛瑙"}

    for _, name in ipairs(gemNames) do
        -- 检查物品是否存在且冷却完毕
        if Mage_FindItemInBag(name) and Mage_CheckItemIsReady(name) then
            if Mage_CastSpell(name) then
                Mage_Combat_AddMessage("**蓝量过低，使用: " .. name .. "**")
                Mage_Default_AddMessage("**蓝量过低，使用: " .. name .. "**")
                return true
            end
        end
    end
    return false
end