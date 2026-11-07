import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpus/pages/BookDetail.dart';
import 'package:perpus/widgets/admin/ModelBuku.dart';

class BookRowStudent extends StatelessWidget {
  final String title;
  final bool showTitle;
  final String? filterGenre;
  final bool sortByPopular;

  const BookRowStudent({
    super.key,
    required this.title,
    required this.showTitle,
    this.filterGenre,
    this.sortByPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          height: 195,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('buku').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var listBuku = (snapshot.data?.docs ?? []).map((doc) {
                return Buku.fromMap(
                  doc.data() as Map<String, dynamic>,
                  docId: doc.id,
                );
              }).toList();

              if (filterGenre != null && filterGenre != 'Semua') {
                listBuku = listBuku
                    .where((b) =>
                        b.kategori.toLowerCase() == filterGenre!.toLowerCase())
                    .toList();
              }

              if (sortByPopular) {
                listBuku.sort(
                  (a, b) => b.dipinjamCount.compareTo(a.dipinjamCount),
                );
              }

              if (listBuku.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: const Center(
                    child: Text('Belum ada buku pada kategori ini.'),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: listBuku.length,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
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
                      width: 135,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey.shade300,
                            Colors.grey.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (buku.cover != null)
                            Image.memory(buku.cover!, fit: BoxFit.cover)
                          else if (buku.coverUrl != null &&
                              buku.coverUrl!.isNotEmpty)
                            Image.network(
                              buku.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  color: Colors.black26,
                                  size: 46,
                                ),
                              ),
                            )
                          else
                            const Center(
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: Colors.black26,
                                size: 46,
                              ),
                            ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              color: Colors.black.withValues(alpha: 0.6),
                              child: Text(
                                buku.judul,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
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
    );
  }
}
