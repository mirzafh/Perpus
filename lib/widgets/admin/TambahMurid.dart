import 'package:flutter/material.dart';

class TambahMurid extends StatefulWidget {
  const TambahMurid({super.key});

  @override
  State<TambahMurid> createState() => _TambahMuridState();
}

class _TambahMuridState extends State<TambahMurid> {
  final namaController = TextEditingController();
  final nisnController = TextEditingController();

  String? selectedKelas;
  String? selectedGender;

  @override
  void dispose() {
    namaController.dispose();
    nisnController.dispose();
    super.dispose();
  }

  void submitData() {
  final nama = namaController.text.trim();
  final nisn = nisnController.text.trim();

  if (nama.isEmpty ||
      nisn.isEmpty ||
      selectedKelas == null ||
      selectedGender == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lengkapi semua data murid!')),
    );
    return;
  }

  if (!RegExp(r'^\d{10}$').hasMatch(nisn)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NISN harus terdiri dari 10 angka!')),
    );
    return;
  }

  // Penyimpanan ke Firestore dilakukan oleh DataAllSiswa.addStudent
  // (dokumen memakai NISN sebagai ID agar login berfungsi).
  Navigator.pop(context, <String, String>{
    'nama': nama,
    'nisn': nisn,
    'kelas': selectedKelas!,
    'gender': selectedGender!,
  });
}

  @override
  Widget build(BuildContext context) {
    final colorBox = Theme.of(context).colorScheme.surface;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),

      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),

        padding: const EdgeInsets.all(26),

        decoration: BoxDecoration(
          color: colorBox,
          borderRadius: BorderRadius.circular(24),
        ),

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER DIALOG
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tambah Murid',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              Text(
                'Masukkan informasi murid baru.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 25),

              // NAMA
              _label('Nama Murid'),

              TextField(
                controller: namaController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration(
                  'Masukkan nama lengkap',
                  Icons.person_outline,
                ),
              ),

              const SizedBox(height: 18),

              // NISN
              _label('NISN'),

              TextField(
                controller: nisnController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: _decoration(
                  'Masukkan 10 digit NISN',
                  Icons.badge_outlined,
                ).copyWith(
                  counterText: '',
                ),
              ),

              const SizedBox(height: 18),

              // KELAS
              _label('Kelas'),

              DropdownButtonFormField<String>(
                initialValue: selectedKelas,
                isExpanded: true,

                decoration: _decoration(
                  'Pilih kelas',
                  Icons.school_outlined,
                ),

                items: ['XA','XB', 'XI', 'XII'].map((kelas) {
                  return DropdownMenuItem<String>(
                    value: kelas,
                    child: Text('Kelas $kelas'),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    selectedKelas = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              // JENIS KELAMIN
              _label('Jenis Kelamin'),

              DropdownButtonFormField<String>(
                initialValue: selectedGender,
                isExpanded: true,

                decoration: _decoration(
                  'Pilih jenis kelamin',
                  Icons.wc_outlined,
                ),

                items: [
                  'Laki-laki',
                  'Perempuan',
                ].map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),

              const SizedBox(height: 28),

              // TOMBOL
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        foregroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: submitData,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF347B51),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LABEL
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // INPUT DECORATION
  InputDecoration _decoration(
    String hint,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final colorBoxSekunder = colors.surfaceContainerHigh;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: colorBoxSekunder,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
    );
  }
}
