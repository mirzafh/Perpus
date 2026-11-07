import 'package:flutter/material.dart';
import 'package:perpus/widgets/admin/ModelBuku.dart';

class TabelBuku extends StatelessWidget {
  final List<Buku> daftarBuku;
  final Function(Buku) onDetail;
  final Function(Buku) onEdit;
  final Function(Buku) onHapus;

  const TabelBuku({
    super.key,
    required this.daftarBuku,
    required this.onDetail,
    required this.onEdit,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (daftarBuku.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_outlined,
                  size: 55, color: colors.secondary),
              const SizedBox(height: 12),
              const Text('Tidak ada buku ditemukan'),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                colors.surfaceContainerHighest,
              ),
              dataRowMinHeight: 72,
              dataRowMaxHeight: 84,
              columnSpacing: 24,
              horizontalMargin: 16,
              columns: const [
                DataColumn(label: Text('No.')),
                DataColumn(label: Text('Cover')),
                DataColumn(label: Text('Judul Buku')),
                DataColumn(label: Text('ISBN')),
                DataColumn(label: Text('Penerbit')),
                DataColumn(label: Text('Kategori')),
                DataColumn(label: Text('Stok')),
                DataColumn(label: Text('Aksi')),
              ],
              rows: List.generate(daftarBuku.length, (index) {
                final buku = daftarBuku[index];

                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 42,
                          height: 54,
                          color: colors.surfaceContainerHighest,
                          child: buku.cover != null
                              ? Image.memory(buku.cover!, fit: BoxFit.cover)
                              : (buku.coverUrl != null &&
                                      buku.coverUrl!.isNotEmpty)
                                  ? Image.network(
                                      buku.coverUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.menu_book,
                                        color: colors.secondary,
                                      ),
                                    )
                                  : Icon(
                                      Icons.menu_book,
                                      color: colors.secondary,
                                    ),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          buku.judul,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(buku.isbn)),
                    DataCell(Text(buku.penerbit)),
                    DataCell(Text(buku.kategori)),
                    DataCell(Text('${buku.stok}')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Detail',
                            onPressed: () => onDetail(buku),
                            icon: const Icon(Icons.visibility_outlined),
                            color: colors.primary,
                          ),
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () => onEdit(buku),
                            icon: const Icon(Icons.edit_outlined),
                            color: colors.secondary,
                          ),
                          IconButton(
                            tooltip: 'Hapus',
                            onPressed: () => onHapus(buku),
                            icon: const Icon(Icons.delete_outline),
                            color: colors.error,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
