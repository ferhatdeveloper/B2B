import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../utils/web_download.dart';

/// Cari Ekstre — mirrors the reference portal's account-statement screen:
/// three summary cards (Toplam Alacak / Toplam Borç / Bakiye), Excel + PDF
/// export, a search box, and a Tarih / Fiş No / İşlem / Açıklama / Borç /
/// Alacak / Bakiye table.
class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  late Future<List<StatementRow>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _future = app.service.statement(app.user?.customerId ?? '');
  }

  List<StatementRow> _filter(List<StatementRow> rows) {
    if (_query.trim().isEmpty) return rows;
    final q = _query.toLowerCase();
    return rows
        .where((r) =>
            r.docNo.toLowerCase().contains(q) ||
            r.docType.toLowerCase().contains(q) ||
            (r.description ?? '').toLowerCase().contains(q))
        .toList();
  }

  void _exportCsv(List<StatementRow> rows) {
    final csv = toCsv(
      ['Tarih', 'Fiş No', 'İşlem', 'Açıklama', 'Borç', 'Alacak', 'Bakiye'],
      rows
          .map((r) => [
                shortDate(r.txnDate),
                r.docNo,
                r.docType,
                r.description ?? '',
                r.debit.toStringAsFixed(2),
                r.credit.toStringAsFixed(2),
                r.runningBalance.toStringAsFixed(2),
              ])
          .toList(),
    );
    downloadTextFile('cari-ekstre.csv', csv);
  }

  Future<void> _exportPdf(List<StatementRow> rows, double credit, double debit, double balance) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(level: 0, child: pw.Text('Cari Ekstre', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Toplam Alacak: ${credit.toStringAsFixed(2)}'),
              pw.Text('Toplam Borç: ${debit.toStringAsFixed(2)}'),
              pw.Text('Bakiye: ${balance.toStringAsFixed(2)}'),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: ['Tarih', 'Fiş No', 'İşlem', 'Açıklama', 'Borç', 'Alacak', 'Bakiye'],
            data: rows
                .map((r) => [
                      shortDate(r.txnDate),
                      r.docNo,
                      r.docType,
                      r.description ?? '',
                      r.debit.toStringAsFixed(2),
                      r.credit.toStringAsFixed(2),
                      r.runningBalance.toStringAsFixed(2),
                    ])
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
    await Printing.sharePdf(bytes: await doc.save(), filename: 'cari-ekstre.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StatementRow>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return Center(child: Text('${snap.error}'));
        final all = snap.data ?? [];
        final credit = all.fold(0.0, (s, r) => s + r.credit);
        final debit = all.fold(0.0, (s, r) => s + r.debit);
        final balance = debit - credit;
        final rows = _filter(all);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SummaryCards(credit: credit, debit: debit, balance: balance),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: all.isEmpty ? null : () => _exportCsv(rows),
                          icon: const Icon(Icons.table_view, size: 18, color: AppColors.accent),
                          label: const Text('Excel Export'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: all.isEmpty ? null : () => _exportPdf(rows, credit, debit, balance),
                          icon: const Icon(Icons.picture_as_pdf, size: 18, color: AppColors.danger),
                          label: const Text('PDF Export'),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 220,
                          child: TextField(
                            decoration: const InputDecoration(hintText: 'Ara…', prefixIcon: Icon(Icons.search), isDense: true),
                            onChanged: (v) => setState(() => _query = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (rows.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(28),
                        child: Text('Cari hareket bulunamadı.', style: TextStyle(color: AppColors.textMuted)),
                      )
                    else
                      _StatementTable(rows: rows),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.credit, required this.debit, required this.balance});
  final double credit;
  final double debit;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 760;
    final cards = [
      _summary('Toplam Alacak', credit, const [Color(0xFF10B981), Color(0xFF059669)], Icons.south_west),
      _summary('Toplam Borç', debit, const [Color(0xFFEF4444), Color(0xFFDC2626)], Icons.north_east),
      _summary('Bakiye', balance, const [AppColors.brand, AppColors.brandAlt], Icons.account_balance_wallet),
    ];
    if (wide) {
      return Row(children: [for (final c in cards) Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: c))]);
    }
    return Column(children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: 10), child: c)]);
  }

  Widget _summary(String label, double value, List<Color> colors, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: colors[0].withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(money(value), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Icon(icon, color: Colors.white54, size: 30),
        ],
      ),
    );
  }
}

class _StatementTable extends StatelessWidget {
  const _StatementTable({required this.rows});
  final List<StatementRow> rows;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 320),
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(const Color(0xFFF1F5F9)),
          columnSpacing: 28,
          columns: const [
            DataColumn(label: Text('Tarih')),
            DataColumn(label: Text('Fiş No')),
            DataColumn(label: Text('İşlem')),
            DataColumn(label: Text('Açıklama')),
            DataColumn(label: Text('Borç'), numeric: true),
            DataColumn(label: Text('Alacak'), numeric: true),
            DataColumn(label: Text('Bakiye'), numeric: true),
          ],
          rows: rows
              .map((r) => DataRow(cells: [
                    DataCell(Text(shortDate(r.txnDate))),
                    DataCell(Text(r.docNo)),
                    DataCell(Text(r.docType)),
                    DataCell(Text(r.description ?? '-')),
                    DataCell(Text(r.debit == 0 ? '-' : money(r.debit), style: const TextStyle(color: AppColors.danger))),
                    DataCell(Text(r.credit == 0 ? '-' : money(r.credit), style: const TextStyle(color: AppColors.accent))),
                    DataCell(Text(money(r.runningBalance), style: const TextStyle(fontWeight: FontWeight.w700))),
                  ]))
              .toList(),
        ),
      ),
    );
  }
}
