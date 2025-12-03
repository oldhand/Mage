Mage_CombatLog_Hit = "关闭战斗记录模式"

local Mage_IsCombatLogMode = true; --是否为打开战斗记录模式
 
function Mage_CombatLog_OnUpdate()
    if UnitClass("player") ~= "法师" then
		HideUIPanel(MageCombatLogBtn);
		return 
	end
    if Mage_IsCombatLogMode then
		if not MageCombatLogBtn:GetChecked() then
	        MageCombatLogBtn:SetChecked(true)
		end
	else
		if MageCombatLogBtn:GetChecked() then
	        MageCombatLogBtn:SetChecked(false)
		end
    end
end

function Mage_Get_CombatLogMode()
	return Mage_IsCombatLogMode;
end	
	 
function Mage_CombatLog_fun()
	 if Mage_IsCombatLogMode then
		Mage_IsCombatLogMode = false;
		Blizzard_AddMessage("**关闭战斗记录模式**",1,0,0,"crit");
		Mage_Default_AddMessage("**关闭战斗记录模式**");
		Mage_CombatLog_Hit = "关闭战斗记录模式";
		MageTooltip:SetText(Mage_CombatLog_Hit);
	 else
		Mage_IsCombatLogMode = true;
		Blizzard_AddMessage("**打开战斗记录模式**",1,0,0,"crit");
		Mage_Default_AddMessage("**打开战斗记录模式**");
		Mage_CombatLog_Hit = "战斗记录模式";
		MageTooltip:SetText(Mage_CombatLog_Hit);
	 end
end

 