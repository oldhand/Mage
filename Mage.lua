
local Mage_Data = nil;
Mage_SaveData = nil;
Mage_Settings = nil;
Mage_Icons = nil;

local ChatEditBox = nil;

local Mage_movement = false;


local Mage_Polymorph = 0; --  变形术
local Mage_Blizzard = 0; --  暴风雪
local Mage_Teleport = 0; --  闪现术
local Mage_Purge = 0; --  唤醒

function Mage_Check_Movement()
	return Mage_movement;
end

function Mage_RegisterEvents(self)
	if UnitClass("player") ~= "法师" then
		HideUIPanel(Mage_MSG_Frame);
		HideUIPanel(PaladinMainFrame);
		HideUIPanel(PaladinSettingBtn);
		return;
	end;
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD");		
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("CHARACTER_POINTS_CHANGED");
    self:RegisterEvent("PLAYER_STARTED_MOVING");
    self:RegisterEvent("PLAYER_STOPPED_MOVING");
	self:RegisterEvent("SPELLS_CHANGED"); 
	self:RegisterEvent("ADDON_LOADED");

	HideUIPanel(UIErrorsFrame);		
end;


function Mage_OnEvent(event)
	if UnitClass("player") ~= "法师" then return; end;
	if (event=="PLAYER_ENTERING_WORLD") then
		Mage_Data = {};
		Mage_Data[UnitName("player")] =
					{			
					Paladin={},
					};
					
		if Mage_SaveData == nil then
			Mage_SaveData = {};
		end 
		if Mage_Settings == nil then
			Mage_Settings = {};
		end 
		if Mage_Icons == nil then
			Mage_Icons = {};
		end 
		
		DEFAULT_CHAT_FRAME:AddMessage("智能施法插件 2.0 (法师泰坦重铸) oldhand 版权所有");
		Mage_SetText("插件加载中...",0)
		ChatFrame_RemoveMessageGroup(ChatFrame1, "CHANNEL")
		Mage_OrganizeActionBar();
		SetCVar("cameraDistanceMax", 30)
		SaveBindings(GetCurrentBindingSet())
		
	elseif event == "PLAYER_REGEN_DISABLED" then
	     Mage_AddMessage("进入战斗状态");
		 StartTimer("UnitAffectingCombat");
	elseif event == "PLAYER_REGEN_ENABLED" then
	     Mage_AddMessage("脱离战斗状态");
	     StartTimer("NotUnitAffectingCombat");
 	elseif event == "PLAYER_STARTED_MOVING" then
 	   	 Mage_movement = true;
 	   	 if Mage_Get_AntiOffLineMode() then
            Mage_AntiOffLine_fun();
         end
 	elseif event == "PLAYER_STOPPED_MOVING" then
 	     Mage_movement = false;
	elseif event == "CHARACTER_POINTS_CHANGED" or event == "SPELLS_CHANGED" then
		Mage_OrganizeActionBar();
	elseif event=="ADDON_LOADED" then
		Mage_OrganizeActionBar();
	end
end;



function getChatEditBox()
	if ChatFrameEditBox ~= nil then
		ChatEditBox = ChatFrameEditBox;
	elseif ChatFrame1EditBox ~= nil then
		ChatEditBox = ChatFrame1EditBox;
	end;
end;


function Mage_SendCommand(flag)
	if flag == 1 then
        if  UnitExists("target") and UnitCanAttack("player", "target") then
            Mage_Polymorph = 1;
            Mage_Combat_AddMessage("**准备使用变形术...**");
            StartTimer("Mage_Polymorph");
        else
            Mage_Combat_AddMessage("**没有敌对目标，无法变形术**");
		end
	elseif flag == 2 then
		 if Mage_GetSpellCooldown("闪现术") == 0 then
		 	 Mage_Combat_AddMessage("准备闪现术..");
	 		 StartTimer("Mage_Teleport");
			 Mage_Teleport = 1;
		 else
			 Mage_AddMessage("**闪现术CD中**");
			 Mage_Combat_AddMessage("**闪现术CD中**");
		 end;
  	elseif flag == 3 then
		if UnitAffectingCombat("player") then
			if Mage_GetUnitManaPercent("player") < 50 then
				if Mage_GetSpellCooldown("唤醒") == 0 then
		   		 	 Mage_Combat_AddMessage("准备唤醒..");
		   	 		 StartTimer("Mage_Purge");
		   			  Mage_Purge = 1;
		   		 else
		   			 Mage_AddMessage("**唤醒CD中**");
		   			 Mage_Combat_AddMessage("**唤醒CD中**");
		   		 end;
			else
   			 Mage_AddMessage("**蓝还比较多，不需要唤醒**");
   			 Mage_Combat_AddMessage("**蓝还比较多，不需要唤醒**");
			end
		else
			 Mage_AddMessage("**没有进入战斗，不需要唤醒**");
			 Mage_Combat_AddMessage("**没有进入战斗，不需要唤醒**");
		end
    elseif flag == 4 then
      if Mage_IsManaEnough("暴风雪") then
          local castspell = Mage_GetPlayerCasting()
          if castspell then
              if string.find(castspell, "暴风雪") then
                 local RemainingTime =  Mage_GetCastRemainingTime("player");
                 if RemainingTime > 2 then
                      Mage_Blizzard = 0;
                      Mage_Combat_AddMessage("**正在施放暴风雪(" .. string.format("%.1f", RemainingTime) .. ")...**");
                      return;
                  end
              end;
          end
         Mage_Blizzard = 1;
         Mage_Combat_AddMessage("**准备使用鼠标位置使用暴风雪...**");
         StartTimer("Mage_Blizzard");
      else
         Mage_Combat_AddMessage("**暴风雪不可用，蓝量不够**");
         Mage_Blizzard = 0;
      end
    end
end;

function Mage_Frame_OnUpdate()
	if UnitClass("player") ~= "法师" then return; end;

	if ChatEditBox ~= nil then
		if (ChatEditBox:IsShown()) then
			Mage_SetText("聊天状态",0);
			return;	
		end;
	else
		getChatEditBox();
	end;  
	
	if UnitIsDeadOrGhost("player")  then
		Mage_SetText("阵亡状态",0);
		return; 
	end

    if IsFalling() then
		if not Mage_PlayerBU("缓落术") and GetTimer("Mage_parachute_cloak") > 2 then
			if Mage_CastSpell("缓落术") then  return true; end;
		end;
	else
		StartTimer("Mage_parachute_cloak");
	end;


	if UnitOnTaxi("player") == 1 then Mage_SetText("航线飞行中",0); return; end;

	if Mage_PlayerDeBU("威慑凝视")  then
		if GetTimer("威慑凝视") > 1 then				
			StartTimer("威慑凝视");				
			Mage_Default_AddMessage("**威慑凝视**");
			Mage_Combat_AddMessage("**威慑凝视，停止施法**");
		end; 
		Mage_SetText("威慑凝视",0);
		return;
	end;

    local castspell = Mage_GetPlayerCasting()

    if castspell then
        if string.find(castspell, "寒冰箭") then
            Mage_SetText("正在施放"..castspell,0);
            if Mage_GetCastRemainingTime("player") > 0.3 then return; end
        elseif string.find(castspell, "暴风雪") then
           if Mage_GetCastRemainingTime("player") > 0.5 then
                Mage_Blizzard = 0;
                Mage_SetText("正在施放"..castspell,0);
               return;
            end
        else
            Mage_SetText("正在施放"..castspell,0);
            return;
        end;
    end

-- 	if Mage_AutoMount() then return; end
--
-- 	if Mage_AutoDrinkAndMounted() then return; end

	if IsMounted() then
		Mage_SetText("骑乘状态",0);
		return;
	end;
	
	if not UnitAffectingCombat("player") then
        if  Mage_PlayerBU("饮用") or Mage_PlayerBU("喝水") then
            if not Mage_Get_AntiOffLineMode() then
                Mage_SetText("喝水中",0);
                return ;
            end
        end
	end; 

	if not UnitAffectingCombat("player") and Mage_PlayerBU("进食") then
        if not Mage_PlayerBU("进食充分") then
		    Mage_SetText("进食中",0);
		    return ;
		end
	end;
	-- 检测晕迷类 (人类自利主要解这个)
    if  Mage_PlayerDeBU("制裁之锤")
        or Mage_PlayerDeBU("肾击")
        or Mage_PlayerDeBU("偷袭")
        or Mage_PlayerDeBU("猛击")
        or Mage_PlayerDeBU("震荡猛击")
        or Mage_PlayerDeBU("暗影狂怒")
        or Mage_PlayerDeBU("拦截")
        or Mage_PlayerDeBU("致盲")
        or Mage_PlayerDeBU("变形术")
        or Mage_PlayerDeBU("深结")
        or Mage_PlayerDeBU("晕迷")
        -- 检测原有的恐惧/魅惑类 (保留)
        or Mage_PlayerDeBU("心灵尖啸")
        or Mage_PlayerDeBU("精神控制")
        or Mage_PlayerDeBU("恐惧")
        or Mage_PlayerDeBU("惊骇")
        or Mage_PlayerDeBU("恐惧嚎叫")
        or Mage_PlayerDeBU("恐吓尖啸")
        or Mage_PlayerDeBU("恐吓")
        or Mage_PlayerDeBU("女妖媚惑")
        or Mage_PlayerDeBU("破胆怒吼")
        or Mage_PlayerDeBU("震耳尖啸")
        or Mage_PlayerDeBU("媚惑")
        or Mage_PlayerDeBU("魅惑")
    then
        if Mage_CastSpell("生存意志") then
           StartTimer("生存意志");
           if Mage_Get_CombatLogMode() then
              Mage_AddMessage("检测到硬控/恐惧 -> 使用生存意志解控");
           end
           return true;
        end
    end;

	if  Mage_PlayerDeBU("心灵尖啸")
			   or  Mage_PlayerDeBU("精神控制")
			   or  Mage_PlayerDeBU("恐惧")
			   or  Mage_PlayerDeBU("恐惧嚎叫")
			   or  Mage_PlayerDeBU("恐吓尖啸")
			   or  Mage_PlayerDeBU("恐吓")
			   or  Mage_PlayerDeBU("女妖媚惑")
			   or  Mage_PlayerDeBU("破胆怒吼")
			   or  Mage_PlayerDeBU("震耳尖啸")
			   or  Mage_PlayerDeBU("媚惑")
			   or  Mage_PlayerDeBU("魅惑")
			   then	
		if Mage_CastSpell("亡灵意志") then
			StartTimer("亡灵意志"); 
			if Mage_Get_CombatLogMode() then
				Mage_AddMessage("使用亡灵意志");
			end 
			return true; 
		end
	end; 

	if GetTimer("亡灵意志") > 1 and not Mage_PlayerBU("亡灵意志") then
		if Mage_Use_INV_Jewelry_TrinketPVP() then return true end;
	end;

	if Mage_Teleport == 1 then
            if GetTimer("Mage_Teleport") > 2 then  Mage_Default_AddMessage("**闪现术命令超时...**"); Mage_Teleport = 0; end;
            if Mage_GetSpellCooldown("闪现术") ~= 0 then
                 Mage_Teleport = 0;
            end;
            if Mage_CastSpell("闪现术") then return true; end;
    end
	if Mage_playerSafe() then return true end;

    if Mage_Purge == 1 then
            if GetTimer("Mage_Purge") > 2 then  Mage_Default_AddMessage("**唤醒命令超时...**"); Mage_Purge = 0; end;
            if Mage_GetSpellCooldown("唤醒") ~= 0 then
                 Mage_Default_AddMessage("**唤醒目前在CD...**");
                 Mage_Combat_AddMessage("**唤醒目前在CD**");
                 Mage_Purge = 0;
            end;
            if not Mage_movement then
                if Mage_CastSpell("唤醒") then return true; end;
            end
    end;

    if Mage_Blizzard == 1 then
        if not Mage_movement then
              if GetTimer("Mage_Blizzard") > 10 then  Mage_Default_AddMessage("**使用暴风雪命令超时...**"); Mage_Blizzard = 0; end;
              if Mage_IsManaEnough("暴风雪") then
                   if Mage_CastBlizzard() then return true; end;
              else
                   Mage_Combat_AddMessage("**暴风雪不可用，蓝量不够**");
                   Mage_Blizzard = 0;
              end
        else
            if GetTimer("Mage_Blizzard") > 2 then  Mage_Default_AddMessage("**使用暴风雪命令超时...**"); Mage_Blizzard = 0; end;
        end
        Mage_SetText("准备暴风雪中",0);
        return;
    end
	
	if not UnitExists("target")  then
		if Mage_AntiOffLine() then return ; end;
		Mage_SetText("没有目标",0);
		return; 
	end;		
	
	if not UnitCanAttack("player","target")  then
        Mage_SetText("友善目标",0);
		return;
	end;	 
	
	if Mage_TargetBU("圣盾术") or  Mage_TargetBU("保护祝福") or  Mage_TargetBU("寒冰屏障")  then
		Mage_Combat_AddMessage("**目标无法攻击**");
		Mage_SetText("目标无法攻击",0);
		return ;
	end;
	

	if Mage_PlayerDeBU("飓风术")  then
		Mage_Combat_AddMessage("**你中了飓风术,无法攻击**");
		Mage_SetText("目标无法攻击",0);
		return ;
	end;


	if not UnitIsPlayer("playertarget") then
		if UnitIsDead("playertarget")  then
			Mage_SetText("目标死亡",0);
			return;
		end
	else
		if UnitIsDeadOrGhost("playertarget") then
			if UnitHealth("target") > 1  then
				if GetTimer("猎人假死") > 1 then				
					  StartTimer("猎人假死");				
					  Mage_Combat_AddMessage("**猎人假死状态，速度鞭尸**");
				end; 
			else
		        Mage_SetText("目标死亡",0);
			    return; 
			end;  
		end; 
	end
	
	  
	Mage_SetText("无动作",0);
	
	if Mage_Test_Target_Debuff() then
		if Mage_IsAttack() then
			if Mage_CastMacro("停止攻击") then return true; end;
		end;
		if GetTimer("目标已经被控制") > 1 then				
			StartTimer("目标已经被控制");				
			Mage_Default_AddMessage(UnitName("target").."目标已经被控制...");
			Mage_Combat_AddMessage(UnitName("target").."目标已经被控制...");
		end; 
		Mage_SetText("目标已经被控制",0);
		return;
	end
	
    Mage_playerCombat();
end;


 


  
function Mage_Test()
	for i = 1, 120 do		    
		if HasAction(i)  then	
			if not GetActionText(i) then
				PaladinTooltip:SetOwner(UIParent, "ANCHOR_NONE")
				PaladinTooltipTextRight1:SetText()
				PaladinTooltip:SetAction(i)
				local name = PaladinTooltipTextLeft1:GetText()
				PaladinTooltip:Hide();
			   if name and IsUsableAction(i) ~= 1 then
					Mage_AddMessage("**_"..name.."__"..i.."_____");
				end
		   else
			   local name = GetActionText(i)	
			   if name and IsUsableAction(i) ~= 1 then	
					Mage_AddMessage("**_"..name.."__"..i.."______");
			   end
		   end 
	   end
   end
end;

