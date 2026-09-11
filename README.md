# Mosslight — Godot Web Game

一个受双角色协作平台玩法启发的原创 Godot 4 网页游戏原型。Ember 与 Tide 必须分别避开对方的元素池，共同抵达月门。

当前设计包含 30 个递进关卡（详见 DESIGN.md）。每关设置 120 秒最短挑战时间与 600 秒最长时限，必须两名玩家配合完成。

## 运行

使用 Godot 4.2+ 打开本目录，运行 `Main.tscn`。

- Ember：`A / D` 移动，`W` 跳跃
- Tide：方向键移动，`↑` 跳跃
- `R` 重置关卡

通过 Project → Export → Web 导出 HTML5；项目使用 Compatibility 渲染器以获得更广泛的浏览器支持。

## 一条命令运行

Linux / macOS（首次运行会自动下载 Godot 4.3 headless）：

```bash
chmod +x run_web.sh scripts/build_web.sh
./run_web.sh
```

macOS 用户请先安装 Godot：`brew install --cask godot`。脚本会优先使用系统 Godot；Linux 才会自动下载 headless 二进制。

然后访问 `http://localhost:8080`。可用 `PORT=3000 ./run_web.sh` 修改端口。

## 服务器部署

服务器安装 Docker 后执行：

```bash
docker build -t mosslight . && docker run -d --name mosslight -p 8080:8080 mosslight
```

容器会在构建阶段导出 Web 版本，运行阶段只提供静态文件，不需要在服务器安装 Godot。
