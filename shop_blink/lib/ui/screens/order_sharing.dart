// order_sharing.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:shop_blink/models/order.dart';

class OrderSharing {
  static final _currencyFormatter = NumberFormat('R\$ #,##0.00', 'pt_BR');
  static final _dateFormatter = DateFormat('dd/MM/yyyy');

  // Gerar e compartilhar como PDF
  static Future<void> shareAsPdf(Order order) async {
    try {
      final pdf = pw.Document();
      // Carregar e converter a logo
      final ByteData logoData = await rootBundle.load(
        'assets/images/blink_logo.jpg',
      );
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      final logoImage = pw.MemoryImage(logoBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Image(
                          logoImage,
                          width: 200,
                        ), // Ajuste o width conforme necessário
                      ],
                    ),
                    pw.SizedBox(height: 20),

                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Pedido #${order.codigo}',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Data: ${_dateFormatter.format(order.dataCom)}',
                        ),
                        pw.Text('Vendedor: ${order.salesman}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Total: ${_currencyFormatter.format(order.amount)}',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Qtd: ${order.quantidade} ${order.quantidade > 1 ? "peças" : "peça"}',
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Tabela de Itens
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.black,
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4), // Produto
                    1: const pw.FlexColumnWidth(1), // Tamanho
                    2: const pw.FlexColumnWidth(1), // Quantidade
                    3: const pw.FlexColumnWidth(2), // Preço
                  },
                  children: [
                    // Cabeçalho da tabela
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Produto',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Tam',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Qtd',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Preço',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    // Linhas de dados
                    ...order.items.map(
                      (item) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.nomeproduto),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.tamanho ?? '-'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.quantidade.toString()),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              _currencyFormatter.format(item.price),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Totalizador
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Total do Pedido: ${_currencyFormatter.format(order.amount)}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/pedido_${order.codigo}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Pedido #${order.codigo}');
    } catch (e) {
      rethrow;
    }
  }

  // Compartilhar como texto
  static Future<void> shareAsText(Order order) async {
    try {
      final StringBuffer buffer = StringBuffer();

      // Cabeçalho
      buffer.writeln('PEDIDO #${order.codigo}');
      buffer.writeln('Data: ${_dateFormatter.format(order.dataCom)}');
      buffer.writeln('Vendedor: ${order.salesman}');
      buffer.writeln('\nITENS DO PEDIDO:');
      buffer.writeln('--------------------------------');

      // Lista de itens
      for (final item in order.items) {
        buffer.writeln('• ${item.nomeproduto}');
        if (item.tamanho?.isNotEmpty ?? false) {
          buffer.writeln('  Tamanho: ${item.tamanho}');
        }
        buffer.writeln('  Quantidade: ${item.quantidade}');
        buffer.writeln('  Preço: ${_currencyFormatter.format(item.price)}');
        buffer.writeln(
          '  Subtotal: ${_currencyFormatter.format(item.price * item.quantidade)}',
        );
        buffer.writeln('--------------------------------');
      }

      // Totalizador
      buffer.writeln('\nResumo do Pedido:');
      buffer.writeln('Total de Itens: ${order.quantidade}');
      buffer.writeln('Valor Total: ${_currencyFormatter.format(order.amount)}');

      await Share.share(buffer.toString(), subject: 'Pedido #${order.codigo}');
    } catch (e) {
      rethrow;
    }
  }
}
