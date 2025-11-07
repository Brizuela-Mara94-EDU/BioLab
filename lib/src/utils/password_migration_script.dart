// src/utils/password_migration_script.dart
// Script para migrar contraseñas existentes a formato hasheado
// EJECUTAR SOLO UNA VEZ

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PasswordMigrationScript {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Hashea una contraseña usando SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifica si una contraseña ya está hasheada
  /// Las contraseñas SHA256 siempre tienen 64 caracteres hexadecimales
  bool _isAlreadyHashed(String password) {
    if (password.length != 64) return false;

    // Verificar que solo contenga caracteres hexadecimales (0-9, a-f)
    final hexPattern = RegExp(r'^[0-9a-f]{64}$');
    return hexPattern.hasMatch(password);
  }

  /// Migrar todas las contraseñas de la colección BioLab
  Future<void> migrateAllPasswords() async {
    try {
      print('🚀 Iniciando migración de contraseñas...\n');

      // Obtener todos los documentos de la colección BioLab
      final snapshot = await _db.collection('BioLab').get();

      if (snapshot.docs.isEmpty) {
        print('⚠️ No se encontraron documentos en la colección BioLab');
        return;
      }

      print('📊 Total de usuarios encontrados: ${snapshot.docs.length}\n');

      int migrated = 0;
      int alreadyHashed = 0;
      int errors = 0;

      // Procesar cada documento
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final email = data['email'] ?? 'Sin email';
          final password = data['password'];

          if (password == null || password.isEmpty) {
            print('⚠️ Usuario sin contraseña: $email');
            errors++;
            continue;
          }

          // Verificar si ya está hasheada
          if (_isAlreadyHashed(password)) {
            print('✓ Ya hasheada: $email');
            alreadyHashed++;
            continue;
          }

          // Hashear la contraseña
          final hashedPassword = _hashPassword(password);

          // Actualizar el documento
          await doc.reference.update({
            'password': hashedPassword,
            'passwordMigratedAt': FieldValue.serverTimestamp(),
          });

          print('✅ Migrada: $email');
          print(
            '   Original: ${password.substring(0, password.length > 10 ? 10 : password.length)}...',
          );
          print('   Hash: ${hashedPassword.substring(0, 20)}...\n');

          migrated++;
        } catch (e) {
          print('❌ Error procesando documento ${doc.id}: $e\n');
          errors++;
        }
      }

      // Resumen final
      print('\n' + '=' * 50);
      print('📋 RESUMEN DE MIGRACIÓN');
      print('=' * 50);
      print('Total de usuarios: ${snapshot.docs.length}');
      print('✅ Migrados exitosamente: $migrated');
      print('✓ Ya estaban hasheadas: $alreadyHashed');
      print('❌ Errores: $errors');
      print('=' * 50 + '\n');

      if (migrated > 0) {
        print('🎉 ¡Migración completada exitosamente!');
        print('⚠️ IMPORTANTE: Este script debe ejecutarse solo UNA VEZ');
      }
    } catch (e) {
      print('💥 Error crítico durante la migración: $e');
    }
  }

  /// Verificar el estado de migración sin realizar cambios
  Future<void> checkMigrationStatus() async {
    try {
      print('🔍 Verificando estado de contraseñas...\n');

      final snapshot = await _db.collection('BioLab').get();

      if (snapshot.docs.isEmpty) {
        print('⚠️ No se encontraron documentos en la colección BioLab');
        return;
      }

      int hashed = 0;
      int plainText = 0;
      int missing = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final email = data['email'] ?? 'Sin email';
        final password = data['password'];

        if (password == null || password.isEmpty) {
          print('❌ Sin contraseña: $email');
          missing++;
        } else if (_isAlreadyHashed(password)) {
          print('✅ Hasheada: $email');
          hashed++;
        } else {
          print('⚠️ Texto plano: $email (longitud: ${password.length})');
          plainText++;
        }
      }

      print('\n' + '=' * 50);
      print('📊 ESTADO DE CONTRASEÑAS');
      print('=' * 50);
      print('Total de usuarios: ${snapshot.docs.length}');
      print('✅ Contraseñas hasheadas: $hashed');
      print('⚠️ Contraseñas en texto plano: $plainText');
      print('❌ Sin contraseña: $missing');
      print('=' * 50 + '\n');

      if (plainText > 0) {
        print('⚠️ Hay contraseñas que necesitan ser migradas.');
        print('Ejecuta migrateAllPasswords() para migrarlas.');
      } else if (hashed == snapshot.docs.length) {
        print('✅ Todas las contraseñas están hasheadas correctamente.');
      }
    } catch (e) {
      print('💥 Error al verificar estado: $e');
    }
  }

  /// Migrar un usuario específico por email (útil para pruebas)
  Future<bool> migrateSingleUser(String email) async {
    try {
      print('🔍 Buscando usuario: $email');

      final query = await _db
          .collection('BioLab')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print('❌ Usuario no encontrado');
        return false;
      }

      final doc = query.docs.first;
      final data = doc.data();
      final password = data['password'];

      if (_isAlreadyHashed(password)) {
        print('✓ La contraseña ya está hasheada');
        return true;
      }

      final hashedPassword = _hashPassword(password);

      await doc.reference.update({
        'password': hashedPassword,
        'passwordMigratedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Contraseña migrada exitosamente');
      print('   Hash: ${hashedPassword.substring(0, 20)}...');
      return true;
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }
}

/* 
═══════════════════════════════════════════════════════════════════
INSTRUCCIONES DE USO:
═══════════════════════════════════════════════════════════════════

1. Agregar este archivo a tu proyecto en: src/utils/password_migration_script.dart

2. En tu archivo principal o en un botón de administración, importa:
   import 'utils/password_migration_script.dart';

3. Para verificar el estado de las contraseñas SIN hacer cambios:
   
   final migration = PasswordMigrationScript();
   await migration.checkMigrationStatus();

4. Para migrar TODAS las contraseñas:
   
   final migration = PasswordMigrationScript();
   await migration.migrateAllPasswords();

5. Para migrar un usuario específico (útil para pruebas):
   
   final migration = PasswordMigrationScript();
   await migration.migrateSingleUser('usuario@ejemplo.com');

⚠️ IMPORTANTE: 
   - Ejecuta primero checkMigrationStatus() para ver qué usuarios necesitan migración
   - Haz un backup de tu base de datos antes de ejecutar la migración
   - Este script debe ejecutarse solo UNA VEZ
   - Una vez migradas, las contraseñas hasheadas tienen 64 caracteres

═══════════════════════════════════════════════════════════════════
EJEMPLO DE IMPLEMENTACIÓN EN UN BOTÓN (para testing):
═══════════════════════════════════════════════════════════════════

// En tu página de administración o testing
ElevatedButton(
  onPressed: () async {
    final migration = PasswordMigrationScript();
    
    // Primero verificar el estado
    print('Verificando estado...');
    await migration.checkMigrationStatus();
    
    // Si hay contraseñas que migrar, preguntar confirmación
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Migrar contraseñas?'),
        content: Text('¿Estás seguro de que quieres hashear todas las contraseñas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await migration.migrateAllPasswords();
            },
            child: Text('Migrar'),
          ),
        ],
      ),
    );
  },
  child: Text('Migrar Contraseñas'),
)

═══════════════════════════════════════════════════════════════════
*/
