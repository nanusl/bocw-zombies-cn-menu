menuMonitor()
{
    self endon("disconnect");

    while (true)
    {
        if (self hasMenu())
        {
            if (!self isInMenu())
            {
                if (self AdsButtonPressed() && self MeleeButtonPressed() && !isDefined(self.menu["DisableMenuControls"]))
                {
                    if (isDefined(self.menu["currentMenu"]) && self.menu["currentMenu"] != "")
                        menu = self.menu["currentMenu"];
                    else
                        menu = "Main";

                    self openMenu1(menu);
                    self PrintHint("^3滚动 [{+speed_throw}] [{+attack}] ^3| 确认 [{+activate}] ^3| 返回 [{+melee}]");
                    wait 0.25;
                }
            }
            else if (self isInMenu() && !isDefined(self.menu["DisableMenuControls"]))
            {
                if (self AdsButtonPressed() || self AttackButtonPressed())
                {
                    if (!self AdsButtonPressed() || !self AttackButtonPressed())
                    {
                        menu = self getCurrent();
                        self.menu["curs"][menu] += self AttackButtonPressed();
                        self.menu["curs"][menu] -= self AdsButtonPressed();

                        arry = self.menu["items"][self getCurrent()].name;
                        curs = self getCursor();
                        if (curs < 0 || curs > (arry.size - 1))
                            self setCursor((curs < 0) ? (arry.size - 1) : 0);

                        self drawTextHina();
                        wait 0.13;
                    }
                }
                else if (self UseButtonPressed())
                {
                    menu = self getCurrent();
                    curs = self getCursor();

                    if (isDefined(self.menu["items"][menu].func[curs]))
                    {
                        self thread ExecuteFunction(self.menu["items"][menu].func[curs], self.menu["items"][menu].input1[curs], self.menu["items"][menu].input2[curs]);
                        if (isDefined(self.menu["items"][menu].bool[curs]))
                        {
                            waitframe(1);
                            self RefreshMenu();
                        }
                        wait 0.2;
                    }
                }
                else if (self MeleeButtonPressed())
                {
                    if (self getCurrent() == "Main")
                        self closeMenu1();
                    else
                        self newMenu();
                    wait 0.2;
                }
            }
        }
        wait 0.05;
    }
}

ExecuteFunction(function, i1, i2, i3, i4)
{
    if (!isDefined(function))
        return;

    if (isDefined(i4))
        return self thread [[ function ]](i1, i2, i3, i4);
    if (isDefined(i3))
        return self thread [[ function ]](i1, i2, i3);
    if (isDefined(i2))
        return self thread [[ function ]](i1, i2);
    if (isDefined(i1))
        return self thread [[ function ]](i1);

    return self thread [[ function ]]();
}

RefreshMenu()
{
    if (self hasMenu() && self isInMenu())
    {
        self runMenuIndex(self getCurrent());
        self drawTextHina();
    }
}

openMenu1(menu)
{
    if (!isDefined(menu))
        menu = "Main";
    if (!isDefined(self.menu["curs"][menu]))
        self.menu["curs"][menu] = 0;
    self.menu["currentMenu"] = menu;
    self runMenuIndex(menu);
    self.playerSetting["isInMenu"] = true;
    self thread MonitorMenuRefresh();
}

MonitorMenuRefresh()
{
    self endon("disconnect");
    self endon("menuClosed");

    if (self isInMenu())
    {
        self drawTextHina();
        while (self isInMenu())
        {
            if (self.lastRefresh < getTime() - 4000)
                self drawTextHina();
            wait 1;
        }
    }
}

closeMenu1()
{
    self notify("menuClosed");
    self DestroyOpts();
    self.playerSetting["isInMenu"] = undefined;
}

DestroyOpts()
{
    for (a = 0; a < 3; a++)
        self iPrintLn("");
}
