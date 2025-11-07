// src/pages/admin_migration_page.dart
// Página de administración para ejecutar la migración de contraseñas
// SOLO PARA USO DEL ADMINISTRADOR - REMOVER EN PRODUCCIÓN

import 'package:flutter/material.dart';
import '../utils/password_migration_script.dart';

class AdminMigrationPage extends StatefulWidget {
  const AdminMigrationPage({super.key});

  @override
  State<AdminMigrationPage> createState() => _AdminMigrationPageState();
}

class _AdminMigrationPageState extends State<AdminMigrationPage> {
  final _migration = PasswordMigrationScript();
  final _emailController = TextEditingController();
  bool _isProcessing = false;
  String _output = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _addOutput(String text) {
    setState(() {
      _output += '$text\n';
    });
  }

  void _clearOutput() {
    setState(() {
      _output = '';
    });
  }

  Future<void> _checkStatus() async {
    _clearOutput();
    setState(() => _isProcessing = true);

    _addOutput('🔍 Verificando estado de contraseñas...\n');

    // Capturar la salida del print
    try {
      await _migration.checkMigrationStatus();
      _addOutput('\n✅ Verificación completada');
    } catch (e) {
      _addOutput('❌ Error: $e');
    }

    setState(() => _isProcessing = false);
  }

  Future<void> _migrateAll() async {
    // Mostrar confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Confirmación'),
        content: const Text(
          '¿Estás seguro de que quieres migrar TODAS las contraseñas?\n\n'
          'Esta acción:\n'
          '• Hasheará todas las contraseñas en texto plano\n'
          '• No puede deshacerse\n'
          '• Debe ejecutarse solo UNA VEZ\n\n'
          '¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Sí, migrar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    _clearOutput();
    setState(() => _isProcessing = true);

    _addOutput('🚀 Iniciando migración de contraseñas...\n');

    try {
      await _migration.migrateAllPasswords();
      _addOutput('\n✅ Migración completada');
    } catch (e) {
      _addOutput('❌ Error: $e');
    }

    setState(() => _isProcessing = false);
  }

  Future<void> _migrateSingle() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un email')));
      return;
    }

    _clearOutput();
    setState(() => _isProcessing = true);

    _addOutput('🔍 Migrando usuario: $email\n');

    try {
      final success = await _migration.migrateSingleUser(email);
      if (success) {
        _addOutput('✅ Usuario migrado exitosamente');
      } else {
        _addOutput('❌ No se pudo migrar el usuario');
      }
    } catch (e) {
      _addOutput('❌ Error: $e');
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migración de Contraseñas'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Advertencia
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'PÁGINA DE ADMINISTRACIÓN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Primero verifica el estado\n'
                    '• Haz backup antes de migrar\n'
                    '• Esta acción es irreversible\n'
                    '• Ejecuta solo UNA VEZ',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botones principales
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _checkStatus,
              icon: const Icon(Icons.analytics),
              label: const Text('Verificar Estado'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _migrateAll,
              icon: const Icon(Icons.sync),
              label: const Text('Migrar TODAS las Contraseñas'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            // Migración individual
            const Text(
              'Migración individual:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'email@ejemplo.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    enabled: !_isProcessing,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _migrateSingle,
                  child: const Text('Migrar'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Salida/Log
            const Text(
              'Salida:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output.isEmpty ? 'Sin salida...' : _output,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

            if (_isProcessing) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
