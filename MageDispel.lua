




function Paladin_Dispel()

    if Paladin_DispelUnit("player") then return true end;
    if Paladin_GetSetting("MainTank") then
        local mainTankName = Paladin_Get_MainTankName();
        if mainTankName ~= "" then
            local unit = Paladin_GetTargetUnit(mainTankName);
            if  unit ~= nil and UnitExists(unit)  then
                if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and IsSpellInRange("圣光术",unit) == 1 then
                    if Paladin_DispelUnit(unit) then return true end;
                end
            end
        end
    end

    for index=1, 4 do
        local unit = "party"..index;
        if  UnitExists(unit)  then
            if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and IsSpellInRange("圣光术",unit) == 1 then
                if Paladin_DispelUnit(unit) then return true end;
            end
        end
    end

    if Paladin_GetSetting("AllDispel") and UnitInRaid("player") then
        for id=1, 40  do
            local unit = "raid"..id;
            if  UnitExists(unit)  then
                if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) and IsSpellInRange("圣光术",unit) == 1 then
                    if Paladin_DispelUnit(unit) then return true end;
                end
            end
        end
    end
    return false;
end