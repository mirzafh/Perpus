import 'package:flutter/material.dart';

class GenreBook extends StatelessWidget {
  final List<String> genres;
  final int selectedIndex;
  final Function(int) onTap;

  const GenreBook({
    super.key,
    required this.genres,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: (screenWidth * 0.1).clamp(35.0, 50.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        itemBuilder: (context, index) {
          bool isActive = index == selectedIndex;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? colorScheme.primary : colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isActive ? colorScheme.primary : colorScheme.outline,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  genres[index],
                  style: TextStyle(
                    color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: (screenWidth * 0.035).clamp(12.0, 16.0),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
