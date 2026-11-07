import 'package:flutter/material.dart';
import 'package:perpus/widgets/students/BookRowStudent.dart';
import 'package:perpus/widgets/students/BoxStudents.dart';
import 'package:perpus/widgets/students/FilterBookStudents.dart';
import 'package:perpus/widgets/students/HeaderTopStudents.dart';

class HomeStudents extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final String nisn;
  const HomeStudents({super.key, required this.onToggleTheme,required this.nisn,});

  @override
  State<HomeStudents> createState() => _HomeStudentsState();
}

class _HomeStudentsState extends State<HomeStudents> {
  int selectedGenreIndex = 0;
  final List<String> genres = ['Semua','Agama','Sains','Novel','Jurnal','Sejarah','Pendidikan','Teknologi','Biografi','Komik','Lainnya'];

  @override
  Widget build(BuildContext context) {
    bool isSemua = selectedGenreIndex == 0;
    final selectedGenre = isSemua ? null : genres[selectedGenreIndex];
    final colorBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: colorBg,
      body: ListView(
        physics: MediaQuery.of(context).size.height < 600
            ? const NeverScrollableScrollPhysics()
            : const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          HeaderTopStudents(onToggleTheme: widget.onToggleTheme, currentNisn: widget.nisn,),
          BoxStudents(onToggleTheme: widget.onToggleTheme, ),
          const SizedBox(height: 10),
          GenreBook(
            genres: genres,
            selectedIndex: selectedGenreIndex,
            onTap: (index) {
              setState(() {
                selectedGenreIndex = index;
              });
            },
          ),
          const SizedBox(height: 25),
          BookRowStudent(
            title: 'Rekomendasi Buku',
            showTitle: isSemua,
            filterGenre: selectedGenre,
            sortByPopular: false,
          ),
          const SizedBox(height: 25),
          BookRowStudent(
            title: 'Buku paling sering dipinjam',
            showTitle: isSemua,
            filterGenre: selectedGenre,
            sortByPopular: true,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
