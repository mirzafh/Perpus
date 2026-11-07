import 'package:flutter/material.dart';
import 'package:perpus/widgets/admin/ModelBuku.dart';

enum AksiDetailBuku {
  edit,
  hapus,
}

class DetailBuku extends StatelessWidget {
  final Buku buku;

  const DetailBuku({
    super.key,
    required this.buku,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget informasi(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colors.secondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Buku'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context, AksiDetailBuku.edit);
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Buku'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: colors.error,
            ),
            onPressed: () {
              Navigator.pop(context, AksiDetailBuku.hapus);
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Hapus Buku'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 650;

                final cover = Container(
                  width: isWide ? 220 : 180,
                  height: 300,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: buku.cover != null
                      ? Image.memory(buku.cover!, fit: BoxFit.cover)
                      : (buku.coverUrl != null && buku.coverUrl!.isNotEmpty)
                          ? Image.network(
                              buku.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.menu_book,
                                size: 75,
                                color: colors.secondary,
                              ),
                            )
                          : Icon(
                              Icons.menu_book,
                              size: 75,
                              color: colors.secondary,
                            ),
                );

                final detail = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buku.judul,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      buku.penerbit,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 28),
                    informasi('Nomor ISBN', buku.isbn),
                    informasi('Kategori', buku.kategori),
                    informasi('Stok Buku', '${buku.stok}'),
                  ],
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cover,
                      const SizedBox(width: 48),
                      Expanded(child: detail),
                    ],
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: cover),
                      const SizedBox(height: 28),
                      detail,
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
