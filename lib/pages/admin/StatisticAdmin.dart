import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpus/widgets/students/BackPill.dart';

class StatisticsAdmins extends StatelessWidget {
  const StatisticsAdmins({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-1.0, -1.0),
            radius: 1.5,
            colors: [
              colors.primaryContainer,
              colors.surface,
              colors.surface,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: SizedBox(
                  height: 45,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        'Statistik',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Backpill(),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('peminjaman')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];

                    // 1. Bulanan
                    final List<double> bulanan = List.filled(12, 0);
                    const namaBulan = [
                      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
                    ];

                    // 2. Genre
                    final Map<String, double> genreCount = {
                      'Novel': 0,
                      'Sains': 0,
                      'Sejarah': 0,
                      'Agama': 0,
                      'Teknologi': 0,
                    };

                    // 3. Kelas
                    final Map<String, double> kelasCount = {
                      'X': 0,
                      'XA': 0,
                      'XB': 0,
                      'XI': 0,
                      'XII': 0,
                    };

                    // 4. Gender
                    double lakiCount = 0;
                    double perempuanCount = 0;

                    for (final doc in docs) {
                      final d = doc.data() as Map<String, dynamic>;
                      final ts = d['waktuPinjam'] as Timestamp?;
                      if (ts != null) {
                        final monthIndex = ts.toDate().month - 1;
                        bulanan[monthIndex] += 1;
                      }

                      final kat = (d['kategoriBuku'] ?? 'Lainnya').toString();
                      genreCount[kat] = (genreCount[kat] ?? 0) + 1;

                      final kls = (d['kelasSiswa'] ?? 'X').toString();
                      kelasCount[kls] = (kelasCount[kls] ?? 0) + 1;

                      final gdr =
                          (d['genderSiswa'] ?? '').toString().toLowerCase();
                      if (gdr.contains('perempuan')) {
                        perempuanCount += 1;
                      } else if (gdr.contains('laki')) {
                        lakiCount += 1;
                      }
                    }

                    final maxBulanVal =
                        bulanan.reduce((a, b) => a > b ? a : b);
                    final topGenre = genreCount.entries
                        .reduce((a, b) => a.value >= b.value ? a : b);
                    final topKelas = kelasCount.entries
                        .reduce((a, b) => a.value >= b.value ? a : b);

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
                      children: [
                        StatisticCard(
                          title: 'Data Peminjaman Bulanan',
                          subtitle: 'Jumlah peminjaman buku setiap bulan',
                          icon: Icons.calendar_month_rounded,
                          accent: const Color(0xFF16A765),
                          labels: namaBulan,
                          values: bulanan,
                          maxY: (maxBulanVal + 5).clamp(10, 500),
                          metric: '${maxBulanVal.toInt()} Buku',
                          metricTitle: 'Peminjaman tertinggi',
                          description:
                              'Data dihitung secara real-time dari transaksi peminjaman di Firebase.',
                        ),
                        StatisticCard(
                          title: 'Genre yang Sering Dipinjam',
                          subtitle: 'Perbandingan peminjaman berdasarkan genre',
                          icon: Icons.auto_stories_rounded,
                          accent: const Color(0xFF3979F6),
                          labels: genreCount.keys.take(5).toList(),
                          values: genreCount.values.take(5).toList(),
                          maxY: (topGenre.value + 5).clamp(10, 500),
                          metric: topGenre.key,
                          metricTitle: 'Genre paling populer',
                          description:
                              'Genre ${topGenre.key} menjadi pilihan paling banyak dipinjam oleh siswa.',
                        ),
                        StatisticCard(
                          title: 'Kelas yang Sering Meminjam',
                          subtitle: 'Jumlah peminjaman berdasarkan kelas',
                          icon: Icons.groups_rounded,
                          accent: const Color(0xFFE59A35),
                          labels: kelasCount.keys.take(5).toList(),
                          values: kelasCount.values.take(5).toList(),
                          maxY: (topKelas.value + 5).clamp(10, 500),
                          metric: 'Kelas ${topKelas.key}',
                          metricTitle: 'Kelas paling aktif',
                          description:
                              'Kelas ${topKelas.key} memiliki jumlah peminjaman tertinggi.',
                        ),
                        StatisticCard(
                          title: 'Statistik Peminjaman Gender',
                          subtitle: 'Perbandingan peminjaman berdasarkan gender',
                          icon: Icons.people_alt_rounded,
                          accent: const Color(0xFF9B70D6),
                          labels: const ['Laki-laki', 'Perempuan'],
                          values: [lakiCount, perempuanCount],
                          maxY: ((lakiCount > perempuanCount
                                      ? lakiCount
                                      : perempuanCount) +
                                  5)
                              .clamp(10, 500),
                          metric: perempuanCount >= lakiCount
                              ? 'Perempuan'
                              : 'Laki-laki',
                          metricTitle: 'Peminjaman terbanyak',
                          description:
                              'Perbandingan jumlah transaksi peminjaman siswa laki-laki dan perempuan.',
                        ),
                      ],
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

class StatisticCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<String> labels;
  final List<double> values;
  final double maxY;
  final String metric;
  final String metricTitle;
  final String description;

  const StatisticCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.labels,
    required this.values,
    required this.maxY,
    required this.metric,
    required this.metricTitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 600;
          final chart = SizedBox(
            height: 190,
            child: MiniBarChart(
              labels: labels,
              values: values,
              maxY: maxY,
              accent: accent,
            ),
          );

          final information = Container(
            height: 190,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accent, size: 21),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  metricTitle,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  metric,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );

          if (isSmall) {
            return Column(
              children: [
                chart,
                const SizedBox(height: 14),
                information,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: chart),
              const SizedBox(width: 18),
              Expanded(flex: 5, child: information),
            ],
          );
        },
      ),
    );
  }
}

class MiniBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final double maxY;
  final Color accent;

  const MiniBarChart({
    super.key,
    required this.labels,
    required this.values,
    required this.maxY,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${labels[group.x.toInt()]}\n${rod.toY.toInt()} peminjaman',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              );
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colors.outline.withValues(alpha: 0.15),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxY / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 9,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 27,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: labels.length > 6 ? 9 : 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(values.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index],
                color: accent,
                width: labels.length > 6 ? 12 : 25,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: colors.surfaceContainerHighest,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
