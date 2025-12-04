Mage_AntiOffLine_Hit = "关闭防掉线模式"

local Mage_IsAntiOffLineMode = true; --是否为防掉线模式
 
function Mage_AntiOffLine_OnUpdate()
    if UnitClass("player") ~= "法师" then
		HideUIPanel(MageAntiOffLineBtn);
		return 
	end
    if Mage_IsAntiOffLineMode then
		if not MageAntiOffLineBtn:GetChecked() then
	        MageAntiOffLineBtn:SetChecked(true)
		end
	else
		if MageAntiOffLineBtn:GetChecked() then
	        MageAntiOffLineBtn:SetChecked(false)
		end
    end
end

function Mage_Get_AntiOffLineMode()
	return Mage_IsAntiOffLineMode;
end	

function Mage_AntiOffLine()
	if Mage_Get_AntiOffLineMode() and not UnitAffectingCombat("player") then
		if GetTimer("AntiOffLine") < 0.5 then
            if Mage_CastSpell("造水术") then return true; end;
-- 			Mage_SetText("跳跃",200);
			return true;
		end;
		if GetTimer("AntiOffLine") > 100 then
-- 			Mage_SetText("跳跃",200);
            if Mage_CastSpell("造水术") then return true; end;
			StartTimer("AntiOffLine");
			return true;
		end
        if GetTimer("魔法纯净水") < 0.5 then
            if Mage_CastSpell("魔法纯净水") then return true; end;
            return true;
        end;
        if GetTimer("魔法纯净水") > 10 then
            if Mage_CastSpell("魔法纯净水") then return true; end;
            StartTimer("魔法纯净水");
            return true;
        end
	end
	return false;
end	
	 
function Mage_AntiOffLine_fun()
	 if Mage_IsAntiOffLineMode then
		Mage_IsAntiOffLineMode = false;
		Blizzard_AddMessage("**关闭防掉线模式**",1,0,0,"crit");
		Mage_Default_AddMessage("**关闭防掉线模式**");
		Mage_AntiOffLine_Hit = "关闭防掉线模式";
		MageTooltip:SetText(Mage_AntiOffLine_Hit);
	 else
		Mage_IsAntiOffLineMode = true;
		Blizzard_AddMessage("**打开防掉线模式**",1,0,0,"crit");
		Mage_Default_AddMessage("**打开防掉线模式**");
		Mage_AntiOffLine_Hit = "防掉线模式";
		MageTooltip:SetText(Mage_AntiOffLine_Hit);
	 end
end

 