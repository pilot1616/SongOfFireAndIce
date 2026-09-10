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
    draw_rect(Rect2(0, 0, W, H), Color("#091522"))
    draw_circle(Vector2(1080, 110), 64 + sin(pulse) * 2, Color("#f5dc9a", 0.10))
    draw_circle(Vector2(1080, 110), 42, Color("#f8e3aa"))
    # distant canopy
    for i in range(11):
        var x := float(i * 130 - 40)
        draw_colored_polygon(PackedVector2Array([Vector2(x, 330), Vector2(x + 80, 120), Vector2(x + 180, 330)]), Color("#102e38"))
    draw_rect(Rect2(0, FLOOR_Y, W, H - FLOOR_Y), Color("#102d32"))
    draw_line(Vector2(0, FLOOR_Y), Vector2(W, FLOOR_Y), Color("#3d8a77"), 3)
    # platforms
    for platform_rect in platforms:
        platform(platform_rect)
    # elemental pools
    draw_rect(fire_pool_rect, Color("#cc704d", 0.72))
    draw_rect(water_pool_rect, Color("#2b9da4", 0.72))
    draw_rect(Rect2(fire_pool_rect.position, Vector2(fire_pool_rect.size.x, 8)), Color("#ff9a5d"))
    draw_rect(Rect2(water_pool_rect.position, Vector2(water_pool_rect.size.x, 8)), Color("#53d9db"))
    draw_string(font, Vector2(660, 650), "FIRE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#ffc092"))
    draw_string(font, Vector2(741, 650), "WATER", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#a2eff0"))
    # goal arch
    draw_line(Vector2(1080, FLOOR_Y), Vector2(1080, 330), Color("#d8c48a"), 8)
    draw_line(Vector2(1170, FLOOR_Y), Vector2(1170, 330), Color("#d8c48a"), 8)
    draw_arc(Vector2(1125, 330), 45, PI, TAU, 20, Color("#d8c48a"), 8)
    draw_string(font, Vector2(1087, 310), "MOON GATE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f7e4ac"))
    actor(ember, "EMBER")
    actor(tide, "TIDE")
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
    draw_rect(r, Color("#315b58"), true); draw_line(r.position, Vector2(r.end.x, r.position.y), Color("#79b6a4"), 3)

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
