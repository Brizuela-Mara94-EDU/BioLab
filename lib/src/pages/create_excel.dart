// src/pages/create_excel.dart
import 'package:flutter/material.dart';

class CreateExcelPage extends StatefulWidget {
  final String worksheetId;
  final Map<String, dynamic> worksheetData;

  const CreateExcelPage({
    super.key,
    required this.worksheetId,
    required this.worksheetData,
  });

  @override
  State<CreateExcelPage> createState() => _CreateExcelPageState();
}

class _CreateExcelPageState extends State<CreateExcelPage> {
  // Datos de ejemplo - estructura tipo Excel
  List<String> columnHeaders = ['ID', 'Nombre', 'Valor', 'Estado', 'Notas'];
  List<List<String>> rows = [
    ['1', 'Animal A', '25', 'Activo', 'Sin observaciones'],
    ['2', 'Animal B', '30', 'Activo', 'En evaluación'],
    ['3', 'Animal C', '22', 'Inactivo', 'Revisar'],
  ];

  void _addRow() {
    setState(() {
      rows.add(List.filled(columnHeaders.length, ''));
    });
  }

  void _addColumn() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Nueva Columna'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre de la columna',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    columnHeaders.add(controller.text);
                    for (var row in rows) {
                      row.add('');
                    }
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F8B5E),
              ),
              child: const Text(
                'Agregar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F8B5E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Planilla de Datos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Datos guardados correctamente'),
                    ],
                  ),
                  backgroundColor: Color(0xFF6F8B5E),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exportar a Excel - Próximamente'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addRow,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Fila'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F8B5E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addColumn,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Columna'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F8B5E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tabla estilo Excel
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Headers
                      Row(
                        children: [
                          // Columna índice
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: const Center(
                              child: Text(
                                '#',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          // Headers de columnas
                          ...columnHeaders.asMap().entries.map((entry) {
                            return Container(
                              width: 120,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6F8B5E),
                                border: Border.all(color: Colors.grey[400]!),
                              ),
                              child: Center(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      // Filas de datos
                      ...rows.asMap().entries.map((rowEntry) {
                        int rowIndex = rowEntry.key;
                        List<String> rowData = rowEntry.value;

                        return Row(
                          children: [
                            // Índice de fila
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.grey[400]!),
                              ),
                              child: Center(
                                child: Text(
                                  '${rowIndex + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            // Celdas
                            ...rowData.asMap().entries.map((cellEntry) {
                              int colIndex = cellEntry.key;
                              String cellValue = cellEntry.value;

                              return Container(
                                width: 120,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey[400]!),
                                ),
                                child: TextField(
                                  controller: TextEditingController(
                                    text: cellValue,
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 14,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      rows[rowIndex][colIndex] = value;
                                    });
                                  },
                                ),
                              );
                            }),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Aquí podrías agregar funcionalidad para análisis o gráficos
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.bar_chart, color: Color(0xFF6F8B5E)),
                  SizedBox(width: 8),
                  Text('Análisis de Datos'),
                ],
              ),
              content: const Text(
                'Funcionalidad de análisis y gráficos disponible próximamente.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        },
        backgroundColor: const Color(0xFF6F8B5E),
        icon: const Icon(Icons.analytics, color: Colors.white),
        label: const Text('Analizar', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
