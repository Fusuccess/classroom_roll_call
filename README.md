# 课堂点名应用

一个跨平台的课堂点名应用，支持 iOS、Android、macOS、Windows 和 Web。

## 功能特性

- ✅ 班级管理：创建和管理多个班级
- ✅ 学生管理：添加、编辑学生信息
- ✅ 随机点名：支持多种点名模式
- ✅ 评分记录：记录学生回答质量
- ✅ 统计分析：查看点名历史和统计数据
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

1. 实现完整的数据持久化
2. 添加导入/导出功能（Excel/CSV）
3. 实现点名动画效果
4. 添加语音播报
