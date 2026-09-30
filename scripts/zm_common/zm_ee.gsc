GetMainQuestName()
{
    switch (level.script)
    {
        case "zm_silver":
            return #"main_quest";
        case "zm_gold":
            return #"gold_main_quest";
        case "zm_platinum":
            return #"platinum_main_quest";
        case "zm_tungsten":
            return #"tungsten_main_quest";
    }
    return undefined;
}

FindContentInstance(scriptname)
{
    if (isdefined(level.contentmanager.spawnedinstances) && isdefined(level.contentmanager.spawnedinstances[scriptname]) && level.contentmanager.spawnedinstances[scriptname].size)
        return level.contentmanager.spawnedinstances[scriptname][0];

    if (isdefined(level.contentmanager.locations))
    {
        foreach (loc in level.contentmanager.locations)
        {
            if (isdefined(loc.instances) && isdefined(loc.instances[scriptname]))
                return loc.instances[scriptname];
        }
    }
    return undefined;
}

SkipCurrentEeStep()
{
    name = GetMainQuestName();
    if (!isdefined(name) || !isdefined(level._ee) || !isdefined(level._ee[name]))
    {
        self PrintHint("^1当前图没有主线");
        return;
    }

    ee = level._ee[name];
    if (is_true(ee.completed))
    {
        self PrintHint("^5主线已完成");
        return;
    }
    if (!is_true(ee.started) || !isdefined(ee.steps) || !isdefined(ee.current_step))
    {
        self PrintHint("^1主线未开始，或者直接 BossRush 吧");
        return;
    }

    step = ee.steps[ee.current_step];
    if (!isdefined(step))
    {
        self PrintHint("^1当前步无效");
        return;
    }

    if (is_true(step.completed))
    {
        self PrintHint("^3当前步已结束，无需再跳");
        return;
    }

    setdvar(#"zm_ee_enabled", 1);
    step notify(#"end_early");
    self PrintHint("^5已跳过当前步");
}

SkipMainQuest()
{
    name = GetMainQuestName();
    if (!isdefined(name) || !isdefined(level._ee) || !isdefined(level._ee[name]))
    {
        self PrintHint("^1当前图没有主线");
        return;
    }

    ee = level._ee[name];
    if (is_true(ee.completed))
    {
        self PrintHint("^5主线已完成");
        return;
    }
    if (!is_true(ee.started))
    {
        self PrintHint("^1主线未开始");
        return;
    }

    self PrintHint("^3正在跳过主线…");
    for (i = 0; i < 20; i++)
    {
        ee = level._ee[name];
        if (!isdefined(ee) || is_true(ee.completed))
            break;
        if (!isdefined(ee.steps) || !isdefined(ee.current_step))
            break;
        step = ee.steps[ee.current_step];
        if (!isdefined(step))
            break;
        step notify(#"end_early");
        wait 1;
    }

    if (isdefined(level._ee[name]) && is_true(level._ee[name].completed))
        self PrintHint("^5主线已跳完");
    else
        self PrintHint("^3主线已尽量跳过，余下步请再按一次");
}

PlayEeSong()
{
    level thread zm_audio::sndmusicsystem_stopandflush();
    waitframe(1);
    level thread zm_audio::sndmusicsystem_playstate("ee_song");
    self PrintHint("^5正在播放彩蛋曲");
}

ToggleDanceParty()
{
    if (level.script != "zm_silver")
    {
        self PrintHint("^1仅时光机器");
        return;
    }

    level.dance_party = isDefined(level.dance_party) ? undefined : true;
    if (isDefined(level.dance_party))
    {
        OpenAllDoors();
        level flag::set(#"hash_76b83a765dea94a5");
        level notify(#"dance_party_light_on");
        if (clientfield::is_registered("" + #"hash_195f6fa038980aca"))
            level clientfield::set("" + #"hash_195f6fa038980aca", 1);
        level flag::set(#"hash_2aecb7319e5a0d11");
        level notify(#"dance_party_start");
        self setorigin((442.138, -853.485, -415.875));
        self setplayerangles((0, 90, 0));
        self dontinterpolate();
        self closeMenu1();
        self PrintHint("^5舞会彩蛋 ^2已启用");
    }
    else
    {
        level flag::clear(#"hash_76b83a765dea94a5");
        level notify(#"dance_party_light_off");
        if (clientfield::is_registered("" + #"hash_195f6fa038980aca"))
            level clientfield::set("" + #"hash_195f6fa038980aca", 0);
        level flag::clear(#"hash_2aecb7319e5a0d11");
        level notify(#"dance_party_end");
        self PrintHint("^5舞会彩蛋 ^1已关闭");
    }
}

BossRush(h_variant)
{
    if (zm_utility::is_survival())
    {
        self closeMenu1();
        self PrintHint("^3正在进入 Boss 战…");
        level thread BossRushOutbreak(self, h_variant);
        return;
    }

    q = BossRushQuest();
    if (!isdefined(q))
    {
        self PrintHint("^1当前图没有 Boss 战");
        return;
    }

    if (!isdefined(level._ee) || !isdefined(level._ee[q.h_quest]))
    {
        self PrintHint("^1主线未注册");
        return;
    }

    self closeMenu1();
    self PrintHint("^3正在进入 Boss 战…");
    level thread BossRushJump(self, q);
}

BossRushOutbreakInfo(h_variant)
{
    s = spawnstruct();

    if (h_variant === #"reveal" || (!isdefined(h_variant) && level.script === "wz_forest"))
    {
        s.str_name = "军团长";
        s.str_label = "鲁卡";
        s.str_map = "wz_forest";
        s.h_variant = #"reveal";
        s.h_key = #"hash_62df6469a6590d1c";
        return s;
    }

    s.str_name = "奥达";
    s.str_label = "疗养院";
    s.str_map = "wz_sanatorium";
    s.h_variant = #"mq4";
    return s;
}

BossRushOutbreakFind(h_variant)
{
    inst_fallback = undefined;
    instances = struct::get_array(#"content_instance", "variantname");
    if (!isdefined(instances))
        return undefined;
    foreach (inst in instances)
    {
        if (!isdefined(inst) || !isdefined(inst.content_script_name))
            continue;
        script = content_manager::get_script(inst.content_script_name);
        if (!isdefined(script) || !isdefined(script.objectivecategory))
            continue;
        cat = script.objectivecategory;
        if (cat !== #"ee" && cat !== #"final_battle")
            continue;

        if (isdefined(h_variant) && inst.variant === h_variant)
            return inst;

        if (!isdefined(inst_fallback))
            inst_fallback = inst;
    }
    return inst_fallback;
}

BossRushOutbreakStop()
{
    inst = undefined;
    if (isdefined(level.contentmanager))
        inst = level.contentmanager.activeobjective;
    if (!isdefined(inst))
        return;
    level.contentmanager.activeobjective = undefined;
    if (level flag::exists("objective_locked"))
        level flag::clear("objective_locked");
    inst notify(#"objective_ended");
    level notify(#"objective_ended", {#completed:0});
}

BossRushOutbreakStart(inst)
{
    if (!isdefined(inst) || !isdefined(inst.content_script_name))
        return 0;
    if (isdefined(level.contentmanager.activeobjective))
        return 0;
    script = content_manager::get_script(inst.content_script_name);
    if (!isdefined(script) || !isdefined(script.var_11dcc37e))
        return 0;
    level.contentmanager.activeobjective = inst;
    if (level flag::exists("objective_locked"))
        level flag::set("objective_locked");
    level thread [[script.var_11dcc37e]](inst, undefined);
    level notify(#"objective_started");
    return 1;
}

BossRushOutbreakPrime(s)
{
    setdvar(#"zm_ee_enabled", 1);

    if (isdefined(s.h_key))
    {
        namespace_cf6efd05::function_c484a9be(s.h_key, 1);
        return;
    }

    setdvar(#"hash_c0b5b313ff35979", 1);
}

BossRushOutbreak(player, h_variant)
{
    level endon(#"end_game");

    info = BossRushOutbreakInfo(h_variant);

    BossRushOutbreakPrime(info);

    if (level.script !== info.str_map)
    {
        if (isdefined(player))
            player PrintHint("^3已解锁" + info.str_name + "，请切到" + info.str_label + "后再按一次");
        return;
    }

    inst = BossRushOutbreakFind(info.h_variant);
    if (!isdefined(inst))
    {
        if (isdefined(player))
            player PrintHint("^1" + info.str_name + "尚未注册，请切图重进" + info.str_label + "后再按");
        return;
    }

    if (isdefined(level.contentmanager) && isdefined(level.contentmanager.activeobjective))
    {
        BossRushOutbreakStop();
        wait 1;
    }
    if (isdefined(level.contentmanager) && isdefined(level.contentmanager.activeobjective))
        level.contentmanager.activeobjective = undefined;
    if (level flag::exists("objective_locked"))
        level flag::clear("objective_locked");

    content_manager::spawn_instance(inst);
    wait 1;
    if (isdefined(inst.origin))
    {
        players = getplayers();
        i = 0;
        while (i < players.size)
        {
            players[i] setorigin(inst.origin);
            if (isdefined(inst.angles))
                players[i] setplayerangles(inst.angles);
            players[i] dontinterpolate();
            i++;
        }
    }

    if (!BossRushOutbreakStart(inst))
    {
        if (isdefined(player))
            player PrintHint("^1目标无法启动");
        return;
    }
    if (isdefined(player))
        player PrintHint("^5已进入疫情爆发 Boss 战");
}

BossRushQuest()
{
    q = spawnstruct();
    switch (level.script)
    {
        case "zm_gold":
            q.h_quest = #"gold_main_quest";
            q.h_step = #"end_fight";
            q.h_scene = #"hash_3c473c110c8c0ff6";
            break;
        case "zm_silver":
            q.h_quest = #"main_quest";
            q.h_step = #"defend";
            q.arena = "mq_pto_tlpt_loc";
            break;
        case "zm_platinum":
            q.h_quest = #"platinum_main_quest";
            q.h_step = #"hash_58a40205ad8ede62";
            q.arena = "mq_lab_start";
            break;
        case "zm_tungsten":
            q.h_quest = #"tungsten_main_quest";
            q.h_step = #"end_fight";
            q.arena = #"hash_5c9e57cec1f8655b";
            break;
        default:
            return undefined;
    }
    return q;
}

BossRushStepIndex(ee, h_step)
{
    if (!isdefined(ee) || !isdefined(ee.steps))
        return -1;
    i = 0;
    while (i < ee.steps.size)
    {
        if (isdefined(ee.steps[i]) && ee.steps[i].name === h_step)
            return i;
        i++;
    }
    return -1;
}

BossRushSkipStep(s_step)
{
    if (!isdefined(s_step))
        return;
    s_step.started = 1;
    if (isdefined(s_step.setup_func))
        [[s_step.setup_func]](1);
    s_step.completed = 1;
    if (isdefined(s_step.cleanup_func))
        [[s_step.cleanup_func]](1, 0);
    s_step.cleaned_up = 1;
    if (isdefined(s_step.var_e788cdd7))
    {
        str_flag = s_step.var_e788cdd7 + "_completed";
        if (level flag::exists(str_flag))
            level flag::set(str_flag);
    }
    waitframe(1);
}

BossRushOpenMap()
{
    level flag::set("power_on");
    level clientfield::set("zombie_power_on", 1);
    setdvar(#"zombie_unlock_all", 1);
    players = getplayers();
    activator = players[0];
    doors = getentarray("zombie_door", "targetname");
    i = 0;
    while (i < doors.size)
    {
        if (!is_true(doors[i].has_been_opened))
            doors[i] notify(#"trigger", {#activator:activator});
        if (is_true(doors[i].power_door_ignore_flag_wait))
            doors[i] notify(#"power_on");
        i++;
        waitframe(1);
    }
    airlocks = getentarray("zombie_airlock_buy", "targetname");
    i = 0;
    while (i < airlocks.size)
    {
        airlocks[i] notify(#"trigger", {#activator:activator});
        i++;
        waitframe(1);
    }
    debris = getentarray("zombie_debris", "targetname");
    i = 0;
    while (i < debris.size)
    {
        if (isdefined(debris[i]))
            debris[i] notify(#"trigger", {#activator:activator});
        i++;
        waitframe(1);
    }
    level notify(#"open_sesame");
    setdvar(#"zombie_unlock_all", 0);

    if (isdefined(level.zones))
    {
        names = getarraykeys(level.zones);
        foreach (name in names)
        {
            z = level.zones[name];
            if (!isdefined(z))
                continue;
            z.is_enabled = 1;
            z.is_spawning_allowed = 1;
            level notify(name);
            waitframe(1);
        }
    }
}

BossRushTeleport(q)
{
    if (!isdefined(q.arena))
        return;
    spots = struct::get_array(q.arena);
    if (!isdefined(spots) || spots.size < 1)
        return;
    players = getplayers();
    i = 0;
    while (i < players.size)
    {
        spot = spots[i];
        if (!isdefined(spot))
            spot = spots[0];
        players[i] setorigin(spot.origin);
        if (isdefined(spot.angles))
            players[i] setplayerangles(spot.angles);
        players[i] dontinterpolate();
        i++;
    }
}

BossRushSkipScene(h_scene)
{
    level endon(#"end_game");

    if (!isdefined(h_scene))
        return;

    for (i = 0; i < 1800; i++)
    {
        if (scene::is_active(h_scene))
        {
            wait 0.5;
            level scene::skipto_end(h_scene);
            return;
        }
        waitframe(1);
    }
}

BossRushOutbreakDiagMenu()
{
    instances = struct::get_array(#"content_instance", "variantname");
    if (!isdefined(instances))
        instances = [];

    n_script = 0;
    n_known = 0;
    n_ee = 0;
    n_mq4 = 0;

    foreach (inst in instances)
    {
        if (!isdefined(inst) || !isdefined(inst.content_script_name))
            continue;
        n_script++;

        script = content_manager::get_script(inst.content_script_name);
        if (!isdefined(script) || !isdefined(script.objectivecategory))
            continue;
        n_known++;

        if (script.objectivecategory !== #"ee")
            continue;
        n_ee++;

        if (inst.variant === #"mq4")
            n_mq4++;
    }

    n_reg = isdefined(level.contentmanager.registeredscripts) ? getarraykeys(level.contentmanager.registeredscripts).size : -1;
    b_orda = 0;
    b_mq4 = 0;

    if (isdefined(level.contentmanager.registeredscripts))
    {
        if (isdefined(level.contentmanager.registeredscripts[#"hash_18be5193d8310f84"]))
            b_orda = 1;
        if (isdefined(level.contentmanager.registeredscripts[#"mq4"]))
            b_mq4 = 1;
    }

    self PrintHint("^3map=" + level.script + " inst=" + instances.size + " script=" + n_script + " reg=" + n_reg);
    self PrintHint("^3known=" + n_known + " ee=" + n_ee + " mq4=" + n_mq4 + " mq4reg=" + b_mq4);
    self PrintHint("^3orda=" + b_orda + " dvar=" + getdvarint(#"hash_c0b5b313ff35979", 0) + " eeEn=" + getdvarint(#"zm_ee_enabled", 0));
    self PrintHint("^3eeGts=" + is_true(getgametypesetting(#"hash_3c5363541b97ca3e")) + " gts=" + is_true(getgametypesetting(#"hash_50cc93a10c9d2175")) + " skip=" + getdvarint(#"hash_292db25b2be947f", 0));
}

BossRushJump(player, q)
{
    level endon(#"end_game");
    setdvar(#"zm_ee_enabled", 1);
    BossRushOpenMap();

    ee = level._ee[q.h_quest];
    if (!isdefined(ee) || !isdefined(ee.steps))
    {
        if (isdefined(player))
            player PrintHint("^1主线数据无效");
        return;
    }

    n_target = BossRushStepIndex(ee, q.h_step);
    if (n_target < 0)
    {
        if (isdefined(player))
            player PrintHint("^1找不到 Boss 步骤");
        return;
    }

    b_running = is_true(ee.started);
    n_first = 0;
    if (b_running)
    {
        n_first = ee.current_step + 1;
        if (ee.current_step >= n_target)
        {
            BossRushTeleport(q);
            if (isdefined(player))
                player PrintHint("^3已在 Boss 步骤，已尝试传送");
            return;
        }
    }

    i = n_first;
    while (i < n_target)
    {
        level BossRushSkipStep(ee.steps[i]);
        i++;
    }

    BossRushTeleport(q);

    level thread BossRushSkipScene(q.h_scene);

    if (b_running)
    {
        live = ee.steps[ee.current_step];
        if (isdefined(live))
        {
            live.next_step = ee.steps[n_target];
            live notify(#"end_early");
        }
    }
    else
    {
        ee.started = 1;
        ee.current_step = n_target;
        boss = ee.steps[n_target];
        if (isdefined(boss))
        {
            boss.started = 1;
            if (isdefined(boss.setup_func))
                level thread [[boss.setup_func]](0);
        }
    }

    if (isdefined(player))
        player PrintHint("^5已进入 Boss 战");
}

TriggerExfil()
{
    level flag::set("rbz_exfil_allowed");
    level flag::set("rbz_exfil_beacon_active");
    level flag::set(#"hash_3e765c26047c9f54");
    self PrintHint("^5已触发撤离");
}

DropEssence()
{
    names = [];
    names[0] = #"resource_item_harvesting_zm";
    names[1] = #"resource_item_harvesting_sr";
    names[2] = #"resource_item_sr";
    i = 0;
    while (i < names.size)
    {
        point = function_4ba8fde(names[i]);
        if (isdefined(point))
        {
            self DropQuestItem(names[i]);
            return;
        }
        i++;
    }
    self PrintHint("^1道具无效或本图未加载");
}

DropQuestItem(item)
{
    origin = self GetLookOrigin();
    angle = self getangles();
    point = function_4ba8fde(item);
    if (!isdefined(point))
    {
        self PrintHint("^1道具无效或本图未加载");
        return;
    }

    bundle = getscriptbundle(item);
    weap = undefined;
    ammo = 0;
    if (isdefined(bundle) && isdefined(bundle.weapon))
    {
        weap = getweapon(bundle.weapon);
        if (isdefined(weap))
            ammo = weap.maxammo;
    }

    self item_drop::drop_item(0, weap, 1, ammo, point.id, origin, angle, 3);
    self PrintHint("^5已掉落道具");
}
