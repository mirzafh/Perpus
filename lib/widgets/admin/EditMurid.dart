import 'package:flutter/material.dart';

class EditMurid extends StatefulWidget {
  final Map<String, String> student;

  const EditMurid({
    super.key,
    required this.student,
  });

  @override
  State<EditMurid> createState() => _EditMuridState();
}

class _EditMuridState extends State<EditMurid> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController namaController;
  late final TextEditingController nisnController;

  late String kelas;
  late String gender;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.student['nama'] ?? '');
    nisnController = TextEditingController(text: widget.student['nisn'] ?? '');
    kelas = widget.student['kelas'] ?? 'X';
    gender = widget.student['gender'] ?? 'Laki-laki';
  }

  @override
  void dispose() {
    namaController.dispose();
    nisnController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop<Map<String, String>>(context, {
      'nama': namaController.text.trim(),
      'nisn': nisnController.text.trim(),
      'kelas': kelas,
      'gender': gender,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final colorBox = colors.surfaceContainerHigh;

    return AlertDialog(
      backgroundColor: colorBox,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      title: const Text(
        'Edit Data Murid',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama Murid',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama murid wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: nisnController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'NISN',
                    prefixIcon: Icon(Icons.badge_outlined),
                    counterText: '',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        !RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                      return 'NISN harus terdiri dari 10 angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: kelas,
                  decoration: const InputDecoration(
                    labelText: 'Kelas',
                    prefixIcon: Icon(Icons.school_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'X', child: Text('Kelas X')),
                    DropdownMenuItem(value: 'XI', child: Text('Kelas XI')),
                    DropdownMenuItem(value: 'XII', child: Text('Kelas XII')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => kelas = value);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: gender,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Kelamin',
                    prefixIcon: Icon(Icons.people_outline),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Laki-laki',
                      child: Text('Laki-laki'),
                    ),
                    DropdownMenuItem(
                      value: 'Perempuan',
                      child: Text('Perempuan'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => gender = value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: _simpan,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Simpan Perubahan'),
        ),
      ],
    );
  }
}
