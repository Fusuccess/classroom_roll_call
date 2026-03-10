# 应用图标配置指南

## 应用名称配置

已完成各平台的应用名称配置：

### ✅ Android
- 文件：`android/app/src/main/AndroidManifest.xml`
- 应用名称：课堂点名

### ✅ iOS
- 文件：`ios/Runner/Info.plist`
- 应用名称：课堂点名
- 显示名称：课堂点名

### ✅ macOS
- 文件：`macos/Runner/Configs/AppInfo.xcconfig`
- 应用名称：课堂点名
- Bundle ID：top.fusuccess.classroomRollCall
- 版权信息：Copyright © 2026 南漳云联软件技术工作室

### ✅ Web
- 文件：`web/index.html` 和 `web/manifest.json`
- 应用名称：课堂点名
- 短名称：点名
- 描述：课堂点名应用 - 随机点名、评分记录、统计分析

---

## 应用图标生成

### 方案一：使用 flutter_launcher_icons 插件（推荐）

#### 1. 添加依赖

在 `pubspec.yaml` 中添加：

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  
  # macOS 图标
  macos:
    generate: true
    image_path: "assets/icon/app_icon.png"
  
  # Web 图标
  web:
    generate: true
    image_path: "assets/icon/app_icon.png"
    background_color: "#2196F3"
    theme_color: "#2196F3"
  
  # Windows 图标（可选）
  windows:
    generate: true
    image_path: "assets/icon/app_icon.png"
    icon_size: 48
```

#### 2. 准备图标文件

创建一个 1024x1024 像素的 PNG 图标：
- 路径：`assets/icon/app_icon.png`
- 尺寸：1024x1024 px
- 格式：PNG（带透明背景）
- 内容建议：
  - 主题：点名、教育相关
  - 颜色：蓝色系（与应用主题一致）
  - 图标：可以是举手、名单、铃铛等元素

#### 3. 生成图标

```bash
# 安装依赖
flutter pub get

# 生成所有平台的图标
flutter pub run flutter_launcher_icons
```

#### 4. 验证

生成后会自动更新以下位置的图标：
- Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- macOS: `macos/Runner/Assets.xcassets/AppIcon.appiconset/`
- Web: `web/icons/Icon-*.png`

---

### 方案二：手动配置（不推荐）

如果不使用插件，需要手动为每个平台准备不同尺寸的图标：

#### Android 所需尺寸
- mipmap-mdpi: 48x48
- mipmap-hdpi: 72x72
- mipmap-xhdpi: 96x96
- mipmap-xxhdpi: 144x144
- mipmap-xxxhdpi: 192x192

#### iOS 所需尺寸
- 20x20, 29x29, 40x40, 58x58, 60x60, 76x76, 80x80, 87x87, 120x120, 152x152, 167x167, 180x180, 1024x1024

#### macOS 所需尺寸
- 16x16, 32x32, 64x64, 128x128, 256x256, 512x512, 1024x1024

#### Web 所需尺寸
- 192x192, 512x512

---

## 图标设计建议

### 设计原则
1. **简洁明了**：图标应该一眼就能识别
2. **主题相关**：与点名、教育相关
3. **颜色协调**：使用应用主题色（蓝色）
4. **适配性好**：在不同背景下都清晰可见

### 设计元素建议
- 📋 名单/清单图标
- ✋ 举手图标
- 🔔 铃铛图标
- 👥 人群图标
- ✓ 勾选图标
- 🎲 骰子图标（随机）

### 配色建议
- 主色：#2196F3（蓝色）
- 辅色：#FFFFFF（白色）
- 背景：可以是渐变或纯色

### 在线设计工具
- [Canva](https://www.canva.com/) - 免费图标设计
- [Figma](https://www.figma.com/) - 专业设计工具
- [IconKitchen](https://icon.kitchen/) - 在线图标生成器
- [AppIcon.co](https://appicon.co/) - 快速生成各平台图标

---

## 快速开始示例

### 使用简单的文字图标

如果暂时没有设计好的图标，可以使用文字图标：

1. 创建一个 1024x1024 的图片
2. 蓝色背景 (#2196F3)
3. 白色大字"点名"或"名"
4. 保存为 `assets/icon/app_icon.png`
5. 运行 `flutter pub run flutter_launcher_icons`

### 使用 emoji 图标（临时方案）

可以使用 emoji 作为临时图标：
- 📋 (U+1F4CB) - 剪贴板
- ✋ (U+270B) - 举手
- 🎲 (U+1F3B2) - 骰子

---

## 打包前检查清单

- [ ] 应用名称已配置（所有平台）
- [ ] 应用图标已生成（所有平台）
- [ ] Bundle ID 已设置（iOS/macOS）
- [ ] 版本号已更新（pubspec.yaml）
- [ ] 版权信息已填写
- [ ] 应用描述已更新

---

## 常见问题

### Q: 图标不显示怎么办？
A: 
1. 清理构建缓存：`flutter clean`
2. 重新生成图标：`flutter pub run flutter_launcher_icons`
3. 重新构建应用：`flutter build [platform]`

### Q: iOS 图标有白边？
A: 确保图标 PNG 文件没有透明背景，或者使用纯色背景。

### Q: Android 图标模糊？
A: 确保原始图标至少 1024x1024 像素，使用高质量 PNG。

### Q: macOS 图标不显示？
A: 需要重新构建应用，有时需要清理 Xcode 缓存。

---

## 版本信息

当前版本：1.0.0
Bundle ID：top.fusuccess.classroomRollCall
开发者：南漳云联软件技术工作室
网站：https://fusuccess.top

---

**更新时间：** 2026-03-10
