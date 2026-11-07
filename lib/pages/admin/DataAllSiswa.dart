import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:excel/excel.dart' as xl;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpus/widgets/admin/TabelDataMurid.dart';
import 'package:perpus/widgets/admin/TambahMurid.dart';
import 'package:perpus/widgets/admin/EditMurid.dart';
import 'package:perpus/widgets/admin/DialogHapusMurid.dart';
import 'package:perpus/widgets/students/BackPill.dart';

class DataMuridAdmin extends StatefulWidget {
  const DataMuridAdmin({super.key});

  @override
  State<DataMuridAdmin> createState() => _DataMuridAdminState();
}

class _DataMuridAdminState extends State<DataMuridAdmin> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  final CollectionReference _muridRef =
      FirebaseFirestore.instance.collection('murid');
  late final Stream<QuerySnapshot> _muridStream =
      _muridRef.orderBy('nama').snapshots();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> addStudent() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const TambahMurid(),
    );

    if (result == null || !mounted) return;

    final nisn = result['nisn']!;
    try {
      final doc = await _muridRef.doc(nisn).get();
      if (doc.exists) {
        _showMessage('NISN sudah terdaftar!');
        return;
      }

      await _muridRef.doc(nisn).set({
        'nama': result['nama'],
        'nisn': nisn,
        'kelas': result['kelas'],
        'gender': result['gender'],
        'password': nisn,
        'streak': 0,
        'wishlist': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showMessage('Murid berhasil ditambahkan.');
    } catch (e) {
      _showMessage('Gagal menambahkan murid: $e');
    }
  }

  Future<void> editStudent(Map<String, String> student) async {
    final oldNisn = student['nisn']!;
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => EditMurid(student: student),
    );

    if (result == null || !mounted) return;

    final newNisn = result['nisn']!;
    try {
      if (newNisn != oldNisn) {
        final cekDoc = await _muridRef.doc(newNisn).get();
        if (cekDoc.exists) {
          _showMessage('NISN tersebut sudah digunakan murid lain.');
          return;
        }
        await _muridRef.doc(oldNisn).delete();
      }

      await _muridRef.doc(newNisn).set({
        'nama': result['nama'],
        'nisn': newNisn,
        'kelas': result['kelas'],
        'gender': result['gender'],
        'password': newNisn,
      }, SetOptions(merge: true));

      _showMessage('Data murid berhasil diperbarui.');
    } catch (e) {
      _showMessage('Gagal memperbarui data: $e');
    }
  }

  Future<void> deleteStudent(Map<String, String> student) async {
    final nama = student['nama'] ?? 'murid ini';
    final nisn = student['nisn'];
    if (nisn == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DialogHapusMurid(
        title: 'Hapus Data Murid?',
        message: 'Apakah kamu yakin ingin menghapus data $nama? '
            'Data yang dihapus tidak dapat dikembalikan.',
        confirmText: 'Hapus',
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _muridRef.doc(nisn).delete();
      _showMessage('Data $nama berhasil dihapus.');
    } catch (e) {
      _showMessage('Gagal menghapus data: $e');
    }
  }

  Future<void> deleteAllStudents(int currentCount) async {
    if (currentCount == 0) {
      _showMessage('Tidak ada data murid untuk dihapus.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DialogHapusMurid(
        title: 'Hapus Semua Data Murid?',
        message: 'Seluruh $currentCount data murid akan dihapus. '
            'Tindakan ini tidak dapat dibatalkan.',
        confirmText: 'Hapus Semua',
        destructiveAll: true,
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final snapshot = await _muridRef.get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      _showMessage('Seluruh data murid berhasil dihapus.');
    } catch (e) {
      _showMessage('Gagal menghapus semua data: $e');
    }
  }

  Future<void> importExcel(Set<String> existingNisn) async {
    try {
      final pickedFile = await fp.FilePicker.pickFile(
        type: fp.FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (pickedFile == null) return;
      final bytes = await pickedFile.readAsBytes();
      final workbook = xl.Excel.decodeBytes(bytes);

      if (workbook.tables.isEmpty) {
        throw Exception('File Excel kosong.');
      }

      final sheet = workbook.tables.values.first;
      final rows = sheet.rows;

      if (rows.length < 2) {
        throw Exception('Tidak ada data murid.');
      }

      String getCell(int row, int col) {
        if (col >= rows[row].length) return '';
        return rows[row][col]?.value?.toString().trim() ?? '';
      }

      final headers = rows.first.map((cell) {
        return cell?.value?.toString().trim().toLowerCase() ?? '';
      }).toList();

      int findColumn(List<String> aliases) {
        return headers.indexWhere((header) => aliases.contains(header));
      }

      final namaCol = findColumn(['nama', 'nama siswa']);
      final nisnCol = findColumn(['nisn']);
      final kelasCol = findColumn(['kelas']);
      final genderCol = findColumn(['jenis kelamin', 'gender', 'jenis_kelamin']);

      if ([namaCol, nisnCol, kelasCol, genderCol].contains(-1)) {
        throw Exception(
          'Header Excel harus berisi Nama, NISN, Kelas, Jenis Kelamin.',
        );
      }

      final batch = FirebaseFirestore.instance.batch();
      int importedCount = 0;
      int skipped = 0;

      for (int i = 1; i < rows.length; i++) {
        final nama = getCell(i, namaCol);
        final nisn = getCell(i, nisnCol);
        final kelas = getCell(i, kelasCol).toUpperCase();
        final genderRaw = getCell(i, genderCol).toLowerCase();

        if (nama.isEmpty && nisn.isEmpty) continue;

        if (nama.isEmpty || !RegExp(r'^\d{10}$').hasMatch(nisn)) {
          skipped++;
          continue;
        }

        if (!['X', 'XA', 'XB', 'XI', 'XII'].contains(kelas)) {
          skipped++;
          continue;
        }

        String gender;
        if (['l', 'laki-laki', 'laki laki'].contains(genderRaw)) {
          gender = 'Laki-laki';
        } else if (['p', 'perempuan'].contains(genderRaw)) {
          gender = 'Perempuan';
        } else {
          skipped++;
          continue;
        }

        if (existingNisn.contains(nisn)) {
          skipped++;
          continue;
        }

        existingNisn.add(nisn);
        final docRef = _muridRef.doc(nisn);
        batch.set(docRef, {
          'nama': nama,
          'nisn': nisn,
          'kelas': kelas,
          'gender': gender,
          'password': nisn,
          'streak': 0,
          'wishlist': <String>[],
          'createdAt': FieldValue.serverTimestamp(),
        });
        importedCount++;
      }

      if (importedCount > 0) {
        await batch.commit();
      }

      _showMessage(
        '$importedCount murid berhasil diimpor. $skipped baris dilewati.',
      );
    } catch (e) {
      _showMessage('Gagal mengimpor Excel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _muridStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allStudents = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'nama': (data['nama'] ?? '').toString(),
                'nisn': (data['nisn'] ?? doc.id).toString(),
                'kelas': (data['kelas'] ?? '-').toString(),
                'gender': (data['gender'] ?? '-').toString(),
              };
            }).toList();

            final query = searchQuery.toLowerCase().trim();
            final filteredStudents = query.isEmpty
                ? allStudents
                : allStudents.where((student) {
                    final nama = (student['nama'] ?? '').toLowerCase();
                    final nisn = student['nisn'] ?? '';
                    return nama.contains(query) || nisn.contains(query);
                  }).toList();

            final existingNisnSet =
                allStudents.map((s) => s['nisn']!).toSet();

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildToolbar(
                        context,
                        existingNisnSet: existingNisnSet,
                        totalCount: allStudents.length,
                      ),
                      const SizedBox(height: 20),
                      TabelMurid(
                        students: filteredStudents,
                        onEdit: editStudent,
                        onDelete: deleteStudent,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          const Backpill(),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              'Data Murid',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: addStudent,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Murid'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context, {
    required Set<String> existingNisnSet,
    required int totalCount,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Cari nama murid atau NISN...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      searchController.clear();
                      setState(() => searchQuery = '');
                    },
                    icon: const Icon(Icons.close),
                  )
                : null,
            filled: true,
            fillColor: colors.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: () => importExcel(existingNisnSet),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Import Data Excel (.xlsx)'),
            ),
            OutlinedButton.icon(
              onPressed: () => deleteAllStudents(totalCount),
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Hapus Semua'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
