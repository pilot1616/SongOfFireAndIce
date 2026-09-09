# Sketchfab 模型接入清单

## 选型标准

为避免网页发行时的版权问题，项目只接入 Sketchfab 页面明确标注为 Creative Commons（CC BY / CC0 等）且允许下载的资产。优先选择低面数、单材质、`.glb` 格式模型，以控制 HTML5 首屏体积。

## 推荐模型类型

- Stylized tree / low poly tree：放置在远景林冠和关卡边缘
- Ancient stone arch / ruin gate：替换 Moon Gate 的程序化拱门
- Glowing crystal / fire orb / water orb：替换元素池顶部装饰
- Stylized character base：仅在确认骨骼授权后替换 Ember/Tide 圆形角色

## 导入流程

1. 将已确认授权的 `.glb` 放入 `assets/sketchfab/`。
2. 在 Godot 中拖入场景，开启 Mesh LOD 或手动限制材质贴图尺寸。
3. 对每个模型保留来源、作者、许可证和原始页面 URL，填写下方记录表。
4. 网页导出前检查包体，单个模型建议小于 2 MB。

## 来源记录

| 用途 | 模型 / 作者 | 许可证 | 原始 URL | 已下载 |
|---|---|---|---|---|
| 远景树木 | 待选择 | 待确认 | 待提供 | 否 |
| 月门 | 待选择 | 待确认 | 待提供 | 否 |
| 元素晶体 | 待选择 | 待确认 | 待提供 | 否 |

当前浏览器连接无法访问 Sketchfab 详情页，因此尚未将未核验模型写入项目。提供具体链接后再导入，避免把不可再分发资产打包进 HTML5。
