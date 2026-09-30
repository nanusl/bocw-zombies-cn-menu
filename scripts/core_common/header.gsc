#include script_4ccfb58a9443a60b;
#include script_437ce686d29bb81b;
#include scripts\core_common\callbacks_shared.gsc;
#include scripts\core_common\system_shared.gsc;
#include scripts\core_common\flag_shared.gsc;
#include scripts\core_common\array_shared.gsc;
#include scripts\core_common\util_shared.gsc;
#include scripts\core_common\clientfield_shared.gsc;
#include scripts\core_common\values_shared.gsc;
#include scripts\core_common\aat_shared.gsc;
#include scripts\core_common\item_inventory.gsc;
#include scripts\core_common\item_drop.gsc;
#include scripts\killstreaks\killstreaks_shared.gsc;
#include scripts\zm_common\zm_score.gsc;
#include scripts\zm_common\zm_powerups.gsc;
#include scripts\zm_common\zm_weapons.gsc;
#include scripts\zm_common\zm_perks.gsc;
#include scripts\zm_common\zm_utility.gsc;
#include scripts\zm_common\zm_loadout.gsc;
#include scripts\zm_common\zm_equipment.gsc;
#include scripts\zm_common\zm_laststand.gsc;
#include scripts\zm_common\zm_game_module.gsc;
#include scripts\zm_common\zm_round_logic.gsc;
#include scripts\zm_common\zm_audio.gsc;
#include scripts\core_common\content_manager.gsc;
#include scripts\core_common\struct.gsc;
#include scripts\core_common\scene_shared.gsc;
#include scripts\core_common\ai\zombie_utility.gsc;
#include scripts\zm\powerup\zm_powerup_hero_weapon_power.gsc;
#include scripts\core_common\player\player_stats.gsc;
#include scripts\zm_common\zm_intel.gsc;
#include scripts\zm_common\zm_stats.gsc;
#include scripts\zm_common\zm_utility_zsurvival.gsc;

// One #namespace per compile unit.
#namespace cnbocwmenu;

autoexec __init__system__()
{
    system::register(#"cnbocwmenu", &__init__, undefined, undefined, undefined);
    system::ignore(#"cheat");
}

__init__()
{
    callback::on_start_gametype(&init);
    callback::on_spawned(&onPlayerSpawned);
}
