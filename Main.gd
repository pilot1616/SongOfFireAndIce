extends Node2D

const W := 1280.0
const H := 720.0
const FLOOR_Y := 604.0
const GRAVITY := 1500.0
const SPEED := 285.0
const JUMP := -575.0

var ember := {"pos": Vector2(260, 520), "vel": Vector2.ZERO, "color": Color("#ff8b4a"), "spawn": Vector2(260, 520), "keys": ["ember_left", "ember_right", "ember_jump"]}
var tide := {"pos": Vector2(450, 520), "vel": Vector2.ZERO, "color": Color("#55d8dc"), "spawn": Vector2(450, 520), "keys": ["tide_left", "tide_right", "tide_jump"]}
var won := false
var pulse := 0.0
var font: Font
var platforms := [Rect2(72, 510, 270, 22), Rect2(390, 440, 210, 22), Rect2(820, 470, 290, 22), Rect2(1030, 385, 170, 22)]
var level_index := 1
var elapsed := 0.0
var target_time := 120.0
var level_count := 30
var fire_pool_rect := Rect2(650, FLOOR_Y, 75, 116)
var water_pool_rect := Rect2(725, FLOOR_Y, 75, 116)

func _ready():
    font = ThemeDB.fallback_font
    load_level(1)
    queue_redraw()

func _process(delta):
    pulse += delta
    if not won: elapsed += delta
    if Input.is_action_just_pressed("reset"): reset_level()
    if won and Input.is_action_just_pressed("ember_jump"):
        level_index = level_index % level_count + 1
        load_level(level_index)
    if not won:
        move_actor(ember, delta)
        move_actor(tide, delta)
        check_hazards(ember)
        check_hazards(tide)
        if ember.pos.x > 1080 and tide.pos.x > 1080 and elapsed >= target_time: won = true
        if elapsed > 600.0: reset_level()
    queue_redraw()

func move_actor(a: Dictionary, delta: float):
    var dir := Input.get_axis(a.keys[0], a.keys[1])
    var previous_y: float = a.pos.y
    a.vel.x = move_toward(a.vel.x, dir * SPEED, 1800.0 * delta)
    if Input.is_action_just_pressed(a.keys[2]) and a.vel.y == 0: a.vel.y = JUMP
    a.vel.y += GRAVITY * delta
    a.pos += a.vel * delta
    var landed := false
    if a.vel.y >= 0:
        for platform_rect in platforms:
            var feet_x := a.pos.x
            var was_above := previous_y + 48 <= platform_rect.position.y
            var crossed := a.pos.y + 48 >= platform_rect.position.y
            if was_above and crossed and feet_x >= platform_rect.position.x - 18 and feet_x <= platform_rect.end.x + 18:
                a.pos.y = platform_rect.position.y - 48
                a.vel.y = 0
                landed = true
                break
    if not landed and a.pos.y > FLOOR_Y - 48:
        a.pos.y = FLOOR_Y - 48
        a.vel.y = 0
    a.pos.x = clamp(a.pos.x, 42.0, W - 42.0)

func check_hazards(a: Dictionary):
    # Two adjacent pools: orange fire hurts Tide, cyan water hurts Ember.
    var in_pool := a.pos.y > FLOOR_Y - 70
    var fire_pool := fire_pool_rect.has_point(Vector2(a.pos.x, FLOOR_Y + 1))
    var water_pool := water_pool_rect.has_point(Vector2(a.pos.x, FLOOR_Y + 1))
    var wrong := in_pool and ((a == tide and fire_pool) or (a == ember and water_pool))
    if wrong:
        a.pos = a.spawn
        a.vel = Vector2.ZERO

func reset_level():
    ember.pos = ember.spawn; ember.vel = Vector2.ZERO
    tide.pos = tide.spawn; tide.vel = Vector2.ZERO; won = false; elapsed = 0.0

func load_level(number: int):
    var chapter := int((number - 1) / 5)
    var variant := (number - 1) % 5
    platforms = [Rect2(72, 510, 270, 22), Rect2(390, 440 - chapter * 8, 210, 22), Rect2(820, 470 - variant * 8, 290, 22), Rect2(1030, 385 - chapter * 7, 170, 22)]
    if number >= 6: platforms.insert(2, Rect2(620, 500 - variant * 10, 125, 22))
    if number >= 16: platforms.insert(3, Rect2(760, 405 - chapter * 5, 110, 22))
    var pool_width := min(75.0 + chapter * 12.0 + variant * 3.0, 145.0)
    fire_pool_rect = Rect2(650, FLOOR_Y, pool_width, 116)
    water_pool_rect = Rect2(650 + pool_width, FLOOR_Y, pool_width, 116)
    target_time = 120.0 + float(chapter * 20 + variant * 5)
    reset_level()

func _draw():
    draw_rect(Rect2(0, 0, W, H), Color("#07131f"))
    draw_scene_background()
    draw_rect(Rect2(0, FLOOR_Y, W, H - FLOOR_Y), Color("#102d32"))
    draw_line(Vector2(0, FLOOR_Y), Vector2(W, FLOOR_Y), Color("#3d8a77"), 3)
    draw_ruins()
    # platforms
    for platform_rect in platforms:
        platform(platform_rect)
    # elemental pools
    draw_rect(fire_pool_rect, Color("#cc704d", 0.72))
    draw_rect(water_pool_rect, Color("#2b9da4", 0.72))
    draw_rect(Rect2(fire_pool_rect.position, Vector2(fire_pool_rect.size.x, 8)), Color("#ff9a5d"))
    draw_rect(Rect2(water_pool_rect.position, Vector2(water_pool_rect.size.x, 8)), Color("#53d9db"))
    for i in range(5):
        var wave_x := fire_pool_rect.position.x + fmod(float(i * 29) + pulse * 18.0, fire_pool_rect.size.x)
        draw_circle(Vector2(wave_x, FLOOR_Y + 5), 3 + sin(pulse * 3.0 + i), Color("#ffd08a", 0.75))
        var drop_x := water_pool_rect.position.x + fmod(float(i * 31) + pulse * 12.0, water_pool_rect.size.x)
        draw_arc(Vector2(drop_x, FLOOR_Y + 6), 5, PI, TAU, 8, Color("#b8ffff", 0.72), 2)
    draw_string(font, Vector2(660, 650), "FIRE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#ffc092"))
    draw_string(font, Vector2(741, 650), "WATER", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#a2eff0"))
    # goal arch
    draw_gate()
    draw_string(font, Vector2(1087, 310), "MOON GATE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f7e4ac"))
    actor(ember, "EMBER")
    actor(tide, "TIDE")
    draw_foreground()
    # HUD
    draw_rect(Rect2(28, 24, 1224, 76), Color("#102431", 0.94), true)
    draw_string(font, Vector2(52, 57), "M O S S L I G H T", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#f2e6bf"))
    draw_string(font, Vector2(52, 82), "CO-OP RUINS  /  01", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#79b6a4"))
    draw_string(font, Vector2(775, 48), "LEVEL %02d / %02d" % [level_index, level_count], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f2e6bf"))
    draw_string(font, Vector2(775, 72), "TIME  %03d / 600" % int(elapsed), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#9ab2b0"))
    draw_string(font, Vector2(930, 57), "A / D  +  W", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ember.color)
    draw_string(font, Vector2(930, 80), "← / →  +  ↑", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, tide.color)
    draw_string(font, Vector2(1130, 67), "R", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#9ab2b0"))
    if won:
        draw_rect(Rect2(330, 250, 620, 150), Color("#102b31", 0.98), true)
        draw_string(font, Vector2(490, 312), "GATE AWAKENED", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#f8e3aa"))
        draw_string(font, Vector2(487, 348), "Two sparks. One way home.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#91d8c1"))
        draw_string(font, Vector2(540, 380), "Press R to run it again", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#a9bbb2"))

func platform(r: Rect2):
    draw_colored_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end + Vector2(-8, 13), Vector2(r.position.x + 8, r.end.y + 13)]), Color("#203f43"))
    draw_rect(r, Color("#315b58"), true)
    draw_line(r.position, Vector2(r.end.x, r.position.y), Color("#80bda1"), 3)
    for x in range(int(r.position.x) + 18, int(r.end.x), 42):
        draw_line(Vector2(x, r.position.y + 5), Vector2(x - 7, r.end.y - 2), Color("#254b4b"), 2)
        draw_circle(Vector2(x + 6, r.position.y - 1), 3, Color("#83a84e"))

func draw_scene_background():
    # Moon glow, stars, layered mountain silhouettes and mist establish depth.
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
        draw_rect(Rect2(base_x, 350, 28, FLOOR_Y - 350), Color("#263f42"))
        draw_rect(Rect2(base_x - 8, 340, 44, 14), Color("#3e5d57"))
        for y in range(375, 580, 40):
            draw_line(Vector2(base_x + 3, y), Vector2(base_x + 25, y - 5), Color("#172f34"), 2)
    draw_arc(Vector2(370, 390), 55, PI, TAU, 18, Color("#35524e"), 12)
    for i in range(6):
        var vine_x := 45.0 + i * 238.0
        draw_bezier(vine_x)

func draw_bezier(start_x: float):
    var previous := Vector2(start_x, 345)
    for i in range(1, 9):
        var next := Vector2(start_x + sin(i * .9) * 10, 345 + i * 22)
        draw_line(previous, next, Color("#47724f"), 2)
        if i % 2 == 0: draw_circle(next + Vector2(6, 0), 4, Color("#699052"))
        previous = next

func draw_gate():
    for offset in [0.0, 90.0]:
        draw_rect(Rect2(1075 + offset, 330, 11, FLOOR_Y - 330), Color("#bda876"))
        draw_line(Vector2(1078 + offset, 340), Vector2(1078 + offset, FLOOR_Y), Color("#f4dfa1", .45), 3)
    draw_arc(Vector2(1125, 330), 45, PI, TAU, 28, Color("#d8c48a"), 10)
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

func actor(a: Dictionary, label: String):
    var p: Vector2 = a.pos
    var velocity: Vector2 = a.vel
    var airborne := abs(velocity.y) > 20.0
    var stride := 0.0 if abs(velocity.x) < 20.0 else sin(pulse * 12.0) * 5.0
    var bob := sin(pulse * 3.0) * 1.5 if not airborne else -2.0
    var facing := 1.0 if velocity.x >= 0 else -1.0
    var accent: Color = a.color
    var skin := Color("#f1c7a5") if label == "EMBER" else Color("#d7d1c4")
    var dark := Color("#472537") if label == "EMBER" else Color("#173a55")
    # Soft elemental aura and grounded shadow.
    draw_ellipse(p + Vector2(0, 45), Vector2(22, 6), Color("#02090d", 0.40))
    draw_circle(p + Vector2(0, 6 + bob), 31 + sin(pulse * 4.0), Color(accent, 0.10))
    # Cape creates a readable silhouette and trails opposite the facing direction.
    var cape := PackedVector2Array([p + Vector2(-10 * facing, 2 + bob), p + Vector2(-24 * facing, 34 + bob), p + Vector2(2 * facing, 29 + bob), p + Vector2(12 * facing, 5 + bob)])
    draw_colored_polygon(cape, Color(dark, 0.92))
    # Boots and animated legs.
    var leg_y := 35.0 if not airborne else 30.0
    draw_line(p + Vector2(-7, 21 + bob), p + Vector2(-8 + stride, leg_y + bob), dark, 8, true)
    draw_line(p + Vector2(7, 21 + bob), p + Vector2(8 - stride, leg_y + bob), dark, 8, true)
    draw_line(p + Vector2(-12 + stride, leg_y + 3 + bob), p + Vector2(-3 + stride, leg_y + 3 + bob), accent, 5, true)
    draw_line(p + Vector2(4 - stride, leg_y + 3 + bob), p + Vector2(13 - stride, leg_y + 3 + bob), accent, 5, true)
    # Tunic, belt and arms.
    draw_colored_polygon(PackedVector2Array([p + Vector2(-14, -2 + bob), p + Vector2(14, -2 + bob), p + Vector2(18, 25 + bob), p + Vector2(-18, 25 + bob)]), dark)
    draw_line(p + Vector2(-13, 3 + bob), p + Vector2(-19 - stride * .4, 19 + bob), skin, 7, true)
    draw_line(p + Vector2(13, 3 + bob), p + Vector2(20 + stride * .4, 17 + bob), skin, 7, true)
    draw_rect(Rect2(p + Vector2(-17, 14 + bob), Vector2(34, 5)), accent, true)
    draw_circle(p + Vector2(0, 10 + bob), 6, Color("#f8e7b0"))
    draw_circle(p + Vector2(0, 10 + bob), 3 + sin(pulse * 5.0), accent)
    # Head, ears, hair/hood, eyes and nose.
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
