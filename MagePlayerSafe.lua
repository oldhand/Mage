
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
               if Mage_FindItemInBag(itemName) and Mage_IsItemReady(itemName) then
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


--    if UnitAffectingCombat("player") and Mage_GetUnitManaPercent("player") < 10 then
--    		if Mage_CheckBagHasItem("法力红宝石") then
--    			 if Mage_CastSpell("法力红宝石") then  return true; end;
--    		end
--    		if Mage_CheckBagHasItem("法力黄水晶") then
--    			 if Mage_CastSpell("法力黄水晶") then  return true; end;
--    		end
--    	end
--    	if not UnitExists("target") or not UnitCanAttack("player","target")  then
--    		if not UnitAffectingCombat("player") and not Mage_CheckBagHasItem("法力红宝石") and not Mage_movement then
--    			if Mage_CastSpell("制造魔法红宝石") then return true; end;
--    		end
--    		if not UnitAffectingCombat("player") and not Mage_CheckBagHasItem("法力黄水晶") and not Mage_movement then
--    			if Mage_CastSpell("制造魔法黄水晶") then return true; end;
--    		end
--    	end



   	if Mage_HasSpell("寒冰屏障") and Mage_GetActiveMeleeCount() > 2 and not Mage_PlayerDeBU("低温") then
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
   			if  UnitClassification("target") == "worldboss" and Mage_GetUnitManaPercent("player") < 60 then
   				if Mage_CheckBagHasItem("法力红宝石") then
   					 if Mage_CastSpell("法力红宝石") then  return true; end;
   				end
   			end;
   			if  UnitClassification("target") == "worldboss" or UnitClassification("target") == "elite" then
   					if Test_Target_IsMe() and UnitLevel("target") > UnitLevel("player")  then
   						if  not Mage_PlayerDeBU("低温") and Mage_GetSpellCooldown("寒冰屏障") == 0 then
   							if Mage_CastSpell("寒冰屏障") then
   								Mage_Default_AddMessage("**OT了,使用冰箱...**");
   								Mage_Combat_AddMessage("**OT了,使用冰箱...**");
   								return true;
   							end;
   						end;
   					end;
   			end;
   			if Test_Raid_Target_IsMe() then
   				if not Mage_PlayerDeBU("低温") and Mage_GetSpellCooldown("寒冰屏障") == 0 then
   					if Mage_CastSpell("寒冰屏障") then
   						Mage_Default_AddMessage("**OT了,使用冰箱...**");
   						Mage_Combat_AddMessage("**OT了,使用冰箱...**");
   						return true;
   					end;
   				end;
   			end;
   		end
   	end;

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

--    	if not UnitExists("target") or UnitIsUnit("target", "player") or UnitCanAttack("player","target")  then
--    		if not Mage_PlayerBU("魔法抑制") and not UnitAffectingCombat("player") and not Test_HasCurer() then
--    			if Mage_CastSpell("魔法抑制") then  return true; end;
--    		end;
--    	end

   	if UnitExists("target")  and UnitIsPlayer("target") then
   		 if UnitClass("target") == "法师" and IsSpellInRange("侦测魔法","target") == 1 then
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
   			 if not UnitAffectingCombat("player") and UnitCanAttack("player","target")  then
   				if not Mage_PlayerBU("寒冰护体") and UnitCanAttack("player","target") then
   					if Mage_CastSpell("寒冰护体") then  return true; end;
   				end;
   			 end;
   			 if Test_Target_IsMe() and UnitCanAttack("player","target") then
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
        if Mage_HasSpell("解除次级诅咒") then
            if Mage_playerSelectSelf() then
                if Mage_CastSpell("解除次级诅咒") then return true; end;
                Mage_SetText(">解除次级诅咒",0);
                return true;
            else
                if Mage_TargetPlayer() then return true; end;
            end
        end
    end
	return false;
end

