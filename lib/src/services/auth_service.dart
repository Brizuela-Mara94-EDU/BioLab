// src/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Hashea la contraseña usando SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifica si el usuario existe en la base de datos
  /// Retorna un Map con los datos del usuario si existe, null si no
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      print('🔍 Buscando usuario con email: ${email.trim().toLowerCase()}');

      // Hashear la contraseña ingresada
      final hashedPassword = _hashPassword(password);

      // Consultar la colección 'BioLab' filtrando por email
      QuerySnapshot querySnapshot = await _db
          .collection('BioLab')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      print('📊 Documentos encontrados: ${querySnapshot.docs.length}');

      // Si no se encuentra ningún usuario
      if (querySnapshot.docs.isEmpty) {
        print('❌ No se encontró ningún usuario con ese email');
        return null;
      }

      // Obtener el documento del usuario
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      print('👤 Usuario encontrado: ${userData['email']}');
      print('🔑 Password hasheado: ${hashedPassword.substring(0, 10)}...');

      // Verificar la contraseña hasheada
      if (userData['password'].toString() == hashedPassword) {
        print('✅ Login exitoso');
        // Retornar datos del usuario sin la contraseña
        return {
          'uid': userDoc.id,
          'email': userData['email'],
          'nombre': userData['nombre'] ?? '',
          'fechaCreacion': userData['fechaCreacion'],
          // Agrega otros campos que necesites
        };
      }

      // Contraseña incorrecta
      print('❌ Contraseña incorrecta');
      return null;
    } catch (e) {
      print('💥 Error en login: $e');
      return null;
    }
  }

  /// Registrar un nuevo usuario
  Future<bool> registerUser({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      print('📝 Iniciando registro para: $email');

      // Verificar si el email ya existe
      QuerySnapshot existingUser = await _db
          .collection('BioLab')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        print('⚠️ El email ya está registrado');
        return false; // El usuario ya existe
      }

      // Hashear la contraseña antes de guardarla
      final hashedPassword = _hashPassword(password);

      // Crear nuevo usuario
      await _db.collection('BioLab').add({
        'nombre': nombre.trim(),
        'email': email.trim().toLowerCase(),
        'password': hashedPassword,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      print('✅ Usuario registrado exitosamente');
      return true;
    } catch (e) {
      print('💥 Error en registro: $e');
      return false;
    }
  }

  /// Verificar si un email ya está registrado
  Future<bool> emailExists(String email) async {
    try {
      QuerySnapshot query = await _db
          .collection('BioLab')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error verificando email: $e');
      return false;
    }
  }

  /// Actualizar contraseña (para la funcionalidad de "Olvidé mi contraseña")
  Future<bool> updatePassword(String email, String newPassword) async {
    try {
      print('🔄 Actualizando contraseña para: $email');

      // Buscar el usuario
      QuerySnapshot querySnapshot = await _db
          .collection('BioLab')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ Usuario no encontrado');
        return false;
      }

      // Hashear la nueva contraseña
      final hashedPassword = _hashPassword(newPassword);

      // Actualizar la contraseña
      await querySnapshot.docs.first.reference.update({
        'password': hashedPassword,
        'passwordUpdatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Contraseña actualizada exitosamente');
      return true;
    } catch (e) {
      print('💥 Error actualizando contraseña: $e');
      return false;
    }
  }
}
