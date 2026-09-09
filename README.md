# Mosslight — Godot Web Game

一个受双角色协作平台玩法启发的原创 Godot 4 网页游戏原型。Ember 与 Tide 必须分别避开对方的元素池，共同抵达月门。

当前设计包含 30 个递进关卡（详见 DESIGN.md）。每关设置 120 秒最短挑战时间与 600 秒最长时限，必须两名玩家配合完成。

## 运行

使用 Godot 4.2+ 打开本目录，运行 `Main.tscn`。

- Ember：`A / D` 移动，`W` 跳跃
- Tide：方向键移动，`↑` 跳跃
- `R` 重置关卡

通过 Project → Export → Web 导出 HTML5；项目使用 Compatibility 渲染器以获得更广泛的浏览器支持。
