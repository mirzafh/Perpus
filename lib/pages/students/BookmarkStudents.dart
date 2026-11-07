import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpus/pages/BookDetail.dart';
import 'package:perpus/widgets/admin/ModelBuku.dart';
import 'package:perpus/widgets/students/BackPill.dart';

class Bookmarkstudents extends StatefulWidget {
  const Bookmarkstudents({super.key});

  @override
  State<Bookmarkstudents> createState() => _BookmarkstudentsState();
}

class _BookmarkstudentsState extends State<Bookmarkstudents> {
  int selectedBook = 0;
  final List<String> categories = ['Aktif', 'Selesai', 'Wishlist'];

  Future<void> _bukaDetail({String? isbn, String? judul}) async {
    try {
      final db = FirebaseFirestore.instance;
      DocumentSnapshot<Map<String, dynamic>>? doc;

      if (isbn != null && isbn.isNotEmpty) {
        final d = await db.collection('buku').doc(isbn).get();
        if (d.exists) doc = d;
      }
      if (doc == null && judul != null && judul.isNotEmpty) {
        final q = await db
            .collection('buku')
            .where('judul', isEqualTo: judul)
            .limit(1)
            .get();
        if (q.docs.isNotEmpty) doc = q.docs.first;
      }

      if (!mounted) return;
      final data = doc?.data();
      if (doc == null || data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data buku tidak ditemukan (mungkin sudah dihapus).'),
          ),
        );
        return;
      }

      final buku = Buku.fromMap(data, docId: doc.id);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailBook(buku: buku)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka detail buku: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorBg = Theme.of(context).scaffoldBackgroundColor;
    final colorBox = Theme.of(context).colorScheme.surface;
    final colorOutline = Theme.of(context).colorScheme.outline;
    final colorIcon = Theme.of(context).colorScheme.primary;
    final colorBoxsc = Theme.of(context).colorScheme.surfaceContainerHigh;
    final screenWidth = MediaQuery.of(context).size.width;
    final nisn = SesiLogin.nisn ?? '1234567890';

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
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorBox,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2.0, color: colorOutline),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Koleksi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(categories.length, (index) {
                        final isSelected = selectedBook == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedBook = index;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                right: index == categories.length - 1 ? 0 : 8,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? colorIcon : colorBoxsc,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? colorIcon : colorOutline,
                                ),
                              ),
                              child: Text(
                                categories[index],
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: screenWidth < 500 ? 11 : 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: selectedBook == 2
                    ? _buildWishlist(nisn, colorBox, colorOutline, colorBoxsc)
                    : _buildPinjamanList(
                        nisn,
                        selectedBook == 0 ? 'dipinjam' : 'kembali',
                        colorBox,
                        colorOutline,
                        colorBoxsc,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinjamanList(
    String nisn,
    String statusFilter,
    Color colorBox,
    Color colorOutline,
    Color colorBoxsc,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('peminjaman')
          .where('nisn', isEqualTo: nisn)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = (snapshot.data?.docs ?? []).where((doc) {
          final d = doc.data() as Map<String, dynamic>;
          if (statusFilter == 'dipinjam') {
            return d['status'] == 'dipinjam' || d['status'] == 'pending';
          }
          return d['status'] == 'kembali';
        }).toList();

        if (docs.isEmpty) {
          return const Center(child: Text('Belum ada buku di daftar ini.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final d = docs[index].data() as Map<String, dynamic>;
            return _cardItem(
              judul: (d['judulBuku'] ?? '-').toString(),
              sub: 'Kode: ${d['kodeInventaris'] ?? '-'}',
              label: (d['status'] ?? '').toString().toUpperCase(),
              onTap: () => _bukaDetail(
                isbn: d['isbn']?.toString(),
                judul: d['judulBuku']?.toString(),
              ),
              colorBox: colorBox,
              colorOutline: colorOutline,
              colorBoxsc: colorBoxsc,
            );
          },
        );
      },
    );
  }

  Widget _buildWishlist(
    String nisn,
    Color colorBox,
    Color colorOutline,
    Color colorBoxsc,
  ) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('murid').doc(nisn).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final wishlist = List<String>.from(data?['wishlist'] ?? []);

        if (wishlist.isEmpty) {
          return const Center(child: Text('Belum ada buku di Wishlist.'));
        }

        return ListView.builder(
          itemCount: wishlist.length,
          itemBuilder: (context, index) {
            return _cardItem(
              judul: wishlist[index],
              sub: 'Tersimpan di koleksi kamu',
              label: 'Wishlist',
              onTap: () => _bukaDetail(judul: wishlist[index]),
              colorBox: colorBox,
              colorOutline: colorOutline,
              colorBoxsc: colorBoxsc,
            );
          },
        );
      },
    );
  }

  Widget _cardItem({
    required String judul,
    required String sub,
    required String label,
    required VoidCallback onTap,
    required Color colorBox,
    required Color colorOutline,
    required Color colorBoxsc,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorBox,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorOutline),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorBoxsc,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
