import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpus/widgets/students/BackPill.dart';
import 'package:perpus/pages/Login.dart';
import 'package:perpus/widgets/admin/ModelBuku.dart';

class ProfileStudents extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final String? nisn; // NISN siswa yang login (default: dari sesi login)

  const ProfileStudents({
    super.key,
    required this.onToggleTheme,
    this.nisn,
  });

  @override
  State<ProfileStudents> createState() => _ProfileStudentsState();
}

class _ProfileStudentsState extends State<ProfileStudents> {
  @override
  Widget build(BuildContext context) {
    final colorBg = Theme.of(context).scaffoldBackgroundColor;
    final colorTextJudul = Theme.of(context).colorScheme.onSurface;
    final colorTextDesk = Theme.of(context).colorScheme.onSurfaceVariant;
    final colorBox = Theme.of(context).colorScheme.surface;
    final colorOutline = Theme.of(context).colorScheme.outline;
    final colorIcon = Theme.of(context).colorScheme.primary;

    final nisnAktif = widget.nisn ?? SesiLogin.nisn ?? '';
    if (nisnAktif.isEmpty) {
      return Scaffold(
        backgroundColor: colorBg,
        body: const Center(
          child: Text('Sesi tidak ditemukan, silakan login ulang.'),
        ),
      );
    }

    // Mendengarkan data profil siswa secara realtime (dokumen murid = NISN)
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('murid')
          .doc(nisnAktif)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Scaffold(
            backgroundColor: colorBg,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        String nama = 'Data murid tidak ditemukan';
        String kelas = '-';
        String gender = 'Laki-laki';
        String nisn = nisnAktif;
        int streak = 0;

        final data = snapshot.data?.data();
        if (data != null) {
          nama = (data['nama'] ?? 'Tanpa Nama').toString();
          kelas = (data['kelas'] ?? '-').toString();
          gender = (data['gender'] ?? 'Laki-laki').toString();
          nisn = (data['nisn'] ?? nisnAktif).toString();
          streak = (data['streak'] is num) ? (data['streak'] as num).toInt() : 0;
        }

        final bool isLaki = gender.toLowerCase().contains('laki');

        return Scaffold(
          backgroundColor: colorBg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Backpill(),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            width: 1.5,
                            color: const Color(0xFFFEE2E2),
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(
                                  onToggleTheme: widget.onToggleTheme,
                                ),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Color(0xFFDC2626),
                            size: 16,
                          ),
                          tooltip: 'Keluar',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: colorBox,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorOutline, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 50,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colorIcon,
                              shape: BoxShape.circle,
                              border: Border.all(color: colorOutline, width: 2),
                            ),
                            child: Icon(
                              isLaki ? Icons.male_rounded : Icons.female_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Nama & Kelas realtime
                  Center(
                    child: Text(
                      nama,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorTextJudul,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Kelas $kelas',
                      style: TextStyle(fontSize: 14, color: colorTextDesk),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Kartu Detail Biodata
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorBox,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorOutline,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Akun',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colorTextJudul,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildInfoItem(Icons.badge_outlined, 'NISN', nisn),
                        Divider(height: 24, color: colorOutline),
                        _buildInfoItem(Icons.class_outlined, 'Kelas', 'Kelas $kelas'),
                        Divider(height: 24, color: colorOutline),
                        _buildInfoItem(
                          isLaki ? Icons.male_rounded : Icons.female_rounded,
                          'Gender',
                          gender,
                        ),
                        Divider(height: 24, color: colorOutline),
                        _buildInfoItem(
                          Icons.local_fire_department_outlined,
                          'Streak Meminjam',
                          '$streak kali',
                        ),
                        Divider(height: 24, color: colorOutline),

                        // Total Buku Dipinjam realtime (Stream dari koleksi 'peminjaman')
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_stories_outlined,
                                color: Color(0xFFD97706),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Buku Dipinjam',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('peminjaman')
                                        .where('nisn', isEqualTo: nisn)
                                        .snapshots(),
                                    builder: (context, pinjamSnapshot) {
                                      // Hanya hitung peminjaman yang benar-benar terjadi
                                      final totalPinjam =
                                          (pinjamSnapshot.data?.docs ?? [])
                                              .where((d) {
                                        final st = (d.data()
                                                as Map<String, dynamic>)['status'];
                                        return st == 'dipinjam' ||
                                            st == 'kembali';
                                      }).length;
                                      return Text(
                                        '$totalPinjam Buku',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD97706),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    final colorTextJudul = Theme.of(context).colorScheme.onSurface;
    final colorTextDesk = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorTextJudul,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorTextDesk,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
