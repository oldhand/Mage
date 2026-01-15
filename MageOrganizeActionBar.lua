

function Mage_PickupSpellByBook(spell)
	for tab = 1, GetNumSpellTabs()+1 do
			local tabName, tabTexture, tabOffset, tabSlots  = GetSpellTabInfo(tab);
			local spellIndex = 0;
			local Rank = 0;
			for i = tabOffset+1, tabSlots+tabOffset do
			     local spellType, spellID = GetSpellBookItemInfo( i, BOOKTYPE_SPELL );
			     local spellName,spellRank,_ = GetSpellInfo( i, BOOKTYPE_SPELL );
			     if spellName == spell then
					 if spellID then
						 if spellID > Rank then
						   Rank =  spellID
						   spellIndex = i;
					  	 end
				     else
					    spellIndex = i;
				  	 end
			     end
			end
			if spellIndex > 0 then
			    PickupSpellBookItem(spellIndex, SpellBookFrame.bookType);
			    return true;
			end
	end;
	return false;
end

function Mage_OrganizeActionBar()

    if Mage_PickupSpellByBook("寒冰箭") then
        PlaceAction(1);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("火焰冲击") then
        PlaceAction(2);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("冰霜新星") then
        PlaceAction(3);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("冰锥术") then
        PlaceAction(4);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("暴风雪") then
        PlaceAction(5);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("法术反制") then
        PlaceAction(6);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("魔爆术") then
        PlaceAction(7);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("闪现术") then
        PlaceAction(8);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("唤醒") then
        PlaceAction(9);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("火球术") then
        PlaceAction(10);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("霜火之箭") then
        PlaceAction(10);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("冰枪术") then
        PlaceAction(11);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("法术吸取") then
        PlaceAction(12);
        ClearCursor();
    end;

    if Mage_PickupSpellByBook("寒冰屏障") then
        PlaceAction(61);
        ClearCursor();
    end;

    if Mage_PickupSpellByBook("解除诅咒") then
        PlaceAction(62);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("变形术") then
        PlaceAction(63);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("霜甲术") then
        PlaceAction(64);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("冰甲术") then
        PlaceAction(64);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("法师护甲") then
        PlaceAction(64);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("熔岩护甲") then
        PlaceAction(65);
        ClearCursor();
    end
   if Mage_PickupSpellByBook("冰冷血脉") then
        PlaceAction(66);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("寒冰护体") then
        PlaceAction(67);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("召唤水元素") then
        PlaceAction(68);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("深度冻结") then
        PlaceAction(69);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("急速冷却") then
        PlaceAction(70);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("狮心") then
        PlaceAction(71);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("生存意志") then
        PlaceAction(72);
        ClearCursor();
    end

    if Mage_PickupSpellByBook("奥术智慧") then
        PlaceAction(25);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("奥术光辉") then
        PlaceAction(26);
        ClearCursor();
    end;

    if Mage_PickupSpellByBook("造餐术") then
        PlaceAction(27);
        ClearCursor();
    else
         if Mage_PickupSpellByBook("造水术") then
            PlaceAction(27);
            ClearCursor();
        end
    end
    if Mage_PickupSpellByBook("召唤餐桌") then
        PlaceAction(28);
        ClearCursor();
    else
         if Mage_PickupSpellByBook("造食术") then
            PlaceAction(28);
            ClearCursor();
        end
    end
    if Mage_PickupSpellByBook("魔法增效") then
        PlaceAction(29);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("魔法抑制") then
        PlaceAction(30);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("防护冰霜结界") then
        PlaceAction(31);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("防护火焰结界") then
        PlaceAction(32);
        ClearCursor();
    end

    if Mage_PickupSpellByBook("镜像") then
        PlaceAction(37);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("法力护盾") then
        PlaceAction(38);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("奥术飞弹") then
        PlaceAction(39);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("制造法力宝石") then
        PlaceAction(40);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("缓落术") then
        PlaceAction(41);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("隐形术") then
        PlaceAction(42);
        ClearCursor();
    end;
    if Mage_PickupSpellByBook("专注魔法") then
        PlaceAction(43);
        ClearCursor();
    end


    if Mage_GetMageSpec() == 1 then
        if Mage_PickupSpellByBook("霜火之箭") then
            PlaceAction(1);
            ClearCursor();
        end;
        if Mage_PickupSpellByBook("燃烧") then
            PlaceAction(5);
            ClearCursor();
        end;
        if Mage_PickupSpellByBook("炎爆术") then
            PlaceAction(10);
            ClearCursor();
        end;
        if Mage_PickupSpellByBook("活动炸弹") then
            PlaceAction(65);
            ClearCursor();
        end
        if Mage_PickupSpellByBook("灼烧") then
            PlaceAction(67);
            ClearCursor();
        end
        if Mage_PickupSpellByBook("冲击波") then
            PlaceAction(68);
            ClearCursor();
        end
        if Mage_PickupSpellByBook("龙息术") then
            PlaceAction(69);
            ClearCursor();
        end
        if Mage_PickupSpellByBook("烈焰风暴") then
            PlaceAction(70);
            ClearCursor();
        end
    end;

    if Mage_GetMageSpec() == 2 then
        if Mage_PickupSpellByBook("奥术弹幕") then
            PlaceAction(1);
            ClearCursor();
        end;
        if Mage_PickupSpellByBook("奥术飞弹") then
            PlaceAction(10);
            ClearCursor();
        end;
        if Mage_PickupSpellByBook("奥术冲击") then
            PlaceAction(66);
            ClearCursor();
        end
        if Mage_PickupSpellByBook("减速") then
            PlaceAction(67);
            ClearCursor();
        end
        if Mage_PickupSpellByBook("奥术强化") then
            PlaceAction(68);
            ClearCursor();
        end
        if Mage_PickupSpellByBook("气定神闲") then
            PlaceAction(69);
            ClearCursor();
        end

    end;



    if Mage_PickupSpellByBook("射击") then
        PlaceAction(49);
        ClearCursor();
    end


	SetBinding("NUMLOCK");


	SetBinding("W", "MOVEFORWARD");
	SetBinding("UP", "MOVEFORWARD");
	SetBinding("S", "MOVEBACKWARD");
	SetBinding("DOWN", "MOVEBACKWARD");
	SetBinding("A", "STRAFELEFT");
	SetBinding("D", "STRAFERIGHT");


	SetBinding("CTRL-MOUSEWHEELDOWN", "CAMERAZOOMIN");
	SetBinding("CTRL-MOUSEWHEELUP", "CAMERAZOOMOUT");


    SetBinding("SHIFT-UP");
	SetBinding("SHIFT-DOWN");
	SetBinding("SHIFT-MOUSEWHEELUP");
	SetBinding("SHIFT-MOUSEWHEELDOWN");
	SetBinding("SHIFT-SPACE");
	SetBinding("SHIFT-M");


	SetBinding("CTRL-=");
	SetBinding("CTRL--");
	SetBinding("CTRL-M");
	SetBinding("CTRL-S");


	SetBinding("1", "ACTIONBUTTON1");
	SetBinding("2", "ACTIONBUTTON2");
	SetBinding("3", "ACTIONBUTTON3");
	SetBinding("4", "ACTIONBUTTON4");
	SetBinding("5", "ACTIONBUTTON5");
	SetBinding("6", "ACTIONBUTTON6");
	SetBinding("7", "ACTIONBUTTON7");
	SetBinding("8", "ACTIONBUTTON8");
	SetBinding("9", "ACTIONBUTTON9");
	SetBinding("0", "ACTIONBUTTON10");
	SetBinding("-", "ACTIONBUTTON11");
	SetBinding("=", "ACTIONBUTTON12");


	SetBinding("F1", "MULTIACTIONBAR1BUTTON1");
	SetBinding("F2", "MULTIACTIONBAR1BUTTON2");
	SetBinding("F3", "MULTIACTIONBAR1BUTTON3");
	SetBinding("]", "MULTIACTIONBAR1BUTTON4");
	SetBinding("F5", "MULTIACTIONBAR1BUTTON5");
	SetBinding("F6", "MULTIACTIONBAR1BUTTON6");
	SetBinding("F7", "MULTIACTIONBAR1BUTTON7");
	SetBinding("F8", "MULTIACTIONBAR1BUTTON8");
	SetBinding("F9", "MULTIACTIONBAR1BUTTON9");
	SetBinding("F10", "MULTIACTIONBAR1BUTTON10");
	SetBinding("F11", "MULTIACTIONBAR1BUTTON11");
	SetBinding("F12", "MULTIACTIONBAR1BUTTON12");


	SetBinding("SHIFT-F1", "MULTIACTIONBAR3BUTTON1");
	SetBinding("SHIFT-F2", "MULTIACTIONBAR3BUTTON2");
	SetBinding("SHIFT-F3", "MULTIACTIONBAR3BUTTON3");
	SetBinding("SHIFT-]", "MULTIACTIONBAR3BUTTON4");
	SetBinding("SHIFT-F5", "MULTIACTIONBAR3BUTTON5");
	SetBinding("SHIFT-F6", "MULTIACTIONBAR3BUTTON6");
	SetBinding("SHIFT-F7", "MULTIACTIONBAR3BUTTON7");
	SetBinding("SHIFT-F8", "MULTIACTIONBAR3BUTTON8");
	SetBinding("SHIFT-F9", "MULTIACTIONBAR3BUTTON9");
	SetBinding("SHIFT-F10", "MULTIACTIONBAR3BUTTON10");
	SetBinding("SHIFT-F11", "MULTIACTIONBAR3BUTTON11");
	SetBinding("SHIFT-F12", "MULTIACTIONBAR3BUTTON12");

	SetBinding("CTRL-F1", "MULTIACTIONBAR4BUTTON1");
	SetBinding("CTRL-F2", "MULTIACTIONBAR4BUTTON2");
	SetBinding("CTRL-F3", "MULTIACTIONBAR4BUTTON3");
	SetBinding("CTRL-]", "MULTIACTIONBAR4BUTTON4");
	SetBinding("CTRL-F5", "MULTIACTIONBAR4BUTTON5");
	SetBinding("CTRL-F6", "MULTIACTIONBAR4BUTTON6");
	SetBinding("CTRL-F7", "MULTIACTIONBAR4BUTTON7");
	SetBinding("CTRL-F8", "MULTIACTIONBAR4BUTTON8");
	SetBinding("CTRL-F9", "MULTIACTIONBAR4BUTTON9");
	SetBinding("CTRL-F10", "MULTIACTIONBAR4BUTTON10");
	SetBinding("CTRL-F11", "MULTIACTIONBAR4BUTTON11");
	SetBinding("CTRL-F12", "MULTIACTIONBAR4BUTTON12");

    Mage_AddMessage("自动奔跑 : `键(ESC键下一个)");
    Mage_AddMessage("施放暴风雪/烈焰风暴 : R键");
    Mage_AddMessage("施放闪现术 : Q键(");
    Mage_AddMessage("施放变形术 : F键");
    Mage_AddMessage("施放唤醒 : T键");
    SetBinding("`", "TOGGLEAUTORUN");

end;