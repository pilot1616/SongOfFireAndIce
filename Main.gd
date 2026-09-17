extends Node2D

const W := 1280.0
const H := 720.0
const GRAVITY := 1500.0
const SPEED := 285.0
const JUMP := -575.0
const ACTOR_HALF := 16.0
const ACTOR_H := 48.0

const LevelData := preload("res://Levels.gd")

var ember := {"pos": Vector2(80, 560), "vel": Vector2.ZERO, "color": Color("#ff8b4a"), "spawn": Vector2(80, 560), "keys": ["ember_left", "ember_right", "ember_jump"]}
var tide := {"pos": Vector2(140, 560), "vel": Vector2.ZERO, "color": Color("#55d8dc"), "spawn": Vector2(140, 560), "keys": ["tide_left", "tide_right", "tide_jump"]}
var font: Font
var pulse := 0.0
var won := false
var elapsed := 0.0
var level_index := 1
var level_count := 30
var target_time := 120.0
var lv := {}
var jump_buffer := ""
var jump_timer := 0.0
var gems_total := 0
var gems_got := 0
var camera_shake := 0.0

func _ready():
    font = ThemeDB.fallback_font
    load_level(1)

func _process(delta):
    pulse += delta
    if not won: elapsed += delta
    jump_timer += delta
    if jump_timer > 2.0: jump_buffer = ""
    if Input.is_action_just_pressed("reset"): reset_level()
    if won and Input.is_action_just_pressed("ember_jump"):
        level_index = level_index % level_count + 1
        load_level(level_index)
    if not won:
        step_actors(delta)
        step_entities(delta)
        if both_at_exit(): won = true
        if elapsed > 600.0: reset_level()
    queue_redraw()

func _input(event: InputEvent):
    # Backdoor: click the < > arrows by the level readout, or use keys.
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if Rect2(733, 30, 30, 26).has_point(event.position):
            level_index = clamp(level_index - 1, 1, level_count)
            load_level(level_index)
        elif Rect2(899, 30, 32, 26).has_point(event.position):
            level_index = clamp(level_index + 1, 1, level_count)
            load_level(level_index)
        return
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    var key: int = event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
    if key == KEY_N:
        level_index = clamp(level_index + 1, 1, level_count)
        load_level(level_index)
    elif key == KEY_P:
        level_index = clamp(level_index - 1, 1, level_count)
        load_level(level_index)
    elif key >= KEY_0 and key <= KEY_9:
        jump_timer = 0.0
        jump_buffer += str(key - KEY_0)
    elif (key == KEY_ENTER or key == KEY_KP_ENTER) and jump_buffer != "":
        level_index = clamp(int(jump_buffer), 1, level_count)
        load_level(level_index)
        jump_buffer = ""

# ---------------------------------------------------------------- level setup

func load_level(n: int):
    lv = LevelData.build(n)
    target_time = 120.0 + (int((n - 1) / 5)) * 20.0
    gems_total = 0
    gems_got = 0
    for e in lv.ents:
        if e.t == "gem": gems_total += 1
    reset_level()

func reset_level():
    ember.pos = ember.spawn; ember.vel = Vector2.ZERO
    tide.pos = tide.spawn; tide.vel = Vector2.ZERO
    won = false; elapsed = 0.0
    for e in lv.ents:
        match e.t:
            "gem":
                e.got = false
            "plate":
                e.pressed = false
            "lever", "esw":
                e.on = false; e.cd = 0.0
            "block":
                e.vy = 0.0
                if e.has("erased"): e.erased = false
            "ice":
                e.melt = 0.0; e.vy = 0.0
                if e.has("erased"): e.erased = false
            "mirror":
                e.cd = 0.0
            "portal":
                e.cdE = 0.0; e.cdT = 0.0
            "swap":
                e.used = false; e.cd = 0.0
            "check":
                e.used = false
            "pools_ok":
                pass

func both_at_exit() -> bool:
    var ex: Array = lv.get("exits", [])
    if ex.is_empty():
        return ember.pos.x > 1100 and tide.pos.x > 1100
    var ok := 0
    for e in ex:
        var who: Dictionary = ember if e[1] == "r" else tide
        if abs(who.pos.x - e[0]) < 42: ok += 1
    return ok == ex.size()

# ---------------------------------------------------------------- physics

func solid_rects() -> Array:
    var out: Array = []
    for f in lv.floors: out.append(f)
    for p in lv.plats: out.append(p.r)
    for pl in lv.pools:
        if pl.kind == "water" and pl.frozen_t > 0.0: out.append(Rect2(pl.r.position, Vector2(pl.r.size.x, 10)))
    for e in lv.ents:
        match e.t:
            "wall":
                out.append(e.r)
            "door":
                if not e.open: out.append(e.r)
            "timdoor":
                if not e.open: out.append(e.r)
            "block":
                if not e.erased: out.append(e.r)
            "ice":
                if not e.erased and e.melt < 0.85: out.append(e.r)
    return out

func platforms_for_actor(a: Dictionary) -> Array:
    # one-way platforms: level plats + movers. Floors/walls/blocks handled as solids.
    var out: Array = []
    for p in lv.plats: out.append(p.r)
    for e in lv.ents:
        if e.t == "mover": out.append(e.r)
        if e.t == "elev": out.append(e.r)
        if e.t == "plat": out.append(e.r)
    return out

func move_actor(a: Dictionary, delta: float):
    var dir := Input.get_axis(a.keys[0], a.keys[1])
    var previous_y: float = a.pos.y
    var on_ice := false
    var feet := Rect2(a.pos.x - ACTOR_HALF, a.pos.y + ACTOR_H, ACTOR_HALF * 2, 4)
    for r in solid_rects():
        if r.has_point(feet.position + Vector2(2, 2)):
            on_ice = true
    var accel: float = 900.0 if on_ice else 1800.0
    var fric: float = 120.0 if on_ice else 1800.0
    if dir != 0.0:
        a.vel.x = move_toward(a.vel.x, dir * SPEED, accel * delta)
    else:
        a.vel.x = move_toward(a.vel.x, 0.0, fric * delta)
    if Input.is_action_just_pressed(a.keys[2]) and a.vel.y == 0: a.vel.y = JUMP
    a.vel.y += GRAVITY * delta
    a.pos += a.vel * delta
    # solid collision (walls, blocks, ice blocks) — floors are landing-only
    var body := Rect2(a.pos.x - ACTOR_HALF, a.pos.y - ACTOR_H, ACTOR_HALF * 2, ACTOR_H * 2)
    var plat_rects: Array = lv.plats.map(func(p): return p.r)
    for r in solid_rects():
        if r in plat_rects: continue
        if r.size.y >= 100.0 and r.position.y >= 604.0: continue  # floor strips: landing-only
        if r.size.y <= 15.0 and r.position.y > 600.0: continue  # frozen water sheet handled as platform
        if not body.intersects(r): continue
        if a.vel.y > 0 and previous_y + ACTOR_H <= r.position.y + 6:
            continue
        if r.position.y >= a.pos.y + ACTOR_H: continue
        # push out horizontally
        if a.pos.x < r.position.x + r.size.x / 2:
            a.pos.x = r.position.x - ACTOR_HALF - 1
        else:
            a.pos.x = r.end.x + ACTOR_HALF + 1
        a.vel.x = 0
        body = Rect2(a.pos.x - ACTOR_HALF, a.pos.y - ACTOR_H, ACTOR_HALF * 2, ACTOR_H * 2)
    # one-way platform landing
    var landed := false
    if a.vel.y >= 0:
        for r in platforms_for_actor(a):
            var was_above: bool = previous_y + ACTOR_H <= r.position.y + 4
            var crossed: bool = a.pos.y + ACTOR_H >= r.position.y
            if was_above and crossed and a.pos.x >= r.position.x - 14 and a.pos.x <= r.end.x + 14:
                a.pos.y = r.position.y - ACTOR_H
                a.vel.y = 0
                landed = true
    # solid ground landing (floors, blocks, walls tops, ice blocks)
    if a.vel.y >= 0:
        for r in solid_rects():
            var was_above: bool = previous_y + ACTOR_H <= r.position.y + 8
            var crossed: bool = a.pos.y + ACTOR_H >= r.position.y and a.pos.y + ACTOR_H <= r.position.y + 60
            if was_above and crossed and a.pos.x >= r.position.x - 14 and a.pos.x <= r.end.x + 14:
                a.pos.y = r.position.y - ACTOR_H
                a.vel.y = 0
                landed = true
    if not landed and a.pos.y > 700.0:
        respawn(a)
        return
    a.pos.x = clamp(a.pos.x, 24.0, W - 24.0)

func respawn(a: Dictionary):
    var cp: Vector2 = a.spawn
    for e in lv.ents:
        if e.t == "check" and e.used:
            cp = e.pos + Vector2(0, -20)
    a.pos = cp
    a.vel = Vector2.ZERO

func hazard_hit(a: Dictionary) -> String:
    var feet_y: float = a.pos.y + ACTOR_H
    if feet_y < 598.0: return ""
    for pl in lv.pools:
        if pl.kind == "water" and pl.frozen_t > 0.0: continue
        if a.pos.x > pl.r.position.x - 6 and a.pos.x < pl.r.end.x + 6 and feet_y > pl.r.position.y - 4:
            if pl.kind == "fire": return "tide" if a == tide else ""
            if pl.kind == "water": return "ember" if a == ember else ""
            if pl.kind == "poison": return "both"
    return ""

func step_actors(delta: float):
    for a in [ember, tide]:
        move_actor(a, delta)
        var hz := hazard_hit(a)
        if hz == "both" or hz == ("tide" if a == tide else "ember"):
            respawn(a)
        # block pushing
        for e in lv.ents:
            if e.t != "block" or e.erased: continue
            var body := Rect2(a.pos.x - ACTOR_HALF, a.pos.y - ACTOR_H + 4, ACTOR_HALF * 2, ACTOR_H * 2 - 8)
            if not body.intersects(e.r): continue
            var dirx := 0.0
            if Input.is_action_pressed(a.keys[0]): dirx = -1.0
            elif Input.is_action_pressed(a.keys[1]): dirx = 1.0
            if dirx == 0.0: continue
            var moving_into: bool = (dirx > 0 and a.pos.x < e.r.position.x) or (dirx < 0 and a.pos.x > e.r.end.x)
            if not moving_into: continue
            var newx: float = e.r.position.x + dirx * 60.0 * delta
            var trial := Rect2(newx, e.r.position.y, e.r.size.x, e.r.size.y)
            var blocked := false
            for r in solid_rects():
                if r == e.r: continue
                if trial.intersects(r): blocked = true
            for other in lv.ents:
                if other != e and other.t == "block" and not other.erased and trial.intersects(other.r): blocked = true
            for pl in lv.pools:
                if trial.position.y + trial.size.y > pl.r.position.y and trial.position.x < pl.r.end.x and trial.end.x > pl.r.position.x:
                    e.erased = true
                    camera_shake = 0.3
                    blocked = true
            if not blocked:
                if trial.position.x < 0 or trial.end.x > W: blocked = true
            if blocked:
                e.r.position.x = clamp(newx, 0.0, W - e.r.size.x)
            # actor pushed back by block edge
            if dirx > 0:
                a.pos.x = min(a.pos.x, e.r.position.x - ACTOR_HALF)
            else:
                a.pos.x = max(a.pos.x, e.r.end.x + ACTOR_HALF)
        # gravity settle for blocks handled in step_entities

func step_entities(delta: float):
    # blocks fall
    for e in lv.ents:
        if e.t == "block" and not e.erased:
            var bottom: float = e.r.end.y
            var grounded := bottom >= 602.0
            for r in solid_rects():
                if r == e.r: continue
                if abs(r.position.y - bottom) < 4 and e.r.position.x < r.end.x and e.r.end.x > r.position.x:
                    grounded = true
            for pl in lv.pools:
                if e.r.position.y + e.r.size.y > pl.r.position.y + 4 and e.r.position.x < pl.r.end.x and e.r.end.x > pl.r.position.x and not e.erased:
                    e.erased = true
                    camera_shake = 0.3
                    grounded = true
            if e.r.end.x > W: e.r.position.x = W - e.r.size.x
            if not grounded:
                e.vy += GRAVITY * delta
                e.r.position.y += e.vy * delta
            else:
                e.vy = 0.0
                e.r.position.y = min(e.r.position.y, 602.0 - e.r.size.y)
        # ice blocks: melt when hot beam hits (segment inside block, or beam tip resting on its surface)
        if e.t == "ice" and not e.erased:
            var hot := false
            for b in lv.ents:
                if b.t == "beam" and b.kind_now == "hot" and beam_on(b):
                    var path: Array = b.path
                    var i := 0
                    while i + 1 < path.size():
                        var sr := Rect2(path[i], path[i + 1] - path[i]).grow(2.0)
                        if sr.intersects(e.r): hot = true
                        i += 2
            if hot:
                e.melt += delta * 0.25
                if e.melt >= 1.0: e.erased = true
        # pools: freeze / thaw under beams
        for pl in lv.pools:
            if pl.kind != "water": continue
            var cold := false
            for b in lv.ents:
                if b.t == "beam" and b.kind_now == "cold" and beam_on(b):
                    var path2: Array = b.path
                    var j := 0
                    while j + 1 < path2.size():
                        var segv: Vector2 = path2[j + 1] - path2[j]
                        if segv.length() > 1:
                            var pool_mid: Vector2 = Vector2(pl.r.position.x + pl.r.size.x / 2, 604.0)
                            var t2: float = clamp((pool_mid - path2[j]).dot(segv) / segv.length_squared(), 0.0, 1.0)
                            var d2: float = (path2[j] + segv * t2 - pool_mid).length()
                            if d2 < pl.r.size.x / 2 + 16.0: cold = true
                        j += 2
            if cold:
                pl.frozen_t = min(1.0, pl.frozen_t + delta * 0.7)
            else:
                pl.frozen_t = max(0.0, pl.frozen_t - delta * 0.35)
        # plates
        if e.t == "plate":
            var pressed := false
            var pr: Rect2 = e.r
            var zone := Rect2(pr.position - Vector2(6, 14), pr.size + Vector2(12, 18))
            for a in [ember, tide]:
                var body := Rect2(a.pos.x - ACTOR_HALF, a.pos.y + ACTOR_H - 6, ACTOR_HALF * 2, 10)
                if zone.intersects(body):
                    if e.k == "f":
                        e.pressed = true; e["latched"] = true; pressed = true
                    elif e.k == "n":
                        pressed = true
                    elif e.k == "r" and a == ember: pressed = true
                    elif e.k == "b" and a == tide: pressed = true
            for blk in lv.ents:
                if blk.t == "block" and not blk.erased:
                    var bb := Rect2(blk.r.position.x, blk.r.end.y - 10, blk.r.size.x, 10)
                    if zone.intersects(bb): pressed = true
            if e.k == "f" and e.get("latched", false):
                e.pressed = true
            else:
                e.pressed = pressed
        # levers
        if e.t == "lever":
            e.cd = max(0.0, e.cd - delta)
            if e.cd == 0.0:
                for a in [ember, tide]:
                    if abs(a.pos.x - e.pos.x) < 26 and abs(a.pos.y - e.pos.y) < 40:
                        e.on = not e.on
                        e.cd = 0.8
        if e.t == "esw":
            e.cd = max(0.0, e.cd - delta)
            if e.cd == 0.0:
                for a in [ember, tide]:
                    if abs(a.pos.x - e.pos.x) < 26 and abs(a.pos.y - e.pos.y) < 40:
                        e.on = not e.on
                        e.cd = 0.8
        # movers
        if e.t == "mover":
            var span: float = e.x2 - e.x1
            var t := fmod(pulse * e.sp / max(span, 1.0) + e.ph, 2.0)
            if t > 1.0: t = 2.0 - t
            var newx: float = e.x1 + span * t
            e.dx = newx - e.r.position.x
            e.r.position.x = newx
            for a in [ember, tide]:
                if abs(a.vel.y) < 5 and abs(a.pos.y + ACTOR_H - e.r.position.y) < 4 and a.pos.x > e.r.position.x - 14 and a.pos.x < e.r.end.x + 14:
                    a.pos.x += e.dx
        # elevators
        if e.t == "elev":
            var want := false
            for sid in e.srcs:
                for s in lv.ents:
                    if s.t == "plate" and s.id == sid and s.pressed: want = true
                    if s.t == "lever" and s.id == sid and s.on: want = true
                    if s.t == "chain" and s.id == sid and s.active: want = true
                    if s.t == "timer" and s.id == sid and s.active: want = true
            var target_y: float = e.y1 if want else e.y2
            var diry: float = sign(target_y - e.r.position.y)
            if absf(target_y - e.r.position.y) > 2.0:
                e.dy = diry * 70.0 * delta
                e.r.position.y += e.dy
            else:
                e.dy = 0.0
                e.r.position.y = target_y
            for a in [ember, tide]:
                if abs(a.vel.y) < 5 and abs(a.pos.y + ACTOR_H - e.r.position.y) < 6 and a.pos.x > e.r.position.x - 14 and a.pos.x < e.r.end.x + 14:
                    a.pos.y += e.dy
        # timers
        if e.t == "timer":
            var ph := fmod(pulse + e.phase, e.period)
            e.active = ph < e.period * e.duty
        # timed doors
        if e.t == "timdoor":
            var ph2 := fmod(pulse + e.phase, e.period)
            e.open = ph2 >= e.period * e.duty
        # beams
        if e.t == "beam":
            compute_beam(e)
        # mirrors
        if e.t == "mirror":
            e.cd = max(0.0, e.cd - delta)
            if e.cd == 0.0:
                for a in [ember, tide]:
                    if abs(a.pos.x - e.pos.x) < 24 and abs(a.pos.y - e.pos.y) < 44:
                        e.slash = not e.slash
                        e.cd = 0.8
        # receivers
        if e.t == "recv":
            var lit := false
            for b in lv.ents:
                if b.t == "beam" and b.kind_now != "hot" and b.kind_now != "cold" and beam_on(b):
                    var path: Array = b.path
                    var i := 0
                    while i + 1 < path.size():
                        var segv: Vector2 = path[i + 1] - path[i]
                        if segv.length() > 1:
                            var t: float = clamp((Vector2(e.pos) - path[i]).dot(segv) / segv.length_squared(), 0.0, 1.0)
                            var d: float = (path[i] + segv * t - Vector2(e.pos)).length()
                            if d < 18: lit = true
                        i += 2
            e.active = lit
        # chains
        if e.t == "chain":
            var all := true
            for rid in e.ids:
                var found := false
                for s in lv.ents:
                    if (s.t == "recv" or s.t == "plate" or s.t == "chain") and s.id == rid and s.get("pressed", s.get("active", false)):
                        found = true
                if not found: all = false
            e.active = all
        # doors
        if e.t == "door":
            var open := false
            for lid in e.links:
                for s in lv.ents:
                    if s.t == "plate" and s.id == lid and s.pressed: open = true
                    if s.t == "lever" and s.id == lid and s.on: open = true
                    if s.t == "recv" and s.id == lid and s.active: open = true
                    if s.t == "chain" and s.id == lid and s.active: open = true
            e.open = open
        if e.t == "timdoor":
            pass
        # portals
        if e.t == "portal":
            e.cdE = max(0.0, e.cdE - delta)
            e.cdT = max(0.0, e.cdT - delta)
            for pair in [[e.a, e.b], [e.b, e.a]]:
                var from: Vector2 = pair[0]
                var to: Vector2 = pair[1]
                if e.mode == "a2b" and pair[0] == e.b: continue
                for a in [ember, tide]:
                    var cd: float = e.cdE if a == ember else e.cdT
                    if cd > 0.0: continue
                    if Vector2(a.pos).distance_to(from) < 26:
                        a.pos = to + (a.pos - from).normalized() * 20.0 if from.distance_to(to) > 1 else to
                        a.pos = to
                        if a == ember: e.cdE = 1.0
                        else: e.cdT = 1.0
        # swap portal
        if e.t == "swap":
            e.cd = max(0.0, e.cd - delta)
            if e.cd == 0.0 and not e.used:
                var gate := false
                for s in lv.ents:
                    if s.t == "plate" and s.id == e.src and s.pressed: gate = true
                    if s.t == "lever" and s.id == e.src and s.on: gate = true
                if gate:
                    var tmp: Vector2 = ember.pos
                    ember.pos = tide.pos
                    tide.pos = tmp
                    e.used = true
                    e.cd = 3.0
                    camera_shake = 0.25
        # gems
        if e.t == "gem" and not e.got:
            for a in [ember, tide]:
                if Vector2(a.pos).distance_to(Vector2(e.pos)) < 30:
                    e.got = true
                    gems_got += 1
        # checkpoints
        if e.t == "check" and not e.used:
            for a in [ember, tide]:
                if abs(a.pos.x - e.pos.x) < 30 and abs(a.pos.y - e.pos.y) < 60:
                    e.used = true
        # draw bridges / moving bridges
        if e.t == "bmov":
            var on := false
            for sid in [e.src]:
                for s in lv.ents:
                    if s.t == "plate" and s.id == sid and s.pressed: on = true
                    if s.t == "lever" and s.id == sid and s.on: on = true
                    if s.t == "recv" and s.id == sid and s.active: on = true
            e["on"] = on
        if e.t == "bflip":
            var on: bool = false
            for s in lv.ents:
                if s.t == "lever" and s.id == e.lever and s.on: on = true
            e["on"] = on
            # carry actors standing on the active bridge toward its target side
            var target: Rect2 = e.a if on else e.b
            var other: Rect2 = e.b if on else e.a
            for a in [ember, tide]:
                if abs(a.vel.y) < 5 and abs(a.pos.y + ACTOR_H - target.position.y) < 4 and a.pos.x > target.position.x - 14 and a.pos.x < target.end.x + 14:
                    pass
        # dark zones
        if e.t == "dark":
            var lit := false
            if e.lever != "":
                for s in lv.ents:
                    if s.t == "plate" and s.id == e.lever and s.pressed: lit = true
                    if s.t == "lever" and s.id == e.lever and s.on: lit = true
                    if s.t == "chain" and s.id == e.lever and s.active: lit = true
            e.lit = lit
    # actors standing on bmov/bflip bridges fall if bridge off
    for e in lv.ents:
        if e.t == "bmov" and not e.get("on", false):
            for a in [ember, tide]:
                if abs(a.vel.y) < 5 and abs(a.pos.y + ACTOR_H - e.r.position.y) < 4 and a.pos.x > e.r.position.x - 14 and a.pos.x < e.r.end.x + 14:
                    a.vel.y = 1.0
        if e.t == "bflip":
            var active: Rect2 = e.a if e.get("on", false) else e.b
            var inactive: Rect2 = e.b if e.get("on", false) else e.a
            for a in [ember, tide]:
                if abs(a.vel.y) < 5 and abs(a.pos.y + ACTOR_H - inactive.position.y) < 4 and a.pos.x > inactive.position.x - 14 and a.pos.x < inactive.end.x + 14:
                    a.vel.y = 1.0

func beam_on(b: Dictionary) -> bool:
    if not b.sw: return true
    for sid in b.srcs:
        for s in lv.ents:
            if s.t == "plate" and s.id == sid and s.pressed: return true
            if s.t == "lever" and s.id == sid and s.on: return true
            if s.t == "recv" and s.id == sid and s.active: return true
            if s.t == "esw" and s.id == sid: return true
    return false

func compute_beam(b: Dictionary):
    b.kind_now = b.kind
    if b.sw:
        for s in lv.ents:
            if s.t == "esw":
                b.kind_now = "hot" if s.on else "cold"
    var dirv: Vector2
    match b.dir:
        "E": dirv = Vector2.RIGHT
        "W": dirv = Vector2.LEFT
        "S": dirv = Vector2.DOWN
        _: dirv = Vector2.RIGHT
    var path: Array = [b.pos]
    var cur: Vector2 = b.pos
    var curdir: Vector2 = dirv
    for bounce in range(6):
        var endpt: Vector2 = cur + curdir * 1400.0
        var best_t := 1400.0
        var hit_mirror: Dictionary = {}
        for r in solid_rects():
            if r.has_point(cur): continue  # emitter buried in geometry: ignore containing rects
            var t := ray_hit_t(cur, curdir, r)
            if t >= 0.0 and t < best_t:
                best_t = t
                hit_mirror = {}
        for m in lv.ents:
            if m.t != "mirror": continue
            var t2 := ray_hit_t(cur, curdir, Rect2(m.pos - Vector2(14, 14), Vector2(28, 28)))
            if t2 >= 0.0 and t2 < best_t:
                best_t = t2
                hit_mirror = m
        endpt = cur + curdir * best_t
        path.append(endpt)
        if hit_mirror.is_empty(): break
        # reflect: slash "/" maps R<->U, L<->D; backslash maps R<->D, L<->U
        var incoming: Vector2 = curdir
        var out: Vector2
        if hit_mirror.slash:
            out = Vector2(-incoming.y, -incoming.x)
        else:
            out = Vector2(incoming.y, incoming.x)
        curdir = out
        cur = endpt + out * 2.0
    b.path = path

func ray_hit_t(o: Vector2, d: Vector2, r: Rect2) -> float:
    var tmin := -1e9
    var tmax := 1e9
    for axis in range(2):
        var oo: float = o.x if axis == 0 else o.y
        var dd: float = d.x if axis == 0 else d.y
        var lo: float = r.position.x if axis == 0 else r.position.y
        var hi: float = r.end.x if axis == 0 else r.end.y
        if absf(dd) < 0.0001:
            if oo < lo or oo > hi: return -1.0
        else:
            var t1 := (lo - oo) / dd
            var t2 := (hi - oo) / dd
            if t1 > t2:
                var tmp := t1
                t1 = t2
                t2 = tmp
            tmin = max(tmin, t1)
            tmax = min(tmax, t2)
    if tmax < tmin or tmax < 0.0: return -1.0
    return max(tmin, 0.0)

# ================================================================ drawing

func _draw():
    draw_rect(Rect2(0, 0, W, H), Color("#07131f"))
    draw_scene_background()
    draw_line(Vector2(0, 604), Vector2(W, 604), Color("#3d8a77"), 2)
    for f in lv.floors:
        draw_rect(Rect2(f.position.x, 604, f.size.x, H - 604), Color("#102d32"))
    draw_ruins()
    for p in lv.pools:
        draw_pool(p)
    for e in lv.ents:
        draw_entity(e)
    for p in lv.plats:
        draw_platform(p.r)
    draw_gate()
    if lv.get("exits", []).is_empty():
        draw_string(font, Vector2(1087, 310), "MOON GATE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f7e4ac"))
    actor(ember, "EMBER")
    actor(tide, "TIDE")
    draw_foreground()
    draw_darkness()
    draw_hud()
    if won:
        draw_rect(Rect2(330, 250, 620, 150), Color("#102b31", 0.98), true)
        draw_string(font, Vector2(490, 312), "GATE AWAKENED", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#f8e3aa"))
        draw_string(font, Vector2(450, 348), "%s   gems %d / %d" % [lv.name, gems_got, gems_total], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#91d8c1"))
        draw_string(font, Vector2(540, 380), "Press W to next level", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#a9bbb2"))

func draw_darkness():
    for e in lv.ents:
        if e.t != "dark" or e.lit: continue
        var r: Rect2 = e.r
        for a in [ember, tide]:
            var radius: float = 150.0 if a == ember else 90.0
            var steps := 12
            for i in range(steps):
                var ri: float = radius * (1.0 - float(i) / steps)
                var alpha: float = 0.085 if i == 0 else 0.085 / steps * 3.0
                draw_circle(a.pos, ri, Color("#020608", alpha))
        draw_rect(r, Color("#010407", 0.55), false, 0.0)
        # fill rest dimmer
        for i in range(6):
            draw_rect(r.grow(6.0 * i), Color("#010407", 0.05), false, 0.0)

func draw_pool(p: Dictionary):
    var r: Rect2 = p.r
    if p.kind == "fire":
        draw_fire_pool(Rect2(r.position.x, 604.0, r.size.x, 116.0))
    elif p.kind == "water":
        if p.frozen_t > 0.0:
            draw_rect(Rect2(r.position.x, 604.0, r.size.x, 12.0), Color("#cfeefc", 0.95))
            draw_rect(Rect2(r.position.x, 604.0, r.size.x, 12.0), Color("#eaf7ff", 0.6), false, 2.0)
        else:
            draw_water_pool(Rect2(r.position.x, 604.0, r.size.x, 116.0))
    else:
        draw_poison_pool(Rect2(r.position.x, 604.0, r.size.x, 116.0))

func draw_poison_pool(r: Rect2):
    draw_rect(r, Color("#1d3a12", 0.9))
    draw_rect(Rect2(r.position + Vector2(0, 16), Vector2(r.size.x, r.size.y - 16)), Color("#254d17", 0.7))
    var surf := PackedVector2Array()
    for i in range(13):
        var lx := r.position.x + r.size.x * float(i) / 12.0
        var ly := r.position.y + sin(pulse * 2.2 + float(i) * 0.9) * 2.0
        surf.append(Vector2(lx, ly))
    for i in range(surf.size() - 1):
        draw_line(surf[i], surf[i + 1], Color("#7dc242", 0.95), 2.5)
    for i in range(4):
        var bx := r.position.x + fmod(float(i * 37) + pulse * 6.0, r.size.x)
        var by := r.position.y + 30.0 - fmod(pulse * (8.0 + float(i) * 3.0) + float(i) * 17.0, 28.0)
        draw_circle(Vector2(bx, by), 2.0 + fmod(float(i), 2.0), Color("#9fdc62", 0.6))

func draw_platform(r: Rect2):
    draw_colored_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end + Vector2(-6, 10), Vector2(r.position.x + 6, r.end.y + 10)]), Color("#203f43"))
    draw_rect(r, Color("#315b58"), true)
    draw_line(r.position, Vector2(r.end.x, r.position.y), Color("#80bda1"), 2)
    for x in range(int(r.position.x) + 14, int(r.end.x), 40):
        draw_line(Vector2(x, r.position.y + 4), Vector2(x - 6, r.end.y - 2), Color("#254b4b"), 2)
        draw_circle(Vector2(x + 6, r.position.y - 1), 2.5, Color("#83a84e"))

func draw_scene_background():
    for radius in range(110, 35, -12):
        draw_circle(Vector2(1080, 110), radius, Color("#f5dc9a", 0.008 + (110 - radius) * 0.0008))
    draw_circle(Vector2(1080, 110), 42, Color("#f8e3aa"))
    for i in range(26):
        var sx := float((i * 173 + 47) % 1260)
        var sy := float((i * 67 + 31) % 270)
        draw_circle(Vector2(sx, sy), 1.0 + float(i % 3) * .35, Color("#d7efdc", .35 + .15 * sin(pulse + i)))
    for i in range(10):
        var x := float(i * 155 - 80)
        draw_colored_polygon(PackedVector2Array([Vector2(x, 390), Vector2(x + 95, 155 + (i % 3) * 35), Vector2(x + 210, 390)]), Color("#0e2733"))
    for i in range(8):
        draw_tree(Vector2(i * 190.0 - 35, 420 + (i % 2) * 25), .7 + (i % 3) * .12, Color("#112f35"))
    draw_circle(Vector2(310 + sin(pulse * .2) * 45, 390), 170, Color("#8bb9a8", .035))
    draw_circle(Vector2(850 + cos(pulse * .16) * 55, 430), 210, Color("#acd0bb", .025))

func draw_tree(base: Vector2, scale_factor: float, tint: Color):
    draw_colored_polygon(PackedVector2Array([base + Vector2(-18, 0) * scale_factor, base + Vector2(-9, -180) * scale_factor, base + Vector2(13, -185) * scale_factor, base + Vector2(22, 0) * scale_factor]), tint.darkened(.2))
    for offset in [Vector2(-32, -165), Vector2(23, -190), Vector2(-8, -225)]:
        draw_circle(base + offset * scale_factor, 55 * scale_factor, tint)
        draw_circle(base + (offset + Vector2(-18, -8)) * scale_factor, 30 * scale_factor, tint.lightened(.08))

func draw_ruins():
    for base_x in [34.0, 350.0, 1215.0]:
        draw_rect(Rect2(base_x, 350, 28, 254), Color("#263f42"))
        draw_rect(Rect2(base_x - 8, 340, 44, 14), Color("#3e5d57"))
    draw_arc(Vector2(370, 390), 55, PI, TAU, 18, Color("#35524e"), 12)

func draw_gate():
    for offset in [0.0, 90.0]:
        draw_rect(Rect2(1075 + offset, 330, 11, 274), Color("#bda876", 0.6))
    draw_arc(Vector2(1125, 330), 45, PI, TAU, 28, Color("#d8c48a", 0.7), 10)
    draw_circle(Vector2(1125, 390), 27 + sin(pulse * 2.0) * 3, Color("#a9f0d0", .08))
    for i in range(5):
        var angle := pulse * .25 + TAU * i / 5.0
        draw_circle(Vector2(1125, 390) + Vector2(cos(angle), sin(angle)) * 22, 2.5, Color("#e9db9d"))

func draw_foreground():
    for i in range(24):
        var x := float(i * 57 + 9)
        var height := 12.0 + float((i * 13) % 25)
        draw_line(Vector2(x, H), Vector2(x + sin(i) * 8, H - height), Color("#091e25", .9), 5)
    draw_rect(Rect2(0, H - 8, W, 8), Color("#07151c"))

func draw_entity(e: Dictionary):
    match e.t:
        "wall":
            draw_rect(e.r, Color("#3a2f45"))
            draw_rect(e.r, Color("#5a4a6a"), false, 2.0)
            for y in range(int(e.r.position.y) + 10, int(e.r.end.y), 26):
                draw_line(Vector2(e.r.position.x + 3, y), Vector2(e.r.end.x - 3, y + 4), Color("#2a2233"), 2)
        "door":
            var r: Rect2 = e.r
            var col := Color("#8a8f98")
            if e.links.size() == 1:
                for s in lv.ents:
                    if s.t == "plate" and s.id == e.links[0]:
                        if s.k == "r": col = Color("#b04a3a")
                        elif s.k == "b": col = Color("#3a7ab0")
            var slide: float = r.size.y * 0.85 if e.open else 0.0
            var rr := Rect2(r.position + Vector2(0, -slide), r.size)
            draw_rect(Rect2(r.position.x - 4, r.position.y - 6, r.size.x + 8, 8), Color("#555f6a"))
            draw_rect(rr, Color(col, 0.95))
            for y in range(int(rr.position.y) + 6, int(rr.end.y), 14):
                draw_line(Vector2(rr.position.x + 2, y), Vector2(rr.end.x - 2, y), Color("#22262c", 0.7), 2)
            if e.open:
                draw_string(font, Vector2(r.position.x - 6, r.position.y - 12), "OPEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#9fdc8f", 0.8))
        "timdoor":
            var r: Rect2 = e.r
            var slide2: float = r.size.y * 0.85 if e.open else 0.0
            var rr2 := Rect2(r.position + Vector2(0, -slide2), r.size)
            draw_rect(Rect2(r.position.x - 4, r.position.y - 6, r.size.x + 8, 8), Color("#555f6a"))
            draw_rect(rr2, Color("#7a5a9a", 0.95))
            for y in range(int(rr2.position.y) + 6, int(rr2.end.y), 14):
                draw_line(Vector2(rr2.position.x + 2, y), Vector2(rr2.end.x - 2, y), Color("#2a2035", 0.7), 2)
            var ph := fmod(pulse + e.phase, e.period)
            var frac: float = ph / (e.period * e.duty)
            var countdown: float = 1.0 - clamp(frac, 0.0, 1.0) if ph < e.period * e.duty else 0.0
            draw_rect(Rect2(r.position.x - 4, r.position.y - 16, (r.size.x + 8) * (1.0 - countdown), 5), Color("#c77fd6", 0.9))
        "plate":
            var r: Rect2 = e.r
            var col: Color = Color("#9aa2ac")
            if e.k == "r": col = Color("#d05a45")
            elif e.k == "b": col = Color("#4a9ad0")
            elif e.k == "f": col = Color("#c8b26a")
            var sink := 3.0 if e.pressed else 0.0
            draw_rect(Rect2(r.position + Vector2(-4, 4), Vector2(r.size.x + 8, 4)), Color("#3c4650"))
            draw_rect(Rect2(r.position + Vector2(0, sink), Vector2(r.size.x, r.size.y - sink)), col)
            if e.k == "f" and e.pressed:
                draw_string(font, r.position + Vector2(-8, -6), "LOCKED", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#c8b26a"))
        "lever":
            var ang := -0.6 if e.on else 0.6
            draw_rect(Rect2(e.pos - Vector2(10, 4), Vector2(20, 8)), Color("#3c4650"))
            draw_line(e.pos + Vector2(0, -4), e.pos + Vector2(sin(ang) * 22, -4 - cos(ang) * 22), Color("#c8ccd4"), 5, true)
            draw_circle(e.pos + Vector2(sin(ang) * 22, -4 - cos(ang) * 22), 5, Color("#d05a45") if e.on else Color("#4a9ad0"))
        "esw":
            var ang2 := -0.6 if e.on else 0.6
            draw_rect(Rect2(e.pos - Vector2(10, 4), Vector2(20, 8)), Color("#3c4650"))
            draw_line(e.pos + Vector2(0, -4), e.pos + Vector2(sin(ang2) * 22, -4 - cos(ang2) * 22), Color("#c8ccd4"), 5, true)
            draw_circle(e.pos + Vector2(sin(ang2) * 22, -4 - cos(ang2) * 22), 5, Color("#d05a45") if e.on else Color("#4a9ad0"))
            draw_string(font, e.pos + Vector2(-14, 20), "HOT/COLD", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#9ab2b0", 0.8))
        "block":
            if not e.erased:
                draw_rect(e.r, Color("#6a6f78"))
                draw_rect(e.r, Color("#8a9098"), false, 2.0)
                draw_line(e.r.position + Vector2(8, 8), e.r.position + Vector2(20, 30), Color("#4a4f58"), 2)
                draw_line(e.r.position + Vector2(30, 12), e.r.position + Vector2(38, 24), Color("#4a4f58"), 2)
        "ice":
            if not e.erased:
                var a3: float = 1.0 - e.melt * 0.6
                draw_rect(e.r, Color("#cfeefc", a3 * 0.92))
                draw_rect(e.r, Color("#eaf7ff", a3 * 0.8), false, 2.0)
                draw_line(e.r.position + Vector2(6, e.r.size.y - 6), e.r.position + Vector2(e.r.size.x - 6, 8), Color("#ffffff", a3 * 0.5), 2)
                if e.melt > 0.0:
                    draw_rect(Rect2(e.r.position.x, e.r.position.y + e.r.size.y * e.melt, e.r.size.x, e.r.size.y * (1.0 - e.melt)), Color("#9fd8ef", 0.0), false, 0.0)
                    draw_line(Vector2(e.r.position.x, e.r.position.y + e.r.size.y * e.melt), Vector2(e.r.end.x, e.r.position.y + e.r.size.y * e.melt), Color("#7ac8e8", 0.9), 2)
        "mover":
            draw_platform(e.r)
            draw_line(Vector2(e.x1, e.r.end.y + 6), Vector2(e.x2, e.r.end.y + 6), Color("#4a6a68", 0.5), 2)
        "elev":
            draw_platform(e.r)
            draw_line(Vector2(e.r.position.x + e.r.size.x / 2, e.y1), Vector2(e.r.position.x + e.r.size.x / 2, e.y2), Color("#4a6a68", 0.5), 2)
        "beam":
            if beam_on(e):
                var col: Color = Color("#ff5a4a", 0.85)
                if e.kind_now == "cold": col = Color("#5ac8ff", 0.85)
                elif e.kind_now == "sig": col = Color("#ffe9a8", 0.85)
                var i2 := 0
                while i2 + 1 < e.path.size():
                    var a4: Vector2 = e.path[i2]
                    var b4: Vector2 = e.path[i2 + 1]
                    draw_line(a4, b4, Color(col, 0.35), 7)
                    draw_line(a4, b4, col, 3)
                    draw_line(a4, b4, Color("#ffffff", 0.6), 1)
                    i2 += 2
                var tip: Vector2 = e.path[e.path.size() - 1]
                draw_circle(tip, 5 + sin(pulse * 8.0) * 2, Color(col, 0.7))
            else:
                draw_circle(e.pos, 4, Color("#777", 0.6))
            draw_rect(Rect2(e.pos - Vector2(8, 8), Vector2(16, 16)), Color("#3c4650"))
        "mirror":
            var ang3 := PI / 4 if e.slash else -PI / 4
            draw_circle(e.pos, 4, Color("#3c4650"))
            var tip1: Vector2 = e.pos + Vector2(cos(ang3), sin(ang3)) * 20
            var tip2: Vector2 = e.pos - Vector2(cos(ang3), sin(ang3)) * 20
            draw_line(tip1, tip2, Color("#dfe8f2"), 4, true)
            draw_line(tip1, tip2, Color("#9fd8ef", 0.6), 7, true)
        "recv":
            var col2: Color = Color("#ffe9a8") if e.active else Color("#666f78")
            draw_arc(e.pos, 12, 0, TAU, 20, col2, 3)
            draw_circle(e.pos, 6, Color(col2, 0.4 if e.active else 0.15))
            if e.active:
                draw_circle(e.pos, 16 + sin(pulse * 6.0) * 3, Color(col2, 0.25))
        "portal":
            var col3 := Color("#b07fe8")
            draw_circle(e.a, 22 + sin(pulse * 3.0) * 2, Color(col3, 0.18))
            draw_arc(e.a, 20, 0, TAU, 24, col3, 3)
            draw_circle(e.a, 14, Color(col3, 0.3))
            draw_circle(e.b, 22 + sin(pulse * 3.0 + 2.0) * 2, Color(col3, 0.18))
            draw_arc(e.b, 20, 0, TAU, 24, col3, 3)
            draw_circle(e.b, 14, Color(col3, 0.3))
            if e.mode == "a2b":
                draw_string(font, e.a + Vector2(-24, 34), "ONE WAY", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#c9a8f0"))
        "swap":
            var gate := false
            for s in lv.ents:
                if s.t == "plate" and s.id == e.src and s.pressed: gate = true
                if s.t == "lever" and s.id == e.src and s.on: gate = true
            var col4 := Color("#e88ac8") if gate and not e.used else Color("#5a4a6a")
            draw_circle(e.pos, 24 + sin(pulse * 4.0) * 3, Color(col4, 0.2))
            draw_arc(e.pos, 22, 0, TAU, 6, col4, 3)
            draw_string(font, e.pos + Vector2(-30, 40), "SWAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(col4))
        "dark":
            pass
        "plat":
            pass
        "check":
            var col5 := Color("#9fdc8f") if e.used else Color("#666f78")
            draw_line(e.pos, e.pos + Vector2(0, -40), col5, 3)
            draw_colored_polygon(PackedVector2Array([e.pos + Vector2(0, -40), e.pos + Vector2(22, -32), e.pos + Vector2(0, -24)]), Color(col5, 0.9))
        "gem":
            if not e.got:
                var col6 := Color("#ff6a5a") if e.k == "r" else Color("#5ad0ff")
                var bob: float = sin(pulse * 3.0 + e.pos.x) * 3.0
                var c: Vector2 = e.pos + Vector2(0, bob)
                draw_colored_polygon(PackedVector2Array([c + Vector2(0, -9), c + Vector2(7, 0), c + Vector2(0, 9), c + Vector2(-7, 0)]), col6)
                draw_circle(c, 14 + sin(pulse * 4.0) * 2, Color(col6, 0.15))
        "bflip":
            var active: Rect2 = e.a if e.get("on", false) else e.b
            var inactive: Rect2 = e.b if e.get("on", false) else e.a
            draw_platform(active)
            for i3 in range(3):
                var frac2: float = float(i3 + 1) / 4.0
                draw_line(inactive.position + inactive.size * Vector2(frac2, 0.5) + Vector2(0, 8), inactive.position + inactive.size * Vector2(frac2, 0.5) + Vector2(0, 20), Color("#4a6a68", 0.4), 2)
        "bmov":
            if e.get("on", false):
                draw_platform(e.r)
            else:
                for i4 in range(3):
                    var frac3: float = float(i4 + 1) / 4.0
                    draw_line(e.r.position + e.r.size * Vector2(frac3, 0.5) + Vector2(0, 8), e.r.position + e.r.size * Vector2(frac3, 0.5) + Vector2(0, 20), Color("#4a6a68", 0.4), 2)
    # default: nothing to draw for unhandled types

func draw_fire_pool(r: Rect2):
    var surface_y := r.position.y
    var seed_offset := r.position.x * 0.13
    draw_rect(r, Color("#5c1f14", 0.85))
    draw_rect(Rect2(r.position + Vector2(0, 14), Vector2(r.size.x, r.size.y - 14)), Color("#7e2a16", 0.6))
    draw_rect(Rect2(r.position, Vector2(r.size.x, 26)), Color("#a63b1a", 0.55))
    var tongue_count := int(r.size.x / 16.0)
    for i in range(tongue_count):
        var t := float(i)
        var phase := pulse * (2.6 + fmod(t * 0.37, 1.4)) + seed_offset + t * 1.7
        var base_x := r.position.x + 8.0 + fmod(t * 16.0 + fmod(phase * 6.0, 9.0), r.size.x - 16.0)
        var sway := sin(phase) * 5.0
        var height := 24.0 + sin(phase * 1.9) * 10.0 + fmod(t * 7.3, 12.0)
        var width := 6.5 + sin(phase * 1.3) * 2.2
        var tip := Vector2(base_x + sway, surface_y - height)
        var left := Vector2(base_x - width, surface_y + 3.0)
        var right := Vector2(base_x + width, surface_y + 3.0)
        var ctrl := Vector2(base_x + sway * 1.6, surface_y - height * 0.55)
        draw_colored_polygon(PackedVector2Array([left, ctrl + Vector2(-width * 0.8, -height * 0.1), tip, ctrl + Vector2(width * 0.8, -height * 0.1), right]), Color("#ff7b39", 0.8))
        var inner_h := height * 0.55
        draw_colored_polygon(PackedVector2Array([
            Vector2(base_x - width * 0.5, surface_y + 2.0),
            Vector2(base_x + sway * 0.8 - width * 0.2, surface_y - inner_h * 0.6),
            Vector2(base_x + sway * 0.9, surface_y - inner_h),
            Vector2(base_x + sway * 0.8 + width * 0.2, surface_y - inner_h * 0.6),
            Vector2(base_x + width * 0.5, surface_y + 2.0)
        ]), Color("#ffc46b", 0.9))
    for i in range(11):
        var cycle := fmod(pulse * (20.0 + fmod(float(i) * 7.3, 13.0)) + float(i) * 23.0, 64.0)
        var sx := r.position.x + fmod(float(i * 37) + sin(pulse * 0.9 + float(i) * 2.1) * 16.0 + 30.0, r.size.x)
        var sy := surface_y - cycle
        var alpha: float = clamp(1.0 - cycle / 64.0, 0.0, 1.0)
        var spark_size: float = 1.8 + fmod(float(i) * 0.8, 1.6) * alpha
        draw_circle(Vector2(sx, sy), spark_size, Color("#ffcf7d", alpha * 0.9))
        if i % 3 == 0:
            draw_circle(Vector2(sx + sin(pulse * 2.2 + float(i)) * 3.5, sy - 5.0), spark_size * 0.55, Color("#ffe9b8", alpha * 0.65))
    for i in range(3):
        var shimmer_y := surface_y - 26.0 - float(i) * 16.0
        var shimmer_w := r.size.x * (0.9 - float(i) * 0.18)
        var shimmer_x := r.position.x + (r.size.x - shimmer_w) * 0.5 + sin(pulse * 1.6 + float(i) * 2.0) * 8.0
        draw_circle(Vector2(shimmer_x + shimmer_w * 0.5, shimmer_y), shimmer_w * 0.5, Color("#ff9a5d", 0.05 + 0.02 * sin(pulse * 2.0 + float(i))))
    var surface := PackedVector2Array()
    for i in range(13):
        var lx := r.position.x + r.size.x * float(i) / 12.0
        var ly := surface_y + sin(pulse * 5.0 + float(i) * 1.1 + seed_offset) * 1.8
        surface.append(Vector2(lx, ly))
    for i in range(surface.size() - 1):
        draw_line(surface[i], surface[i + 1], Color("#ff9a5d", 0.9), 2.5)

func draw_water_pool(r: Rect2):
    var surface_y := r.position.y
    var seed_offset := r.position.x * 0.11
    draw_rect(r, Color("#0e4a56", 0.88))
    draw_rect(Rect2(r.position + Vector2(0, 22), Vector2(r.size.x, r.size.y - 22)), Color("#0a3641", 0.75))
    draw_rect(Rect2(r.position + Vector2(0, 52), Vector2(r.size.x, r.size.y - 52)), Color("#072731", 0.8))
    for layer in range(2):
        var amp := 4.2 if layer == 0 else 2.8
        var speed := 2.2 if layer == 0 else 3.1
        var y_off := 0.0 if layer == 0 else 6.0
        var wave_color := Color("#53d9db", 0.9) if layer == 0 else Color("#2b9da4", 0.75)
        var points := PackedVector2Array()
        var steps := 14
        for i in range(steps + 1):
            var wx := r.position.x + r.size.x * float(i) / float(steps)
            var wy := surface_y + y_off + sin(pulse * speed + float(i) * 0.9 + seed_offset + float(layer) * 2.4) * amp
            points.append(Vector2(wx, wy))
        for i in range(points.size() - 1):
            draw_line(points[i], points[i + 1], wave_color, 3.0 if layer == 0 else 2.0)
        var fill := PackedVector2Array(points)
        fill.append(Vector2(r.end.x, surface_y + y_off + 16.0))
        fill.append(Vector2(r.position.x, surface_y + y_off + 16.0))
        draw_colored_polygon(fill, Color("#1b707c", 0.28 if layer == 0 else 0.2))
    for i in range(8):
        var cycle := fmod(pulse * (10.0 + fmod(float(i) * 6.1, 9.0)) + float(i) * 27.0, 52.0)
        var bx := r.position.x + fmod(float(i * 43) + sin(float(i) * 3.7) * 18.0 + 24.0, r.size.x)
        var by := surface_y + 46.0 - cycle
        var balpha: float = clamp(1.0 - cycle / 52.0, 0.0, 1.0) * 0.7
        var bob := sin(pulse * 3.4 + float(i) * 1.9) * 3.0
        draw_arc(Vector2(bx + bob, by), 2.2 + fmod(float(i) * 0.7, 1.8), 0.0, TAU, 10, Color("#b8ffff", balpha), 1.4)
    for i in range(4):
        var twinkle := sin(pulse * 4.0 + float(i) * 2.4)
        if twinkle > 0.2:
            var gx := r.position.x + fmod(float(i * 61) + pulse * 9.0, r.size.x)
            var gy := surface_y + 4.0 + sin(pulse * 2.6 + float(i)) * 2.0
            var g: float = (twinkle - 0.2) / 0.8
            draw_circle(Vector2(gx, gy), 1.6 + g * 1.4, Color("#d9ffff", g * 0.8))
    var crest := PackedVector2Array()
    for i in range(13):
        var lx := r.position.x + r.size.x * float(i) / 12.0
        var ly := surface_y + sin(pulse * 3.2 + float(i) * 0.85 + seed_offset) * 2.6
        crest.append(Vector2(lx, ly))
    for i in range(crest.size() - 1):
        draw_line(crest[i], crest[i + 1], Color("#9ff2ee", 0.95), 2.2)

func actor(a: Dictionary, label: String):
    var p: Vector2 = a.pos
    var velocity: Vector2 = a.vel
    var airborne: bool = abs(velocity.y) > 20.0
    var stride := 0.0 if abs(velocity.x) < 20.0 else sin(pulse * 12.0) * 5.0
    var bob := sin(pulse * 3.0) * 1.5 if not airborne else -2.0
    var facing := 1.0 if velocity.x >= 0 else -1.0
    var accent: Color = a.color
    var skin := Color("#f1c7a5") if label == "EMBER" else Color("#d7d1c4")
    var dark := Color("#472537") if label == "EMBER" else Color("#173a55")
    draw_ellipse(p + Vector2(0, 45), Vector2(22, 6), Color("#02090d", 0.40))
    draw_circle(p + Vector2(0, 6 + bob), 31 + sin(pulse * 4.0), Color(accent, 0.10))
    var cape := PackedVector2Array([p + Vector2(-10 * facing, 2 + bob), p + Vector2(-24 * facing, 34 + bob), p + Vector2(2 * facing, 29 + bob), p + Vector2(12 * facing, 5 + bob)])
    draw_colored_polygon(cape, Color(dark, 0.92))
    var leg_y := 35.0 if not airborne else 30.0
    draw_line(p + Vector2(-7, 21 + bob), p + Vector2(-8 + stride, leg_y + bob), dark, 8, true)
    draw_line(p + Vector2(7, 21 + bob), p + Vector2(8 - stride, leg_y + bob), dark, 8, true)
    draw_line(p + Vector2(-12 + stride, leg_y + 3 + bob), p + Vector2(-3 + stride, leg_y + 3 + bob), accent, 5, true)
    draw_line(p + Vector2(4 - stride, leg_y + 3 + bob), p + Vector2(13 - stride, leg_y + 3 + bob), accent, 5, true)
    draw_colored_polygon(PackedVector2Array([p + Vector2(-14, -2 + bob), p + Vector2(14, -2 + bob), p + Vector2(18, 25 + bob), p + Vector2(-18, 25 + bob)]), dark)
    draw_line(p + Vector2(-13, 3 + bob), p + Vector2(-19 - stride * .4, 19 + bob), skin, 7, true)
    draw_line(p + Vector2(13, 3 + bob), p + Vector2(20 + stride * .4, 17 + bob), skin, 7, true)
    draw_rect(Rect2(p + Vector2(-17, 14 + bob), Vector2(34, 5)), accent, true)
    draw_circle(p + Vector2(0, 10 + bob), 6, Color("#f8e7b0"))
    draw_circle(p + Vector2(0, 10 + bob), 3 + sin(pulse * 5.0), accent)
    draw_circle(p + Vector2(-12, -15 + bob), 4, skin); draw_circle(p + Vector2(12, -15 + bob), 4, skin)
    draw_circle(p + Vector2(0, -17 + bob), 15, skin)
    if label == "EMBER":
        var hair := PackedVector2Array([p + Vector2(-15, -20 + bob), p + Vector2(-9, -35 + bob), p + Vector2(-2, -29 + bob), p + Vector2(5, -39 + bob), p + Vector2(9, -27 + bob), p + Vector2(16, -21 + bob), p + Vector2(12, -12 + bob), p + Vector2(-13, -12 + bob)])
        draw_colored_polygon(hair, accent)
    else:
        draw_arc(p + Vector2(0, -18 + bob), 17, PI, TAU, 14, dark, 7)
        draw_circle(p + Vector2(14, -28 + bob), 6, accent)
        draw_circle(p + Vector2(18, -34 + bob), 3, Color("#bff7f2"))
    draw_circle(p + Vector2(-5, -17 + bob), 2.2, Color("#17212b"))
    draw_circle(p + Vector2(5, -17 + bob), 2.2, Color("#17212b"))
    draw_line(p + Vector2(0, -14 + bob), p + Vector2(2 * facing, -11 + bob), Color("#ad735f"), 1.5)
    draw_arc(p + Vector2(0, -10 + bob), 5, 0.25, PI - 0.25, 8, Color("#7f4545"), 1.4)
    draw_string(font, p + Vector2(-27, -48 + bob), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, accent)

func draw_ellipse(center: Vector2, radius: Vector2, color: Color):
    var points := PackedVector2Array()
    for i in range(25):
        var angle := TAU * float(i) / 24.0
        points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
    draw_colored_polygon(points, color)

func draw_hud():
    draw_rect(Rect2(28, 24, 1224, 76), Color("#102431", 0.94), true)
    draw_string(font, Vector2(52, 57), "M O S S L I G H T", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#f2e6bf"))
    draw_string(font, Vector2(52, 82), "CO-OP RUINS  /  " + lv.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#79b6a4"))
    draw_string(font, Vector2(52, 100), "CHEAT  click < > by LEVEL  /  N next  /  P prev  /  number + ENTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#5f7a74", 0.8))
    draw_string(font, Vector2(775, 48), "LEVEL %02d / %02d" % [level_index, level_count], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f2e6bf"))
    draw_string(font, Vector2(775, 72), "TIME  %03d / 600" % int(elapsed), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#9ab2b0"))
    var arrow_hot := Color("#f2e6bf", 0.28 if int(pulse * 2.0) % 2 == 0 else 0.5)
    draw_string(font, Vector2(737, 48), "<", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, arrow_hot)
    draw_string(font, Vector2(903, 48), ">", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, arrow_hot)
    draw_string(font, Vector2(930, 57), "A / D  +  W", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ember.color)
    draw_string(font, Vector2(930, 80), "← / →  +  ↑", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, tide.color)
    draw_string(font, Vector2(1130, 57), "GEMS", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#9ab2b0"))
    draw_colored_polygon(PackedVector2Array([Vector2(1138, 66), Vector2(1145, 74), Vector2(1138, 82), Vector2(1131, 74)]), Color("#ff6a5a"))
    draw_colored_polygon(PackedVector2Array([Vector2(1168, 66), Vector2(1175, 74), Vector2(1168, 82), Vector2(1161, 74)]), Color("#5ad0ff"))
    draw_string(font, Vector2(1182, 78), "%d/%d" % [gems_got, gems_total], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#f2e6bf"))
    if jump_buffer != "":
        draw_string(font, Vector2(620, 200), "JUMP TO LEVEL %s" % jump_buffer, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f8e3aa", 0.9))
