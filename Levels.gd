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
    # 40 关按 v0.8 分级框架：尺寸 12×8 → 30×20 格连续递增（每关约 +0.5 格宽 / +0.3 格高），
    # 1 关 1 新机关、旧机关复用；宝石 1+1 → 2+2 → 3+3；分路从同行到留守到长分头。
    # 换算：宽 px = 格数*55、高 px = 格数*45（地面线 y=604）。
    var lv := {"name": "", "floors": [seg(0.0, 1280.0)], "plats": [], "pools": [], "ents": [], "spawnE": Vector2(70, 550), "spawnT": Vector2(130, 550), "map_w": 1280.0, "map_h": 720.0}
    match n:
        # ---------- 简单档 1-10：单房间，机关≤2 种，宝石 1+1，几乎不分路 ----------
        1:
            lv.name = "1 森林入口"
            lv.map_w = 660.0
            lv.map_h = 500.0
            lv.floors = [seg(0.0, 320.0), seg(360.0, 660.0)]
            lv.spawnE = Vector2(610, 550)
            lv.spawnT = Vector2(80, 550)
            lv.ents = [gemdoor(40.0, 604.0), gemdoor(620.0, 604.0)]
        2:
            lv.name = "2 分隔浅沟"
            lv.map_w = 715.0
            lv.map_h = 510.0
            lv.floors = [seg(0.0, 330.0), seg(440.0, 715.0)]
            lv.pools = [pool("shallow", 330.0, 110.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(660, 550)
            lv.ents = [gemdoor(60.0, 604.0), gemdoor(665.0, 604.0)]
        3:
            lv.name = "3 双色水池初识"
            lv.map_w = 770.0
            lv.map_h = 510.0
            lv.floors = [seg(0.0, 300.0), seg(500.0, 770.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(715, 550)
            lv.pools = [pool("fire", 300.0, 200.0), pool("water", 300.0, 200.0)]
            lv.ents = [gemdoor(60.0, 604.0), gemdoor(715.0, 604.0)]
        4:
            lv.name = "4 单向跳板初体验"
            lv.map_w = 825.0
            lv.map_h = 540.0
            lv.floors = [seg(0.0, 825.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(130, 550)
            lv.pools = [pool("fire", 520.0, 70.0), pool("water", 630.0, 70.0)]
            lv.ents = [
                bouncepad(380.0, 590.0, 780.0),
                plat(300.0, 320.0, 220.0),
                gemdoor(400.0, 320.0, 1, 1),
                gem(420.0, 280.0, "r"), gem(470.0, 280.0, "b"),
            ]
        5:
            lv.name = "5 按钮与门"
            lv.map_w = 880.0
            lv.map_h = 540.0
            lv.floors = [seg(0.0, 880.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(130, 550)
            lv.pools = [pool("fire", 640.0, 70.0), pool("water", 740.0, 70.0)]
            lv.ents = [
                plate(350.0, 596.0, "p1", "n"),
                door(520.0, 444.0, 160.0, ["p1"]),
                gemdoor(800.0, 604.0, 1, 1),
                gem(760.0, 550.0, "r"), gem(790.0, 550.0, "b"),
            ]
        6:
            lv.name = "6 推箱子压按钮"
            lv.map_w = 935.0
            lv.map_h = 550.0
            lv.floors = [seg(0.0, 935.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(130, 550)
            lv.pools = [pool("fire", 740.0, 70.0), pool("water", 840.0, 70.0)]
            lv.ents = [
                block(300.0, 558.0),
                plate(500.0, 596.0, "p1", "n"),
                door(640.0, 444.0, 160.0, ["p1"]),
                gemdoor(870.0, 604.0, 1, 1),
                gem(820.0, 550.0, "r"), gem(855.0, 550.0, "b"),
            ]
        7:
            lv.name = "7 交错水池"
            lv.map_w = 1045.0
            lv.map_h = 560.0
            lv.floors = [seg(0.0, 1045.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(990, 550)
            lv.pools = [pool("fire", 210.0, 85.0), pool("water", 345.0, 85.0), pool("fire", 580.0, 85.0), pool("water", 715.0, 85.0)]
            lv.plats = [plat(275.0, 520.0, 60.0), plat(625.0, 520.0, 60.0)]
            lv.ents = [
                gemdoor(70.0, 604.0, 1, 1), gemdoor(985.0, 604.0, 1, 1),
                gem(580.0, 550.0, "r"), gem(715.0, 550.0, "b"),
            ]
        8:
            lv.name = "8 高低台跳板"
            lv.map_w = 1045.0
            lv.map_h = 780.0
            lv.floors = [seg(0.0, 1045.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(130, 550)
            lv.pools = [pool("fire", 500.0, 75.0), pool("water", 655.0, 75.0)]
            lv.ents = [
                bouncepad(310.0, 590.0, 700.0),
                plat(250.0, 430.0, 160.0),
                bouncepad(580.0, 420.0, 760.0),
                plat(520.0, 250.0, 180.0),
                gemdoor(580.0, 250.0, 1, 1),
                gem(540.0, 210.0, "r"), gem(620.0, 210.0, "b"),
            ]
        9:
            lv.name = "9 双按钮双门"
            lv.map_w = 1155.0
            lv.map_h = 580.0
            lv.floors = [seg(0.0, 1155.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1100, 550)
            lv.ents = [
                wall(570.0, 240.0, 20.0, 364.0),
                plate(300.0, 596.0, "pA", "n"),
                door(430.0, 444.0, 160.0, ["pA"]),
                block(760.0, 558.0),
                plate(900.0, 596.0, "pB", "n"),
                door(1010.0, 444.0, 160.0, ["pB"]),
                gemdoor(80.0, 604.0, 1, 1), gemdoor(1090.0, 604.0, 1, 1),
                gem(540.0, 550.0, "r"), gem(680.0, 550.0, "b"),
            ]
        10:
            lv.name = "10 消失浮板"
            lv.map_w = 1210.0
            lv.map_h = 580.0
            lv.floors = [seg(0.0, 290.0), seg(920.0, 1210.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1160, 550)
            lv.pools = [pool("fire", 290.0, 315.0), pool("water", 605.0, 315.0)]
            lv.ents = [
                crumbleplat(330.0, 560.0, 90.0, 2.2),
                crumbleplat(475.0, 540.0, 90.0, 2.2),
                crumbleplat(620.0, 560.0, 90.0, 2.2),
                crumbleplat(765.0, 540.0, 90.0, 2.2),
                gemdoor(60.0, 604.0, 1, 1), gemdoor(1155.0, 604.0, 1, 1),
                gem(450.0, 500.0, "r"), gem(700.0, 500.0, "b"),
            ]
        # ---------- 中档 11-20：两房间，组合机关，宝石 2+2，短时分路 ----------
        11:
            lv.name = "11 长廊推箱"
            lv.map_w = 1265.0
            lv.map_h = 600.0
            lv.floors = [seg(0.0, 1265.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1215, 550)
            lv.pools = [pool("fire", 570.0, 60.0), pool("water", 690.0, 60.0), pool("shallow", 990.0, 70.0)]
            lv.ents = [
                block(300.0, 558.0), block(380.0, 558.0), block(1150.0, 558.0),
                plate(500.0, 596.0, "p1", "n"),
                door(620.0, 444.0, 160.0, ["p1"]),
                plate(870.0, 596.0, "p2", "n"),
                door(1080.0, 444.0, 160.0, ["p2"]),
                gemdoor(70.0, 604.0, 2, 2), gemdoor(1215.0, 604.0, 2, 2),
                gem(770.0, 550.0, "r"), gem(900.0, 550.0, "b"),
            ]
        12:
            lv.name = "12 跳板接浮板"
            lv.map_w = 1265.0
            lv.map_h = 850.0
            lv.floors = [seg(0.0, 1265.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1215, 550)
            lv.pools = [pool("fire", 420.0, 110.0), pool("water", 640.0, 110.0), pool("fire", 880.0, 100.0), pool("water", 1080.0, 100.0)]
            lv.ents = [
                bouncepad(250.0, 590.0, 820.0),
                plat(180.0, 330.0, 150.0),
                crumbleplat(400.0, 320.0, 80.0, 2.0),
                crumbleplat(560.0, 320.0, 80.0, 2.0),
                plat(700.0, 300.0, 150.0),
                crumbleplat(900.0, 320.0, 80.0, 2.0),
                crumbleplat(1050.0, 320.0, 80.0, 2.0),
                plat(1180.0, 300.0, 140.0),
                gemdoor(1240.0, 300.0, 2, 2),
                gem(440.0, 280.0, "r"), gem(940.0, 280.0, "b"),
                gem(200.0, 550.0, "r"), gem(1150.0, 550.0, "b"),
            ]
        13:
            lv.name = "13 分头开锁"
            lv.map_w = 1375.0
            lv.map_h = 850.0
            lv.floors = [seg(0.0, 1375.0)]
            lv.spawnE = Vector2(660, 550)
            lv.spawnT = Vector2(780, 550)
            lv.pools = [pool("fire", 250.0, 70.0), pool("water", 1150.0, 70.0)]
            lv.ents = [
                wall(640.0, 300.0, 16.0, 304.0),
                wall(790.0, 300.0, 16.0, 304.0),
                block(180.0, 558.0),
                plate(380.0, 596.0, "pL", "n"),
                door(500.0, 444.0, 160.0, ["pL"]),
                bouncepad(1000.0, 590.0, 760.0),
                plat(940.0, 400.0, 150.0),
                plate(990.0, 366.0, "pR", "n"),
                door(1210.0, 444.0, 160.0, ["pR"]),
                door(714.0, 444.0, 160.0, ["pL", "pR"]),
                gemdoor(1300.0, 604.0, 2, 2),
                gem(540.0, 550.0, "r"), gem(920.0, 550.0, "b"),
            ]
        14:
            lv.name = "14 元素迷宫"
            lv.map_w = 1430.0
            lv.map_h = 620.0
            lv.floors = [seg(0.0, 1430.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1370, 550)
            lv.pools = [
                pool("fire", 200.0, 90.0), pool("water", 335.0, 90.0),
                pool("fire", 570.0, 90.0), pool("water", 710.0, 90.0),
                pool("fire", 920.0, 90.0), pool("water", 1055.0, 90.0),
                pool("fire", 1255.0, 90.0),
            ]
            lv.plats = [plat(295.0, 520.0, 60.0), plat(660.0, 520.0, 60.0), plat(1010.0, 520.0, 60.0), plat(1200.0, 460.0, 95.0)]
            lv.ents = [
                gemdoor(75.0, 604.0, 2, 2), gemdoor(1355.0, 604.0, 2, 2),
                gem(710.0, 550.0, "r"), gem(1055.0, 550.0, "b"),
                gem(1200.0, 430.0, "r"), gem(570.0, 550.0, "b"),
            ]
        15:
            lv.name = "15 多层高塔"
            lv.map_w = 1430.0
            lv.map_h = 940.0
            lv.floors = [seg(0.0, 1430.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1370, 550)
            lv.pools = [pool("fire", 620.0, 80.0), pool("water", 790.0, 80.0)]
            lv.ents = [
                bouncepad(410.0, 590.0, 720.0),
                plat(340.0, 430.0, 180.0),
                crumbleplat(620.0, 400.0, 80.0, 2.2),
                crumbleplat(780.0, 380.0, 80.0, 2.2),
                plat(900.0, 300.0, 180.0),
                plate(940.0, 266.0, "pT", "n"),
                elev(1120.0, 480.0, 180.0, 480.0, ["pT"]),
                plat(1070.0, 180.0, 260.0),
                gemdoor(1200.0, 180.0, 2, 2),
                gem(660.0, 370.0, "r"), gem(820.0, 350.0, "b"),
                gem(1160.0, 150.0, "r"), gem(1260.0, 150.0, "b"),
            ]
        16:
            lv.name = "16 混合试炼"
            lv.map_w = 1485.0
            lv.map_h = 850.0
            lv.floors = [seg(0.0, 1485.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(130, 550)
            lv.pools = [pool("fire", 720.0, 80.0), pool("water", 860.0, 80.0), pool("fire", 1120.0, 70.0), pool("water", 1230.0, 70.0)]
            lv.ents = [
                block(280.0, 558.0),
                plate(460.0, 596.0, "p1", "n"),
                door(580.0, 444.0, 160.0, ["p1"]),
                bouncepad(770.0, 590.0, 780.0),
                plat(710.0, 380.0, 170.0),
                crumbleplat(950.0, 360.0, 80.0, 2.0),
                crumbleplat(1090.0, 360.0, 80.0, 2.0),
                plat(1300.0, 340.0, 200.0),
                gemdoor(1400.0, 340.0, 2, 2),
                gem(990.0, 320.0, "r"), gem(1130.0, 320.0, "b"),
                gem(700.0, 550.0, "r"), gem(840.0, 550.0, "b"),
            ]
        17:
            lv.name = "17 双墙回廊"
            lv.map_w = 1540.0
            lv.map_h = 640.0
            lv.floors = [seg(0.0, 1540.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1490, 550)
            lv.ents = [
                elewall(560.0, 344.0, 26.0, 260.0, "ice"),
                wall(630.0, 344.0, 16.0, 260.0),
                elewall(900.0, 344.0, 26.0, 260.0, "fire"),
                wall(970.0, 344.0, 16.0, 260.0),
                plate(1200.0, 596.0, "p1", "n"),
                door(1330.0, 444.0, 160.0, ["p1"]),
                gemdoor(1450.0, 604.0, 2, 2),
                gem(800.0, 550.0, "r"), gem(1100.0, 550.0, "b"),
                gem(300.0, 550.0, "r"), gem(1300.0, 550.0, "b"),
            ]
        18:
            lv.name = "18 元素双塔"
            lv.map_w = 1540.0
            lv.map_h = 900.0
            lv.floors = [seg(0.0, 500.0), seg(1040.0, 1540.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1490, 550)
            lv.pools = [pool("shallow", 500.0, 540.0)]
            lv.ents = [
                bouncepad(250.0, 590.0, 720.0),
                plat(180.0, 430.0, 160.0),
                crumbleplat(430.0, 380.0, 80.0, 2.2),
                plat(560.0, 300.0, 150.0),
                mover(760.0, 280.0, 740.0, 980.0, 100.0, 0.0),
                plat(1040.0, 300.0, 160.0),
                crumbleplat(1250.0, 380.0, 80.0, 2.2),
                plat(1380.0, 430.0, 160.0),
                gemdoor(1450.0, 604.0, 2, 2),
                gem(600.0, 270.0, "r"), gem(1420.0, 400.0, "b"),
                gem(240.0, 550.0, "r"), gem(1100.0, 550.0, "b"),
            ]
        19:
            lv.name = "19 双门谜城"
            lv.map_w = 1595.0
            lv.map_h = 660.0
            lv.floors = [seg(0.0, 1595.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1545, 550)
            lv.ents = [
                wall(780.0, 240.0, 20.0, 364.0),
                block(300.0, 558.0),
                plate(500.0, 596.0, "pA", "n"),
                door(640.0, 444.0, 160.0, ["pA"]),
                plate(1000.0, 596.0, "pB", "n"),
                door(1130.0, 444.0, 160.0, ["pB"]),
                elewall(880.0, 344.0, 26.0, 260.0, "ice"),
                gemdoor(90.0, 604.0, 2, 2), gemdoor(1520.0, 604.0, 2, 2),
                gem(700.0, 550.0, "r"), gem(900.0, 550.0, "b"),
            ]
        20:
            lv.name = "20 冰殿之心"
            lv.map_w = 1595.0
            lv.map_h = 900.0
            lv.floors = [seg(0.0, 650.0), pit(650.0, 850.0), seg(850.0, 1595.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1545, 550)
            lv.pools = [pool("shallow", 1050.0, 300.0)]
            lv.ents = [
                block(240.0, 558.0), block(420.0, 558.0),
                plate(560.0, 596.0, "p1", "n"),
                door(560.0, 444.0, 160.0, ["p1"]),
                crumbleplat(880.0, 540.0, 90.0, 2.2),
                crumbleplat(1010.0, 560.0, 90.0, 2.2),
                mover(1180.0, 470.0, 1160.0, 1420.0, 105.0, 0.6),
                gemdoor(1450.0, 604.0, 2, 2),
                gem(930.0, 500.0, "r"), gem(1050.0, 520.0, "b"),
                gem(1300.0, 440.0, "r"), gem(400.0, 550.0, "b"),
            ]
        # ---------- 高阶 21-30：多房间长分路，传送/旋转/元素墙，宝石 2+2→3+3 ----------
        21:
            lv.name = "21 红蓝分厅"
            lv.map_w = 1650.0
            lv.map_h = 700.0
            lv.floors = [seg(0.0, 650.0), seg(1000.0, 1650.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1600, 550)
            lv.pools = [pool("shallow", 650.0, 350.0)]
            lv.ents = [
                portal(200.0, 540.0, 1450.0, 540.0, "r"),
                portal(1500.0, 540.0, 250.0, 540.0, "b"),
                plat(800.0, 500.0, 130.0),
                gemdoor(820.0, 604.0, 2, 2),
                gem(860.0, 470.0, "r"), gem(760.0, 550.0, "b"),
                gem(400.0, 550.0, "r"), gem(1250.0, 550.0, "b"),
            ]
        22:
            lv.name = "22 旋转长廊"
            lv.map_w = 1650.0
            lv.map_h = 720.0
            lv.floors = [seg(0.0, 500.0), seg(1150.0, 1650.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1600, 550)
            lv.pools = [pool("shallow", 500.0, 650.0)]
            lv.ents = [
                plate(220.0, 596.0, "p1", "n"),
                rotator(830.0, 480.0, 150.0, "p1"),
                rotator(1000.0, 460.0, 120.0, "p1"),
                plat(1200.0, 480.0, 90.0),
                gemdoor(1550.0, 604.0, 2, 2),
                gem(830.0, 340.0, "r"), gem(1000.0, 330.0, "b"),
                gem(300.0, 540.0, "r"), gem(1420.0, 540.0, "b"),
            ]
        23:
            lv.name = "23 火娃专线"
            lv.map_w = 1650.0
            lv.map_h = 660.0
            lv.floors = [seg(0.0, 1650.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1600, 550)
            lv.ents = [
                elewall(700.0, 344.0, 26.0, 260.0, "ice"),
                wall(770.0, 344.0, 16.0, 260.0),
                elewall(1150.0, 344.0, 26.0, 260.0, "ice"),
                wall(1220.0, 344.0, 16.0, 260.0),
                plate(1400.0, 596.0, "p1", "n"),
                door(1480.0, 444.0, 160.0, ["p1"]),
                gemdoor(1590.0, 604.0, 2, 2),
                gem(900.0, 550.0, "r"), gem(1000.0, 550.0, "r"),
                gem(950.0, 550.0, "b"), gem(1350.0, 550.0, "b"),
                gem(300.0, 550.0, "r"), gem(550.0, 550.0, "b"),
            ]
        24:
            lv.name = "24 冰娃专线"
            lv.map_w = 1650.0
            lv.map_h = 660.0
            lv.floors = [seg(0.0, 1650.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1600, 550)
            lv.ents = [
                elewall(700.0, 344.0, 26.0, 260.0, "fire"),
                wall(770.0, 344.0, 16.0, 260.0),
                elewall(1150.0, 344.0, 26.0, 260.0, "fire"),
                wall(1220.0, 344.0, 16.0, 260.0),
                plate(1400.0, 596.0, "p1", "n"),
                door(1480.0, 444.0, 160.0, ["p1"]),
                gemdoor(1590.0, 604.0, 2, 2),
                gem(900.0, 550.0, "b"), gem(1000.0, 550.0, "b"),
                gem(950.0, 550.0, "r"), gem(1350.0, 550.0, "r"),
                gem(300.0, 550.0, "b"), gem(550.0, 550.0, "r"),
            ]
        25:
            lv.name = "25 四墙联廊"
            lv.map_w = 1650.0
            lv.map_h = 660.0
            lv.floors = [seg(0.0, 1650.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1600, 550)
            lv.ents = [
                elewall(480.0, 344.0, 26.0, 260.0, "ice"),
                wall(550.0, 344.0, 16.0, 260.0),
                elewall(780.0, 344.0, 26.0, 260.0, "fire"),
                wall(850.0, 344.0, 16.0, 260.0),
                elewall(1010.0, 344.0, 26.0, 260.0, "ice"),
                wall(1080.0, 344.0, 16.0, 260.0),
                elewall(1240.0, 344.0, 26.0, 260.0, "fire"),
                plate(1420.0, 596.0, "p1", "n"),
                door(1500.0, 444.0, 160.0, ["p1"]),
                gemdoor(1600.0, 604.0, 2, 2),
                gem(680.0, 550.0, "r"), gem(920.0, 550.0, "b"),
                gem(1150.0, 550.0, "r"), gem(350.0, 550.0, "b"),
            ]
        26:
            lv.name = "26 远端双板"
            lv.map_w = 1650.0
            lv.map_h = 700.0
            lv.floors = [seg(0.0, 450.0), seg(1200.0, 1650.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1600, 550)
            lv.pools = [pool("shallow", 450.0, 750.0)]
            lv.ents = [
                mover(500.0, 500.0, 480.0, 1180.0, 130.0, 0.0),
                portal(300.0, 540.0, 1400.0, 540.0, "r"),
                portal(1350.0, 540.0, 240.0, 540.0, "b"),
                plate(1520.0, 596.0, "pL", "n"),
                plate(150.0, 596.0, "pR", "n"),
                door(830.0, 444.0, 160.0, ["pL", "pR"]),
                gemdoor(830.0, 604.0, 2, 2),
                gem(1080.0, 550.0, "r"), gem(1280.0, 550.0, "b"),
                gem(240.0, 550.0, "r"), gem(1550.0, 550.0, "b"),
            ]
        27:
            lv.name = "27 高塔速降"
            lv.map_w = 1650.0
            lv.map_h = 880.0
            lv.floors = [seg(0.0, 1650.0)]
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(1600, 550)
            lv.plats = [plat(0.0, 300.0, 420.0), plat(600.0, 300.0, 140.0), plat(900.0, 240.0, 140.0), plat(1250.0, 350.0, 150.0)]
            lv.pools = [pool("shallow", 760.0, 100.0), pool("fire", 1080.0, 120.0)]
            lv.ents = [
                gem(960.0, 210.0, "r"), gem(1290.0, 320.0, "b"),
                gem(240.0, 250.0, "r"), gem(1420.0, 550.0, "b"),
                gemdoor(1500.0, 604.0, 2, 2),
            ]
        28:
            lv.name = "28 双转台渡"
            lv.map_w = 1650.0
            lv.map_h = 720.0
            lv.floors = [seg(0.0, 460.0), seg(1190.0, 1650.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1600, 550)
            lv.pools = [pool("shallow", 460.0, 730.0)]
            lv.ents = [
                plate(150.0, 596.0, "p1", "n"),
                rotator(820.0, 480.0, 160.0, "p1"),
                rotator(1000.0, 440.0, 130.0, "p1"),
                spike(340.0, 590.0, 50.0, false, ""),
                spike(1100.0, 590.0, 50.0, false, ""),
                plat(1250.0, 470.0, 100.0),
                gemdoor(1550.0, 604.0, 2, 2),
                gem(820.0, 340.0, "r"), gem(1000.0, 300.0, "b"),
                gem(280.0, 540.0, "r"), gem(1450.0, 540.0, "b"),
            ]
        29:
            lv.name = "29 黑暗矿区"
            lv.map_w = 1650.0
            lv.map_h = 680.0
            lv.floors = [seg(0.0, 1650.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1600, 550)
            lv.ents = [
                darkzone(550.0, 150.0, 700.0, 470.0, "pl"),
                spike(800.0, 590.0, 100.0, false, ""),
                spike(1000.0, 590.0, 100.0, false, ""),
                lever(650.0, 560.0, "l1"),
                door(900.0, 444.0, 160.0, ["l1"]),
                plate(1150.0, 596.0, "pl", "n"),
                gemdoor(1550.0, 604.0, 2, 2),
                gem(750.0, 540.0, "r"), gem(1050.0, 540.0, "b"),
                gem(300.0, 550.0, "r"), gem(1350.0, 550.0, "b"),
            ]
        30:
            lv.name = "30 火殿之心"
            lv.map_w = 1650.0
            lv.map_h = 760.0
            lv.floors = [seg(0.0, 1650.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1600, 550)
            lv.pools = [pool("fire", 600.0, 110.0), pool("water", 900.0, 110.0), pool("fire", 1200.0, 110.0)]
            lv.ents = [
                portal(300.0, 540.0, 1400.0, 540.0, "r"),
                portal(1450.0, 540.0, 350.0, 540.0, "b"),
                elewall(750.0, 344.0, 26.0, 260.0, "ice"),
                elewall(1050.0, 344.0, 26.0, 260.0, "fire"),
                plat(800.0, 480.0, 130.0),
                gemdoor(1500.0, 604.0, 3, 3),
                gem(850.0, 450.0, "r"), gem(1100.0, 450.0, "b"),
                gem(450.0, 550.0, "r"), gem(1350.0, 550.0, "b"),
                gem(250.0, 550.0, "b"), gem(1550.0, 550.0, "r"),
            ]
        # ---------- 困难档 31-40：超大立体复合，连锁+接力，宝石 3+3 ----------
        31:
            lv.name = "31 三层立体"
            lv.map_w = 1760.0
            lv.map_h = 900.0
            lv.floors = [seg(0.0, 500.0), seg(1150.0, 1760.0)]
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(1700, 550)
            lv.plats = [plat(0.0, 300.0, 420.0), plat(1300.0, 300.0, 460.0), plat(700.0, 200.0, 380.0)]
            lv.pools = [pool("shallow", 500.0, 650.0), pool("shallow", 1150.0, 300.0)]
            lv.ents = [
                gem(880.0, 170.0, "r"), gem(1000.0, 170.0, "b"),
                gem(180.0, 250.0, "r"), gem(1600.0, 250.0, "b"),
                gem(1450.0, 550.0, "r"), gem(1200.0, 550.0, "b"),
                gemdoor(1600.0, 604.0, 3, 3),
            ]
        32:
            lv.name = "32 传送接力"
            lv.map_w = 1760.0
            lv.map_h = 720.0
            lv.floors = [seg(0.0, 1760.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1700, 550)
            lv.ents = [
                portal(300.0, 540.0, 1500.0, 460.0, "r"),
                portal(1650.0, 540.0, 450.0, 460.0, "b"),
                plat(1350.0, 500.0, 170.0), plat(400.0, 500.0, 170.0),
                plate(1420.0, 466.0, "p1", "f"),
                plate(460.0, 466.0, "p2", "f"),
                door(950.0, 444.0, 160.0, ["p1", "p2"]),
                gemdoor(950.0, 604.0, 3, 3),
                gem(1400.0, 470.0, "r"), gem(500.0, 470.0, "b"),
                gem(850.0, 550.0, "r"), gem(1050.0, 550.0, "b"),
                gem(150.0, 550.0, "r"), gem(1650.0, 550.0, "b"),
            ]
        33:
            lv.name = "33 尖刺迷宫"
            lv.map_w = 1760.0
            lv.map_h = 660.0
            lv.floors = [seg(0.0, 1760.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1700, 550)
            lv.ents = [
                timer("t1", 2.2, 0.5, 0.0),
                timer("t2", 2.2, 0.5, 1.1),
                spike(500.0, 590.0, 120.0, true, "t1"),
                spike(830.0, 590.0, 120.0, true, "t2"),
                spike(1160.0, 590.0, 120.0, true, "t1"),
                plat(665.0, 490.0, 70.0), plat(995.0, 490.0, 70.0),
                gemdoor(1700.0, 604.0, 3, 3),
                gem(700.0, 460.0, "r"), gem(1030.0, 460.0, "b"),
                gem(300.0, 550.0, "r"), gem(1450.0, 550.0, "b"),
                gem(180.0, 550.0, "b"), gem(1560.0, 550.0, "r"),
            ]
        34:
            lv.name = "34 三转台渡"
            lv.map_w = 1760.0
            lv.map_h = 720.0
            lv.floors = [seg(0.0, 420.0), seg(1340.0, 1760.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1700, 550)
            lv.pools = [pool("shallow", 420.0, 920.0)]
            lv.ents = [
                plate(130.0, 596.0, "p1", "n"),
                rotator(650.0, 480.0, 150.0, "p1"),
                rotator(1050.0, 440.0, 140.0, "p1"),
                plat(1200.0, 460.0, 100.0),
                gemdoor(1650.0, 604.0, 3, 3),
                gem(650.0, 340.0, "r"), gem(1050.0, 300.0, "b"),
                gem(280.0, 540.0, "r"), gem(1500.0, 540.0, "b"),
                gem(1500.0, 500.0, "r"), gem(320.0, 500.0, "b"),
            ]
        35:
            lv.name = "35 暗殿回环"
            lv.map_w = 1760.0
            lv.map_h = 700.0
            lv.floors = [seg(0.0, 1760.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1700, 550)
            lv.ents = [
                darkzone(500.0, 150.0, 900.0, 470.0, "pl"),
                lever(350.0, 560.0, "l1"),
                door(780.0, 444.0, 160.0, ["l1"]),
                portal(1000.0, 540.0, 1450.0, 540.0, "r"),
                portal(1080.0, 540.0, 620.0, 540.0, "b"),
                plate(1550.0, 596.0, "pl", "n"),
                spike(880.0, 590.0, 90.0, false, ""),
                spike(1250.0, 590.0, 90.0, false, ""),
                gemdoor(1650.0, 604.0, 3, 3),
                gem(700.0, 540.0, "r"), gem(1150.0, 540.0, "b"),
                gem(250.0, 550.0, "r"), gem(1600.0, 540.0, "b"),
                gem(1600.0, 500.0, "r"), gem(250.0, 500.0, "b"),
            ]
        36:
            lv.name = "36 墙外有墙"
            lv.map_w = 1760.0
            lv.map_h = 660.0
            lv.floors = [seg(0.0, 1760.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1700, 550)
            lv.ents = [
                elewall(450.0, 344.0, 26.0, 260.0, "ice"),
                wall(520.0, 344.0, 16.0, 260.0),
                elewall(680.0, 344.0, 26.0, 260.0, "fire"),
                wall(750.0, 344.0, 16.0, 260.0),
                elewall(950.0, 344.0, 26.0, 260.0, "ice"),
                wall(1020.0, 344.0, 16.0, 260.0),
                elewall(1180.0, 344.0, 26.0, 260.0, "fire"),
                elewall(1340.0, 344.0, 26.0, 260.0, "ice"),
                door(1480.0, 444.0, 160.0, ["p1"]),
                plate(1420.0, 596.0, "p1", "n"),
                gemdoor(1680.0, 604.0, 3, 3),
                gem(600.0, 550.0, "r"), gem(850.0, 550.0, "b"),
                gem(1080.0, 550.0, "r"), gem(1300.0, 550.0, "b"),
                gem(250.0, 550.0, "b"), gem(1550.0, 550.0, "r"),
            ]
        37:
            lv.name = "37 连锁三器"
            lv.map_w = 1760.0
            lv.map_h = 720.0
            lv.floors = [seg(0.0, 1760.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1700, 550)
            lv.ents = [
                beam(350.0, 470.0, "E", "sig", false, []),
                mirror(750.0, 470.0, false),
                mirror(1150.0, 380.0, false),
                recv(1150.0, 240.0, "r1"),
                block(1400.0, 558.0),
                plate(1550.0, 596.0, "p1", "n"),
                chain("c1", ["r1", "p1"]),
                door(1620.0, 444.0, 160.0, ["c1"]),
                gemdoor(1700.0, 604.0, 3, 3),
                gem(750.0, 430.0, "r"), gem(1150.0, 550.0, "b"),
                gem(200.0, 550.0, "r"), gem(950.0, 550.0, "b"),
                gem(500.0, 550.0, "b"), gem(1300.0, 550.0, "r"),
            ]
        38:
            lv.name = "38 立体回环"
            lv.map_w = 1760.0
            lv.map_h = 900.0
            lv.floors = [seg(0.0, 700.0), seg(1250.0, 1760.0)]
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(1700, 550)
            lv.plats = [plat(0.0, 300.0, 430.0), plat(1350.0, 300.0, 160.0), plat(1650.0, 240.0, 110.0)]
            lv.pools = [pool("fire", 720.0, 90.0), pool("shallow", 960.0, 90.0), pool("water", 1130.0, 90.0)]
            lv.ents = [
                elewall(560.0, 344.0, 26.0, 200.0, "ice"),
                elev(180.0, 540.0, 300.0, 540.0, ["p1"]),
                plate(80.0, 596.0, "p1", "n"),
                portal(1700.0, 260.0, 1300.0, 540.0, "r"),
                portal(1750.0, 260.0, 760.0, 540.0, "b"),
                gemdoor(1400.0, 604.0, 3, 3),
                gem(1690.0, 210.0, "r"), gem(1420.0, 550.0, "b"),
                gem(180.0, 250.0, "r"), gem(500.0, 550.0, "b"),
                gem(900.0, 550.0, "r"), gem(1350.0, 260.0, "b"),
            ]
        39:
            lv.name = "39 顺序即解"
            lv.map_w = 1760.0
            lv.map_h = 680.0
            lv.floors = [seg(0.0, 1760.0)]
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1700, 550)
            lv.ents = [
                block(280.0, 558.0),
                plate(470.0, 596.0, "p1", "n"),
                door(600.0, 444.0, 160.0, ["p1"]),
                timer("t1", 2.5, 0.45, 0.0),
                timer("t2", 2.5, 0.45, 1.25),
                spike(780.0, 590.0, 120.0, true, "t1"),
                spike(1080.0, 590.0, 120.0, true, "t2"),
                spike(1310.0, 590.0, 110.0, true, "t1"),
                plate(1430.0, 596.0, "p2", "f"),
                door(1520.0, 444.0, 160.0, ["p2"]),
                gemdoor(1660.0, 604.0, 3, 3),
                gem(950.0, 540.0, "r"), gem(1200.0, 540.0, "b"),
                gem(180.0, 550.0, "r"), gem(1620.0, 550.0, "b"),
                gem(1000.0, 500.0, "r"), gem(1150.0, 500.0, "b"),
            ]
        40:
            lv.name = "40 光明之心"
            lv.map_w = 1760.0
            lv.map_h = 950.0
            lv.floors = [seg(0.0, 950.0), seg(1300.0, 1760.0)]
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(1700, 550)
            lv.plats = [plat(0.0, 300.0, 430.0), plat(1350.0, 300.0, 160.0), plat(1600.0, 240.0, 160.0)]
            lv.pools = [pool("fire", 520.0, 80.0), pool("shallow", 950.0, 80.0), pool("water", 1120.0, 90.0), pool("fire", 1380.0, 70.0)]
            lv.ents = [
                elewall(430.0, 344.0, 26.0, 200.0, "ice"),
                elewall(1330.0, 344.0, 26.0, 200.0, "fire"),
                spike(700.0, 590.0, 90.0, false, ""),
                block(800.0, 558.0),
                plate(900.0, 596.0, "p1", "n"),
                door(1010.0, 444.0, 160.0, ["p1"]),
                elev(180.0, 540.0, 300.0, 540.0, ["p2"]),
                plate(80.0, 596.0, "p2", "n"),
                rotator(1500.0, 180.0, 100.0, "l1"),
                lever(1730.0, 232.0, "l1"),
                portal(1630.0, 210.0, 1250.0, 540.0, "r"),
                portal(1700.0, 210.0, 400.0, 540.0, "b"),
                checkpoint(650.0, 556.0),
                gemdoor(1160.0, 604.0, 3, 3),
                gem(1420.0, 210.0, "r"), gem(1620.0, 550.0, "b"),
                gem(180.0, 250.0, "r"), gem(750.0, 550.0, "b"),
                gem(950.0, 550.0, "r"), gem(1250.0, 260.0, "b"),
            ]
    return lv
