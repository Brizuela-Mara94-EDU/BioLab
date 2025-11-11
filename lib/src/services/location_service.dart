// src/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Verifica y solicita permisos de ubicación
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('⚠️ Servicio de ubicación deshabilitado');
      return false;
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('⚠️ Permisos de ubicación denegados');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('⚠️ Permisos de ubicación denegados permanentemente');
      return false;
    }

    print('✅ Permisos de ubicación concedidos');
    return true;
  }

  /// Obtiene la ubicación actual con nombre legible
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      // Verificar permisos primero
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      print('📍 Obteniendo posición GPS...');

      // Obtener posición actual con timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      print('✅ Posición obtenida: ${position.latitude}, ${position.longitude}');

      // Convertir coordenadas a dirección legible
      String locationName = await _getReadableLocation(
        position.latitude,
        position.longitude,
      );

      print('📍 Ubicación: $locationName');

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'locationName': locationName,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp,
      };
    } catch (e) {
      print('💥 Error obteniendo ubicación: $e');
      return null;
    }
  }

  /// Convierte coordenadas a un nombre legible priorizando lugares específicos
  Future<String> _getReadableLocation(double lat, double lon) async {
    try {
      print('🔍 Geocodificando: $lat, $lon');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        lon,
        localeIdentifier: 'es_AR', // Español de Argentina
      );

      if (placemarks.isEmpty) {
        return 'Ubicación desconocida';
      }

      Placemark place = placemarks[0];
      List<String> parts = [];

      print('📄 Placemark recibido:');
      print('  - name: ${place.name}');
      print('  - thoroughfare: ${place.thoroughfare}');
      print('  - subThoroughfare: ${place.subThoroughfare}');
      print('  - locality: ${place.locality}');
      print('  - subLocality: ${place.subLocality}');
      print('  - administrativeArea: ${place.administrativeArea}');
      print('  - subAdministrativeArea: ${place.subAdministrativeArea}');
      print('  - postalCode: ${place.postalCode}');

      // PRIORIDAD 1: Nombre específico del lugar (ej: "UNSJ", "Plaza 25 de Mayo")
      if (_isValidPart(place.name)) {
        // Evitar nombres que son solo números (direcciones)
        if (!_isOnlyNumbers(place.name!)) {
          parts.add(place.name!);
        }
      }

      // PRIORIDAD 2: Calle principal (thoroughfare)
      if (_isValidPart(place.thoroughfare) &&
          !_containsPart(parts, place.thoroughfare!)) {
        // Solo agregar si tiene número de calle
        if (_isValidPart(place.subThoroughfare)) {
          parts.add('${place.thoroughfare} ${place.subThoroughfare}');
        } else {
          parts.add(place.thoroughfare!);
        }
      }

      // PRIORIDAD 3: Barrio o sub-localidad
      if (_isValidPart(place.subLocality) &&
          !_containsPart(parts, place.subLocality!)) {
        parts.add(place.subLocality!);
      }

      // PRIORIDAD 4: Ciudad/Localidad
      if (_isValidPart(place.locality) &&
          !_containsPart(parts, place.locality!)) {
        parts.add(place.locality!);
      }

      // PRIORIDAD 5: Departamento o sub-área administrativa
      if (_isValidPart(place.subAdministrativeArea) &&
          !_containsPart(parts, place.subAdministrativeArea!) &&
          parts.length < 3) {
        parts.add(place.subAdministrativeArea!);
      }

      // PRIORIDAD 6: Provincia/Estado
      if (_isValidPart(place.administrativeArea) &&
          !_containsPart(parts, place.administrativeArea!) &&
          parts.length < 4) {
        parts.add(place.administrativeArea!);
      }

      // Si no tenemos nada útil, usar coordenadas
      if (parts.isEmpty) {
        return 'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}';
      }

      // Limitar a máximo 3 partes para que no sea muy largo
      if (parts.length > 3) {
        parts = parts.sublist(0, 3);
      }

      String result = parts.join(', ');
      print('✅ Ubicación formateada: $result');
      return result;
    } catch (e) {
      print('💥 Error en geocodificación: $e');
      return 'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}';
    }
  }

  /// Verifica si una parte es válida (no nula, no vacía)
  bool _isValidPart(String? part) {
    return part != null && part.trim().isNotEmpty && part != 'Unnamed Road';
  }

  /// Verifica si una parte ya está contenida en la lista
  bool _containsPart(List<String> parts, String part) {
    return parts.any(
      (p) =>
          p.toLowerCase().contains(part.toLowerCase()) ||
          part.toLowerCase().contains(p.toLowerCase()),
    );
  }

  /// Verifica si un string es solo números
  bool _isOnlyNumbers(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str.trim());
  }

  /// Abre la configuración de ubicación del dispositivo
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Abre la configuración de permisos de la app
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Verifica si los servicios de ubicación están habilitados
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Obtiene el estado actual de los permisos
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }
}
