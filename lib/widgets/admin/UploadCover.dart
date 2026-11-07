import 'dart:typed_data';
import 'dart:ui' as ui;

/// Firebase Storage butuh paket Blaze (berbayar), jadi cover disimpan
/// langsung di Firestore sebagai gambar kecil (base64).
/// Class ini hanya mengecilkan gambar supaya muat di batas 1 MB dokumen Firestore.
class UploadCover {
  static Future<Uint8List> kompres(Uint8List bytes) async {
    for (final lebar in [280, 200, 140]) {
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: lebar);
      final frame = await codec.getNextFrame();
      final data =
          await frame.image.toByteData(format: ui.ImageByteFormat.png);
      frame.image.dispose();
      if (data == null) continue;
      final hasil = data.buffer.asUint8List();
      // base64 menambah ukuran ~33%, jaga tetap jauh di bawah 1 MB
      if (hasil.length * 4 / 3 < 700000) return hasil;
    }
    throw Exception('Ukuran gambar terlalu besar, pilih gambar lain');
  }
}
