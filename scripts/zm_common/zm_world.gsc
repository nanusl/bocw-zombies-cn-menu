TurnOnPower()
{
    level flag::set("power_on");
    level clientfield::set("zombie_power_on", 1);
    power_trigs = getentarray("use_elec_switch", "targetname");
    foreach (trig in power_trigs)
    {
        if (isdefined(trig.script_int))
        {
            level flag::set("power_on" + trig.script_int);
            level clientfield::set("zombie_power_on", trig.script_int + 1);
        }
    }
    self PrintHint("^5已通电");
}

OpenAllDoors()
{
    setdvar(#"zombie_unlock_all", 1);
    players = getplayers();
    zombie_doors = getentarray("zombie_door", "targetname");
    for (i = 0; i < zombie_doors.size; i++)
    {
        if (!is_true(zombie_doors[i].has_been_opened))
            zombie_doors[i] notify(#"trigger", { #activator:players[0] });
        if (is_true(zombie_doors[i].power_door_ignore_flag_wait))
            zombie_doors[i] notify(#"power_on");
        waitframe(1);
    }
    zombie_airlock_doors = getentarray("zombie_airlock_buy", "targetname");
    for (i = 0; i < zombie_airlock_doors.size; i++)
    {
        zombie_airlock_doors[i] notify(#"trigger", { #activator:players[0] });
        waitframe(1);
    }
    zombie_debris = getentarray("zombie_debris", "targetname");
    for (i = 0; i < zombie_debris.size; i++)
    {
        if (isdefined(zombie_debris[i]))
            zombie_debris[i] notify(#"trigger", { #activator:players[0] });
        waitframe(1);
    }
    level notify(#"open_sesame");
    wait 1;
    setdvar(#"zombie_unlock_all", 0);
    self PrintHint("^5门已打开");
}

KillAllZombies()
{
    level.zombie_total = 0;
    for (a = 0; a < 3; a++)
    {
        enemies = getaiteamarray(level.zombie_team);
        if (isdefined(enemies))
        {
            for (i = 0; i < enemies.size; i++)
            {
                enemy = enemies[i];
                if (!isdefined(enemy) || !isalive(enemy))
                    continue;
                if (is_true(enemy.cnbocw_friendly))
                    continue;
                if (zm_utility::is_magic_bullet_shield_enabled(enemy))
                    enemy util::stop_magic_bullet_shield();
                enemy.allowdeath = 1;
                enemy kill(undefined, undefined, undefined, undefined, undefined, 1);
            }
        }
        wait 0.5;
    }
    self PrintHint("^5清场完成");
}

KillFriendlyAi()
{
    n = 0;
    n += self KillFriendlyList(getaiteamarray(#"allies"));
    n += self KillFriendlyList(getaiteamarray(level.zombie_team));
    self PrintHint("^5友方已清除 x" + n);
}

KillFriendlyList(ais)
{
    n = 0;
    if (!isdefined(ais))
        return 0;

    foreach (ai in ais)
    {
        if (!isdefined(ai) || !isalive(ai) || isplayer(ai))
            continue;
        if (!is_true(ai.cnbocw_friendly))
            continue;
        if (zm_utility::is_magic_bullet_shield_enabled(ai))
            ai util::stop_magic_bullet_shield();
        ai.allowdeath = 1;
        ai kill();
        n++;
    }
    return n;
}

ToggleKillLoop()
{
    self.kill_loop = isDefined(self.kill_loop) ? undefined : true;
    if (isDefined(self.kill_loop))
    {
        self PrintHint("^5循环清场 ^2已启用");
        self thread KillLoopThink();
    }
    else
        self PrintHint("^5循环清场 ^1已关闭");
}

KillLoopThink()
{
    self endon("disconnect");
    while (isDefined(self.kill_loop))
    {
        enemies = getaiteamarray(level.zombie_team);
        if (isdefined(enemies))
        {
            foreach (enemy in enemies)
            {
                if (!isdefined(enemy) || !isalive(enemy))
                    continue;
                enemy.allowdeath = 1;
                enemy kill();
            }
        }
        wait 0.25;
    }
}

ToggleZombieTP()
{
    self.ZombiePos = isDefined(self.ZombiePos) ? undefined : true;
    if (isDefined(self.ZombiePos))
    {
        self PrintHint("^5传到准星 ^2已启用");
        self thread ZombieTPThink();
    }
    else
        self PrintHint("^5传到准星 ^1已关闭");
}

ZombieTPThink()
{
    self endon("disconnect");
    while (isDefined(self.ZombiePos))
    {
        dest = self GetLookOrigin();
        foreach (zombo in GetAITeamArray(level.zombie_team))
        {
            if (isdefined(zombo) && isalive(zombo))
                zombo ForceTeleport(dest);
        }
        wait 0.1;
    }
}

ToggleInstaKill()
{
    self.oneHPZombs = isDefined(self.oneHPZombs) ? undefined : true;
    if (isDefined(self.oneHPZombs))
        self PrintHint("^5秒杀 ^2已启用");
    else
        self PrintHint("^5秒杀 ^1已关闭");

    while (isDefined(self.oneHPZombs))
    {
        foreach (zombo in GetAiTeamArray(level.zombie_team))
        {
            if (isDefined(zombo) && isalive(zombo))
                zombo.health = 1;
        }
        wait 0.1;
    }
}

SetRound(newRound)
{
    if (newRound < 1)
        newRound = 1;

    if (zm_utility::is_survival())
    {
        zm_utility_zsurvival::function_7c97e961(newRound);
        players = getplayers();
        foreach (player in players)
            player luinotifyevent(#"hash_5b1ff06d07e9002a", 3, 2, level.var_b48509f9, 0);
        self PrintHint("^5疫情爆发回合已设为 ^2" + newRound);
        return;
    }

    level zm_game_module::zombie_goto_round(newRound);
    self PrintHint("^5回合已设为 ^2" + newRound);
}

GivePowerupDrop(Powerup)
{
    self zm_powerups::specific_powerup_drop(Powerup, self GetLookOrigin(), undefined, undefined, undefined, 1);
    self PrintHint("^5已掉落");
}

IsOutbreakMap(mapname)
{
    if (mapname === "wz_forest" || mapname === "wz_sanatorium" || mapname === "wz_golova")
        return 1;
    if (mapname === "wz_duga" || mapname === "wz_ski_slopes" || mapname === "wz_zoo")
        return 1;
    return 0;
}

ChangeMap(mapname)
{
    self PrintHint("^3切图 " + mapname);
    wait 0.5;

    if (zm_utility::is_survival() && IsOutbreakMap(mapname))
    {
        level.var_83e2326 = undefined;
        zm_utility_zsurvival::switch_map(mapname);
        level.var_83e2326 = undefined;
        self PrintHint("^3官方换区未生效，改用硬切");
    }

    setdvar("ls_mapname", mapname);
    setdvar("mapname", mapname);
    setdvar("party_mapname", mapname);
    setdvar("ui_mapname", mapname);
    setdvar("ui_currentmap", mapname);
    setdvar("ui_previewmap", mapname);
    setdvar("ui_showmap", mapname);
    map(mapname);
    wait 0.1;
    switchmap_switch();
}

SetZombieSpeed(speed)
{
    if (!isdefined(speed) || speed == "default")
    {
        level.var_43fb4347 = undefined;
        level.var_102b1301 = undefined;
        self PrintHint("^5移速已恢复");
        return;
    }

    level.var_43fb4347 = speed;
    level.var_102b1301 = speed;
    zombies = getaiteamarray(level.zombie_team);
    if (isdefined(zombies))
    {
        foreach (z in zombies)
        {
            if (isdefined(z) && isalive(z) && z.archetype === #"zombie")
                z.zombie_move_speed = speed;
        }
    }
    self PrintHint("^5移速 " + speed);
}

FunZombieOk(z)
{
    if (!isdefined(z) || !isalive(z))
        return 0;
    if (is_true(z.cnbocw_friendly) || is_true(z.aat_turned) || z.team === #"allies")
        return 0;
    return 1;
}

ToggleHeadless()
{
    level.headless_ai = isDefined(level.headless_ai) ? undefined : true;
    if (isDefined(level.headless_ai))
    {
        self PrintHint("^5下头 ^2已启用");
        level thread HeadlessThink();
    }
    else
        self PrintHint("^5下头 ^1已关闭");
}

HeadlessThink()
{
    level endon(#"end_game");
    while (isDefined(level.headless_ai))
    {
        zombies = getaiteamarray(level.zombie_team);
        if (isdefined(zombies))
        {
            foreach (z in zombies)
            {
                if (!FunZombieOk(z))
                    continue;
                z detachall();
            }
        }
        wait 0.25;
    }
}

SetFunSkin(model)
{
    if (!isdefined(model) || model == "off")
    {
        level.fun_skin = undefined;
        self PrintHint("^5换皮 ^1已关闭");
        return;
    }

    level.fun_skin = model;
    self PrintHint("^5换皮 ^2已启用");
    if (!isDefined(level.fun_skin_loop))
        level thread FunSkinThink();
}

FunSkinThink()
{
    level.fun_skin_loop = 1;
    level endon(#"end_game");
    while (isdefined(level.fun_skin))
    {
        zombies = getaiteamarray(level.zombie_team);
        if (isdefined(zombies))
        {
            foreach (z in zombies)
            {
                if (!FunZombieOk(z))
                    continue;
                z setmodel(level.fun_skin);
            }
        }
        wait 0.25;
    }
    level.fun_skin_loop = undefined;
}

SetZombieEyes(index)
{
    level.eye_rainbow = undefined;
    if (index < 0)
        level.var_1f966535 = undefined;
    else
        level.var_1f966535 = index;

    ApplyZombieEyes();
    if (index < 0)
        self PrintHint("^5眼色 ^2默认");
    else if (index == 0)
        self PrintHint("^5眼色 ^2无");
    else if (index == 2)
        self PrintHint("^5眼色 ^2蓝");
    else if (index == 3)
        self PrintHint("^5眼色 ^2绿");
    else if (index == 4)
        self PrintHint("^5眼色 ^2橙");
    else
        self PrintHint("^5眼色 ^2已设置");
}

ToggleEyeRainbow()
{
    level.eye_rainbow = isDefined(level.eye_rainbow) ? undefined : true;
    if (isDefined(level.eye_rainbow))
    {
        self PrintHint("^5彩虹眼色 ^2已启用");
        level thread EyeRainbowThink();
    }
    else
    {
        level.var_1f966535 = undefined;
        ApplyZombieEyes();
        self PrintHint("^5彩虹眼色 ^1已关闭");
    }
}

EyeRainbowThink()
{
    level endon(#"end_game");
    n = 1;
    while (isDefined(level.eye_rainbow))
    {
        n++;
        if (n > 4)
            n = 1;
        level.var_1f966535 = n;
        ApplyZombieEyes();
        wait 0.5;
    }
}

ApplyZombieEyes()
{
    value = 1;
    if (isdefined(level.var_1f966535))
        value = level.var_1f966535;

    zombies = getaiteamarray(level.zombie_team);
    if (!isdefined(zombies))
        return;

    foreach (z in zombies)
    {
        if (!FunZombieOk(z))
            continue;
        if (z.archetype !== #"zombie")
            continue;
        z clientfield::set("zombie_eye_glow", value);
    }
}

ToggleFreeBox()
{
    level.free_box = isDefined(level.free_box) ? undefined : true;
    if (isDefined(level.free_box))
    {
        self PrintHint("^5免费神秘箱 ^2已启用");
        level thread FreeBoxThink();
    }
    else
    {
        FreeBoxRestore(950);
        self PrintHint("^5免费神秘箱 ^1已关闭");
    }
}

FreeBoxThink()
{
    level endon(#"end_game");
    while (isDefined(level.free_box))
    {
        FreeBoxRestore(0);
        wait 1;
    }
}

FreeBoxRestore(cost)
{
    if (!isdefined(level.chests))
        return;

    foreach (chest in level.chests)
    {
        if (isdefined(chest))
            chest.zombie_cost = cost;
    }
}

ToggleBoxNoFly()
{
    level.box_nofly = isDefined(level.box_nofly) ? undefined : true;
    if (isDefined(level.box_nofly))
    {
        self PrintHint("^5神秘箱不飞走 ^2已启用");
        level thread BoxNoFlyThink();
    }
    else
    {
        BoxNoFlySet(0);
        self PrintHint("^5神秘箱不飞走 ^1已关闭");
    }
}

BoxNoFlyThink()
{
    level endon(#"end_game");
    while (isDefined(level.box_nofly))
    {
        BoxNoFlySet(1);
        wait 1;
    }
}

BoxNoFlySet(on)
{
    if (!isdefined(level.chests))
        return;

    foreach (chest in level.chests)
    {
        if (isdefined(chest))
            chest.no_fly_away = on;
    }
}

ToggleNoSpawn()
{
    level.no_spawn = isDefined(level.no_spawn) ? undefined : true;
    if (isDefined(level.no_spawn))
    {
        if (level flag::exists("spawn_zombies"))
            level flag::clear("spawn_zombies");
        level.zombie_total = 0;
        self PrintHint("^5停刷 ^2已启用");
    }
    else
    {
        if (level flag::exists("spawn_zombies"))
            level flag::set("spawn_zombies");
        self PrintHint("^5停刷 ^1已关闭");
    }
}

ToggleFreezeAi()
{
    level.freeze_ai = isDefined(level.freeze_ai) ? undefined : true;
    if (isDefined(level.freeze_ai))
    {
        self PrintHint("^5定身 ^2已启用");
        level thread FreezeAiThink();
    }
    else
    {
        FreezeAiSet(0);
        self PrintHint("^5定身 ^1已关闭");
    }
}

FreezeAiThink()
{
    level endon(#"end_game");
    while (isDefined(level.freeze_ai))
    {
        FreezeAiSet(1);
        wait 0.25;
    }
}

FreezeAiSet(on)
{
    FreezeAiApply(getaiteamarray(level.zombie_team), on, 0);
    FreezeAiApply(getaiteamarray(#"allies"), on, 1);
}

FreezeAiApply(ais, on, friendlies)
{
    if (!isdefined(ais))
        return;

    foreach (ai in ais)
    {
        if (!isdefined(ai) || !isalive(ai) || isplayer(ai))
            continue;
        if (friendlies)
        {
            if (!is_true(ai.cnbocw_friendly))
                continue;
        }
        else if (is_true(ai.aat_turned) || ai.team === #"allies" || is_true(ai.cnbocw_friendly))
            continue;

        if (on)
        {
            ai.cnbocw_frozen = 1;
            ai setentitypaused(1);
        }
        else if (is_true(ai.cnbocw_frozen))
        {
            ai.cnbocw_frozen = undefined;
            ai setentitypaused(0);
        }
    }
}

ToggleDarkAetherFx()
{
    if (level.script != "zm_silver")
    {
        self PrintHint("^1仅“时光机器”可用");
        return;
    }

    level.dark_aether_fx = isDefined(level.dark_aether_fx) ? undefined : true;
    if (isDefined(level.dark_aether_fx))
    {
        level notify(#"into_the_dark_side");
        level flag::set(#"dark_aether_active");
        level flag::set(#"in_dark_side");
        if (clientfield::is_registered("" + #"dark_aether_light_on"))
            level clientfield::set("" + #"dark_aether_light_on", 1);
        if (clientfield::is_registered("" + #"dark_aether"))
            self clientfield::set_to_player("" + #"dark_aether", 1);
        self PrintHint("^5暗乙太场景 ^2已启用");
    }
    else
    {
        level notify(#"dark_side_timeout");
        if (level flag::get(#"dark_aether_active"))
            level flag::clear(#"dark_aether_active");
        if (level flag::get(#"in_dark_side"))
            level flag::clear(#"in_dark_side");
        if (clientfield::is_registered("" + #"dark_aether_light_on"))
            level clientfield::set("" + #"dark_aether_light_on", 0);
        if (clientfield::is_registered("" + #"dark_aether"))
            self clientfield::set_to_player("" + #"dark_aether", 0);
        self PrintHint("^5暗乙太场景 ^1已关闭");
    }
}

TeleportToShop(kind)
{
    nodes = ShopCollect(kind);
    node = ShopNearest(nodes);
    if (!isdefined(node) || !isdefined(node.origin))
    {
        self PrintHint("^1本图没有该设施");
        return;
    }

    dest = ShopStandPos(node);
    if (!isdefined(dest))
    {
        self PrintHint("^1找不到可站立的位置");
        return;
    }

    self setorigin(dest);
    self dontinterpolate();
    self closeMenu1();
    self PrintHint("^5已到达");
}

ShopStandPos(node)
{
    origin = node.origin;
    yaw = 0;
    if (isdefined(node.angles))
        yaw = node.angles[1];

    offsets = [];
    offsets[0] = 0;
    offsets[1] = 90;
    offsets[2] = 270;
    offsets[3] = 180;
    offsets[4] = 45;
    offsets[5] = 135;
    offsets[6] = 225;
    offsets[7] = 315;

    dists = [];
    dists[0] = 80;
    dists[1] = 104;
    dists[2] = 128;
    dists[3] = 160;
    dists[4] = 192;

    i = 0;
    while (i < offsets.size)
    {
        j = 0;
        while (j < dists.size)
        {
            cand = origin + anglestoforward((0, yaw + offsets[i], 0)) * dists[j] + (0, 0, 24);
            pos = ShopClearStand(origin, cand);
            j++;
            if (isdefined(pos))
                return pos;
        }
        i++;
    }
    return undefined;
}

ShopClearStand(origin, cand)
{
    n = getclosestpointonnavmesh(cand, 72, 16);
    if (!isdefined(n))
        return undefined;
    if (distance2d(n, origin) < 72)
        return undefined;
    if (distance2d(n, origin) > 240)
        return undefined;

    start = n + (0, 0, 56);
    end = n + (0, 0, -8);
    trace = physicstraceex(start, end, (-15, -15, 0), (15, 15, 72));
    if (!isdefined(trace))
        return undefined;

    frac = trace[#"fraction"];
    hit = trace[#"position"];
    if (!isdefined(frac))
        frac = trace["fraction"];
    if (!isdefined(hit))
        hit = trace["position"];
    if (!isdefined(frac) || frac <= 0)
        return undefined;
    if (!isdefined(hit))
        return undefined;
    if (abs(hit[2] - n[2]) > 72)
        return undefined;
    if (distance2d(hit, origin) < 72)
        return undefined;

    n_flat = distance2d(hit, origin);
    if (n_flat > 64)
    {
        v_to_machine = vectornormalize((origin[0] - hit[0], origin[1] - hit[1], 0));
        v_to = origin - v_to_machine * 64;
        s_los = bullettrace(hit + (0, 0, 56), (v_to[0], v_to[1], hit[2] + 56), 0, undefined);

        if (isdefined(s_los) && isdefined(s_los[#"fraction"]) && s_los[#"fraction"] < 0.99)
            return undefined;
    }

    return hit + (0, 0, 8);
}

ShopNearest(nodes)
{
    if (!isdefined(nodes) || !nodes.size)
        return undefined;

    best = undefined;
    bestd = 0;
    foreach (n in nodes)
    {
        if (!isdefined(n) || !isdefined(n.origin))
            continue;
        d = distancesquared(self.origin, n.origin);
        if (!isdefined(best) || d < bestd)
        {
            best = n;
            bestd = d;
        }
    }
    return best;
}

ShopCollect(kind)
{
    nodes = [];
    if (kind == "perk")
    {
        nodes = ShopAddContent(nodes, #"perk_machine_choice");
        if (!nodes.size)
        {
            machines = zm_perks::get_perk_machines();
            foreach (m in machines)
                nodes = ShopAddNode(nodes, m);
        }
    }
    else if (kind == "craft")
        nodes = ShopAddContent(nodes, #"crafting_table");
    else if (kind == "pap")
    {
        paps = getentarray("zm_pack_a_punch", "targetname");
        foreach (p in paps)
            nodes = ShopAddNode(nodes, p);
        if (isdefined(level.pack_a_punch) && isdefined(level.pack_a_punch.trigger_stubs))
        {
            foreach (stub in level.pack_a_punch.trigger_stubs)
                nodes = ShopAddNode(nodes, stub);
        }
        nodes = ShopAddContent(nodes, #"weapon_machine");
    }
    else if (kind == "armor")
        nodes = ShopAddContent(nodes, #"armor_machine");
    else if (kind == "ammo")
        nodes = ShopAddContent(nodes, #"ammo_cache");
    else if (kind == "box")
    {
        if (isdefined(level.chests) && isdefined(level.chest_index) && isdefined(level.chests[level.chest_index]))
        {
            chest = level.chests[level.chest_index];
            if (ShopBoxUsable(chest))
                nodes = ShopAddNode(nodes, chest);
        }
        else
        {
            raw = ShopAddContent([], #"magicbox");
            foreach (chest in raw)
            {
                if (ShopBoxUsable(chest))
                    nodes = ShopAddNode(nodes, chest);
            }
        }
    }
    return nodes;
}

ShopAddContent(nodes, kind)
{
    if (!isdefined(level.contentmanager))
        return nodes;

    if (isdefined(level.contentmanager.spawnedinstances))
    {
        if (isdefined(level.contentmanager.spawnedinstances[kind]))
        {
            foreach (inst in level.contentmanager.spawnedinstances[kind])
                nodes = ShopAddInstance(nodes, inst);
        }

        foreach (arr in level.contentmanager.spawnedinstances)
        {
            if (!isdefined(arr))
                continue;
            foreach (inst in arr)
            {
                if (isdefined(inst) && isdefined(inst.contentgroups) && isdefined(inst.contentgroups[kind]))
                    nodes = ShopAddGroup(nodes, inst.contentgroups[kind]);
            }
        }
    }

    return nodes;
}

ShopAddGroup(nodes, group)
{
    if (!isdefined(group))
        return nodes;
    if (isarray(group))
    {
        foreach (item in group)
            nodes = ShopAddGroup(nodes, item);
        return nodes;
    }
    return ShopAddInstance(nodes, group);
}

ShopAddInstance(nodes, inst)
{
    if (!isdefined(inst))
        return nodes;

    children = content_manager::get_children(inst);
    if (isdefined(children) && children.size)
    {
        foreach (c in children)
            nodes = ShopAddNode(nodes, c);
        return nodes;
    }
    return ShopAddNode(nodes, inst);
}

ShopBoxUsable(chest)
{
    if (!isdefined(chest) || !isdefined(chest.origin))
        return 0;
    if (is_true(chest.hidden))
        return 0;
    zb = chest.zbarrier;
    if (isdefined(zb) && isdefined(zb.state) && (zb.state == "away" || zb.state == "leaving" || zb.state == "moving"))
        return 0;
    return 1;
}

ShopAddNode(nodes, ent)
{
    if (!isdefined(ent) || !isdefined(ent.origin))
        return nodes;
    nav = getclosestpointonnavmesh(ent.origin, 400, 32);
    if (!isdefined(nav))
        return nodes;
    nodes[nodes.size] = ent;
    return nodes;
}
