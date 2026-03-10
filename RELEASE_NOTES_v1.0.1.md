# 课堂点名 v1.0.1 发布说明

**发布日期**：2026-03-10  
**版本号**：1.0.1 (Build 2)

---

## 📋 版本概述

v1.0.1 是 v1.0.0 的维护和功能增强版本，主要聚焦于**导入导出功能**、**页面布局优化**和**数据验证增强**。

---

## ✨ 主要更新

### 1️⃣ 导入导出功能（核心新增）

#### 导入学生数据
- **支持格式**：CSV 文件
- **自动列匹配**：智能识别"学生姓名"和"学号"列
  - 支持中文列名：`学生姓名`、`学号`
  - 支持英文列名：`Name`、`Student ID`
  - 支持混合列名
- **灵活适配**：可导入来自其他系统的 CSV 文件（自动忽略多余列）
- **无需手动选择**：系统自动检测和匹配列

#### 导出功能
- **导出学生信息**：包含姓名、学号、点名次数、平均分
- **导出点名记录**：包含学生信息、点名时间、评分
- **生成统计报告**：班级统计、学生排名、分数分布

#### 文件位置
- **保存位置**：手机 Download 文件夹（`/storage/emulated/0/Download/`）
- **易于查找**：用户可直接在文件管理器中找到导出文件
- **文件命名**：带时间戳，便于区分多个导出文件

#### 权限配置
- Android 已配置必要权限：
  - `READ_EXTERNAL_STORAGE`
  - `WRITE_EXTERNAL_STORAGE`
  - `MANAGE_EXTERNAL_STORAGE`

---

### 2️⃣ 页面布局优化

#### 评分按钮响应式设计
**问题**：5 个评分按钮在小屏幕上换行，影响用户体验

**解决方案**：
- 减小按钮间距：`spacing: 4`（原 8）
- 减小按钮 padding：`horizontal: 12, vertical: 8`（原 20, 12）
- 减小字体大小：`fontSize: 14`（原 16）
- 减小图标大小：`size: 14`（原 16）
- 简化按钮文本：显示"5"而非"5分"

**效果**：5 个按钮在所有屏幕尺寸上保持一行显示

---

### 3️⃣ 数据验证增强

#### 学号必填
- 添加学生时必须输入学号
- 导入时自动验证学号不为空
- 防止数据不完整

---

## 🔧 技术改进

### 依赖更新
```yaml
file_picker: ^8.0.0  # 从 6.1.0 升级
```

**升级原因**：
- 解决 Android v1 embedding 兼容性问题
- 支持最新 Android 编译工具链
- 改进文件选择器性能

### 代码优化
- 新增 `ImportExportService` 类
  - 统一管理导入导出逻辑
  - 支持 CSV 解析和生成
  - 平台适配（Android/iOS）
- 改进 CSV 列匹配算法
  - 支持多种列名格式
  - 自动去除空格和大小写差异
  - 智能列检测

---

## 📁 文件变更

### 新增文件
- `lib/core/services/import_export_service.dart` - 导入导出服务
- `lib/features/class_management/widgets/import_class_dialog.dart` - 导入对话框
- `IMPORT_EXPORT_COMPLETE_GUIDE.md` - 完整导入导出指南
- `DOCUMENTATION_SUMMARY.md` - 文档汇总说明
- `RELEASE_NOTES_v1.0.1.md` - 本文件

### 修改文件
- `pubspec.yaml` - 版本号和依赖更新
- `lib/features/roll_call/roll_call_screen.dart` - 评分按钮优化
- `lib/features/class_management/class_list_screen.dart` - 添加导入按钮
- `android/app/src/main/AndroidManifest.xml` - 权限配置
- `CHANGELOG.md` - 更新日志

### 删除文件（文档整合）
- ANDROID_IMPORT_ADAPTATION.md
- CHANGELOG_IMPORT_FEATURE.md
- EXPORT_IMPORT_IMPROVEMENTS.md
- EXPORT_LOCATION_UPDATE.md
- FLEXIBLE_IMPORT_GUIDE.md
- IMPORT_CHECKLIST.md
- IMPORT_EXPORT_GUIDE.md
- IMPORT_FEATURE_GUIDE.md
- IMPORT_FEATURE_IMPLEMENTATION.md
- IMPORT_IMPLEMENTATION_SUMMARY.md
- IMPORT_QUICK_START.md
- IMPORT_USAGE_GUIDE.md
- SIMPLIFIED_IMPORT_GUIDE.md

---

## 🚀 使用指南

### 导入学生数据

1. 打开应用，进入班级管理页面
2. 点击底部"导入"按钮
3. 选择 CSV 文件
4. 系统自动匹配"学生姓名"和"学号"列
5. 确认导入

**CSV 文件要求**：
- 必须包含"学生姓名"和"学号"列
- 支持其他额外列（系统会自动忽略）
- 编码：UTF-8

### 导出数据

1. 进入统计分析页面
2. 点击导出按钮
3. 选择导出类型：
   - 学生信息
   - 点名记录
   - 统计报告
4. 文件自动保存到 Download 文件夹

---

## 🐛 Bug 修复

| Bug | 原因 | 修复 |
|-----|------|------|
| file_picker 编译错误 | Android v1 embedding 移除 | 升级到 v8.0.0 |
| 导入后白屏 | 对话框状态管理问题 | 改进错误处理 |
| 评分按钮换行 | 屏幕宽度不足 | 优化按钮尺寸 |

---

## 📊 版本对比

| 功能 | v1.0.0 | v1.0.1 |
|------|--------|--------|
| 班级管理 | ✅ | ✅ |
| 学生管理 | ✅ | ✅ |
| 随机点名 | ✅ | ✅ |
| 评分功能 | ✅ | ✅ |
| 统计分析 | ✅ | ✅ |
| **导入导出** | ❌ | ✅ |
| **学号必填** | ⚠️ | ✅ |
| **响应式按钮** | ❌ | ✅ |

---

## 🔄 升级建议

### 从 v1.0.0 升级到 v1.0.1

**无需数据迁移**：所有现有数据完全兼容

**升级步骤**：
1. 卸载旧版本（可选，保留数据）
2. 安装 v1.0.1
3. 享受新功能

---

## 📝 已知限制

- 导入时不支持自定义列映射（系统自动匹配）
- 导出文件格式仅支持 CSV
- 点名记录导入功能预留至 v1.1.0

---

## 🎯 下一步计划（v1.1.0）

- [ ] 点名记录导入功能
- [ ] 数据备份和恢复
- [ ] 更多统计图表
- [ ] 语音播报学生姓名
- [ ] 自定义主题色

---

## 📞 反馈和支持

如有问题或建议，请通过以下方式联系：
- 网站：https://fusuccess.top
- 开发者：南漳云联软件技术工作室

---

**感谢使用课堂点名！** 🎉
