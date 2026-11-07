import 'package:flutter/material.dart';

class TabelMurid extends StatelessWidget {
  final List<Map<String, String>> students;
  final ValueChanged<Map<String, String>> onEdit;
  final ValueChanged<Map<String, String>> onDelete;

  const TabelMurid({
    super.key,
    required this.students,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Seluruh Murid',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${students.length} murid ditemukan',
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          if (students.isEmpty)
            Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 45,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Data murid tidak ditemukan',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(
                        colors.surfaceContainerHighest,
                      ),
                      dataRowColor: WidgetStatePropertyAll(colors.surface),
                      dividerThickness: 0.7,
                      columnSpacing: 26,
                      horizontalMargin: 16,
                      columns: const [
                        DataColumn(label: Text('No.')),
                        DataColumn(label: Text('Nama Murid')),
                        DataColumn(label: Text('NISN')),
                        DataColumn(label: Text('Kelas')),
                        DataColumn(label: Text('Jenis Kelamin')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: List.generate(students.length, (index) {
                        final student = students[index];
                        final nama = student['nama'] ?? '';
                        final initial =
                            nama.trim().isEmpty ? '?' : nama.trim()[0].toUpperCase();

                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        colors.primary.withValues(alpha: 0.12),
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(nama),
                                ],
                              ),
                            ),
                            DataCell(Text(student['nisn'] ?? '-')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Kelas ${student['kelas'] ?? '-'}',
                                  style: TextStyle(
                                    color: colors.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(student['gender'] ?? '-')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit murid',
                                    onPressed: () => onEdit(student),
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: colors.primary,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Hapus murid',
                                    onPressed: () => onDelete(student),
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: colors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
