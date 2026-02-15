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

    // Load a font that supports currency symbols (like Open Sans or Noto Sans)
    // We use a system font available in this environment as a reliable source.
    pw.Font regularFont;
    pw.Font boldFont;

    try {
      final fontData = await File(
        '/usr/share/fonts/truetype/open-sans/OpenSans-Regular.ttf',
      ).readAsBytes();
      regularFont = pw.Font.ttf(fontData.buffer.asByteData());

      final boldData = await File(
        '/usr/share/fonts/truetype/open-sans/OpenSans-Bold.ttf',
      ).readAsBytes();
      boldFont = pw.Font.ttf(boldData.buffer.asByteData());
    } catch (e) {
      // Fallback to standard fonts if system fonts aren't available
      regularFont = pw.Font.helvetica();
      boldFont = pw.Font.helveticaBold();
    }

    // App Colors (using hex for PDF compatibility)
    final primaryOrange = PdfColor.fromInt(0xFFF97316);
    final primaryBlue = PdfColor.fromInt(0xFF1E40AF);
    final bgSecondary = PdfColor.fromInt(0xFFF9FAFB);
    final textSecondary = PdfColor.fromInt(0xFF6B7280);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        build: (pw.Context context) {
          return [
            // Header Bar
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              decoration: pw.BoxDecoration(
                color: primaryOrange,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'MindSpend',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Transaction History',
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary Info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Generated on: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                      style: pw.TextStyle(fontSize: 10, color: textSecondary),
                    ),
                    pw.Text(
                      'Total Transactions: ${transactions.length}',
                      style: pw.TextStyle(fontSize: 10, color: textSecondary),
                    ),
                  ],
                ),
                pw.Text(
                  'Currency: $currencySymbol',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Table
            pw.Table(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(
                  color: PdfColors.grey200,
                  width: 0.5,
                ),
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
              ),
              columnWidths: {
                0: const pw.FixedColumnWidth(80),
                1: const pw.FixedColumnWidth(50),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FixedColumnWidth(80),
                4: const pw.FlexColumnWidth(3),
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: primaryBlue),
                  children: [
                    _buildHeaderCell('Date'),
                    _buildHeaderCell('Type'),
                    _buildHeaderCell('Category'),
                    _buildHeaderCell('Amount', isRight: true),
                    _buildHeaderCell('Note'),
                  ],
                ),
                // Data Rows
                ...transactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final t = entry.value;
                  final isEven = index % 2 == 0;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: isEven ? PdfColors.white : bgSecondary,
                    ),
                    children: [
                      _buildDataCell(DateFormat('MMM dd, yyyy').format(t.date)),
                      _buildDataCell(
                        t.isIncome ? 'Income' : 'Expense',
                        color: t.isIncome ? PdfColors.green : PdfColors.red,
                      ),
                      _buildDataCell(t.category),
                      _buildDataCell(
                        '${t.isIncome ? '+' : '-'}$currencySymbol${t.amount.toStringAsFixed(2)}',
                        isRight: true,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      _buildDataCell(t.note ?? '-', isItalic: t.note == null),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 40),

            // Footer
            pw.Divider(color: PdfColors.grey300),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Stay Mindful of Your Spending ✨',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                    color: textSecondary,
                  ),
                ),
                pw.Text(
                  '© ${DateTime.now().year} MindSpend App',
                  style: pw.TextStyle(fontSize: 10, color: textSecondary),
                ),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await _saveAndShareFile(bytes, 'mindspend_export.pdf', isPdf: true);
  }

  pw.Widget _buildHeaderCell(String text, {bool isRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: isRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  pw.Widget _buildDataCell(
    String text, {
    bool isRight = false,
    PdfColor? color,
    pw.FontWeight? fontWeight,
    bool isItalic = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: isRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: fontWeight,
          fontStyle: isItalic ? pw.FontStyle.italic : pw.FontStyle.normal,
        ),
      ),
    );
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
