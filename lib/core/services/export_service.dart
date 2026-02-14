import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../features/transaction/domain/models/transaction_model.dart';

class ExportService {
  Future<void> exportToCSV(
    List<TransactionModel> transactions,
    String currencySymbol,
  ) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Date',
      'Time of Day',
      'Type',
      'Category',
      'Amount ($currencySymbol)',
      'Note',
      'Emotion',
    ]);

    // Data
    for (var t in transactions) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(t.date),
        t.timeOfDay ?? '',
        t.isIncome ? 'Income' : 'Expense',
        t.category,
        t.amount.toStringAsFixed(2),
        t.note ?? '',
        t.emotion ?? '',
      ]);
    }

    String csvContent = const ListToCsvConverter().convert(rows);
    await _saveAndShareFile(csvContent, 'mindspend_export.csv', isPdf: false);
  }

  Future<void> exportToPDF(
    List<TransactionModel> transactions,
    String currencySymbol,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'MindSpend Transaction History',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              headers: ['Date', 'Type', 'Category', 'Amount', 'Note'],
              data: transactions
                  .map(
                    (t) => [
                      DateFormat('yyyy-MM-dd').format(t.date),
                      t.isIncome ? 'Inc' : 'Exp',
                      t.category,
                      '$currencySymbol${t.amount.toStringAsFixed(2)}',
                      t.note ?? '',
                    ],
                  )
                  .toList(),
              border: pw.TableBorder.all(color: PdfColors.grey),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey700,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await _saveAndShareFile(bytes, 'mindspend_export.pdf', isPdf: true);
  }

  Future<void> _saveAndShareFile(
    dynamic content,
    String fileName, {
    required bool isPdf,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');

    if (isPdf) {
      await file.writeAsBytes(content as List<int>);
    } else {
      await file.writeAsString(content as String);
    }

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Here is your MindSpend data export.');
  }
}
