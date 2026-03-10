# 课堂点名应用

一个跨平台的课堂点名应用，支持 iOS、Android、macOS、Windows 和 Web。

## 功能特性

- ✅ 班级管理：创建和管理多个班级
- ✅ 学生管理：添加、编辑学生信息（学号必填）
- ✅ 随机点名：支持多种点名模式
- ✅ 评分记录：记录学生回答质量
- ✅ 统计分析：查看点名历史和统计数据
- ✅ 导入功能：从 CSV 文件导入班级和学生信息（自动列匹配）
- ✅ 导出功能：导出班级、学生和点名记录到 CSV
- ✅ 响应式设计：适配各种屏幕尺寸
- ✅ 跨平台：支持所有主流平台

## 技术栈

- Flutter 3.x
- Riverpod (状态管理)
- Hive (本地存储)
- Go Router (路由)
- Material Design 3

## 快速开始

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Web
flutter run -d chrome
```

### 构建发布版本

```bash
# iOS
flutter build ios

# Android
flutter build apk

# macOS
flutter build macos

# Windows
flutter build windows

# Web
flutter build web
```

## 项目结构

```
lib/
├── core/
│   ├── models/          # 数据模型
│   ├── providers/       # Riverpod 状态管理
│   ├── services/        # 业务服务
│   ├── router/          # 路由配置
│   └── theme/           # 主题配置
└── features/
    ├── home/            # 首页
    ├── roll_call/       # 点名功能
    ├── class_management/# 班级管理
    └── statistics/      # 统计分析
```

## 下一步开发

1. ✅ 导入/导出功能（CSV）- 已完成（v1.0.1）
2. ✅ 学号必填验证 - 已完成（v1.0.1）
3. ✅ 页面布局优化 - 已完成（v1.0.1）
4. 导入点名记录功能（v1.1.0）
5. 支持 Excel 格式（v1.1.0）
6. 数据备份和恢复（v1.1.0）
7. 更多统计图表（v1.1.0）
8. 语音播报功能（v1.2.0）
9. 云备份功能（v1.2.0）

## 文档

- [导入导出完整指南](IMPORT_EXPORT_COMPLETE_GUIDE.md)
- [v1.0.1 发布说明](RELEASE_NOTES_v1.0.1.md)
- [v1.0.1 快速参考](v1.0.1_QUICK_REFERENCE.md)
- [版本历史](CHANGELOG.md)
