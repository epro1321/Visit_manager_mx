import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/visit.dart';
import 'package:flutter_application_1/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ListScreen extends StatelessWidget {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(238, 71, 36, 1),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 0),
            Image.asset(
              'assets/images/logo.png',
              width: 250,
              height: 50,
            ),
            Spacer(), // Espacio flexible para centrar el texto
            Text(
              'Lista de Registros',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(), // Espacio flexible para centrar el texto
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () async {
              await _clearRecordsByDate(context);
            },
          ),
        ],
      ),
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      body: FutureBuilder<List<Visit>>(
        future: _dbService.getVisits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay visitas registradas'));
          } else {
            final visits = snapshot.data!;
            final groupedByDate = _groupVisitsByDate(visits);

            return ListView.builder(
              itemCount: groupedByDate.length,
              itemBuilder: (context, index) {
                final date = groupedByDate.keys.elementAt(index);
                final visitsByDate = groupedByDate[date]!;

                return ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(date)),
                      IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () async {
                          await _downloadDailyVisitsPDF(
                              context, visitsByDate, date);
                        },
                      ),
                    ],
                  ),
                  children: visitsByDate.map((visit) {
                    final formattedVisitTime =
                        DateFormat('HH:mm').format(visit.visitTime);
                    final formattedExitTime = visit.exitTime != null
                        ? DateFormat('HH:mm').format(visit.exitTime!)
                        : 'No registrado';

                    return Card(
                      child: ListTile(
                        title: Text(visit.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Empresa: ${visit.company}'),
                            Text('Motivo: ${visit.reason}'),
                            Text('Teléfono: ${visit.phone}'),
                            Text('Email: ${visit.email}'),
                            Text('Departamento: ${visit.department}'),
                            Text('Hora de Registro: $formattedVisitTime'),
                            Text('Hora de Salida: $formattedExitTime'),
                            visit.photo != null
                                ? Image.memory(
                                    visit.photo!,
                                    width: 300,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  )
                                : Text('No se tomó foto'),
                            visit.signature != null
                                ? Container(
                                    width: 200,
                                    height: 100,
                                    child: Center(
                                      child: Image.memory(
                                        visit.signature!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  )
                                : Text('No hay firma'),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          }
        },
      ),
    );
  }

  Map<DateTime, List<Visit>> _groupVisitsByDate(List<Visit> visits) {
    final Map<DateTime, List<Visit>> groupedByDate = {};
    for (var visit in visits) {
      final visitDate = DateTime(
          visit.visitTime.year, visit.visitTime.month, visit.visitTime.day);
      if (groupedByDate.containsKey(visitDate)) {
        groupedByDate[visitDate]!.add(visit);
      } else {
        groupedByDate[visitDate] = [visit];
      }
    }
    return groupedByDate;
  }

  Future<void> _downloadDailyVisitsPDF(
      BuildContext context, List<Visit> visitsByDate, DateTime date) async {
    try {
      final pdf = pw.Document();
      final formattedDate = DateFormat('dd_MM_yyyy').format(date);
      final pdfName = 'visits_$formattedDate.pdf';

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: visitsByDate.map((visit) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Nombre: ${visit.name}'),
                    pw.Text('Empresa: ${visit.company}'),
                    pw.Text('Motivo: ${visit.reason}'),
                    pw.Text('Teléfono: ${visit.phone}'),
                    pw.Text('Email: ${visit.email}'),
                    pw.Text('Departamento: ${visit.department}'),
                    pw.Text(
                        'Hora de Registro: ${DateFormat('HH:mm').format(visit.visitTime)}'),
                    pw.Text(
                        'Hora de Salida: ${visit.exitTime != null ? DateFormat('HH:mm').format(visit.exitTime!) : 'No registrado'}'),
                    visit.photo != null
                        ? pw.Image(
                            pw.MemoryImage(visit.photo!),
                            width: 300,
                            height: 200,
                            fit: pw.BoxFit.cover,
                          )
                        : pw.Text('No se tomó foto'),
                    visit.signature != null
                        ? pw.Container(
                            width: 200,
                            height: 100,
                            child: pw.Center(
                              child: pw.Image(
                                pw.MemoryImage(visit.signature!),
                                fit: pw.BoxFit.contain,
                              ),
                            ),
                          )
                        : pw.Text('No hay firma'),
                    pw.SizedBox(height: 10),
                  ],
                );
              }).toList(),
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final outputFile = File('${output.path}/$pdfName');
      await outputFile.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF descargado: $pdfName'),
          action: SnackBarAction(
            label: 'Abrir',
            onPressed: () {
              OpenFile.open(outputFile.path);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar PDF: $e'),
        ),
      );
    }
  }

  Future<void> _clearRecordsByDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      try {
        await _dbService.deleteRecordsByDate(selectedDate);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Registros del ${DateFormat('dd/MM/yyyy').format(selectedDate)} eliminados')),
        );
        // ignore: invalid_use_of_protected_member
        (context as Element).reassemble();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar registros: $e')),
        );
      }
    }
  }
}
