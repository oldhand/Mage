-- ========================================================
-- 配置：反射与免疫类 Buff 列表
-- ========================================================
local Mage_Reflect_Buffs = {
    ["法术反射"] = true,     -- 战士
    ["魔法反射"] = true,     -- 怪物
    ["群体反射"] = true,     -- 怪物/副本
    ["根基图腾"] = true,     -- 萨满 (虽然是图腾，但有时会显示为Buff或需特殊处理，此处作为Buff处理)
    ["法术偏斜"] = true,     -- 部分怪物
}

local Mage_Immune_Control_Buffs = {
    ["反魔法盾"] = true,     -- DK 绿坝
    ["暗影斗蓬"] = true,     -- 盗贼 斗篷
    ["圣盾术"] = true,       -- 骑士 无敌
    ["寒冰屏障"] = true,     -- 法师 冰箱
    ["神圣之火"] = true,     -- 或者是类似的免控Buff
    ["剑刃风暴"] = true,     -- 战士 大风车(免疫控制)
    ["兽心"] = true,         -- 猎人 红人
}

-- ========================================================
-- 辅助函数：一次性扫描目标身上的关键 Buff
-- 返回: isReflect (是否有反射), isImmuneControl (是否免控/免疫法术)
-- ========================================================
local function Mage_ScanTargetStatus(unit)
    if not UnitExists(unit) then return false, false end

    local isReflect = false
    local isImmuneControl = false

    local i = 1
    while true do
        local name = UnitBuff(unit, i)
        if not name then break end
        
        -- 检查是否为反射 Buff
        if Mage_Reflect_Buffs[name] then
            isReflect = true
        end

        -- 检查是否为免疫/免控 Buff
        if Mage_Immune_Control_Buffs[name] then
            isImmuneControl = true
        end

        -- 如果两个都找到了，可以提前退出循环（优化）
        if isReflect and isImmuneControl then
            break
        end

        i = i + 1
    end

    return isReflect, isImmuneControl
end


function Mage_playerCombat()

    -- ========================================================
    -- [优化] 战斗中的法术反射处理
    -- 使用之前获取的 targetIsReflect 状态
    -- ========================================================
    local targetIsReflect, targetIsImmuneControl = false, false
    if UnitExists("target") then
        targetIsReflect, targetIsImmuneControl = Mage_ScanTargetStatus("target")
    end
    -- ========================================================

    if Mage_TargetBU("反魔法盾") or
        Mage_TargetBU("暗影斗蓬") or
        Mage_TargetBU("圣盾术") or
        Mage_TargetBU("寒冰屏障")  then
            Mage_SetText("目录免疫魔法-停手", 0)
        return true;
    end

    -- 1. 基础快照（减少性能开销）
    local targetIsPlayer = UnitIsPlayer("target")
    local mageSpec = Mage_GetMageSpec()
    local targetType = UnitClassification("target")
    local targetHP = Mage_GetUnitHealthPercent("target")
    local creatureType = UnitCreatureType("target")

    -- 1. 变羊术逻辑
    if Mage_Get_Polymorph() == 1 then
        if UnitAffectingCombat("player") then
            if GetTimer("Mage_Polymorph") > 2 then  Mage_Combat_AddMessage("**变形术命令超时...**"); Mage_Set_Polymorph(0); end;
        else
            if GetTimer("Mage_Polymorph") > 6 then  Mage_Combat_AddMessage("**变形术命令超时...**"); Mage_Set_Polymorph(0); end;
        end
        if not Mage_Check_Movement() then
            if targetIsPlayer or creatureType == "人型生物" or creatureType == "野兽" then
                if IsSpellInRange("变形术","target") == 1  then
                    -- 使用缓存的状态进行判断
                    if targetIsReflect then
                        Mage_Combat_AddMessage("**目标>>"..UnitName("target").."<<存在反射效果，无法施放变形术...**");
                    elseif targetIsImmuneControl then
                        Mage_Combat_AddMessage("**目标>>"..UnitName("target").."<<存在免疫效果，无法施放变形术...**");
                    else
                        -- 既无反射也无免疫，执行变羊
                        if not Mage_Check_Dot_Debuff("target") then
                            if UnitExists("pet") and not UnitIsDead("pet") then
                                if Mage_IsPetAttacking() and UnitIsUnit("pettarget","target") then
                                     if Mage_StopPetAttack() then  return true; end
                                end
                            end
                            if Mage_CastSpell("变形术") then return true; end;
                        else
                             Mage_Combat_AddMessage("**目标>>"..UnitName("target").."<<目标有持续伤害效果，无法施放变形术...**");
                        end
                    end
                else
                    if GetTimer("变形术目标距离太远") > 0.5 then
                          StartTimer("变形术目标距离太远");
                          Blizzard_AddMessage("**目标距离太远，无法施放变形术**",1,0,0,"crit");
                    end;
                    Mage_SetText("变形术距离太远",0);
                    return true;
                end
            else
                Mage_Combat_AddMessage("**焦点>>"..UnitName("focus").."<<非人型生物和野兽，无法施放变形术...**");
                Mage_Default_AddMessage("**焦点>>"..UnitName("focus").."<<非人型生物和野兽，无法施放变形术...**");
                Mage_Set_Polymorph(0);
            end
        end
        Mage_SetText("等待变形术",0);
        return true;
    end

    -- 2. 非战斗/特殊目标检查
	if not UnitAffectingCombat("player") and not UnitAffectingCombat("target")  then
		if creatureType == "野生宠物" then
			    Mage_SetText("野生宠物",0);
			    return true;
		end;
		if  targetType == "rareelite"  then
			    Mage_SetText("稀有精英",0);
			    return true;
		end;
		if  targetType == "worldboss" or  targetType == "elite" then
				 Mage_SetText("精英目标",0);
			    return true;
		end
	end;


    if IsInInstance() and not targetIsPlayer and not Test_Target_IsMe()  then
		if  targetType == "worldboss" or targetType == "elite" then
			if UnitHealth("target") == UnitHealthMax("target") then
			    Mage_SetText("副本中绝不先手",0);
			    return true;
			end
		end
	end

   if mageSpec == 1 then
          if IsSpellInRange("霜火之箭","target") == 0 then
          		Mage_SetText("距离过远",0);
          		return;
          end;
    elseif mageSpec == 0 then
          if IsSpellInRange("寒冰箭","target") == 0 then
          		Mage_SetText("距离过远",0);
          		return;
          end;
    end

	if UnitExists("pet") and not UnitIsDead("pet") then
        if not Mage_IsPetAttacking() then
             if Mage_PetAttack() then  return true; end
        end
    end

    if mageSpec == 0 and UnitAffectingCombat("player") and not UnitExists("pet") and Mage_HasSpell("召唤水元素") and Mage_GetSpellCooldown("召唤水元素") == 0 then
        if Mage_CastSpell("召唤水元素") then return true; end;
    end



    if targetIsReflect then
        Mage_SetText("目标反射",0);
        -- 尝试使用冰枪术破盾 (瞬发, 伤害低, 适合破反射)
        if Mage_HasSpell("冰枪术") and Mage_GetSpellCooldown("冰枪术") == 0 and UnitClass("target") == "战士" and Mage_TargetBU("法术反射") then
             if Mage_CastSpell("冰枪术") then
                 Mage_Combat_AddMessage("**目标战士使用法术反射，使用冰枪术破盾...**");
                 return true;
             end
        end
        -- 如果没有冰枪术，则停止输出，防止被反伤/反制
        Mage_Combat_AddMessage("**目标存在反射，停止施法...**");
        return true;
    end
    -- ========================================================

	if Mage_Interrupt_Casting() then return true; end;


    if Mage_HasSpell("法术吸取") and Mage_IsManaEnough("法术吸取") and IsSpellInRange("法术吸取","target") == 1 then
        local hasMagicBuff, buffName = Mage_ScanTargetBuffs("target");
        if hasMagicBuff then
            if Mage_CastSpell("法术吸取") then
                Mage_Combat_AddMessage("**发现目标增益 [".. buffName .."] -> 使用法术吸取**");
                Mage_Default_AddMessage("**偷取目标Buff: [".. buffName .."]**");
                return true;
            end
        end
    end

    if mageSpec == 1 then
            if Mage_PlayerBU("一触即燃") then
                 if Mage_IsManaEnough("烈焰风暴") then
                      if GetTimer("烈焰风暴") > 1 and GetTimer("烈焰风暴") < 5 then
                             if Mage_FlameStormLevel8() then
                                 Mage_Combat_AddMessage("**(一触即燃)烈焰风暴(等级8)**");
                                 Mage_AddMessage("**(一触即燃)烈焰风暴(等级8)**")
                                 return true;
                             end;
                       else
                            if Mage_FlameStorm() then
                                 Mage_Combat_AddMessage("**(一触即燃)烈焰风暴**");
                                 Mage_AddMessage("**(一触即燃)烈焰风暴**")
                                 StartTimer("烈焰风暴");
                                 return true;
                            end;
                       end
                  else
                       Mage_Combat_AddMessage("**(一触即燃)烈焰风暴不可用，蓝量不够**");
                       Mage_AddMessage("**(一触即燃)烈焰风暴不可用，蓝量不够**")
                  end
            end
            if Mage_PlayerBU("法术连击") and Mage_HasSpell("炎爆术") then
                if Mage_CastSpell("炎爆术") then  return true; end
            end
            if Mage_HasSpell("冰枪术") then
                if Mage_TargetDeBU("深度冻结") or Mage_TargetDeBU("霜寒刺骨") then
                   if Mage_CastSpell("冰枪术") then  return true; end
                end
             end
            if targetIsPlayer or
                targetType == "worldboss" or
                ( targetType == "rareelite" and targetHP > 40 ) or
                ( targetType == "elite" and targetHP > 30 ) then
                    if not Mage_UnitTargetDeBU_ByPlayer("target", "活动炸弹") and IsSpellInRange("活动炸弹","target") == 1 then
                         if Mage_CastSpell("活动炸弹") then
                             Mage_Default_AddMessage("**施放活动炸弹 -> " .. UnitName("target") .. "**");
                             Mage_Combat_AddMessage("**施放活动炸弹 -> " .. UnitName("target") .. "**");
                             return true;
                             end
                    end
                    if CheckInteractDistance("target", 3)  then
                         if Mage_CastSpell("龙息术") then  return  true; end;
                         if Mage_CastSpell("冲击波") then  return  true; end;
                    end
                    if IsSpellInRange("灼烧","target") == 1 and not UnitInRaid("player") then
                        if not Mage_TargetDeBU("强化灼烧") and
                        not Mage_TargetDeBU("强化暗影箭")  and
                        not Mage_TargetDeBU("暗影掌握")  and
                        not Mage_TargetDeBU("深冬之寒") then
                            if Mage_CastSpell("灼烧") then  return true; end
                        end
                    end
            end
    elseif mageSpec == 0 then
		   if Mage_HasSpell("深度冻结") and Mage_GetSpellCooldown("深度冻结") == 0 and not Mage_TargetDeBU("霜寒刺骨") then
               if Mage_CastSpell("深度冻结") then  return true; end
           end

           if Mage_TargetDeBU("深度冻结") or Mage_TargetDeBU("霜寒刺骨") then
               if Mage_CastSpell("冰枪术") then  return true; end
           end

           if Mage_PlayerBU("寒冰指") and Mage_HasSpell("冰枪术") then
               if Mage_CastSpell("冰枪术") then  return true; end
           end
    end


    if UnitAffectingCombat("player") then
        local burst_switch = false;
        if Mage_PlayerBU("就是现在！") or Mage_PlayerBU("闪电之纹") then
            burst_switch = true;
        else
            if not Mage_TestTrinket("流放者的日晷") then
                burst_switch = true;
            end
        end

        -- ========================================================
        -- 镜像使用逻辑
        -- 场景：对抗玩家、世界BOSS、精英怪时，如果可用则使用
        -- ========================================================
        if burst_switch and Mage_HasSpell("镜像") and Mage_GetSpellCooldown("镜像") == 0 then
            local targetType = targetType;
            -- 如果目标是玩家，或者 目标是BOSS/精英/稀有
            if targetIsPlayer or
              targetType == "worldboss" or
              ( targetType == "rareelite" and targetHP > 40 ) or
              ( targetType == "elite" and targetHP > 40 ) then
                 if Mage_CastSpell("镜像") then
                     Mage_Combat_AddMessage("**遭遇强敌，开启镜像爆发...**");
                     return true;
                 end
            end
        end

        if targetIsPlayer then
            if Mage_HasSpell("燃烧") and Mage_GetSpellCooldown("燃烧") == 0 then
                if Mage_CastSpell("燃烧") then return true; end;
            end
            if Mage_HasSpell("狮心") and Mage_GetSpellCooldown("狮心") == 0 then
                if Mage_CastSpell("狮心") then return true; end;
            end
            if Mage_HasSpell("冰冷血脉") and Mage_GetSpellCooldown("冰冷血脉") == 0 then
                if Mage_CastSpell("冰冷血脉") then return true; end;
            end
        else
            if targetType == "worldboss" or ( targetType == "elite" and targetHP > 50 ) then
                if targetHP < 95 and burst_switch then
                    if Mage_HasSpell("燃烧") and Mage_GetSpellCooldown("燃烧") == 0 then
                        if Mage_CastSpell("燃烧") then return true; end;
                    end
                    if Mage_HasSpell("狮心") and Mage_GetSpellCooldown("狮心") == 0 then
                        if Mage_CastSpell("狮心") then return true; end;
                    end
                    if Mage_HasSpell("冰冷血脉") and Mage_GetSpellCooldown("冰冷血脉") == 0 then
                        if Mage_CastSpell("冰冷血脉") then return true; end;
                    end
                end
            end
        end

    end

    if Mage_PlayerBU("火球！") and IsSpellInRange("火球术","target") == 1 then
          if Mage_HasSpell("霜火之箭") then
               if Mage_CastSpell("霜火之箭") then  return true; end
          else
               if Mage_CastSpell("火球术") then  return true; end
          end
    end

	if Mage_TargetDeBU("冰霜新星")  and CheckInteractDistance("target",2) and GetTimer("变形术") > 2  then
		 if Mage_CastSpell("冰锥术") then  return true; end
	end

	if Mage_HasSpell("急速冷却") and Mage_GetSpellCooldown("冰霜新星") > 5 and  Mage_GetSpellCooldown("寒冰屏障") > 10 then
		if Mage_CastSpell("急速冷却") then  return true; end;
	end

	if UnitClass("target") == "法师" and targetHP > 90 and GetTimer("变形术_"..UnitName("target")) > 12 then
		if IsSpellInRange("变形术","target") == 1 then
			if not Mage_UnitTargetDeBU("target","变形术") then
                if not targetIsReflect and not targetIsImmuneControl then
				    if Mage_CastSpell("变形术") then return true; end;
                end
			end;
		end
	end

	if UnitClass("target") == "潜行者" and GetTimer("变形术") > 2 then
			if not UnitAffectingCombat("target")  then
				if  targetHP > 70 and GetTimer("变形术_"..UnitName("target")) > 12 then
					if IsSpellInRange("变形术","target") == 1 then
						if not Mage_UnitTargetDeBU("target","变形术") then
                            if not targetIsReflect and not targetIsImmuneControl then
							    if Mage_CastSpell("变形术") then return true; end;
                            end
						end;
					end
				else
					 if Mage_CastSpell("火焰冲击") then  return true; end;
		 			 if CheckInteractDistance("target",2) then
		 				if Mage_CastSpell("魔爆术") then  return true; end;
		 			 end
				end
			else
				if  targetHP > 90 and GetTimer("变形术_"..UnitName("target")) > 12 then
					if IsSpellInRange("变形术","target") == 1 then
						if not Mage_UnitTargetDeBU("target","变形术") then
                            if not targetIsReflect and not targetIsImmuneControl then
							    if Mage_CastSpell("变形术") then return true; end;
                            end
						end;
					end
				end
			end
	end;

	if targetIsPlayer and not Mage_TargetDeBU("冰霜新星")  and  IsSpellInRange("火焰冲击","target") == 1 and GetTimer("变形术") > 2 then
	    if Mage_CastSpell("火焰冲击") then return true; end
	end

	if not targetIsPlayer and targetHP < 5 and IsSpellInRange("火焰冲击","target") == 1 and GetTimer("变形术") > 2 then
        if Mage_CastSpell("火焰冲击") then return true; end
	end

	if CheckInteractDistance("target",3) and GetTimer("变形术") > 2 then
        if mageSpec == 1  then
             if Mage_CastSpell("龙息术") then  return  true; end;
             if Mage_CastSpell("冲击波") then  return  true; end;
        end
		if UnitIsPlayer("target") then
 		   if not Mage_TargetDeBU("冰霜新星") then
 				 if Mage_CastSpell("冰霜新星") then return true; end;
 		   end;
		else
            if Test_Target_IsMe() then
                   if not Mage_TargetDeBU("冰霜新星") then
                         if Mage_CastSpell("冰霜新星") then return true; end;
                   end;
            end;
		end
     end

	if not Mage_Check_Movement() then
        if mageSpec == 1 then
            if Mage_CastSpell("霜火之箭") then return true; end
        elseif mageSpec == 0 then
		    if Mage_CastSpell("寒冰箭") then return true; end
		end
		Mage_SetText("无动作",0);
		return;
	else
        if mageSpec == 1 and CheckInteractDistance("target", 3)  then
             if Mage_CastSpell("龙息术") then  return  true; end;
             if Mage_CastSpell("冲击波") then  return  true; end;
        end
	    if not Mage_TargetDeBU("冰霜新星") and GetTimer("变形术") > 2 then
			if UnitAffectingCombat("player")  and  IsSpellInRange("火焰冲击","target") == 1 then
                if Mage_CastSpell("火焰冲击") then return true; end
			end
			if CheckInteractDistance("target", 3)  then
				if Mage_CastSpell("魔爆术") then  return  true; end;
			end
	    end;
		Mage_SetText("移动中",0);
		return;
	end

	if not Mage_Check_Movement() then
		Mage_SetText("无动作",0);
		return;
	else
		Mage_SetText("移动中",0);
		return;
	end
end;

function Mage_Interrupt_Casting()
    if UnitExists("target") and Mage_GetSpellCooldown("法术反制") == 0 then
        -- 基础检查：不死、可见、敌对、在射程内
        if not UnitIsDead("target") and UnitIsVisible("target") and UnitCanAttack("player","target") and IsSpellInRange("法术反制","target") == 1 then

            -- 获取读条信息
            local spellname = UnitCastingInfo("target")
            if not spellname then
                spellname = UnitChannelInfo("target") -- 同时也检查引导法术（如唤醒、苦修）
            end

            if spellname then
                -- 1. 猎人读条通常不打断 (稳固/眼镜蛇无威胁且频率高)
                if string.find(spellname,"稳固射击") or string.find(spellname,"眼镜蛇射击") then
                    return false;
                end

                -- 2. 尝试执行打断
                if UnitIsPlayer("target") then
                    -- PVP逻辑：如果是玩家，直接尝试打断 (移除了只打断法师变形术的限制，改为全打断)
                    -- 如果您只想打断特定法术，请在这里恢复之前的 if string.find... 逻辑
                    if Mage_do_Interrupt_Casting(spellname) then return true; end;
                else
                    if not Mage_ImmuneSpell() then
                        if Mage_do_Interrupt_Casting(spellname) then return true; end;
                    end;
                end;
            end
        end
    end;
    return false;
end;

function Mage_do_Interrupt_Casting(spellname)
	if UnitClassification("target") ~= "worldboss" then
		if Mage_UnitTargetBU("target","不灭决心") then
			Mage_Default_AddMessage("**目标>>"..UnitName("target").."<<正在施放"..spellname..",但免疫打断【不灭决心】...**");
			Mage_Combat_AddMessage("**目标>>"..UnitName("target").."<<正在施放"..spellname..",但免疫打断【不灭决心】...**");
			return false;
		end
		if Mage_UnitTargetBU("target","虔诚光环") then
			Mage_Default_AddMessage("**目标>>"..UnitName("target").."<<正在施放"..spellname..",但免疫打断【虔诚光环】...**");
			Mage_Combat_AddMessage("**目标>>"..UnitName("target").."<<正在施放"..spellname..",但免疫打断【虔诚光环】...**");
			return false;
		end
		if Mage_CastSpell("法术反制") then
			Mage_Combat_AddMessage("**目标>>"..UnitName("target").."<<正在施放"..spellname..",使用法术反制...**");
			Mage_Default_AddMessage("**目标>>"..UnitName("target").."<<正在施放"..spellname..",使用法术反制...**");
			return true;
		end;
	end
	return false;
end;


function Mage_AutoSelectTarget()
    if Mage_GetAutoMode() then
        if UnitExists("target") and UnitCanAttack("player","target") and UnitHealth("target") > 0 then
            return false;
        end
        if not UnitAffectingCombat("player")  then
             return false;
        end
        if Mage_TargetEnemy() then return true; end;
    end
    return false;
end


-- ========================================================
-- [新增] PVP 高价值法术名单 (只针对能显著改变战局的魔法)
-- ========================================================
local Mage_PVP_HighValue_Magic = {
    -- 圣骑士
    ["自由之手"] = true, ["牺牲之手"] = true,  ["复仇之怒"] = true, ["神圣启示"] = true, ["保护之手"] = true,
    -- 牧师
    ["能量灌注"] = true, ["真言术：盾"] = true, ["真言术：韧"] = true, ["坚韧祷言"] = true,
    -- 法师
    ["寒冰护体"] = true, ["法术连击"] = true, ["奥术强化"] = true, ["气定神闲"] = true,
    -- 德鲁伊/萨满
    ["激活"] = true, ["自然迅捷"] = true, ["嗜血"] = true, ["英勇"] = true,
    ["嗜血"] = true, ["英勇"] = true, ["自然迅捷"] = true, ["激活"] = true, ["潮汐之力"] = true,
}

function Mage_ScanTargetBuffs(Unit)
    if not UnitIsPlayer(Unit) then return Mage_ScanUnitMagicBuff(Unit) end
    local i = 1;
    while (true) do
        -- 使用系统 UnitBuff 接口获取信息
        local name, icon, count, debuffType = UnitBuff(Unit, i);
        if not name then break end

        -- 判定逻辑：必须是可驱散的魔法类型，且在我们的高价值白名单内
        if (debuffType == Mage_MAGIC) then
            if (Mage_PVP_HighValue_Magic[name]) then
                return true, name; -- 命中关键 Buff，返回 true
            end
        end
        i = i + 1
    end
    return false, nil;
end

-- ========================================================
-- 函数：Mage_FocusControl
-- 逻辑：
-- 1. 检查焦点目标是否可变羊（根据剩余时间补羊）
-- 2. 如果无法变羊（免疫/反射/非生物），则尝试法术反制打断
-- ========================================================
function Mage_FocusControl()
    if not UnitExists("focus") or UnitIsDead("focus") or not UnitCanAttack("player", "focus") then
        return false
    end

    if UnitExists("target") and UnitIsUnit("target", "focus") then  return false; end

    if Mage_Test_Target_Debuff("focus") then
        if UnitExists("pet") and not UnitIsDead("pet") then
            if Mage_IsPetAttacking() and UnitIsUnit("pettarget","focus") then
                 if Mage_StopPetAttack() then  return true; end
            end
        end
        -- 获取焦点身上自己施放的变形术剩余时间
        local polyTime = Mage_GetDeBuffTimeByName("focus", "变形术")
        if polyTime == 0 then
            if GetTimer("焦点已经被控制") > 2 then
               StartTimer("焦点已经被控制");
               Mage_Default_AddMessage(UnitName("focus").."焦点已经被控制...");
               Mage_Combat_AddMessage(UnitName("focus").."焦点已经被控制...");
           end;
           return false;
        else
             -- 判定补羊时间：玩家1秒，非玩家5秒
            local threshold = isPlayer and 2 or 10
            if polyTime >= threshold then
                if GetTimer("焦点已经被控制") > 3 then
                    StartTimer("焦点已经被控制");
                    Mage_Combat_AddMessage(UnitName("focus").."焦点已经被控制(" .. string.format("%.1f", polyTime) .. ")");
                end;
                return false;
            end
        end
    end

    -- ========================================================
    -- [优化] 战斗中的法术反射处理
    -- 使用之前获取的 targetIsReflect 状态
    -- ========================================================
    local targetIsReflect, targetIsImmuneControl  = Mage_ScanTargetStatus("focus")

    if not Mage_Check_Movement() then
        local creatureType = UnitCreatureType("focus")
        if creatureType == "人型生物" or creatureType == "野兽" then
            if IsSpellInRange("变形术","focus") == 1  then
                if targetIsReflect then
                    Mage_Combat_AddMessage("**焦点>>"..UnitName("focus").."<<存在反射效果，无法施放变形术...**");
                    Mage_Default_AddMessage("**焦点>>"..UnitName("focus").."<<存在反射效果，无法施放变形术...**");
                else
                    -- 既无反射也无免疫，执行变羊
                    if not Mage_Check_Dot_Debuff("focus") then
                        if UnitExists("pet") and not UnitIsDead("pet") then
                            if Mage_IsPetAttacking() and UnitIsUnit("pettarget","focus") then
                                 if Mage_StopPetAttack() then  return true; end
                            end
                        end
                        if Mage_CastFocusPolymorph() then
                            Mage_Combat_AddMessage("**对焦点>>"..UnitName("focus").."<<施放变形术...**");
                            Mage_Default_AddMessage("**对焦点>>"..UnitName("focus").."<<施放变形术...**");
                            return true;
                        end;
                    else
                         Mage_Combat_AddMessage("**焦点>>"..UnitName("focus").."<<目标有持续伤害效果，无法施放变形术...**");
                         Mage_Default_AddMessage("**焦点>>"..UnitName("focus").."<<目标有持续伤害效果，无法施放变形术...**");
                    end
                end
            else
                if GetTimer("焦点距离太远") > 1 then
                       StartTimer("焦点距离太远");
                       Mage_Default_AddMessage("**焦点距离太远,变形术无法施放**");
                       Blizzard_AddMessage("**焦点距离太远,变形术无法施放**",1,0,0,"crit");
                end;
            end
        else
            if GetTimer("非人型生物和野兽") > 1 then
                   StartTimer("非人型生物和野兽");
                   Mage_Default_AddMessage("**焦点>>"..UnitName("focus").."<<非人型生物和野兽，无法施放变形术...**");
                   Blizzard_AddMessage("**焦点>>"..UnitName("focus").."<<非人型生物和野兽，无法施放变形术...**",1,0,0,"crit");
            end;
        end
    end

    -- 焦点打断逻辑 (当无法变羊或不需要变羊时)
    if Mage_GetSpellCooldown("法术反制") == 0 and IsSpellInRange("法术反制", "focus") == 1 then
        local spellName = UnitCastingInfo("focus") or UnitChannelInfo("focus")
        if spellName then
            if Mage_CastFocusInterruptCasting() then
                Mage_Combat_AddMessage("**焦点>>" .. focusName .. "<<正在施放" .. spellName .. ",使用法术反制...**")
                Mage_Default_AddMessage("**焦点>>" .. focusName .. "<<正在施放" .. spellName .. ",使用法术反制...**")
                return true
            end
        end
    end

    return false
end