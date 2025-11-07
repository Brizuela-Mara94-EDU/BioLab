// src/pages/new_worksheet_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/worksheet_service.dart';

class NewWorksheetPage extends StatefulWidget {
  final String userEmail;

  const NewWorksheetPage({super.key, required this.userEmail});

  @override
  State<NewWorksheetPage> createState() => _NewWorksheetPageState();
}

class _NewWorksheetPageState extends State<NewWorksheetPage> {
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

  final List<Map<String, dynamic>> _objectsData = [];
  final List<Map<String, String>> _customFields = [];

  final Map<String, List<String>> _dataOptions = {
    'General': ['Color', 'Especie', 'Peso', 'Temperatura'],
    'Botánica': ['Color', 'Especie', 'Altura', 'Diámetro'],
    'Hongos': ['Color', 'Especie', 'Diámetro', 'Altura'],
    'Animal': ['Color', 'Especie', 'Peso', 'Altura'],
  };

  final List<String> _ecologySubItems = [
    'Población',
    'Morfología',
    'Interacciones',
    'Comportamiento',
    'Hábitat',
  ];

  final List<String> _dataTypes = [
    'Texto',
    'Número entero',
    'Número decimal',
    'Fecha',
    'Hora',
    'Verdadero/Falso',
  ];

  @override
  void dispose() {
    _objectCountController.dispose();
    super.dispose();
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
            'Cancelar planilla',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            '¿Estás seguro de que quieres cancelar? Se perderán todos los datos ingresados.',
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
                'Sí, cancelar',
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
    String selectedType = _dataTypes[0];

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
                      items: _dataTypes.map((String type) {
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

  Future<void> _saveWorksheet() async {
    setState(() => _isSaving = true);

    try {
      String? worksheetId = await _worksheetService.createWorksheet(
        userEmail: widget.userEmail,
        fieldWorkType: _selectedFieldWork!,
        animalType: _selectedAnimalType,
        selectedData: _selectedData.toList(),
        selectedEcologyItems: _selectedEcologyItems.toList(),
        customFields: _customFields,
        objectCount: _objectCount,
        objectsData: _objectsData,
      );

      if (!mounted) return;

      if (worksheetId != null) {
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
                Text('¡Planilla guardada!'),
              ],
            ),
            content: const Text(
              'Tu planilla ha sido guardada exitosamente y ya puedes verla en la sección correspondiente.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar diálogo
                  Navigator.of(context).pop(); // Volver a home
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
                    'Error al guardar la planilla. Intenta de nuevo.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => _showCancelDialog(),
        ),
        title: const Text(
          'Nueva Planilla',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(child: _buildCurrentStep()),
          _buildBottomButtons(),
        ],
      ),
    );
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
    List<String> availableData =
        _dataOptions[_selectedFieldWork ?? 'General'] ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Elige los datos que necesitas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                ...availableData.map((data) => _buildDataCheckbox(data)),
                _buildEcologyExpansion(),
                const SizedBox(height: 16),
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

  Widget _buildDataCheckbox(String data) {
    bool isSelected = _selectedData.contains(data);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedData.remove(data);
          } else {
            _selectedData.add(data);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6F8B5E).withOpacity(0.15)
              : const Color(0xFFD4C4B0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
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
  }

  Widget _buildEcologyExpansion() {
    bool isEcologySelected = _selectedData.contains('Ecología');

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (isEcologySelected) {
                _selectedData.remove('Ecología');
                _selectedEcologyItems.clear();
              } else {
                _selectedData.add('Ecología');
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isEcologySelected
                  ? const Color(0xFF6F8B5E).withOpacity(0.15)
                  : const Color(0xFFD4C4B0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ecología',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                if (isEcologySelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF6F8B5E),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (isEcologySelected)
          Container(
            margin: const EdgeInsets.only(left: 16, bottom: 8),
            child: Column(
              children: _ecologySubItems.map((item) {
                bool isSelected = _selectedEcologyItems.contains(item);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedEcologyItems.remove(item);
                      } else {
                        _selectedEcologyItems.add(item);
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6F8B5E).withOpacity(0.15)
                          : const Color(0xFFD4C4B0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF6F8B5E),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomFieldItem(Map<String, String> field, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF6F8B5E).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
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
        margin: const EdgeInsets.only(bottom: 8),
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
                      } else if (newValue != null && newValue <= 0) {
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
    if (_objectsData.isEmpty) {
      for (int i = 0; i < _objectCount; i++) {
        _objectsData.add({});
      }
    }

    List<String> allFields = _selectedData.toList();
    if (_selectedData.contains('Ecología')) {
      allFields.remove('Ecología');
      allFields.addAll(_selectedEcologyItems);
    }

    for (var customField in _customFields) {
      allFields.add(customField['name']!);
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
              children: allFields.map((field) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (value) {
                          _objectsData[_currentObjectIndex][field] = value;
                        },
                        controller: TextEditingController(
                          text: _objectsData[_currentObjectIndex][field] ?? '',
                        ),
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
                            borderSide: const BorderSide(
                              color: Color(0xFF6F8B5E),
                              width: 2,
                            ),
                          ),
                        ),
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
              onPressed: _isSaving ? null : _saveWorksheet,
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
                      'Guardar',
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
