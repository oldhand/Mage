-- 常量定义
Mage_DISEASE = 'Disease';
Mage_MAGIC   = 'Magic';
Mage_POISON  = 'Poison';
Mage_CURSE   = 'Curse';
Mage_CHARMED = 'Charm';

Mage_CLASS_DRUID   = 'DRUID';
Mage_CLASS_HUNTER  = 'HUNTER';
Mage_CLASS_MAGE    = 'MAGE';
Mage_CLASS_PALADIN = 'PALADIN';
Mage_CLASS_ROGUE   = 'ROGUE';
Mage_CLASS_SHAMAN  = 'SHAMAN';
Mage_CLASS_WARLOCK = 'WARLOCK';
Mage_CLASS_WARRIOR = 'WARRIOR';

-- 遇到这些 Debuff 时，直接忽略该目标（不进行驱散），并停止继续扫描该目标
-- 通常用于被控制、放逐或相位变换的目标
Mage_IGNORELIST = {
    ["放逐术"]    = true,
    ["相位变换"]   = true,
};

-- 跳过这些特定的 Debuff（即使是可驱散类型也不驱散）
Mage_SKIP_LIST = {
    ["无梦睡眠"]   = true,
    ["强效无梦睡眠"]= true,
    ["昏睡"]       = true,
    ["强效昏睡"]   = true,
    ["寒冰箭"]    = true,
    ["心灵视界"]   = true,
    ["变异注射"]   = true,
    ["腐蚀耐力"]   = true,
    ["十字军打击"]  = true, -- 通常不需要浪费蓝驱散这个
    ["雷霆一击"]   = true,
    ["淹没"]       = true,
};

-- 根据职业跳过特定的 Debuff（例如战士不需要驱散法力燃烧）
Mage_SKIP_BY_CLASS_LIST = {
    [Mage_CLASS_WARRIOR] = {
       ["上古狂乱"]   = true,
       ["点燃法力"]   = true,
       ["污浊之魂"]   = true,
       ["法力燃烧"]   = true,
    },
    [Mage_CLASS_ROGUE] = {
       ["沉默"]       = true, -- 盗贼被沉默通常不致命，视情况而定
       ["上古狂乱"]   = true,
       ["点燃法力"]   = true,
       ["污浊之魂"]   = true,
       ["法力燃烧"]   = true,
       ["音素爆破"]   = true,
    },
    [Mage_CLASS_HUNTER] = {
       ["熔岩镣铐"]   = true,
    },
    [Mage_CLASS_MAGE] = {
       ["熔岩镣铐"]   = true,
    },
};

-- 主扫描函数
function Mage_DecursiveScanUnit(Unit)
    local Magic_Count   = 0;
    local Disease_Count = 0;
    local Poison_Count  = 0;
    local Curse_Count   = 0;

    -- 确保单位存在
    if not UnitExists(Unit) then  return { ["Magic"]=0, ["Curse"]=0, ["Poison"]=0, ["Disease"]=0 }; end

    local _, UClass = UnitClass(Unit);

    -- 获取所有 Debuff 数据
    local AllUnitDebuffs = Mage_GetUnitDebuffAll(Unit);

    for debuff_name, debuff_params in pairs(AllUnitDebuffs) do
       local Go_On = true;

       -- 1. 致命黑名单检查：如果中了放逐等，直接返回全0，不再处理该目标
       if (Mage_IGNORELIST[debuff_name]) then
          return { ["Magic"]=0, ["Curse"]=0, ["Poison"]=0, ["Disease"]=0 };
       end

       -- 2. 跳过列表检查
       if (Mage_SKIP_LIST[debuff_name]) then
          Go_On = false;
       end

       -- 3. 职业特定跳过列表检查
       if (UnitAffectingCombat("player")) then
          if (UClass and Mage_SKIP_BY_CLASS_LIST[UClass]) then
             if (Mage_SKIP_BY_CLASS_LIST[UClass][debuff_name]) then
                Go_On = false;
             end
          end
       end

       -- 4. 统计逻辑
       if (Go_On) then
          if (debuff_params.debuff_type and debuff_params.debuff_type ~= "") then
             -- 现代 API 中 count 如果是 0 通常代表 1 层，这里简单处理为 +1
             local count = debuff_params.debuffApplications;
             if count == 0 then count = 1 end

             if (debuff_params.debuff_type == Mage_MAGIC) then
                Magic_Count = Magic_Count + count;
             elseif (debuff_params.debuff_type == Mage_DISEASE) then
                Disease_Count = Disease_Count + count;
             elseif (debuff_params.debuff_type == Mage_POISON) then
                Poison_Count = Poison_Count + count;
             elseif (debuff_params.debuff_type == Mage_CURSE) then
                Curse_Count = Curse_Count + count;
             end
          end
       end
    end

    local counts = {};
    counts["Magic"] = Magic_Count;
    counts["Curse"] = Curse_Count;
    counts["Poison"] = Poison_Count;
    counts["Disease"] = Disease_Count;
    return counts;
end


-- 获取目标所有 Debuff 的详细信息表
function Mage_GetUnitDebuffAll(unit)
    local ThisUnitDebuffs = {};
    local i = 1;

    while (true) do
       -- 直接调用适配后的获取函数
       local debuff_name, debuff_type, debuffApplications, DebuffTexture = Mage_GetUnitDebuff(unit, i);

       if debuff_name == nil then
          break;
       end

       -- 注意：如果有同名 Debuff，后者会覆盖前者，但在驱散逻辑中这通常是可以接受的
       ThisUnitDebuffs[debuff_name] = {};
       ThisUnitDebuffs[debuff_name].DebuffTexture = DebuffTexture;
       ThisUnitDebuffs[debuff_name].debuffApplications = debuffApplications;
       ThisUnitDebuffs[debuff_name].debuff_type   = debuff_type;
       ThisUnitDebuffs[debuff_name].debuff_name   = debuff_name;
       ThisUnitDebuffs[debuff_name].index    = i;

       i = i + 1;
    end
    return ThisUnitDebuffs;
end

-- 封装 UnitDebuff 以适配旧代码的返回值顺序
-- 现代 API: name, icon, count, debuffType, duration, expirationTime, source, isStealable, ...
function Mage_GetUnitDebuff(Unit, i)
    -- 现代怀旧服 API 直接返回 Name (第1个参数) 和 Type (第4个参数)
    local name, icon, count, debuffType = UnitDebuff(Unit, i);

    if (name) then
       -- 为了兼容你原来的逻辑，调整返回顺序：
       -- Name, Type, Count, Icon
       return name, debuffType, count, icon;
    else
       return nil, false, false, false;
    end
end

-- 扫描是否有魔法 Buff (用于进攻驱散/偷取，如果有)
function Mage_ScanUnitMagicBuff(Unit)
    local i = 1;
    while (true) do
       -- 现代 API: UnitBuff 返回值结构与 UnitDebuff 类似
       local name, icon, count, debuffType = UnitBuff(Unit, i);
       if not name then break end

       if (debuffType == Mage_MAGIC) then
          return true, name;
       end
       i = i + 1
    end
    return false, nil;
end