extends Object
# Mosslight 关卡数据 v0.5 —— 4 神殿章节 × 10 关（40 关），按分级框架：
# 一章 森林(1-10):  8×6 小房间, ≤2 种机关, 宝石 1红1蓝, 几乎不分路
# 二章 冰(11-20):   12×8, 推石/移动平台, 短分支, 宝石 2红2蓝
# 三章 火(21-30):   16×10 多房间, 传送门/旋转台/元素墙, 长分路, 宝石 2-3
# 四章 光明(31-40): 20×12 立体复合, 连锁机关+接力操作, 宝石 3红3蓝
# 元素规则：火人走岩浆、冰人走水潭、浅水坑双杀、尖刺双杀、死亡整关重置。
# 地面 y=604，画布 1280x720。

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
    var lv := {"name": "", "floors": [seg(0.0, 1280.0)], "plats": [], "pools": [], "ents": [], "spawnE": Vector2(70, 550), "spawnT": Vector2(130, 550)}
    match n:
        # ================= 第一章 森林神殿（1-10）：8×6 单房间，机关≤2种，宝石1红1蓝，不分路 =================
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
        # ================= 第二章 冰神殿（11-20）：12×8，推石+移动平台，短分支，宝石2红2蓝 =================
        11:
            lv.name = "I11 支路初现"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("fire", 430.0, 130.0), pool("water", 760.0, 130.0)]
            lv.plats = [plat(620.0, 500.0, 100.0)]
            lv.ents = [
                gem(670.0, 470.0, "r"), gem(870.0, 550.0, "b"),
                gem(360.0, 550.0, "r"), gem(1000.0, 550.0, "b"),
                gemdoor(640.0, 604.0, 2, 2),
            ]
        12:
            lv.name = "I12 留守接力"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.plats = [plat(430.0, 460.0, 90.0)]
            lv.ents = [
                plate(330.0, 596.0, "p1", "n"),
                door(560.0, 444.0, 160.0, ["p1"]),
                block(760.0, 558.0),
                plate(900.0, 596.0, "p2", "f"),
                door(980.0, 444.0, 160.0, ["p2"]),
                gem(830.0, 550.0, "r"), gem(660.0, 550.0, "b"),
                gemdoor(1180.0, 604.0, 2, 2),
            ]
        13:
            lv.name = "I13 石填水洼"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("shallow", 520.0, 130.0), pool("shallow", 760.0, 130.0)]
            lv.ents = [
                block(280.0, 558.0), block(1000.0, 558.0),
                gem(700.0, 550.0, "r"), gem(660.0, 550.0, "b"),
                gemdoor(660.0, 604.0, 2, 2),
            ]
        14:
            lv.name = "I14 滑台初渡"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("shallow", 300.0, 680.0)]
            lv.ents = [
                mover(100.0, 500.0, 100.0, 420.0, 85.0, 0.0),
                mover(620.0, 470.0, 600.0, 900.0, 95.0, 1.4),
                gem(420.0, 460.0, "r"), gem(760.0, 430.0, "b"),
                gem(1180.0, 550.0, "r"), gem(200.0, 550.0, "b"),
                gemdoor(640.0, 604.0, 2, 2),
            ]
        15:
            lv.name = "I15 高低分支"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.plats = [plat(360.0, 470.0, 120.0), plat(800.0, 470.0, 120.0)]
            lv.ents = [
                plate(620.0, 596.0, "p1", "n"),
                door(560.0, 444.0, 160.0, ["p1"]),
                gem(420.0, 440.0, "r"), gem(860.0, 440.0, "b"),
                gem(700.0, 550.0, "r"), gem(660.0, 550.0, "b"),
                gemdoor(660.0, 604.0, 2, 2),
            ]
        16:
            lv.name = "I16 双石架桥"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("shallow", 460.0, 120.0), pool("shallow", 720.0, 120.0)]
            lv.ents = [
                block(280.0, 558.0), block(1000.0, 558.0),
                plat(600.0, 520.0, 60.0),
                gem(630.0, 490.0, "r"), gem(640.0, 550.0, "b"),
                gemdoor(660.0, 604.0, 2, 2),
            ]
        17:
            lv.name = "I17 冰面电梯"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("water", 900.0, 380.0)]
            lv.ents = [
                elev(400.0, 540.0, 320.0, 540.0, ["p1"]),
                plate(300.0, 596.0, "p1", "n"),
                plat(430.0, 360.0, 100.0), plat(560.0, 360.0, 100.0),
                gem(480.0, 330.0, "r"), gem(600.0, 330.0, "b"),
                gem(1050.0, 550.0, "r"), gem(1000.0, 550.0, "b"),
                gemdoor(1180.0, 604.0, 2, 2),
            ]
        18:
            lv.name = "I18 弹刺节奏"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                timer("t1", 3.0, 0.5, 0.0),
                spike(480.0, 590.0, 110.0, true, "t1"),
                spike(700.0, 590.0, 110.0, true, "t1"),
                plat(610.0, 500.0, 60.0),
                gem(640.0, 470.0, "r"), gem(950.0, 550.0, "b"),
                gem(350.0, 550.0, "r"), gem(1060.0, 550.0, "b"),
                gemdoor(1180.0, 604.0, 2, 2),
            ]
        19:
            lv.name = "I19 支路汇流"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("fire", 350.0, 100.0), pool("water", 850.0, 100.0)]
            lv.plats = [plat(560.0, 490.0, 60.0), plat(720.0, 440.0, 60.0)]
            lv.ents = [
                gem(590.0, 460.0, "r"), gem(750.0, 410.0, "b"),
                gem(420.0, 550.0, "r"), gem(950.0, 550.0, "b"),
                gemdoor(660.0, 604.0, 2, 2),
            ]
        20:
            lv.name = "I20 冰殿之心"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("shallow", 480.0, 320.0)]
            lv.ents = [
                block(240.0, 558.0), block(1040.0, 558.0),
                mover(480.0, 480.0, 460.0, 820.0, 100.0, 0.8),
                plate(150.0, 596.0, "p1", "n"),
                door(300.0, 444.0, 160.0, ["p1"]),
                gem(700.0, 450.0, "r"), gem(640.0, 550.0, "b"),
                gem(1130.0, 550.0, "r"), gem(200.0, 550.0, "b"),
                gemdoor(660.0, 604.0, 2, 2),
            ]
        # ================= 第三章 火神殿（21-30）：16×10 多房间，传送/旋转/元素墙，长分路 =================
        21:
            lv.name = "H21 红蓝漩涡"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("fire", 500.0, 280.0)]
            lv.ents = [
                portal(200.0, 540.0, 1080.0, 540.0, "r"),
                portal(1100.0, 540.0, 400.0, 540.0, "b"),
                plat(880.0, 500.0, 110.0), plat(300.0, 500.0, 110.0),
                gem(935.0, 470.0, "r"), gem(355.0, 470.0, "b"),
                gemdoor(640.0, 604.0, 2, 2),
            ]
        22:
            lv.name = "H22 旋转回廊"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("shallow", 340.0, 600.0)]
            lv.ents = [
                plate(200.0, 596.0, "p1", "n"),
                rotator(640.0, 470.0, 140.0, "p1"),
                plat(980.0, 480.0, 80.0),
                gem(640.0, 340.0, "r"), gem(1010.0, 450.0, "b"),
                gem(300.0, 540.0, "r"), gem(1120.0, 540.0, "b"),
                gemdoor(640.0, 604.0, 2, 2),
            ]
        23:
            lv.name = "H23 火娃专线"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                elewall(540.0, 344.0, 26.0, 260.0, "ice"),
                wall(620.0, 344.0, 16.0, 260.0),
                door(860.0, 444.0, 160.0, ["p1"]),
                plate(760.0, 596.0, "p1", "n"),
                gem(700.0, 550.0, "r"), gem(700.0, 500.0, "b"),
                gem(950.0, 550.0, "r"), gem(1000.0, 550.0, "b"),
                gemdoor(1120.0, 604.0, 2, 2),
            ]
        24:
            lv.name = "H24 冰娃专线"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                elewall(540.0, 344.0, 26.0, 260.0, "fire"),
                wall(620.0, 344.0, 16.0, 260.0),
                door(860.0, 444.0, 160.0, ["p1"]),
                plate(760.0, 596.0, "p1", "n"),
                gem(700.0, 550.0, "r"), gem(700.0, 500.0, "b"),
                gem(950.0, 550.0, "r"), gem(1000.0, 550.0, "b"),
                gemdoor(1120.0, 604.0, 2, 2),
            ]
        25:
            lv.name = "H25 双墙并行"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                elewall(380.0, 344.0, 26.0, 260.0, "ice"),
                wall(450.0, 344.0, 16.0, 260.0),
                elewall(700.0, 344.0, 26.0, 260.0, "fire"),
                wall(770.0, 344.0, 16.0, 260.0),
                door(960.0, 444.0, 160.0, ["p1"]),
                plate(880.0, 596.0, "p1", "n"),
                gem(580.0, 550.0, "r"), gem(640.0, 550.0, "b"),
                gem(840.0, 550.0, "r"), gem(900.0, 550.0, "b"),
                gemdoor(1120.0, 604.0, 2, 2),
            ]
        26:
            lv.name = "H26 远端双板"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("fire", 450.0, 90.0), pool("water", 740.0, 90.0)]
            lv.ents = [
                portal(300.0, 540.0, 980.0, 540.0, "r"),
                portal(980.0, 540.0, 300.0, 540.0, "b"),
                plate(1060.0, 596.0, "pL", "n"),
                plate(230.0, 596.0, "pR", "n"),
                door(620.0, 444.0, 160.0, ["pL", "pR"]),
                gem(1120.0, 550.0, "r"), gem(160.0, 550.0, "b"),
                gem(640.0, 550.0, "r"), gem(690.0, 550.0, "b"),
                gemdoor(660.0, 604.0, 2, 2),
            ]
        27:
            lv.name = "H27 高塔速降"
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(1210, 550)
            lv.plats = [plat(0.0, 300.0, 320.0), plat(420.0, 300.0, 110.0), plat(640.0, 240.0, 110.0)]
            lv.pools = [pool("shallow", 480.0, 130.0)]
            lv.ents = [
                gem(690.0, 210.0, "r"), gem(540.0, 270.0, "b"),
                gem(200.0, 250.0, "r"), gem(1150.0, 550.0, "b"),
                gemdoor(1000.0, 604.0, 2, 2),
            ]
        28:
            lv.name = "H28 转台渡渊"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("shallow", 300.0, 680.0)]
            lv.ents = [
                plate(160.0, 596.0, "p1", "n"),
                rotator(640.0, 480.0, 150.0, "p1"),
                rotator(640.0, 360.0, 100.0, "p1"),
                spike(240.0, 590.0, 40.0, false, ""),
                spike(1000.0, 590.0, 40.0, false, ""),
                plat(980.0, 470.0, 80.0),
                gem(640.0, 320.0, "r"), gem(1010.0, 440.0, "b"),
                gem(300.0, 540.0, "r"), gem(1120.0, 540.0, "b"),
                gemdoor(640.0, 604.0, 2, 2),
            ]
        29:
            lv.name = "H29 黑暗矿区"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                darkzone(220.0, 150.0, 840.0, 470.0, "pl"),
                spike(520.0, 590.0, 90.0, false, ""),
                lever(360.0, 560.0, "l1"),
                door(700.0, 444.0, 160.0, ["l1"]),
                plate(770.0, 596.0, "pl", "n"),
                gem(470.0, 540.0, "r"), gem(760.0, 540.0, "b"),
                gem(300.0, 540.0, "r"), gem(1020.0, 550.0, "b"),
                gemdoor(1120.0, 604.0, 2, 2),
            ]
        30:
            lv.name = "H30 火殿之心"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("fire", 420.0, 100.0), pool("water", 760.0, 100.0)]
            lv.ents = [
                portal(250.0, 540.0, 1050.0, 540.0, "r"),
                portal(1030.0, 540.0, 250.0, 540.0, "b"),
                elewall(560.0, 344.0, 26.0, 260.0, "ice"),
                elewall(720.0, 344.0, 26.0, 260.0, "fire"),
                plat(640.0, 480.0, 80.0),
                gem(680.0, 450.0, "r"), gem(620.0, 450.0, "b"),
                gem(460.0, 550.0, "r"), gem(840.0, 550.0, "b"),
                gemdoor(660.0, 604.0, 2, 2),
            ]
        # ================= 第四章 光明神殿（31-40）：20×12 立体复合，连锁+接力，宝石3红3蓝 =================
        31:
            lv.name = "L31 三层立体"
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(1210, 550)
            lv.plats = [plat(0.0, 300.0, 330.0), plat(950.0, 300.0, 330.0), plat(480.0, 200.0, 320.0)]
            lv.pools = [pool("shallow", 380.0, 90.0), pool("shallow", 810.0, 90.0)]
            lv.ents = [
                gem(560.0, 170.0, "r"), gem(720.0, 170.0, "b"),
                gem(150.0, 250.0, "r"), gem(1130.0, 250.0, "b"),
                gem(640.0, 550.0, "r"), gem(690.0, 550.0, "b"),
                gemdoor(665.0, 604.0, 3, 3),
            ]
        32:
            lv.name = "L32 传送接力"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                portal(200.0, 540.0, 900.0, 460.0, "r"),
                portal(1080.0, 540.0, 380.0, 460.0, "b"),
                plat(840.0, 500.0, 130.0), plat(320.0, 500.0, 130.0),
                plate(940.0, 466.0, "p1", "f"),
                plate(360.0, 466.0, "p2", "f"),
                door(640.0, 444.0, 160.0, ["p1", "p2"]),
                gem(905.0, 470.0, "r"), gem(390.0, 470.0, "b"),
                gem(640.0, 550.0, "r"), gem(690.0, 550.0, "b"),
                gemdoor(665.0, 604.0, 3, 3),
            ]
        33:
            lv.name = "L33 尖刺迷宫"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                timer("t1", 2.2, 0.5, 0.0),
                timer("t2", 2.2, 0.5, 1.1),
                spike(320.0, 590.0, 100.0, true, "t1"),
                spike(540.0, 590.0, 100.0, true, "t2"),
                spike(760.0, 590.0, 100.0, true, "t1"),
                plat(430.0, 490.0, 60.0), plat(650.0, 490.0, 60.0),
                gem(460.0, 460.0, "r"), gem(680.0, 460.0, "b"),
                gem(150.0, 550.0, "r"), gem(1130.0, 550.0, "b"),
                gemdoor(1120.0, 604.0, 3, 3),
            ]
        34:
            lv.name = "L34 双转台渡"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("shallow", 280.0, 720.0)]
            lv.ents = [
                plate(140.0, 596.0, "p1", "n"),
                rotator(560.0, 480.0, 130.0, "p1"),
                rotator(900.0, 420.0, 110.0, "p1"),
                plat(1080.0, 460.0, 80.0),
                gem(560.0, 340.0, "r"), gem(900.0, 280.0, "b"),
                gem(300.0, 540.0, "r"), gem(1150.0, 540.0, "b"),
                gemdoor(660.0, 604.0, 3, 3),
            ]
        35:
            lv.name = "L35 暗殿回环"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                darkzone(160.0, 150.0, 960.0, 470.0, "pl"),
                lever(300.0, 560.0, "l1"),
                door(560.0, 444.0, 160.0, ["l1"]),
                portal(640.0, 540.0, 1020.0, 540.0, "r"),
                portal(700.0, 540.0, 260.0, 540.0, "b"),
                plate(1080.0, 596.0, "pl", "n"),
                spike(480.0, 590.0, 70.0, false, ""),
                gem(420.0, 540.0, "r"), gem(840.0, 540.0, "b"),
                gem(1140.0, 550.0, "r"), gem(200.0, 540.0, "b"),
                gemdoor(660.0, 604.0, 3, 3),
            ]
        36:
            lv.name = "L36 墙外有墙"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                elewall(340.0, 344.0, 26.0, 260.0, "ice"),
                wall(400.0, 344.0, 16.0, 260.0),
                elewall(520.0, 344.0, 26.0, 260.0, "fire"),
                wall(580.0, 344.0, 16.0, 260.0),
                elewall(720.0, 344.0, 26.0, 260.0, "ice"),
                wall(780.0, 344.0, 16.0, 260.0),
                elewall(900.0, 344.0, 26.0, 260.0, "fire"),
                door(1000.0, 444.0, 160.0, ["p1"]),
                plate(960.0, 596.0, "p1", "n"),
                gem(460.0, 550.0, "r"), gem(640.0, 550.0, "b"),
                gem(840.0, 550.0, "r"), gem(940.0, 550.0, "b"),
                gemdoor(1180.0, 604.0, 3, 3),
            ]
        37:
            lv.name = "L37 连锁三器"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                beam(300.0, 470.0, "E", "sig", false, []),
                mirror(560.0, 470.0, false),
                recv(560.0, 330.0, "r1"),
                block(760.0, 558.0),
                plate(860.0, 596.0, "p1", "n"),
                chain("c1", ["r1", "p1"]),
                door(1000.0, 444.0, 160.0, ["c1"]),
                gem(560.0, 430.0, "r"), gem(700.0, 550.0, "b"),
                gem(200.0, 550.0, "r"), gem(1130.0, 550.0, "b"),
                gemdoor(1180.0, 604.0, 3, 3),
            ]
        38:
            lv.name = "L38 立体回环"
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(70, 550)
            lv.plats = [plat(0.0, 300.0, 300.0), plat(420.0, 300.0, 120.0), plat(700.0, 240.0, 120.0), plat(940.0, 300.0, 340.0)]
            lv.pools = [pool("fire", 380.0, 60.0), pool("shallow", 520.0, 60.0), pool("water", 640.0, 50.0)]
            lv.ents = [
                elewall(300.0, 344.0, 26.0, 200.0, "ice"),
                elev(140.0, 540.0, 300.0, 540.0, ["p1"]),
                plate(60.0, 596.0, "p1", "n"),
                portal(960.0, 260.0, 340.0, 540.0, "b"),
                portal(1080.0, 260.0, 1140.0, 540.0, "r"),
                gem(760.0, 210.0, "r"), gem(480.0, 270.0, "b"),
                gem(1140.0, 250.0, "r"), gem(1140.0, 550.0, "b"),
                gemdoor(660.0, 604.0, 3, 3),
            ]
        39:
            lv.name = "L39 顺序即解"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                block(240.0, 558.0),
                plate(360.0, 596.0, "p1", "n"),
                door(460.0, 444.0, 160.0, ["p1"]),
                timer("t1", 2.5, 0.45, 0.0),
                timer("t2", 2.5, 0.45, 1.25),
                spike(580.0, 590.0, 100.0, true, "t1"),
                spike(780.0, 590.0, 100.0, true, "t2"),
                plate(940.0, 596.0, "p2", "f"),
                door(1010.0, 444.0, 160.0, ["p2"]),
                gem(640.0, 540.0, "r"), gem(880.0, 540.0, "b"),
                gem(200.0, 540.0, "r"), gem(1130.0, 550.0, "b"),
                gemdoor(700.0, 604.0, 3, 3),
            ]
        40:
            lv.name = "L40 光明之心"
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(1210, 550)
            lv.plats = [plat(0.0, 300.0, 300.0), plat(430.0, 300.0, 120.0), plat(700.0, 240.0, 130.0), plat(960.0, 300.0, 320.0)]
            lv.pools = [pool("fire", 360.0, 55.0), pool("shallow", 500.0, 60.0), pool("water", 620.0, 50.0), pool("shallow", 860.0, 55.0)]
            lv.ents = [
                elewall(300.0, 344.0, 26.0, 200.0, "ice"),
                elewall(920.0, 344.0, 26.0, 200.0, "fire"),
                spike(580.0, 590.0, 90.0, false, ""),
                block(660.0, 558.0),
                plate(760.0, 596.0, "p1", "n"),
                door(860.0, 444.0, 160.0, ["p1"]),
                elev(150.0, 540.0, 300.0, 540.0, ["p2"]),
                plate(50.0, 596.0, "p2", "n"),
                rotator(560.0, 180.0, 90.0, "l1"),
                lever(740.0, 232.0, "l1"),
                portal(980.0, 260.0, 1140.0, 540.0, "r"),
                portal(1060.0, 260.0, 300.0, 540.0, "b"),
                checkpoint(620.0, 556.0),
                gem(480.0, 250.0, "r"), gem(770.0, 210.0, "b"),
                gem(150.0, 250.0, "r"), gem(1150.0, 550.0, "b"),
                gem(660.0, 550.0, "r"), gem(700.0, 550.0, "b"),
                gemdoor(680.0, 604.0, 3, 3),
            ]
    return lv
