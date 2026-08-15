import 'package:flutter/material.dart';

class StandingsTable extends StatelessWidget {
  const StandingsTable({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
  });

  final String title;
  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              const Color(0xFF1C1C1E),
            ),
            dataRowColor: WidgetStateProperty.all(const Color(0xFF141414)),
            columns: columns
                .map(
                  (col) => DataColumn(
                    label: Text(
                      col,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                )
                .toList(),
            rows: rows
                .map(
                  (cells) => DataRow(
                    cells: cells
                        .map(
                          (value) => DataCell(
                            Text(
                              value,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
