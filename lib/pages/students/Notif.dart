import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpus/widgets/admin/ModelBuku.dart';
import 'package:perpus/widgets/students/BackPill.dart';

class NotifficationStudents extends StatefulWidget {
  const NotifficationStudents({super.key});

  @override
  State<NotifficationStudents> createState() => _NotifficationStudentsState();
}

class _NotifficationStudentsState extends State<NotifficationStudents> {
  final Set<String> _sudahDihapus = {};

  // Hapus notifikasi yang sudah lewat 1 hari (best-effort)
  Future<void> _hapusKadaluarsa(List<QueryDocumentSnapshot> list) async {
    final baru = list.where((d) => _sudahDihapus.add(d.id)).toList();
    if (baru.isEmpty) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final d in baru) {
        batch.delete(d.reference);
      }
      await batch.commit();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colorOutline = Theme.of(context).colorScheme.outline;
    final colorBox = Theme.of(context).colorScheme.surface;
    final colorTextJudul = Theme.of(context).colorScheme.onSurface;
    final colorTextDesk = Theme.of(context).colorScheme.onSurfaceVariant;
    final nisn = SesiLogin.nisn ?? '1234567890';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Backpill()],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorTextJudul,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifikasi')
                    .where('nisn', isEqualTo: nisn)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final batas = DateTime.now().subtract(const Duration(days: 1));
                  DateTime waktuDoc(QueryDocumentSnapshot d) {
                    final m = d.data() as Map<String, dynamic>;
                    return (m['waktu'] as Timestamp?)?.toDate() ?? DateTime.now();
                  }

                  final semua = snapshot.data?.docs ?? [];
                  final kadaluarsa =
                      semua.where((d) => waktuDoc(d).isBefore(batas)).toList();
                  if (kadaluarsa.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _hapusKadaluarsa(kadaluarsa),
                    );
                  }

                  // Terbaru -> terlama, hanya yang belum lewat 1 hari
                  final docs = semua
                      .where((d) => !waktuDoc(d).isBefore(batas))
                      .toList()
                    ..sort((a, b) => waktuDoc(b).compareTo(waktuDoc(a)));
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Belum ada notifikasi untukmu.'),
                    );
                  }

                  return ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final notif = docs[index].data() as Map<String, dynamic>;
                      final waktu = (notif['waktu'] as Timestamp?)?.toDate();
                      final timeStr = waktu != null
                          ? '${waktu.day}/${waktu.month} ${waktu.hour}:${waktu.minute.toString().padLeft(2, '0')}'
                          : 'Baru saja';

                      return _buildNotificationCard(
                        title: (notif['title'] ?? 'Info').toString(),
                        subtitle: (notif['subtitle'] ?? '').toString(),
                        time: timeStr,
                        type: (notif['type'] ?? 'info').toString(),
                        colorBox: colorBox,
                        colorTextJudul: colorTextJudul,
                        colorTextDesk: colorTextDesk,
                        colorOutline: colorOutline,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required String time,
    required String type,
    required Color colorBox,
    required Color colorTextJudul,
    required Color colorTextDesk,
    required Color colorOutline,
  }) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    if (type == 'warning') {
      iconData = Icons.access_time_filled_rounded;
      iconColor = const Color(0xFFD97706);
      bgColor = const Color(0xFFFEF3C7);
    } else if (type == 'success') {
      iconData = Icons.book_online_rounded;
      iconColor = const Color(0xFF0D9488);
      bgColor = const Color(0xFFCCFBF1);
    } else {
      iconData = Icons.notifications_active_rounded;
      iconColor = const Color(0xFF2563EB);
      bgColor = const Color(0xFFDBEAFE);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorBox,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorOutline, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colorTextJudul,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 11, color: colorTextDesk),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorTextDesk,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
