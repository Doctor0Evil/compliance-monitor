Universal Combat and Defense Functions
move_to(coordinates): Relocate entity to target grid or location.

attack(target): Execute standard attack on selected enemy.

defend(zone): Raise defenses at a specified node/region.

cast_skill(skill_id, target): Use a skill/spell on an entity/surface.

heal(target): Apply healing or repair effect to an ally or structure.

reinforce(structure_id): Instantly upgrade or fortify a base asset.

build(structure_type, coordinates): Place new turret, barricade, or utility.

dismantle(structure_id): Remove or recycle specific construction.

Advanced Tactical Commands
scout(area_id): Recon and reveal hidden threats or treasures.

set_trap(type, coordinates): Place trap (spike, explosive, snare) in selected position.

merge_towers(tower_id_1, tower_id_2): Combine two towers for a higher tier.

upgrade(asset_id): Enhance the functionality or stats of any game asset.

loot(entity_id): Collect resources from defeated unit or container.

quicksave(): Instantly snapshot current state for rollback and safety.

quickload(): Roll back to last quicksave in event of critical error.

teleport(entity_id, location): Instantly relocate entity/resource/hero.

revive(dead_unit): Restore fallen ally/survivor to functional state.

Environmental & Resource Control
harvest(resource_type): Gather factional resource (wood, stone, food, metal).

craft(item_id): Assemble new gear, weapon, or trap from available materials.

equip(entity_id, item_id): Assign equipment or resource to unit.

store(item_id, container_id): Transfer item to storage or container.

distribute(resource_type, count, recipients): Split resources among survivors or defenders.

Status and Crowd Control Interpreters
stun(target): Apply brief immobilization or disrupt action.

knockback(target): Physically push target away from origin.

slow(target): Reduce movement/action speed of target by a base percent.

decurse(target): Remove any negative effect/status afflicting entity.

shield(entity_id, duration): Grant temporary bonus protection or armor.

AI and Autonomy Routines
patrol(route_id): Loop pathing between specified waypoints for defense.

auto_upgrade(enabled): Activate intelligent upgrading of assets based on threat level.

auto_repair(threshold): Begin healing/repair if structure drops below percent threshold.

auto_loot(): Enable automatic collection of nearby resources or corpses.

auto_target(enemy_criteria): Automatically select highest-threat enemy for engagement.

auto_assign(role, unit_pool): Dynamically balance defenders and resource-gatherers based on priorities.

Emergency and Utility Interpreters
fallback(location): Retreat entity or squad to designated safe point.

mass_command(command, group_id): Issue specified command to multi-unit squad.

reset_game_state(): Perform debug-level full system reset (preserving essential state).

replay(last_action): Re-execute previous action for verification or correction.

notify(event_type): Broadcast alert as visual/audio/signal notification to all relevant agents.
