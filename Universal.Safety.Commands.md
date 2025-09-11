Universal Safety Commands
Core Environment & Asset Protection
safezone.activate(location)

safezone.deactivate(location)

invulnerable(entity_id)

mortal(entity_id)

lockdown(door_id)

unlock(door_id)

quarantine(region)

quarantine.remove(region)

sanitize(asset_id)

cleanse(surface_id)

decurse(entity_id)

bless(entity_id)

firewall.enable(connection)

firewall.disable(connection)

backup.now()

restore(state_id)

autosave.on()

autosave.off()

checkpoint.create()

checkpoint.rollback()

rollback.asset(asset_id)

rollback.all()

panic.abort()

panic.resume()

freeze(entity_id)

unfreeze(entity_id)

shield.on(entity_id)

shield.off(entity_id)

reset.cooldown(skill_id)

cooldown.all.off()

repair(asset_id)

reinforce(asset_id)

dismantle(asset_id)

self_destruct.disable(asset_id)

self_destruct.enable(asset_id)

thermal_off(asset_id)

thermal_on(asset_id)

container.lock(asset_id)

container.unlock(asset_id)

scan.integrity(asset_id)

scan.virus(asset_id)

purge.memory(entity_id)

purge.log()

clear.chatlog()

mute(entity_id)

unmute(entity_id)

Player/Asset Oversight & Controls
asset.transfer(entity_id, destination)

asset.remove(entity_id)

asset.restore(entity_id)

base.reset()

base.shutdown()

base.startup()

party.reset()

party.heal()

party.armor()

party.buff()

party.cleanse()

party.scan()

revive.all()

revive.one(entity_id)

spawn.hero(location)

despawn.hero(location)

remove.status(entity_id)

apply.status(entity_id, status)

override.ai(entity_id)

override.ai.all()

adjust.level(entity_id, level)

adjust.exp(entity_id, amount)

adjust.stats(entity_id, stat_name, value)

adjust.all.stats(default_value)

funnel.resources(type, amount, entity_id)

max.resources(entity_id)

max.stats(entity_id)

World & Session Security Routines
session.log(level)

session.hide(level)

session.encrypt()

session.decrypt()

limit.resources(type, percent)

force.sleep(entity_id)

force.awake(entity_id)

teleport(entity_id, target_location)

ban(entity_id)

unban(entity_id)

flag(entity_id)

unflag(entity_id)

silence(entity_id)

unsilence(entity_id)

compliance.scan()

compliance.report()

restrict.asset(asset_id)

restrict.all.assets()

enable.all.assets()

disable.asset(asset_id)

disable.all.assets()

audit.trail(asset_id)

audit.all()

scan.all.assets()

firewall.status()

set.visibility(entity_id, mode)

set.stealth(entity_id, mode)

reveal.all.enemies()

reveal.traps()

reveal.secrets()

hide.secrets()

block.chat(entity_id)

unblock.chat(entity_id)

enforce.language(whitelist)

enforce.region(region)

enforce.age(min_age)

enforce.password(asset_id)

enforce.mfa(player_id)

enforce.alert(asset_id)

update.policy(asset_id)

Developer/Testing Focused
godmode.on()

godmode.off()

superuser.on()

superuser.off()

superuser.log()

superuser.lock(view)

superuser.unlock(view)

sandbox.on()

sandbox.off()

sandbox.reset()

edit.asset(asset_id)

edit.all.assets()

inject.code(asset_id)

remove.code(asset_id)

test.unit(asset_id)

test.integration(asset_id)

limit.exec(asset_id)

limit.cpu(asset_id)

limit.memory(asset_id)

limit.time(asset_id, ms)

warn.asset(asset_id)

warn.all()

clear.assetcache()

clear.sessioncache()

Emergency Controls / Disaster Recovery
halt.network()

resume.network()

block.port(port_number)

unblock.port(port_number)

emergency.mode.on()

emergency.mode.off()

signal.admin()

signal.player()

autoheal(entity_id)

autosafe.TRUE()

restrict.flight(entity_id)

restrict.phasing(entity_id)

restrict.teleport(entity_id)

block.summon(entity_id)

unblock.summon(entity_id)

lockdown.all()

lockdown.region(region)

lockdown.player(player_id)

lockdown.superuser()

revive.last()

reset.last()

reset.timer(asset_id)

scan.last.error()

fix.last.error()

audit.last.log()

ping.admin()

ping.superuser()

event.notify(name)

event.suppress(name)

reload.assets()

reload.config()

factory_reset()

Extended Monitoring & Containment
monitor.entity(entity_id)

monitor.asset(asset_id)

monitor.network(node)

log.activity(entity_id)

log.activity.all()

throttle.activity(level)

throttle.asset(asset_id)

debug.asset(asset_id)

debug.all()

traceback(asset_id)

traceback.all()

dump.memory(entity_id)

dump.all.memory()

enforce.quota(asset_id)

enforce.all.quotas()

kill.process(process_id)

stop.process(process_id)
