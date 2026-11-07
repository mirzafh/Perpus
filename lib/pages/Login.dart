import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpus/main.dart';
import 'package:perpus/pages/admin/homeAdmins.dart';
import 'package:perpus/pages/students/homeStudents.dart';
import 'package:perpus/widgets/admin/ModelBuku.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const LoginPage({super.key, required this.onToggleTheme});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
  final inputNama = _namaController.text.trim();
  final inputNisn = _passwordController.text.trim(); // Diinput di password (berisi NISN)

  if (inputNama.isEmpty || inputNisn.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nama dan NISN (password) wajib diisi!')),
    );
    return;
  }

  // 1. Cek Login Admin
  if (inputNama == '1' && inputNisn == '1') {
    SesiLogin.nisn = null;
    SesiLogin.nama = null;
    SesiLogin.kelas = null;
    SesiLogin.gender = null;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Homeadmins(
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil Login Sebagai Admin')),
    );
    return;
  }

  // 2. Cek Login Siswa Berdasarkan Document ID (NISN)
  try {
    // Mengambil dokumen langsung menggunakan NISN sebagai ID-nya
    final docSnapshot = await FirebaseFirestore.instance
        .collection('murid')
        .doc(inputNisn)
        .get();

    if (docSnapshot.exists) {
      final dataMurid = docSnapshot.data() as Map<String, dynamic>;
      final namaDatabase = (dataMurid['nama'] ?? '').toString().trim();

      // Cocokkan nama yang diinput dengan nama di database (case-insensitive)
      if (namaDatabase.toLowerCase() == inputNama.toLowerCase()) {
        if (!mounted) return;
        // Simpan sesi siswa agar halaman lain memakai NISN yang benar
        SesiLogin.nisn = inputNisn;
        SesiLogin.nama = namaDatabase;
        SesiLogin.kelas = (dataMurid['kelas'] ?? '').toString();
        SesiLogin.gender = (dataMurid['gender'] ?? '').toString();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeStudents(
              onToggleTheme: widget.onToggleTheme,
              nisn: inputNisn, // Teruskan NISN ke halaman siswa
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selamat datang, $namaDatabase!')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama murid tidak sesuai dengan NISN tersebut!')),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NISN tidak terdaftar di database!')),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTextJudul = Theme.of(context).colorScheme.onSurface;
    final colorTextDesk = Theme.of(context).colorScheme.onSurfaceVariant;
    final colorBg = Theme.of(context).scaffoldBackgroundColor;
    final colorPanel = Theme.of(context).colorScheme.surface;

    final Gradient warnaGradientLogin = isDark
        ? Warna.darkGradientLogin
        : Warna.lightGradientLogin;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: warnaGradientLogin),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final panelHeight = screenHeight * 0.62;

            return Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: panelHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorBg,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.25 : 0.15,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                      child: Container(
                        color: colorPanel,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28, 25, 28, 24),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: (panelHeight - 49).clamp(
                                0.0,
                                double.infinity,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pathama',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: colorTextJudul,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Silahkan isi Nama Lengkap dan NISN',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorTextDesk,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // INPUT NAMA MURID
                                TextField(
                                  controller: _namaController,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    hintText: 'Nama Murid',
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF1D261F).withValues(alpha: 0.8)
                                        : Colors.white.withValues(alpha: 0.85),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF2A2F38)
                                            : const Color(0xFFCCCCCC),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                // INPUT PASSWORD (DIISI NISN)
                                TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _login(),
                                  decoration: InputDecoration(
                                    hintText: 'Password (NISN)',
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF1D261F).withValues(alpha: 0.8)
                                        : Colors.white.withValues(alpha: 0.85),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF2A2F38)
                                            : const Color(0xFFCCCCCC),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 75),
                                Center(
                                  child: SizedBox(
                                    width: 138,
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF00A995),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      child: const Text(
                                        'MASUK',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
