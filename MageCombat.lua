
function Mage_playerCombat()

    if Mage_Polymorph == 1 then
        if UnitAffectingCombat("player") then
            if GetTimer("Mage_Polymorph") > 2 then  Mage_Default_AddMessage("**变形术命令超时...**"); Mage_Polymorph = 0; end;
        else
            if GetTimer("Mage_Polymorph") > 15 then  Mage_Default_AddMessage("**变形术命令超时...**"); Mage_Polymorph = 0; end;
        end
        if not Mage_Check_Movement() then
            if IsSpellInRange("变形术","target") == 1  then
                if Mage_UnitTargetBU("target","法术反射") or
                   Mage_UnitTargetBU("target","魔法反射") or
                   Mage_UnitTargetBU("target","群体反射") then
                    Mage_Combat_AddMessage("**目标>>"..UnitName("target").."<<存在反射效果，无法施放变形术...**");
                end;
                if Mage_UnitTargetBU("target","反魔法盾") or
                   Mage_UnitTargetBU("target","暗影斗蓬") then
                    Mage_Combat_AddMessage("**对目标>>"..UnitName("target").."<<存在免疫效果，无法施放变形术...**");
                end;
                if  not Mage_UnitTargetBU("target","法术反射") and
                    not Mage_UnitTargetBU("target","群体反射") and
                    not Mage_UnitTargetBU("target","魔法反射") and
                    not Mage_UnitTargetBU("target","反魔法盾") and
                    not Mage_UnitTargetBU("target","暗影斗蓬") then
                        if UnitExists("pet") and not UnitIsDead("pet") then
                            if Mage_IsPetAttacking() then
                                 if Mage_StopPetAttack() then  return true; end
                            end
                        end
                        if Mage_CastSpell("变形术") then return true; end;
                end;
            else
                if GetTimer("变形术目标距离太远") > 0.5 then
                      StartTimer("变形术目标距离太远");
                      Blizzard_AddMessage("**目标距离太远，无法施放变形术**",1,0,0,"crit");
                end;
                Mage_SetText("变形术距离太远",0);
                return;
            end
        end
        Mage_SetText("等待变形术",0);
        return;
    end

	if not UnitAffectingCombat("player") and not UnitAffectingCombat("target")  then
		if  UnitCreatureType("target") == "野生宠物" then
			    Mage_SetText("野生宠物",0);
			    return true;
		end;
		if  UnitClassification("target") == "rareelite"  then
			    Mage_SetText("稀有精英",0);
			    return true;
		end;
		if  UnitClassification("target") == "worldboss" or  UnitClassification("target") == "elite" then
				 Mage_SetText("精英目标",0);
			    return true;
		end
	end;


    if IsInInstance() and not UnitIsPlayer("target") and not Test_Target_IsMe()  then
		if  UnitClassification("target") == "worldboss" or UnitClassification("target") == "elite" then
			if UnitHealth("target") == UnitHealthMax("target") then
			    Mage_SetText("副本中绝不先手",0);
			    return true;
			end
		end
	end

	if  UnitIsPlayer("target") then
		if UnitClass("target") == "法师" or UnitClass("target") == "圣骑士" then
			if IsSpellInRange("侦测魔法","target") == 1 then
				    if not Mage_TargetDeBU("侦测魔法")  then
				 		if Mage_CastSpell("侦测魔法") then return true; end;
				    end;
			end;
		end
	else
		if IsSpellInRange("侦测魔法","target") == 1  then
			if UnitClassification("target") == "worldboss" then
			    if not Mage_TargetDeBU("侦测魔法")  then
			 		if Mage_CastSpell("侦测魔法") then return true; end;
			    end;
			end;
		end;
	end

	if IsSpellInRange("寒冰箭","target") == 0 then
		Mage_SetText("距离过远",0);
		return;
	end;

	if UnitExists("pet") and not UnitIsDead("pet") then
        if not Mage_IsPetAttacking() then
             if Mage_PetAttack() then  return true; end
        end
    end

    if UnitAffectingCombat("player") and not UnitExists("pet") and Mage_HasSpell("召唤水元素") and Mage_GetSpellCooldown("召唤水元素") == 0 then
        if Mage_CastSpell("召唤水元素") then return true; end;
    end

	if Mage_Interrupt_Casting() then return true; end;

    if Mage_PlayerBU("寒冰指") and Mage_HasSpell("冰枪术") then
        if Mage_CastSpell("冰枪术") then  return true; end
    end

    if Mage_HasSpell("法术吸取") and Mage_IsManaEnough("法术吸取") then
        -- 利用 MageDecursive.lua 中的函数扫描目标身上是否有 Magic 类型的 Buff
        local hasMagicBuff, buffName = Mage_ScanUnitMagicBuff("target");

        if hasMagicBuff then
            -- 如果有可偷取的魔法Buff，执行偷取
            if Mage_CastSpell("法术吸取") then
                Mage_Combat_AddMessage("**发现目标增益 [".. buffName .."] -> 使用法术吸取**");
                Mage_Default_AddMessage("**偷取目标Buff: [".. buffName .."]**");
                return true;
            end
        end
    end


    if UnitClassification("player") and UnitClassification("target") then
        if UnitIsPlayer("target") then
            if Mage_HasSpell("狮心") and Mage_GetSpellCooldown("狮心") == 0 then
                if Mage_CastSpell("狮心") then return true; end;
            end
            if Mage_HasSpell("冰冷血脉") and Mage_GetSpellCooldown("冰冷血脉") == 0 then
                if Mage_CastSpell("冰冷血脉") then return true; end;
            end
        else
            if UnitClassification("target") == "worldboss" or UnitClassification("target") == "elite" then
                if Mage_GetUnitHealthPercent("target") < 90 then
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

	if Mage_GetSpellCooldown("冰霜新星") > 5 and  Mage_GetSpellCooldown("寒冰屏障") > 10 then
		if Mage_CastSpell("急速冷却") then  return true; end;
	end

	if UnitClass("target") == "法师" and Mage_GetUnitHealthPercent("target") > 90 and GetTimer("变形术_"..UnitName("target")) > 12 then
		if IsSpellInRange("变形术","target") == 1 then
			if not Mage_UnitTargetDeBU("target","变形术") then
				if Mage_CastSpell("变形术") then return true; end;
			end;
		end
	end

	if UnitClass("target") == "潜行者" and GetTimer("变形术") > 2 then
			if not UnitAffectingCombat("target")  then
				if  Mage_GetUnitHealthPercent("target") > 70 and GetTimer("变形术_"..UnitName("target")) > 12 then
					if IsSpellInRange("变形术","target") == 1 then
						if not Mage_UnitTargetDeBU("target","变形术") then
							if Mage_CastSpell("变形术") then return true; end;
						end;
					end
				else
					 if Mage_CastSpell("火焰冲击") then  return true; end;
		 			 if CheckInteractDistance("target",2) then
		 				if Mage_CastSpell("魔爆术") then  return true; end;
		 			 end
				end
			else
				if  Mage_GetUnitHealthPercent("target") > 90 and GetTimer("变形术_"..UnitName("target")) > 12 then
					if IsSpellInRange("变形术","target") == 1 then
						if not Mage_UnitTargetDeBU("target","变形术") then
							if Mage_CastSpell("变形术") then return true; end;
						end;
					end
				end
			end
	end;

	if UnitIsPlayer("target") and not Mage_TargetDeBU("冰霜新星")  and  IsSpellInRange("火焰冲击","target") == 1 and GetTimer("变形术") > 2 then
	    if Mage_CastSpell("火焰冲击") then return true; end
	end

	if not UnitIsPlayer("target") and Mage_GetUnitHealthPercent("target") < 95 and IsSpellInRange("火焰冲击","target") == 1 and GetTimer("变形术") > 2 then
		if  UnitClassification("target") == "worldboss" or UnitClassification("target") == "elite" then
            if Mage_CastSpell("火焰冲击") then return true; end
		end
	end

	if UnitHealthMax("target") == 100 then
		if Mage_GetUnitHealthPercent("target") < 2 and IsSpellInRange("火焰冲击","target") == 1 and GetTimer("变形术") > 2  then
            if Mage_CastSpell("火焰冲击") then return true; end
			if CheckInteractDistance("target",3) then
				if Mage_CastSpell("魔爆术") then  return  true; end;
			end
		end
	else
		if UnitHealth("target") < 300 and  IsSpellInRange("火焰冲击","target") == 1 and GetTimer("变形术") > 2  then
            if Mage_CastSpell("火焰冲击") then return true; end
			if CheckInteractDistance("target",3) then
				if Mage_CastSpell("魔爆术") then  return  true; end;
			end
		end
	end


	if CheckInteractDistance("target",3) and GetTimer("变形术") > 2 then
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
		if Mage_CastSpell("寒冰箭") then return true; end
		Mage_SetText("无动作",0);
		return;
	else
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
                    if not Mage_ImmuneSpell(spellname) then
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
