SpawnAi(ai_type)
{
    ai = self SpawnAiAtLook(ai_type);
    if (isdefined(ai))
        self PrintHint("^5已召唤");
    else
        self SpawnFailHint();
}

SpawnFriendly(ai_type)
{
    self SpawnFriendlyInternal(ai_type);
}

RegularZombieTypes()
{
    types = [];
    switch (level.script)
    {
        case "zm_silver":
            types = strtok("spawner_zm_zombie,spawner_zm_zombie_silver,spawner_zm_zombie_silver_dp,spawner_bo5_zombie_zm_silver,spawner_bo5_zombie_zm_silver_armor_medium,spawner_bo5_zombie_zm_silver_armor_heavy", ",");
            break;
        case "zm_gold":
            types = strtok("spawner_bo5_zombie_zm_gold,spawner_bo5_zombie_zm_gold_soldiers,spawner_bo5_zombie_zm_gold_female,spawner_bo5_zombie_zm_gold_armor_medium,spawner_bo5_zombie_zm_gold_armor_heavy", ",");
            break;
        case "zm_platinum":
            types = strtok("spawner_bo5_zombie_zm_platinum,spawner_bo5_zombie_zm_platinum_omega_soldier,spawner_bo5_zombie_zm_platinum_german_soldier,spawner_bo5_zombie_zm_platinum_german_soldier_pap_03,spawner_bo5_zombie_zm_platinum_german_soldier_pap_02,spawner_bo5_zombie_zm_platinum_german_soldier_pap_01,spawner_bo5_zombie_zm_platinum_female,spawner_bo5_zombie_zm_platinum_american_soldier,spawner_bo5_zombie_zm_platinum_amor_medium,spawner_bo5_zombie_zm_platinum_armor_heavy", ",");
            break;
        case "zm_tungsten":
            types = strtok("spawner_bo5_zombie_zm_platinum,spawner_bo5_zombie_zm_tungsten,spawner_bo5_zombie_zm_tungsten_omega_soldier,spawner_bo5_zombie_zm_tungsten_german_soldier,spawner_bo5_zombie_zm_tungsten_german_soldier_pap_03,spawner_bo5_zombie_zm_tungsten_german_soldier_pap_02,spawner_bo5_zombie_zm_tungsten_armor_medium,spawner_bo5_zombie_zm_tungsten_armor_heavy", ",");
            break;
        default:
            types = strtok("spawner_zm_zombie,spawner_zm_zombie_onslaught,spawner_bo5_zombie_sr,spawner_bo5_zombie_sr_female,spawner_bo5_zombie_sr_armor_medium,spawner_bo5_zombie_sr_armor_heavy", ",");
            break;
    }
    return types;
}

SpawnRegularZombies(count)
{
    self thread SpawnRegularZombiesThink(count, 0);
}

SpawnFriendlyRegularZombies(count)
{
    self thread SpawnRegularZombiesThink(count, 1);
}

SpawnRegularZombiesThink(count, friendly)
{
    self endon("disconnect");
    types = RegularZombieTypes();
    if (!isdefined(types) || !types.size)
    {
        self PrintHint("^1本图没有僵尸类型");
        return;
    }

    if (!isdefined(count) || count < 1)
        count = 20;

    spawned = 0;
    tries = 0;
    max_tries = count * 3;
    while (spawned < count && tries < max_tries)
    {
        name = types[randomint(types.size)];
        ai_type = ishash(name) ? name : hash(name);
        ai = self SpawnAiAtLook(ai_type);
        if (isdefined(ai))
        {
            spawned++;
            jitter = (randomintrange(-70, 71), randomintrange(-70, 71), 0);
            dest = ai.origin + jitter;
            nav = getclosestpointonnavmesh(dest, 200, 32);
            if (isdefined(nav))
                dest = nav;

            if (!SpotIsStandable(dest))
                dest = ai.origin;

            ai forceteleport(dest, ai.angles);
            if (friendly)
            {
                waitframe(1);
                if (isalive(ai))
                    ai thread MakeFriendly(self);
            }
        }
        tries++;
        wait 0.15;
    }

    fail = count - spawned;
    prefix = "^5已召唤僵尸 x";
    if (friendly)
        prefix = "^5友方僵尸 x";
    if (spawned < 1)
        self SpawnFailHint();
    else if (fail > 0)
        self PrintHint(prefix + spawned + " ^1失败 x" + fail);
    else
        self PrintHint(prefix + spawned);
}

SpawnFriendlyInternal(ai_type)
{
    ai = self SpawnAiAtLook(ai_type);
    if (!isdefined(ai))
    {
        self SpawnFailHint();
        return;
    }

    waitframe(1);
    if (isalive(ai))
        ai thread MakeFriendly(self);

    self PrintHint("^5友方已召唤");
}

SpawnFailHint()
{
    r = self.spawn_fail;
    if (r === "full")
        self PrintHint("^1召唤失败：数量上限");
    else if (r === "type")
        self PrintHint("^1召唤失败：本图没有该类型");
    else if (r === "pos")
        self PrintHint("^1召唤失败：落点无效");
    else
        self PrintHint("^1召唤失败");
}

ProbeStep()
{
    return 40;
}

ClimbLimit()
{
    return 24;
}

DropLimit()
{
    return 80;
}

FloorAt(v_pos, n_ref_z)
{
    v_from = (v_pos[0], v_pos[1], n_ref_z + ProbeStep());
    v_to = (v_pos[0], v_pos[1], n_ref_z - ProbeStep());

    s_trace = groundtrace(v_from, v_to, 0, undefined);

    if (!isdefined(s_trace) || !isdefined(s_trace[#"position"]))
        return undefined;

    if (isdefined(s_trace[#"fraction"]) && s_trace[#"fraction"] >= 1)
        return undefined;

    v_hit = s_trace[#"position"];

    if (abs(v_hit[2] - n_ref_z) > ProbeStep())
        return undefined;

    return v_hit;
}

WalkSpan(v_from, n_yaw, n_max)
{
    v_dir = anglestoforward((0, n_yaw, 0));

    v_at = v_from;
    n_done = 0;

    while (n_done < n_max)
    {
        n_next = n_done + 24;
        if (n_next > n_max)
            n_next = n_max;

        v_want = v_from + v_dir * n_next;

        s_wall = bullettrace(v_at + (0, 0, 40), (v_want[0], v_want[1], v_at[2] + 40), 0, undefined);
        if (isdefined(s_wall) && isdefined(s_wall[#"fraction"]) && s_wall[#"fraction"] < 0.99)
            break;

        v_ground = FloorAt(v_want, v_at[2]);
        if (!isdefined(v_ground))
            break;

        v_at = v_ground;
        n_done = n_next;
    }

    s_result = spawnstruct();
    s_result.dist = n_done;
    s_result.origin = v_at;
    return s_result;
}

RoomOpenness(v_pos)
{
    n_total = 0;
    n_min = 100000;

    for (n_bearing = 0; n_bearing < 360; n_bearing += 45)
    {
        n_span = WalkSpan(v_pos, n_bearing, 260).dist;
        n_total += n_span;

        if (n_span < n_min)
            n_min = n_span;
    }

    return n_total + n_min * 8;
}

SpotHeightOk(v_spot, v_start)
{
    n_dz = v_spot[2] - v_start[2];

    if (n_dz > ClimbLimit())
        return false;

    return n_dz >= 0 - DropLimit();
}

SpotInPlayArea(v_spot)
{
    return zm_utility::check_point_in_playable_area(v_spot);
}

SpotIsStandable(v_spot)
{
    if (!isdefined(FloorAt(v_spot, v_spot[2])))
        return false;

    for (n_bearing = 0; n_bearing < 360; n_bearing += 90)
    {
        if (WalkSpan(v_spot, n_bearing, 96).dist >= 24)
            return true;
    }

    return false;
}

FindWalkableSpot(v_start)
{
    if (SpotIsStandable(v_start))
        return v_start;

    foreach (n_dist in array(110, 180, 260))
    {
        b_found = false;
        v_best = undefined;
        n_best = 0;

        for (n_bearing = 0; n_bearing < 360; n_bearing += 30)
        {
            s_reach = WalkSpan(v_start, n_bearing, n_dist);

            if (s_reach.dist < 24)
                continue;
            if (!SpotHeightOk(s_reach.origin, v_start))
                continue;
            if (!SpotInPlayArea(s_reach.origin))
                continue;

            n_score = RoomOpenness(s_reach.origin);
            if (!b_found || n_score > n_best)
            {
                b_found = true;
                n_best = n_score;
                v_best = s_reach.origin;
            }
        }

        if (b_found)
            return v_best;

        waitframe(1);
    }

    return undefined;
}

SpawnAiAtLook(ai_type)
{
    self.spawn_fail = undefined;
    origin = self GetLookOrigin();

    spot = FindWalkableSpot(origin);
    if (isdefined(spot))
        origin = spot;
    nav = getclosestpointonnavmesh(origin, 200, 32);
    if (!isdefined(nav))
        nav = getclosestpointonnavmesh(self.origin, 200, 32);
    if (isdefined(nav))
        origin = nav;
    else
    {
        self.spawn_fail = "pos";
        return undefined;
    }

    angle = self getangles() + (0, -180, 0);
    if (getfreeactorcount() < 1)
    {
        zombies = getaiarchetypearray(#"zombie");
        foreach (z in zombies)
        {
            if (!isdefined(z) || !isalive(z))
                continue;
            if (is_true(z.cnbocw_friendly) || is_true(z.aat_turned) || z.team === #"allies")
                continue;
            z.allowdeath = 1;
            z kill();
            waitframe(1);
            break;
        }
    }
    if (getfreeactorcount() < 1)
    {
        self.spawn_fail = "full";
        return undefined;
    }

    ai = spawnactor(ai_type, origin, angle, "debug_spawn", 1);
    if (!isdefined(ai))
    {
        self.spawn_fail = "type";
        return undefined;
    }

    ai.never_hide = 1;
    ai.b_ignore_cleanup = 1;
    ai.ignore_enemy_count = 1;
    ai.completed_emerging_into_playable_area = 1;
    ai.exclude_cleanup_adding_to_total = 1;
    ai.zombie_think_done = 1;
    ai.var_7a5e475 = 0;
    ai.ignoreall = 0;
    ai.check_point_in_enabled_zone = &zm_utility::check_point_in_playable_area;
    ai forceteleport(origin, angle);
    ai pathmode("move allowed");
    return ai;
}

MakeFriendly(owner)
{
    self endon(#"death");

    self.favoriteenemy = undefined;
    self.aat_turned = 1;
    self.cnbocw_friendly = 1;
    self.team = #"allies";
    self.n_aat_turned_zombie_kills = 0;
    self.ignoreall = 0;
    self.keep_moving = 0;
    self.zombie_think_done = 1;
    self.completed_emerging_into_playable_area = 1;
    self clearpath();
    self pathmode("move allowed");

    if (isplayer(owner))
        self.var_443d78cc = owner;

    self ApplyFriendlyPersist();

    if (self.archetype === #"zombie")
        self zombie_utility::set_zombie_run_cycle_override_value("super_sprint");

    if (self.archetype === #"zombie" || self.archetype === #"zombie_dog")
        self clientfield::set("ammomod_brainrot", 1);

    if (isdefined(self.on_brainrot))
        self [[ self.on_brainrot ]]();

    self RegisterFriendlyTarget();
    EnsureFriendlyAatHook();
    self thread FriendlyHuntThink();
}

EnsureFriendlyAatHook()
{
    if (isdefined(level.cnbocw_aat_hook))
        return;

    level.cnbocw_aat_hook = 1;
    callback::on_ai_damage(&FriendlyAatOnDamage);
}

FriendlyAatOnDamage(params)
{
    if (is_true(self.aat_turned) || self.team === #"allies")
        return;

    attacker = params.eattacker;
    if (!isdefined(attacker) || isplayer(attacker))
        return;
    if (!is_true(attacker.aat_turned) && attacker.team !== #"allies")
        return;

    owner = attacker.var_443d78cc;
    if (!isplayer(owner) || !isalive(owner))
        return;

    weapon = owner GetAatWeapon();
    if (!isdefined(weapon))
        return;

    death = params.idamage >= self.health;
    self aat::aat_response(death, params.einflictor, owner, params.idamage, params.idflags, "MOD_RIFLE_BULLET", weapon, params.var_fd90b0bb, params.vpoint, params.vdir, params.shitloc, params.psoffsettime, params.boneindex, params.surfacetype);
}

GetAatWeapon()
{
    weapon = self getcurrentweapon();
    if (isdefined(weapon) && isdefined(self aat::getaatonweapon(weapon)))
        return weapon;

    if (isdefined(self.aat))
    {
        keys = getarraykeys(self.aat);
        foreach (w in keys)
        {
            if (isdefined(w) && isdefined(self.aat[w]) && self.aat[w] != "none")
                return w;
        }
    }
    return undefined;
}

ApplyFriendlyPersist()
{
    hp = 99999999;
    self.maxhealth = hp;
    self.health = hp;
    self.var_5ade90d9 = hp;
    self.allowdeath = 0;
    self.allowpain = 0;
    self.b_ignore_cleanup = 1;
    self.never_hide = 1;
    self.ignore_enemy_count = 1;
    self.exclude_cleanup_adding_to_total = 1;
    self.completed_emerging_into_playable_area = 1;
    self.var_921627ad = 1;
    self.var_4df707f6 = 1;
    self.var_a950813d = 1;

    if (!is_true(self.magic_bullet_shield))
        self util::magic_bullet_shield();

    self.ignoreme = 0;
    self.am_i_valid = 1;
    self.last_valid_position = self.origin;
}

RegisterFriendlyTarget()
{
    EnsureFriendlyTargetHook();

    if (!isdefined(level.zombie_targets))
        level.zombie_targets = [];
    if (!isinarray(level.zombie_targets, self))
        level.zombie_targets[level.zombie_targets.size] = self;

    self thread FriendlyTargetCleanup();
}

FriendlyTargetCleanup()
{
    self waittill(#"death");
    if (isdefined(level.zombie_targets))
        arrayremovevalue(level.zombie_targets, self, 0);
}

EnsureFriendlyTargetHook()
{
    if (isdefined(level.cnbocw_friendly_hook))
        return;

    level.cnbocw_friendly_hook = 1;
    level.cnbocw_old_no_target = level.no_target_override;
    level.no_target_override = &FriendlyNoTargetOverride;
}

FriendlyNoTargetOverride(zombie)
{
    if (isdefined(zombie) && isalive(zombie) && zombie.team !== #"allies")
    {
        friend = FriendlyClosest(zombie.origin);
        if (isdefined(friend))
        {
            zombie.favoriteenemy = friend;
            zombie.enemy = friend;
            if (isdefined(friend.origin))
                zombie setgoal(friend.origin);
            return;
        }
    }

    if (isdefined(level.cnbocw_old_no_target))
        [[ level.cnbocw_old_no_target ]](zombie);
}

FriendlyClosest(origin)
{
    best = undefined;
    bestd = 0;
    if (isdefined(level.zombie_targets))
    {
        foreach (f in level.zombie_targets)
        {
            if (!isdefined(f) || !isalive(f))
                continue;
            if (f.team !== #"allies")
                continue;
            d = distancesquared(origin, f.origin);
            if (!isdefined(best) || d < bestd)
            {
                best = f;
                bestd = d;
            }
        }
    }
    return best;
}

FriendlyHuntThink()
{
    self endon(#"death");
    n = 0;

    while (isalive(self))
    {
        self.team = #"allies";
        self.aat_turned = 1;
        self.ignoreall = 0;
        self.ignoreme = 0;
        self.am_i_valid = 1;
        if (isdefined(self.origin))
            self.last_valid_position = self.origin;

        n++;
        if (n >= 10)
        {
            n = 0;
            self ApplyFriendlyPersist();
        }

        target = undefined;
        best = undefined;
        enemies = getaiteamarray(level.zombie_team);
        if (isdefined(enemies))
        {
            foreach (enemy in enemies)
            {
                if (!isdefined(enemy) || !isalive(enemy) || enemy == self)
                    continue;
                if (is_true(enemy.cnbocw_friendly) || is_true(enemy.aat_turned) || enemy.team === #"allies")
                    continue;
                d = distancesquared(self.origin, enemy.origin);
                if (!isdefined(best) || d < best)
                {
                    best = d;
                    target = enemy;
                }
            }
        }

        if (isdefined(target))
        {
            self.favoriteenemy = target;
            self.enemy = target;
            if (isdefined(target.origin))
                self setgoal(target.origin);
            self FriendlyPullEnemy(target);
        }
        else if (isplayer(self.var_443d78cc) && isalive(self.var_443d78cc))
        {
            self.favoriteenemy = self.var_443d78cc;
            self.enemy = self.var_443d78cc;
            self setgoal(self.var_443d78cc.origin);
        }
        else
        {
            self.favoriteenemy = undefined;
            self.enemy = undefined;
        }

        wait 0.5;
    }
}

FriendlyPullEnemy(enemy)
{
    if (!isdefined(enemy) || !isalive(enemy))
        return;
    if (is_true(enemy.cnbocw_friendly) || is_true(enemy.aat_turned) || enemy.team === #"allies")
        return;
    if (distancesquared(self.origin, enemy.origin) > 810000)
        return;
    enemy.favoriteenemy = self;
    enemy.enemy = self;
    enemy setgoal(self.origin);
}
