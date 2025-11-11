// src/services/worksheet_service.dart
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'location_service.dart';

class WorksheetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();

  /// Crear un nuevo trabajo de campo (worksheet)
  Future<String?> createWorksheet({
    required String userEmail,
    required String fieldWorkType, // 'Animal', 'Botánica', 'Hongos'
    String? animalType, // 'Vertebrados', 'Invertebrados', 'Ambos'
    required List<String> selectedData,
    required List<String> selectedEcologyItems,
    required List<Map<String, String>> customFields,
    required int objectCount,
    required List<Map<String, dynamic>> objectsData,
    Map<String, dynamic>? location, // Ubicación ya obtenida (opcional)
  }) async {
    try {
      print('📝 Creando nuevo worksheet para: $userEmail');

      // Usar ubicación proporcionada o obtener una nueva
      Map<String, dynamic>? locationData = location;

      if (locationData == null) {
        print('📍 Ubicación no proporcionada, obteniendo nueva...');
        locationData = await _locationService.getCurrentLocation();
      }

      // Valores por defecto si no hay ubicación
      String locationName = 'Ubicación no disponible';
      double? latitude;
      double? longitude;

      if (locationData != null) {
        locationName = locationData['locationName'] ?? 'Ubicación desconocida';
        latitude = locationData['latitude'];
        longitude = locationData['longitude'];
        print('✅ Ubicación a guardar: $locationName');
      } else {
        print('⚠️ No se pudo obtener ubicación');
      }

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
        'location': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'deleted': false, // Campo para eliminación lógica
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

  /// Obtener todos los worksheets de un usuario (solo no eliminados)
  Future<List<Map<String, dynamic>>> getUserWorksheets(String userEmail) async {
    try {
      print('🔍 Buscando worksheets para: $userEmail');

      QuerySnapshot querySnapshot = await _db
          .collection('Worksheets')
          .where('userEmail', isEqualTo: userEmail.trim().toLowerCase())
          .orderBy('createdAt', descending: true)
          .get();

      print('📦 Total documentos encontrados: ${querySnapshot.docs.length}');

      // Filtrar en memoria los que NO están eliminados
      List<Map<String, dynamic>> worksheets = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Verificar el campo deleted
        bool isDeleted = data.containsKey('deleted')
            ? (data['deleted'] == true)
            : false;

        print(
          '📄 Doc ${doc.id}: deleted field exists: ${data.containsKey('deleted')}, isDeleted: $isDeleted',
        );

        // Solo agregar si NO está eliminado
        if (!isDeleted) {
          data['id'] = doc.id;
          worksheets.add(data);
        }
      }

      print('📊 Worksheets activos encontrados: ${worksheets.length}');
      return worksheets;
    } catch (e) {
      print('💥 Error obteniendo worksheets: $e');
      return [];
    }
  }

  /// Obtener worksheets por categoría (solo no eliminados)
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

      print(
        '📦 Total documentos encontrados en $category: ${querySnapshot.docs.length}',
      );

      // Filtrar en memoria los que NO están eliminados
      List<Map<String, dynamic>> worksheets = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Verificar el campo deleted
        bool isDeleted = data.containsKey('deleted')
            ? (data['deleted'] == true)
            : false;

        print(
          '📄 Doc ${doc.id}: deleted field exists: ${data.containsKey('deleted')}, isDeleted: $isDeleted',
        );

        // Solo agregar si NO está eliminado
        if (!isDeleted) {
          data['id'] = doc.id;
          worksheets.add(data);
        }
      }

      print(
        '📊 Worksheets activos encontrados en $category: ${worksheets.length}',
      );
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

  /// Eliminación lógica (soft delete)
  Future<bool> softDeleteWorksheet(String worksheetId) async {
    try {
      print('🗑️ Eliminando lógicamente worksheet: $worksheetId');

      // Usar set con merge para que funcione incluso si el campo no existe
      await _db.collection('Worksheets').doc(worksheetId).set({
        'deleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Worksheet marcado como eliminado');
      return true;
    } catch (e) {
      print('💥 Error en eliminación lógica: $e');
      return false;
    }
  }

  /// Restaurar worksheet eliminado
  Future<bool> restoreWorksheet(String worksheetId) async {
    try {
      print('♻️ Restaurando worksheet: $worksheetId');

      // Usar set con merge para mayor compatibilidad
      await _db.collection('Worksheets').doc(worksheetId).set({
        'deleted': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Eliminar el campo deletedAt si existe
      await _db.collection('Worksheets').doc(worksheetId).update({
        'deletedAt': FieldValue.delete(),
      });

      print('✅ Worksheet restaurado');
      return true;
    } catch (e) {
      print('💥 Error restaurando worksheet: $e');
      return false;
    }
  }

  /// Eliminar un worksheet permanentemente
  Future<bool> deleteWorksheet(String worksheetId) async {
    try {
      print('🗑️ Eliminando worksheet permanentemente: $worksheetId');

      await _db.collection('Worksheets').doc(worksheetId).delete();

      print('✅ Worksheet eliminado permanentemente');
      return true;
    } catch (e) {
      print('💥 Error eliminando worksheet: $e');
      return false;
    }
  }

  /// Obtener worksheets eliminados (papelera)
  Future<List<Map<String, dynamic>>> getDeletedWorksheets(
    String userEmail,
  ) async {
    try {
      print('🗑️ Buscando worksheets eliminados para: $userEmail');

      QuerySnapshot querySnapshot = await _db
          .collection('Worksheets')
          .where('userEmail', isEqualTo: userEmail.trim().toLowerCase())
          .where('deleted', isEqualTo: true)
          .orderBy('deletedAt', descending: true)
          .get();

      List<Map<String, dynamic>> worksheets = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print('📊 Worksheets eliminados encontrados: ${worksheets.length}');
      return worksheets;
    } catch (e) {
      print('💥 Error obteniendo worksheets eliminados: $e');
      return [];
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

  /// Crear thumbnail de la imagen
  Future<Uint8List> _createThumbnail(Uint8List imageBytes) async {
    try {
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('No se pudo decodificar la imagen');

      img.Image thumbnail = img.copyResize(image, width: 400);

      return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 70));
    } catch (e) {
      print('Error creando thumbnail: $e');
      rethrow;
    }
  }

  /// Actualizar imagen de fondo del worksheet
  Future<bool> updateWorksheetBackgroundImage({
    required String workId,
    required Uint8List imageBytes,
  }) async {
    try {
      Uint8List thumbnailBytes = await _createThumbnail(imageBytes);
      List<int> thumbnailList = thumbnailBytes.toList();

      await _db.collection('Worksheets').doc(workId).update({
        'imagenFondo': thumbnailList,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error actualizando imagen de fondo: $e');
      return false;
    }
  }

  /// Eliminar imagen de fondo
  Future<bool> removeWorksheetBackgroundImage(String workId) async {
    try {
      await _db.collection('Worksheets').doc(workId).update({
        'imagenFondo': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error eliminando imagen de fondo: $e');
      return false;
    }
  }

  /// Obtener ubicación actual (método de utilidad)
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    return await _locationService.getCurrentLocation();
  }

  /// Verificar si hay permisos de ubicación
  Future<bool> hasLocationPermission() async {
    return await _locationService.requestLocationPermission();
  }
}
