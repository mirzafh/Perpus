import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpus/main.dart';
import 'package:perpus/widgets/students/BackPill.dart';

class PengembalianAdmins extends StatefulWidget {
  const PengembalianAdmins({super.key});

  @override
  State<PengembalianAdmins> createState() => _PengembalianAdminsState();
}

class _PengembalianAdminsState extends State<PengembalianAdmins> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _timer;
  DateTime waktuSekarang = DateTime.now();

  String searchKeyword = '';
  late final Stream<QuerySnapshot> _pinjamStream =
      FirebaseFirestore.instance.collection('peminjaman').snapshots();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {
            waktuSekarang = DateTime.now();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String formatWaktu(DateTime? waktu) {
    if (waktu == null) return '-';
    String duaDigit(int angka) => angka.toString().padLeft(2, '0');
    return '${duaDigit(waktu.day)}/'
        '${duaDigit(waktu.month)}/'
        '${waktu.year} '
        '${duaDigit(waktu.hour)}:'
        '${duaDigit(waktu.minute)}';
  }

  void konfirmasiPengembalian(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    if (data['status'] == 'kembali') return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 42,
          ),
          title: const Text('Konfirmasi Pengembalian'),
          content: Text(
            'Anda yakin ingin mengubah status peminjaman '
            'pada ${data['namaSiswa']} menjadi sudah dikembalikan?\n\n'
            'Buku: ${data['judulBuku']}\n'
            'Kode: ${data['kodeInventaris']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  final db = FirebaseFirestore.instance;
                  final batch = db.batch();

                  batch.update(doc.reference, {
                    'status': 'kembali',
                    'waktuKembali': Timestamp.now(),
                  });

                  final isbn = (data['isbn'] ?? '').toString();
                  if (isbn.isNotEmpty) {
                    batch.update(db.collection('buku').doc(isbn), {
                      'stok': FieldValue.increment(1),
                    });
                  }

                  await batch.commit();

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Buku berhasil dikonfirmasi kembali'),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal mengonfirmasi: $e')),
                  );
                }
              },
              child: const Text('Ya, Konfirmasi'),
            ),
          ],
        );
      },
    );
  }

  void cariSiswa() {
    setState(() {
      searchKeyword = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final Gradient backgroundGradient =
        isDark ? Warna.darkGreenRadialGlow : Warna.lightGreenRadialGlow;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengembalian Buku',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keterangan waktu saat ini',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formatWaktu(waktuSekarang),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Cari Siswa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: (_) => cariSiswa(),
                              onChanged: (_) => cariSiswa(),
                              decoration: InputDecoration(
                                hintText: 'Masukkan nama atau NISN siswa',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: colors.surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filled(
                            onPressed: cariSiswa,
                            icon: const Icon(Icons.search),
                            tooltip: 'Cari Siswa',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      StreamBuilder<QuerySnapshot>(
                        stream: _pinjamStream,
                        builder: (context, snapshot) {
                          final allDocs = snapshot.data?.docs ?? [];
                          final daftarPeminjaman = allDocs.where((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            final status = (d['status'] ?? '').toString();
                            if (status != 'dipinjam' && status != 'kembali') {
                              return false;
                            }
                            if (searchKeyword.isEmpty) return true;
                            final nama =
                                (d['namaSiswa'] ?? '').toString().toLowerCase();
                            final nisn =
                                (d['nisn'] ?? '').toString().toLowerCase();
                            return nama.contains(searchKeyword) ||
                                nisn.contains(searchKeyword);
                          }).toList();

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 950,
                              child: Table(
                                border: TableBorder.all(
                                  color: colors.outline.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                                columnWidths: const {
                                  0: FlexColumnWidth(0.6),
                                  1: FlexColumnWidth(1.5),
                                  2: FlexColumnWidth(1.7),
                                  3: FlexColumnWidth(1.4),
                                  4: FlexColumnWidth(1.4),
                                  5: FlexColumnWidth(1.1),
                                  6: FlexColumnWidth(1.3),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: colors.surfaceContainerHighest,
                                    ),
                                    children: [
                                      _headerCell('No'),
                                      _headerCell('Siswa'),
                                      _headerCell('Buku'),
                                      _headerCell('Dipinjam Pada'),
                                      _headerCell('Batas Kembali'),
                                      _headerCell('Kode Buku'),
                                      _headerCell('Status'),
                                    ],
                                  ),
                                  ...List.generate(
                                    daftarPeminjaman.length,
                                    (index) {
                                      final doc = daftarPeminjaman[index];
                                      final buku =
                                          doc.data() as Map<String, dynamic>;
                                      final bool sudahKembali =
                                          buku['status'] == 'kembali';
                                      final waktuPinjam =
                                          (buku['waktuPinjam'] as Timestamp?)
                                              ?.toDate();
                                      final deadline =
                                          (buku['deadline'] as Timestamp?)
                                              ?.toDate();

                                      return TableRow(
                                        decoration: BoxDecoration(
                                          color: index.isEven
                                              ? colors.surface
                                              : colors.surfaceContainerLow,
                                        ),
                                        children: [
                                          _dataCell('${index + 1}'),
                                          _dataCell(
                                            '${buku['namaSiswa'] ?? '-'}\n(${buku['nisn'] ?? '-'})',
                                          ),
                                          _dataCell(
                                            (buku['judulBuku'] ?? '-')
                                                .toString(),
                                          ),
                                          _dataCell(formatWaktu(waktuPinjam)),
                                          _dataCell(formatWaktu(deadline)),
                                          _dataCell(
                                            (buku['kodeInventaris'] ?? '-')
                                                .toString(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: GestureDetector(
                                              onTap: () =>
                                                  konfirmasiPengembalian(doc),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 10,
                                                  horizontal: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: sudahKembali
                                                      ? const Color(0xFF16A765)
                                                      : const Color(0xFFDC2626),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Text(
                                                  sudahKembali
                                                      ? 'Sudah Kembali'
                                                      : 'Belum Kembali',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Klik tombol merah "Belum Kembali" untuk mengonfirmasi pengembalian buku.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Backpill(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String title) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(13),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: colors.onSurface,
        ),
      ),
    );
  }

  Widget _dataCell(String value) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(13),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: colors.onSurface,
        ),
      ),
    );
  }
}
