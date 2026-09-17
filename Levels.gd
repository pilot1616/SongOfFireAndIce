extends Object
# Mosslight 关卡数据 —— 严格对应 LEVELS.md 的 30 关设计。
# 坐标系：1280x720，地面 y=604。

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

static func esw(x: float, y: float) -> Dictionary:
    return {"t": "esw", "pos": Vector2(x, y), "cd": 0.0}

static func door(x: float, y: float, h: float, links: Array) -> Dictionary:
    return {"t": "door", "r": Rect2(x, y, 16, h), "links": links, "open": false}

static func wall(x: float, y: float, w: float, h: float) -> Dictionary:
    return {"t": "wall", "r": Rect2(x, y, w, h)}

static func block(x: float, y: float) -> Dictionary:
    return {"t": "block", "r": Rect2(x, y, 46, 46), "vy": 0.0, "erased": false}

static func iceblk(x: float, y: float, w: float, h: float) -> Dictionary:
    return {"t": "ice", "r": Rect2(x, y, w, h), "melt": 0.0, "vy": 0.0, "erased": false}

static func bflip(a: Rect2, b: Rect2, lid: String) -> Dictionary:
    return {"t": "bflip", "a": a, "b": b, "lever": lid}

static func bmov(r: Rect2, src: String) -> Dictionary:
    return {"t": "bmov", "r": r, "src": src}

static func mover(x: float, y: float, x1: float, x2: float, sp: float, ph: float) -> Dictionary:
    return {"t": "mover", "r": Rect2(x, y, 120, 14), "x1": x1, "x2": x2, "sp": sp, "ph": ph, "dx": 0.0}

static func elev(x: float, y: float, y1: float, y2: float, srcs: Array) -> Dictionary:
    return {"t": "elev", "r": Rect2(x, y, 130, 14), "y1": y1, "y2": y2, "srcs": srcs, "dy": 0.0}

static func beam(x: float, y: float, dir: String, kind: String, sw: bool, srcs: Array) -> Dictionary:
    return {"t": "beam", "pos": Vector2(x, y), "dir": dir, "kind": kind, "sw": sw, "srcs": srcs, "path": [], "on": true, "kind_now": kind}

static func mirror(x: float, y: float, slash: bool) -> Dictionary:
    return {"t": "mirror", "pos": Vector2(x, y), "slash": slash, "cd": 0.0}

static func recv(x: float, y: float, id: String) -> Dictionary:
    return {"t": "recv", "id": id, "pos": Vector2(x, y), "active": false}

static func chain(id: String, ids: Array) -> Dictionary:
    return {"t": "chain", "id": id, "ids": ids, "active": false}

static func portal(ax: float, ay: float, bx: float, by: float, mode: String) -> Dictionary:
    return {"t": "portal", "a": Vector2(ax, ay), "b": Vector2(bx, by), "mode": mode, "cdE": 0.0, "cdT": 0.0}

static func swapportal(x: float, y: float, src: String) -> Dictionary:
    return {"t": "swap", "pos": Vector2(x, y), "src": src, "used": false, "cd": 0.0}

static func darkzone(x: float, y: float, w: float, h: float, lit_id: String) -> Dictionary:
    return {"t": "dark", "r": Rect2(x, y, w, h), "lever": lit_id, "lit": false}

static func checkpoint(x: float, y: float) -> Dictionary:
    return {"t": "check", "pos": Vector2(x, y), "used": false}

static func gem(x: float, y: float, k: String) -> Dictionary:
    return {"t": "gem", "pos": Vector2(x, y), "k": k, "got": false}

static func timdoor(x: float, y: float, h: float, period: float, duty: float, phase: float) -> Dictionary:
    return {"t": "timdoor", "r": Rect2(x, y, 16, h), "period": period, "duty": duty, "phase": phase, "open": false}

static func timer(id: String, period: float, duty: float, phase: float) -> Dictionary:
    return {"t": "timer", "id": id, "period": period, "duty": duty, "phase": phase, "active": false}

static func build(n: int) -> Dictionary:
    var lv := {"name": "", "floors": [seg(0.0, 1280.0)], "plats": [], "pools": [], "ents": [], "exits": []}
    match n:
        1:
            lv.name = "01 同门而入"
            lv.plats = [plat(600.0, 440.0, 80.0), plat(660.0, 520.0, 60.0)]
            lv.ents = [
                plate(500.0, 596.0, "p1", "f"),
                door(660.0, 444.0, 160.0, ["p1"]),
                gem(640.0, 405.0, "r"), gem(40.0, 560.0, "b"),
            ]
        2:
            lv.name = "02 红灯绿灯"
            lv.ents = [
                wall(200.0, 470.0, 560.0, 16.0),
                door(700.0, 486.0, 118.0, ["pr"]),
                door(700.0, 386.0, 84.0, ["pb"]),
                plate(536.0, 462.0, "pr", "r"),
                plate(536.0, 596.0, "pb", "b"),
                plat(770.0, 530.0, 60.0), plat(840.0, 470.0, 60.0),
                gem(900.0, 560.0, "r"), gem(900.0, 430.0, "b"),
            ]
        3:
            lv.name = "03 岩与水之间"
            lv.pools = [pool("fire", 500.0, 80.0), pool("water", 620.0, 80.0), pool("fire", 740.0, 80.0), pool("water", 860.0, 80.0)]
            lv.plats = [plat(580.0, 540.0, 50.0), plat(700.0, 510.0, 60.0), plat(820.0, 510.0, 60.0)]
            lv.ents = [gem(730.0, 480.0, "r"), gem(850.0, 480.0, "b")]
        4:
            lv.name = "04 双门协奏"
            lv.ents = [
                timer("t1", 4.0, 0.375, 0.0),
                timdoor(640.0, 444.0, 160.0, 4.0, 0.375, 0.0),
                plate(760.0, 596.0, "p1", "f"),
                door(880.0, 444.0, 160.0, ["p1"]),
                plat(580.0, 470.0, 60.0),
                gem(610.0, 440.0, "r"), gem(1000.0, 560.0, "b"),
            ]
        5:
            lv.name = "05 萤火守门人"
            lv.ents = [
                plate(440.0, 596.0, "p1", "n"),
                door(560.0, 444.0, 160.0, ["p1", "l1"]),
                lever(620.0, 560.0, "l1"),
                lever(720.0, 560.0, "l2"),
                door(820.0, 444.0, 160.0, ["l2"]),
                wall(812.0, 200.0, 16.0, 244.0),
                plat(530.0, 480.0, 60.0),
                gem(560.0, 450.0, "r"), gem(1200.0, 560.0, "b"),
            ]
        6:
            lv.name = "06 换轨者"
            lv.floors = [seg(0.0, 420.0), seg(560.0, 620.0), seg(860.0, 1280.0)]
            lv.ents = [
                lever(360.0, 596.0, "l1"),
                bflip(Rect2(420.0, 566.0, 140.0, 12.0), Rect2(620.0, 566.0, 240.0, 12.0), "l1"),
                plate(580.0, 596.0, "p1", "f"),
                door(1000.0, 444.0, 160.0, ["p1"]),
                gem(590.0, 540.0, "r"), gem(900.0, 560.0, "b"),
            ]
        7:
            lv.name = "07 推石问路"
            lv.floors = [seg(0.0, 560.0), pit(560.0, 800.0), seg(800.0, 1280.0)]
            lv.ents = [
                block(300.0, 558.0),
                plat(320.0, 470.0, 70.0),
                gem(355.0, 440.0, "r"), gem(900.0, 560.0, "b"),
            ]
        8:
            lv.name = "08 一石二鸟"
            lv.plats = [plat(500.0, 500.0, 120.0)]
            lv.ents = [
                block(540.0, 454.0),
                plate(590.0, 596.0, "p1", "n"),
                door(700.0, 444.0, 160.0, ["p1"]),
                gem(540.0, 420.0, "r"), gem(1000.0, 560.0, "b"),
            ]
        9:
            lv.name = "09 双石记"
            lv.floors = [seg(0.0, 480.0), pit(480.0, 620.0), seg(620.0, 1280.0)]
            lv.pools = [pool("poison", 1100.0, 60.0)]
            lv.ents = [
                block(280.0, 558.0), block(660.0, 558.0),
                plate(700.0, 596.0, "p1", "n"),
                door(780.0, 444.0, 160.0, ["p1"]),
                plat(1020.0, 470.0, 80.0),
                gem(550.0, 600.0, "r"), gem(1060.0, 440.0, "b"),
            ]
        10:
            lv.name = "10 根须吊桥"
            lv.floors = [seg(0.0, 420.0), seg(560.0, 700.0), seg(840.0, 1280.0)]
            lv.ents = [
                block(200.0, 558.0),
                plate(360.0, 596.0, "p1", "n"),
                bmov(Rect2(420.0, 560.0, 140.0, 12.0), "p1"),
                plate(620.0, 596.0, "p2", "f"),
                bmov(Rect2(700.0, 560.0, 140.0, 12.0), "p2"),
                gem(490.0, 505.0, "r"), gem(660.0, 540.0, "b"),
            ]
        11:
            lv.name = "11 雾中渡台"
            lv.pools = [pool("water", 150.0, 950.0)]
            lv.ents = [
                mover(100.0, 500.0, 100.0, 380.0, 80.0, 0.0),
                mover(480.0, 450.0, 460.0, 760.0, 95.0, 1.7),
                mover(860.0, 500.0, 840.0, 1120.0, 85.0, 3.1),
                gem(620.0, 410.0, "r"), gem(300.0, 460.0, "b"),
            ]
        12:
            lv.name = "12 升降之间"
            lv.ents = [
                wall(400.0, 340.0, 16.0, 264.0),
                wall(620.0, 200.0, 16.0, 204.0),
                elev(440.0, 540.0, 260.0, 540.0, ["p1", "l1"]),
                plate(760.0, 596.0, "p1", "n"),
                lever(700.0, 190.0, "l1"),
                plat(420.0, 480.0, 60.0), plat(500.0, 400.0, 60.0), plat(420.0, 320.0, 60.0),
                gem(450.0, 290.0, "r"), gem(760.0, 540.0, "b"),
            ]
        13:
            lv.name = "13 双梯交错"
            lv.ents = [
                wall(364.0, 200.0, 16.0, 404.0),
                wall(560.0, 200.0, 16.0, 204.0),
                wall(760.0, 200.0, 16.0, 404.0),
                elev(410.0, 540.0, 240.0, 540.0, ["pr"]),
                elev(610.0, 540.0, 240.0, 540.0, ["pb"]),
                plate(700.0, 596.0, "pr", "r"),
                plate(450.0, 596.0, "pb", "b"),
                plat(470.0, 470.0, 60.0), plat(540.0, 390.0, 60.0), plat(470.0, 310.0, 60.0),
                plat(470.0, 300.0, 60.0), plat(660.0, 290.0, 80.0),
                gem(500.0, 270.0, "r"), gem(700.0, 260.0, "b"),
            ]
        14:
            lv.name = "14 雾门摆渡"
            lv.ents = [
                timdoor(640.0, 444.0, 160.0, 4.0, 0.375, 0.0),
                mover(100.0, 520.0, 100.0, 480.0, 120.0, 0.0),
                plate(760.0, 596.0, "p1", "f"),
                door(880.0, 444.0, 160.0, ["p1"]),
                plat(580.0, 470.0, 60.0),
                gem(610.0, 440.0, "r"), gem(1000.0, 560.0, "b"),
            ]
        15:
            lv.name = "15 温室之巅"
            lv.pools = [pool("poison", 420.0, 140.0)]
            lv.ents = [
                plat(900.0, 520.0, 100.0), plat(1040.0, 440.0, 100.0),
                plat(900.0, 360.0, 100.0), plat(1040.0, 280.0, 100.0),
                mover(620.0, 300.0, 620.0, 900.0, 110.0, 2.0),
                plat(470.0, 300.0, 100.0), plat(350.0, 240.0, 80.0),
                plat(240.0, 180.0, 150.0),
                elev(60.0, 340.0, 180.0, 540.0, ["pb"]),
                plate(50.0, 596.0, "pb", "b"),
                checkpoint(700.0, 556.0),
                gem(1090.0, 400.0, "r"), gem(490.0, 540.0, "b"),
            ]
            lv.exits = [[265.0, "r"], [330.0, "b"]]
        16:
            lv.name = "16 热光引路"
            lv.ents = [
                wall(584.0, 200.0, 16.0, 404.0),
                wall(626.0, 200.0, 16.0, 284.0),
                iceblk(600.0, 484.0, 26.0, 120.0),
                beam(613.0, 300.0, "S", "hot", false, []),
                plat(170.0, 510.0, 60.0),
                gem(613.0, 450.0, "b"), gem(200.0, 480.0, "r"),
            ]
        17:
            lv.name = "17 寒光造桥"
            lv.pools = [pool("water", 560.0, 320.0)]
            lv.ents = [
                plat(880.0, 560.0, 160.0),
                lever(940.0, 552.0, "l1"),
                wall(912.0, 540.0, 16.0, 64.0),
                beam(908.0, 560.0, "W", "cold", false, ["l1"]),
                plat(170.0, 510.0, 60.0),
                gem(200.0, 480.0, "r"), gem(720.0, 540.0, "b"),
            ]
        18:
            lv.name = "18 融冰为阶"
            lv.pools = [pool("water", 860.0, 80.0)]
            lv.ents = [
                iceblk(400.0, 558.0, 46.0, 46.0),
                wall(584.0, 200.0, 16.0, 404.0),
                wall(626.0, 200.0, 16.0, 284.0),
                iceblk(600.0, 484.0, 26.0, 120.0),
                beam(613.0, 300.0, "S", "hot", true, []),
                beam(900.0, 300.0, "S", "cold", true, []),
                plat(480.0, 480.0, 60.0), plat(620.0, 500.0, 60.0), plat(740.0, 440.0, 70.0),
                esw(773.0, 432.0),
                gem(505.0, 450.0, "r"), gem(900.0, 540.0, "b"),
            ]
        19:
            lv.name = "19 光路哨兵"
            lv.ents = [
                beam(300.0, 470.0, "E", "sig", false, []),
                mirror(600.0, 470.0, false),
                recv(600.0, 330.0, "r1"),
                door(700.0, 444.0, 160.0, ["r1"]),
                beam(300.0, 380.0, "E", "sig", false, []),
                mirror(500.0, 380.0, false),
                recv(500.0, 270.0, "r2"),
                door(800.0, 444.0, 160.0, ["r2"]),
                plat(420.0, 430.0, 60.0),
                gem(450.0, 400.0, "r"), gem(1100.0, 540.0, "b"),
            ]
        20:
            lv.name = "20 树冠之心"
            lv.pools = [pool("water", 860.0, 80.0)]
            lv.ents = [
                wall(584.0, 200.0, 16.0, 404.0),
                wall(626.0, 200.0, 16.0, 284.0),
                iceblk(600.0, 484.0, 26.0, 120.0),
                beam(613.0, 300.0, "S", "hot", false, []),
                block(450.0, 437.0),
                beam(300.0, 460.0, "E", "sig", false, []),
                mirror(600.0, 460.0, false),
                recv(600.0, 320.0, "r1"),
                beam(900.0, 260.0, "S", "cold", false, ["r1"]),
                door(1040.0, 444.0, 160.0, ["r1"]),
                plat(430.0, 360.0, 60.0),
                gem(460.0, 330.0, "r"), gem(900.0, 540.0, "b"),
            ]
        21:
            lv.name = "21 初见水晶"
            lv.floors = [seg(0.0, 560.0), pit(560.0, 840.0), seg(840.0, 1280.0)]
            lv.ents = [
                portal(460.0, 540.0, 860.0, 540.0, "pair"),
                gem(700.0, 610.0, "b"), gem(335.0, 440.0, "r"),
                plat(300.0, 470.0, 70.0),
            ]
        22:
            lv.name = "22 镜面对折"
            lv.ents = [
                wall(620.0, 240.0, 16.0, 364.0),
                portal(560.0, 540.0, 690.0, 540.0, "pair"),
                lever(400.0, 560.0, "l1"),
                door(760.0, 444.0, 160.0, ["l1"]),
                plate(860.0, 596.0, "p1", "f"),
                door(930.0, 320.0, 120.0, ["p1"]),
                plat(960.0, 440.0, 90.0),
                gem(1000.0, 410.0, "b"), gem(200.0, 480.0, "r"),
            ]
        23:
            lv.name = "23 黑暗中的萤火"
            lv.pools = [pool("poison", 500.0, 100.0)]
            lv.ents = [
                darkzone(0.0, 150.0, 1280.0, 470.0, "pl"),
                lever(300.0, 560.0, "l1"),
                door(640.0, 444.0, 160.0, ["l1"]),
                plate(700.0, 596.0, "pl", "f"),
                gem(450.0, 540.0, "r"), gem(760.0, 540.0, "b"),
            ]
        24:
            lv.name = "24 单行水晶"
            lv.ents = [
                wall(560.0, 200.0, 16.0, 244.0),
                door(552.0, 444.0, 160.0, ["p1"]),
                plate(420.0, 596.0, "p1", "n"),
                block(300.0, 558.0),
                portal(250.0, 500.0, 700.0, 500.0, "a2b"),
                plat(380.0, 470.0, 60.0),
                gem(410.0, 440.0, "r"), gem(780.0, 540.0, "b"),
            ]
        25:
            lv.name = "25 矿井之心"
            lv.pools = [pool("poison", 620.0, 80.0)]
            lv.ents = [
                darkzone(0.0, 150.0, 1280.0, 470.0, "c1"),
                wall(560.0, 240.0, 16.0, 204.0),
                portal(846.0, 540.0, 916.0, 540.0, "pair"),
                beam(250.0, 470.0, "E", "sig", false, []),
                mirror(450.0, 470.0, false),
                recv(450.0, 330.0, "r1"),
                plate(930.0, 596.0, "p1", "n"),
                plate(990.0, 596.0, "p2", "n"),
                chain("c1", ["r1", "p1", "p2"]),
                door(1040.0, 444.0, 160.0, ["c1"]),
                gem(450.0, 430.0, "r"), gem(960.0, 520.0, "b"),
            ]
        26:
            lv.name = "26 元素法庭"
            lv.pools = [pool("water", 760.0, 80.0)]
            lv.ents = [
                wall(384.0, 200.0, 16.0, 404.0),
                wall(426.0, 200.0, 16.0, 284.0),
                iceblk(400.0, 484.0, 26.0, 120.0),
                beam(405.0, 300.0, "S", "hot", true, []),
                beam(800.0, 300.0, "S", "cold", true, []),
                plat(500.0, 530.0, 70.0), plat(580.0, 480.0, 100.0),
                esw(625.0, 472.0),
                plate(300.0, 596.0, "pL", "f"),
                bmov(Rect2(660.0, 540.0, 70.0, 12.0), "pL"),
                plate(870.0, 596.0, "pR", "f"),
                door(1000.0, 444.0, 160.0, ["pR"]),
                gem(413.0, 450.0, "r"), gem(800.0, 540.0, "b"),
            ]
        27:
            lv.name = "27 三重奏之门"
            lv.ents = [
                plat(600.0, 500.0, 60.0), plat(670.0, 420.0, 70.0),
                beam(500.0, 380.0, "E", "sig", false, []),
                mirror(700.0, 380.0, false),
                recv(700.0, 240.0, "r2"),
                block(700.0, 558.0),
                plate(900.0, 596.0, "p3", "f"),
                plate(960.0, 596.0, "pr", "r"),
                chain("c1", ["pr", "r2", "p3"]),
                door(1040.0, 444.0, 160.0, ["c1"]),
                gem(630.0, 470.0, "r"), gem(940.0, 540.0, "b"),
            ]
        28:
            lv.name = "28 错位回廊"
            lv.ents = [
                wall(628.0, 240.0, 16.0, 364.0),
                swapportal(640.0, 520.0, "pr"),
                plate(900.0, 596.0, "pr", "r"),
                gem(60.0, 460.0, "r"), gem(1220.0, 460.0, "b"),
            ]
            lv.exits = [[100.0, "r"], [1180.0, "b"]]
        29:
            lv.name = "29 月蚀倒计时"
            lv.pools = [pool("water", 560.0, 40.0)]
            lv.ents = [
                mover(140.0, 520.0, 140.0, 250.0, 100.0, 0.0),
                timdoor(300.0, 444.0, 160.0, 5.0, 0.3, 0.0),
                timdoor(500.0, 444.0, 160.0, 5.0, 0.3, 1.5),
                timdoor(700.0, 444.0, 160.0, 5.0, 0.3, 3.0),
                timdoor(900.0, 444.0, 160.0, 5.0, 0.3, 4.5),
                checkpoint(740.0, 556.0),
                gem(760.0, 540.0, "r"), gem(340.0, 500.0, "b"),
            ]
        30:
            lv.name = "30 月门圣所"
            lv.pools = [pool("fire", 300.0, 70.0), pool("water", 400.0, 70.0), pool("fire", 500.0, 70.0), pool("water", 600.0, 70.0)]
            lv.ents = [
                block(760.0, 558.0),
                plate(820.0, 596.0, "p1", "n"),
                door(880.0, 444.0, 160.0, ["p1"]),
                wall(60.0, 240.0, 16.0, 364.0),
                wall(300.0, 240.0, 16.0, 204.0),
                elev(140.0, 540.0, 180.0, 540.0, ["p2", "l2"]),
                plate(40.0, 596.0, "p2", "n"),
                lever(200.0, 172.0, "l2"),
                plat(170.0, 460.0, 60.0), plat(240.0, 380.0, 60.0), plat(170.0, 300.0, 60.0),
                plat(300.0, 220.0, 750.0),
                darkzone(350.0, 140.0, 600.0, 80.0, ""),
                beam(500.0, 205.0, "E", "sig", false, []),
                mirror(700.0, 205.0, false),
                recv(700.0, 145.0, "r1"),
                door(950.0, 130.0, 90.0, ["r1"]),
                gem(450.0, 560.0, "r"), gem(840.0, 540.0, "b"),
                gem(200.0, 300.0, "r"), gem(600.0, 170.0, "b"),
                gem(760.0, 120.0, "r"), gem(950.0, 560.0, "b"),
            ]
    return lv
