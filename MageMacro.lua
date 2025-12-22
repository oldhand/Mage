if UnitClass("player") == "法师" then
     local frame = CreateFrame("Frame")
     frame:RegisterEvent("PLAYER_LOGIN")

     -- ==========================================
     --  配置区域：在这里修改按键和宏名称
     -- ==========================================
     local macroConfig = {
         {
             name = "ACM_StartAttack",   -- 宏名称 (尽量用英文避免乱码问题)
             body = "/startattack",      -- 宏内容：开始攻击
             key = "ALT-F1"                  -- 绑定的热键
         },
         {
             name = "ACM_StopAttack",
             body = "/stopattack",       -- 宏内容：停止攻击
             key = "ALT-F2"
         },
         {
             name = "ACM_StopCast",
             body = "/stopcasting",      -- 宏内容：打断施法
             key = "ALT-F3"
         },
         {
             name = "ACM_Dismount",
             body = "/dismount",         -- 宏内容：下马
             key = "ALT-]"
         },
         {
              name = "ACM_Mount",
              body = "/mount",         -- 宏内容：上马
              key = "ALT-F5"
         },
         {
             name = "ACM_FlameStormLevel8",
             body = "/cast [@cursor] 烈焰风暴(等级8)",            -- 宏内容：站立 (这会自动取消喝水/吃东西)
             key = "ALT-F6"
         },
         {
             name = "ACM_SelectTargetTarget",
             body = "/tar targettarget",            -- 宏内容：选择目标的目标
             key = "ALT-F7"
         },
         {
              name = "ACM_CastBlizzard",
              body = "/cast [@cursor] 暴风雪",            -- 宏内容：使用暴风雪
              key = "ALT-F8"
          },
         {
             name = "ACM_PetAttack",
             body = "/petattack\n/petdefensive",            -- 宏内容：宠物攻击
             key = "ALT-F9"
         },
         {
              name = "ACM_StopPetAttack",
              body = "/petfollow\n/petpassive",            -- 宏内容：宠物停止攻击
              key = "ALT-F10"
         },
         {
               name = "ACM_TargetEnemy",
               body = "/cleartarget [dead]\n/targetenemy",            -- 宏内容：智能攻击（有目标打目标，没目标打最近）
               key = "ALT-F11"
         },
         {
               name = "ACM_FlameStorm",
               body = "/cast [@cursor] 烈焰风暴",            -- 宏内容：使用暴风雪
               key = "ALT-F12"
         },
         {
              name = "ACM_UserPolymorph",
              body = "/script Mage_SendCommand(1);",            -- 宏内容：使用变形术
              key = "F"
         },
         {
             name = "ACM_UseTeleport",
              body = "/script Mage_SendCommand(2);",            -- 宏内容：使用闪现术
             key = "Q"
         },
          {
              name = "ACM_UsePurge",
              body = "/script Mage_SendCommand(3);",            -- 宏内容：使用唤醒
              key = "T"
          },
          {
               name = "ACM_UseBlizzard",
              body = "/script Mage_SendCommand(4);",            -- 宏内容：使用暴风雪
               key = "R"
          }
     }



    -- ==========================================
    --  核心逻辑
    -- ==========================================
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_LOGIN" then
            -- 战斗中绝对禁止创建安全按钮或绑定按键
            if InCombatLockdown() then
                print("|cffff0000[AutoCombat]|r 错误：战斗中无法初始化按键！请脱战后 /reload")
                return
            end

            for i, cfg in ipairs(macroConfig) do
                -- 1. 生成唯一的按钮名称，例如 ACH_Btn_StartAttack
                local btnName = "ACH_Btn_" .. cfg.name

                -- 2. 获取或创建安全按钮
                -- 使用 SecureActionButtonTemplate 是核心，它允许按钮执行受保护的动作（如攻击、施法）
                local btn = _G[btnName] or CreateFrame("Button", btnName, UIParent, "SecureActionButtonTemplate")

                -- 3. 设置按钮属性：点击该按钮 = 执行宏文本
                btn:SetAttribute("type", "macro")
                btn:SetAttribute("macrotext", cfg.body)

                -- 4. 清除该按键之前的旧绑定 (可选，为了防止冲突，建议先解绑该键的旧功能)
                -- 注意：这会移除该键在暴雪按键设置里的绑定
                SetBinding(cfg.key)

                -- 5. 将按键绑定到这个隐形按钮的点击事件上
                -- 意思是：当你按下 cfg.key 时，游戏会认为你鼠标点击了 btnName 这个按钮
                SetBindingClick(cfg.key, btnName)
            end
            SaveBindings(2)
        end
    end)

end

function Mage_StartAttack()
    Mage_SetText("开始攻击", 61);
    return true;
end

function Mage_DisMount()
    Mage_SetText("停止攻击", 62);
    return true;
end

function Mage_StopCasting()
    Mage_SetText("打断施法", 63);
    return true;
end

function Mage_Dismount()
    Mage_SetText("下马", 64);
    return true;
end

function Mage_Mount()
    Mage_SetText("上马", 65);
    return true;
end

function Mage_FlameStormLevel8()
    Mage_SetText("烈焰风暴(等级8)", 66);
    return true;
end

function Mage_SelectTargetTarget()
    Mage_SetText("选择目标的目标", 67);
    return true;
end

function Mage_CastBlizzard()
    Mage_SetText("暴风雪", 68);
    return true;
end

function Mage_PetAttack()
    Mage_SetText("宠物攻击", 69);
    return true;
end

function Mage_StopPetAttack()
    Mage_SetText("宠物停止攻击", 70);
    return true;
end

function Mage_TargetEnemy()
    Mage_SetText("选择最近的目标", 71);
    return true;
end

function Mage_FlameStorm()
    Mage_SetText("烈焰风暴", 72);
    return true;
end


