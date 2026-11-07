import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpus/main.dart';
import 'package:perpus/widgets/students/BackPill.dart';

class NotificationAdmin extends StatefulWidget {
  const NotificationAdmin({super.key});

  @override
  State<NotificationAdmin> createState() => _NotificationAdminState();
}

class _NotificationAdminState extends State<NotificationAdmin> {
  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> updateStatus(
    DocumentSnapshot doc,
    String newStatus,
  ) async {
    try {
      final data = doc.data() as Map<String, dynamic>;
      final db = FirebaseFirestore.instance;

      // Cegah diproses dua kali
      if ((data['status'] ?? 'pending') != 'pending') {
        _pesan('Pengajuan ini sudah diproses.');
        return;
      }

      final batch = db.batch();

      if (newStatus == 'approved') {
        final isbn = (data['isbn'] ?? '').toString();

        // Cek stok sebelum menyetujui
        if (isbn.isNotEmpty) {
          final bukuSnap = await db.collection('buku').doc(isbn).get();
          final stok = (bukuSnap.data()?['stok'] is num)
              ? (bukuSnap.data()!['stok'] as num).toInt()
              : 0;
          if (!bukuSnap.exists || stok <= 0) {
            _pesan('Stok buku habis, pengajuan tidak bisa disetujui.');
            return;
          }
        }

        batch.update(doc.reference, {
          'status': 'dipinjam',
          'waktuPinjam': Timestamp.now(),
          'deadline': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 7)),
          ),
        });

        if (isbn.isNotEmpty) {
          batch.update(db.collection('buku').doc(isbn), {
            'stok': FieldValue.increment(-1),
            'dipinjamCount': FieldValue.increment(1),
          });
        }

        // Streak bertambah saat peminjaman benar-benar terjadi (disetujui),
        // bukan saat siswa mengajukan.
        final nisnSiswa = (data['nisn'] ?? '').toString();
        if (nisnSiswa.isNotEmpty) {
          batch.set(
            db.collection('murid').doc(nisnSiswa),
            {'streak': FieldValue.increment(1)},
            SetOptions(merge: true),
          );
        }

        batch.set(db.collection('notifikasi').doc(), {
          'nisn': data['nisn'],
          'title': 'Buku Siap Diambil',
          'subtitle':
              'Pengajuan peminjaman buku "${data['judulBuku']}" telah disetujui Admin.',
          'type': 'success',
          'waktu': Timestamp.now(),
          'dibaca': false,
        });
      } else {
        batch.update(doc.reference, {'status': 'ditolak'});
        batch.set(db.collection('notifikasi').doc(), {
          'nisn': data['nisn'],
          'title': 'Pengajuan Ditolak',
          'subtitle':
              'Maaf, pengajuan buku "${data['judulBuku']}" belum dapat disetujui.',
          'type': 'warning',
          'waktu': Timestamp.now(),
          'dibaca': false,
        });
      }

      await batch.commit();
      _pesan(newStatus == 'approved'
          ? 'Pengajuan disetujui.'
          : 'Pengajuan ditolak.');
    } catch (e) {
      _pesan('Gagal memproses pengajuan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Gradient backgroundGradient =
        isDark ? Warna.darkGreenRadialGlow : Warna.lightGreenRadialGlow;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final colorBox = colors.surfaceContainerHigh;
    final colorOutline = colors.outline;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colorOutline, width: 3),
                  ),
                ),
                child: Row(
                  children: [
                    const Backpill(),
                    const SizedBox(width: 20),
                    Text(
                      'Notifikasi Pengajuan',
                      style: TextStyle(
                        fontSize: 28,
                        color: colors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('peminjaman')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final batas =
                        DateTime.now().subtract(const Duration(days: 1));
                    DateTime waktuDoc(QueryDocumentSnapshot d) {
                      final m = d.data() as Map<String, dynamic>;
                      return (m['waktuPinjam'] as Timestamp?)?.toDate() ??
                          DateTime.now();
                    }

                    // Terbaru -> terlama. Yang sudah diproses & lewat 1 hari
                    // disembunyikan dari daftar (data peminjaman TIDAK dihapus).
                    // Pengajuan yang masih pending tetap tampil sampai diproses.
                    final docs = (snapshot.data?.docs ?? []).where((d) {
                      final m = d.data() as Map<String, dynamic>;
                      final st = (m['status'] ?? 'pending').toString();
                      if (st == 'pending') return true;
                      return !waktuDoc(d).isBefore(batas);
                    }).toList()
                      ..sort((a, b) => waktuDoc(b).compareTo(waktuDoc(a)));
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          'Belum ada permintaan peminjaman dari siswa.',
                          style: TextStyle(color: colors.onSurface),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 30,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final request = doc.data() as Map<String, dynamic>;
                        final status = (request['status'] ?? 'pending').toString();
                        final waktu =
                            (request['waktuPinjam'] as Timestamp?)?.toDate();
                        final waktuStr = waktu != null
                            ? '${waktu.day}/${waktu.month}/${waktu.year} ${waktu.hour}:${waktu.minute.toString().padLeft(2, '0')}'
                            : 'Baru saja';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorBox,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: colorOutline,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: colorBox,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorOutline,
                                    width: 4,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 40,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (request['namaSiswa'] ?? '-')
                                                    .toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: colors.onSurface,
                                                ),
                                              ),
                                              Text(
                                                '${request['nisn'] ?? '-'}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: colors.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            (request['judulBuku'] ?? '-')
                                                .toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: colors.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            waktuStr,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: colors.onSurface,
                                            ),
                                          ),
                                        ),
                                        if (status == 'pending') ...[
                                          _statusButton(
                                            text: 'Setujui',
                                            color: const Color(0xFF9DE52D),
                                            onPressed: () =>
                                                updateStatus(doc, 'approved'),
                                          ),
                                          const SizedBox(width: 12),
                                          _statusButton(
                                            text: 'Tolak',
                                            color: const Color(0xFFE51C23),
                                            onPressed: () =>
                                                updateStatus(doc, 'rejected'),
                                          ),
                                        ] else ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: status == 'ditolak'
                                                  ? const Color(0xFFE51C23)
                                                  : const Color(0xFF9DE52D),
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                            ),
                                            child: Text(
                                              status == 'ditolak'
                                                  ? 'Ditolak'
                                                  : 'Disetujui ($status)',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 115,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
