ProjectName()
{
    return "^7BOCW 僵尸模式 GSC菜单";
}

ItemSuffix(menu, index)
{
    if (isDefined(self.menu["items"][menu].bool[index]))
    {
        if (isDefined(self.menu_B[menu][index]) && self.menu_B[menu][index])
            return " ^2已启用";
        return "";
    }
    return "";
}

drawTextHina()
{
    self endon("menuClosed");
    self endon("disconnect");

    if (!isDefined(self.menu["curs"][self getCurrent()]))
        self.menu["curs"][self getCurrent()] = 0;

    menu = self getCurrent();
    items = self.menu["items"][menu].name;
    curs = self getCursor();
    total = items.size;
    self.lastRefresh = getTime();

    if (total == 0)
    {
        self PrintToLevel(ProjectName() + "^3 : [0/0]");
        self PrintToLevel("^1(空菜单)");
        self PrintToLevel("");
        return;
    }

    title = ProjectName();
    if (isDefined(self.menuParent) && self.menuParent.size > 0 && isDefined(self.menu["items"][menu].title))
        title += "^3 / " + self.menu["items"][menu].title;
    title += "^3 : [" + (curs + 1) + "/" + total + "]";
    self PrintToLevel(title);

    str = items[curs];
    self PrintToLevel("^7>> ^5" + str + self ItemSuffix(menu, curs));

    if (curs + 1 < total)
        self PrintToLevel("^7   " + items[curs + 1] + self ItemSuffix(menu, curs + 1));
    else
        self PrintToLevel("");
}
