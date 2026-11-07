import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:perpus/widgets/admin/ModelBuku.dart';

class FormBuku extends StatefulWidget {
  final Buku? buku;
  final List<String> daftarKategori;

  const FormBuku({
    super.key,
    this.buku,
    required this.daftarKategori,
  });

  @override
  State<FormBuku> createState() => _FormBukuState();
}

class _FormBukuState extends State<FormBuku> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController isbnController;
  late TextEditingController judulController;
  late TextEditingController penerbitController;
  late TextEditingController stokController;

  String? kategori;
  Uint8List? coverBytes;
  String? coverUrl;

  bool get isEdit => widget.buku != null;

  @override
  void initState() {
    super.initState();

    final buku = widget.buku;

    isbnController = TextEditingController(text: buku?.isbn ?? '');
    judulController = TextEditingController(text: buku?.judul ?? '');
    penerbitController =
        TextEditingController(text: buku?.penerbit ?? '');
    stokController =
        TextEditingController(text: buku?.stok.toString() ?? '');

    kategori = buku?.kategori;
    coverBytes = buku?.cover;
    coverUrl = buku?.coverUrl;
  }

  @override
  void dispose() {
    isbnController.dispose();
    judulController.dispose();
    penerbitController.dispose();
    stokController.dispose();
    super.dispose();
  }

  Future<void> pilihCover() async {
  final files = await fp.FilePicker.pickFiles(
    type: fp.FileType.image,
  );

  if (files.isEmpty) return;

  final bytes = await files.single.readAsBytes();

  if (!mounted) return;

  setState(() {
    coverBytes = bytes;
  });
}

  void simpanBuku() {
    if (!_formKey.currentState!.validate()) return;

    if (kategori == null ||
        !widget.daftarKategori.contains(kategori)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori buku terlebih dahulu'),
        ),
      );
      return;
    }

    final buku = Buku(
      isbn: isbnController.text.trim(),
      judul: judulController.text.trim(),
      penerbit: penerbitController.text.trim(),
      kategori: kategori!,
      stok: int.parse(stokController.text.trim()),
      cover: coverBytes,
      coverUrl: coverUrl,
    );

    Navigator.pop(context, buku);
  }

  InputDecoration dekorasi(String label) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: colors.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Buku' : 'Tambah Buku'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit Data Buku' : 'Tambah Buku',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 650;

                      final coverWidget = Column(
                        children: [
                          InkWell(
                            onTap: pilihCover,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: isWide ? 240 : 180,
                              height: 280,
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colors.outlineVariant,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: coverBytes != null
                                  ? Image.memory(
                                      coverBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : (coverUrl != null && coverUrl!.isNotEmpty)
                                      ? Image.network(
                                          coverUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image),
                                        )
                                      : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 45,
                                          color: colors.secondary,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text('Pilih Cover Buku'),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Klik untuk memilih gambar',
                            style: TextStyle(color: colors.secondary),
                          ),
                        ],
                      );

                      final fields = Column(
                        children: [
                          TextFormField(
                            controller: isbnController,
                            decoration: dekorasi('Nomor Seri / ISBN'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'ISBN wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: judulController,
                            decoration: dekorasi('Judul Buku'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Judul wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: penerbitController,
                            decoration: dekorasi('Penerbit'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Penerbit wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            initialValue: kategori,
                            decoration: dekorasi('Kategori'),
                            isExpanded: true,
                            hint: const Text('Pilih kategori'),
                            items: widget.daftarKategori.map((item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Pilih kategori buku';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                kategori = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: stokController,
                            keyboardType: TextInputType.number,
                            decoration: dekorasi('Stok Buku'),
                            validator: (value) {
                              final stok = int.tryParse(value ?? '');

                              if (stok == null || stok < 0) {
                                return 'Masukkan stok berupa angka 0 atau lebih';
                              }

                              return null;
                            },
                          ),
                        ],
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            coverWidget,
                            const SizedBox(width: 40),
                            Expanded(child: fields),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          coverWidget,
                          const SizedBox(height: 28),
                          fields,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: simpanBuku,
                        icon: const Icon(Icons.save),
                        label: Text(
                          isEdit ? 'Simpan Perubahan' : 'Tambah Buku',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
