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

func _ready():
    font = ThemeDB.fallback_font
    queue_redraw()

func _process(delta):
    pulse += delta
    if Input.is_action_just_pressed("reset"): reset_level()
    if not won:
        move_actor(ember, delta)
        move_actor(tide, delta)
        check_hazards(ember)
        check_hazards(tide)
        if ember.pos.x > 1080 and tide.pos.x > 1080: won = true
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
    var fire_pool := a.pos.x > 650 and a.pos.x < 725
    var water_pool := a.pos.x >= 725 and a.pos.x < 800
    var wrong := in_pool and ((a == tide and fire_pool) or (a == ember and water_pool))
    if wrong:
        a.pos = a.spawn
        a.vel = Vector2.ZERO

func reset_level():
    ember.pos = ember.spawn; ember.vel = Vector2.ZERO
    tide.pos = tide.spawn; tide.vel = Vector2.ZERO; won = false

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
    platform(Rect2(72, 510, 270, 22)); platform(Rect2(390, 440, 210, 22)); platform(Rect2(820, 470, 290, 22)); platform(Rect2(1030, 385, 170, 22))
    # elemental pools
    draw_rect(Rect2(650, FLOOR_Y, 75, 116), Color("#cc704d", 0.72))
    draw_rect(Rect2(725, FLOOR_Y, 75, 116), Color("#2b9da4", 0.72))
    draw_rect(Rect2(650, FLOOR_Y, 75, 8), Color("#ff9a5d"))
    draw_rect(Rect2(725, FLOOR_Y, 75, 8), Color("#53d9db"))
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
    draw_string(font, Vector2(775, 57), "A / D  +  W", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ember.color)
    draw_string(font, Vector2(775, 80), "← / →  +  ↑", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, tide.color)
    draw_string(font, Vector2(1050, 67), "R  RESET", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#9ab2b0"))
    if won:
        draw_rect(Rect2(330, 250, 620, 150), Color("#102b31", 0.98), true)
        draw_string(font, Vector2(490, 312), "GATE AWAKENED", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#f8e3aa"))
        draw_string(font, Vector2(487, 348), "Two sparks. One way home.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#91d8c1"))
        draw_string(font, Vector2(540, 380), "Press R to run it again", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#a9bbb2"))

func platform(r: Rect2):
    draw_rect(r, Color("#315b58"), true); draw_line(r.position, Vector2(r.end.x, r.position.y), Color("#79b6a4"), 3)

func actor(a: Dictionary, label: String):
    var p: Vector2 = a.pos
    draw_circle(p + Vector2(0, 8), 22, Color(a.color, 0.16))
    draw_circle(p, 17, a.color)
    draw_circle(p + Vector2(0, -4), 11, Color("#f5e8c7"))
    draw_circle(p + Vector2(-4, -5), 2.5, Color("#13212a")); draw_circle(p + Vector2(4, -5), 2.5, Color("#13212a"))
    draw_string(font, p + Vector2(-27, -28), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, a.color)
