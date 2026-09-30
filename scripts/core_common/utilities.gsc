isInMenu()
{
    if (!isDefined(self.playerSetting["isInMenu"]))
        return false;
    return true;
}

hasMenu()
{
    return self IsHost();
}

getCurrent()
{
    return self.menu["currentMenu"];
}

getCursor()
{
    return self.menu["curs"][self getCurrent()];
}

setCursor(curs)
{
    self.menu["curs"][self getCurrent()] = curs;
}

BackMenu()
{
    return self.menuParent[(self.menuParent.size - 1)];
}

PrintToLevel(message)
{
    self iPrintLn(message);
}

PrintHint(message)
{
    self iPrintLnBold(message);
}

PrintedControls()
{
    self endon("disconnect");
    self endon("game_ended");

    controls = [];
    controls[0] = "^3呼出 ^1[{+speed_throw}]+[{+melee}]";
    controls[1] = "^3滚动 ^1[{+speed_throw}] / [{+attack}]";
    controls[2] = "^3确认 ^1[{+activate}]^3，返回 ^1[{+melee}]";

    for (;;)
    {
        for (i = 0; i < controls.size; i++)
        {
            if (self isInMenu())
                break;
            self PrintHint(controls[i]);
            wait 5;
        }
        wait 1;
    }
}
