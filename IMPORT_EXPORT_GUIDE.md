# 导入导出功能实现指南

## 概述
为应用添加了完整的数据导入导出功能，支持学生名单、点名记录和统计报告的导出，以及学生名单的导入。

## 核心功能

### 1. 导出功能

#### 导出学生名单
- **格式**：CSV
- **包含内容**：班级名称、学生姓名、学号、被点名次数、平均分
- **用途**：备份、转移、数据分析

#### 导出点名记录
- **格式**：CSV
- **包含内容**：班级名称、学生姓名、学号、点名时间、评分、备注
- **用途**：历史查询、数据分析、审计

#### 生成统计报告
- **格式**：CSV
- **包含内容**：班级统计、学生排名、总体数据
- **用途**：总结分析、汇报、存档

### 2. 导入功能

#### 导入学生名单
- **格式**：CSV
- **要求**：班级名称、学生姓名、学号
- **流程**：选择文件 → 预览 → 确认导入

## 文件结构

```
lib/
├── core/
│   └── services/
│       └── import_export_service.dart    # 导入导出服务
└── features/
    └── class_management/
        └── widgets/
            ├── export_dialog.dart         # 导出对话框
            └── import_students_dialog.dart # 导入对话框
```

## 使用方式

### 导出数据

1. 在班级列表页面，点击班级的菜单按钮
2. 选择"导出数据"
3. 在对话框中选择导出类型：
   - 导出学生名单
   - 导出点名记录
   - 生成统计报告
4. 等待导出完成
5. 查看导出文件路径

### 导入数据

1. 在班级列表页面，点击班级的菜单按钮
2. 选择"导入学生"（未来功能）
3. 选择 CSV 文件
4. 预览导入数据
5. 确认导入

## CSV 文件格式

### 学生名单格式
```csv
班级名称,学生姓名,学号,被点名次数,平均分
班级A,张三,001,5,4.20
班级A,李四,002,3,3.67
班级A,王五,003,0,0.00
```

### 点名记录格式
```csv
班级名称,学生姓名,学号,点名时间,评分,备注
班级A,张三,001,2026-03-10 10:30:45,5,
班级A,李四,002,2026-03-10 10:31:20,未评分,
班级A,王五,003,2026-03-10 10:32:00,4,
```

### 统计报告格式
```csv
班级统计报告

班级名称,班级A
生成时间,2026-03-10 14:30:00

总体统计
总学生数,50
参与点名学生数,45
总点名次数,120
已评分次数,115
平均分,4.15

学生排名
排名,学生姓名,学号,被点名次数,平均分
1,张三,001,5,4.80
2,李四,002,4,4.50
3,王五,003,3,4.33
```

## 技术实现

### 导出服务

```dart
// 导出学生名单
final filePath = await ImportExportService.exportStudentsToCSV(
  students,
  className,
);

// 导出点名记录
final filePath = await ImportExportService.exportRecordsToCSV(
  records,
  className,
);

// 生成统计报告
final filePath = await ImportExportService.generateStatisticsReport(
  students,
  records,
  className,
);
```

### 导入服务

```dart
// 导入学生名单
final students = await ImportExportService.importStudentsFromCSV(file);
```

## 依赖库

- `csv: ^6.0.0` - CSV 文件处理
- `path_provider: ^2.1.0` - 文件路径管理

## 文件存储位置

### 存储位置更新（2026-03-10）

为了让用户能够更容易地找到导出的文件，已将存储位置从应用私有目录改为外部存储：

**Android 存储位置：**
```
/storage/emulated/0/Android/data/{packageName}/files/
```

例如：
```
/storage/emulated/0/Android/data/fusuccess.top.classroom_roll_call/files/students_2_1773133345150.csv
```

**访问方式：**
1. 打开手机文件管理器
2. 导航到 **内部存储** → **Android** → **data** → **fusuccess.top.classroom_roll_call** → **files**
3. 找到导出的 CSV 文件

**其他平台：**
- iOS: `Documents/`
- Windows: `AppData/Local/`
- macOS: `Library/Application Support/`

**文件命名格式：**
```
{type}_{className}_{timestamp}.csv
```

例如：
- `students_班级A_1773133345150.csv` - 学生名单
- `records_班级A_1773133345150.csv` - 点名记录
- `report_班级A_1773133345150.csv` - 统计报告

### 权限配置

为了支持外部存储访问，已在 `AndroidManifest.xml` 中添加以下权限：
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
```

## 错误处理

### 导出错误
- 文件写入失败
- 权限不足
- 磁盘空间不足

### 导入错误
- 文件格式错误
- 数据不完整
- 编码问题

所有错误都会显示给用户，并提供重试选项。

## 性能考虑

### 导出性能
- 大数据集（1000+ 条记录）可能需要几秒
- 使用异步操作避免 UI 冻结
- 显示进度指示器

### 导入性能
- 文件解析在后台进行
- 大文件可能需要几秒
- 显示加载指示器

## 安全考虑

### 数据隐私
- 不导出敏感信息
- 用户可选择导出范围
- 导出文件由用户管理

### 数据完整性
- 导出前验证数据
- 导入时检查格式
- 错误时提示用户

## 未来改进

### 短期
1. 完整的导入功能实现
2. 支持 Excel 格式
3. 数据验证和清理

### 中期
1. 云备份功能
2. 数据同步
3. 批量操作

### 长期
1. 数据恢复功能
2. 版本控制
3. 数据加密

## 测试建议

### 功能测试
- 导出空班级
- 导出大量数据
- 导出特殊字符
- 导入各种格式

### 性能测试
- 导出 1000+ 条记录
- 导入大文件
- 并发操作

### 兼容性测试
- 不同 Excel 版本
- 不同操作系统
- 不同字符编码

## 常见问题

### Q: 导出的文件在哪里？
A: 文件存储在外部存储的应用数据目录：
- Android: `/storage/emulated/0/Android/data/{packageName}/files/`
- 通过文件管理器访问：**内部存储** → **Android** → **data** → **{packageName}** → **files**

### Q: 为什么改变了存储位置？
A: 之前使用应用私有目录，用户无法直接访问。现在改为外部存储，用户可以通过文件管理器轻松找到和管理导出的文件。

### Q: 可以导入 Excel 文件吗？
A: 目前只支持 CSV 格式，但 Excel 可以导出为 CSV。

### Q: 导入会覆盖现有数据吗？
A: 不会，导入是添加操作，不会删除现有数据。

### Q: 导出的数据包含隐私信息吗？
A: 导出的是学生学号和姓名，不包含其他隐私信息。

## 相关文件

- `lib/core/services/import_export_service.dart` - 导入导出服务
- `lib/features/class_management/widgets/export_dialog.dart` - 导出对话框
- `lib/features/class_management/widgets/import_students_dialog.dart` - 导入对话框
- `lib/features/class_management/class_list_screen.dart` - 班级列表页面

---

**实现时间：** 2026-03-10
**最后更新：** 2026-03-10 - 更新文件存储位置为外部存储
**状态：** 导出功能完成，导入功能框架完成
