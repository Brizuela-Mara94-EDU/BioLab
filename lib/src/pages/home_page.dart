import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.8);

  final List<String> _categories = ['Animal', 'Botánica', 'Hongos'];

  final List<Map<String, String>> _allCategories = [
    {
      'title': 'Vertebrados',
      'image': 'assets/images/hornero.jpg',
      'category': 'Animal',
    },
    {
      'title': 'Invertebrados',
      'image': 'assets/images/scorpion.jpg',
      'category': 'Animal',
    },
    {
      'title': 'Botánica',
      'image': 'assets/images/jarilla.jpg',
      'category': 'Botánica',
    },
    {
      'title': 'Hongos',
      'image': 'assets/images/mushroom.jpg',
      'category': 'Hongos',
    },
  ];

  void _jumpToCategory() {
    int targetIndex = 0;

    if (_selectedCategoryIndex == 0) {
      // Animal - ir a Vertebrados (índice 0)
      targetIndex = 0;
    } else if (_selectedCategoryIndex == 1) {
      // Botánica - ir a Botánica (índice 2)
      targetIndex = 2;
    } else if (_selectedCategoryIndex == 2) {
      // Hongos - ir a Hongos (índice 3)
      targetIndex = 3;
    }

    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con saludo
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bienvenida, Mara!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 20,
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Pestañas de categorías (atajos)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _categories.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final String category = entry.value;
                  final bool isSelected = _selectedCategoryIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                      _jumpToCategory();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 24),
                      padding: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: isSelected
                            ? const Border(
                                bottom: BorderSide(
                                  color: Color(0xFF6F8B5E),
                                  width: 2,
                                ),
                              )
                            : null,
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF6F8B5E)
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // PageView con todas las 4 cards
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                  bottom: 20,
                ), // Espacio antes del navbar
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _allCategories.length,
                  onPageChanged: (index) {
                    // Actualizar la pestaña activa basada en la card visible
                    setState(() {
                      if (index <= 1) {
                        // Vertebrados o Invertebrados -> Animal
                        _selectedCategoryIndex = 0;
                      } else if (index == 2) {
                        // Botánica
                        _selectedCategoryIndex = 1;
                      } else if (index == 3) {
                        // Hongos
                        _selectedCategoryIndex = 2;
                      }
                    });
                  },
                  itemBuilder: (context, index) {
                    // Ajustar margen para la primera y última card
                    EdgeInsets margin;
                    if (index == 0) {
                      // Primera card: menos espacio a la izquierda
                      margin = const EdgeInsets.only(left: 5, right: 10);
                    } else if (index == _allCategories.length - 1) {
                      // Última card: menos espacio a la derecha
                      margin = const EdgeInsets.only(left: 10, right: 5);
                    } else {
                      // Cards del medio: espacio simétrico
                      margin = const EdgeInsets.symmetric(horizontal: 10);
                    }

                    return Container(
                      margin: margin,
                      child: _buildCard(_allCategories[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation con FAB
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
            _showAddEntryDialog(context);
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
                  onPressed: () {},
                  icon: const Icon(
                    Icons.home,
                    color: Color(0xFF6F8B5E),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 40), // Espacio para el FAB
                IconButton(
                  onPressed: () {},
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

  Widget _buildCard(Map<String, String> category) {
    return GestureDetector(
      onTap: () {
        _showCategoryDetail(context, category['title']!);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo
              Image.asset(
                category['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Si la imagen no se puede cargar, mostrar placeholder
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image,
                      size: 70,
                      color: Colors.grey,
                    ),
                  );
                },
              ),

              // Gradient overlay (más sutil)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
              ),

              // Título con background semitransparente que ocupa todo el ancho
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  height: 80, // Altura fija para el área del texto
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(
                      0.5,
                    ), // Background negro con 50% opacidad
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      category['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDetail(BuildContext context, String categoryTitle) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Trabajos de $categoryTitle',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aquí se mostrarían los trabajos guardados para esta categoría.',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Trabajo'),
        content: const Text('¿Qué tipo de trabajo deseas agregar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí iría la navegación a la página de agregar trabajo
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
