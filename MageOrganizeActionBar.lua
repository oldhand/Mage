

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

    if Mage_PickupSpellByBook("圣光审判") then
        PlaceAction(1);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("奉献") then
        PlaceAction(2);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("制裁之锤") then
        PlaceAction(3);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("圣光闪现") then
        PlaceAction(4);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("圣光术") then
        PlaceAction(5);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("神圣震击") then
        PlaceAction(6);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("神恩术") then
        PlaceAction(7);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("愤怒之锤") then
        PlaceAction(8);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("圣光道标") then
        PlaceAction(9);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("智慧审判") then
        PlaceAction(10);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("智慧圣印") then
        PlaceAction(11);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("神启") then
        PlaceAction(12);
        ClearCursor();
    end

    if Mage_PickupSpellByBook("圣盾术") then
        PlaceAction(61);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("圣疗术") then
        PlaceAction(62);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("纯净术") then
        PlaceAction(63);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("清洁术") then
        PlaceAction(64);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("圣佑术") then
        PlaceAction(65);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("自由之手") then
        PlaceAction(66);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("保护之手") then
        PlaceAction(67);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("神圣恳求") then
        PlaceAction(68);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("圣洁护盾") then
        PlaceAction(69);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("复仇之怒") then
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


    if Mage_PickupSpellByBook("救赎") then
        PlaceAction(25);
        ClearCursor();
    end

    if Mage_PickupSpellByBook("智慧祝福") then
        PlaceAction(26);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("强效智慧祝福") then
        PlaceAction(27);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("王者祝福") then
        PlaceAction(28);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("强效王者祝福") then
        PlaceAction(29);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("力量祝福") then
        PlaceAction(30);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("强效力量祝福") then
        PlaceAction(31);
        ClearCursor();
    end
   if Mage_PickupSpellByBook("正义之怒") then
        PlaceAction(32);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("正义防御") then
        PlaceAction(33);
        ClearCursor();
    end


    if Mage_PickupSpellByBook("正义圣印") then
        PlaceAction(37);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("驱邪术") then
        PlaceAction(38);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("清算之手") then
        PlaceAction(39);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("牺牲之手") then
        PlaceAction(40);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("拯救之手") then
        PlaceAction(41);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("神圣愤怒") then
        PlaceAction(42);
        ClearCursor();
    end



    if Mage_PickupSpellByBook("神圣牺牲") then
        PlaceAction(47);
        ClearCursor();
    end
    if Mage_PickupSpellByBook("神圣干涉") then
        PlaceAction(48);
        ClearCursor();
    end


    if Mage_PickupSpellByBook("攻击") then
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
	SetBinding("SHIFT-1");
	SetBinding("SHIFT-2");
	SetBinding("SHIFT-3");
	SetBinding("SHIFT-4");
	SetBinding("SHIFT-5");
	SetBinding("SHIFT-6");

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
    SetBinding("`", "TOGGLEAUTORUN");

end;