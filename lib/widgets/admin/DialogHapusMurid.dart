import 'package:flutter/material.dart';

class DialogHapusMurid extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final bool destructiveAll;

  const DialogHapusMurid({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Hapus',
    this.destructiveAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      icon: Icon(
        Icons.warning_amber_rounded,
        color: colors.error,
        size: 34,
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
