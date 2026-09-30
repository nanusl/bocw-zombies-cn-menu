ToggleGod()
{
    self.godmode = isDefined(self.godmode) ? undefined : true;
    if (isDefined(self.godmode))
    {
        self PrintHint("^5无敌 ^2已启用");
        self endon("disconnect");
        while (isDefined(self.godmode))
        {
            self EnableInvulnerability();
            wait 0.1;
        }
    }
    else
    {
        self PrintHint("^5无敌 ^1已关闭");
        self DisableInvulnerability();
    }
}

ToggleIgnore()
{
    self.tool_ignore = isDefined(self.tool_ignore) ? undefined : true;
    if (isDefined(self.tool_ignore))
    {
        self val::set(#"cnbocwmenu", "ignoreme", 1);
        self PrintHint("^5无视 ^2已启用");
    }
    else
    {
        self val::reset(#"cnbocwmenu", "ignoreme");
        self PrintHint("^5无视 ^1已关闭");
    }
}

ToggleThirdPerson()
{
    self.tool_third = isDefined(self.tool_third) ? undefined : true;
    if (isDefined(self.tool_third))
    {
        self setclientthirdperson(1);
        self PrintHint("^5第三人称 ^2已启用");
    }
    else
    {
        self setclientthirdperson(0);
        self PrintHint("^5第三人称 ^1已关闭");
    }
}

ToggleAmmo()
{
    self.UnlimitedAmmo = isDefined(self.UnlimitedAmmo) ? undefined : true;
    if (isDefined(self.UnlimitedAmmo))
    {
        self PrintHint("^5无限弹药 ^2已启用");
        self endon("disconnect");
        while (isDefined(self.UnlimitedAmmo))
        {
            weapons = self getweaponslist();
            foreach (weapon in weapons)
            {
                if (!isdefined(weapon) || weapon == level.weaponnone)
                    continue;
                if (zm_loadout::is_tactical_grenade(weapon) || zm_loadout::is_lethal_grenade(weapon) || zm_equipment::is_equipment(weapon))
                    continue;
                if (weapon.isgadget)
                {
                    slot = self gadgetgetslot(weapon);
                    if (isdefined(slot) && slot >= 0 && self gadgetpowerget(slot) < 100)
                        self gadgetpowerset(slot, 100);
                }
                else
                {
                    self givemaxammo(weapon);
                    self setweaponammoclip(weapon, weapon.clipsize);
                }
            }
            wait 0.05;
        }
    }
    else
        self PrintHint("^5无限弹药 ^1已关闭");
}

ToggleUnlimitedEquipment()
{
    self.unlimited_equipment = isDefined(self.unlimited_equipment) ? undefined : true;
    if (isDefined(self.unlimited_equipment))
    {
        self PrintHint("^5无限道具 ^2已启用");
        self thread UnlimitedEquipmentThink();
    }
    else
    {
        self notify(#"stop_unlimited_equipment");
        self PrintHint("^5无限道具 ^1已关闭");
    }
}

RefillInventoryEquipment()
{
    if (!isdefined(self.inventory) || !isdefined(self.inventory.items))
        return;

    // Inventory slot 7: lethal equipment
    if (isdefined(self.inventory.items[7]) && self.inventory.items[7].networkid !== 32767)
    {
        item = self.inventory.items[7];
        max_stack = (isdefined(item.itementry) && isdefined(item.itementry.stackcount) && item.itementry.stackcount > 0) ? item.itementry.stackcount : 2;
        if (item.count != max_stack)
        {
            item.count = max_stack;
            self clientfield::set_player_uimodel("hudItems.equipmentStackCount", max_stack);
        }
        if (isdefined(item.itementry) && isdefined(item.itementry.weapon))
            self RefillHeldOffhand(item.itementry.weapon, max_stack);
    }

    // Inventory slot 13: tactical equipment
    if (isdefined(self.inventory.items[13]) && self.inventory.items[13].networkid !== 32767)
    {
        item = self.inventory.items[13];
        max_stack = (isdefined(item.itementry) && isdefined(item.itementry.stackcount) && item.itementry.stackcount > 0) ? item.itementry.stackcount : 2;
        if (item.count != max_stack)
        {
            item.count = max_stack;
        }
        if (isdefined(item.itementry) && isdefined(item.itementry.weapon))
            self RefillHeldOffhand(item.itementry.weapon, max_stack);
    }
}

RefillHeldOffhand(weapon, target_count)
{
    if (!isdefined(weapon) || weapon == level.weaponnone)
        return;
    if (!self hasweapon(weapon))
        return;

    clip = (isdefined(weapon.clipsize) && weapon.clipsize >= 1) ? weapon.clipsize : 1;
    self setweaponammoclip(weapon, clip);

    max = isdefined(target_count) ? target_count : ((isdefined(weapon.maxammo) && weapon.maxammo >= 1) ? weapon.maxammo : 2);
    self setweaponammostock(weapon, max);

    if (is_true(weapon.isgadget))
    {
        slot = self gadgetgetslot(weapon);
        if (isdefined(slot) && slot >= 0 && self gadgetpowerget(slot) < 100)
            self gadgetpowerset(slot, 100);
    }
}

DoRefillEquipment()
{
    self RefillInventoryEquipment();

    offhand = self getcurrentoffhand();
    if (isdefined(offhand) && offhand != level.weaponnone)
        self RefillHeldOffhand(offhand);
}

MonitorEquipmentFire()
{
    self endon("disconnect");
    self endon(#"stop_unlimited_equipment");

    while (isDefined(self.unlimited_equipment))
    {
        self waittill(#"grenade_fire", #"missile_fire", #"offhand_fire", #"weapon_change");
        waitframe(1);
        self DoRefillEquipment();
    }
}

UnlimitedEquipmentThink()
{
    self endon("disconnect");
    self endon(#"stop_unlimited_equipment");

    self thread MonitorEquipmentFire();

    while (isDefined(self.unlimited_equipment))
    {
        if (!isalive(self))
        {
            wait 0.5;
            continue;
        }

        self DoRefillEquipment();
        wait 0.25;
    }
}

ToggleUnlimitedFieldUpgrade()
{
    self.unlimited_field_upgrade = isDefined(self.unlimited_field_upgrade) ? undefined : true;
    if (isDefined(self.unlimited_field_upgrade))
    {
        self PrintHint("^5无限战场升级 ^2已启用");
        self thread UnlimitedFieldUpgradeThink();
    }
    else
    {
        self notify(#"stop_unlimited_field_upgrade");
        self PrintHint("^5无限战场升级 ^1已关闭");
    }
}

UnlimitedFieldUpgradeThink()
{
    self endon("disconnect");
    self endon(#"stop_unlimited_field_upgrade");

    while (isDefined(self.unlimited_field_upgrade))
    {
        if (isdefined(self.var_87f72f8) && isdefined(self.inventory) && isdefined(self.inventory.items) && isdefined(self.inventory.items[12]) && isdefined(self.var_c9448182))
        {
            cur = isdefined(self.inventory.items[12].count) ? self.inventory.items[12].count : 0;
            if (cur < self.var_c9448182)
                self zm_powerup_hero_weapon_power::hero_weapon_power();
        }
        wait 0.25;
    }
}

EssenceFloor()
{
    return 66666;
}

ScrapFloor()
{
    return 23333;
}

EssenceScrapFloorLoop()
{
    level endon(#"end_game");
    level notify(#"stop_essence_scrap_floor");
    level endon(#"stop_essence_scrap_floor");

    n_essence = EssenceFloor();
    n_scrap = ScrapFloor();

    for (;;)
    {
        foreach (player in getplayers())
        {
            if (!isdefined(player) || !isalive(player))
                continue;

            player ApplyEssenceScrapFloor(n_essence, n_scrap);
        }

        wait 0.25;
    }
}

ApplyEssenceScrapFloor(n_essence, n_scrap)
{
    if (!isdefined(self.score) || self.score < n_essence)
    {
        self.pers[#"score"] = n_essence;
        self.score = n_essence;
        self.score_total = n_essence;
        self.objscore = n_essence;
    }

    if (isdefined(self.var_595a11bc) && self.var_595a11bc < n_scrap)
    {
        self.var_595a11bc = n_scrap;
        self clientfield::set_player_uimodel("hudItems.scrap", self.var_595a11bc);
    }

    if (isdefined(self.var_72d64cfd) && self.var_72d64cfd < n_scrap)
    {
        self.var_72d64cfd = n_scrap;
        self clientfield::set_player_uimodel("hudItems.rareScrap", self.var_72d64cfd);
    }
}

ToggleUnlimitedArmor()
{
    self.unlimited_armor = isDefined(self.unlimited_armor) ? undefined : true;
    if (isDefined(self.unlimited_armor))
    {
        self PrintHint("^5无限护甲 ^2已启用");
        self namespace_1cc7b406::give_item(#"armor_item_lv3_t9_sr");
        self thread UnlimitedArmorThink();
    }
    else
    {
        self notify(#"stop_unlimited_armor");
        self PrintHint("^5无限护甲 ^1已关闭");
    }
}

PlayerHasArmor()
{
    if (isdefined(self.maxarmor) && self.maxarmor > 0)
        return 1;
    if (isdefined(self.inventory) && isdefined(self.inventory.items) && isdefined(self.inventory.items[6]) && self.inventory.items[6].networkid !== 32767 && isdefined(self.inventory.items[6].itementry))
        return 1;
    return 0;
}

RestorePlayerArmor()
{
    if (!self PlayerHasArmor())
        return;

    maxa = 0;
    if (isdefined(self.inventory) && isdefined(self.inventory.items) && isdefined(self.inventory.items[6]) && isdefined(self.inventory.items[6].itementry))
    {
        item = self.inventory.items[6];
        if (item.networkid !== 32767)
        {
            if (isdefined(item.itementry.amount))
                maxa = item.itementry.amount;
            item.amount = maxa;
        }
    }
    if (isdefined(self.maxarmor) && self.maxarmor > 0)
        maxa = self.maxarmor;
    if (maxa <= 0)
        return;
    if (!isdefined(self.armor) || self.armor < maxa)
        self.armor = maxa;
}

UnlimitedArmorThink()
{
    self endon("disconnect");
    self endon(#"stop_unlimited_armor");

    while (isDefined(self.unlimited_armor))
    {
        self RestorePlayerArmor();
        wait 0.05;
    }
}

ToggleUnlimitedVehicle()
{
    self.unlimited_vehicle = isDefined(self.unlimited_vehicle) ? undefined : true;
    if (isDefined(self.unlimited_vehicle))
    {
        self PrintHint("^5无限载具耐久 ^2已启用");
        self thread UnlimitedVehicleThink();
    }
    else
    {
        self notify(#"stop_unlimited_vehicle");
        self UnlockAllVehicles();
        self PrintHint("^5无限载具耐久 ^1已关闭");
    }
}

UnlimitedVehicleThink()
{
    self endon("disconnect");
    self endon(#"stop_unlimited_vehicle");

    while (isDefined(self.unlimited_vehicle))
    {
        vehs = getvehiclearray();
        if (isdefined(vehs))
        {
            foreach (veh in vehs)
                self LockVehicleHealth(veh);
        }
        if (self isinvehicle())
        {
            occ = self getvehicleoccupied();
            if (isdefined(occ))
                self LockVehicleHealth(occ);
        }
        wait 0.05;
    }
}

LockVehicleHealth(veh)
{
    if (!isdefined(veh) || !isvehicle(veh))
        return;
    if (!isalive(veh))
        return;

    maxh = 0;
    if (isdefined(veh.maxhealth) && veh.maxhealth > 0)
        maxh = veh.maxhealth;
    if (isdefined(veh.healthdefault) && veh.healthdefault > maxh)
        maxh = veh.healthdefault;
    if (maxh < 1 && isdefined(veh.health) && veh.health > 0)
        maxh = veh.health;
    if (maxh < 1)
        return;

    veh.maxhealth = maxh;
    veh.health = maxh;
    veh.cnbocw_vehlock = 1;
    veh setcandamage(0);
}

UnlockAllVehicles()
{
    vehs = getvehiclearray();
    if (!isdefined(vehs))
        return;
    foreach (veh in vehs)
    {
        if (!isdefined(veh) || !is_true(veh.cnbocw_vehlock))
            continue;
        veh.cnbocw_vehlock = undefined;
        veh setcandamage(1);
    }
}

GiveSelfRevive()
{
    self zm_laststand::function_3d685b5f(3);
    self PrintHint("^5自救针已拉满");
}

ToggleNoclip()
{
    self.tool_noclip = isDefined(self.tool_noclip) ? undefined : true;
    if (isDefined(self.tool_noclip))
    {
        if (isDefined(self.tool_fly))
            self ToggleFly();
        if (self isInMenu())
            self closeMenu1();
        self PrintHint("^5穿墙 ^2已启用  开火前进/开镜后退/近战退出");
        self DisableWeapons();
        self DisableOffHandWeapons();
        self.nocliplinker = spawn("script_model", self.origin);
        self.nocliplinker setmodel("tag_origin");
        self.nocliplinker thread CleanEntityOnDisconnect(self);
        self PlayerLinkTo(self.nocliplinker, "tag_origin");
        self thread NoclipThink();
    }
    else
        self PrintHint("^5穿墙 ^1已关闭");
}

NoclipThink()
{
    self endon("disconnect");
    while (isDefined(self.tool_noclip) && isAlive(self))
    {
        if (self AttackButtonPressed())
            self.nocliplinker.origin = self.nocliplinker.origin + anglestoforward(self getplayerangles()) * 60;
        else if (self AdsButtonPressed())
            self.nocliplinker.origin = self.nocliplinker.origin - anglestoforward(self getplayerangles()) * 60;
        if (self MeleeButtonPressed())
            break;
        wait 0.01;
    }

    self Unlink();
    if (isdefined(self.nocliplinker))
        self.nocliplinker delete();
    self EnableWeapons();
    self EnableOffHandWeapons();
    if (isDefined(self.tool_noclip))
        self PrintHint("^5穿墙 ^1已关闭");
    self.tool_noclip = undefined;
}

CleanEntityOnDisconnect(player)
{
    self endon(#"death");
    player waittill("disconnect");
    if (isdefined(self))
        self delete();
}

SetXpScale(value)
{
    if (!isdefined(level._orig_xp_mult) && isdefined(level.var_3426461d))
        level._orig_xp_mult = level.var_3426461d;

    if (value <= 0 || value == 1)
    {
        level.customXPValue = undefined;
        if (isdefined(level._orig_xp_mult))
            level.var_3426461d = level._orig_xp_mult;
        self PrintHint("^5XP 倍率已恢复");
        return;
    }

    level.customXPValue = value;
    level.var_3426461d = &GetXpMultiplier;
    self PrintHint("^5XP 倍率 x" + value);
}

GetXpMultiplier(*event)
{
    if (isdefined(level.customXPValue) && level.customXPValue > 0)
        return level.customXPValue;
    if (isdefined(level._orig_xp_mult))
        return self [[ level._orig_xp_mult ]](event);
    return 1;
}

FastRestart()
{
    self PrintHint("^3正在重开…");
    wait 1;
    map_restart(0);
}

ToggleFly()
{
    self.tool_fly = isDefined(self.tool_fly) ? undefined : true;
    if (isDefined(self.tool_fly))
    {
        self PrintHint("^5飞行 ^2已启用  跳上升/蹲下降/冲刺加速");
        self thread FlyThink();
    }
    else
        self PrintHint("^5飞行 ^1已关闭");
}

FlyThink()
{
    self endon("disconnect");
    self notify(#"stop_player_out_of_playable_area_monitor");
    self unlink();
    if (isdefined(self.originObj))
        self.originObj delete();

    self.originObj = spawn("script_origin", self.origin, 1);
    self.originObj.angles = self.angles;
    self.originObj thread CleanEntityOnDisconnect(self);
    self PlayerLinkTo(self.originObj, undefined);
    self enableweapons();

    while (isDefined(self.tool_fly))
    {
        fly_speed = 20;
        if (self SprintButtonPressed())
            fly_speed = 60;

        player_angles = self getPlayerAngles();
        front_vector = AnglesToForward(player_angles);
        left_vector = AnglesToForward(player_angles - (0, 90, 0));
        top_vector = AnglesToForward(player_angles - (90, 0, 0));
        v_movement = self getNormalizedMovement();

        z_movement = 0;
        if (self JumpButtonPressed())
            z_movement = 1;
        else if (self StanceButtonPressed())
            z_movement = -1;

        move_vector = z_movement * top_vector + front_vector * v_movement[0] + (left_vector[0], left_vector[1], 0) * v_movement[1];
        self.originObj.origin = self.origin + vectorScale(move_vector, fly_speed);
        waitframe(1);
    }

    self unlink();
    if (isdefined(self.originObj))
        self.originObj delete();
}

GetLookOrigin()
{
    trace = self GetLookTrace(0);
    return trace[#"position"];
}

GetLookTrace(hitents)
{
    if (!isdefined(hitents))
        hitents = 1;

    angles = self getplayerangles();
    forward = anglestoforward(angles);
    eye = self geteye();
    return bullettrace(eye, eye + vectorscale(forward, 8000), hitents, self);
}

ToggleRapidFire()
{
    self.rapidfire = isDefined(self.rapidfire) ? undefined : true;
    if (isDefined(self.rapidfire))
    {
        self PrintHint("^5连发 ^2已启用");
        self thread RapidFireThink();
    }
    else
    {
        self notify(#"stop_rapidfire");
        self PrintHint("^5连发 ^1已关闭");
    }
}

RapidFireThink()
{
    self endon("disconnect");
    self endon(#"stop_rapidfire");
    while (isDefined(self.rapidfire))
    {
        self waittill(#"weapon_fired");
        if (!isDefined(self.rapidfire))
            break;

        weapon = self getcurrentweapon();
        if (!isdefined(weapon) || weapon.isgadget)
            continue;

        start = self geteye();
        fwd = anglestoforward(self getplayerangles());
        i = 0;
        while (i < 3)
        {
            jitter = (randomfloatrange(-8, 8), randomfloatrange(-8, 8), randomfloatrange(-8, 8));
            magicbullet(weapon, start, start + vectorscale(fwd, 2000) + jitter, self);
            wait 0.05;
            i++;
        }
    }
}

SaveLocation()
{
    self.save_origin = self.origin;
    self.save_angles = self getplayerangles();
    self PrintHint("^5已存点");
}

LoadLocation()
{
    if (!isdefined(self.save_origin))
    {
        self PrintHint("^1还没有存点");
        return;
    }

    self setorigin(self.save_origin);
    self setplayerangles(self.save_angles);
    self dontinterpolate();
    self PrintHint("^5已读点");
}

ToggleAfk()
{
    self.tool_afk = isDefined(self.tool_afk) ? undefined : true;
    if (isDefined(self.tool_afk))
    {
        if (self isInMenu())
            self closeMenu1();
        self PrintHint("^5挂机模式 ^2已启用  建议同时开无敌");
        self thread AfkThink();
    }
    else
    {
        self notify(#"stop_afk");
        self PrintHint("^5挂机模式 ^1已关闭");
    }
}

AfkThink()
{
    self endon("disconnect");
    self endon(#"stop_afk");
    while (isDefined(self.tool_afk))
    {
        if (!isalive(self) || self isInMenu() || isDefined(self.tool_noclip) || isDefined(self.tool_fly))
        {
            wait 0.4;
            continue;
        }

        roll = randomintrange(0, 10);
        if (roll < 5)
            self AfkWalk();
        else if (roll < 8)
            self AfkShoot();
        else if (roll == 8)
            self AfkLook();
        else
            self AfkUseItem();

        wait randomfloatrange(0.2, 0.8);
    }
}

AfkLook()
{
    yaw = self getplayerangles()[1] + randomintrange(-120, 121);
    self setplayerangles((randomintrange(-18, 19), yaw, 0));
}

AfkWalk()
{
    yaw = self getplayerangles()[1] + randomintrange(-80, 81);
    fwd = anglestoforward((0, yaw, 0));
    dest = self.origin + fwd * 96;
    nav = getclosestpointonnavmesh(dest, 140, 16);
    if (!isdefined(nav) || distance2d(nav, self.origin) < 24)
    {
        yaw += 160 + randomintrange(0, 41);
        fwd = anglestoforward((0, yaw, 0));
        nav = getclosestpointonnavmesh(self.origin + fwd * 96, 140, 16);
    }
    if (!isdefined(nav))
    {
        self AfkLook();
        return;
    }

    self setplayerangles((randomintrange(-10, 11), yaw, 0));
    speed = randomintrange(90, 210);
    t = 0;
    dur = randomfloatrange(0.35, 1.05);
    while (t < dur && isDefined(self.tool_afk) && isalive(self))
    {
        vel = fwd * speed;
        if (randomint(14) == 0 && self isonground())
            vel += (0, 0, 230);
        self setvelocity(vel);
        wait 0.05;
        t += 0.05;
    }
}

AfkShoot()
{
    weapon = self getcurrentweapon();
    if (!isdefined(weapon) || weapon == level.weaponnone || weapon.isgadget)
        return;

    n = randomintrange(2, 8);
    i = 0;
    while (i < n && isDefined(self.tool_afk) && isalive(self))
    {
        start = self geteye();
        fwd = anglestoforward(self getplayerangles());
        jitter = (randomfloatrange(-36, 36), randomfloatrange(-36, 36), randomfloatrange(-18, 18));
        magicbullet(weapon, start, start + vectorscale(fwd, 1600) + jitter, self);
        wait 0.07;
        i++;
    }
}

AfkUseItem()
{
    choice = randomintrange(0, 4);
    if (choice == 0)
        self AfkThrowNade();
    else if (choice == 1)
        self AfkSwitchWeapon();
    else if (choice == 2 && self isonground())
        self setvelocity(self getvelocity() + (0, 0, 240));
    else
        self AfkLook();
}

AfkThrowNade()
{
    nade = undefined;
    list = self getweaponslist();
    if (isdefined(list))
    {
        foreach (w in list)
        {
            if (!isdefined(w))
                continue;
            if (!is_true(w.isgrenadeweapon) && !is_true(w.islethalgrenade))
                continue;
            nade = w;
            break;
        }
    }
    if (!isdefined(nade))
    {
        self AfkSwitchWeapon();
        return;
    }

    start = self geteye();
    vel = anglestoforward(self getplayerangles()) * randomintrange(160, 300) + (0, 0, randomintrange(70, 150));
    self magicgrenadeplayer(nade, start, vel);
}

AfkSwitchWeapon()
{
    list = self getweaponslistprimaries();
    if (!isdefined(list) || list.size < 2)
        return;
    self switchtoweapon(list[randomint(list.size)]);
}
