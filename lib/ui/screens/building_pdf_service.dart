import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuildingPdfService {
  static final supabase = Supabase.instance.client;

  static Future<void> generateFullReport(int idEdificio) async {
    // 1. Fetch de datos (Igual a tu lógica actual)
    final edificio = await supabase.from('edificios').select('*').eq('id_edificio', idEdificio).single();
    final inspeccion = await supabase.from('inspecciones').select('*').eq('id_edificio', idEdificio).maybeSingle();

    Map<String, dynamic>? inspector;
    if (inspeccion != null) {
      inspector = await supabase.from('usuarios').select('*').eq('id_usuario', inspeccion['id_usuario']).maybeSingle();
    }

    final resultados = inspeccion == null ? [] : await supabase.from('resultados_inspeccion').select('*').eq('id_inspeccion', inspeccion['id_inspeccion']);
    final comentarios = inspeccion == null ? [] : await supabase.from('comentarios_inspeccion').select('*').eq('id_inspeccion', inspeccion['id_inspeccion']);

    // 2. Lógica del Semáforo de Riesgo
    double puntuacion = double.tryParse(inspeccion?['puntuacion_final']?.toString() ?? '0') ?? 0;
    PdfColor colorRiesgo;
    String textoRiesgo;

    if (puntuacion >= 70) {
      colorRiesgo = PdfColors.green700;
      textoRiesgo = "RIESGO BAJO / SEGURO";
    } else if (puntuacion >= 40) {
      colorRiesgo = PdfColors.orange700;
      textoRiesgo = "RIESGO MEDIO / REVISIÓN RECOMENDADA";
    } else {
      colorRiesgo = PdfColors.red700;
      textoRiesgo = "RIESGO ALTO / INSEGURO";
    }

    final pdf = pw.Document();

    // Helper para filas con estilo formal
    pw.TableRow buildRow(String label, String value, {bool isHeader = false}) {
      return pw.TableRow(
        decoration: isHeader ? const pw.BoxDecoration(color: PdfColors.grey200) : null,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.all(40),
          pageFormat: PdfPageFormat.a4,
        ),
        header: (context) => pw.Column(children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("REPORTE TÉCNICO ESTRUCTURAL", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  pw.Text("SismosApp - Sistema de Gestión de Vulnerabilidad", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
              pw.Text("ID: #${edificio['id_edificio']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
            ],
          ),
          pw.Divider(thickness: 2, color: PdfColors.blue900),
          pw.SizedBox(height: 10),
        ]),
        build: (context) => [
          // BANNER DE RIESGO (SEMÁFORO)
          if (inspeccion != null)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: pw.BoxDecoration(color: colorRiesgo, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("ESTADO DE VULNERABILIDAD:", style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                  pw.Text(textoRiesgo, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),

          pw.SizedBox(height: 20),

          // SECCIÓN: DATOS DEL EDIFICIO
          pw.Text("1. INFORMACIÓN GENERAL DEL EDIFICIO", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
          pw.SizedBox(height: 5),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: {0: const pw.FlexColumnWidth(2), 1: const pw.FlexColumnWidth(3)},
            children: [
              buildRow("Nombre de la Estructura", "${edificio['nombre_edificio']}"),
              buildRow("Dirección Completa", "${edificio['direccion']}"),
              buildRow("Uso del Suelo", "${edificio['uso_principal']}"),
              buildRow("Año de Construcción", "${edificio['anio_construccion']}"),
              buildRow("Niveles / Pisos", "${edificio['numero_pisos']}"),
              buildRow("Área Total", "${edificio['area_total_piso']} m²"),
            ],
          ),

          pw.SizedBox(height: 20),

          // SECCIÓN: RESULTADOS DE INSPECCIÓN
          pw.Text("2. RESULTADOS DE LA EVALUACIÓN", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
          pw.SizedBox(height: 5),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            children: [
              buildRow("Fecha de Ejecución", "${inspeccion?['fecha_inspeccion'] ?? 'N/A'}"),
              buildRow("Puntuación Técnica", "${inspeccion?['puntuacion_final'] ?? '0.00'} / 100"),
              buildRow("Inspector Asignado", "${inspector?['nombre'] ?? 'No asignado'}"),
            ],
          ),

          pw.SizedBox(height: 20),

          // TABLA DE CRITERIOS (DETALLE)
          if (resultados.isNotEmpty) ...[
            pw.Text("3. DETALLE DE CRITERIOS EVALUADOS", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue900),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Criterio ID", style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Valor Obtenido", style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9))),
                  ],
                ),
                ...resultados.map((r) => pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("Criterio #${r['id_criterio']}", style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("${r['valor_obtenido']}", style: const pw.TextStyle(fontSize: 9))),
                  ],
                )),
              ],
            ),
          ],

          pw.SizedBox(height: 20),

          // COMENTARIOS
          if (comentarios.isNotEmpty) ...[
            pw.Text("4. OBSERVACIONES Y RECOMENDACIONES", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 8),
            ...comentarios.map((c) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Bullet(text: "${c['comentario']}", style: const pw.TextStyle(fontSize: 10)),
            )),
          ],
        ],
        footer: (context) => pw.Column(children: [
          pw.Divider(color: PdfColors.grey400),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Documento generado automáticamente por SismosApp", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              pw.Text("Página ${context.pageNumber} de ${context.pagesCount}", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
        ]),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'Reporte_${edificio['nombre_edificio']}');
  }
}