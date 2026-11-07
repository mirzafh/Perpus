import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:excel/excel.dart' as xl;
import 'package:perpus/widgets/admin/ModelBuku.dart';
import 'package:perpus/widgets/admin/TabelBuku.dart';
import 'package:perpus/widgets/admin/FormBuku.dart';
import 'package:perpus/widgets/admin/DetailBuku.dart';
import 'package:perpus/widgets/admin/DialogHapusBuku.dart';
import 'package:perpus/widgets/admin/DataKategori.dart';
import 'package:perpus/widgets/admin/UploadCover.dart';

class DataBukuAdmin extends StatefulWidget {
  const DataBukuAdmin({super.key});

  @override
  State<DataBukuAdmin> createState() => _DataBukuAdminState();
}

class _DataBukuAdminState extends State<DataBukuAdmin> {
  final TextEditingController searchController = TextEditingController();
  final CollectionReference _bukuRef =
      FirebaseFirestore.instance.collection('buku');
  final DocumentReference _kategoriDoc =
      FirebaseFirestore.instance.collection('kategori').doc('daftar');

  late final Stream<QuerySnapshot> _bukuStream = _bukuRef.snapshots();

  List<String> daftarKategori = List.from(kategoriBuku);
  String? filterKategori;

  @override
  void initState() {
    super.initState();
    _initDataAwal();
  }

  Future<void> _initDataAwal() async {
    try {
      // Muat atau inisialisasi kategori
      final katSnap = await _kategoriDoc.get();
      if (katSnap.exists) {
        final data = katSnap.data() as Map<String, dynamic>;
        final list = List<String>.from(data['list'] ?? []);
        if (list.isNotEmpty && mounted) {
          setState(() => daftarKategori = list);
        }
      } else {
        await _kategoriDoc.set({'list': kategoriBuku});

        // Isi data contoh HANYA saat pertama kali (dokumen kategori belum ada),
        // supaya buku yang sudah dihapus tidak muncul lagi.
        final bukuSnap = await _bukuRef.limit(1).get();
        if (bukuSnap.docs.isEmpty) {
          final batch = FirebaseFirestore.instance.batch();
          for (final b in dummyBuku) {
            batch.set(_bukuRef.doc(b.isbn), b.toMap());
          }
          await batch.commit();
        }
      }
    } catch (e) {
      debugPrint('Gagal inisialisasi data awal: $e');
      tampilkanPesan('Gagal memuat data awal: $e');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void tampilkanPesan(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  Future<Buku> _uploadCoverJikaPerlu(Buku buku, {String? coverLama}) async {
    if (buku.cover == null) return buku;
    final kecil = await UploadCover.kompres(buku.cover!);
    return buku.copyWith(cover: kecil);
  }

  Future<void> tambahBuku() async {
    final hasil = await Navigator.push<Buku>(
      context,
      MaterialPageRoute(
        builder: (_) => FormBuku(daftarKategori: daftarKategori),
      ),
    );

    if (!mounted || hasil == null) return;

    try {
      final cek = await _bukuRef.doc(hasil.isbn).get();
      if (cek.exists) {
        tampilkanPesan('ISBN sudah terdaftar!');
        return;
      }

      Buku bukuSiapSimpan = hasil;
      try {
        bukuSiapSimpan = await _uploadCoverJikaPerlu(hasil);
      } catch (e) {
        debugPrint('Upload cover gagal: $e');
        tampilkanPesan('Cover gagal diproses ($e). Buku disimpan tanpa cover.');
      }
      await _bukuRef.doc(hasil.isbn).set(bukuSiapSimpan.toMap());
      tampilkanPesan('Buku berhasil ditambahkan ke Firebase');
    } catch (e) {
      tampilkanPesan('Gagal menambahkan buku: $e');
    }
  }

  Future<void> editBuku(Buku buku) async {
    final oldIsbn = buku.isbn;
    final hasil = await Navigator.push<Buku>(
      context,
      MaterialPageRoute(
        builder: (_) => FormBuku(
          buku: buku,
          daftarKategori: daftarKategori,
        ),
      ),
    );

    if (!mounted || hasil == null) return;

    try {
      if (hasil.isbn != oldIsbn) {
        final cek = await _bukuRef.doc(hasil.isbn).get();
        if (cek.exists) {
          tampilkanPesan('ISBN sudah digunakan oleh buku lain!');
          return;
        }
      }

      Buku bukuSiapSimpan = hasil;
      try {
        bukuSiapSimpan = await _uploadCoverJikaPerlu(
          hasil,
          coverLama: buku.coverUrl,
        );
      } catch (e) {
        debugPrint('Upload cover gagal: $e');
        tampilkanPesan('Cover gagal diproses ($e). Cover lama dipertahankan.');
      }

      if (hasil.isbn != oldIsbn) {
        await _bukuRef.doc(oldIsbn).delete();
      }

      await _bukuRef
          .doc(hasil.isbn)
          .set(bukuSiapSimpan.copyWith(dipinjamCount: buku.dipinjamCount).toMap());
      tampilkanPesan('Data buku berhasil diperbarui');
    } catch (e) {
      tampilkanPesan('Gagal memperbarui buku: $e');
    }
  }

  Future<void> hapusBuku(Buku buku) async {
    final setuju = await dialogHapusBuku(context, buku);
    if (!mounted || !setuju) return;

    try {
      await _bukuRef.doc(buku.isbn).delete();
      tampilkanPesan('Buku berhasil dihapus');
    } catch (e) {
      tampilkanPesan('Gagal menghapus buku: $e');
    }
  }

  Future<void> bukaDetail(Buku buku) async {
    final aksi = await Navigator.push<AksiDetailBuku>(
      context,
      MaterialPageRoute(builder: (_) => DetailBuku(buku: buku)),
    );

    if (!mounted) return;
    if (aksi == AksiDetailBuku.edit) {
      await editBuku(buku);
    } else if (aksi == AksiDetailBuku.hapus) {
      await hapusBuku(buku);
    }
  }

  Future<void> bukaKelolaKategori(List<Buku> daftarBuku) async {
    final hasil = await showDialog<HasilKelolaKategori>(
      context: context,
      builder: (context) => KelolaKategoriDialog(
        kategoriAwal: daftarKategori,
        kategoriTerpakai: daftarBuku.map((buku) => buku.kategori).toSet(),
      ),
    );

    if (!mounted || hasil == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.set(_kategoriDoc, {'list': hasil.kategori});

      for (final perubahan in hasil.perubahanNama.entries) {
        final namaBaru = perubahan.key;
        final namaLama = perubahan.value;

        for (final buku in daftarBuku) {
          if (buku.kategori == namaLama) {
            batch.update(_bukuRef.doc(buku.isbn), {'kategori': namaBaru});
          }
        }
        if (filterKategori == namaLama) {
          filterKategori = namaBaru;
        }
      }

      await batch.commit();

      setState(() {
        daftarKategori = hasil.kategori;
        if (filterKategori != null &&
            !daftarKategori.contains(filterKategori)) {
          filterKategori = null;
        }
      });

      tampilkanPesan('Daftar kategori berhasil diperbarui');
    } catch (e) {
      tampilkanPesan('Gagal menyimpan kategori: $e');
    }
  }

  Future<void> importExcel() async {
    try {
      final pickedFile = await fp.FilePicker.pickFile(
        type: fp.FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final workbook = xl.Excel.decodeBytes(bytes);
      if (workbook.tables.isEmpty) throw Exception('File Excel kosong.');

      final rows = workbook.tables.values.first.rows;
      if (rows.length < 2) throw Exception('Tidak ada data buku.');

      String getCell(int row, int col) {
        if (col < 0 || col >= rows[row].length) return '';
        return rows[row][col]?.value?.toString().trim() ?? '';
      }

      final headers = rows.first
          .map((c) => c?.value?.toString().trim().toLowerCase() ?? '')
          .toList();
      int findColumn(List<String> aliases) =>
          headers.indexWhere((h) => aliases.contains(h));

      final isbnCol = findColumn(['isbn']);
      final judulCol = findColumn(['judul', 'judul buku']);
      final penerbitCol = findColumn(['penerbit']);
      final kategoriCol = findColumn(['kategori']);
      final stokCol = findColumn(['stok', 'jumlah']);

      if ([isbnCol, judulCol, penerbitCol, kategoriCol, stokCol]
          .contains(-1)) {
        throw Exception(
          'Header Excel harus berisi ISBN, Judul, Penerbit, Kategori, Stok.',
        );
      }

      final existing = (await _bukuRef.get()).docs.map((d) => d.id).toSet();
      final batch = FirebaseFirestore.instance.batch();
      int imported = 0;
      int skipped = 0;

      for (int i = 1; i < rows.length; i++) {
        // Hilangkan format ilmiah / desimal jika ISBN terbaca sebagai angka
        var isbn = getCell(i, isbnCol);
        if (isbn.endsWith('.0')) isbn = isbn.substring(0, isbn.length - 2);
        final judul = getCell(i, judulCol);
        final penerbit = getCell(i, penerbitCol);
        var kategori = getCell(i, kategoriCol);
        final stok = int.tryParse(getCell(i, stokCol).split('.').first);

        if (isbn.isEmpty && judul.isEmpty) continue;
        if (isbn.isEmpty ||
            judul.isEmpty ||
            stok == null ||
            stok < 0 ||
            existing.contains(isbn)) {
          skipped++;
          continue;
        }

        final cocok = kategoriBuku.where(
          (k) => k.toLowerCase() == kategori.toLowerCase(),
        );
        kategori = cocok.isNotEmpty ? cocok.first : 'Lainnya';

        existing.add(isbn);
        batch.set(
          _bukuRef.doc(isbn),
          Buku(
            isbn: isbn,
            judul: judul,
            penerbit: penerbit,
            kategori: kategori,
            stok: stok,
          ).toMap(),
        );
        imported++;
      }

      if (imported > 0) await batch.commit();
      tampilkanPesan('$imported buku berhasil diimpor. $skipped baris dilewati.');
    } catch (e) {
      tampilkanPesan('Gagal mengimpor Excel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Buku'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Impor Excel',
            onPressed: importExcel,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _bukuStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final daftarBuku = snapshot.data!.docs.map((doc) {
            return Buku.fromMap(
              doc.data() as Map<String, dynamic>,
              docId: doc.id,
            );
          }).toList();

          final bukuTersaring = daftarBuku.where((buku) {
            final keyword = searchController.text.toLowerCase();
            final cocokPencarian = buku.judul.toLowerCase().contains(keyword) ||
                buku.isbn.toLowerCase().contains(keyword) ||
                buku.penerbit.toLowerCase().contains(keyword);
            final cocokKategori =
                filterKategori == null || buku.kategori == filterKategori;
            return cocokPencarian && cocokKategori;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Seluruh Buku',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kelola data buku yang terdaftar di perpustakaan.',
                  style: TextStyle(color: colors.secondary),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final searchField = TextField(
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari judul, ISBN, atau penerbit...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: colors.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    );

                    final filter = DropdownButtonFormField<String>(
                      initialValue: filterKategori,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        filled: true,
                        fillColor: colors.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Semua Kategori'),
                        ),
                        ...daftarKategori.map(
                          (kategori) => DropdownMenuItem<String>(
                            value: kategori,
                            child: Text(kategori),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          filterKategori = value;
                        });
                      },
                    );

                    final tombolKategori = OutlinedButton.icon(
                      onPressed: () => bukaKelolaKategori(daftarBuku),
                      icon: const Icon(Icons.category_outlined),
                      label: const Text('Kelola Kategori'),
                    );

                    final tambahButton = FilledButton.icon(
                      onPressed: tambahBuku,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Buku'),
                    );

                    if (constraints.maxWidth >= 950) {
                      return Row(
                        children: [
                          Expanded(flex: 3, child: searchField),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: filter),
                          const SizedBox(width: 12),
                          tombolKategori,
                          const SizedBox(width: 8),
                          tambahButton,
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        searchField,
                        const SizedBox(height: 12),
                        filter,
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            tombolKategori,
                            tambahButton,
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  '${bukuTersaring.length} buku ditemukan',
                  style: TextStyle(
                    color: colors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: TabelBuku(
                        daftarBuku: bukuTersaring,
                        onDetail: bukaDetail,
                        onEdit: editBuku,
                        onHapus: hapusBuku,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
