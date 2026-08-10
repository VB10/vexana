import 'package:flutter/material.dart';
import 'package:playground/src/model/endpoint_summary.dart';
import 'package:playground/src/utility/formatters.dart';

class SummaryTable extends StatelessWidget {
  const SummaryTable({required this.summary, super.key});

  final List<EndpointSummary> summary;

  static const List<String> _columns = [
    'endpoint',
    'n',
    'p50',
    'p95',
    'max',
    'errors',
    'cache',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowHeight: 36,
        dataRowMinHeight: 34,
        dataRowMaxHeight: 34,
        columns: [
          for (final (index, label) in _columns.indexed)
            DataColumn(label: Text(label), numeric: index > 0),
        ],
        rows: [for (final row in summary) _rowOf(row)],
      ),
    );
  }

  DataRow _rowOf(EndpointSummary row) {
    return DataRow(
      cells: [
        DataCell(Text(row.endpoint)),
        DataCell(Text('${row.count}')),
        DataCell(Text(row.p50.readable)),
        DataCell(Text(row.p95.readable)),
        DataCell(Text(row.max.readable)),
        DataCell(Text('${row.errorCount}')),
        DataCell(Text('${row.cacheHitCount}')),
      ],
    );
  }
}
