extends Object
# Mosslight 关卡数据 v0.3 —— 按新机关体系与难度曲线。
# 难度递进：出生点同点→分离→对角/上下；出口统一为宝石门（红槽 Ember / 蓝槽 Tide）；
# 火人可走岩浆、冰人可走水潭（元素路面）；透明浅水坑双杀；尖刺双杀；死亡整关重置。
# 坐标：1280x720，地面 y=604。

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

static func gemdoor(rx: float, ry: float) -> Dictionary:
    return {"t": "gemdoor", "pos": Vector2(rx, ry), "need": {"r": 1, "b": 1}, "have": {"r": 0, "b": 0}, "open": false}

static func build(n: int) -> Dictionary:
    var lv := {"name": "", "floors": [seg(0.0, 1280.0)], "plats": [], "pools": [], "ents": [], "spawnE": Vector2(70, 550), "spawnT": Vector2(130, 550)}
    match n:
        # ============ 第一章：同点出生 / 单层 / 2-4 机关 ============
        1:
            lv.name = "01 同门而入"
            lv.plats = [plat(600.0, 440.0, 80.0)]
            lv.ents = [
                plate(500.0, 596.0, "p1", "n"),
                door(660.0, 444.0, 160.0, ["p1"]),
                gem(950.0, 550.0, "r"), gem(990.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        2:
            lv.name = "02 踏板留守"
            lv.plats = [plat(430.0, 460.0, 90.0)]
            lv.ents = [
                plate(330.0, 596.0, "p1", "n"),
                door(560.0, 444.0, 160.0, ["p1"]),
                gem(700.0, 550.0, "r"), gem(750.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        3:
            lv.name = "03 各行其道"
            lv.pools = [pool("fire", 480.0, 120.0), pool("water", 700.0, 120.0)]
            lv.ents = [
                gem(540.0, 550.0, "r"), gem(760.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        4:
            lv.name = "04 跳跃试炼"
            lv.pools = [pool("shallow", 430.0, 90.0), pool("shallow", 620.0, 110.0), pool("shallow", 830.0, 90.0)]
            lv.plats = [plat(560.0, 520.0, 50.0)]
            lv.ents = [
                gem(585.0, 490.0, "r"), gem(940.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        5:
            lv.name = "05 萤火守门人"
            lv.plats = [plat(430.0, 460.0, 90.0)]
            lv.ents = [
                plate(330.0, 596.0, "p1", "n"),
                door(560.0, 444.0, 160.0, ["p1"]),
                lever(640.0, 560.0, "l1"),
                door(760.0, 444.0, 160.0, ["l1"]),
                gem(880.0, 550.0, "r"), gem(920.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        # ============ 第二章：分离出生 / 坑洞 / 4-6 机关 ============
        6:
            lv.name = "06 分道扬镳"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("fire", 400.0, 160.0), pool("water", 760.0, 160.0)]
            lv.plats = [plat(620.0, 500.0, 90.0)]
            lv.ents = [
                gem(660.0, 470.0, "r"), gem(830.0, 550.0, "b"),
                gemdoor(610.0, 604.0),
            ]
        7:
            lv.name = "07 推石填坑"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.floors = [seg(0.0, 560.0), pit(560.0, 760.0), seg(760.0, 1280.0)]
            lv.ents = [
                block(300.0, 558.0),
                gem(500.0, 550.0, "r"), gem(900.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        8:
            lv.name = "08 一石二鸟"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.plats = [plat(460.0, 500.0, 120.0)]
            lv.ents = [
                block(500.0, 454.0),
                plate(560.0, 596.0, "p1", "n"),
                door(700.0, 444.0, 160.0, ["p1"]),
                gem(650.0, 550.0, "r"), gem(950.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        9:
            lv.name = "09 尖刺回廊"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                spike(430.0, 590.0, 90.0, false, ""),
                spike(620.0, 590.0, 120.0, false, ""),
                plat(540.0, 500.0, 60.0),
                gem(570.0, 470.0, "r"), gem(900.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        10:
            lv.name = "10 石板双开"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("shallow", 500.0, 100.0)]
            lv.ents = [
                block(260.0, 558.0),
                plate(760.0, 596.0, "p1", "n"),
                door(880.0, 444.0, 160.0, ["p1"]),
                gem(650.0, 540.0, "r"), gem(700.0, 540.0, "b"),
                gemdoor(1050.0, 604.0),
            ]
        # ============ 第三章：分离出生 / 爬塔 / 5-7 机关 ============
        11:
            lv.name = "11 雾中渡台"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("shallow", 200.0, 900.0)]
            lv.ents = [
                mover(100.0, 500.0, 100.0, 380.0, 80.0, 0.0),
                mover(480.0, 450.0, 460.0, 760.0, 95.0, 1.7),
                mover(860.0, 500.0, 840.0, 1120.0, 85.0, 3.1),
                gem(620.0, 410.0, "r"), gem(300.0, 460.0, "b"),
                gemdoor(1180.0, 604.0),
            ]
        12:
            lv.name = "12 升降之间"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                wall(400.0, 340.0, 16.0, 264.0),
                wall(620.0, 200.0, 16.0, 204.0),
                elev(440.0, 540.0, 260.0, 540.0, ["p1", "l1"]),
                plate(760.0, 596.0, "p1", "n"),
                lever(700.0, 190.0, "l1"),
                plat(420.0, 480.0, 60.0), plat(500.0, 400.0, 60.0), plat(420.0, 320.0, 60.0),
                gem(450.0, 290.0, "r"), gem(760.0, 540.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        13:
            lv.name = "13 旋转渡台"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("shallow", 420.0, 420.0)]
            lv.ents = [
                plate(320.0, 596.0, "p1", "n"),
                rotator(640.0, 480.0, 130.0, "p1"),
                plat(900.0, 500.0, 90.0),
                gem(640.0, 380.0, "r"), gem(940.0, 470.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        14:
            lv.name = "14 弹刺走廊"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                timer("t1", 3.0, 0.5, 0.0),
                spike(500.0, 590.0, 140.0, true, "t1"),
                spike(760.0, 590.0, 140.0, true, "t1"),
                plat(640.0, 500.0, 60.0),
                gem(670.0, 470.0, "r"), gem(950.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        15:
            lv.name = "15 温室之巅"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                plat(900.0, 520.0, 100.0), plat(1040.0, 440.0, 100.0),
                plat(900.0, 360.0, 100.0), plat(1040.0, 280.0, 100.0),
                mover(620.0, 300.0, 620.0, 880.0, 110.0, 2.0),
                plat(470.0, 300.0, 100.0), plat(350.0, 240.0, 80.0),
                plat(240.0, 180.0, 150.0),
                elev(60.0, 340.0, 180.0, 540.0, ["p1"]),
                plate(50.0, 596.0, "p1", "n"),
                checkpoint(700.0, 556.0),
                gem(1090.0, 400.0, "r"), gem(490.0, 540.0, "b"),
                gemdoor(310.0, 180.0),
            ]
        # ============ 第四章：对角出生 / 光路与属性墙 / 6-8 机关 ============
        16:
            lv.name = "16 火娃融墙"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                elewall(560.0, 344.0, 26.0, 260.0, "ice"),
                wall(660.0, 344.0, 16.0, 260.0),
                door(880.0, 444.0, 160.0, ["p1"]),
                plate(760.0, 596.0, "p1", "n"),
                gem(700.0, 550.0, "r"), gem(950.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        17:
            lv.name = "17 冰娃灭火"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                elewall(560.0, 344.0, 26.0, 260.0, "fire"),
                wall(660.0, 344.0, 16.0, 260.0),
                door(880.0, 444.0, 160.0, ["p1"]),
                plate(760.0, 596.0, "p1", "n"),
                gem(700.0, 550.0, "r"), gem(950.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        18:
            lv.name = "18 双墙夹道"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                elewall(400.0, 344.0, 26.0, 260.0, "ice"),
                wall(470.0, 344.0, 16.0, 260.0),
                elewall(700.0, 344.0, 26.0, 260.0, "fire"),
                wall(770.0, 344.0, 16.0, 260.0),
                door(950.0, 444.0, 160.0, ["p1"]),
                plate(880.0, 596.0, "p1", "n"),
                gem(590.0, 550.0, "r"), gem(640.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        19:
            lv.name = "19 红蓝门扉"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("fire", 420.0, 100.0), pool("water", 860.0, 100.0)]
            lv.ents = [
                portal(300.0, 540.0, 1000.0, 540.0, "r"),
                portal(1050.0, 540.0, 260.0, 540.0, "b"),
                gem(640.0, 550.0, "r"), gem(680.0, 550.0, "b"),
                gemdoor(640.0, 604.0),
            ]
        20:
            lv.name = "20 树冠之心"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("water", 560.0, 160.0)]
            lv.ents = [
                elewall(400.0, 344.0, 26.0, 260.0, "ice"),
                beam(900.0, 300.0, "S", "cold", false, []),
                plate(300.0, 596.0, "p1", "n"),
                elev(500.0, 540.0, 300.0, 540.0, ["p1"]),
                gem(560.0, 470.0, "r"), gem(900.0, 500.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        # ============ 第五章：上下分离出生 / 黑暗与尖刺 / 7-9 机关 ============
        21:
            lv.name = "21 上层下层"
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(1210, 550)
            lv.plats = [plat(0.0, 300.0, 340.0), plat(950.0, 300.0, 330.0)]
            lv.ents = [
                door(620.0, 444.0, 160.0, ["p1"]),
                plate(460.0, 596.0, "p1", "n"),
                gem(150.0, 250.0, "r"), gem(1080.0, 550.0, "b"),
                gemdoor(640.0, 604.0),
            ]
        22:
            lv.name = "22 红门蓝门"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("fire", 350.0, 90.0), pool("water", 510.0, 90.0), pool("fire", 670.0, 90.0), pool("water", 830.0, 90.0)]
            lv.ents = [
                portal(200.0, 540.0, 1150.0, 540.0, "r"),
                portal(1080.0, 540.0, 130.0, 540.0, "b"),
                gem(620.0, 550.0, "r"), gem(660.0, 550.0, "b"),
                gemdoor(650.0, 604.0),
            ]
        23:
            lv.name = "23 黑暗中的萤火"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                darkzone(200.0, 150.0, 880.0, 470.0, "pl"),
                spike(560.0, 590.0, 100.0, false, ""),
                lever(400.0, 560.0, "l1"),
                door(740.0, 444.0, 160.0, ["l1"]),
                plate(800.0, 596.0, "pl", "n"),
                gem(500.0, 540.0, "r"), gem(700.0, 540.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        24:
            lv.name = "24 连环尖刺"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                timer("t1", 2.5, 0.45, 0.0),
                timer("t2", 3.5, 0.4, 1.2),
                spike(420.0, 590.0, 120.0, true, "t1"),
                spike(640.0, 590.0, 120.0, true, "t2"),
                spike(860.0, 590.0, 120.0, true, "t1"),
                plat(560.0, 480.0, 60.0),
                gem(590.0, 450.0, "r"), gem(1000.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        25:
            lv.name = "25 旋转深渊"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("shallow", 300.0, 680.0)]
            lv.ents = [
                plate(180.0, 596.0, "p1", "n"),
                rotator(640.0, 480.0, 140.0, "p1"),
                rotator(640.0, 380.0, 90.0, "p1"),
                spike(250.0, 590.0, 40.0, false, ""),
                spike(1030.0, 590.0, 40.0, false, ""),
                plat(980.0, 480.0, 70.0),
                gem(640.0, 340.0, "r"), gem(1000.0, 450.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        # ============ 第六章：异步出生 / 全机关联动 / 8-12 机关 ============
        26:
            lv.name = "26 元素法庭"
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(1210, 550)
            lv.plats = [plat(0.0, 300.0, 280.0)]
            lv.pools = [pool("water", 640.0, 90.0), pool("fire", 830.0, 90.0)]
            lv.ents = [
                elewall(500.0, 344.0, 26.0, 260.0, "ice"),
                elewall(760.0, 344.0, 26.0, 260.0, "fire"),
                gem(200.0, 250.0, "r"), gem(1100.0, 550.0, "b"),
                gemdoor(640.0, 604.0),
            ]
        27:
            lv.name = "27 三重机关"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                plate(300.0, 596.0, "p1", "n"),
                door(430.0, 444.0, 160.0, ["p1"]),
                spike(560.0, 590.0, 100.0, false, ""),
                block(700.0, 558.0),
                plate(800.0, 596.0, "p2", "n"),
                door(900.0, 444.0, 160.0, ["p2"]),
                gem(620.0, 540.0, "r"), gem(1000.0, 550.0, "b"),
                gemdoor(1100.0, 604.0),
            ]
        28:
            lv.name = "28 传送迷宫"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.pools = [pool("fire", 500.0, 280.0)]
            lv.ents = [
                portal(200.0, 540.0, 900.0, 460.0, "r"),
                portal(1100.0, 540.0, 420.0, 460.0, "b"),
                plat(850.0, 500.0, 110.0), plat(370.0, 500.0, 110.0),
                spike(650.0, 590.0, 80.0, false, ""),
                gem(905.0, 470.0, "r"), gem(400.0, 470.0, "b"),
                gemdoor(640.0, 604.0),
            ]
        29:
            lv.name = "29 月蚀倒计时"
            lv.spawnE = Vector2(70, 550)
            lv.spawnT = Vector2(1210, 550)
            lv.ents = [
                timer("t1", 2.0, 0.5, 0.0),
                timer("t2", 2.0, 0.5, 1.0),
                spike(300.0, 590.0, 110.0, true, "t1"),
                spike(520.0, 590.0, 110.0, true, "t2"),
                spike(740.0, 590.0, 110.0, true, "t1"),
                spike(960.0, 590.0, 110.0, true, "t2"),
                plat(430.0, 480.0, 60.0), plat(650.0, 480.0, 60.0), plat(870.0, 480.0, 60.0),
                gem(460.0, 450.0, "r"), gem(900.0, 450.0, "b"),
                gemdoor(1150.0, 604.0),
            ]
        30:
            lv.name = "30 圣所终章"
            lv.spawnE = Vector2(70, 250)
            lv.spawnT = Vector2(1210, 550)
            lv.plats = [plat(0.0, 300.0, 300.0), plat(420.0, 300.0, 120.0), plat(840.0, 300.0, 120.0), plat(990.0, 300.0, 290.0)]
            lv.pools = [pool("fire", 350.0, 60.0), pool("shallow", 480.0, 70.0), pool("water", 700.0, 60.0), pool("shallow", 790.0, 60.0)]
            lv.ents = [
                elewall(300.0, 344.0, 26.0, 200.0, "ice"),
                elewall(970.0, 344.0, 26.0, 200.0, "fire"),
                spike(580.0, 590.0, 90.0, false, ""),
                block(640.0, 558.0),
                plate(760.0, 596.0, "p1", "n"),
                door(880.0, 444.0, 160.0, ["p1"]),
                elev(150.0, 540.0, 300.0, 540.0, ["p2"]),
                plate(60.0, 596.0, "p2", "n"),
                checkpoint(600.0, 556.0),
                gem(480.0, 250.0, "r"), gem(850.0, 250.0, "b"),
                gem(140.0, 250.0, "r"), gem(1150.0, 550.0, "b"),
                gemdoor(640.0, 604.0),
            ]
    return lv
