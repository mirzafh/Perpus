import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpus/main.dart';
import 'package:perpus/pages/Login.dart';
import 'package:perpus/widgets/admin/BoxAdmin.dart';
import 'package:perpus/widgets/admin/HeaderTopAdmins.dart';

class Homeadmins extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const Homeadmins({
    super.key,
    required this.onToggleTheme,
  });

  @override
  State<Homeadmins> createState() => _HomeadminsState();
}

class _HomeadminsState extends State<Homeadmins> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Gradient warnaBg =
        isDark ? Warna.darkGreenRadialGlow : Warna.lightGreenRadialGlow;

    final db = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: warnaBg,
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: db.collection('buku').snapshots(),
          builder: (context, bukuSnap) {
            final totalBuku = bukuSnap.data?.docs.length ?? 0;

            return StreamBuilder<QuerySnapshot>(
              stream: db.collection('murid').snapshots(),
              builder: (context, muridSnap) {
                final totalMurid = muridSnap.data?.docs.length ?? 0;

                return StreamBuilder<QuerySnapshot>(
                  stream: db
                      .collection('peminjaman')
                      .where('status', isEqualTo: 'dipinjam')
                      .snapshots(),
                  builder: (context, pinjamSnap) {
                    final peminjamanAktif = pinjamSnap.data?.docs.length ?? 0;

                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        HeaderTopAdmins(
                          totalBuku: totalBuku,
                          totalMurid: totalMurid,
                          peminjamanAktif: peminjamanAktif,
                          onToggleTheme: widget.onToggleTheme,
                          onLogout: () {
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
                        ),
                        const Boxadmin(),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
