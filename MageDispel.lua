


function Mage_playerSelectUnit(unit)
    if not UnitExists("target") then return false; end
    if UnitCanAttack("player",unit) then return false; end
    if UnitIsUnit("target", unit) then return true; end
    return false;
end

function Mage_GetTargetUnit(name)
    local prefix = UnitInRaid("player") and "raid" or "party"
    local count = UnitInRaid("player") and 40 or 4

    for id = 1, count do
        local unit = prefix .. id
        if UnitExists(unit) and UnitName(unit) == name then
            return unit
        end
    end
	return nil;
end


function Mage_Dispel()
    if  UnitExists("target") and UnitCanAttack("player","target") and UnitIsPlayer("target") then return false; end

    if Mage_GetSetting("MainTank") then
        local mainTankName = Mage_Get_MainTankName();
        if mainTankName ~= "" then
            local unit = Mage_GetTargetUnit(mainTankName);
            if  unit ~= nil and UnitExists(unit)  then
                if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and IsSpellInRange("解除诅咒",unit) == 1 then
                    if Mage_DispelUnit(unit) then return true end;
                end
            end
        end
    end

    for index=1, 4 do
        local unit = "party"..index;
        if  UnitExists(unit)  then
            if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and IsSpellInRange("解除诅咒",unit) == 1 then
                if Mage_DispelUnit(unit) then return true end;
            end
        end
    end

    if Mage_GetSetting("AllDispel") and UnitInRaid("player") then
        for id=1, 40  do
            local unit = "raid"..id;
            if  UnitExists(unit)  then
                if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and IsSpellInRange("解除诅咒",unit) == 1 then
                    if Mage_DispelUnit(unit) then return true end;
                end
            end
        end
    end
    return false;
end



function Mage_DispelUnit(unit)
    if GetTimer(UnitName(unit).."_FAILED_LINE_OF_SIGHT") < 2 then return false; end

	local counts = Mage_DecursiveScanUnit(unit);

	if counts ~= nil and counts["Curse"] > 0 and Mage_HasSpell("解除诅咒") then
        if Mage_playerSelectUnit(unit) then
            if Mage_CastSpell("解除诅咒") then
                if Mage_Get_CombatLogMode() then
                    Mage_AddMessage("对>>" .. UnitName("target").."<<使用解除诅咒");
                end
                return true;
            end;
            Mage_SetText(">解除诅咒",0);
            return true;
        else
            if Mage_SelectTarget(unit) then return true; end;
        end
	 end
    return false;
end