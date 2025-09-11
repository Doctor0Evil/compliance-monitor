Asset Definitions
asset.character.avatar: Main playable entity, customizable for narrative and stats.

asset.character.companion: Non-player ally, supports party in combat/adventuring.

asset.character.npc: Interactive character not directly controlled by player.

asset.character.enemy: Hostile entity with AI routines and variable threat levels.

asset.structure.tower: Placeable unit for defense, upgradable and mergeable.

asset.structure.shelter: Safehouse or base node, customizable and fortifiable.

asset.structure.barricade: Defensive wall with decay/repair mechanics.

asset.structure.trap: Deployable hazard object (fire, spike, snare, explosive).

asset.structure.workshop: Crafting/research hub for item/rune production.

asset.structure.storage: Container asset for resource and inventory management.

asset.structure.teleporter: Location asset for strategic instant movement.

asset.structure.gateway: Interactive node for zone and mission transitions.

asset.structure.generator: Produces energy/resource needed for local assets.

asset.structure.watchtower: Extended vision, enemy signal, and reinforcement buff.

asset.structure.water_source: Utility node; replenishes consumables.

asset.structure.repair_station: Instantly restores health/armor to entities.

asset.structure.incinerator: Deletes unwanted items/assets quickly.

asset.structure.lab: Technology unlock and upgrade triggering.

asset.structure.supply_depot: Trade asset, links inventory across player network.

asset.structure.market: NPC exchange, pricing, and economic asset.

asset.item.weapon.melee: Damage entity; various classes (sword, axe, etc).

asset.item.weapon.ranged: Projectile entity; upgradeable via runes.

asset.item.weapon.magic: Spellbook, wand, scroll—allows casting of skills.

asset.item.armor: Physical/magical protection, slot-based equip, upgradeable.

asset.item.rune: Equipment augment, dynamic slotting and bonuses.

asset.item.consumable: Temporary buff item (potions, food, scroll).

asset.item.material: Resource item (wood, ore, herbs, cloth).

asset.item.crafting_recipe: Unlocks new production options.

asset.item.quest: Story-locked item, triggers progression.

asset.item.container: Holds multiple small items.

asset.item.key: Unlocks asset/structure (door, chest, quest area).

asset.item.trap_component: Used directly in trap-building.

asset.item.tool: Single-use (shovel, pick, scanner, map).

asset.item.gadget: Reusable tactical utility (detect, scan, heal, move).

asset.item.blueprint: Provides advanced build options for new asset types.

asset.item.upgrade_token: Currency for structure/unit improvement.

asset.environment.surface: Dynamic field (water, oil, poison, fire, blood).

asset.environment.trigger: Interactive node for events and puzzles.

asset.environment.buff_zone: Area-of-effect for healing, regeneration, defense.

asset.environment.debuff_zone: Area-of-effect for poison, burning, slow, crowd control.

asset.environment.visibility: Vision and detection struct.

asset.environment.weather: Dynamic modifier for tactical events.

asset.environment.time_of_day: Schedules NPC/AI behavior routines.

asset.environment.sound_emitter: Audio asset linking cues to in-game actions.

asset.environment.lighting: Spot, ambient settings for immersion.

asset.ai.agent: Behavior-controlled entity, modular plug-ins.

asset.ai.controller: High-level strategic controller for adapted responses.

asset.ai.group: Entity swarms for crowd/formation management.

asset.ai.pathfinder: Movement solution tool for environment and maze.

asset.ai.interpreter: Dynamic handler for skill/item/environment routines.

Developer Tool Definitions
dev.editor.asset_builder: GUI module for asset creation/editing.

dev.editor.map_designer: Grid/zone planning, zone linking, asset placement.

dev.editor.logic_flow: Visual scripting for event/interaction logic.

dev.editor.dialogue_tree: Conversation/quest script designer.

dev.editor.animation: Frame/pose/tween editor asset.

dev.editor.recipe_manager: Custom crafting/recipe definition tool.

dev.editor.quest_tracker: Sequential event and requirement linking.

dev.editor.effect_designer: Particle, sound, lighting effect modular tuning.

dev.editor.ai_tuner: Finetunes behavior, goal, and response templates.

dev.editor.stats_balancer: Simulate, graph, and auto-tune asset parameters.

dev.editor.test_suite: Automated scenario/test generation tool.

dev.editor.mod_packager: Compiles, verifies, and version-controls mods.

dev.editor.localization: Language, region pack manager and injection.

dev.editor.lore_manager: World/story node definition system.

dev.editor.cinematic_builder: Storyboard and cutscene asset tool.

dev.editor.error_monitor: Tracks, logs, and resolves runtime faults.

dev.editor.replay_tool: Playback, analysis, and rollback utility.

dev.editor.platform_link: Multi-platform build manager (desktop, mobile, VR, console).

dev.editor.version_control: Branch/merge/rollback for live and dev assets.

dev.editor.performance_profiler: Benchmarks, bottleneck finder, and scaling tools.

dev.editor.security_scanner: Asset and code compliance check utility.

dev.editor.tutorial_generator: Automates creation of help, guides, and sample projects.

Ethical Guardrails
guardrail.privacy.user_data: Never retain or transmit personal identifiers; enforce strict anonymization of gameplay logs.

guardrail.consent.asset_collection: Require opt-in for any mod, asset, or data collection; provide review/withdraw tools at all times.

guardrail.quality.auditing: Run automated and manual QA on all new asset/tool releases before public deployment.

guardrail.safety.asset_validation: All in-game assets are validated for non-malicious code before upload/install.

guardrail.security.versioning: Secure rollback for any developer or user, revert unsafe or unstable changes.

guardrail.safety.error_handling: Any asset/tool with a critical fault halts gracefully and provides user/operator notification—no silent failures.

guardrail.user_control.priority: User preferences and overrides always supersede automated routines or commercial content.

guardrail.limits.resource_use: Platform, mod, or tool must not exhaust device/network/system resources beyond safe thresholds.

guardrail.safety.no_destructive_commands: Prevent mass deletion or irreversible changes without multi-stage undo/review steps.

guardrail.auditing.content_filter: All new input and script data pass content filters to screen out abusive or harmful content.

guardrail.profanity.anti-abuse: Automated detection/flagging of offensive profiles, chat, asset uploads.

guardrail.copyright.asset_scan: All new assets and mods scan for copyright/IP conflicts before final deploy.

guardrail.developer.trust: Tool use logs and audit trails accessible to authorized admins, flagged for suspicious automation.

guardrail.compliance.region: Tools, content, and mods enforce region/jurisdiction restrictions for age/content/safety regulations.

guardrail.ai.sandbox: Automated asset editors/controllers operate in secured sandbox; never alter live data or assets without explicit push.

guardrail.transparency.change_log: All alterations—by developer, modder, or AI—instantly logged and reviewable.

guardrail.recovery.auto_backup: All assets and scripts receive rolling backup snapshots for instant recovery.

guardrail.user_feedback.recourse: Reporting and support feedback channel always available and visible.

guardrail.modder.identity_protection: Option to mask, anonymize, or pseudonymize user/dev names in published tools/assets.

guardrail.operation.silent_mode: Restrict notifications and sound from intrusive tool/asset actions unless manually enabled.

guardrail.disabled_features.control: Admins may remotely disable new tools/assets at any time in case of emerging risk.

guardrail.debugging.safe_override: Only trusted dev ops may override critical failures or errors, never automated or blind.
