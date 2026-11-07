import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpus/widgets/admin/ModelBuku.dart';
import 'package:perpus/widgets/students/BackPill.dart';

class DetailBook extends StatelessWidget {
  final Buku? buku;
  const DetailBook({super.key, this.buku});

  Future<void> _ajukanPeminjaman(BuildContext context, Buku b) async {
    final nisn = SesiLogin.nisn ?? '1234567890';
    final nama = SesiLogin.nama ?? 'Siswa';
    final kelas = SesiLogin.kelas ?? 'XI';
    final gender = SesiLogin.gender ?? 'Laki-laki';

    try {
      await FirebaseFirestore.instance.collection('peminjaman').add({
        'nisn': nisn,
        'namaSiswa': nama,
        'kelasSiswa': kelas,
        'genderSiswa': gender,
        'isbn': b.isbn,
        'judulBuku': b.judul,
        'penerbit': b.penerbit,
        'kategoriBuku': b.kategori,
        'kodeInventaris': 'ONLINE-${b.isbn.substring(b.isbn.length > 4 ? b.isbn.length - 4 : 0)}',
        'status': 'pending',
        'waktuPinjam': Timestamp.now(),
        'deadline': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 7)),
        ),
        'waktuKembali': null,
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pengajuan peminjaman "${b.judul}" terkirim ke Admin!',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengajukan peminjaman: $e')),
      );
    }
  }

  Future<void> _simpanWishlist(BuildContext context, Buku b) async {
    final nisn = SesiLogin.nisn ?? '1234567890';
    try {
      await FirebaseFirestore.instance.collection('murid').doc(nisn).set({
        'wishlist': FieldValue.arrayUnion([b.judul]),
      }, SetOptions(merge: true));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${b.judul}" ditambahkan ke Wishlist!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan bookmark: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = buku ?? dummyBuku.first;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradientBack = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        (isDark ? Colors.black : Colors.white).withValues(
          alpha: isDark ? 0.65 : 0.75,
        ),
        (isDark ? Colors.black : Colors.white).withValues(alpha: 0.0),
      ],
    );
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      width: double.infinity,
                      color: colors.surfaceContainerHighest,
                      child: b.cover != null
                          ? Image.memory(b.cover!, fit: BoxFit.cover)
                          : Icon(
                              Icons.menu_book_rounded,
                              size: 60,
                              color: colors.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(gradient: gradientBack),
                      alignment: Alignment.centerLeft,
                      child: const Backpill(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.judul,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Kategori: ${b.kategori}',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Penerbit: ${b.penerbit}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ISBN: ${b.isbn}',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Stok Tersedia: ${b.stok}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _ajukanPeminjaman(context, b),
                        icon: const Icon(Icons.assignment_add, size: 18),
                        label: const Text(
                          'Ajukan Peminjaman',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.surfaceContainerHighest,
                          foregroundColor: colors.onSurface,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 70,
                    height: 48,
                    child: IconButton(
                      onPressed: () => _simpanWishlist(context, b),
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surfaceContainerHighest,
                        foregroundColor: colors.onSurfaceVariant,
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.bookmark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
