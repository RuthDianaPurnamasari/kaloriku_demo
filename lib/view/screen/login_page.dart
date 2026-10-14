import 'package:flutter/material.dart';
import 'package:kaloriku/model/login_model.dart';
import 'package:kaloriku/services/api_services.dart';
import 'package:kaloriku/services/auth_manager.dart';
import 'package:kaloriku/view/screen/bottom_navbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final ApiServices _dataService = ApiServices();

  bool _isLoading = false;

  // Akun demo lokal, tidak membutuhkan backend.
  static const String _demoUsername = 'demo';
  static const String _demoPassword = 'demo123';

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final isLoggedIn = await AuthManager.isLoggedIn();

    if (isLoggedIn && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const DynamicBottomNavbar(),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username tidak boleh kosong';
    }

    if (value.trim().length < 4) {
      return 'Masukkan minimal 4 karakter';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 3) {
      return 'Masukkan minimal 3 karakter';
    }

    return null;
  }

  // Login dari kolom username dan password.
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final isValidForm = _formKey.currentState!.validate();
    if (!isValidForm) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Periksa akun demo terlebih dahulu.
    if (username.toLowerCase() == _demoUsername && password == _demoPassword) {
      await _handleDemoLogin();
      return;
    }

    // Jika bukan akun demo, lanjutkan login biasa.
    setState(() {
      _isLoading = true;
    });

    final loginData = LoginInput(
      username: username,
      password: password,
    );

    try {
      final res = await _dataService.login(loginData);

      if (!mounted) return;

      if (res?.status == 200 && (res?.token ?? '').isNotEmpty) {
        await AuthManager.login(
          username,
          res!.token!,
        );

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DynamicBottomNavbar(),
          ),
          (route) => false,
        );
      } else {
        displaySnackbar(
          res?.message ??
              'Login gagal. Gunakan demo / demo123 untuk masuk mode demo.',
        );
      }
    } catch (e) {
      if (mounted) {
        displaySnackbar(
          'Login server gagal. Gunakan demo / demo123 untuk masuk mode demo.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Masuk demo tanpa backend atau token.
  Future<void> _handleDemoLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthManager.enableDemoMode('Demo KaloriKu');

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const DynamicBottomNavbar(),
        ),
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background image.
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Gradient overlay.
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black54,
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Login form.
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextFormField(
                              controller: _usernameController,
                              validator: _validateUsername,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.account_circle_rounded,
                                ),
                                hintText: 'Masukkan username...',
                                labelText: 'Username',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                fillColor: Color.fromARGB(
                                  255,
                                  242,
                                  254,
                                  255,
                                ),
                                filled: true,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              validator: _validatePassword,
                              onFieldSubmitted: (_) {
                                if (!_isLoading) {
                                  _handleLogin();
                                }
                              },
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.password_rounded,
                                ),
                                hintText: 'Masukkan password...',
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                fillColor: Color.fromARGB(
                                  255,
                                  242,
                                  254,
                                  255,
                                ),
                                filled: true,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Login'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleDemoLogin,
                        icon: const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          '.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Akun demo: demo / demo123',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void displaySnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
