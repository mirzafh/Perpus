import 'dart:convert';
import 'dart:typed_data';

// Menyimpan sesi siswa yang sedang login
class SesiLogin {
  static String? nisn;
  static String? nama;
  static String? kelas;
  static String? gender;
}

class Buku {
  final String isbn;
  final String judul;
  final String penerbit;
  final String kategori;
  final int stok;
  final Uint8List? cover; // Untuk preview sementara / data Base64 lama
  final String? coverUrl; // URL Firebase Storage
  final int dipinjamCount;

  const Buku({
    required this.isbn,
    required this.judul,
    required this.penerbit,
    required this.kategori,
    required this.stok,
    this.cover,
    this.coverUrl,
    this.dipinjamCount = 0,
  });

  Buku copyWith({
    String? isbn,
    String? judul,
    String? penerbit,
    String? kategori,
    int? stok,
    Uint8List? cover,
    String? coverUrl,
    int? dipinjamCount,
  }) {
    return Buku(
      isbn: isbn ?? this.isbn,
      judul: judul ?? this.judul,
      penerbit: penerbit ?? this.penerbit,
      kategori: kategori ?? this.kategori,
      stok: stok ?? this.stok,
      cover: cover ?? this.cover,
      coverUrl: coverUrl ?? this.coverUrl,
      dipinjamCount: dipinjamCount ?? this.dipinjamCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isbn': isbn,
      'judul': judul,
      'penerbit': penerbit,
      'kategori': kategori,
      'stok': stok,
      'coverUrl': coverUrl,
      if (cover != null) 'coverBase64': base64Encode(cover!),
      'dipinjamCount': dipinjamCount,
    };
  }

  factory Buku.fromMap(Map<String, dynamic> map, {String? docId}) {
    Uint8List? decodedCover;
    final coverStr = map['coverBase64'];
    if (coverStr is String && coverStr.isNotEmpty) {
      try {
        decodedCover = base64Decode(coverStr);
      } catch (_) {}
    }
    return Buku(
      isbn: (map['isbn'] ?? docId ?? '').toString(),
      judul: (map['judul'] ?? '').toString(),
      penerbit: (map['penerbit'] ?? '').toString(),
      kategori: (map['kategori'] ?? 'Lainnya').toString(),
      stok: (map['stok'] is num)
          ? (map['stok'] as num).toInt()
          : int.tryParse('${map['stok']}') ?? 0,
      cover: decodedCover,
      coverUrl: (map['coverUrl'] ?? '').toString().isEmpty
          ? null
          : map['coverUrl'].toString(),
      dipinjamCount: (map['dipinjamCount'] is num)
          ? (map['dipinjamCount'] as num).toInt()
          : 0,
    );
  }
}

const List<String> kategoriBuku = [
  'Agama',
  'Sains',
  'Novel',
  'Jurnal',
  'Sejarah',
  'Pendidikan',
  'Teknologi',
  'Biografi',
  'Komik',
  'Lainnya',
];

final List<Buku> dummyBuku = [
  const Buku(
    isbn: '9786020324784',
    judul: 'Laskar Pelangi',
    penerbit: 'Bentang Pustaka',
    kategori: 'Novel',
    stok: 12,
  ),
  const Buku(
    isbn: '9786020647823',
    judul: 'Bumi',
    penerbit: 'Gramedia',
    kategori: 'Novel',
    stok: 8,
  ),
  const Buku(
    isbn: '9786230000001',
    judul: 'Fisika Dasar',
    penerbit: 'Erlangga',
    kategori: 'Sains',
    stok: 15,
  ),
  const Buku(
    isbn: '9786230000002',
    judul: 'Sejarah Indonesia',
    penerbit: 'Yudhistira',
    kategori: 'Sejarah',
    stok: 10,
  ),
  const Buku(
    isbn: '9786230000003',
    judul: 'Teknologi Informasi',
    penerbit: 'Andi Publisher',
    kategori: 'Teknologi',
    stok: 7,
  ),
  const Buku(
    isbn: '9786230000004',
    judul: 'Pendidikan Agama',
    penerbit: 'Erlangga',
    kategori: 'Agama',
    stok: 20,
  ),
];
