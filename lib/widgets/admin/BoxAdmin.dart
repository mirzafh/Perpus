import 'package:flutter/material.dart';
import 'package:perpus/pages/admin/NontificationAdmin.dart';
import 'package:perpus/pages/admin/PeminjamanAdmin.dart';
import 'package:perpus/pages/admin/PengembalianAdmin.dart';
import 'package:perpus/pages/admin/StatisticAdmin.dart';

class Boxadmin extends StatelessWidget {
  const Boxadmin({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colors = Theme.of(context).colorScheme;
    final colorBox = colors.surfaceContainerHigh;
    final colorIcon = colors.onSurfaceVariant;
    final colorOutline = colors.outline;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.025),
      margin: EdgeInsets.all(screenWidth * 0.025),

      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorOutline.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // JUDUL AKSES CEPAT
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, color: colors.primary, size: 30),

                const SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Akses Cepat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),

                    Text(
                      'Kelola perpustakaan dengan lebih mudah',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // BARIS PERTAMA
          Row(
            children: [
              // PEMINJAMAN BUKU
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) => const PeminjamanAdmins()),
                      ),
                    );
                  },
                  child: Container(
                    height: (screenWidth * 0.12).clamp(85, 150),
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: colorBox,
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Row(
                      children: [
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          color: colorIcon,
                          size: 28,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            'Peminjaman Buku',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: colorIcon,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              // PENGEMBALIAN BUKU
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) => const PengembalianAdmins()),
                      ),
                    );
                  },
                  child: Container(
                    height: (screenWidth * 0.12).clamp(85, 150),
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: colorBox,
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Row(
                      children: [
                        Icon(
                          Icons.assignment_return_rounded,
                          color: colorIcon,
                          size: 28,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            'Pengembalian Buku',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: colorIcon,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // BARIS KEDUA
          Row(
            children: [
              // STATISTIK
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatisticsAdmins(),
                      ),
                    );
                  },
                  child: Container(
                    height: (screenWidth * 0.12).clamp(85, 150),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorBox,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          color: colorIcon,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Statistik',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: colorIcon,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              // NOTIFICATION
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationAdmin(),
                      ),
                    );
                  },
                  child: Container(
                    height: (screenWidth * 0.12).clamp(85, 150),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorBox,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          color: colorIcon,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Notification',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: colorIcon,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
