import 'package:flutter/material.dart';
import 'package:perpus/widgets/admin/ModelBuku.dart';

Future<bool> dialogHapusBuku(
  BuildContext context,
  Buku buku,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final colors = Theme.of(context).colorScheme;

      return AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: colors.error,
          size: 36,
        ),
        title: const Text('Hapus Buku?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus buku "${buku.judul}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
