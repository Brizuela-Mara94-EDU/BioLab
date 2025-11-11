// src/pages/category_detail_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../services/worksheet_service.dart';
import 'login_page.dart';
import 'camera_page.dart';
import 'new_worksheet_page.dart';
import 'edit_worksheet_page.dart';
import 'worksheet_page.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryTitle;
  final String categoryType;
  final String userEmail;

  const CategoryDetailPage({
    super.key,
    required this.categoryTitle,
    required this.categoryType,
    required this.userEmail,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final WorksheetService _worksheetService = WorksheetService();
  List<Map<String, dynamic>> _worksheets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorksheets();
  }

  Future<void> _loadWorksheets() async {
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> worksheets = await _worksheetService
          .getWorksheetsByCategory(widget.userEmail, widget.categoryTitle);

      setState(() {
        _worksheets = worksheets;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando worksheets: $e');
      setState(() => _isLoading = false);
    }
  }

  String get userName {
    final emailName = widget.userEmail.split('@')[0];
    return emailName.isNotEmpty
        ? emailName[0].toUpperCase() + emailName.substring(1).toLowerCase()
        : 'Usuario';
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF6F8B5E),
              radius: 30,
              child: Text(
                widget.userEmail.isNotEmpty
                    ? widget.userEmail[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.userEmail,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF6F8B5E)),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF6F8B5E)),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
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
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Cerrar sesión',
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
        backgroundColor: const Color(0xFFF5F1EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Te encuentras en\n${widget.categoryTitle.toLowerCase()}',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _showUserMenu,
              child: CircleAvatar(
                backgroundColor: const Color(0xFF6F8B5E),
                radius: 18,
                child: Text(
                  widget.userEmail.isNotEmpty
                      ? widget.userEmail[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6F8B5E)),
              ),
            )
          : _worksheets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay trabajos en esta categoría',
                    style: TextStyle(fontSize: 16, color: Color(0xFF616161)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Presiona el botón + para crear uno',
                    style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadWorksheets,
              color: const Color(0xFF6F8B5E),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _worksheets.length,
                itemBuilder: (context, index) {
                  final work = _worksheets[index];
                  return _buildWorkCard(work);
                },
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF6F8B5E),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NewWorksheetPage(userEmail: widget.userEmail),
              ),
            ).then((_) {
              // Recargar la lista cuando vuelve de crear una planilla
              _loadWorksheets();
            });
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          elevation: 0,
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.home, color: Colors.grey[600], size: 28),
                ),
                const SizedBox(width: 40),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CameraPage(userEmail: widget.userEmail),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.grey[600],
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkCard(Map<String, dynamic> work) {
    final String workId = work['id'] ?? '';
    final imagenFondoData = work['imagenFondo'];
    Uint8List? imagenFondoBytes;

    if (imagenFondoData != null && imagenFondoData is List) {
      imagenFondoBytes = Uint8List.fromList(List<int>.from(imagenFondoData));
    }

    final bool hasCustomImage = imagenFondoBytes != null;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorksheetPage(
              worksheetId: workId,
              worksheetData: work,
              userEmail: widget.userEmail,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              hasCustomImage
                  ? Image.memory(
                      imagenFondoBytes,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFD4C5B0), Color(0xFF9FB88A)],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFD4C5B0), Color(0xFF9FB88A)],
                        ),
                      ),
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      work['date']?.toString() ?? 'Sin fecha',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      work['location']?.toString() ?? 'Sin ubicación',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'view') {
                        _showWorksheetDetails(work);
                      } else if (value == 'edit') {
                        _navigateToEdit(work);
                      } else if (value == 'delete') {
                        _showDeleteDialog(work['id']);
                      } else if (value == 'add_images') {
                        _showNotAvailableMessage('Agregar imágenes');
                      } else if (value == 'background_image') {
                        _pickBackgroundImage(work['id']);
                      } else if (value == 'remove_background') {
                        _removeBackgroundImage(work['id']);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 20,
                              color: Color(0xFF6F8B5E),
                            ),
                            SizedBox(width: 8),
                            Text('Ver detalles'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              size: 20,
                              color: Color(0xFF6F8B5E),
                            ),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'add_images',
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 20,
                              color: Color(0xFF6F8B5E),
                            ),
                            SizedBox(width: 8),
                            Text('Agregar imágenes'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'background_image',
                        child: Row(
                          children: [
                            Icon(
                              Icons.image,
                              size: 20,
                              color: Color(0xFF6F8B5E),
                            ),
                            SizedBox(width: 8),
                            Text('Imagen de fondo'),
                          ],
                        ),
                      ),
                      if (hasCustomImage)
                        const PopupMenuItem(
                          value: 'remove_background',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 8),
                              Text('Quitar imagen de fondo'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEdit(Map<String, dynamic> work) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWorksheetPage(
          worksheetId: work['id'],
          worksheetData: work,
          userEmail: widget.userEmail,
        ),
      ),
    );

    if (result == true) {
      _loadWorksheets();
    }
  }

  void _showWorksheetDetails(Map<String, dynamic> work) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.description, color: Color(0xFF6F8B5E)),
                  const SizedBox(width: 8),
                  const Text(
                    'Detalles del trabajo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 30),
              _buildDetailRow(
                'Fecha',
                work['date']?.toString() ?? 'No disponible',
              ),
              _buildDetailRow(
                'Ubicación',
                work['location']?.toString() ?? 'No disponible',
              ),
              _buildDetailRow(
                'Tipo',
                work['fieldWorkType']?.toString() ?? 'No disponible',
              ),
              if (work['animalType'] != null)
                _buildDetailRow(
                  'Subtipo',
                  work['animalType']?.toString() ?? '',
                ),
              _buildDetailRow(
                'Objetos evaluados',
                work['objectCount']?.toString() ?? '0',
              ),
              const SizedBox(height: 20),
              if (work['selectedData'] != null &&
                  work['selectedData'] is List &&
                  (work['selectedData'] as List).isNotEmpty) ...[
                const Text(
                  'Datos recopilados:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (work['selectedData'] as List).map((data) {
                    return Chip(
                      label: Text(data?.toString() ?? ''),
                      backgroundColor: const Color(0xFF6F8B5E).withOpacity(0.1),
                      labelStyle: const TextStyle(color: Color(0xFF6F8B5E)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              if (work['customFields'] != null &&
                  work['customFields'] is List &&
                  (work['customFields'] as List).isNotEmpty) ...[
                const Text(
                  'Campos personalizados:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...(work['customFields'] as List).map((field) {
                  if (field is Map) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${field['name']?.toString() ?? 'Campo'} (${field['type']?.toString() ?? 'Texto'})',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6F8B5E),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  Future<void> _pickBackgroundImage(String workId) async {
    try {
      final ImagePicker picker = ImagePicker();
      ImageSource? source;

      if (kIsWeb) {
        source = ImageSource.gallery;
      } else {
        source = await showDialog<ImageSource>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Seleccionar imagen'),
            content: const Text('¿De dónde quieres obtener la imagen?'),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                icon: const Icon(Icons.camera_alt, color: Color(0xFF6F8B5E)),
                label: const Text('Cámara'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6F8B5E),
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                icon: const Icon(Icons.photo_library, color: Color(0xFF6F8B5E)),
                label: const Text('Galería'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6F8B5E),
                ),
              ),
            ],
          ),
        );
      }

      if (source == null) return;

      // Solicitar permisos solo en dispositivos móviles
      if (!kIsWeb) {
        bool permissionGranted = false;

        if (source == ImageSource.camera) {
          permissionGranted = await _requestPermission(Permission.camera);
          if (!permissionGranted) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Se necesita permiso de cámara'),
                action: SnackBarAction(
                  label: 'Ajustes',
                  onPressed: () => openAppSettings(),
                ),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
        } else {
          // Para galería
          if (Platform.isAndroid) {
            // Obtener la versión real de Android
            final deviceInfo = DeviceInfoPlugin();
            final androidInfo = await deviceInfo.androidInfo;

            // Android 13 (API 33) y superior usa Permission.photos
            if (androidInfo.version.sdkInt >= 33) {
              permissionGranted = await _requestPermission(Permission.photos);
            } else {
              // Android 12 y anteriores usan Permission.storage
              permissionGranted = await _requestPermission(Permission.storage);
            }
          } else if (Platform.isIOS) {
            // iOS siempre usa Permission.photos
            permissionGranted = await _requestPermission(Permission.photos);
          }

          if (!permissionGranted) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Se necesita permiso para la galería'),
                action: SnackBarAction(
                  label: 'Ajustes',
                  onPressed: () => openAppSettings(),
                ),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
        }
      }

      // Seleccionar imagen
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selección cancelada'),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }

      // Mostrar indicador de carga
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6F8B5E)),
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  'Procesando imagen...',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Por favor espera',
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );

      // Leer y procesar imagen
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      bool success = await _worksheetService.updateWorksheetBackgroundImage(
        workId: workId,
        imageBytes: imageBytes,
      );

      if (!mounted) return;
      Navigator.pop(context); // Cerrar loading

      if (success) {
        await _loadWorksheets();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Imagen de fondo actualizada'),
              ],
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF6F8B5E),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Error al actualizar la imagen'),
              ],
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;

      String errorMessage = 'Error al seleccionar imagen';

      if (e.toString().contains('camera_access_denied')) {
        errorMessage = 'Permiso de cámara denegado';
      } else if (e.toString().contains('photo_access_denied')) {
        errorMessage = 'Permiso de galería denegado';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeBackgroundImage(String workId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6F8B5E)),
        ),
      ),
    );

    bool success = await _worksheetService.removeWorksheetBackgroundImage(
      workId,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      await _loadWorksheets();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Imagen de fondo eliminada'),
            ],
          ),
          backgroundColor: Color(0xFF6F8B5E),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Error al eliminar la imagen'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showNotAvailableMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature no disponible por el momento'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteDialog(String workId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar trabajo'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este trabajo?\n\nPodrás recuperarlo más tarde desde la sección de trabajos eliminados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF6F8B5E),
                    ),
                  ),
                ),
              );

              bool success = await _worksheetService.softDeleteWorksheet(
                workId,
              );

              if (!mounted) return;
              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Trabajo eliminado correctamente'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF6F8B5E),
                  ),
                );
                _loadWorksheets();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Error al eliminar el trabajo'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
