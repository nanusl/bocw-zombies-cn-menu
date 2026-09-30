GiveWeaponAsItem(weapon)
{
    if (!isdefined(weapon) || !isdefined(weapon.name))
        return 0;

    str_item = weapon.name + "_item_sr";
    if (weapon.name == #"knife_loadout")
        str_item = "knife_loadout_t9_item_sr";

    point = function_4ba8fde(str_item);
    if (!isdefined(point))
        return 0;

    if (!zm_loadout::is_melee_weapon(weapon) && !zm_loadout::is_tactical_grenade(weapon) && !zm_loadout::is_lethal_grenade(weapon))
    {
        primaries = self getweaponslistprimaries();
        if (isdefined(primaries) && primaries.size >= 2)
        {
            cur = self getcurrentweapon();
            if (isdefined(cur) && self hasweapon(cur) && !zm_loadout::is_melee_weapon(cur))
                self takeweapon(cur);
        }
    }

    given = self zm_weapons::function_943eabd9(point, 1);
    waitframe(1);
    if (isdefined(given) && given != level.weaponnone)
    {
        self switchtoweapon(given);
        self givemaxammo(given);
        return 1;
    }

    return isdefined(self item_inventory::function_230ceec4(self getcurrentweapon()));
}

GivePlayerWeapon(WeaponName)
{
    Weapon = getweapon(ishash(WeaponName) ? WeaponName : hash(WeaponName));
    if (!isDefined(Weapon) || Weapon == level.weaponnone)
    {
        self PrintHint("^1武器无效");
        return;
    }

    if (self hasweapon(Weapon) && isdefined(self item_inventory::function_230ceec4(Weapon)))
    {
        self switchtoweapon(Weapon);
        self givemaxammo(Weapon);
        self PrintHint("^5已切换该武器");
        return;
    }

    if (self hasweapon(Weapon))
        self takeweapon(Weapon);

    if (self GiveWeaponAsItem(Weapon))
    {
        self PrintHint("^5已给予武器");
        return;
    }

    self giveweapon(Weapon);
    if (!zm_loadout::is_tactical_grenade(Weapon) && !zm_loadout::is_lethal_grenade(Weapon))
        self switchtoweapon(Weapon);
    self givemaxammo(Weapon);
    self PrintHint("^5已给予武器");
}

DropCurrentWeapon()
{
    weapon = self GetCurrentWeapon();
    if (isdefined(weapon) && weapon != level.weaponnone)
    {
        self takeweapon(weapon);
        self PrintHint("^5已丢掉当前武器");
    }
}

PapWeapon(chalice)
{
    if (!isdefined(chalice))
        chalice = "gold_chalice_item_sr";
    self thread namespace_1cc7b406::give_item(chalice);
    self playsound("zmb_powerup_chalice_gold_pickup");
    self PrintHint("^5PAP 圣杯已应用");
}

RarityUp()
{
    self thread namespace_1cc7b406::give_item("aether_tool_item_sr");
    self playsound("zmb_powerup_aethertool_pickup");
    self PrintHint("^5以太扳手已应用");
}

AllAatNames()
{
    ids = [];
    ids[0] = "ammomod_deadwire";
    ids[1] = "ammomod_napalmburst";
    ids[2] = "ammomod_cryofreeze";
    ids[3] = "ammomod_brainrot";
    ids[4] = "ammomod_shatterblast";
    return ids;
}

ToggleAllAat()
{
    self.all_aat = isDefined(self.all_aat) ? undefined : true;
    if (isDefined(self.all_aat))
    {
        EnhanceAatCooldowns();
        self thread AllAatThink();
        self PrintHint("^5增强弹药模组 ^2已启用");
    }
    else
    {
        self notify(#"stop_all_aat");
        self.menu_aat = undefined;
        self.var_2defbefd = undefined;
        weapon = self getcurrentweapon();
        if (isdefined(weapon) && weapon != level.weaponnone)
            self zm_weapons::function_51897592(weapon);
        self PrintHint("^5增强弹药模组 ^1已关闭");
    }
}

EnhanceAatCooldowns()
{
    if (isdefined(level.enhance_aat_done) || !isdefined(level.aat))
        return;

    level.enhance_aat_done = 1;
    keys = getarraykeys(level.aat);
    foreach (name in keys)
    {
        if (!isdefined(level.aat[name]))
            continue;
        level.aat[name].cooldown_time_entity = 0;
        level.aat[name].cooldown_time_attacker = 0;
        level.aat[name].cooldown_time_global = 0;
        level.aat[name].cooldown_time_global_start = 0;
        level.aat[name].percentage = 1;
    }
}

AllAatThink()
{
    self endon("disconnect");
    self endon(#"stop_all_aat");
    ids = self AllAatNames();
    i = 0;
    while (isDefined(self.all_aat))
    {
        self.var_2defbefd = 1;
        self.menu_aat = ids[i];
        weapon = self getcurrentweapon();
        if (isdefined(weapon) && weapon != level.weaponnone)
            self zm_weapons::function_e1fd87b0(weapon, ids[i]);
        i++;
        if (i >= ids.size)
            i = 0;
        wait 0.15;
    }
}

GiveKillstreak(streakName)
{
    self killstreaks::give(streakName);
    self PrintHint("^5已给予连杀奖励");
}


