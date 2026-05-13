import 'package:flutter/material.dart';
import '../auth_service.dart';
import 'package:smartshop/features/auth/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _auth = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      var user = await _auth.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user == null) {
        setState(() => _errorMessage = 'Invalid email or password.');
      }
      // AuthGate handles navigation automatically on success
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF5F6D), Color(0xFFFF8A65)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ), // Standard "Box" width for Web
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Friendly Icon Header ---
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // --- The Login Card (The Box) ---
                  Card(
                    elevation: 10,
                    shadowColor: Colors.black38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF5F6D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Access your Fashion Store account",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Email Field
                            _buildField(
                              controller: emailController,
                              label: 'Email address',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if (!v.contains('@')) {
                                  return 'Enter valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Password Field
                            _buildPasswordField(),

                            _buildForgotPassword(),

                            if (_errorMessage.isNotEmpty)
                              _buildErrorContainer(),

                            const SizedBox(height: 12),

                            // Sign In Button
                            _buildSignInButton(),

                            const SizedBox(height: 24),
                            _buildDivider(),
                            const SizedBox(height: 24),

                            const SizedBox(height: 20),
                            _buildRegisterLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Component Helper Methods ---

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'SmartShop',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscurePassword,
      validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(
          Icons.lock_outline,
          size: 20,
          color: Colors.grey,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Forgot password?',
          style: TextStyle(color: Color(0xFFFF5F6D), fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        _errorMessage,
        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF5F6D)),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF5F6D), Color(0xFFFF8A65)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.black12)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        Expanded(child: Divider(color: Colors.black12)),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RegisterScreen()),
        ),
        child: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(color: Color.fromARGB(242, 246, 245, 245)),
              ),
              TextSpan(
                text: 'Register',
                style: TextStyle(
                  color: Color(0xFFFF5F6D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFF5F6D)),
        ),
      ),
    );
  }
}
