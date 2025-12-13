Mage_Settings_Hit = "设置参数"

Mage_Settings = nil;
local Mage_PopMenu = nil

local Mage_MainTank = false; --治疗主坦克
local Mage_MainTankName = nil; --治疗主坦克名字
local Mage_AllDispel = false; --全团驱散



function Mage_Settings_OnLoad(self)
    if UnitClass("player") ~= "法师" then
		HideUIPanel(MageSettingBtn);
		return
	end

    self:RegisterEvent("PLAYER_ENTERING_WORLD")	
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function Mage_Settings_OnEvent(event)
    if (event == "PLAYER_ENTERING_WORLD") then			
		if ( Mage_Settings == nil ) then
			Mage_Settings = {};
			Mage_Settings["MainTank"] = false;
			Mage_Settings["MainTankName"] = nil;
			Mage_Settings["AllDispel"] = false;
		end
		if Mage_Settings["MainTank"] ~= nil then
			 Mage_MainTank = Mage_Settings["MainTank"];
		end 
		if Mage_Settings["MainTankName"] ~= nil then
			 Mage_MainTankName= Mage_Settings["MainTankName"];
		end 
		if Mage_Settings["AllDispel"] ~= nil then
			 Mage_AllDispel = Mage_Settings["AllDispel"];
		end
		
    elseif (event == "GROUP_ROSTER_UPDATE") then
      
	end;
end
 
function Mage_Settings_OnUpdate()
    
end


function Mage_Get_MainTankName()
	if Mage_MainTank and Mage_MainTankName ~= nil then
		return Mage_MainTankName;
	end
	return "";
end

function Mage_GetSetting(key)
	if key == "MainTank" then
		return Mage_MainTank;
	elseif key == "AllDispel" then
		return Mage_AllDispel;
	end
	return false;
end

function Mage_Setting_onClick(key)
	if ( Mage_Settings == nil ) then
		Mage_Settings = {};
	end
	if key == "MainTank" then
		if Mage_MainTank then
			Mage_MainTank = false;
			Mage_Settings["MainTank"] = Mage_MainTank;
			Mage_Default_AddMessage("**主坦克关闭**");
		else
			Mage_MainTank = true;
			Mage_Settings["MainTank"] = Mage_MainTank;
			Mage_Default_AddMessage("**主坦克开启**");
		end
	elseif key == "AllDispel" then
			if Mage_AllDispel then
				Mage_AllDispel = false;
				Mage_Settings["AllDispel"] = Mage_AllDispel;
				Mage_Default_AddMessage("**全团驱散关闭**");
			else
				Mage_AllDispel = true;
				Mage_Settings["AllDispel"] = Mage_AllDispel;
				Mage_Default_AddMessage("**全团驱散开启**");
			end
	end 
end

function Mage_Settings_fun()
	MageSettings:Show();
    if Mage_MainTank then
		if not MageSettingsMainTank:GetChecked() then
	        MageSettingsMainTank:SetChecked(true)
		end
	else
		if MageSettingsMainTank:GetChecked() then
	        MageSettingsMainTank:SetChecked(false)
		end
    end
    if Mage_AllDispel then
		if not MageSettingsAllDispel:GetChecked() then
	        MageSettingsAllDispel:SetChecked(true)
		end
	else
		if MageSettingsAllDispel:GetChecked() then
	        MageSettingsAllDispel:SetChecked(false)
		end
    end
end
 
function Mage_SelectMainTank_onClick()
	Mage_SelectMainTank_popuMenu();
end

function Mage_SelectMainTank_OnEnter()
	if Mage_MainTankName ~= nil then
		MageSettingsTooltip:SetOwner(MageSettingsSelectMainTank, "ANCHOR_BOTTOMRIGHT",-120,-10);
		MageSettingsTooltip:SetText("已经设置主坦克>>" .. Mage_MainTankName.."<<");
		MageSettingsTooltip:Show();
	end
end

function Mage_SelectMainTank(self)
	v = self.value;
	Mage_PopMenu:Hide();
	if v ~= nil then
		Mage_MainTankName = v;
		Mage_Settings["MainTankName"] = Mage_MainTankName;
		Mage_AddMessage("**设置主坦克>>"..Mage_MainTankName.."<<**");
		Blizzard_AddMessage("**设置主坦克>>"..Mage_MainTankName.."<<**",1,0,0,"crit");
		local unit = Mage_GetTargetUnit(Mage_MainTankName);
		if unit ~= "" and UnitExists(unit) then 
			SetRaidTargetIcon(unit, 1)
			SetRaidTargetIcon("player", 2)
		end
	end 
end

function Mage_SetMainTank(name)
	Mage_MainTankName = name;
	Mage_Settings["MainTankName"] = Mage_MainTankName;
	Mage_AddMessage("**设置主坦克>>"..Mage_MainTankName.."<<**");
	Blizzard_AddMessage("**设置主坦克>>"..Mage_MainTankName.."<<**",1,0,0,"crit");
	local unit = Mage_GetTargetUnit(Mage_MainTankName);
	if unit ~= "" and UnitExists(unit) then 
		SetRaidTargetIcon(unit, 1)
		SetRaidTargetIcon("player", 2)
	end
end


function Mage_PopMenu_Tank_Initialize(level)
	if not level then return end
    if UnitInRaid("player") then
        for id=1, 40  do
            local unit = "raid"..id;
            if  UnitExists(unit) then
                if Mage_IsUnitTank(unit) then
                    local info = {}
                    info.text = UnitName(unit) .. "(" .. UnitClass(unit) .. ")"
                    info.value = UnitName(unit)
                    info.checked = (UnitName(unit) == Mage_MainTankName)
                    info.func = Mage_SelectMainTank
                    UIDropDownMenu_AddButton(info, 1)
                end
            end
        end
    else
        local hasTank =  false;
        for id=1, 4  do
            local unit = "party"..id;
            if UnitExists(unit) and Mage_IsUnitTank(unit) then
                hasTank = true
                local info = {}
                info.text = UnitName(unit)
                info.value = UnitName(unit)
                info.checked = (UnitName(unit) == Mage_MainTankName)
                info.func = Mage_SelectMainTank
                UIDropDownMenu_AddButton(info, 1)
            end
        end
        if not hasTank then
            for id=1, 4  do
                local unit = "party"..id;
                if UnitExists(unit) and Mage_IsUnitTank(unit) then
                    local info = {}
                    info.text = UnitName(unit)
                    info.value = UnitName(unit)
                    info.checked = (UnitName(unit) == Mage_MainTankName)
                    info.func = Mage_SelectMainTank
                    UIDropDownMenu_AddButton(info, 1)
                end
            end
        end
    end
end

function Mage_SelectMainTank_popuMenu(window)
	if not Mage_PopMenu then
		Mage_PopMenu = CreateFrame('Frame', nil, UIParent, 'UIDropDownMenuTemplate')
	else
		Mage_PopMenu:Hide();
	end

	Mage_PopMenu.displayMode = "MENU"

	Mage_PopMenu.initialize = Mage_PopMenu_Tank_Initialize

	ToggleDropDownMenu(1, nil, Mage_PopMenu,'cursor')
	 
end

-- ========================================================
-- 函数：判断指定单位是否为坦克
-- 参数：unit (例如 "target", "player", "party1", "raid5")
-- 返回：true (是坦克) / false (不是)
-- ========================================================
function Mage_IsUnitTank(unit)
    if not UnitExists(unit) then return false end

    -- 1. 优先检查系统分配的职责 (适用于随机本/团队框架已设置职责的情况)
    -- 如果是正式服或较新的怀旧服核心，这个函数很准
    if UnitGroupRolesAssigned and UnitGroupRolesAssigned(unit) == "TANK" then
        return true
    end

    -- 2. 如果系统没分配职责，则检查关键的“坦克姿态/Buff”
    -- 定义坦克特征 SpellID 表 (根据时光服版本，主要是 WLK/CTM 常用ID)
    local tankBuffs = {
        [71]    = true, -- 战士: 防御姿态 (Defensive Stance)
        [5487]  = true, -- 德鲁伊: 熊形态 (Bear Form)
        [9634]  = true, -- 德鲁伊: 巨熊形态 (Dire Bear Form)
        [25780] = true, -- 圣骑士: 正义之怒 (Righteous Fury)
        [48263] = true, -- DK: 鲜血灵气 (Blood Presence) - WLK后期/CTM坦克标配
        [48266] = true, -- DK: 冰霜灵气 (Frost Presence) - WLK早期可能会用这个坦
        -- 如果有武僧/DH，需补充 醉拳/复仇形态 的ID
    }

    -- 遍历目标身上的所有 Buff
    local i = 1
    while true do
        -- 获取 Buff 信息 (参数 "HELPFUL" 表示增益 Buff)
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitAura(unit, i, "HELPFUL")

        if not name then break end -- 遍历结束

        -- 检查 SpellID 是否在我们的坦克列表里
        if tankBuffs[spellId] then
            return true
        end

        i = i + 1
    end

    return false
end