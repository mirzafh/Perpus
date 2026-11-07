import 'package:flutter/material.dart';

class Backpill extends StatelessWidget {
  final VoidCallback? onTap;
  const Backpill({super.key, this.onTap});
  @override
  Widget build(BuildContext context) {
    final colorOutline = Theme.of(context).colorScheme.outline;
    final colorIcon = Theme.of(context).colorScheme.primary;
    final colorBoxSekunder = Theme.of(context).colorScheme.surfaceContainerHigh;
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colorBoxSekunder,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1.5, color: colorOutline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_ios_new, size: 16, color: colorIcon),
            SizedBox(width: 8),
            Text(
              'Back',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colorIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
