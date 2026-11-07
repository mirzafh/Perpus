import 'package:flutter/material.dart';

class PopupDeadline {
  static Future<DateTime?> tampilkan(
    BuildContext context, {
    DateTime? tanggalAwal,
  }) {
    final sekarang = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: tanggalAwal ?? sekarang.add(
        const Duration(days: 7),
      ),
      firstDate: DateTime(
        sekarang.year,
        sekarang.month,
        sekarang.day,
      ),
      lastDate: sekarang.add(
        const Duration(days: 365),
      ),
      helpText: 'Pilih Tanggal Pengembalian',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
  }
}
