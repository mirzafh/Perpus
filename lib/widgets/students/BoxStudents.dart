import 'package:flutter/material.dart';
import 'package:perpus/main.dart';
import 'package:perpus/pages/students/BookmarkStudents.dart';
import 'package:perpus/pages/students/SearchStudents.dart';
import 'package:perpus/pages/students/ProfileStudents.dart';
import 'package:perpus/pages/students/Notif.dart';

class BoxStudents extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const BoxStudents({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Gradient warnaGradient = isDark
        ? Warna.darkGradient
        : Warna.lightGradient;
    final colorOutline = Theme.of(context).colorScheme.outline;
    final colorIcon = Theme.of(context).colorScheme.primary;
    final colorBoxSekunder = Theme.of(context).colorScheme.surfaceContainerHigh;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.025),
      margin: EdgeInsets.all(screenWidth * 0.025),
      decoration: BoxDecoration(
        gradient: warnaGradient,
        border: Border.all(color: colorOutline, width: 5.0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotifficationStudents(),
                          ),
                        );
                      },
                      child: Container(
                        height: (screenWidth * 0.13).clamp(45, 60),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorBoxSekunder,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorOutline, width: 5.0),
                        ),
                        child: Icon(
                          Icons.notifications_none_outlined,
                          color: colorIcon,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Bookmarkstudents(),
                          ),
                        );
                      },
                      child: Container(
                        height: (screenWidth * 0.13).clamp(45, 60),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorBoxSekunder,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorOutline, width: 5.0),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.menu_book_outlined,
                            color: colorIcon,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileStudents(onToggleTheme: onToggleTheme),
                      ),
                    );
                  },
                  child: Container(
                    height: (screenWidth * 0.26 + 10).clamp(100, 130),
                    decoration: BoxDecoration(
                      color: colorBoxSekunder,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorOutline, width: 5.0),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_2_outlined,
                        color: colorIcon,
                        size: (screenWidth * 0.1).clamp(40, 50),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Searchstudents()),
              );
            },
            child: Container(
              height: (screenWidth * 0.12).clamp(45, 60),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1D261F).withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 3.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                    size: (screenWidth * 0.06).clamp(20, 28),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Search buku',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: (screenWidth * 0.04).clamp(14, 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
