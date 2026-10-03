extends Object
# Mosslight 关卡数据 v0.6 —— 4 神殿 × 10 关，地图尺寸四档递进：
# 一章 森林(1-10):   map_w 1280（单屏小房间）
# 二章 冰(11-20):    map_w 1920（1.5 屏，两段式）
# 三章 火(21-30):    map_w 2560（2 屏，多房间+传送门连通）
# 四章 光明(31-40):  map_w 3200（2.5 屏，立体复合+接力回环）
# 相机在 map_w>1280 时自动跟随双人中点；元素规则同 v0.5。

static func plat(x: float, y: float, w: float) -> Dictionary:
    return {"t": "plat", "r": Rect2(x, y, w, 14)}

static func seg(a: float, b: float) -> Rect2:
    return Rect2(a, 604.0, b - a, 116.0)

static func pit(a: float, b: float) -> Rect2:
    return Rect2(a, 650.0, b - a, 70.0)

static func pool(kind: String, x: float, w: float) -> Dictionary:
    return {"kind": kind, "r": Rect2(x, 604.0, w, 64), "frozen_t": 0.0}

static func plate(x: float, y: float, id: String, k: String) -> Dictionary:
    return {"t": "plate", "id": id, "k": k, "r": Rect2(x, y, 44, 8), "pressed": false}

static func lever(x: float, y: float, id: String) -> Dictionary:
    return {"t": "lever", "id": id, "pos": Vector2(x, y), "on": false, "cd": 0.0}

static func door(x: float, y: float, h: float, links: Array) -> Dictionary:
    return {"t": "door", "r": Rect2(x, y, 16, h), "links": links, "open": false}

static func wall(x: float, y: float, w: float, h: float) -> Dictionary:
    return {"t": "wall", "r": Rect2(x, y, w, h)}

static func block(x: float, y: float) -> Dictionary:
    return {"t": "block", "r": Rect2(x, y, 46, 46), "vy": 0.0, "erased": false}

static func iceblk(x: float, y: float, w: float, h: float) -> Dictionary:
    return {"t": "ice", "r": Rect2(x, y, w, h), "melt": 0.0, "vy": 0.0, "erased": false}

static func bmov(r: Rect2, src: String) -> Dictionary:
    return {"t": "bmov", "r": r, "src": src}

static func mover(x: float, y: float, x1: float, x2: float, sp: float, ph: float) -> Dictionary:
    return {"t": "mover", "r": Rect2(x, y, 120, 14), "x1": x1, "x2": x2, "sp": sp, "ph": ph, "dx": 0.0}

static func elev(x: float, y: float, y1: float, y2: float, srcs: Array) -> Dictionary:
    return {"t": "elev", "r": Rect2(x, y, 130, 14), "y1": y1, "y2": y2, "srcs": srcs, "dy": 0.0}

static func beam(x: float, y: float, dir: String, kind: String, sw: bool, srcs: Array) -> Dictionary:
    return {"t": "beam", "pos": Vector2(x, y), "dir": dir, "kind": kind, "sw": sw, "srcs": srcs, "path": [], "on": true, "kind_now": kind}

static func recv(x: float, y: float, id: String) -> Dictionary:
    return {"t": "recv", "id": id, "pos": Vector2(x, y), "active": false}

static func mirror(x: float, y: float, slash: bool) -> Dictionary:
    return {"t": "mirror", "pos": Vector2(x, y), "slash": slash, "cd": 0.0}

static func chain(id: String, ids: Array) -> Dictionary:
    return {"t": "chain", "id": id, "ids": ids, "active": false}

static func portal(ax: float, ay: float, bx: float, by: float, col: String) -> Dictionary:
    return {"t": "portal", "a": Vector2(ax, ay), "b": Vector2(bx, by), "col": col, "cdE": 0.0, "cdT": 0.0}

static func darkzone(x: float, y: float, w: float, h: float, lit_id: String) -> Dictionary:
    return {"t": "dark", "r": Rect2(x, y, w, h), "lever": lit_id, "lit": false}

static func checkpoint(x: float, y: float) -> Dictionary:
    return {"t": "check", "pos": Vector2(x, y), "used": false}

static func gem(x: float, y: float, k: String) -> Dictionary:
    return {"t": "gem", "pos": Vector2(x, y), "k": k, "got": false}

static func timer(id: String, period: float, duty: float, phase: float) -> Dictionary:
    return {"t": "timer", "id": id, "period": period, "duty": duty, "phase": phase, "active": false}

static func spike(x: float, y: float, w: float, pop: bool, src: String) -> Dictionary:
    return {"t": "spike", "r": Rect2(x, y, w, 14), "pop": pop, "src": src, "extended": false}

static func rotator(x: float, y: float, arm: float, src: String) -> Dictionary:
    return {"t": "rot", "pos": Vector2(x, y), "arm": arm, "src": src, "ang": 0.0, "spin": false}

static func elewall(x: float, y: float, w: float, h: float, k: String) -> Dictionary:
    return {"t": "elewall", "r": Rect2(x, y, w, h), "k": k, "gone": false}

static func gemdoor(rx: float, ry: float, nr: int = 1, nb: int = 1) -> Dictionary:
    return {"t": "gemdoor", "pos": Vector2(rx, ry), "need": {"r": nr, "b": nb}, "have": {"r": 0, "b": 0}, "open": false}

static func bouncepad(x: float, y: float, power: float) -> Dictionary:
    # Launches any actor standing on it upward with the given velocity (fixed direction).
    return {"t": "bounce", "r": Rect2(x, y, 70, 12), "power": power, "cd": {}}

static func crumbleplat(x: float, y: float, w: float, ttl: float) -> Dictionary:
    # Vanishing platform: countdown starts when an actor stands on it,
    # shatters permanently (level restart restores it).
    return {"t": "crumble", "r": Rect2(x, y, w, 12), "ttl": ttl, "t_left": ttl, "gone": false, "shaking": false}

static func build(n: int) -> Dictionary:
    # 关卡尺寸按设计文档格子数换算：1 格 ≈ 55px 宽 / 45px 高，地面基线 y=604。
    # map_w = 格宽*55, map_h = 格高*45（部分塔关再留出纵向余量）。
    var lv := {"name": "", "floors": [seg(0.0, 1280.0)], "plats": [], "pools": [], "ents": [], "spawnE": Vector2(70, 550), "spawnT": Vector2(130, 550), "map_w": 1280.0, "map_h": 720.0}
    match n:
        # ========== 第 1 关｜森林入口：12×8，无机关，双平台相向而行 ==========
        1:
            lv.name = "1 森林入口"
            lv.map_w = 660.0
            lv.floors = [seg(0.0, 320.0), seg(360.0, 660.0)]
            lv.spawnE = Vector2(610, 550)
            lv.spawnT = Vector2(80, 550)
            lv.ents = [
                gemdoor(40.0, 604.0),
                gemdoor(620.0, 604.0),
            ]
        # ========== 第 2 关｜分隔浅沟：14×9，缺口跳越大沟 ==========
        2:
            lv.name = "2 分隔浅沟"
            lv.map_w = 770.0
            lv.floors = [seg(0.0, 330.0), seg(440.0, 770.0)]
            lv.pools = [pool("shallow", 330.0, 110.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(710, 550)
            lv.ents = [
                gemdoor(60.0, 604.0),
                gemdoor(720.0, 604.0),
            ]
        # ========== 第 3 关｜双色水池初识：15×9，元素路面教学 ==========
        3:
            lv.name = "3 双色水池初识"
            lv.map_w = 825.0
            lv.floors = [seg(0.0, 300.0), seg(500.0, 825.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(770, 550)
            lv.pools = [pool("fire", 300.0, 200.0), pool("water", 300.0, 200.0)]
            lv.ents = [
                gemdoor(60.0, 604.0),
                gemdoor(770.0, 604.0),
            ]
        # ========== 第 4 关｜单向跳板初体验：16×10，跳板上高台 ==========
        4:
            lv.name = "4 单向跳板初体验"
            lv.map_w = 880.0
            lv.floors = [seg(0.0, 880.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(130, 550)
            lv.pools = [pool("fire", 500.0, 80.0), pool("water", 620.0, 80.0)]
            lv.ents = [
                bouncepad(380.0, 590.0, 780.0),
                plat(300.0, 320.0, 220.0),
                gemdoor(400.0, 320.0, 1, 1),
                gem(420.0, 280.0, "r"), gem(470.0, 280.0, "b"),
            ]
        # ========== 第 5 关｜按钮与门·基础版：17×10，留守分工 ==========
        5:
            lv.name = "5 按钮与门"
            lv.map_w = 935.0
            lv.floors = [seg(0.0, 935.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(130, 550)
            lv.pools = [pool("fire", 600.0, 70.0), pool("water", 700.0, 70.0)]
            lv.ents = [
                plate(350.0, 596.0, "p1", "n"),
                door(520.0, 444.0, 160.0, ["p1"]),
                gemdoor(830.0, 604.0, 1, 1),
                gem(780.0, 550.0, "r"), gem(830.0, 550.0, "b"),
            ]
        # ========== 第 6 关｜推箱子压按钮：18×11，木箱替代留守 ==========
        6:
            lv.name = "6 推箱子压按钮"
            lv.map_w = 990.0
            lv.floors = [seg(0.0, 990.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(130, 550)
            lv.pools = [pool("fire", 700.0, 70.0), pool("water", 800.0, 70.0)]
            lv.ents = [
                block(300.0, 558.0),
                plate(500.0, 596.0, "p1", "n"),
                door(640.0, 444.0, 160.0, ["p1"]),
                gemdoor(900.0, 604.0, 1, 1),
                gem(840.0, 550.0, "r"), gem(880.0, 550.0, "b"),
            ]
        # ========== 第 7 关｜交错水池迷宫：20×12，S 形元素路线 ==========
        7:
            lv.name = "7 交错水池迷宫"
            lv.map_w = 1100.0
            lv.floors = [seg(0.0, 1100.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1040, 550)
            lv.pools = [pool("fire", 200.0, 90.0), pool("water", 330.0, 90.0), pool("fire", 560.0, 90.0), pool("water", 690.0, 90.0), pool("fire", 830.0, 90.0)]
            lv.plats = [plat(270.0, 520.0, 60.0), plat(620.0, 520.0, 60.0), plat(950.0, 520.0, 60.0)]
            lv.ents = [
                gemdoor(80.0, 604.0, 1, 1),
                gemdoor(1030.0, 604.0, 1, 1),
                gem(560.0, 550.0, "r"), gem(690.0, 550.0, "b"),
            ]
        # ========== 第 8 关｜高低台组合跳板：20×13，三层跳板登高 ==========
        8:
            lv.name = "8 高低台组合跳板"
            lv.map_w = 1100.0
            lv.map_h = 880.0
            lv.floors = [seg(0.0, 1100.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(130, 550)
            lv.pools = [pool("fire", 480.0, 80.0), pool("water", 640.0, 80.0)]
            lv.ents = [
                bouncepad(300.0, 590.0, 700.0),
                plat(240.0, 430.0, 160.0),
                bouncepad(560.0, 420.0, 760.0),
                plat(500.0, 250.0, 180.0),
                gemdoor(560.0, 250.0, 1, 1),
                gem(520.0, 210.0, "r"), gem(600.0, 210.0, "b"),
            ]
        # ========== 第 9 关｜双按钮双门：22×14，左右分房 ==========
        9:
            lv.name = "9 双按钮双门"
            lv.map_w = 1210.0
            lv.floors = [seg(0.0, 1210.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1150, 550)
            lv.ents = [
                wall(590.0, 240.0, 20.0, 364.0),
                plate(300.0, 596.0, "pA", "n"),
                door(430.0, 444.0, 160.0, ["pA"]),
                block(760.0, 558.0),
                plate(900.0, 596.0, "pB", "n"),
                door(1010.0, 444.0, 160.0, ["pB"]),
                gemdoor(80.0, 604.0, 1, 1),
                gemdoor(1140.0, 604.0, 1, 1),
                gem(540.0, 550.0, "r"), gem(680.0, 550.0, "b"),
            ]
        # ========== 第 10 关｜移动浮板：23×14，消失平台跨池 ==========
        10:
            lv.name = "10 消失浮板"
            lv.map_w = 1265.0
            lv.floors = [seg(0.0, 300.0), seg(965.0, 1265.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("fire", 300.0, 330.0), pool("water", 630.0, 335.0)]
            lv.ents = [
                crumbleplat(340.0, 560.0, 90.0, 2.2),
                crumbleplat(490.0, 540.0, 90.0, 2.2),
                crumbleplat(650.0, 560.0, 90.0, 2.2),
                crumbleplat(800.0, 540.0, 90.0, 2.2),
                gemdoor(60.0, 604.0, 1, 1),
                gemdoor(1210.0, 604.0, 1, 1),
                gem(500.0, 500.0, "r"), gem(760.0, 500.0, "b"),
            ]
        # ========== 第 11 关｜长通道推箱子迷宫：24×15，多箱多门 ==========
        11:
            lv.name = "11 长廊推箱"
            lv.map_w = 1320.0
            lv.floors = [seg(0.0, 1320.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1270, 550)
            lv.pools = [pool("fire", 560.0, 60.0), pool("water", 680.0, 60.0), pool("shallow", 980.0, 70.0)]
            lv.ents = [
                block(300.0, 558.0), block(380.0, 558.0), block(1200.0, 558.0),
                plate(500.0, 596.0, "p1", "n"),
                door(620.0, 444.0, 160.0, ["p1"]),
                plate(860.0, 596.0, "p2", "n"),
                door(1080.0, 444.0, 160.0, ["p2"]),
                gemdoor(70.0, 604.0, 1, 1),
                gemdoor(1260.0, 604.0, 1, 1),
                gem(760.0, 550.0, "r"), gem(900.0, 550.0, "b"),
            ]
        # ========== 第 12 关｜跳板+消失平台组合：24×15，弹射后限时跳跃 ==========
        12:
            lv.name = "12 跳板接浮板"
            lv.map_w = 1320.0
            lv.map_h = 900.0
            lv.floors = [seg(0.0, 1320.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1270, 550)
            lv.pools = [pool("fire", 400.0, 120.0), pool("water", 620.0, 120.0), pool("fire", 850.0, 120.0), pool("water", 1060.0, 120.0)]
            lv.ents = [
                bouncepad(250.0, 590.0, 820.0),
                plat(180.0, 330.0, 150.0),
                crumbleplat(400.0, 320.0, 80.0, 2.0),
                crumbleplat(560.0, 320.0, 80.0, 2.0),
                plat(700.0, 300.0, 150.0),
                crumbleplat(900.0, 320.0, 80.0, 2.0),
                crumbleplat(1060.0, 320.0, 80.0, 2.0),
                plat(1180.0, 300.0, 140.0),
                gemdoor(1240.0, 300.0, 1, 1),
                gem(440.0, 280.0, "r"), gem(940.0, 280.0, "b"),
            ]
        # ========== 第 13 关｜分隔大房间：26×16，左右独立任务链 ==========
        13:
            lv.name = "13 分头开锁"
            lv.map_w = 1430.0
            lv.map_h = 880.0
            lv.floors = [seg(0.0, 1430.0)]
            lv.spawnE = Vector2(660, 550)
            lv.spawnT = Vector2(780, 550)
            lv.pools = [pool("fire", 250.0, 70.0), pool("water", 1120.0, 70.0)]
            lv.ents = [
                wall(640.0, 300.0, 16.0, 304.0),
                wall(790.0, 300.0, 16.0, 304.0),
                # 左任务链：推箱压板开门
                block(180.0, 558.0),
                plate(380.0, 596.0, "pL", "n"),
                door(500.0, 444.0, 160.0, ["pL"]),
                # 右任务链：跳板上高台踩板
                bouncepad(980.0, 590.0, 760.0),
                plat(920.0, 400.0, 150.0),
                plate(970.0, 366.0, "pR", "n"),
                door(1150.0, 444.0, 160.0, ["pR"]),
                # 中央大门：双条件
                door(714.0, 444.0, 160.0, ["pL", "pR"]),
                gemdoor(1360.0, 604.0, 1, 1),
                gem(540.0, 550.0, "r"), gem(900.0, 550.0, "b"),
            ]
        # ========== 第 14 关｜双色水池大迷宫：27×16，纯路线迷宫 ==========
        14:
            lv.name = "14 元素迷宫"
            lv.map_w = 1485.0
            lv.floors = [seg(0.0, 1485.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1420, 550)
            lv.pools = [
                pool("fire", 200.0, 90.0), pool("water", 330.0, 90.0),
                pool("fire", 560.0, 90.0), pool("water", 700.0, 90.0),
                pool("fire", 900.0, 90.0), pool("water", 1030.0, 90.0),
                pool("fire", 1230.0, 90.0), pool("water", 1330.0, 90.0),
            ]
            lv.plats = [plat(290.0, 520.0, 60.0), plat(650.0, 520.0, 60.0), plat(990.0, 520.0, 60.0), plat(1180.0, 460.0, 90.0)]
            lv.ents = [
                gemdoor(80.0, 604.0, 1, 1),
                gemdoor(1400.0, 604.0, 1, 1),
                gem(700.0, 550.0, "r"), gem(1030.0, 550.0, "b"),
                gem(1180.0, 430.0, "r"), gem(560.0, 550.0, "b"),
            ]
        # ========== 第 15 关｜多层高塔：27×18，四层纵向推进 ==========
        15:
            lv.name = "15 多层高塔"
            lv.map_w = 1485.0
            lv.map_h = 990.0
            lv.floors = [seg(0.0, 1485.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1420, 550)
            lv.pools = [pool("fire", 600.0, 80.0), pool("water", 760.0, 80.0)]
            lv.ents = [
                # 1 层→2 层：跳板
                bouncepad(400.0, 590.0, 720.0),
                plat(330.0, 430.0, 180.0),
                # 2 层→3 层：消失浮板
                crumbleplat(600.0, 400.0, 80.0, 2.2),
                crumbleplat(760.0, 380.0, 80.0, 2.2),
                plat(880.0, 300.0, 180.0),
                # 3 层→4 层：留守压板上顶层
                plate(920.0, 266.0, "pT", "n"),
                elev(1100.0, 480.0, 180.0, 480.0, ["pT"]),
                # 4 层
                plat(1050.0, 180.0, 260.0),
                gemdoor(1180.0, 180.0, 1, 1),
                gem(640.0, 370.0, "r"), gem(800.0, 350.0, "b"),
                gem(1140.0, 150.0, "r"), gem(1240.0, 150.0, "b"),
            ]
        # ========== 第 16 关｜多机关混合试炼：28×18，四段任务 ==========
        16:
            lv.name = "16 混合试炼"
            lv.map_w = 1540.0
            lv.map_h = 900.0
            lv.floors = [seg(0.0, 1540.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(130, 550)
            lv.pools = [pool("fire", 700.0, 80.0), pool("water", 840.0, 80.0), pool("fire", 1100.0, 70.0), pool("water", 1200.0, 70.0)]
            lv.ents = [
                # ①推箱开门
                block(280.0, 558.0),
                plate(460.0, 596.0, "p1", "n"),
                door(580.0, 444.0, 160.0, ["p1"]),
                # ②跳板上中层
                bouncepad(760.0, 590.0, 780.0),
                plat(700.0, 380.0, 170.0),
                # ③消失浮板跨池
                crumbleplat(940.0, 360.0, 80.0, 2.0),
                crumbleplat(1080.0, 360.0, 80.0, 2.0),
                # ④终点
                plat(1300.0, 340.0, 200.0),
                gemdoor(1400.0, 340.0, 1, 1),
                gem(980.0, 320.0, "r"), gem(1120.0, 320.0, "b"),
                gem(700.0, 550.0, "r"), gem(840.0, 550.0, "b"),
            ]
        # ========== 第 17 关｜最终神殿：30×20，全机关 5 阶段 ==========
        17:
            lv.name = "17 最终神殿"
            lv.map_w = 1650.0
            lv.map_h = 1000.0
            lv.floors = [seg(0.0, 1650.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(130, 550)
            lv.pools = [pool("fire", 650.0, 90.0), pool("water", 800.0, 90.0), pool("fire", 1050.0, 80.0), pool("water", 1180.0, 80.0), pool("shallow", 1420.0, 60.0)]
            lv.ents = [
                # 阶段1：双人分工压板（双按钮同时踩）
                plate(350.0, 596.0, "p1", "n"),
                plate(500.0, 596.0, "p2", "n"),
                door(620.0, 444.0, 160.0, ["p1", "p2"]),
                # 阶段2：跳板登二层 + 连续消失浮板
                bouncepad(800.0, 590.0, 800.0),
                plat(740.0, 370.0, 160.0),
                crumbleplat(960.0, 350.0, 80.0, 2.0),
                crumbleplat(1110.0, 350.0, 80.0, 2.0),
                # 阶段3：分岔——火娃融冰墙 / 冰娃灭火墙
                plat(1250.0, 350.0, 400.0),
                elewall(1420.0, 224.0, 24.0, 130.0, "ice"),
                elewall(1520.0, 224.0, 24.0, 130.0, "fire"),
                # 阶段4：汇合中央高台
                plat(1450.0, 190.0, 200.0),
                # 终点双门
                gemdoor(1520.0, 190.0, 1, 1),
                gem(990.0, 310.0, "r"), gem(1140.0, 310.0, "b"),
                gem(1480.0, 550.0, "r"), gem(1520.0, 550.0, "b"),
                checkpoint(700.0, 556.0),
            ]
    return lv
