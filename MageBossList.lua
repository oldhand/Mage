-- 包含：WotLK/TBC/60级 的 团本+5人本+野外BOSS 名单 (简体中文)
    local All_Bosses = {
        -- ==========================================
        -- [ 野外世界 BOSS (World Bosses) ]
        -- ==========================================
        -- 经典旧世
        ["艾索雷葛斯"] = true, ["卡扎克"] = true, ["蓝龙"] = true,
        ["伊森德雷"] = true, ["莱索恩"] = true, ["艾莫莉丝"] = true, ["泰拉尔"] = true, -- 翡翠四绿龙
        -- TBC
        ["末日领主卡扎克"] = true, ["末日行者"] = true,
        -- WotLK (通常指阿尔卡冯宝库，已在团本列表中，此处列出稀有精英以防万一)
        -- (注：WotLK没有像TBC那样传统的野外BOSS，主要集中在冬拥湖副本)

        -- ==========================================
        -- [ 巫妖王之怒 (WotLK) - 团本 & 5人本 ]
        -- ==========================================
        -- 冰冠堡垒 (ICC)
        ["玛洛加尔领主"] = true, ["亡语者女士"] = true, ["死亡使者萨鲁法尔"] = true,
        ["烂肠"] = true, ["腐面"] = true, ["普崔希德教授"] = true,
        ["瓦拉纳王子"] = true, ["塔达拉姆王子"] = true, ["凯雷塞斯王子"] = true, -- 鲜血议会
        ["鲜血女王兰娜瑟尔"] = true, ["踏梦者瓦莉瑟瑞孔"] = true, ["辛达苟萨"] = true, ["巫妖王"] = true,
        -- 十字军的试炼 (ToC)
        ["穿刺者戈莫克"] = true, ["酸喉"] = true, ["恐鳞"] = true, ["冰吼"] = true, ["加拉克苏斯大王"] = true,
        ["瓦格里双子"] = true, ["光明邪使菲奥拉"] = true, ["黑暗邪使艾瑞克"] = true, ["阿努巴拉克"] = true,
        -- 奥杜尔 (Ulduar)
        ["烈焰巨兽"] = true, ["锋鳞"] = true, ["掌炉者伊格尼斯"] = true, ["拆解者XT-002"] = true,
        ["钢铁议会"] = true, ["破钢者"] = true, ["符文大师摩尔基姆"] = true, ["风暴唤唤者布伦迪尔"] = true,
        ["科隆加恩"] = true, ["欧尔莉亚"] = true, ["霍迪尔"] = true, ["托里姆"] = true, ["弗蕾亚"] = true, ["米米尔隆"] = true,
        ["维扎克斯将军"] = true, ["尤格-萨隆"] = true, ["观察者奥尔加隆"] = true,
        -- 纳克萨玛斯 (Naxx)
        ["阿努布雷坎"] = true, ["黑女巫法琳娜"] = true, ["迈克斯纳"] = true,
        ["瘟疫使者诺斯"] = true, ["肮脏的希尔盖"] = true, ["洛欧塞布"] = true,
        ["教官拉苏维奥斯"] = true, ["收割者戈提克"] = true, ["四骑士"] = true,
        ["库尔塔兹领主"] = true, ["瑟里耶克爵士"] = true, ["女公爵布劳缪克丝"] = true, ["瑞文戴尔男爵"] = true,
        ["帕奇维克"] = true, ["格罗布鲁斯"] = true, ["格拉斯"] = true, ["塔迪乌斯"] = true,
        ["萨菲隆"] = true, ["克尔苏加德"] = true,
        -- 其他团本 (OS, EoE, RS, VoA, Onyxia)
        ["萨塔里奥"] = true, ["玛里苟斯"] = true, ["海里昂"] = true, ["奥妮克希亚"] = true,
        ["岩石看守者阿尔卡冯"] = true, ["风暴看守者埃玛尔隆"] = true, ["火焰看守者科拉隆"] = true, ["寒冰看守者图拉旺"] = true,
        -- WotLK 5人本 (部分核心BOSS)
        ["依米隆国王"] = true, ["洛肯"] = true, ["玛尔加尼斯"] = true, ["克洛诺斯领主"] = true,
        ["黑骑士"] = true, ["纯洁者耶德瑞克"] = true, ["银色神官帕尔崔丝"] = true, -- 冠军试炼
        ["布隆亚姆"] = true, ["噬魂者"] = true, ["天灾领主泰兰努斯"] = true, ["锻造大师加弗罗斯"] = true, -- 新三本
        ["阿努巴拉克"] = true, ["传令官沃拉兹"] = true, ["先知萨隆亚"] = true, ["迦尔达拉"] = true, ["斯拉德兰"] = true, ["莫拉比"] = true,

        -- ==========================================
        -- [ 燃烧的远征 (TBC) - 团本 & 5人本 ]
        -- ==========================================
        -- 太阳井 (SWP)
        ["卡雷苟斯"] = true, ["布鲁塔卢斯"] = true, ["菲米丝"] = true, ["艾瑞达双子"] = true, ["穆鲁"] = true, ["基尔加丹"] = true,
        -- 黑暗神殿 (BT)
        ["高阶督军纳因图斯"] = true, ["苏普雷姆斯"] = true, ["阿卡玛之影"] = true, ["泰伦·血魔"] = true, ["古尔图格·血沸"] = true,
        ["灵魂之匣"] = true, ["莎赫拉丝主母"] = true, ["伊利达雷议会"] = true, ["伊利丹·怒风"] = true,
        -- 海加尔山 (Hyjal)
        ["雷基·冬寒"] = true, ["安纳塞隆"] = true, ["卡兹洛加"] = true, ["阿兹加洛"] = true, ["阿克蒙德"] = true,
        -- 风暴要塞 (TK) & 毒蛇神殿 (SSC)
        ["奥"] = true, ["空灵机甲"] = true, ["大星术师索兰莉安"] = true, ["凯尔萨斯·逐日者"] = true,
        ["不稳定的海度斯"] = true, ["盲眼者莱欧瑟拉斯"] = true, ["深水领主卡拉瑟雷斯"] = true, ["莫洛格里·踏潮者"] = true, ["瓦斯琪"] = true,
        -- 卡拉赞 (Kara), 格鲁尔, 玛瑟里顿, 祖阿曼 (ZA)
        ["莫罗斯"] = true, ["贞节圣女"] = true, ["馆长"] = true, ["埃兰之影"] = true, ["虚空幽龙"] = true, ["夜之魇"] = true, ["玛克扎尔王子"] = true,
        ["莫加尔大王"] = true, ["格鲁尔"] = true, ["玛瑟里顿"] = true, ["祖尔金"] = true,
        -- TBC 5人本 (部分核心)
        ["凯尔萨斯·逐日者"] = true, ["穆鲁"] = true, ["塞林·火哈特"] = true, -- 魔导师平台
        ["埃欧努斯"] = true, ["坦普卢斯"] = true, -- 时光之穴
        ["算计者帕萨雷恩"] = true, ["预言者斯克瑞斯"] = true, ["利爪之王艾吉斯"] = true, ["摩摩尔"] = true,
        ["夸格米拉"] = true, ["瓦兹德"] = true, ["卡加斯·刃拳"] = true,

        -- ==========================================
        -- [ 经典旧世 (60级) - 团本 & 5人本 ]
        -- ==========================================
        -- 安其拉 (TAQ/RAQ)
        ["克苏恩"] = true, ["双子皇帝"] = true, ["奥罗"] = true, ["哈霍兰公主"] = true, ["范克瑞斯"] = true, ["维希度斯"] = true,
        ["无疤者奥斯里安"] = true, ["莫阿姆"] = true,
        -- 纳克萨玛斯 (60级版本同名，已在WotLK部分覆盖)
        -- 黑翼之巢 (BWL) & 熔火之心 (MC)
        ["奈法利安"] = true, ["克洛玛古斯"] = true, ["弗莱格尔"] = true, ["埃博诺克"] = true, ["费尔默"] = true,
        ["勒什雷尔"] = true, ["堕落的瓦拉斯塔兹"] = true, ["狂野的拉佐格尔"] = true,
        ["拉格纳罗斯"] = true, ["管理者埃克索图斯"] = true, ["焚化者古雷曼格"] = true, ["加尔"] = true, ["迦顿男爵"] = true, ["玛格曼达"] = true,
        -- 祖尔格拉布 (ZG)
        ["哈卡"] = true, ["金度"] = true, ["曼多基尔"] = true,
        -- 经典5人本 (三大本等)
        ["瑞文戴尔男爵"] = true, ["巴纳扎尔"] = true, ["黑暗院长加丁"] = true, ["詹迪斯·巴罗夫"] = true,
        ["达基萨斯将军"] = true, ["比斯巨兽"] = true, ["雷德·黑手"] = true,
        ["索瑞森大帝"] = true, ["伊莫塔尔"] = true, ["戈多克大王"] = true
    }

-- 内部辅助函数：检查单个单位的目标是否是 BOSS
local function Mage_IsUnitTargetingBoss(unit)
    local targetUnit = unit .. "target"
    if UnitExists(targetUnit) then
        local name = UnitName(targetUnit)
        -- 检查名字是否存在于列表中
        if name and All_Bosses[name] then
            return true
        end
    end
    return false
end

function Mage_IsTargetLegacyBoss()
    -- 1. 如果在团队中
    if UnitInRaid("player") then
        local raidCount = GetNumRaidMembers()
        for i = 1, raidCount do
            local unit = "raid" .. i
            if UnitExists(unit) and UnitIsVisible(unit) and Mage_IsUnitTargetingBoss(unit) then
                return true
            end
        end
    -- 2. 如果在小队中（或者只有自己）
    else
        -- 检查自己
        if Mage_IsUnitTargetingBoss("player") then
            return true
        end
        -- 检查队友
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitExists(unit) and UnitIsVisible(unit) and Mage_IsUnitTargetingBoss(unit) then
                return true
            end
        end
    end
    return false
end