// src/pages/camera_page.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gal/gal.dart';

// Importación condicional para la descarga en web
import 'package:universal_html/html.dart' as html;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;
  XFile? _lastImage;
  bool _showGrid = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        await _setupCamera(_selectedCameraIndex);
      }
    } catch (e) {
      debugPrint('Error al inicializar la cámara: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al inicializar la cámara: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_cameras == null || _cameras!.isEmpty) return;

    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();

      // Intentar configurar el flash solo si está disponible
      try {
        await _controller!.setFlashMode(_flashMode);
      } catch (e) {
        debugPrint('Flash no soportado: $e');
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error al configurar la cámara: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al configurar la cámara: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _isInitialized = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    });

    await _setupCamera(_selectedCameraIndex);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    FlashMode newFlashMode;
    switch (_flashMode) {
      case FlashMode.off:
        newFlashMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newFlashMode = FlashMode.always;
        break;
      case FlashMode.always:
        newFlashMode = FlashMode.off;
        break;
      default:
        newFlashMode = FlashMode.off;
    }

    try {
      await _controller!.setFlashMode(newFlashMode);
      setState(() {
        _flashMode = newFlashMode;
      });
    } catch (e) {
      debugPrint('No se puede cambiar el modo flash: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flash no disponible en esta cámara'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile image = await _controller!.takePicture();

      setState(() {
        _lastImage = image;
        _isProcessing = false;
      });

      // Mostrar preview de la imagen capturada
      _showImagePreview(image);
    } catch (e) {
      debugPrint('Error al tomar la foto: $e');
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al tomar la foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePreview(XFile image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        // Usar MediaQuery para un tamaño responsive del diálogo
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            mainAxisSize:
                MainAxisSize.max, // Se asegura de que Column ocupe el Container
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Foto capturada',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  child: kIsWeb
                      ? Image.network(image.path, fit: BoxFit.contain)
                      : Image.file(File(image.path), fit: BoxFit.contain),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retomar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Espera a que la función de guardado/descarga termine
                        await _saveAndProcess(image);
                        if (mounted) {
                          // Cierra el diálogo *después* de que se haya intentado guardar
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F8B5E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Método para manejar la descarga en Web
  // ------------------------------------------------------------------
  Future<void> _webDownload(XFile image) async {
    final bytes = await image.readAsBytes();
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute(
        'download',
        'MiApp_Foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
      )
      ..click();

    html.Url.revokeObjectUrl(url); // Liberar la URL temporal
  }

  Future<void> _saveAndProcess(XFile image) async {
    if (!mounted) return;

    // Mostrar indicador de carga
    final loadingSnackBar = SnackBar(
      content: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            kIsWeb ? 'Descargando foto...' : 'Guardando foto...',
          ), // Mensaje adaptado
        ],
      ),
      backgroundColor: const Color(0xFF6F8B5E),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 10),
    );
    ScaffoldMessenger.of(context).showSnackBar(loadingSnackBar);

    try {
      if (kIsWeb) {
        // SOLUCIÓN WEB: Forzar la descarga del archivo
        await _webDownload(image);

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Foto descargada exitosamente.'),
              backgroundColor: Color(0xFF6F8B5E),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Lógica para móvil/desktop (guardar en galería)
        try {
          await Gal.putImageBytes(await image.readAsBytes(), album: 'BioLab');

          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).hideCurrentSnackBar(); // Ocultar el de carga

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(child: Text('✓ Foto guardada en la galería')),
                  ],
                ),
                backgroundColor: Color(0xFF6F8B5E),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            throw Exception('No se pudo guardar la imagen: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error al guardar/descargar la imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).hideCurrentSnackBar(); // Asegurar que se oculte el de carga
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '❌ Error: ${kIsWeb ? 'Descarga fallida' : 'Guardado fallido'}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.grid_on, color: Color(0xFF6F8B5E)),
              title: const Text('Mostrar cuadrícula'),
              trailing: Switch(
                value: _showGrid,
                onChanged: (value) {
                  setState(() {
                    _showGrid = value;
                  });
                },
                activeColor: const Color(0xFF6F8B5E),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.folder_open, color: Color(0xFF6F8B5E)),
              title: const Text('Guardar en trabajo anterior creado'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función no implementada'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF6F8B5E)),
              title: const Text('Guardar en trabajo reciente'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función no implementada'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF6F8B5E),
              ),
              title: const Text('Guardar en trabajo próximo a crear'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función no implementada'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFlashIconData() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6F8B5E)),
        ),
      );
    }

    // Detectar si es pantalla grande (computadora) o pequeña (celular)
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vista previa de la cámara
          Center(
            child: isLargeScreen
                ? // Computadora: usar AspectRatio directo sin zoom
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  )
                : // Celular: vertical ocupando altura
                  FittedBox(
                    fit: BoxFit.fitHeight,
                    child: SizedBox(
                      width: _controller!.value.previewSize!.height,
                      height: _controller!.value.previewSize!.width,
                      child: CameraPreview(_controller!),
                    ),
                  ),
          ),

          // Cuadrícula superpuesta
          if (_showGrid)
            Positioned.fill(
              child: CustomPaint(size: Size.infinite, painter: GridPainter()),
            ),

          // Barra superior con controles
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón de volver
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  // Botón de flash
                  IconButton(
                    onPressed: _toggleFlash,
                    icon: Icon(
                      _getFlashIconData(),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  // Botón de configuración
                  IconButton(
                    onPressed: _showOptionsMenu,
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Controles inferiores
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Última foto tomada (miniatura)
                  GestureDetector(
                    onTap: () {
                      if (_lastImage != null) {
                        _showImagePreview(_lastImage!);
                      }
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _lastImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: kIsWeb
                                  ? Image.network(
                                      _lastImage!.path,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_lastImage!.path),
                                      fit: BoxFit.cover,
                                    ),
                            )
                          : const Icon(
                              Icons.image,
                              color: Colors.white54,
                              size: 30,
                            ),
                    ),
                  ),

                  // Botón de captura
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isProcessing ? Colors.grey : Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Botón de cambiar cámara
                  IconButton(
                    onPressed: _cameras != null && _cameras!.length > 1
                        ? _toggleCamera
                        : null,
                    icon: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter personalizado para dibujar la cuadrícula
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Dividir en 3x3 (regla de los tercios)
    final double columnWidth = size.width / 3;
    final double rowHeight = size.height / 3;

    // Líneas verticales
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(columnWidth * i, 0),
        Offset(columnWidth * i, size.height),
        paint,
      );
    }

    // Líneas horizontales
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(0, rowHeight * i),
        Offset(size.width, rowHeight * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
