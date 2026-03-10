import 'package:flutter/material.dart';

class RollCallSettingsDialog extends StatefulWidget {
  final bool initialAvoidRepeat;
  final Function(bool avoidRepeat) onSave;

  const RollCallSettingsDialog({
    super.key,
    required this.initialAvoidRepeat,
    required this.onSave,
  });

  @override
  State<RollCallSettingsDialog> createState() => _RollCallSettingsDialogState();
}

class _RollCallSettingsDialogState extends State<RollCallSettingsDialog> {
  late bool avoidRepeat;

  @override
  void initState() {
    super.initState();
    avoidRepeat = widget.initialAvoidRepeat;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('点名设置'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('避免重复点名'),
            subtitle: const Text('已点名的学生不会再次被选中'),
            value: avoidRepeat,
            onChanged: (value) {
              setState(() => avoidRepeat = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSave(avoidRepeat);
            Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
