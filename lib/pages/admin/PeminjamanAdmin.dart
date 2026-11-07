import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpus/main.dart';
import 'package:perpus/widgets/admin/Dateline.dart';
import 'package:perpus/widgets/admin/DataSiswa.dart';

class PeminjamanAdmins extends StatefulWidget {
  const PeminjamanAdmins({super.key});

  @override
  State<PeminjamanAdmins> createState() => _PeminjamanAdminsState();
}

class _PeminjamanAdminsState extends State<PeminjamanAdmins> {
  final TextEditingController _scanController = TextEditingController();
  final FocusNode _scanFocus = FocusNode();

  Timer? _timer;
  DateTime waktuSekarang = DateTime.now();

  String? namaSiswa;
  String? nisSiswa;
  String? kelasSiswa;
  String? genderSiswa;
  DateTime? deadline;

  final List<Map<String, dynamic>> daftarBuku = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          waktuSekarang = DateTime.now();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scanController.dispose();
    _scanFocus.dispose();
    super.dispose();
  }

  String formatWaktu(DateTime waktu) {
    String duaDigit(int angka) => angka.toString().padLeft(2, '0');
    return '${duaDigit(waktu.day)}/'
        '${duaDigit(waktu.month)}/'
        '${waktu.year} '
        '${duaDigit(waktu.hour)}:'
        '${duaDigit(waktu.minute)}:'
        '${duaDigit(waktu.second)}';
  }

  Future<void> prosesScan(String isbn) async {
    isbn = isbn.trim();
    if (isbn.isEmpty) return;

    final sudahAda = daftarBuku.any((buku) => buku['isbn'] == isbn);
    if (sudahAda) {
      tampilkanPesan('Buku ini sudah masuk daftar peminjaman');
      _scanController.clear();
      _scanFocus.requestFocus();
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('buku')
          .doc(isbn)
          .get();

      if (!mounted) return;

      if (!doc.exists) {
        tampilkanPesan('ISBN "$isbn" tidak ditemukan di database buku');
        _scanController.clear();
        _scanFocus.requestFocus();
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      final stok = (data['stok'] is num) ? (data['stok'] as num).toInt() : 0;

      if (stok <= 0) {
        tampilkanPesan('Stok buku "${data['judul']}" sedang habis!');
        _scanController.clear();
        _scanFocus.requestFocus();
        return;
      }

      setState(() {
        daftarBuku.add({
          'isbn': isbn,
          'judul': (data['judul'] ?? '').toString(),
          'penerbit': (data['penerbit'] ?? '').toString(),
          'kategori': (data['kategori'] ?? 'Lainnya').toString(),
          'kode': '',
        });
      });
    } catch (e) {
      tampilkanPesan('Gagal mencari buku: $e');
    }

    _scanController.clear();
    _scanFocus.requestFocus();
  }

  Future<void> tampilkanPopupSiswa() async {
    final hasil = await PopupDataSiswa.tampilkan(context);
    if (hasil != null) {
      setState(() {
        namaSiswa = hasil['nama'];
        nisSiswa = hasil['nis'];
        kelasSiswa = hasil['kelas'];
        genderSiswa = hasil['gender'];
      });
    }
  }

  Future<void> tampilkanPopupDeadline() async {
    final hasil = await PopupDeadline.tampilkan(
      context,
      tanggalAwal: deadline,
    );
    if (hasil != null) {
      setState(() {
        deadline = hasil;
      });
    }
  }

  void konfirmasiPeminjaman() {
    if (namaSiswa == null || nisSiswa == null) {
      tampilkanPesan('Silakan pilih siswa terlebih dahulu');
      return;
    }
    if (deadline == null) {
      tampilkanPesan('Silakan tentukan deadline peminjaman');
      return;
    }
    if (daftarBuku.isEmpty) {
      tampilkanPesan('Belum ada buku yang dipindai');
      return;
    }

    final kodeKosong = daftarBuku.any(
      (buku) => buku['kode'].toString().trim().isEmpty,
    );
    if (kodeKosong) {
      tampilkanPesan('Semua kode inventaris harus diisi');
      return;
    }

    final kodeDuplikat = daftarBuku
            .map((buku) => buku['kode'].toString().trim())
            .toSet()
            .length !=
        daftarBuku.length;
    if (kodeDuplikat) {
      tampilkanPesan('Ada kode inventaris yang sama');
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Peminjaman Siap Disimpan'),
          content: Text(
            'Siswa: $namaSiswa ($nisSiswa)\n'
            'Jumlah buku: ${daftarBuku.length}\n'
            'Deadline: ${formatWaktu(deadline!)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Periksa Lagi'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _simpanKeFirebase();
              },
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _simpanKeFirebase() async {
    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();
      final sekarang = Timestamp.now();
      final batas = Timestamp.fromDate(deadline!);

      for (final buku in daftarBuku) {
        final pinjamRef = db.collection('peminjaman').doc();
        batch.set(pinjamRef, {
          'nisn': nisSiswa,
          'namaSiswa': namaSiswa,
          'kelasSiswa': kelasSiswa ?? '-',
          'genderSiswa': genderSiswa ?? '-',
          'isbn': buku['isbn'],
          'judulBuku': buku['judul'],
          'penerbit': buku['penerbit'],
          'kategoriBuku': buku['kategori'],
          'kodeInventaris': buku['kode'].toString().trim(),
          'status': 'dipinjam',
          'waktuPinjam': sekarang,
          'deadline': batas,
          'waktuKembali': null,
        });

        // Kurangi stok buku & tambah dipinjamCount
        final bukuDoc = db.collection('buku').doc(buku['isbn']);
        batch.update(bukuDoc, {
          'stok': FieldValue.increment(-1),
          'dipinjamCount': FieldValue.increment(1),
        });

        // Buat notifikasi untuk siswa
        final notifRef = db.collection('notifikasi').doc();
        batch.set(notifRef, {
          'nisn': nisSiswa,
          'title': 'Peminjaman Berhasil',
          'subtitle':
              'Kamu berhasil meminjam buku "${buku['judul']}" (Kode: ${buku['kode']}).',
          'type': 'info',
          'waktu': sekarang,
          'dibaca': false,
        });
      }

      // Tambah streak meminjam pada dokumen murid
      final muridDoc = db.collection('murid').doc(nisSiswa);
      batch.set(
        muridDoc,
        {'streak': FieldValue.increment(1)},
        SetOptions(merge: true),
      );

      await batch.commit();

      if (!mounted) return;
      setState(() {
        daftarBuku.clear();
        namaSiswa = null;
        nisSiswa = null;
        kelasSiswa = null;
        genderSiswa = null;
        deadline = null;
      });
      tampilkanPesan('Transaksi peminjaman berhasil disimpan ke Firebase!');
    } catch (e) {
      tampilkanPesan('Gagal menyimpan peminjaman: $e');
    }
  }

  void tampilkanPesan(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final Gradient backgroundGradient =
        isDark ? Warna.darkGreenRadialGlow : Warna.lightGreenRadialGlow;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Peminjaman Buku',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.3),
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
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatWaktu(waktuSekarang),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Scan Barcode ISBN',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _scanController,
                            focusNode: _scanFocus,
                            autofocus: true,
                            onSubmitted: prosesScan,
                            decoration: InputDecoration(
                              hintText:
                                  'Ketik / Scan ISBN buku dari database (misal: 9786020324784)...',
                              prefixIcon: const Icon(
                                Icons.qr_code_scanner_rounded,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    prosesScan(_scanController.text),
                                icon: const Icon(Icons.search),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: colors.surfaceContainerHighest,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: constraints.maxWidth < 650
                                  ? 650
                                  : constraints.maxWidth - 76,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: colors.primaryContainer,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        _headerCell('ISBN', 12),
                                        _headerCell('Nama Buku', 20),
                                        _headerCell('Penerbit', 16),
                                        _headerCell('Kode Buku', 14),
                                      ],
                                    ),
                                  ),
                                  if (daftarBuku.isEmpty)
                                    Container(
                                      height: 120,
                                      alignment: Alignment.center,
                                      color: colors.surfaceContainerLow,
                                      child: Text(
                                        'Belum ada buku yang dipindai',
                                        style: TextStyle(
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ...List.generate(
                                    daftarBuku.length,
                                    (index) {
                                      final buku = daftarBuku[index];
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: index.isEven
                                              ? colors.surfaceContainerLow
                                              : colors.surface,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: colors.outline.withValues(
                                                alpha: 0.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            _dataCell(buku['isbn'], 12),
                                            _dataCell(buku['judul'], 20),
                                            _dataCell(buku['penerbit'], 16),
                                            Expanded(
                                              flex: 140,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                child: TextField(
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: 'Kode buku',
                                                    isDense: true,
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  onChanged: (value) {
                                                    daftarBuku[index]['kode'] =
                                                        value;
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (namaSiswa != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Siswa terpilih: $namaSiswa ($nisSiswa)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    if (deadline != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Deadline: ${formatWaktu(deadline!)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    LayoutBuilder(
                      builder: (context, buttonConstraints) {
                        final kecil = buttonConstraints.maxWidth < 500;
                        final buttons = [
                          _actionButton(
                            context,
                            icon: Icons.arrow_back_rounded,
                            title: 'Back',
                            onTap: () => Navigator.pop(context),
                          ),
                          _actionButton(
                            context,
                            icon: Icons.people_alt_rounded,
                            title: 'Data Siswa',
                            onTap: tampilkanPopupSiswa,
                          ),
                          _actionButton(
                            context,
                            icon: Icons.calendar_month_rounded,
                            title: 'Deadline',
                            onTap: tampilkanPopupDeadline,
                          ),
                          _actionButton(
                            context,
                            icon: Icons.check_rounded,
                            title: 'Oke',
                            onTap: konfirmasiPeminjaman,
                          ),
                        ];

                        if (kecil) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: buttons[0]),
                                  const SizedBox(width: 10),
                                  Expanded(child: buttons[1]),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: buttons[2]),
                                  const SizedBox(width: 10),
                                  Expanded(child: buttons[3]),
                                ],
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            for (int i = 0; i < buttons.length; i++) ...[
                              Expanded(child: buttons[i]),
                              if (i != buttons.length - 1)
                                const SizedBox(width: 12),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String title, int flex) {
    return Expanded(
      flex: flex * 10,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _dataCell(String value, int flex) {
    return Expanded(
      flex: flex * 10,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 19),
        label: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              primary ? colors.primary : colors.surfaceContainerHigh,
          foregroundColor: primary ? colors.onPrimary : colors.onSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
