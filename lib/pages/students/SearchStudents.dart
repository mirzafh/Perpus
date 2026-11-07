import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpus/pages/BookDetail.dart';
import 'package:perpus/widgets/admin/ModelBuku.dart';
import 'package:perpus/widgets/students/BackPill.dart';

class Searchstudents extends StatefulWidget {
  const Searchstudents({super.key});

  @override
  State<Searchstudents> createState() => _SearchstudentsState();
}

class _SearchstudentsState extends State<Searchstudents> {
  final TextEditingController _searchController = TextEditingController();
  late final Stream<QuerySnapshot> _bukuStream =
      FirebaseFirestore.instance.collection('buku').snapshots();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorBg = Theme.of(context).scaffoldBackgroundColor;
    final colorTextJudul = Theme.of(context).colorScheme.onSurface;
    final colorTextDesk = Theme.of(context).colorScheme.onSurfaceVariant;
    final colorBox = Theme.of(context).colorScheme.surface;
    final colorOutline = Theme.of(context).colorScheme.outline;
    final colorIcon = Theme.of(context).colorScheme.primary;
    final colorBoxsc = Theme.of(context).colorScheme.surfaceContainerHigh;

    return Scaffold(
      backgroundColor: colorBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Backpill(),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1D261F).withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari judul, kategori, atau penerbit buku...',
                    hintStyle: TextStyle(color: colorTextDesk),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: Icon(Icons.search, color: colorIcon),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _bukuStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final keyword = _searchController.text.toLowerCase().trim();
                    final listBuku = (snapshot.data?.docs ?? [])
                        .map((doc) => Buku.fromMap(
                              doc.data() as Map<String, dynamic>,
                              docId: doc.id,
                            ))
                        .where((b) {
                      if (keyword.isEmpty) return true;
                      return b.judul.toLowerCase().contains(keyword) ||
                          b.kategori.toLowerCase().contains(keyword) ||
                          b.penerbit.toLowerCase().contains(keyword);
                    }).toList();

                    if (listBuku.isEmpty) {
                      return const Center(
                        child: Text('Buku tidak ditemukan.'),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: listBuku.length,
                      itemBuilder: (context, index) {
                        final buku = listBuku[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailBook(buku: buku),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorBox,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colorOutline),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: colorBoxsc,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: buku.cover != null
                                        ? Image.memory(
                                            buku.cover!,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Icons.menu_book_rounded,
                                            size: 50,
                                            color: Colors.black26,
                                          ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          buku.judul,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: colorTextJudul,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          buku.kategori,
                                          style: TextStyle(
                                            color: colorTextDesk,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          '${buku.penerbit} â€¢ Stok: ${buku.stok}',
                                          style: TextStyle(
                                            color: colorTextDesk,
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
}
