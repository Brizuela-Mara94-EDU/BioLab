// src/pages/home_page.dart
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'category_detail_page.dart';
import 'camera_page.dart';
import 'new_worksheet_page.dart';

class HomePage extends StatefulWidget {
  final String email;

  const HomePage({super.key, required this.email});

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

  String get userName {
    final emailName = widget.email.split('@')[0];
    return emailName.isNotEmpty
        ? emailName[0].toUpperCase() + emailName.substring(1).toLowerCase()
        : 'Usuario';
  }

  void _jumpToCategory() {
    int targetIndex = 0;

    if (_selectedCategoryIndex == 0) {
      targetIndex = 0;
    } else if (_selectedCategoryIndex == 1) {
      targetIndex = 2;
    } else if (_selectedCategoryIndex == 2) {
      targetIndex = 3;
    }

    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
                widget.email.isNotEmpty ? widget.email[0].toUpperCase() : 'U',
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
              widget.email,
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
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bienvenido, $userName!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showUserMenu,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF6F8B5E),
                      radius: 20,
                      child: Text(
                        widget.email.isNotEmpty
                            ? widget.email[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

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

            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _allCategories.length,
                  onPageChanged: (index) {
                    setState(() {
                      if (index <= 1) {
                        _selectedCategoryIndex = 0;
                      } else if (index == 2) {
                        _selectedCategoryIndex = 1;
                      } else if (index == 3) {
                        _selectedCategoryIndex = 2;
                      }
                    });
                  },
                  itemBuilder: (context, index) {
                    EdgeInsets margin;
                    if (index == 0) {
                      margin = const EdgeInsets.only(left: 5, right: 10);
                    } else if (index == _allCategories.length - 1) {
                      margin = const EdgeInsets.only(left: 10, right: 5);
                    } else {
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
            // Navega directamente a la página de nueva planilla con el email
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewWorksheetPage(
                  userEmail: widget.email, // ← CAMBIO IMPORTANTE
                ),
              ),
            ).then((_) {
              // Opcional: recargar algo si es necesario cuando vuelva
              setState(() {});
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
                  onPressed: () {},
                  icon: const Icon(
                    Icons.home,
                    color: Color(0xFF6F8B5E),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 40),
                IconButton(
                  onPressed: () {
                    // Navega a la página de cámara
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraPage(),
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

  Widget _buildCard(Map<String, String> category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailPage(
              categoryTitle: category['title']!,
              categoryType: category['category']!,
              userEmail: widget.email, // ← CAMBIO IMPORTANTE
            ),
          ),
        ).then((_) {
          // Opcional: recargar datos cuando vuelva de la página de detalles
          setState(() {});
        });
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
              Image.asset(
                category['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
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
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
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
}
