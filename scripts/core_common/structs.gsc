addMenu(menu, title)
{
    if (!isDefined(self.menu["items"]))
        self.menu["items"] = [];
    if (!isDefined(self.menu["items"][menu]))
        self.menu["items"][menu] = SpawnStruct();
    if (!isDefined(self.menuParent))
        self.menuParent = [];
    if (!isDefined(self.temp))
        self.temp = [];
    if (isDefined(title))
        self.menu["items"][menu].title = title;
    if (isDefined(menu))
        self.temp["memory"] = menu;

    self.menu["items"][menu].name = [];
    self.menu["items"][menu].func = [];
    self.menu["items"][menu].input1 = [];
    self.menu["items"][menu].input2 = [];
    self.menu["items"][menu].bool = [];

    if (!isDefined(self.menu_B))
        self.menu_B = [];
    if (!isDefined(self.menu_B[menu]))
        self.menu_B[menu] = [];
}

addOpt(name, func, input1, input2)
{
    menu = self.temp["memory"];
    count = self.menu["items"][menu].name.size;

    if (isDefined(name))
        self.menu["items"][menu].name[count] = name;
    if (isDefined(func))
        self.menu["items"][menu].func[count] = func;
    if (isDefined(input1))
        self.menu["items"][menu].input1[count] = input1;
    if (isDefined(input2))
        self.menu["items"][menu].input2[count] = input2;
}

addOptBool(var, name, func, input1, input2)
{
    menu = self.temp["memory"];
    count = self.menu["items"][menu].name.size;

    if (isDefined(name))
        self.menu["items"][menu].name[count] = name;
    if (isDefined(func))
        self.menu["items"][menu].func[count] = func;
    if (isDefined(input1))
        self.menu["items"][menu].input1[count] = input1;
    if (isDefined(input2))
        self.menu["items"][menu].input2[count] = input2;
    self.menu["items"][menu].bool[count] = true;
    self.menu_B[menu][count] = (isDefined(var) && var) ? true : undefined;
}

newMenu(menu)
{
    self endon("disconnect");
    self endon("menuClosed");

    if (!isDefined(menu))
    {
        menu = self BackMenu();
        self.menuParent[(self.menuParent.size - 1)] = undefined;
    }
    else
        self.menuParent[self.menuParent.size] = self getCurrent();

    if (!isDefined(self.menu["curs"][menu]))
        self.menu["curs"][menu] = 0;

    self.menu["currentMenu"] = menu;
    self runMenuIndex(menu);
    self drawTextHina();
}
