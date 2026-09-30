init()
{
    self endon("disconnect", #"end_game");
    level thread InitializeVarsPrecaches();

    level thread EssenceScrapFloorLoop();
}

onPlayerSpawned()
{
    self endon("disconnect", #"end_game");

    if (level flag::exists("start_zombie_round_logic") && !level flag::get("start_zombie_round_logic"))
    {
        level flag::wait_till("start_zombie_round_logic");
    }

    if (!isDefined(self.menuThreaded))
        self thread playerSetup();
}

InitializeVarsPrecaches()
{
    if (isDefined(level.InitializeVarsPrecaches))
        return;

    level.InitializeVarsPrecaches = true;
    CnBocwMenuConfig();
}

playerSetup()
{
    if (isDefined(self.menuThreaded))
        return;

    self defineVariables();

    if (!self IsHost())
    {
        self.menuThreaded = true;
        return;
    }

    wait 10;
    self PrintToLevel("^3欢迎使用^1" + ProjectName());
    self PrintToLevel("^3本脚本^2免费、^1开源");
    self PrintToLevel("^3呼出菜单请按^1 [{+speed_throw}]+[{+melee}]");
    self thread PrintedControls();
    self thread menuMonitor();
    self.menuThreaded = true;
}

defineVariables()
{
    if (isDefined(self.DefinedVariables))
        return;
    self.DefinedVariables = true;

    if (!isDefined(self.menu))
        self.menu = [];
    if (!isDefined(self.playerSetting))
        self.playerSetting = [];
    if (!isDefined(self.menu["curs"]))
        self.menu["curs"] = [];

    self.playerSetting["isInMenu"] = undefined;
    self.menu["currentMenu"] = "Main";
    self.menu["curs"][self.menu["currentMenu"]] = 0;
}
