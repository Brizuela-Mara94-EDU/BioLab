// src/services/worksheet_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class WorksheetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Obtener la ubicación actual del dispositivo
  Future<Map<String, dynamic>> _getCurrentLocation() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            'location': 'Ubicación no disponible',
            'latitude': null,
            'longitude': null,
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'location': 'Ubicación no disponible',
          'latitude': null,
          'longitude': null,
        };
      }

      // Obtener posición actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convertir coordenadas a dirección legible
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String location = '';

          if (place.locality != null && place.locality!.isNotEmpty) {
            location = place.locality!;
          } else if (place.subAdministrativeArea != null &&
              place.subAdministrativeArea!.isNotEmpty) {
            location = place.subAdministrativeArea!;
          } else if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty) {
            location = place.administrativeArea!;
          } else {
            location = 'Ubicación detectada';
          }

          return {
            'location': location,
            'latitude': position.latitude,
            'longitude': position.longitude,
          };
        }
      } catch (e) {
        print('Error al convertir coordenadas: $e');
      }

      return {
        'location':
            'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return {
        'location': 'Ubicación no disponible',
        'latitude': null,
        'longitude': null,
      };
    }
  }

  /// Crear un nuevo trabajo de campo (worksheet)
  Future<String?> createWorksheet({
    required String userEmail,
    required String fieldWorkType, // 'Animal', 'Botánica', 'Hongos'
    String?
    animalType, // 'Vertebrados', 'Invertebrados', 'Ambos' (solo si es Animal)
    required List<String> selectedData,
    required List<String> selectedEcologyItems,
    required List<Map<String, String>> customFields,
    required int objectCount,
    required List<Map<String, dynamic>> objectsData,
  }) async {
    try {
      print('📝 Creando nuevo worksheet para: $userEmail');

      // Obtener ubicación actual
      Map<String, dynamic> locationData = await _getCurrentLocation();

      // Obtener fecha actual en formato legible
      final now = DateTime.now();
      final dateFormat = DateFormat('d \'de\' MMMM', 'es_ES');
      final String formattedDate = dateFormat.format(now);

      // Determinar la categoría correcta para el trabajo
      String category;
      if (fieldWorkType == 'Animal' && animalType != null) {
        category = animalType; // 'Vertebrados' o 'Invertebrados'
      } else {
        category = fieldWorkType; // 'Botánica' o 'Hongos'
      }

      // Crear el documento del worksheet
      DocumentReference worksheetRef = await _db.collection('Worksheets').add({
        'userEmail': userEmail.trim().toLowerCase(),
        'fieldWorkType': fieldWorkType,
        'animalType': animalType,
        'category': category,
        'selectedData': selectedData,
        'selectedEcologyItems': selectedEcologyItems,
        'customFields': customFields,
        'objectCount': objectCount,
        'objectsData': objectsData,
        'date': formattedDate,
        'fullDate': Timestamp.fromDate(now),
        'location': locationData['location'],
        'latitude': locationData['latitude'],
        'longitude': locationData['longitude'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Worksheet creado exitosamente con ID: ${worksheetRef.id}');
      return worksheetRef.id;
    } catch (e) {
      print('💥 Error creando worksheet: $e');
      return null;
    }
  }

  /// Obtener todos los worksheets de un usuario
  Future<List<Map<String, dynamic>>> getUserWorksheets(String userEmail) async {
    try {
      print('🔍 Buscando worksheets para: $userEmail');

      QuerySnapshot querySnapshot = await _db
          .collection('Worksheets')
          .where('userEmail', isEqualTo: userEmail.trim().toLowerCase())
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> worksheets = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print('📊 Worksheets encontrados: ${worksheets.length}');
      return worksheets;
    } catch (e) {
      print('💥 Error obteniendo worksheets: $e');
      return [];
    }
  }

  /// Obtener worksheets por categoría
  Future<List<Map<String, dynamic>>> getWorksheetsByCategory(
    String userEmail,
    String category,
  ) async {
    try {
      print('🔍 Buscando worksheets de categoría: $category');

      QuerySnapshot querySnapshot = await _db
          .collection('Worksheets')
          .where('userEmail', isEqualTo: userEmail.trim().toLowerCase())
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> worksheets = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print('📊 Worksheets encontrados en $category: ${worksheets.length}');
      return worksheets;
    } catch (e) {
      print('💥 Error obteniendo worksheets por categoría: $e');
      return [];
    }
  }

  /// Actualizar un worksheet existente
  Future<bool> updateWorksheet(
    String worksheetId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      print('🔄 Actualizando worksheet: $worksheetId');

      await _db.collection('Worksheets').doc(worksheetId).update({
        ...updatedData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Worksheet actualizado exitosamente');
      return true;
    } catch (e) {
      print('💥 Error actualizando worksheet: $e');
      return false;
    }
  }

  /// Eliminar un worksheet
  Future<bool> deleteWorksheet(String worksheetId) async {
    try {
      print('🗑️ Eliminando worksheet: $worksheetId');

      await _db.collection('Worksheets').doc(worksheetId).delete();

      print('✅ Worksheet eliminado exitosamente');
      return true;
    } catch (e) {
      print('💥 Error eliminando worksheet: $e');
      return false;
    }
  }

  /// Obtener un worksheet específico por ID
  Future<Map<String, dynamic>?> getWorksheetById(String worksheetId) async {
    try {
      print('🔍 Buscando worksheet con ID: $worksheetId');

      DocumentSnapshot doc = await _db
          .collection('Worksheets')
          .doc(worksheetId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }

      return null;
    } catch (e) {
      print('💥 Error obteniendo worksheet: $e');
      return null;
    }
  }
}
