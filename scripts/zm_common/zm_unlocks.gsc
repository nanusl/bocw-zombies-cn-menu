UnlockDarkAether()
{
    if (isdefined(self.unlock_da_run))
    {
        self PrintHint("^3正在解锁黑暗乙太迷彩");
        return;
    }
    if (!isdefined(level._menuweapons))
    {
        self PrintHint("^1武器表未初始化");
        return;
    }

    self.unlock_da_run = 1;
    saved = self getcurrentweapon();
    idx = 0;
    foreach (w in level._menuweapons)
    {
        weapon = getweapon(w);
        idx++;
        if (!isdefined(weapon) || weapon == level.weaponnone)
            continue;

        curr = self getcurrentweapon();
        if (isdefined(curr) && self hasweapon(curr) && curr != saved)
            self takeweapon(curr);

        self giveweapon(weapon);
        self switchtoweapon(weapon);
        wait 0.45;
        self PrintHint("^5黑暗乙太迷彩 " + idx + "/" + level._menuweapons.size);

        tokill = 10;
        tries = 0;
        while (tokill > 0 && tries < 50)
        {
            zombies = getaiteamarray(level.zombie_team);
            if (isdefined(zombies))
            {
                foreach (zombie in zombies)
                {
                    if (!isdefined(zombie) || !isalive(zombie))
                        continue;
                    if (is_true(zombie.cnbocw_friendly) || is_true(zombie.aat_turned) || zombie.team === #"allies")
                        continue;
                    zombie dodamage(zombie.maxhealth + 666, zombie.origin, self);
                    tokill--;
                    if (tokill <= 0)
                        break;
                }
            }
            tries++;
            waitframe(1);
        }

        self addrankxpvalue("kills", 10000);
        self addrankxpvalue("kill", 10000);
        self addrankxpvalue("ekia", 10000);
        self addrankxpvalue("match_end_xp", 23000, 3);
        self addweaponstat(weapon, #"kills", 52486400);
        self addweaponstat(weapon, #"hash_46422decc5803401", 52486400);
        self addweaponstat(weapon, #"packedkills", 52486400);
        self addweaponstat(weapon, #"hash_9c59d60380f570a", 15);
        self addweaponstat(weapon, #"multikill", 52486400);
        self addweaponstat(weapon, #"hash_5870df5ed04a8f11", 25);
        self addweaponstat(weapon, #"hash_1f3b0d3bd9acb4a5", 10);
        self addweaponstat(weapon, #"rapidkills", 50000);
        self addweaponstat(weapon, #"hash_72467b6043fb9ef7", 10000);
        self addweaponstat(weapon, #"hash_1f451bc4d664e2ad", 50);
        self addweaponstat(weapon, #"hash_16ef903a11cc4173", 15);
        self addweaponstat(weapon, #"ekia", 52486400);
        self addweaponstat(weapon, #"hash_14b7133a39a0456e", 52486400);
        self addweaponstat(weapon, #"hash_49b586d05aaa0209", 25000);
        self addweaponstat(weapon, #"challenges", 35);
        self addweaponstat(weapon, #"hash_7fce4a14fec05da1", 1);
        self addweaponstat(weapon, #"hash_404a29a3ead5edb3", 1);
        self addweaponstat(weapon, #"hash_141b0e8dbfaf9468", 1);
        self addweaponstat(weapon, #"hash_7f0ce2a2e0a76e67", 2);
        self addweaponstat(weapon, #"hash_5a2ba340560103b3", 1);
        self addweaponstat(weapon, #"hash_4711f96a09147c", 9);
        self addweaponstat(weapon, #"hash_4714f96a091995", 7);
        self addweaponstat(weapon, #"hash_4713f96a0917e2", 5);
        self addweaponstat(weapon, #"hash_440a913b1fa5afba", 3);
        self stats::set_stat(#"hash_60e21f66eb3a1f18", weapon, #"xp", 52486400);
        self stats::set_stat(#"item_stats", weapon.name, #"challenges", #"challengevalue", 35);

        if (self hasweapon(weapon) && weapon != saved)
            self takeweapon(weapon);
        wait 0.05;
    }

    if (isdefined(saved) && saved != level.weaponnone && !self hasweapon(saved))
    {
        self giveweapon(saved);
        self switchtoweapon(saved);
    }

    self stats::set_stat(#"globalchallenges", #"weapons_mastery", #"challengetier", 9);
    uploadstats(self);
    self.unlock_da_run = undefined;
    self PrintHint("^5黑暗乙太迷彩 ^2已解锁");
}

ToggleXpGrind()
{
    self.xp_grind = isDefined(self.xp_grind) ? undefined : true;
    if (isDefined(self.xp_grind))
    {
        self PrintHint("^5静默刷 XP ^2已启用");
        self thread XpGrindThink();
    }
    else
    {
        self notify(#"stop_xp_grind");
        self PrintHint("^5静默刷 XP ^1已关闭");
    }
}

XpGrindThink()
{
    self endon("disconnect");
    self endon(#"stop_xp_grind");
    while (isDefined(self.xp_grind))
    {
        self incrementplayerstat("kills", 100);
        self incrementplayerstat("kills_critical", 150);
        self incrementplayerstat("kills_elite", 10);
        self incrementplayerstat("headshots", 20);
        self incrementplayerstat("distance_traveled", 800);
        self incrementplayerstat("time_played_total", 8);
        self incrementplayerstat("weighted_rounds_played", 1);
        self incrementplayerstat("doors_purchased", 5);
        self incrementplayerstat("grenade_kills", 30);
        self incrementplayerstat("melee_kills", 2);
        self addrankxpvalue("kills", 250);
        self addrankxpvalue("kill", 250);
        self addrankxpvalue("ekia", 250);
        uploadstats(self);
        wait randomintrange(1, 11);
    }
}

UnlockZmChallenges()
{
    if (isdefined(self.unlock_ch_run))
    {
        self PrintHint("^3正在完成僵尸挑战");
        return;
    }

    self.unlock_ch_run = 1;
    weapon = self getcurrentweapon();
    tableid = 1;
    while (tableid <= 6)
    {
        tablename = #"gamedata/stats/zm/statsmilestones" + tableid + ".csv";
        rows = tablelookuprowcount(tablename);
        if (!isdefined(rows) || rows <= 0)
        {
            tableid++;
            continue;
        }

        row = 0;
        while (row < rows)
        {
            value = tablelookupcolumnforrow(tablename, row, 2);
            name = tablelookupcolumnforrow(tablename, row, 4);
            if (isdefined(name))
            {
                self stats::function_dad108fa(name, value);
                self stats::function_42277145(name, value);
                if (isdefined(weapon) && weapon != level.weaponnone)
                    self stats::function_e24eec31(weapon, name, value);
            }
            if (row % 8 == 0)
                self PrintHint("^5僵尸挑战 表" + tableid + " " + (row + 1) + "/" + rows);
            wait 0.05;
            row++;
        }
        tableid++;
    }

    uploadstats(self);
    self.unlock_ch_run = undefined;
    self PrintHint("^5全部僵尸挑战 ^2已完成");
}

UnlockAllTrophies()
{
    trophies = GetTrophyList();
    i = 0;
    foreach (id in trophies)
    {
        self zm_utility::give_achievement(id);
        i++;
        if (i % 5 == 0)
            self PrintHint("^5成就 " + i + "/" + trophies.size);
        wait 0.1;
    }
    uploadstats(self);
    self PrintHint("^5成就全开 ^2完成");
}

GetTrophyList()
{
    return array(#"hash_8d1920cf39e4c14", #"hash_b97db915a42a356", #"hash_be13d1076856219", #"hash_1215c0ed5cbc40b2", #"hash_12bde4bff49c66ca", #"hash_1734e93ba3a2bcc5", #"hash_20e72f8d6f572262", #"hash_21ba7b916636a235", #"hash_26c877bc3e2d96e7", #"hash_2cd993420c84660c", #"hash_2e8492b0fa87ecf6", #"hash_2f586e4c7661915f", #"hash_351cedf964a5cf11", #"hash_53a13cdbd8cdf8d7", #"hash_54fff7449654db1a", #"hash_59fd1356bba820b2", #"hash_6436e34c054bc185", #"hash_6564dfd45c6715ce", #"hash_6d9871f78dd8004a", #"hash_6e3165439b9bf116", #"hash_779bbce9266d0ae6", #"hash_77ead6a0a6cb5248", #"hash_7b24bebf11150d62", #"hash_7cfe4a58cd11b4f5", #"hash_7f83a4601ad1744d", #"hash_c33cd90f4b67bfe", #"hash_16b2ec90fb2e0c3b", #"hash_309368ef8f9b86a3", #"hash_47d5fff4205db171", #"hash_53c6bfe9f5d68f47", #"hash_5faa668391e3d463", #"hash_5fb48c8391ec697a", #"hash_6567a09c3046170f", #"hash_69455e37009492aa", #"hash_ed510979375c908", #"hash_284d0b2a070bfb79", #"hash_3f780d94296c68c6", #"hash_4ab5f04a4e88fd55", #"hash_5f4e85a66456e98b", #"hash_134e3e238f070bf6", #"hash_2670a9f559576876", #"hash_4fd5239967bfd36e", #"hash_79b5e565395ad617", #"hash_7fc3515d8479dc7a", #"hash_3c8fbebec2f463f5", #"hash_6703984223a2809c", #"hash_2deb5f76757c411d");
}

ApplyCamo(id)
{
    currentweapon = self getcurrentweapon();
    if (isdefined(currentweapon))
    {
        self setcamo(currentweapon, id);
        self PrintHint("^5迷彩 " + id);
    }
}

OpenCamoRange(start)
{
    self.camo_id_start = start;
    self newMenu("CamoRange");
}

ApplySkin(id)
{
    self setspecialistindex(id);
    self setcharacteroutfit(0);
    self setcharacterwarpaintoutfit(0);
    self function_ab96a9b5("head", 0);
    self function_ab96a9b5("headgear", 0);
    self function_ab96a9b5("arms", 0);
    self function_ab96a9b5("torso", 0);
    self function_ab96a9b5("legs", 0);
    self function_ab96a9b5("palette", 0);
    self function_ab96a9b5("warpaint", 0);
    self function_ab96a9b5("decal", 0);
    self PrintHint("^5特战兵已切换");
}

ApplyOutfit(id)
{
    self setcharacteroutfit(id);
    self setcharacterwarpaintoutfit(0);
    self PrintHint("^5皮肤 " + id);
}
