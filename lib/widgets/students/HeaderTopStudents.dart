import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HeaderTopStudents extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final String currentNisn;

  const HeaderTopStudents({
    super.key,
    required this.onToggleTheme,
    this.currentNisn = '10293', // NISN default siswa yang sedang aktif
  });

  // Menghitung total peminjaman siswa dari Firestore
  Future<int> _getTotalBukuDipinjam() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('peminjaman')
          .where('nisn', isEqualTo: currentNisn)
          .count()
          .get();
      return query.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final colorBox = Theme.of(context).colorScheme.surface;
    final colorOutline = Theme.of(context).colorScheme.outline;
    final colorIcon = Theme.of(context).colorScheme.primary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.1 > 90
          ? MediaQuery.of(context).size.height * 0.1
          : 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorIcon, Colors.transparent],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ikon Logo Kiri
              Container(
                height: (screenWidth * 0.1).clamp(40, 60),
                width: (screenWidth * 0.1).clamp(40, 60),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: colorBox,
                  border: Border.all(color: colorOutline, width: 3.0),
                ),
                child: Center(
                  child: Icon(
                    Icons.book,
                    color: colorIcon,
                    size: (screenWidth * 0.06).clamp(24, 32),
                  ),
                ),
              ),

              // Bagian Total Buku Dipinjam (Menggantikan 9999 statis)
              Container(
                height: (screenWidth * 0.1).clamp(40, 60),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: colorOutline, width: 3.0),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_stories_outlined,
                        color: const Color(0xFFD97706),
                        size: (screenWidth * 0.05).clamp(20, 28),
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      FutureBuilder<int>(
                        future: _getTotalBukuDipinjam(),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Text(
                            '$count',
                            style: TextStyle(
                              color: const Color(0xFFD97706),
                              fontSize: (screenWidth * 0.04).clamp(14, 20),
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol Pengubah Tema
              InkWell(
                onTap: onToggleTheme,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  height: (screenWidth * 0.1).clamp(40, 60),
                  width: (screenWidth * 0.1).clamp(40, 60),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: colorBox,
                    border: Border.all(
                      color: colorOutline,
                      width: 3.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.sunny,
                      color: Theme.of(context).colorScheme.primary,
                      size: (screenWidth * 0.06).clamp(24, 32),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
