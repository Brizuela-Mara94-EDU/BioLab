// src/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import 'loading_page.dart';
import 'register_page.dart';
import 'forget_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _trySubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final email = _emailCtrl.text.trim();
      final password = _passCtrl.text;

      try {
        // Intentar login
        final userData = await _authService.loginUser(email, password);

        if (!mounted) return;

        if (userData != null) {
          // Login exitoso
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => LoadingPage(
                email: userData['email'],
                // Puedes pasar más datos si los necesitas
                // userName: userData['nombre'],
              ),
            ),
          );
        } else {
          // Credenciales incorrectas
          _showErrorDialog(
            'Error de autenticación',
            'El email o la contraseña son incorrectos.',
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog(
            'Error',
            'Ocurrió un error al intentar iniciar sesión. Intenta nuevamente.',
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _goToRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
  }

  void _goToForgetPassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ForgetPasswordPage()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 400 ? 20 : 32,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth < 400 ? screenWidth - 40 : 400,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo SVG y título
                    Container(
                      width: screenWidth < 400 ? 140 : 180,
                      height: screenWidth < 400 ? 140 : 180,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/tree.svg',
                          width: 140,
                          height: 140,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'BioLab',
                      style: TextStyle(
                        fontSize: screenWidth < 400 ? 28 : 32,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Iniciar sesión',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 40),
                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'ejemplo@biolab.com',
                        prefixIcon: Icon(
                          Icons.email,
                          color: theme.primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa tu email';
                        }
                        if (!v.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Contraseña
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock, color: theme.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                            color: theme.primaryColor,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresa tu contraseña';
                        }
                        if (v.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Botón de login
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _trySubmit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Links adicionales - Diseño responsive
                    screenWidth < 400
                        ? Column(
                            children: [
                              TextButton(
                                onPressed: _isLoading ? null : _goToRegister,
                                child: Text(
                                  'Registrarse',
                                  style: TextStyle(color: theme.primaryColor),
                                ),
                              ),
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : _goToForgetPassword,
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(color: theme.primaryColor),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: TextButton(
                                  onPressed: _isLoading ? null : _goToRegister,
                                  child: Text(
                                    'Registrarse',
                                    style: TextStyle(color: theme.primaryColor),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _goToForgetPassword,
                                  child: Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: TextStyle(color: theme.primaryColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
