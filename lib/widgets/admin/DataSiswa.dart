import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PopupDataSiswa {
  static Future<Map<String, String>?> tampilkan(BuildContext context) {
    final cariController = TextEditingController();
    final muridStream = FirebaseFirestore.instance
        .collection('murid')
        .orderBy('nama')
        .snapshots();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            return AlertDialog(
              title: const Text('Pilih Data Siswa'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: cariController,
                      onChanged: (_) => setPopupState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Cari nama atau NISN siswa',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 220,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: muridStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];
                          final daftarSiswa = docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return {
                              'nama': (data['nama'] ?? '').toString(),
                              'nis': (data['nisn'] ?? doc.id).toString(),
                              'kelas': (data['kelas'] ?? '-').toString(),
                              'gender': (data['gender'] ?? '-').toString(),
                            };
                          }).toList();

                          final kata = cariController.text.toLowerCase();
                          final hasilPencarian = daftarSiswa.where((siswa) {
                            return siswa['nama']!.toLowerCase().contains(kata) ||
                                siswa['nis']!.contains(kata);
                          }).toList();

                          if (hasilPencarian.isEmpty) {
                            return const Center(
                              child: Text('Siswa tidak ditemukan'),
                            );
                          }

                          return ListView.builder(
                            itemCount: hasilPencarian.length,
                            itemBuilder: (context, index) {
                              final siswa = hasilPencarian[index];
                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(siswa['nama']!),
                                subtitle: Text(
                                  'NISN: ${siswa['nis']} â€¢ Kelas ${siswa['kelas']}',
                                ),
                                onTap: () {
                                  Navigator.pop(dialogContext, siswa);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      cariController.dispose();
    });
  }
}
