import 'package:flutter/material.dart';
import 'package:perpus/pages/admin/DataAllSiswa.dart';
import 'package:perpus/pages/admin/DataBukuSiswa.dart';

class HeaderTopAdmins extends StatelessWidget {
  final String namaAdmin;
  final int totalBuku;
  final int totalMurid;
  final int peminjamanAktif;

  final VoidCallback onLogout;
  final VoidCallback onToggleTheme;

  const HeaderTopAdmins({
    super.key,
    this.namaAdmin = 'Admin',
    this.totalBuku = 0,
    this.totalMurid = 0,
    this.peminjamanAktif = 0,
    required this.onLogout,
    required this.onToggleTheme,
  });

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 11) {
      return 'Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Sore';
    } else {
      return 'Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.library_books_rounded,
                size: 38,
                color: colors.onSurface,
              ),

              const SizedBox(width: 10),

              Text(
                'Pathama',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),

              const Spacer(),

              IconButton(
                onPressed: onToggleTheme,
                style: IconButton.styleFrom(
                  backgroundColor: colors.surface,
                  foregroundColor: colors.primary,
                ),
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
                tooltip: 'Ganti Tema',
              ),

              const SizedBox(width: 10),

              IconButton(
                onPressed: onLogout,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF2F2),
                  foregroundColor: const Color(0xFFDC2626),
                ),
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Keluar',
              ),
            ],
          ),

          const SizedBox(height: 28),

          Text(
            'Selamat ${getGreeting()}, $namaAdmin!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Semoga hari ini produktif dalam mengelola perpustakaan.',
            style: TextStyle(
              fontSize: 15,
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 28),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 700) {
                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Buku',
                        value: totalBuku,
                        icon: Icons.menu_book_rounded,
                        color: const Color(0xFF16A765),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> const DataBukuAdmin() ));
                        },
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: _StatCard(
                        title: 'Total Murid',
                        value: totalMurid,
                        icon: Icons.people_alt_rounded,
                        color: const Color(0xFF3979F6),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> const DataMuridAdmin() ));
                        },
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: _StatCard(
                        title: 'Peminjaman Aktif',
                        value: peminjamanAktif,
                        icon: Icons.swap_horiz_rounded,
                        color: const Color(0xFFE9823C),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _StatCard(
                    title: 'Total Buku',
                    value: totalBuku,
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF16A765),
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    title: 'Total Murid',
                    value: totalMurid,
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF3979F6),
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    title: 'Peminjaman Aktif',
                    value: peminjamanAktif,
                    icon: Icons.swap_horiz_rounded,
                    color: const Color(0xFFE9823C),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(icon, color: color, size: 28),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
