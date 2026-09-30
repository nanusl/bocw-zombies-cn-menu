runMenuIndex(menu)
{
    self endon("disconnect");

    if (!isDefined(menu))
        menu = "Main";

    switch (menu)
    {
        case "Main":
            self addMenu(menu, level.menuName);
            self addOpt("玩家", &newMenu, "Player");
            self addOpt("武器", &newMenu, "Weapon");
            self addOpt("购物", &newMenu, "Shop");
            self addOpt("掉落", &newMenu, "Drop");
            self addOpt("世界", &newMenu, "World");
            self addOpt("召唤", &newMenu, "Spawn");
            self addOpt("彩蛋", &newMenu, "Easter");
            self addOpt("账号", &newMenu, "Account");
            self addOpt("外观", &newMenu, "Appearance");
            break;

        case "Player":
            self addMenu(menu, "玩家");
            self addOptBool(self.godmode, "无敌", &ToggleGod);
            self addOptBool(self.tool_ignore, "无视", &ToggleIgnore);
            self addOptBool(self.tool_fly, "飞行", &ToggleFly);
            self addOptBool(self.tool_noclip, "穿墙", &ToggleNoclip);
            self addOptBool(self.tool_third, "第三人称", &ToggleThirdPerson);
            self addOptBool(self.UnlimitedAmmo, "无限弹药", &ToggleAmmo);
            self addOptBool(self.unlimited_equipment, "无限道具", &ToggleUnlimitedEquipment);
            self addOptBool(self.unlimited_field_upgrade, "无限战场升级", &ToggleUnlimitedFieldUpgrade);
            self addOptBool(self.unlimited_armor, "无限护甲", &ToggleUnlimitedArmor);
            self addOptBool(self.unlimited_vehicle, "无限载具耐久", &ToggleUnlimitedVehicle);
            self addOptBool(self.rapidfire, "连发", &ToggleRapidFire);
            self addOpt("自救针x3", &GiveSelfRevive);
            self addOpt("存点", &SaveLocation);
            self addOpt("读点", &LoadLocation);
            break;

        case "XpScale":
            self addMenu(menu, "XP 倍率");
            self addOpt("恢复默认", &SetXpScale, 1);
            self addOpt("x2", &SetXpScale, 2);
            self addOpt("x4", &SetXpScale, 4);
            self addOpt("x8", &SetXpScale, 8);
            self addOpt("x10", &SetXpScale, 10);
            break;

        case "Weapon":
            self addMenu(menu, "武器");
            self addOpt("PAP 黄金圣杯", &PapWeapon, "gold_chalice_item_sr");
            self addOpt("以太扳手", &RarityUp);
            self addOpt("RayGun", &GivePlayerWeapon, "ray_gun");
            self addOpt("D.I.E.", &newMenu, "WeaponDie");
            self addOpt("RAI K-84", &GivePlayerWeapon, "ww_ray_rifle_t9");
            self addOpt("CRBR-S", &newMenu, "WeaponCrbr");
            self addOpt("Chrysalax", &GivePlayerWeapon, "ww_axe_gun_melee_t9");
            self addOpt("其它武器", &newMenu, "WeaponOther");
            self addOpt("丢掉当前武器", &DropCurrentWeapon);
            self addOptBool(self.all_aat, "开启增强弹药模组", &ToggleAllAat);
            self addOpt("连杀奖励", &newMenu, "Streak");
            break;

        case "WeaponDie":
            self addMenu(menu, "D.I.E.");
            self addOpt("冲击波", &GivePlayerWeapon, "ww_ieu_shockwave_t9");
            self addOpt("电弧", &GivePlayerWeapon, "ww_ieu_electric_t9");
            self addOpt("热相", &GivePlayerWeapon, "ww_ieu_plasma_t9");
            self addOpt("Nova-5", &GivePlayerWeapon, "ww_ieu_gas_t9");
            self addOpt("冷冻发射器", &GivePlayerWeapon, "ww_ieu_acid_t9");
            break;

        case "WeaponCrbr":
            self addMenu(menu, "CRBR-S");
            self addOpt("CRBR-S", &GivePlayerWeapon, "ww_mega_barrel_fullauto_copycat_t9");
            self addOpt("Blazer", &GivePlayerWeapon, "ww_mega_barrel_fullauto_blazer_beam_t9");
            self addOpt("Diffusion", &GivePlayerWeapon, "ww_mega_barrel_fullauto_diffusion_beam_t9");
            self addOpt("Swarm", &GivePlayerWeapon, "ww_mega_barrel_fullauto_micro_missile_t9");
            break;

        case "WeaponOther":
            self addMenu(menu, "其它武器");
            self addOpt("Hauer 77", &GivePlayerWeapon, "shotgun_pump_t9");
            self addOpt("M79", &GivePlayerWeapon, "special_grenadelauncher_t9");
            break;

        case "Shop":
            self addMenu(menu, "购物");
            self addOpt("特长机", &TeleportToShop, "perk");
            self addOpt("工作台", &TeleportToShop, "craft");
            self addOpt("PAP", &TeleportToShop, "pap");
            self addOpt("护甲机", &TeleportToShop, "armor");
            self addOpt("弹药箱", &TeleportToShop, "ammo");
            self addOpt("神秘箱", &TeleportToShop, "box");
            self addOptBool(level.free_box, "免费神秘箱", &ToggleFreeBox);
            self addOptBool(level.box_nofly, "神秘箱不飞走", &ToggleBoxNoFly);
            break;

        case "Streak":
            self addMenu(menu, "连杀奖励");
            self addOpt("死亡机器", &GivePlayerWeapon, "sig_lmg");
            self addOpt("手炮", &GivePlayerWeapon, "hero_annihilator");
            self addOpt("喷火器", &GivePlayerWeapon, "hero_flamethrower");
            self addOpt("战争机器", &GivePlayerWeapon, "hero_pineapplegun");
            self addOpt("战斗弓", &GivePlayerWeapon, "sig_bow_flame");
            self addOpt("武装直升机炮手", &GiveKillstreak, "chopper_gunner");
            self addOpt("凝固汽油弹", &GivePlayerWeapon, #"hash_183ddeea72e71f27");
            self addOpt("火炮打击", &GivePlayerWeapon, #"hash_3f33adcbed7f6c86");
            self addOpt("巡航导弹", &GivePlayerWeapon, "remote_missile_zm");
            self addOpt("遥控炸弹车", &GivePlayerWeapon, "recon_car_zm");
            self addOpt("哨戒机枪", &GivePlayerWeapon, "ultimate_turret");
            break;

        case "Drop":
            self addMenu(menu, "掉落");
            self addOpt("一击必杀", &GivePowerupDrop, "insta_kill");
            self addOpt("弹药全满", &GivePowerupDrop, "full_ammo");
            self addOpt("双倍积分", &GivePowerupDrop, "double_points");
            self addOpt("核弹", &GivePowerupDrop, "nuke");
            self addOpt("木匠", &GivePowerupDrop, "carpenter");
            self addOpt("清仓甩卖", &GivePowerupDrop, "fire_sale");
            self addOpt("随机特长", &GivePowerupDrop, "free_perk");
            self addOpt("火力全开", &GivePowerupDrop, "hero_weapon_power");
            self addOpt("PAP 黄金圣杯", &DropQuestItem, "gold_chalice_item_sr");
            self addOpt("以太扳手", &DropQuestItem, "aether_tool_item_sr");
            self addOpt("精华", &DropEssence);
            self addOpt("废料", &DropQuestItem, "scrap_legendary_item_sr");
            break;

        case "World":
            self addMenu(menu, "世界");
            self addOpt("通电", &TurnOnPower);
            self addOpt("开门", &OpenAllDoors);
            self addOpt("僵尸", &newMenu, "WorldZombie");
            self addOpt("对局", &newMenu, "WorldMatch");
            break;

        case "WorldZombie":
            self addMenu(menu, "僵尸");
            self addOpt("清场", &KillAllZombies);
            self addOpt("友方清场", &KillFriendlyAi);
            self addOptBool(self.kill_loop, "循环清场", &ToggleKillLoop);
            self addOptBool(self.ZombiePos, "传到准星", &ToggleZombieTP);
            self addOptBool(self.oneHPZombs, "秒杀", &ToggleInstaKill);
            self addOptBool(level.no_spawn, "停刷", &ToggleNoSpawn);
            self addOptBool(level.freeze_ai, "定身", &ToggleFreezeAi);
            self addOptBool(level.dark_aether_fx, "暗乙太场景", &ToggleDarkAetherFx);
            self addOptBool(level.headless_ai, "下头", &ToggleHeadless);
            self addOpt("换皮", &newMenu, "ZombieSkin");
            self addOpt("眼色", &newMenu, "ZombieEyes");
            self addOpt("移速", &newMenu, "ZombieSpeed");
            break;

        case "WorldMatch":
            self addMenu(menu, "对局");
            self addOpt("快速重开", &FastRestart);
            self addOpt("切图", &newMenu, "ChangeMap");
            self addOpt("回合", &newMenu, "Round");
            break;

        case "Round":
            self addMenu(menu, "回合");
            self addOpt("回合 1", &SetRound, 1);
            self addOpt("回合 25", &SetRound, 25);
            self addOpt("回合 50", &SetRound, 50);
            self addOpt("回合 100", &SetRound, 100);
            self addOpt("回合 500", &SetRound, 500);
            self addOpt("回合 999", &SetRound, 999);
            break;

        case "ZombieSkin":
            self addMenu(menu, "换皮");
            self addOpt("恢复", &SetFunSkin, "off");
            self addOpt("雪人", &SetFunSkin, #"p9_nt6x_win_snowman");
            self addOpt("填充龙", &SetFunSkin, #"p8_stuffed_dragon_yellow");
            self addOpt("神秘箱兔子", &SetFunSkin, #"p9_zm_platinum_magic_box_bunny");
            self addOpt("特长机", &SetFunSkin, #"hash_11bef33a8a5054ee");
            self addOpt("圣诞树", &SetFunSkin, #"p9_zm_silver_foliage_tree_christmas_full");
            self addOpt("街机", &SetFunSkin, #"p9_machine_arcade_02");
            self addOpt("地狱犬雕像", &SetFunSkin, #"c_t9_zmb_hellhound");
            self addOpt("死亡射线球", &SetFunSkin, #"p7_zm_ctl_deathray_sphere");
            self addOpt("火箭", &SetFunSkin, #"p9_sur_machine_rocket_01");
            break;

        case "ZombieEyes":
            self addMenu(menu, "眼色");
            self addOpt("默认", &SetZombieEyes, -1);
            self addOpt("蓝", &SetZombieEyes, 2);
            self addOpt("绿", &SetZombieEyes, 3);
            self addOpt("橙", &SetZombieEyes, 4);
            self addOpt("无", &SetZombieEyes, 0);
            self addOptBool(level.eye_rainbow, "彩虹", &ToggleEyeRainbow);
            break;

        case "ZombieSpeed":
            self addMenu(menu, "移速");
            self addOpt("默认", &SetZombieSpeed, "default");
            self addOpt("走", &SetZombieSpeed, "walk");
            self addOpt("跑", &SetZombieSpeed, "run");
            self addOpt("冲刺", &SetZombieSpeed, "sprint");
            self addOpt("超级冲刺", &SetZombieSpeed, "super_sprint");
            break;

        case "ChangeMap":
            self addMenu(menu, "切图");
            self addOpt("回合图", &newMenu, "ChangeMapRound");
            self addOpt("疫情爆发", &newMenu, "ChangeMapOutbreak");
            break;

        case "ChangeMapRound":
            self addMenu(menu, "回合图");
            self addOpt("时光机器", &ChangeMap, "zm_silver");
            self addOpt("火力基地 Z", &ChangeMap, "zm_gold");
            self addOpt("死亡之墙", &ChangeMap, "zm_platinum");
            self addOpt("遗落孤魂", &ChangeMap, "zm_tungsten");
            break;

        case "ChangeMapOutbreak":
            self addMenu(menu, "疫情爆发");
            self addOpt("鲁卡", &ChangeMap, "wz_forest");
            self addOpt("高山", &ChangeMap, "wz_ski_slopes");
            self addOpt("哥洛瓦", &ChangeMap, "wz_golova");
            self addOpt("杜格", &ChangeMap, "wz_duga");
            self addOpt("疗养院", &ChangeMap, "wz_sanatorium");
            self addOpt("动物园", &ChangeMap, "wz_zoo");
            self addOpt("误袭", &ChangeMap, "mp_dune");
            self addOpt("舰队", &ChangeMap, "mp_black_sea");
            break;

        case "Easter":
            self addMenu(menu, "彩蛋");
            self addOpt("BossRush", &BossRush);
            self addOpt("BossRush 奥达", &BossRush, #"mq4");
            self addOpt("BossRush 军团长", &BossRush, #"reveal");
            self addOpt("播放彩蛋曲", &PlayEeSong);
            self addOptBool(level.dance_party, "时光机器舞会彩蛋", &ToggleDanceParty);
            self addOpt("跳过当前步", &SkipCurrentEeStep);
            self addOpt("跳过整条主线&撤离", &SkipMainQuest);
            self addOpt("开启撤离", &TriggerExfil);
            self addOpt("分图道具", &newMenu, "EasterDebug");
            break;

        case "EasterDebug":
            self addMenu(menu, "分图道具");
            self addOpt("时光机器 道具", &newMenu, "EasterSilver");
            self addOpt("火力基地 Z 道具", &newMenu, "EasterGold");
            self addOpt("死亡之墙 道具", &newMenu, "EasterPlatinum");
            self addOpt("遗落孤魂 道具", &newMenu, "EasterTungsten");
            break;

        case "EasterSilver":
            self addMenu(menu, "时光机器 道具");
            self addOpt("以太镜 1", &DropQuestItem, "item_zmquest_silver_mq_aetherscope_1");
            self addOpt("以太镜 2", &DropQuestItem, "item_zmquest_silver_mq_aetherscope_2");
            self addOpt("以太镜 3", &DropQuestItem, "item_zmquest_silver_mq_aetherscope_3");
            self addOpt("D.I.E. 烧瓶", &DropQuestItem, "item_zmquest_silver_ww_flask");
            self addOpt("D.I.E. 装满烧瓶", &DropQuestItem, "item_zmquest_silver_ww_flask_filled");
            self addOpt("D.I.E. 钥匙卡", &DropQuestItem, "item_zmquest_silver_ww_keycard");
            self addOpt("D.I.E. 保险丝", &DropQuestItem, "item_zmquest_silver_ww_fuse");
            self addOpt("D.I.E. 空罐", &DropQuestItem, "item_zmquest_silver_ww_canister_gasless");
            break;

        case "EasterGold":
            self addMenu(menu, "火力基地 Z 道具");
            self addOpt("电池", &DropQuestItem, "item_zmquest_gold_power_cell");
            self addOpt("未充电电池", &DropQuestItem, "item_zmquest_gold_unpower_cell");
            self addOpt("铲子", &DropQuestItem, "item_zmquest_gold_shovel");
            self addOpt("头", &DropQuestItem, "item_zmquest_gold_head");
            self addOpt("RAI 转换器", &DropQuestItem, "item_zmquest_gold_rifle_converter");
            self addOpt("储物柜钥匙", &DropQuestItem, "item_zmquest_gold_locker_key");
            self addOpt("枪管", &DropQuestItem, "item_zmquest_gold_barrel");
            self addOpt("化合物 36", &DropQuestItem, "item_zmquest_gold_compound_36");
            self addOpt("化合物 S16", &DropQuestItem, "item_zmquest_gold_compound_s16");
            self addOpt("化合物 P65", &DropQuestItem, "item_zmquest_gold_compound_p65");
            self addOpt("软盘", &DropQuestItem, "item_zmquest_gold_fd");
            break;

        case "EasterPlatinum":
            self addMenu(menu, "死亡之墙 道具");
            self addOpt("Klaus 电池", &DropQuestItem, "item_zmquest_platinum_klaus_battery");
            self addOpt("Klaus 手", &DropQuestItem, "item_zmquest_platinum_klaus_hand");
            self addOpt("Klaus 指令器", &DropQuestItem, "item_zmquest_klaus_command_device");
            self addOpt("保险丝", &DropQuestItem, "item_zmquest_platinum_power_quest_fuse");
            self addOpt("核弹头", &DropQuestItem, "item_zmquest_platinum_nuke_warhead");
            self addOpt("Rico 卡", &DropQuestItem, "item_zmquest_platinum_rico_card");
            self addOpt("CRBR-S", &DropQuestItem, "item_zmquest_platinum_ww");
            self addOpt("天线", &DropQuestItem, "item_zmquest_platinum_helm_component_antenna");
            self addOpt("晶体管", &DropQuestItem, "item_zmquest_platinum_helm_component_transistor");
            self addOpt("电路板", &DropQuestItem, "item_zmquest_platinum_helm_component_board");
            self addOpt("微波碟", &DropQuestItem, "item_zmquest_platinum_microwave_dish");
            self addOpt("磁盘 Punk", &DropQuestItem, "item_zmquest_platinum_disk_punk");
            self addOpt("磁盘 Goth", &DropQuestItem, "item_zmquest_platinum_disk_goth");
            self addOpt("磁盘 New Wave", &DropQuestItem, "item_zmquest_platinum_disk_new_wave");
            break;

        case "EasterTungsten":
            self addMenu(menu, "遗落孤魂 道具");
            self addOpt("PAP 零件 A", &DropQuestItem, "item_zmquest_tungsten_pap_quest_part_a");
            self addOpt("PAP 零件 B", &DropQuestItem, "item_zmquest_tungsten_pap_quest_part_b");
            self addOpt("PAP 零件 C", &DropQuestItem, "item_zmquest_tungsten_pap_quest_part_c");
            self addOpt("PAP 零件 D", &DropQuestItem, "item_zmquest_tungsten_pap_quest_part_d");
            self addOpt("燃料", &DropQuestItem, "item_zmquest_tungsten_mq_quest_part_fuel");
            self addOpt("壳体", &DropQuestItem, "item_zmquest_tungsten_mq_quest_part_housing");
            self addOpt("监视器", &DropQuestItem, "item_zmquest_tungsten_mq_quest_part_monitor");
            self addOpt("中和器", &DropQuestItem, "item_zmquest_tungsten_mq_quest_part_neutralizer");
            self addOpt("催化零件", &DropQuestItem, "item_zmquest_tungsten_mq_quest_part_catalyzed");
            self addOpt("碎片", &DropQuestItem, "item_zmquest_tungsten_mq_quest_part_shard");
            self addOpt("补燃料", &DropQuestItem, "item_zmquest_tungsten_mq_quest_part_refuel");
            self addOpt("Chrysalax 零件 A", &DropQuestItem, "item_zmquest_tungsten_ww_quest_part_a");
            self addOpt("Chrysalax 零件 B", &DropQuestItem, "item_zmquest_tungsten_ww_quest_part_b");
            self addOpt("Chrysalax 零件 C", &DropQuestItem, "item_zmquest_tungsten_ww_quest_part_c");
            self addOpt("挥发性晶体", &DropQuestItem, "axe_gun_volatile_crystal_item_t9");
            self addOpt("能量碎片", &DropQuestItem, "axe_gun_energetic_shard_item_t9");
            self addOpt("兔子", &DropQuestItem, "item_zmquest_tungsten_bunny");
            self addOpt("街机代币", &DropQuestItem, "item_zmquest_tungsten_arcade_token");
            break;

        case "Spawn":
            self addMenu(menu, "召唤");
            self addOpt("僵尸x20", &SpawnRegularZombies, 20);
            self addOpt("憎恶", &SpawnAi, #"spawner_bo5_abom");
            self addOpt("红战士", &SpawnAi, #"spawner_bo5_mechz_sr");
            self addOpt("百万吨", &SpawnAi, #"spawner_zm_steiner");
            self addOpt("绞肉机", &SpawnAi, #"hash_4f87aa2a203d37d0");
            self addOpt("拟态", &SpawnAi, #"spawner_bo5_mimic");
            self addOpt("使徒", &SpawnAi, #"spawner_bo5_soa");
            self addOpt("风暴", &SpawnAi, #"spawner_bo5_avogadro_sr");
            self addOpt("地狱犬", &SpawnAi, #"hash_7a8b592728eec95d");
            self addOpt("瘟疫犬", &SpawnAi, #"hash_12a17ab3df5889eb");
            self addOpt("奥洛夫", &SpawnAi, #"spawner_zm_steiner_f");
            self addOpt("奥达", &SpawnAi, #"hash_21f3d5d40d72e08d");
            self addOpt("友方召唤", &newMenu, "SpawnFriend");
            self addOptBool(self.wingman_air_id === "ac130", "空中支援：AC-130", &ToggleWingman, "ac130");
            self addOptBool(self.wingman_id === "plush", "僚机：玩具", &ToggleWingman, "plush");
            self addOptBool(self.wingman_id === "device", "僚机：装置", &ToggleWingman, "device");
            break;

        case "SpawnFriend":
            self addMenu(menu, "友方召唤");
            self addOpt("友方僵尸x20", &SpawnFriendlyRegularZombies, 20);
            self addOpt("友方憎恶", &SpawnFriendly, #"spawner_bo5_abom");
            self addOpt("友方红战士", &SpawnFriendly, #"spawner_bo5_mechz_sr");
            self addOpt("友方百万吨", &SpawnFriendly, #"spawner_zm_steiner");
            self addOpt("友方绞肉机", &SpawnFriendly, #"hash_4f87aa2a203d37d0");
            self addOpt("友方拟态", &SpawnFriendly, #"spawner_bo5_mimic");
            self addOpt("友方使徒", &SpawnFriendly, #"spawner_bo5_soa");
            self addOpt("友方风暴", &SpawnFriendly, #"spawner_bo5_avogadro_sr");
            self addOpt("友方地狱犬", &SpawnFriendly, #"hash_7a8b592728eec95d");
            self addOpt("友方瘟疫犬", &SpawnFriendly, #"hash_12a17ab3df5889eb");
            self addOpt("友方奥洛夫", &SpawnFriendly, #"spawner_zm_steiner_f");
            self addOpt("友方奥达", &SpawnFriendly, #"hash_21f3d5d40d72e08d");
            break;

        case "Account":
            self addMenu(menu, "账号");
            self addOptBool(self.xp_grind, "静默刷 XP", &ToggleXpGrind);
            self addOpt("XP 倍率", &newMenu, "XpScale");
            self addOptBool(self.tool_afk, "挂机模式", &ToggleAfk);
            self addOpt("完成全部僵尸挑战", &UnlockZmChallenges);
            self addOpt("解锁成就", &UnlockAllTrophies);
            self addOpt("解锁情报", &CollectAllIntel);
            break;

        case "Appearance":
            self addMenu(menu, "外观");
            self addOpt("迷彩", &newMenu, "Camo");
            self addOpt("特战兵", &newMenu, "Skin");
            self addOpt("皮肤", &newMenu, "Outfit");
            break;

        case "Camo":
            self addMenu(menu, "迷彩");
            self addOpt("解锁黑暗乙太迷彩", &UnlockDarkAether);
            self addOpt("PAP 1", &ApplyCamo, 67);
            self addOpt("PAP 2", &ApplyCamo, 68);
            self addOpt("PAP 3", &ApplyCamo, 69);
            self addOpt("死亡之墙 PAP 1", &ApplyCamo, 116);
            self addOpt("死亡之墙 PAP 2", &ApplyCamo, 117);
            self addOpt("死亡之墙 PAP 3", &ApplyCamo, 118);
            self addOpt("遗落孤魂 PAP 1", &ApplyCamo, 119);
            self addOpt("遗落孤魂 PAP 2", &ApplyCamo, 120);
            self addOpt("遗落孤魂 PAP 3", &ApplyCamo, 121);
            self addOpt("金", &ApplyCamo, 61);
            self addOpt("钻", &ApplyCamo, 62);
            self addOpt("DM Ultra", &ApplyCamo, 63);
            self addOpt("ZM 金", &ApplyCamo, 64);
            self addOpt("ZM 钻", &ApplyCamo, 65);
            self addOpt("黑暗乙太", &ApplyCamo, 66);
            self addOpt("按 ID", &newMenu, "CamoId");
            break;

        case "CamoId":
            self addMenu(menu, "按 ID");
            self addOpt("0–19", &OpenCamoRange, 0);
            self addOpt("20–39", &OpenCamoRange, 20);
            self addOpt("40–59", &OpenCamoRange, 40);
            self addOpt("60–79", &OpenCamoRange, 60);
            self addOpt("80–99", &OpenCamoRange, 80);
            self addOpt("100–119", &OpenCamoRange, 100);
            self addOpt("120–139", &OpenCamoRange, 120);
            self addOpt("140–149", &OpenCamoRange, 140);
            break;

        case "CamoRange":
            start = 0;
            if (isdefined(self.camo_id_start))
                start = self.camo_id_start;
            last = start + 19;
            if (last > 149)
                last = 149;
            self addMenu(menu, "迷彩 " + start + "-" + last);
            c = start;
            while (c <= last)
            {
                self addOpt("迷彩 " + c, &ApplyCamo, c);
                c++;
            }
            break;

        case "Skin":
            self addMenu(menu, "特战兵");
            if (isdefined(level._SkinNames))
            {
                for (s = 0; s < level._SkinNames.size; s++)
                    self addOpt(level._SkinNames[s], &ApplySkin, s);
            }
            break;

        case "Outfit":
            self addMenu(menu, "皮肤");
            for (o = 0; o < 24; o++)
                self addOpt("皮肤 " + o, &ApplyOutfit, o);
            break;

        default:
            self addMenu(menu, "404");
            self addOpt("未找到页面");
            break;
    }
}
