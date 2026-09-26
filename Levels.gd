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

static func build(n: int) -> Dictionary:
    var lv := {"name": "", "floors": [seg(0.0, 1280.0)], "plats": [], "pools": [], "ents": [], "spawnE": Vector2(70, 550), "spawnT": Vector2(130, 550), "map_w": 1280.0}
    match n:
        # ================= 第一章 森林神殿（1-10）：map_w 1280 单屏小房间 =================
        1:
            lv.name = "F1 相克初识"
            lv.pools = [pool("fire", 520.0, 130.0)]
            lv.ents = [
                gem(585.0, 550.0, "r"), gem(1000.0, 550.0, "b"),
                gemdoor(1120.0, 604.0),
            ]
        2:
            lv.name = "F2 各走各路"
            lv.pools = [pool("fire", 430.0, 110.0), pool("water", 700.0, 110.0)]
            lv.ents = [
                gem(485.0, 550.0, "r"), gem(755.0, 550.0, "b"),
                gemdoor(1120.0, 604.0),
            ]
        3:
            lv.name = "F3 踏板与门"
            lv.plats = [plat(430.0, 460.0, 90.0)]
            lv.ents = [
                plate(330.0, 596.0, "p1", "n"),
                door(560.0, 444.0, 160.0, ["p1"]),
                gem(760.0, 550.0, "r"), gem(820.0, 550.0, "b"),
                gemdoor(1120.0, 604.0),
            ]
        4:
            lv.name = "F4 跃过水洼"
            lv.pools = [pool("shallow", 470.0, 90.0), pool("shallow", 680.0, 110.0)]
            lv.plats = [plat(600.0, 520.0, 50.0)]
            lv.ents = [
                gem(625.0, 490.0, "r"), gem(940.0, 550.0, "b"),
                gemdoor(1120.0, 604.0),
            ]
        5:
            lv.name = "F5 双池相间"
            lv.pools = [pool("fire", 420.0, 100.0), pool("water", 640.0, 100.0), pool("fire", 860.0, 100.0)]
            lv.ents = [
                gem(470.0, 550.0, "r"), gem(690.0, 550.0, "b"),
                gemdoor(1120.0, 604.0),
            ]
        6:
            lv.name = "F6 金色踏板"
            lv.plats = [plat(430.0, 460.0, 90.0)]
            lv.ents = [
                plate(330.0, 596.0, "p1", "f"),
                door(560.0, 444.0, 160.0, ["p1"]),
                gem(880.0, 550.0, "r"), gem(940.0, 550.0, "b"),
                gemdoor(1120.0, 604.0),
            ]
        7:
            lv.name = "F7 石块初推"
            lv.pools = [pool("shallow", 560.0, 160.0)]
            lv.ents = [
                block(300.0, 558.0),
                gem(500.0, 550.0, "r"), gem(1000.0, 550.0, "b"),
                gemdoor(1120.0, 604.0),
            ]
        8:
            lv.name = "F8 石块压板"
            lv.plats = [plat(460.0, 500.0, 120.0)]
            lv.ents = [
                block(500.0, 454.0),
                plate(580.0, 596.0, "p1", "n"),
                door(720.0, 444.0, 160.0, ["p1"]),
                gem(660.0, 550.0, "r"), gem(980.0, 550.0, "b"),
                gemdoor(1120.0, 604.0),
            ]
        9:
            lv.name = "F9 尖刺小径"
            lv.ents = [
                spike(500.0, 590.0, 80.0, false, ""),
                spike(680.0, 590.0, 80.0, false, ""),
                plat(600.0, 505.0, 50.0),
                gem(625.0, 475.0, "r"), gem(950.0, 550.0, "b"),
                gemdoor(1120.0, 604.0),
            ]
        10:
            lv.name = "F10 森林之心"
            lv.pools = [pool("fire", 380.0, 90.0), pool("shallow", 560.0, 90.0), pool("water", 740.0, 90.0)]
            lv.ents = [
                plate(960.0, 596.0, "p1", "n"),
                door(1040.0, 444.0, 160.0, ["p1"]),
                gem(430.0, 550.0, "r"), gem(790.0, 550.0, "b"),
                gemdoor(1180.0, 604.0),
            ]
        # ================= 第二章 冰神殿（11-20）：map_w 1920 两段式 =================
        11:
            lv.name = "I11 双厅相望"
            lv.map_w = 1920.0
            lv.floors = [seg(0.0, 1920.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1850, 550)
            lv.pools = [pool("fire", 430.0, 150.0), pool("water", 1420.0, 150.0)]
            lv.plats = [plat(700.0, 500.0, 120.0), plat(1100.0, 500.0, 120.0)]
            lv.ents = [
                gem(760.0, 470.0, "r"), gem(1160.0, 470.0, "b"),
                gem(480.0, 550.0, "r"), gem(1330.0, 550.0, "b"),
                gemdoor(950.0, 604.0, 2, 2),
            ]
        12:
            lv.name = "I12 留守接力"
            lv.map_h = 820.0
            lv.map_w = 1920.0
            lv.floors = [seg(0.0, 880.0), pit(880.0, 1040.0), seg(1040.0, 1920.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1850, 550)
            lv.ents = [
                plate(330.0, 596.0, "p1", "n"),
                door(560.0, 444.0, 160.0, ["p1"]),
                block(720.0, 558.0),
                plate(1160.0, 596.0, "p2", "f"),
                door(1300.0, 444.0, 160.0, ["p2"]),
                gem(820.0, 550.0, "r"), gem(1420.0, 550.0, "b"),
                gem(1100.0, 550.0, "r"), gem(1180.0, 550.0, "b"),
                gemdoor(1700.0, 604.0, 2, 2),
            ]
        13:
            lv.name = "I13 石填双洼"
            lv.map_w = 1920.0
            lv.floors = [seg(0.0, 1920.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1850, 550)
            lv.pools = [pool("shallow", 560.0, 140.0), pool("shallow", 900.0, 140.0)]
            lv.ents = [
                block(300.0, 558.0), block(1500.0, 558.0),
                gem(830.0, 550.0, "r"), gem(790.0, 550.0, "b"),
                gem(1100.0, 550.0, "r"), gem(1200.0, 550.0, "b"),
                gemdoor(1700.0, 604.0, 2, 2),
            ]
        14:
            lv.name = "I14 滑台连廊"
            lv.map_w = 1920.0
            lv.floors = [seg(0.0, 350.0), seg(1600.0, 1920.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1850, 550)
            lv.pools = [pool("shallow", 350.0, 1250.0)]
            lv.ents = [
                mover(100.0, 500.0, 100.0, 420.0, 85.0, 0.0),
                mover(700.0, 470.0, 680.0, 1000.0, 95.0, 1.4),
                mover(1350.0, 500.0, 1330.0, 1560.0, 90.0, 2.6),
                gem(430.0, 460.0, "r"), gem(800.0, 430.0, "b"),
                gem(1450.0, 460.0, "r"), gem(230.0, 550.0, "b"),
                gemdoor(1750.0, 604.0, 2, 2),
            ]
        15:
            lv.name = "I15 高低分支"
            lv.map_h = 820.0
            lv.map_w = 1920.0
            lv.floors = [seg(0.0, 1920.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1850, 550)
            lv.plats = [plat(400.0, 470.0, 140.0), plat(900.0, 470.0, 140.0), plat(1300.0, 400.0, 120.0)]
            lv.ents = [
                plate(700.0, 596.0, "p1", "n"),
                door(640.0, 444.0, 160.0, ["p1"]),
                gem(460.0, 440.0, "r"), gem(960.0, 440.0, "b"),
                gem(1350.0, 370.0, "r"), gem(1500.0, 550.0, "b"),
                gemdoor(1750.0, 604.0, 2, 2),
            ]
        16:
            lv.name = "I16 双石架桥"
            lv.map_w = 1920.0
            lv.floors = [seg(0.0, 1920.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1850, 550)
            lv.pools = [pool("shallow", 500.0, 130.0), pool("shallow", 820.0, 130.0), pool("shallow", 1150.0, 130.0)]
            lv.ents = [
                block(280.0, 558.0), block(1620.0, 558.0),
                plat(700.0, 520.0, 60.0), plat(1020.0, 520.0, 60.0),
                gem(730.0, 490.0, "r"), gem(740.0, 550.0, "b"),
                gem(1050.0, 490.0, "r"), gem(1250.0, 550.0, "b"),
                gemdoor(1750.0, 604.0, 2, 2),
            ]
        17:
            lv.name = "I17 冰面电梯"
            lv.map_h = 900.0
            lv.map_w = 1920.0
            lv.floors = [seg(0.0, 800.0), seg(1920.0 - 520.0, 520.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1850, 550)
            lv.pools = [pool("water", 800.0, 620.0)]
            lv.ents = [
                elev(400.0, 540.0, 320.0, 540.0, ["p1"]),
                plate(300.0, 596.0, "p1", "n"),
                plat(430.0, 360.0, 100.0), plat(560.0, 360.0, 100.0),
                gem(480.0, 330.0, "r"), gem(600.0, 330.0, "b"),
                gem(1500.0, 550.0, "r"), gem(1440.0, 550.0, "b"),
                gemdoor(1780.0, 604.0, 2, 2),
            ]
        18:
            lv.name = "I18 弹刺长廊"
            lv.map_w = 1920.0
            lv.floors = [seg(0.0, 1920.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1850, 550)
            lv.ents = [
                timer("t1", 3.0, 0.5, 0.0),
                timer("t2", 3.0, 0.5, 1.5),
                spike(480.0, 590.0, 120.0, true, "t1"),
                spike(760.0, 590.0, 120.0, true, "t2"),
                spike(1100.0, 590.0, 120.0, true, "t1"),
                plat(650.0, 500.0, 60.0), plat(980.0, 500.0, 60.0),
                gem(680.0, 470.0, "r"), gem(1010.0, 470.0, "b"),
                gem(350.0, 550.0, "r"), gem(1500.0, 550.0, "b"),
                gemdoor(1780.0, 604.0, 2, 2),
            ]
        19:
            lv.name = "I19 支路汇流"
            lv.map_w = 1920.0
            lv.floors = [seg(0.0, 1920.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1850, 550)
            lv.pools = [pool("fire", 400.0, 120.0), pool("water", 1440.0, 120.0)]
            lv.plats = [plat(620.0, 490.0, 70.0), plat(800.0, 440.0, 70.0), plat(1000.0, 490.0, 70.0)]
            lv.ents = [
                gem(655.0, 460.0, "r"), gem(835.0, 410.0, "b"),
                gem(1035.0, 460.0, "r"), gem(470.0, 550.0, "b"),
                gemdoor(1750.0, 604.0, 2, 2),
            ]
        20:
            lv.name = "I20 冰殿之心"
            lv.map_w = 1920.0
            lv.floors = [seg(0.0, 700.0), pit(700.0, 900.0), seg(900.0, 1920.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1850, 550)
            lv.pools = [pool("shallow", 1000.0, 350.0)]
            lv.ents = [
                block(240.0, 558.0), block(560.0, 558.0),
                mover(950.0, 480.0, 930.0, 1280.0, 100.0, 0.8),
                plate(150.0, 596.0, "p1", "n"),
                door(340.0, 444.0, 160.0, ["p1"]),
                gem(1080.0, 450.0, "r"), gem(640.0, 550.0, "b"),
                gem(1500.0, 550.0, "r"), gem(300.0, 550.0, "b"),
                gemdoor(1700.0, 604.0, 2, 2),
            ]
        # ================= 第三章 火神殿（21-30）：map_w 2560 多房间 =================
        21:
            lv.name = "H21 红蓝分厅"
            lv.map_w = 2560.0
            lv.floors = [seg(0.0, 1000.0), seg(1560.0, 2560.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(2490, 550)
            lv.pools = [pool("shallow", 1000.0, 560.0)]
            lv.ents = [
                portal(200.0, 540.0, 2300.0, 540.0, "r"),
                portal(2360.0, 540.0, 300.0, 540.0, "b"),
                plat(600.0, 500.0, 110.0), plat(1900.0, 500.0, 110.0),
                gem(655.0, 470.0, "r"), gem(1955.0, 470.0, "b"),
                gem(880.0, 550.0, "r"), gem(1700.0, 550.0, "b"),
                gemdoor(1280.0, 604.0, 2, 2),
            ]
        22:
            lv.name = "H22 旋转长廊"
            lv.map_w = 2560.0
            lv.floors = [seg(0.0, 500.0), seg(2060.0, 2560.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(2490, 550)
            lv.pools = [pool("shallow", 500.0, 1560.0)]
            lv.ents = [
                plate(220.0, 596.0, "p1", "n"),
                rotator(900.0, 480.0, 150.0, "p1"),
                rotator(1650.0, 460.0, 130.0, "p1"),
                plat(2280.0, 480.0, 90.0),
                gem(900.0, 340.0, "r"), gem(1650.0, 330.0, "b"),
                gem(400.0, 540.0, "r"), gem(2380.0, 540.0, "b"),
                gemdoor(2400.0, 604.0, 2, 2),
            ]
        23:
            lv.name = "H23 火娃专线"
            lv.map_w = 2560.0
            lv.floors = [seg(0.0, 2560.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(2490, 550)
            lv.ents = [
                elewall(700.0, 344.0, 26.0, 260.0, "ice"),
                wall(790.0, 344.0, 16.0, 260.0),
                elewall(1300.0, 344.0, 26.0, 260.0, "ice"),
                wall(1390.0, 344.0, 16.0, 260.0),
                door(1700.0, 444.0, 160.0, ["p1"]),
                plate(1600.0, 596.0, "p1", "n"),
                gem(1000.0, 550.0, "r"), gem(1500.0, 550.0, "r"),
                gem(1050.0, 550.0, "b"), gem(1900.0, 550.0, "b"),
                gemdoor(2400.0, 604.0, 2, 2),
            ]
        24:
            lv.name = "H24 冰娃专线"
            lv.map_w = 2560.0
            lv.floors = [seg(0.0, 2560.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(2490, 550)
            lv.ents = [
                elewall(700.0, 344.0, 26.0, 260.0, "fire"),
                wall(790.0, 344.0, 16.0, 260.0),
                elewall(1300.0, 344.0, 26.0, 260.0, "fire"),
                wall(1390.0, 344.0, 16.0, 260.0),
                door(1700.0, 444.0, 160.0, ["p1"]),
                plate(1600.0, 596.0, "p1", "n"),
                gem(1000.0, 550.0, "b"), gem(1500.0, 550.0, "b"),
                gem(1050.0, 550.0, "r"), gem(1900.0, 550.0, "r"),
                gemdoor(2400.0, 604.0, 2, 2),
            ]
        25:
            lv.name = "H25 四墙联廊"
            lv.map_w = 2560.0
            lv.floors = [seg(0.0, 2560.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(2490, 550)
            lv.ents = [
                elewall(480.0, 344.0, 26.0, 260.0, "ice"),
                wall(550.0, 344.0, 16.0, 260.0),
                elewall(900.0, 344.0, 26.0, 260.0, "fire"),
                wall(970.0, 344.0, 16.0, 260.0),
                elewall(1300.0, 344.0, 26.0, 260.0, "ice"),
                wall(1370.0, 344.0, 16.0, 260.0),
                elewall(1700.0, 344.0, 26.0, 260.0, "fire"),
                door(2050.0, 444.0, 160.0, ["p1"]),
                plate(1950.0, 596.0, "p1", "n"),
                gem(700.0, 550.0, "r"), gem(1100.0, 550.0, "b"),
                gem(1500.0, 550.0, "r"), gem(1850.0, 550.0, "b"),
                gemdoor(2400.0, 604.0, 2, 2),
            ]
        26:
            lv.name = "H26 远端双板"
            lv.map_w = 2560.0
            lv.floors = [seg(0.0, 700.0), seg(1860.0, 2560.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(2490, 550)
            lv.pools = [pool("shallow", 700.0, 1160.0)]
            lv.ents = [
                mover(750.0, 500.0, 740.0, 1780.0, 130.0, 0.0),
                portal(400.0, 540.0, 2200.0, 540.0, "r"),
                portal(2150.0, 540.0, 340.0, 540.0, "b"),
                plate(2350.0, 596.0, "pL", "n"),
                plate(230.0, 596.0, "pR", "n"),
                door(1290.0, 444.0, 160.0, ["pL", "pR"]),
                gem(1180.0, 550.0, "r"), gem(1380.0, 550.0, "b"),
                gem(360.0, 550.0, "r"), gem(2280.0, 550.0, "b"),
                gemdoor(1290.0, 604.0, 2, 2),
            ]
        27:
            lv.name = "H27 高塔速降"
            lv.map_h = 900.0
            lv.map_w = 2560.0
            lv.floors = [seg(0.0, 2560.0)]
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(2490, 550)
            lv.plats = [plat(0.0, 300.0, 400.0), plat(560.0, 300.0, 130.0), plat(860.0, 240.0, 130.0), plat(1600.0, 350.0, 140.0)]
            lv.pools = [pool("shallow", 1150.0, 160.0), pool("fire", 2100.0, 120.0)]
            lv.ents = [
                gem(920.0, 210.0, "r"), gem(1680.0, 320.0, "b"),
                gem(240.0, 250.0, "r"), gem(2000.0, 550.0, "b"),
                gemdoor(2400.0, 604.0, 2, 2),
            ]
        28:
            lv.name = "H28 双转台渡"
            lv.map_w = 2560.0
            lv.floors = [seg(0.0, 460.0), seg(2100.0, 2560.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(2490, 550)
            lv.pools = [pool("shallow", 460.0, 1640.0)]
            lv.ents = [
                plate(150.0, 596.0, "p1", "n"),
                rotator(1000.0, 480.0, 160.0, "p1"),
                rotator(1750.0, 440.0, 130.0, "p1"),
                spike(340.0, 590.0, 50.0, false, ""),
                spike(1960.0, 590.0, 50.0, false, ""),
                plat(2200.0, 470.0, 100.0),
                gem(1000.0, 330.0, "r"), gem(1750.0, 300.0, "b"),
                gem(330.0, 540.0, "r"), gem(2420.0, 540.0, "b"),
                gemdoor(2380.0, 604.0, 2, 2),
            ]
        29:
            lv.name = "H29 黑暗矿区"
            lv.map_w = 2560.0
            lv.floors = [seg(0.0, 2560.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(2490, 550)
            lv.ents = [
                darkzone(500.0, 150.0, 1560.0, 470.0, "pl"),
                spike(900.0, 590.0, 110.0, false, ""),
                spike(1300.0, 590.0, 110.0, false, ""),
                lever(650.0, 560.0, "l1"),
                door(1080.0, 444.0, 160.0, ["l1"]),
                plate(1500.0, 596.0, "pl", "n"),
                gem(760.0, 540.0, "r"), gem(1200.0, 540.0, "b"),
                gem(300.0, 550.0, "r"), gem(2100.0, 550.0, "b"),
                gemdoor(2400.0, 604.0, 2, 2),
            ]
        30:
            lv.name = "H30 火殿之心"
            lv.map_w = 2560.0
            lv.floors = [seg(0.0, 2560.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(2490, 550)
            lv.pools = [pool("fire", 600.0, 130.0), pool("water", 1000.0, 130.0), pool("fire", 1500.0, 130.0)]
            lv.ents = [
                portal(300.0, 540.0, 2200.0, 540.0, "r"),
                portal(2260.0, 540.0, 380.0, 540.0, "b"),
                elewall(1750.0, 344.0, 26.0, 260.0, "ice"),
                elewall(1900.0, 344.0, 26.0, 260.0, "fire"),
                plat(1850.0, 480.0, 120.0),
                gem(900.0, 550.0, "r"), gem(1350.0, 550.0, "b"),
                gem(1820.0, 450.0, "r"), gem(2100.0, 550.0, "b"),
                gemdoor(2400.0, 604.0, 2, 2),
            ]
        # ================= 第四章 光明神殿（31-40）：map_w 3200 立体复合 =================
        31:
            lv.name = "L31 三层立体"
            lv.map_h = 900.0
            lv.map_w = 3200.0
            lv.floors = [seg(0.0, 500.0), seg(1150.0, 2050.0), seg(2700.0, 3200.0)]
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(3130, 550)
            lv.plats = [plat(0.0, 300.0, 420.0), plat(2200.0, 300.0, 400.0), plat(1400.0, 200.0, 400.0)]
            lv.pools = [pool("shallow", 500.0, 650.0), pool("shallow", 2050.0, 650.0)]
            lv.ents = [
                gem(1550.0, 170.0, "r"), gem(1750.0, 170.0, "b"),
                gem(180.0, 250.0, "r"), gem(2950.0, 250.0, "b"),
                gem(1450.0, 550.0, "r"), gem(2350.0, 550.0, "b"),
                gemdoor(1900.0, 604.0, 3, 3),
            ]
        32:
            lv.name = "L32 传送接力"
            lv.map_w = 3200.0
            lv.floors = [seg(0.0, 3200.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(3130, 550)
            lv.ents = [
                portal(300.0, 540.0, 2700.0, 460.0, "r"),
                portal(2900.0, 540.0, 500.0, 460.0, "b"),
                plat(2550.0, 500.0, 170.0), plat(450.0, 500.0, 170.0),
                plate(2700.0, 466.0, "p1", "f"),
                plate(490.0, 466.0, "p2", "f"),
                door(1600.0, 444.0, 160.0, ["p1", "p2"]),
                gem(2600.0, 470.0, "r"), gem(545.0, 470.0, "b"),
                gem(1400.0, 550.0, "r"), gem(1800.0, 550.0, "b"),
                gemdoor(1600.0, 604.0, 3, 3),
            ]
        33:
            lv.name = "L33 尖刺迷宫"
            lv.map_w = 3200.0
            lv.floors = [seg(0.0, 3200.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(3130, 550)
            lv.ents = [
                timer("t1", 2.2, 0.5, 0.0),
                timer("t2", 2.2, 0.5, 1.1),
                spike(500.0, 590.0, 120.0, true, "t1"),
                spike(850.0, 590.0, 120.0, true, "t2"),
                spike(1200.0, 590.0, 120.0, true, "t1"),
                spike(1900.0, 590.0, 120.0, true, "t2"),
                spike(2250.0, 590.0, 120.0, true, "t1"),
                plat(700.0, 490.0, 70.0), plat(1550.0, 490.0, 70.0), plat(2450.0, 490.0, 70.0),
                gem(735.0, 460.0, "r"), gem(1585.0, 460.0, "b"),
                gem(2485.0, 460.0, "r"), gem(1800.0, 550.0, "b"),
                gemdoor(3050.0, 604.0, 3, 3),
            ]
        34:
            lv.name = "L34 双转台渡"
            lv.map_w = 3200.0
            lv.floors = [seg(0.0, 420.0), seg(2780.0, 3200.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(3130, 550)
            lv.pools = [pool("shallow", 420.0, 2360.0)]
            lv.ents = [
                plate(130.0, 596.0, "p1", "n"),
                rotator(800.0, 480.0, 150.0, "p1"),
                rotator(1600.0, 440.0, 140.0, "p1"),
                rotator(2400.0, 480.0, 150.0, "p1"),
                plat(2700.0, 460.0, 90.0),
                gem(800.0, 340.0, "r"), gem(1600.0, 300.0, "b"),
                gem(2400.0, 340.0, "r"), gem(300.0, 540.0, "b"),
                gemdoor(3050.0, 604.0, 3, 3),
            ]
        35:
            lv.name = "L35 暗殿回环"
            lv.map_w = 3200.0
            lv.floors = [seg(0.0, 3200.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(3130, 550)
            lv.ents = [
                darkzone(600.0, 150.0, 2000.0, 470.0, "pl"),
                lever(400.0, 560.0, "l1"),
                door(900.0, 444.0, 160.0, ["l1"]),
                portal(1400.0, 540.0, 2500.0, 540.0, "r"),
                portal(1500.0, 540.0, 800.0, 540.0, "b"),
                plate(2900.0, 596.0, "pl", "n"),
                spike(1100.0, 590.0, 90.0, false, ""),
                spike(1900.0, 590.0, 90.0, false, ""),
                gem(1000.0, 540.0, "r"), gem(2000.0, 540.0, "b"),
                gem(2900.0, 540.0, "r"), gem(400.0, 540.0, "b"),
                gemdoor(3050.0, 604.0, 3, 3),
            ]
        36:
            lv.name = "L36 墙外有墙"
            lv.map_w = 3200.0
            lv.floors = [seg(0.0, 3200.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(3130, 550)
            lv.ents = [
                elewall(600.0, 344.0, 26.0, 260.0, "ice"),
                wall(670.0, 344.0, 16.0, 260.0),
                elewall(1000.0, 344.0, 26.0, 260.0, "fire"),
                wall(1070.0, 344.0, 16.0, 260.0),
                elewall(1400.0, 344.0, 26.0, 260.0, "ice"),
                wall(1470.0, 344.0, 16.0, 260.0),
                elewall(1800.0, 344.0, 26.0, 260.0, "fire"),
                wall(1870.0, 344.0, 16.0, 260.0),
                elewall(2200.0, 344.0, 26.0, 260.0, "ice"),
                door(2600.0, 444.0, 160.0, ["p1"]),
                plate(2500.0, 596.0, "p1", "n"),
                gem(800.0, 550.0, "r"), gem(1200.0, 550.0, "b"),
                gem(1600.0, 550.0, "r"), gem(2000.0, 550.0, "b"),
                gemdoor(3000.0, 604.0, 3, 3),
            ]
        37:
            lv.name = "L37 连锁三器"
            lv.map_w = 3200.0
            lv.floors = [seg(0.0, 3200.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(3130, 550)
            lv.ents = [
                beam(400.0, 470.0, "E", "sig", false, []),
                mirror(900.0, 470.0, false),
                mirror(1500.0, 380.0, false),
                recv(1500.0, 240.0, "r1"),
                block(2000.0, 558.0),
                plate(2200.0, 596.0, "p1", "n"),
                chain("c1", ["r1", "p1"]),
                door(2600.0, 444.0, 160.0, ["c1"]),
                gem(900.0, 430.0, "r"), gem(1600.0, 550.0, "b"),
                gem(300.0, 550.0, "r"), gem(2900.0, 550.0, "b"),
                gemdoor(3000.0, 604.0, 3, 3),
            ]
        38:
            lv.name = "L38 立体回环"
            lv.map_h = 900.0
            lv.map_w = 3200.0
            lv.floors = [seg(0.0, 700.0), seg(1200.0, 2000.0), seg(2500.0, 3200.0)]
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(3130, 550)
            lv.plats = [plat(0.0, 300.0, 420.0), plat(1300.0, 300.0, 150.0), plat(1800.0, 240.0, 150.0), plat(2550.0, 300.0, 650.0)]
            lv.pools = [pool("fire", 700.0, 100.0), pool("shallow", 950.0, 100.0), pool("water", 2050.0, 130.0), pool("shallow", 2200.0, 100.0)]
            lv.ents = [
                elewall(560.0, 344.0, 26.0, 200.0, "ice"),
                elev(180.0, 540.0, 300.0, 540.0, ["p1"]),
                plate(80.0, 596.0, "p1", "n"),
                portal(1900.0, 210.0, 2750.0, 540.0, "b"),
                portal(2850.0, 260.0, 1350.0, 540.0, "r"),
                gem(1880.0, 210.0, "r"), gem(1150.0, 270.0, "b"),
                gem(2850.0, 550.0, "r"), gem(500.0, 550.0, "b"),
                gemdoor(2350.0, 604.0, 3, 3),
            ]
        39:
            lv.name = "L39 顺序即解"
            lv.map_w = 3200.0
            lv.floors = [seg(0.0, 3200.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(3130, 550)
            lv.ents = [
                block(300.0, 558.0),
                plate(480.0, 596.0, "p1", "n"),
                door(640.0, 444.0, 160.0, ["p1"]),
                timer("t1", 2.5, 0.45, 0.0),
                timer("t2", 2.5, 0.45, 1.25),
                spike(850.0, 590.0, 120.0, true, "t1"),
                spike(1150.0, 590.0, 120.0, true, "t2"),
                spike(1750.0, 590.0, 120.0, true, "t1"),
                plate(2000.0, 596.0, "p2", "f"),
                door(2150.0, 444.0, 160.0, ["p2"]),
                gem(1000.0, 540.0, "r"), gem(1500.0, 540.0, "b"),
                gem(400.0, 540.0, "r"), gem(2500.0, 550.0, "b"),
                gemdoor(2850.0, 604.0, 3, 3),
            ]
        40:
            lv.name = "L40 光明之心"
            lv.map_h = 900.0
            lv.map_w = 3200.0
            lv.floors = [seg(0.0, 900.0), seg(1250.0, 2100.0), seg(2450.0, 3200.0)]
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(3130, 550)
            lv.plats = [plat(0.0, 300.0, 430.0), plat(1350.0, 300.0, 160.0), plat(1900.0, 240.0, 160.0), plat(2500.0, 300.0, 700.0)]
            lv.pools = [pool("fire", 500.0, 80.0), pool("shallow", 940.0, 80.0), pool("water", 1130.0, 90.0), pool("shallow", 2150.0, 90.0), pool("fire", 2280.0, 70.0)]
            lv.ents = [
                elewall(420.0, 344.0, 26.0, 200.0, "ice"),
                elewall(2450.0, 344.0, 26.0, 200.0, "fire"),
                spike(1450.0, 590.0, 100.0, false, ""),
                block(1650.0, 558.0),
                plate(1800.0, 596.0, "p1", "n"),
                door(2000.0, 444.0, 160.0, ["p1"]),
                elev(180.0, 540.0, 300.0, 540.0, ["p2"]),
                plate(80.0, 596.0, "p2", "n"),
                rotator(1650.0, 180.0, 100.0, "l1"),
                lever(1980.0, 232.0, "l1"),
                portal(1960.0, 210.0, 2900.0, 540.0, "r"),
                portal(2900.0, 260.0, 420.0, 540.0, "b"),
                checkpoint(1700.0, 556.0),
                gem(1500.0, 250.0, "r"), gem(1980.0, 210.0, "b"),
                gem(180.0, 250.0, "r"), gem(2950.0, 550.0, "b"),
                gem(1700.0, 550.0, "r"), gem(1800.0, 550.0, "b"),
                gemdoor(2350.0, 604.0, 3, 3),
            ]
    return lv
