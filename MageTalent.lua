Mage_TalentMode_Hit = "我是冰法模式"
Mage_AutoMode_Hit = "自动选择目标模式"

local Mage_AutoMode = true;
local Mage_TalentMode = 0;
  
function Mage_TalentMode_OnUpdate()
    if UnitClass("player") ~= "法师" then
		HideUIPanel(MageTalentModeBtn);
		return 
	end
end

function Mage_Get_TalentMode()
	return Mage_TalentMode;
end	
 
function Mage_TalentMode_fun()
	 if Mage_TalentMode == 0 then
		Mage_TalentMode = 1;
		Blizzard_AddMessage("**转换为火法模式**",1,0,0,"crit");
		Mage_Default_AddMessage("**转换为火法模式**");
		Mage_TalentMode_Hit = "火法模式";
		MageTooltip:SetText(Mage_TalentMode_Hit);
		MageTalentModeBtn:SetNormalTexture("Interface\\Icons\\Spell_Holy_DevotionAura");
     elseif Mage_TalentMode == 1 then
            Mage_TalentMode = 2;
            Blizzard_AddMessage("**转换为奥法模式**",1,0,0,"crit");
            Mage_Default_AddMessage("**转换为奥法模式**");
            Mage_TalentMode_Hit = "奥法模式";
            MageTooltip:SetText(Mage_TalentMode_Hit);
            MageTalentModeBtn:SetNormalTexture("Interface\\Icons\\Spell_Holy_AuraOfLight");
	 else
		Mage_TalentMode = 0;
		Blizzard_AddMessage("**转换为冰法模式**",1,0,0,"crit");
	    Mage_Default_AddMessage("**转换为冰法模式**");
	    Mage_TalentMode_Hit = "冰法模式";
		MageTooltip:SetText(Mage_TalentMode_Hit);
		MageTalentModeBtn:SetNormalTexture("Interface\\Icons\\Spell_Holy_LayOnHands");
	 end
end



  
function Mage_AutoMode_OnUpdate()
    if UnitClass("player") ~= "法师" then
		HideUIPanel(MageAutoModeBtn);
		return 
	end
end

function Mage_GetAutoMode()
	return Mage_AutoMode;
end	
 
function Mage_AutoMode_fun()
	 if Mage_AutoMode then
		Mage_AutoMode = false;
		Blizzard_AddMessage("**转换手动选择目标模式**",1,0,0,"crit");
		Mage_Default_AddMessage("**转换手动选择目标模式**");
		Mage_AutoMode_Hit = "手动选择目标模式";
		MageTooltip:SetText(Mage_AutoMode_Hit);
		MageAutoModeBtn:SetNormalTexture("Interface\\Icons\\Inv_Misc_QuestionMark");
	 else
		Mage_AutoMode = true;
		Blizzard_AddMessage("**转换自动选择目标模式**",1,0,0,"crit");
	    Mage_Default_AddMessage("**转换为自动选择目标模式**");
	    Mage_AutoMode_Hit = "自动选择目标模式";
		MageTooltip:SetText(Mage_AutoMode_Hit);
		MageAutoModeBtn:SetNormalTexture("Interface\\Icons\\Ability_Seal");
	 end
end