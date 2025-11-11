// src/pages/edit_worksheet_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/worksheet_service.dart';
import '../services/location_service.dart';

class EditWorksheetPage extends StatefulWidget {
  final String userEmail;
  final String worksheetId;
  final Map<String, dynamic> worksheetData;

  const EditWorksheetPage({
    super.key,
    required this.userEmail,
    required this.worksheetId,
    required this.worksheetData,
  });

  @override
  State<EditWorksheetPage> createState() => _EditWorksheetPageState();
}

class _EditWorksheetPageState extends State<EditWorksheetPage> {
  int _currentStep = 0;
  String? _selectedFieldWork;
  String? _selectedAnimalType;
  final Set<String> _selectedData = {};
  final Set<String> _selectedEcologyItems = {};
  int _objectCount = 1;
  int _currentObjectIndex = 0;
  final TextEditingController _objectCountController = TextEditingController(
    text: '1',
  );
  bool _isSaving = false;
  final WorksheetService _worksheetService = WorksheetService();
  final LocationService _locationService = LocationService();

  final List<Map<String, dynamic>> _objectsData = [];
  List<Map<String, String>> _customFields = [];

  Map<String, dynamic>? _currentLocation;
  bool _isLoadingLocation = false;
  String? _locationError;

  // Estructura completa de datos (copiada de new_worksheet_page)
  final Map<String, Map<String, List<Map<String, dynamic>>>>
  _completeDataStructure = {
    'Botánica': {
      '1. Datos de Localización y Tiempo': [
        {'field': 'Punto GPS - Latitud', 'type': 'Número decimal'},
        {'field': 'Punto GPS - Longitud', 'type': 'Número decimal'},
        {'field': 'Punto GPS - Altitud (m.s.n.m.)', 'type': 'Número decimal'},
        {'field': 'Fecha', 'type': 'Fecha'},
        {'field': 'Hora', 'type': 'Hora'},
        {'field': 'Observador/Recolector', 'type': 'Texto'},
        {'field': 'Número de Muestra/Registro', 'type': 'Texto'},
      ],
      '2. Factores Abióticos - Aire': [
        {'field': 'Temperatura del aire (°C)', 'type': 'Número decimal'},
        {'field': 'Humedad Relativa (%)', 'type': 'Número decimal'},
        {'field': 'Velocidad del Viento (m/s)', 'type': 'Número decimal'},
        {'field': 'Dirección del Viento', 'type': 'Texto'},
        {'field': 'Luz/Radiación (Lux)', 'type': 'Número decimal'},
      ],
      '2. Factores Abióticos - Suelo': [
        {'field': 'Temperatura del Suelo (°C)', 'type': 'Número decimal'},
        {'field': 'pH del Suelo', 'type': 'Número decimal'},
        {'field': 'Humedad del Suelo (%)', 'type': 'Número decimal'},
        {'field': 'Tipo de Suelo', 'type': 'Texto'},
      ],
      '2. Factores Abióticos - Condiciones': [
        {'field': 'Nubosidad', 'type': 'Texto'},
        {'field': 'Precipitación', 'type': 'Texto'},
      ],
      '3. Hábitat y Fisiografía - Topografía': [
        {'field': 'Altitud (m.s.n.m.)', 'type': 'Número decimal'},
        {'field': 'Pendiente (grados/porcentaje)', 'type': 'Número decimal'},
        {'field': 'Exposición/Orientación', 'type': 'Texto'},
      ],
      '3. Hábitat y Fisiografía - Sustrato': [
        {'field': 'Textura del Suelo', 'type': 'Texto'},
        {'field': 'Composición del Suelo', 'type': 'Texto'},
        {'field': 'Color del Suelo', 'type': 'Texto'},
      ],
      '3. Hábitat y Fisiografía - Cobertura': [
        {'field': 'Estrato Arbóreo (%)', 'type': 'Número decimal'},
        {'field': 'Estrato Arbustivo (%)', 'type': 'Número decimal'},
        {'field': 'Estrato Herbáceo (%)', 'type': 'Número decimal'},
        {'field': 'Materia Muerta (%)', 'type': 'Número decimal'},
        {'field': 'Suelo Desnudo (%)', 'type': 'Número decimal'},
        {'field': 'Estructura (Parche/Interparche)', 'type': 'Texto'},
      ],
      '4. Especie y Taxonomía': [
        {'field': 'Nombre Científico', 'type': 'Texto'},
        {'field': 'Nombre Común/Local', 'type': 'Texto'},
        {'field': 'Familia', 'type': 'Texto'},
        {'field': 'Origen (Nativa/Naturalizada/Exótica)', 'type': 'Texto'},
        {'field': 'Ejemplar Herbario N°', 'type': 'Texto'},
      ],
      '5. Población y Cuantificación': [
        {'field': 'Densidad (Ind/m²)', 'type': 'Número decimal'},
        {'field': 'Cobertura/Abundancia (%)', 'type': 'Número decimal'},
        {'field': 'Número total de Individuos', 'type': 'Número entero'},
        {'field': 'Frecuencia de aparición', 'type': 'Texto'},
      ],
      '6. Interacciones Bióticas': [
        {'field': 'Tipo de Interacción', 'type': 'Texto'},
        {'field': 'Especies Asociadas/Vecinas', 'type': 'Texto'},
        {'field': 'Especie dominante del área', 'type': 'Texto'},
      ],
      '7. Morfología - Dimensiones Generales': [
        {'field': 'Hábito de crecimiento', 'type': 'Texto'},
        {'field': 'Altura de la planta (cm/m)', 'type': 'Número decimal'},
        {'field': 'Diámetro de la cepa (cm/m)', 'type': 'Número decimal'},
        {'field': 'Diámetro del tronco - DAP (cm)', 'type': 'Número decimal'},
      ],
      '7. Morfología - Características Foliares': [
        {'field': 'Tipo de follaje', 'type': 'Texto'},
        {'field': 'Color del follaje', 'type': 'Texto'},
        {'field': 'Presencia de pilosidad', 'type': 'Verdadero/Falso'},
        {'field': 'Ubicación de pilosidad', 'type': 'Texto'},
        {'field': 'Tipo de pilosidad', 'type': 'Texto'},
        {'field': 'Color de la pilosidad', 'type': 'Texto'},
      ],
      '7. Morfología - Estructuras Defensivas': [
        {'field': 'Presencia de espinas', 'type': 'Verdadero/Falso'},
        {'field': 'Ubicación de espinas', 'type': 'Texto'},
        {'field': 'Cantidad de espinas', 'type': 'Texto'},
      ],
      '8. Fenología - Flores': [
        {'field': 'Fase reproductiva actual', 'type': 'Texto'},
        {'field': 'Color de las flores', 'type': 'Texto'},
        {'field': 'Estado de floración', 'type': 'Texto'},
      ],
      '8. Fenología - Frutos': [
        {'field': 'Tipo de fruto', 'type': 'Texto'},
        {'field': 'Color del fruto', 'type': 'Texto'},
        {'field': 'Producción de frutos', 'type': 'Texto'},
        {'field': 'N° aprox. frutos/semillas', 'type': 'Número entero'},
        {'field': 'Origen de colección (suelo/planta)', 'type': 'Texto'},
      ],
      '9. Recolección y Muestreo': [
        {'field': 'Esfuerzo de Muestra - Tiempo', 'type': 'Texto'},
        {'field': 'Esfuerzo de Muestra - Área (m²)', 'type': 'Número decimal'},
        {'field': 'Método de Muestreo', 'type': 'Texto'},
        {'field': 'N° bolsas de colección', 'type': 'Número entero'},
        {'field': 'Fotografías tomadas', 'type': 'Verdadero/Falso'},
        {'field': 'Dispositivo fotográfico', 'type': 'Texto'},
      ],
      '10. Estado y Sanidad': [
        {'field': 'Sanidad general', 'type': 'Texto'},
        {'field': 'Observaciones/Notas', 'type': 'Texto'},
      ],
      '11. Ubicación Detallada': [
        {'field': 'Provincia', 'type': 'Texto'},
        {'field': 'Departamento', 'type': 'Texto'},
        {'field': 'Localidad', 'type': 'Texto'},
        {'field': 'Hábitat de muestreo', 'type': 'Texto'},
        {'field': 'Ecorregión', 'type': 'Texto'},
        {'field': 'Referencia cercana', 'type': 'Texto'},
      ],
    },
    'Hongos': {
      '1. Datos de Localización y Tiempo': [
        {'field': 'Punto GPS - Latitud', 'type': 'Número decimal'},
        {'field': 'Punto GPS - Longitud', 'type': 'Número decimal'},
        {'field': 'Punto GPS - Altitud (m.s.n.m.)', 'type': 'Número decimal'},
        {'field': 'Fecha', 'type': 'Fecha'},
        {'field': 'Hora', 'type': 'Hora'},
        {'field': 'Observador/Recolector', 'type': 'Texto'},
        {'field': 'Número de Muestra/Registro', 'type': 'Texto'},
      ],
      '2. Factores Abióticos': [
        {'field': 'Temperatura del aire (°C)', 'type': 'Número decimal'},
        {'field': 'Humedad Relativa (%)', 'type': 'Número decimal'},
        {'field': 'Temperatura del Suelo (°C)', 'type': 'Número decimal'},
        {'field': 'pH del Suelo', 'type': 'Número decimal'},
        {'field': 'Humedad del Suelo', 'type': 'Texto'},
      ],
      '3. Hábitat': [
        {'field': 'Altitud (m.s.n.m.)', 'type': 'Número decimal'},
        {'field': 'Tipo de Sustrato', 'type': 'Texto'},
        {'field': 'Estructura del Hábitat', 'type': 'Texto'},
      ],
      '4. Especie y Taxonomía': [
        {'field': 'Nombre Científico', 'type': 'Texto'},
        {'field': 'Nombre Común', 'type': 'Texto'},
        {'field': 'Familia', 'type': 'Texto'},
      ],
      '5. Interacciones Bióticas': [
        {'field': 'Tipo de Interacción', 'type': 'Texto'},
        {'field': 'Simbionte/Hospedador', 'type': 'Texto'},
        {'field': 'Especies Asociadas', 'type': 'Texto'},
      ],
      '6. Morfología del Hongo': [
        {'field': 'Diámetro del Sombrero/Píleo (cm)', 'type': 'Número decimal'},
        {'field': 'Forma del Sombrero', 'type': 'Texto'},
        {'field': 'Textura del Sombrero', 'type': 'Texto'},
        {'field': 'Color del Sombrero', 'type': 'Texto'},
        {'field': 'Color de Láminas/Tubos', 'type': 'Texto'},
        {'field': 'Tipo de unión al estipe', 'type': 'Texto'},
        {'field': 'Largo del Estipe (cm)', 'type': 'Número decimal'},
        {'field': 'Diámetro del Estipe (cm)', 'type': 'Número decimal'},
        {'field': 'Textura del Estipe', 'type': 'Texto'},
        {'field': 'Olor', 'type': 'Texto'},
      ],
      '7. Fenología': [
        {'field': 'Estado de madurez', 'type': 'Texto'},
        {'field': 'Presencia de esporas', 'type': 'Verdadero/Falso'},
      ],
      '8. Recolección': [
        {'field': 'Método de Muestreo', 'type': 'Texto'},
        {'field': 'Esfuerzo de muestra', 'type': 'Texto'},
      ],
    },
    'Animal': {
      '1. Datos de Localización y Tiempo': [
        {'field': 'Punto GPS - Latitud', 'type': 'Número decimal'},
        {'field': 'Punto GPS - Longitud', 'type': 'Número decimal'},
        {'field': 'Punto GPS - Altitud (m.s.n.m.)', 'type': 'Número decimal'},
        {'field': 'Fecha', 'type': 'Fecha'},
        {'field': 'Hora', 'type': 'Hora'},
        {'field': 'Observador/Recolector', 'type': 'Texto'},
        {'field': 'Número de Muestra/Registro', 'type': 'Texto'},
      ],
      '2. Factores Abióticos': [
        {'field': 'Temperatura del aire (°C)', 'type': 'Número decimal'},
        {'field': 'Humedad Relativa (%)', 'type': 'Número decimal'},
        {'field': 'Condiciones climáticas', 'type': 'Texto'},
      ],
      '3. Hábitat': [
        {'field': 'Altitud (m.s.n.m.)', 'type': 'Número decimal'},
        {'field': 'Tipo de Hábitat', 'type': 'Texto'},
        {'field': 'Cobertura Vegetal', 'type': 'Texto'},
      ],
      '4. Especie y Taxonomía': [
        {'field': 'Tipo de Animal', 'type': 'Texto'},
        {'field': 'Nombre Científico', 'type': 'Texto'},
        {'field': 'Nombre Común', 'type': 'Texto'},
        {'field': 'Familia', 'type': 'Texto'},
      ],
      '5. Morfología del Animal': [
        {'field': 'Sexo', 'type': 'Texto'},
        {'field': 'Largo Hocico-Cloaca (cm)', 'type': 'Número decimal'},
        {'field': 'Peso (g/kg)', 'type': 'Número decimal'},
        {'field': 'Coloración', 'type': 'Texto'},
        {'field': 'Textura', 'type': 'Texto'},
        {'field': 'Temperatura Corporal (°C)', 'type': 'Número decimal'},
      ],
      '6. Estado y Madurez': [
        {'field': 'Fase de desarrollo', 'type': 'Texto'},
        {'field': 'Madurez Sexual', 'type': 'Texto'},
      ],
      '7. Comportamiento': [
        {'field': 'Actividad registrada', 'type': 'Texto'},
        {'field': 'Alimentación/Forrajeo', 'type': 'Texto'},
        {'field': 'Termorregulación', 'type': 'Texto'},
        {'field': 'Reproducción - Estado', 'type': 'Texto'},
        {'field': 'Número de crías/huevos', 'type': 'Número entero'},
        {'field': 'Comportamiento Social', 'type': 'Texto'},
        {'field': 'Contexto adicional', 'type': 'Texto'},
      ],
      '8. Recolección': [
        {'field': 'Método de Muestreo', 'type': 'Texto'},
        {'field': 'Tipo de Trampa', 'type': 'Texto'},
        {'field': 'Tipo de Cebo', 'type': 'Texto'},
        {'field': 'Esfuerzo de muestra - Tiempo', 'type': 'Texto'},
        {'field': 'Esfuerzo de muestra - Área (m²)', 'type': 'Número decimal'},
      ],
    },
  };
  // --- Fin de la estructura de datos ---

  @override
  void initState() {
    super.initState();
    _loadExistingData(); // Cargar datos existentes
    _getCurrentLocation(); // Obtener ubicación actual
  }

  void _loadExistingData() {
    setState(() {
      // Cargar fieldWorkType y animalType de forma segura
      _selectedFieldWork = widget.worksheetData['fieldWorkType']?.toString();
      _selectedAnimalType = widget.worksheetData['animalType']?.toString();

      _objectCount = widget.worksheetData['objectCount'] ?? 1;
      _objectCountController.text = _objectCount.toString();

      // Cargar datos seleccionados de forma segura
      if (widget.worksheetData['selectedData'] != null) {
        final dataList = widget.worksheetData['selectedData'];
        if (dataList is List) {
          _selectedData.addAll(
            dataList
                .map((item) => item.toString())
                .where((item) => item.isNotEmpty),
          );
        }
      }

      // Cargar campos personalizados de forma segura
      if (widget.worksheetData['customFields'] != null) {
        final fields = widget.worksheetData['customFields'];
        if (fields is List) {
          _customFields = fields
              .map((field) {
                if (field is Map) {
                  return {
                    'name': field['name']?.toString() ?? 'Campo sin nombre',
                    'type': field['type']?.toString() ?? 'Texto',
                  };
                }
                return null;
              })
              .whereType<Map<String, String>>()
              .toList();
        }
      }

      // Cargar datos de objetos
      if (widget.worksheetData['objectsData'] != null) {
        final objectsData = widget.worksheetData['objectsData'];
        if (objectsData is List) {
          _objectsData.addAll(List<Map<String, dynamic>>.from(objectsData));
        }
      }

      // INICIAR EN EL PASO 0 para permitir editar todo
      _currentStep = 0;
    });
  }

  @override
  void dispose() {
    _objectCountController.dispose();
    super.dispose();
  }

  // --- Todas las funciones de new_worksheet_page se copian aquí ---

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      Map<String, dynamic>? location = await _locationService
          .getCurrentLocation();

      setState(() {
        _currentLocation = location;
        _isLoadingLocation = false;
        if (location == null) {
          _locationError = 'No se pudo obtener la ubicación';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Error: ${e.toString()}';
      });
    }
  }

  void _showLocationErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Ubicación no disponible'),
          ],
        ),
        content: const Text(
          'Para registrar tu ubicación, necesitas:\n\n'
          '1. Activar el GPS de tu dispositivo\n'
          '2. Dar permisos de ubicación a la app\n\n'
          '¿Deseas abrir la configuración?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _locationService.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6F8B5E),
            ),
            child: const Text(
              'Abrir configuración',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Salir de la edición', // Título modificado
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            '¿Estás seguro de que quieres salir? Se perderán los cambios no guardados.', // Texto modificado
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Sí, salir', // Texto modificado
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddCustomFieldDialog() {
    final TextEditingController nameController = TextEditingController();
    String selectedType = 'Texto';
    final List<String> dataTypes = [
      'Texto',
      'Número entero',
      'Número decimal',
      'Fecha',
      'Hora',
      'Verdadero/Falso',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Agregar campo personalizado',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nombre del campo',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Ej: Longitud de cola',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tipo de dato',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: dataTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setDialogState(() {
                            selectedType = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      setState(() {
                        _customFields.add({
                          'name': nameController.text.trim(),
                          'type': selectedType,
                        });
                      });
                      Navigator.of(context).pop();
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
      },
    );
  }

  void _autoFillDefaultValues() {
    final now = DateTime.now();
    final dateFormatter = DateFormat('dd \'de\' MMMM \'de\' yyyy', 'es_ES');
    final currentDate = dateFormatter.format(now);
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (int i = 0; i < _objectsData.length; i++) {
      // Auto-fill Fecha
      if (_objectsData[i]['Fecha'] == null || _objectsData[i]['Fecha'] == '') {
        _objectsData[i]['Fecha'] = currentDate;
      }

      // Auto-fill Hora
      if (_objectsData[i]['Hora'] == null || _objectsData[i]['Hora'] == '') {
        _objectsData[i]['Hora'] = currentTime;
      }

      // Auto-fill GPS si tenemos ubicación
      if (_currentLocation != null) {
        // Latitud
        if (_objectsData[i]['Punto GPS - Latitud'] == null ||
            _objectsData[i]['Punto GPS - Latitud'] == '') {
          _objectsData[i]['Punto GPS - Latitud'] = _currentLocation!['latitude']
              .toString();
        }

        // Longitud
        if (_objectsData[i]['Punto GPS - Longitud'] == null ||
            _objectsData[i]['Punto GPS - Longitud'] == '') {
          _objectsData[i]['Punto GPS - Longitud'] =
              _currentLocation!['longitude'].toString();
        }

        // Altitud (si está disponible en el campo)
        if (_objectsData[i]['Punto GPS - Altitud (m.s.n.m.)'] == null ||
            _objectsData[i]['Punto GPS - Altitud (m.s.n.m.)'] == '') {
          _objectsData[i]['Punto GPS - Altitud (m.s.n.m.)'] = '0.0';
        }
      }
    }
  }

  // --- Función de guardado MODIFICADA ---
  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    try {
      // Preparar el mapa de datos para la actualización
      Map<String, dynamic> updatedData = {
        'userEmail': widget.userEmail,
        'fieldWorkType': _selectedFieldWork,
        'animalType': _selectedAnimalType,
        'selectedData': _selectedData.toList(),
        'selectedEcologyItems': _selectedEcologyItems
            .toList(), // Aunque esté vacío, lo mantenemos por consistencia
        'customFields': _customFields,
        'objectCount': _objectCount,
        'objectsData': _objectsData,
      };

      // Agregar datos de ubicación en el formato correcto (igual que en createWorksheet)
      if (_currentLocation != null) {
        updatedData['location'] =
            _currentLocation!['locationName'] ?? 'Ubicación no disponible';
        updatedData['latitude'] = _currentLocation!['latitude'];
        updatedData['longitude'] = _currentLocation!['longitude'];
      }

      // Llamar a updateWorksheet en lugar de createWorksheet
      bool success = await _worksheetService.updateWorksheet(
        widget.worksheetId,
        updatedData,
      );

      if (!mounted) return;

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF6F8B5E), size: 28),
                SizedBox(width: 8),
                Text('¡Planilla actualizada!'), // Título modificado
              ],
            ),
            content: const Text(
              'Tus cambios han sido guardados exitosamente.', // Texto modificado
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                  Navigator.of(
                    context,
                  ).pop(true); // Cierra la página de edición
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6F8B5E),
                ),
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error al actualizar la planilla. Intenta de nuevo.', // Texto modificado
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // --- Todo el ÁRBOL DE WIDGETS de new_worksheet_page se copia aquí ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => _showCancelDialog(), // Usa el mismo diálogo
        ),
        title: const Text(
          'Editar Planilla', // Título modificado
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildLocationIndicator(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          _buildLocationBanner(),
          Expanded(child: _buildCurrentStep()),
          _buildBottomButtons(), // Este ya maneja el guardado
        ],
      ),
    );
  }

  Widget _buildLocationIndicator() {
    if (_isLoadingLocation) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_currentLocation != null) {
      return IconButton(
        icon: const Icon(Icons.location_on, color: Color(0xFF6F8B5E)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ubicación: ${_currentLocation!['locationName']}'),
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );
    }

    return IconButton(
      icon: const Icon(Icons.location_off, color: Colors.red),
      onPressed: _showLocationErrorDialog,
    );
  }

  Widget _buildLocationBanner() {
    if (_isLoadingLocation) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: Colors.blue[50],
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Obteniendo ubicación...',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    if (_currentLocation != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: const Color(0xFF6F8B5E).withOpacity(0.1),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF6F8B5E), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _currentLocation!['locationName'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _getCurrentLocation,
              tooltip: 'Actualizar ubicación',
            ),
          ],
        ),
      );
    }

    if (_locationError != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: Colors.red[50],
        child: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Ubicación no disponible',
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: _getCurrentLocation,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProgressIndicator() {
    int totalSteps = 4;
    if (_selectedFieldWork == 'Animal') totalSteps = 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(totalSteps, (index) {
          bool isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF6F8B5E) : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildFieldWorkSelection();
      case 1:
        if (_selectedFieldWork == 'Animal') {
          return _buildAnimalTypeSelection();
        }
        return _buildDataSelection();
      case 2:
        return _buildDataSelection();
      case 3:
        return _buildObjectCountInput();
      case 4:
        return _buildDataEntry();
      default:
        return Container();
    }
  }

  Widget _buildFieldWorkSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿De qué es el trabajo de campo?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildOptionCard('Animal', Icons.pets),
          const SizedBox(height: 12),
          _buildOptionCard('Botánica', Icons.local_florist),
          const SizedBox(height: 12),
          _buildOptionCard('Hongos', Icons.grass),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String title, IconData icon) {
    bool isSelected = _selectedFieldWork == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFieldWork = title;
          _selectedData.clear();
          _selectedEcologyItems.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6F8B5E).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6F8B5E) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6F8B5E) : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF6F8B5E) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalTypeSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Qué tipo de animal?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildAnimalTypeCard('Vertebrados'),
          const SizedBox(height: 12),
          _buildAnimalTypeCard('Invertebrados'),
          const SizedBox(height: 12),
          _buildAnimalTypeCard('Ambos'),
        ],
      ),
    );
  }

  Widget _buildAnimalTypeCard(String type) {
    bool isSelected = _selectedAnimalType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAnimalType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6F8B5E).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6F8B5E) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Text(
          type,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? const Color(0xFF6F8B5E) : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildDataSelection() {
    if (_selectedFieldWork == null) return Container();

    Map<String, List<Map<String, dynamic>>> categories =
        _completeDataStructure[_selectedFieldWork!] ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona los campos que necesitas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Puedes agregar campos personalizados al final',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                ...categories.entries.map((entry) {
                  return _buildCategoryExpansion(entry.key, entry.value);
                }),
                const SizedBox(height: 16),
                const Divider(thickness: 2),
                const SizedBox(height: 8),
                const Text(
                  'Campos Personalizados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ..._customFields.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> field = entry.value;
                  return _buildCustomFieldItem(field, index);
                }),
                _buildAddCustomFieldButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryExpansion(
    String categoryName,
    List<Map<String, dynamic>> fields,
  ) {
    int selectedCount = fields
        .where((f) => _selectedData.contains('${categoryName}|${f['field']}'))
        .length;

    bool allSelected = selectedCount == fields.length;
    bool someSelected = selectedCount > 0 && selectedCount < fields.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedCount > 0
              ? const Color(0xFF6F8B5E)
              : Colors.grey[300]!,
          width: selectedCount > 0 ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              // Checkbox para seleccionar/deseleccionar toda la categoría
              Checkbox(
                value: allSelected,
                tristate: true,
                activeColor: const Color(0xFF6F8B5E),
                onChanged: (bool? value) {
                  setState(() {
                    if (allSelected || someSelected) {
                      // Si todos o algunos están seleccionados, deseleccionar todos
                      for (var fieldData in fields) {
                        _selectedData.remove(
                          '${categoryName}|${fieldData['field']}',
                        );
                      }
                    } else {
                      // Si ninguno está seleccionado, seleccionar todos
                      for (var fieldData in fields) {
                        _selectedData.add(
                          '${categoryName}|${fieldData['field']}',
                        );
                      }
                    }
                  });
                },
              ),
              Expanded(
                child: Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: selectedCount > 0
                        ? const Color(0xFF6F8B5E)
                        : Colors.black87,
                  ),
                ),
              ),
              if (selectedCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6F8B5E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$selectedCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          children: fields.map((fieldData) {
            String fieldKey = '${categoryName}|${fieldData['field']}';
            bool isSelected = _selectedData.contains(fieldKey);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedData.remove(fieldKey);
                  } else {
                    _selectedData.add(fieldKey);
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6F8B5E).withOpacity(0.15)
                      : const Color(0xFFD4C4B0).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fieldData['field'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fieldData['type'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF6F8B5E),
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCustomFieldItem(Map<String, String> field, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF6F8B5E).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF6F8B5E), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  field['type']!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () {
              setState(() {
                _customFields.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddCustomFieldButton() {
    return GestureDetector(
      onTap: _showAddCustomFieldDialog,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF6F8B5E),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, color: Color(0xFF6F8B5E), size: 20),
            SizedBox(width: 8),
            Text(
              'Agregar campo personalizado',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6F8B5E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectCountInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Cuántos objetos estás evaluando?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (_objectCount > 1) {
                    setState(() {
                      _objectCount--;
                      _objectCountController.text = _objectCount.toString();
                    });
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6F8B5E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
              ),
              const SizedBox(width: 24),
              Container(
                width: 120,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6F8B5E), width: 2),
                ),
                child: TextField(
                  controller: _objectCountController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6F8B5E),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      int? newValue = int.tryParse(value);
                      if (newValue != null && newValue > 0) {
                        setState(() {
                          _objectCount = newValue;
                        });
                      } else {
                        _objectCountController.text = '1';
                        setState(() {
                          _objectCount = 1;
                        });
                      }
                    } else {
                      _objectCountController.text = '1';
                      setState(() {
                        _objectCount = 1;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: () {
                  setState(() {
                    _objectCount++;
                    _objectCountController.text = _objectCount.toString();
                  });
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6F8B5E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataEntry() {
    // Asegurarse de que _objectsData tenga la longitud correcta si se cambió
    while (_objectsData.length < _objectCount) {
      _objectsData.add({});
    }
    while (_objectsData.length > _objectCount) {
      _objectsData.removeLast();
    }

    // Auto-rellenar campos vacíos de tiempo y localización
    // Esto se ejecuta tanto para planillas nuevas como editadas
    _autoFillDefaultValues();

    List<Map<String, String>> allSelectedFields = [];

    for (String selected in _selectedData) {
      List<String> parts = selected.split('|');
      if (parts.length == 2) {
        String? fieldType;
        if (_selectedFieldWork != null) {
          Map<String, List<Map<String, dynamic>>> categories =
              _completeDataStructure[_selectedFieldWork!] ?? {};
          for (var fields in categories.values) {
            for (var fieldData in fields) {
              if (fieldData['field'] == parts[1]) {
                fieldType = fieldData['type'];
                break;
              }
            }
            if (fieldType != null) break;
          }
        }

        allSelectedFields.add({
          'category': parts[0],
          'field': parts[1],
          'type': fieldType ?? 'Texto',
        });
      }
    }

    for (var customField in _customFields) {
      allSelectedFields.add({
        'category': 'Personalizado',
        'field': customField['name']!,
        'type': customField['type']!,
      });
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Objeto ${_currentObjectIndex + 1} de $_objectCount',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _currentObjectIndex > 0
                        ? () {
                            setState(() {
                              _currentObjectIndex--;
                            });
                          }
                        : null,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: _currentObjectIndex > 0
                          ? const Color(0xFF6F8B5E)
                          : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: _currentObjectIndex < _objectCount - 1
                        ? () {
                            setState(() {
                              _currentObjectIndex++;
                            });
                          }
                        : null,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: _currentObjectIndex < _objectCount - 1
                          ? const Color(0xFF6F8B5E)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: allSelectedFields.map((fieldData) {
                String fieldKey = fieldData['field']!;
                String fieldType = fieldData['type']!;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fieldData['field']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              fieldType,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildFieldInput(
                        fieldKey,
                        fieldType,
                        _objectsData[_currentObjectIndex][fieldKey] ?? '',
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldInput(String fieldKey, String fieldType, dynamic value) {
    switch (fieldType) {
      case 'Número entero':
        return TextField(
          onChanged: (val) {
            _objectsData[_currentObjectIndex][fieldKey] = val;
          },
          controller: TextEditingController(text: value.toString()),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6F8B5E), width: 2),
            ),
          ),
        );

      case 'Número decimal':
        return TextField(
          onChanged: (val) {
            _objectsData[_currentObjectIndex][fieldKey] = val;
          },
          controller: TextEditingController(text: value.toString()),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6F8B5E), width: 2),
            ),
          ),
        );

      case 'Verdadero/Falso':
        return Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Sí'),
                value: true,
                groupValue: value == 'true' || value == true,
                onChanged: (val) {
                  setState(() {
                    _objectsData[_currentObjectIndex][fieldKey] = val
                        .toString();
                  });
                },
                activeColor: const Color(0xFF6F8B5E),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('No'),
                value: false,
                groupValue: value == 'false' || value == false,
                onChanged: (val) {
                  setState(() {
                    _objectsData[_currentObjectIndex][fieldKey] = val
                        .toString();
                  });
                },
                activeColor: const Color(0xFF6F8B5E),
              ),
            ),
          ],
        );

      case 'Fecha':
        return GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: value != null && value.toString().isNotEmpty
                  ? DateTime.tryParse(value.toString()) ?? DateTime.now()
                  : DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              locale: const Locale('es', 'ES'),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF6F8B5E),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _objectsData[_currentObjectIndex][fieldKey] = DateFormat(
                  'dd \'de\' MMMM \'de\' yyyy',
                  'es_ES',
                ).format(picked);
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF6F8B5E),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null && value.toString().isNotEmpty
                        ? value.toString()
                        : 'Seleccionar fecha',
                    style: TextStyle(
                      fontSize: 14,
                      color: value != null && value.toString().isNotEmpty
                          ? Colors.black87
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case 'Hora':
        return GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: value != null && value.toString().isNotEmpty
                  ? TimeOfDay(
                      hour: int.tryParse(value.toString().split(':')[0]) ?? 0,
                      minute: int.tryParse(value.toString().split(':')[1]) ?? 0,
                    )
                  : TimeOfDay.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF6F8B5E),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _objectsData[_currentObjectIndex][fieldKey] =
                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Color(0xFF6F8B5E),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null && value.toString().isNotEmpty
                        ? value.toString()
                        : 'Seleccionar hora',
                    style: TextStyle(
                      fontSize: 14,
                      color: value != null && value.toString().isNotEmpty
                          ? Colors.black87
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      default:
        return TextField(
          onChanged: (val) {
            _objectsData[_currentObjectIndex][fieldKey] = val;
          },
          controller: TextEditingController(text: value.toString()),
          maxLines: fieldType == 'Texto' ? 3 : 1,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6F8B5E), width: 2),
            ),
          ),
        );
    }
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              child: const Text(
                'Atrás',
                style: TextStyle(color: Color(0xFF6F8B5E)),
              ),
            ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _showCancelDialog,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
          const Spacer(),
          if (_currentStep == 4)
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : _saveChanges, // Llamar a la función de guardado modificada
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F8B5E),
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Guardar', // Texto modificado
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            )
          else
            ElevatedButton(
              onPressed: _canProceed()
                  ? () {
                      setState(() {
                        _currentStep++;
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F8B5E),
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedFieldWork != null;
      case 1:
        if (_selectedFieldWork == 'Animal') {
          return _selectedAnimalType != null;
        }
        return _selectedData.isNotEmpty || _customFields.isNotEmpty;
      case 2:
        return _selectedData.isNotEmpty || _customFields.isNotEmpty;
      case 3:
        return _objectCount > 0;
      default:
        return true;
    }
  }
}
