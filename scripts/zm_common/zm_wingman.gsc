ToggleWingman(kind)
{
    if (kind == "ac130")
    {
        self ToggleAirSupport();
        return;
    }

    same = isDefined(self.wingman) && self.wingman_id === kind;
    self StopCloseWingman();
    if (same)
    {
        self PrintHint("^5僚机 ^1已关闭");
        return;
    }

    self.wingman = true;
    self.wingman_id = kind;
    self thread WingmanThink(kind);
    if (kind == "plush")
        self PrintHint("^5僚机：玩具 ^2已启用");
    else
        self PrintHint("^5僚机：装置 ^2已启用");
}

ToggleAirSupport()
{
    if (isDefined(self.wingman_air))
    {
        self StopAirSupport();
        self PrintHint("^5空中支援：AC-130 ^1已关闭");
        return;
    }

    self.wingman_air = true;
    self.wingman_air_id = "ac130";
    self thread WingmanThink("ac130");
    self PrintHint("^5空中支援：AC-130 ^2已启用");
}

StopAirSupport()
{
    self notify(#"stop_wingman_air");
    if (isdefined(self.wingman_air_ents))
    {
        foreach (ent in self.wingman_air_ents)
        {
            if (isdefined(ent))
                ent delete();
        }
    }
    self.wingman_air_ents = [];
    self.wingman_air = undefined;
    self.wingman_air_id = undefined;
}

StopCloseWingman()
{
    self notify(#"stop_wingman");
    if (isdefined(self.wingman_ents))
    {
        foreach (ent in self.wingman_ents)
        {
            if (isdefined(ent))
                ent delete();
        }
    }
    self.wingman_ents = [];
    if (isdefined(self.wingman_rotator))
    {
        self.wingman_rotator delete();
        self.wingman_rotator = undefined;
    }
    self.wingman = undefined;
    self.wingman_id = undefined;
}

WingmanThink(kind)
{
    self endon("disconnect");
    if (kind == "ac130")
        self endon(#"stop_wingman_air");
    else
        self endon(#"stop_wingman");

    models = [];
    count = 2;
    height = 40;
    dist = 48;
    range = 450;
    waitt = 0.15;
    if (kind == "plush")
    {
        models[0] = #"p9_zm_platinum_magic_box_bunny";
        models[1] = #"p8_stuffed_dragon_yellow";
        models[2] = #"p7_zm_teddybear";
        models[3] = #"p9_nt6x_win_snowman";
        count = 4;
        dist = 44;
        waitt = 0.35;
    }
    else if (kind == "device")
    {
        models[0] = #"p9_machine_arcade_02";
        models[1] = #"p7_zm_ctl_deathray_sphere";
        models[2] = #"p9_sur_machine_rocket_01";
        models[3] = #"hash_11bef33a8a5054ee";
        count = 4;
        dist = 52;
        waitt = 0.35;
    }
    else if (kind == "ac130")
    {
        count = 1;
        range = 1800;
        waitt = 0.12;
    }

    if (kind == "ac130")
        self WingmanSpawnAir("veh_t8_ac130_gunship_mp", -27, 320);
    else
    {
        self.wingman_ents = [];
        self.wingman_orbit_z = height;
        self WingmanSpawnOrbit(models, count, height, dist, 5, self WingmanScale(kind));
    }

    shot_ms = int(waitt * 1000);
    if (shot_ms < 50)
        shot_ms = 50;
    next_shot = 0;
    while (true)
    {
        if (kind == "ac130")
        {
            if (!isDefined(self.wingman_air))
                break;
        }
        else
        {
            if (!isDefined(self.wingman))
                break;
            if (isdefined(self.wingman_rotator))
                self.wingman_rotator.origin = self.origin + (0, 0, self.wingman_orbit_z);
        }

        now = gettime();
        if (now >= next_shot)
        {
            next_shot = now + shot_ms;
            target = self WingmanNearest(range);
            ents = (kind == "ac130") ? self.wingman_air_ents : self.wingman_ents;
            if (isdefined(target) && isdefined(ents) && ents.size)
            {
                foreach (shooter in ents)
                {
                    if (!isdefined(shooter))
                        continue;
                    if (!isdefined(target) || !isalive(target))
                    {
                        target = self WingmanNearest(range);
                        if (!isdefined(target))
                            break;
                    }
                    self WingmanPlayAttackFx(target, shooter, kind);
                    self WingmanHit(target, shooter, kind);
                    waitframe(1);
                }
            }
        }
        waitframe(1);
    }
}

WingmanScale(kind)
{
    if (kind == "plush")
        return 0.4;
    if (kind == "device")
        return 0.18;
    return 0.35;
}

WingmanMapCenter()
{
    if (isdefined(level.mapcenter))
        return level.mapcenter;
    return self.origin;
}

WingmanAirHeight()
{
    center = self WingmanMapCenter();
    height = undefined;
    lockh = getheliheightlockheight(center);
    if (isdefined(lockh) && lockh > center[2] + 400)
        height = lockh;
    if (!isdefined(height))
    {
        air = struct::get("air_support_height", "targetname");
        if (isdefined(air) && isdefined(air.origin))
            height = air.origin[2];
    }
    if (!isdefined(height) || height < center[2] + 800)
        height = center[2] + 2200;
    height += 300;
    if (height > center[2] + 4200)
        height = center[2] + 4200;
    return height;
}

WingmanMapBounds()
{
    x0 = undefined;
    x1 = undefined;
    y0 = undefined;
    y1 = undefined;
    corners = getentarray("minimap_corner", "targetname");
    if (isdefined(corners) && corners.size >= 2)
    {
        x0 = corners[0].origin[0];
        x1 = corners[1].origin[0];
        y0 = corners[0].origin[1];
        y1 = corners[1].origin[1];
        if (x0 > x1)
        {
            t = x0;
            x0 = x1;
            x1 = t;
        }
        if (y0 > y1)
        {
            t = y0;
            y0 = y1;
            y1 = t;
        }
    }
    if (!isdefined(x0))
    {
        center = self WingmanMapCenter();
        x0 = center[0] - 2800;
        x1 = center[0] + 2800;
        y0 = center[1] - 2800;
        y1 = center[1] + 2800;
    }
    b = spawnstruct();
    b.x0 = x0;
    b.x1 = x1;
    b.y0 = y0;
    b.y1 = y1;
    return b;
}

WingmanAirEllipse(height)
{
    b = self WingmanMapBounds();
    padx = (b.x1 - b.x0) * 0.08;
    pady = (b.y1 - b.y0) * 0.08;
    if (padx < 200)
        padx = 200;
    if (pady < 200)
        pady = 200;
    x0 = b.x0 + padx;
    x1 = b.x1 - padx;
    y0 = b.y0 + pady;
    y1 = b.y1 - pady;
    hw = (x1 - x0) * 0.5;
    hh = (y1 - y0) * 0.5;
    mx = (x0 + x1) * 0.5;
    my = (y0 + y1) * 0.5;
    ax = hw * 0.42;
    ay = hh * 0.42;
    if (ax < 900)
        ax = 900;
    if (ay < 700)
        ay = 700;
    if (ax > hw)
        ax = hw;
    if (ay > hh)
        ay = hh;
    cx = self.origin[0];
    cy = self.origin[1];
    minx = x0 + ax;
    maxx = x1 - ax;
    miny = y0 + ay;
    maxy = y1 - ay;
    if (minx > maxx)
    {
        cx = mx;
        ax = hw;
    }
    else
    {
        if (cx < minx)
            cx = minx;
        if (cx > maxx)
            cx = maxx;
    }
    if (miny > maxy)
    {
        cy = my;
        ay = hh;
    }
    else
    {
        if (cy < miny)
            cy = miny;
        if (cy > maxy)
            cy = maxy;
    }
    e = spawnstruct();
    e.cx = cx;
    e.cy = cy;
    e.ax = ax;
    e.ay = ay;
    e.h = height;
    return e;
}

WingmanAirEllipsePoint(e, a)
{
    return (e.cx + cos(a) * e.ax, e.cy + sin(a) * e.ay, e.h);
}

WingmanAirEllipseYaw(e, a)
{
    look = (-1 * sin(a) * e.ax, cos(a) * e.ay, 0);
    return vectortoangles(look)[1];
}

WingmanRotatorThink(seconds)
{
    self endon(#"death");
    while (true)
    {
        self rotateyaw(360, seconds);
        wait seconds;
    }
}

WingmanSpawnOrbit(models, count, height, dist, period, scale)
{
    if (!isdefined(scale) || scale <= 0)
        scale = 0.35;

    rotator = spawn("script_model", self.origin + (0, 0, height));
    rotator setmodel(#"tag_origin");
    rotator hide();
    rotator notsolid();
    rotator.owner = self;
    rotator setowner(self);
    rotator.team = self.team;
    rotator setteam(self.team);
    rotator thread WingmanRotatorThink(period);
    self.wingman_rotator = rotator;

    i = 0;
    while (i < count)
    {
        if (!isdefined(models[i]))
        {
            i++;
            continue;
        }
        angle = i * (360 / count);
        offset = (cos(angle) * dist, sin(angle) * dist, 0);
        pos = rotator.origin + offset;
        link_angles = (0, angle + 90, 0);
        ent = spawn("script_model", pos);
        ent setmodel(models[i]);
        ent notsolid();
        ent setplayercollision(0);
        ent.owner = self;
        ent setowner(self);
        ent.team = self.team;
        ent setteam(self.team);
        m_scale = scale;
        if (models[i] == #"p9_nt6x_win_snowman")
            m_scale = 0.2;
        else if (models[i] == #"p9_sur_machine_rocket_01")
            m_scale = 0.12;
        else if (models[i] == #"p9_machine_arcade_02")
            m_scale = 0.16;
        else if (models[i] == #"hash_11bef33a8a5054ee")
            m_scale = 0.16;
        else if (models[i] == #"p7_zm_ctl_deathray_sphere")
            m_scale = 0.22;
        ent setscale(m_scale);
        ent linkto(rotator, "tag_origin", offset, link_angles);
        self.wingman_ents[self.wingman_ents.size] = ent;
        i++;
    }
}

WingmanSpawnAir(type, roll, speed)
{
    height = self WingmanAirHeight();
    if (!isdefined(speed) || speed < 80)
        speed = 320;
    e = self WingmanAirEllipse(height);
    start = self WingmanAirEllipsePoint(e, 0);
    ent = spawn("script_model", start);
    ent.angles = (0, self WingmanAirEllipseYaw(e, 0), roll);
    ent setmodel(type);
    ent notsolid();
    ent setplayercollision(0);
    ent.team = self.team;
    self.wingman_air_ents = [];
    self.wingman_air_ents[0] = ent;
    self thread WingmanAirPatrol(ent, roll, speed, e);
}

WingmanAirPatrol(ent, roll, speed, e)
{
    self endon("disconnect");
    self endon(#"stop_wingman_air");
    ent endon(#"death");
    a = 0;
    while (isdefined(ent) && isDefined(self.wingman_air))
    {
        a += 8;
        if (a >= 360)
            a -= 360;
        dest = self WingmanAirEllipsePoint(e, a);
        dist = distance(ent.origin, dest);
        time = dist / speed;
        if (time < 0.25)
            time = 0.25;
        if (time > 2)
            time = 2;
        yaw = self WingmanAirEllipseYaw(e, a);
        ent rotateto((0, yaw, roll), time);
        ent moveto(dest, time);
        wait time;
    }
}

WingmanGetAttackWeapon()
{
    wep = getweapon(#"hash_1734871fef9c0549");
    if (!isdefined(wep) || wep == level.weaponnone)
        wep = getweapon(#"gun_ultimate_turret");
    if (!isdefined(wep) || wep == level.weaponnone)
        wep = getweapon(#"minigun");
    if (!isdefined(wep) || wep == level.weaponnone)
        wep = getweapon(#"pistol_semiauto_t9");
    return wep;
}

WingmanGetRayGun()
{
    wep = getweapon("ray_gun");
    if (!isdefined(wep) || wep == level.weaponnone)
        wep = getweapon("ray_gun_upgraded");
    if (!isdefined(wep) || wep == level.weaponnone)
        wep = self WingmanGetAttackWeapon();
    return wep;
}

WingmanPlayAttackFx(target, shooter, kind)
{
    if (!isdefined(target) || !isdefined(shooter) || isplayer(target))
        return;
    wep = self WingmanGetAttackWeapon();
    if (kind == "ac130" || kind == "device")
        wep = self WingmanGetRayGun();
    if (!isdefined(wep) || wep == level.weaponnone)
        return;
    start = shooter.origin;
    end = target.origin + (0, 0, 32);
    if (kind != "ac130")
        start = start + (0, 0, 12);
    trace = bullettrace(start, end, 1, shooter);
    if (isdefined(trace["entity"]) && isplayer(trace["entity"]))
        return;
    magicbullet(wep, start, end, shooter);
}

WingmanHit(target, shooter, kind)
{
    if (!isdefined(target) || !isalive(target) || isplayer(target))
        return;
    if (is_true(target.cnbocw_friendly) || is_true(target.aat_turned) || target.team === #"allies")
        return;
    if (target == self)
        return;

    wep = getweapon(#"pistol_semiauto_t9");
    dmg = self WingmanHitDamage(target, kind);
    hit_pos = target.origin + (0, 0, 35);
    if (isdefined(wep) && wep != level.weaponnone)
        target dodamage(dmg, hit_pos, self, shooter, "none", "MOD_PISTOL_BULLET", 0, wep);
    else
        target dodamage(dmg, hit_pos, self, shooter, "none", "MOD_CRUSH");
}

WingmanHitDamage(target, kind)
{
    base = randomintrange(100, 351);
    maxh = 0;
    if (isdefined(target.maxhealth) && target.maxhealth > 0)
        maxh = target.maxhealth;
    if (maxh < 1)
        return base;

    pct = 12;
    if (kind == "ac130")
        pct = 20;
    cat = #"normal";
    if (isdefined(target.zm_ai_category))
        cat = target.zm_ai_category;
    if (cat === #"special")
        pct = int(pct / 2);
    else if (cat === #"elite")
        pct = int(pct / 4);
    else if (cat === #"boss")
        pct = int(pct / 10);
    if (pct < 1)
        pct = 1;

    dmg = int(maxh * pct / 1000);
    if (dmg < base)
        dmg = base;
    cap = int(maxh * 12 / 100);
    if (cap < base)
        cap = base;
    if (dmg > cap)
        dmg = cap;
    return dmg;
}

WingmanNearest(range)
{
    nearest = undefined;
    best = range * range;
    ais = getaiteamarray(level.zombie_team);
    if (!isdefined(ais))
        return undefined;

    foreach (ai in ais)
    {
        if (!isdefined(ai) || !isalive(ai))
            continue;
        if (is_true(ai.cnbocw_friendly) || is_true(ai.aat_turned) || ai.team === #"allies")
            continue;

        d = distancesquared(self.origin, ai.origin);
        if (d < best)
        {
            best = d;
            nearest = ai;
        }
    }
    return nearest;
}


