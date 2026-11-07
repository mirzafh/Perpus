import 'package:flutter/material.dart';

class HasilKelolaKategori {
  final List<String> kategori;
  final Map<String, String> perubahanNama;

  HasilKelolaKategori({
    required this.kategori,
    required this.perubahanNama,
  });
}

class KelolaKategoriDialog extends StatefulWidget {
  final List<String> kategoriAwal;
  final Set<String> kategoriTerpakai;

  const KelolaKategoriDialog({
    super.key,
    required this.kategoriAwal,
    required this.kategoriTerpakai,
  });

  @override
  State<KelolaKategoriDialog> createState() =>
      _KelolaKategoriDialogState();
}

class _KelolaKategoriDialogState
    extends State<KelolaKategoriDialog> {
  late List<String> kategori;
  late Set<String> kategoriTerpakai;
  final TextEditingController controller = TextEditingController();
  final Map<String, String> perubahanNama = {};

  @override
  void initState() {
    super.initState();
    kategori = List.from(widget.kategoriAwal);
    kategoriTerpakai = Set.from(widget.kategoriTerpakai);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  void tambahKategori() {
    final nama = controller.text.trim();

    if (nama.isEmpty) {
      tampilkanPesan('Nama kategori tidak boleh kosong');
      return;
    }

    final sudahAda = kategori.any(
      (item) => item.toLowerCase() == nama.toLowerCase(),
    );

    if (sudahAda) {
      tampilkanPesan('Kategori sudah tersedia');
      return;
    }

    setState(() {
      kategori.add(nama);
      controller.clear();
    });
  }

  Future<void> editKategori(String namaLama) async {
    final editController = TextEditingController(text: namaLama);

    final namaBaru = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Kategori'),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nama kategori',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(dialogContext, value.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                editController.text.trim(),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    editController.dispose();

    if (!mounted || namaBaru == null || namaBaru.isEmpty) {
      return;
    }

    final sudahAda = kategori.any(
      (item) =>
          item.toLowerCase() == namaBaru.toLowerCase() &&
          item != namaLama,
    );

    if (sudahAda) {
      tampilkanPesan('Nama kategori sudah digunakan');
      return;
    }

    setState(() {
      final index = kategori.indexOf(namaLama);
      if (index == -1) return;

      kategori[index] = namaBaru;

      if (kategoriTerpakai.remove(namaLama)) {
        kategoriTerpakai.add(namaBaru);
      }

      final namaAsal = perubahanNama.remove(namaLama) ?? namaLama;
      perubahanNama[namaBaru] = namaAsal;
    });
  }

  void hapusKategori(String nama) {
    if (kategoriTerpakai.contains(nama)) {
      tampilkanPesan(
        'Kategori masih digunakan oleh buku',
      );
      return;
    }

    setState(() {
      kategori.remove(nama);
      perubahanNama.remove(nama);
    });
  }

  void simpanKategori() {
    Navigator.pop(
      context,
      HasilKelolaKategori(
        kategori: List.from(kategori),
        perubahanNama: Map.from(perubahanNama),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.category_outlined),
          const SizedBox(width: 10),
          const Expanded(child: Text('Kelola Kategori')),
        ],
      ),
      content: SizedBox(
        width: 420,
        height: 400,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => tambahKategori(),
                    decoration: InputDecoration(
                      hintText: 'Nama kategori baru',
                      filled: true,
                      fillColor: colors.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: tambahKategori,
                  icon: const Icon(Icons.add),
                  tooltip: 'Tambah kategori',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${kategori.length} kategori terdaftar',
                style: TextStyle(color: colors.secondary),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: kategori.isEmpty
                  ? const Center(
                      child: Text('Belum ada kategori'),
                    )
                  : ListView.separated(
                      itemCount: kategori.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final nama = kategori[index];
                        final sedangDigunakan =
                            kategoriTerpakai.contains(nama);

                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          title: Text(nama),
                          subtitle: sedangDigunakan
                              ? const Text('Sedang digunakan')
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => editKategori(nama),
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: 'Edit kategori',
                              ),
                              IconButton(
                                onPressed: () => hapusKategori(nama),
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: sedangDigunakan
                                      ? colors.onSurface.withValues(
                                          alpha: 0.3,
                                        )
                                      : colors.error,
                                ),
                                tooltip: sedangDigunakan
                                    ? 'Kategori masih digunakan'
                                    : 'Hapus kategori',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: simpanKategori,
          child: const Text('Selesai'),
        ),
      ],
    );
  }
}
