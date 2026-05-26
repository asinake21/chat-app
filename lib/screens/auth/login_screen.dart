import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../core/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (mounted) {
          Helpers.showSnackBar(context, 'Successfully signed in!');
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } catch (e) {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            e.toString().replaceAll('Exception:', '').trim(),
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Heading
                Text(
                  'Welcome Back!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to stay connected with your campus community.',
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 36),

                // Form Fields
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Enter your student email',
                  labelText: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  enabled: !authProvider.isLoading,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Enter your password',
                  labelText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: Validators.validatePassword,
                  enabled: !authProvider.isLoading,
                ),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.forgotPassword);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Submit Button
                CustomButton(
                  text: 'Sign In',
                  onPressed: _handleLogin,
                  isLoading: authProvider.isLoading,
                ),
                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: theme.hintColor),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: Text(
                        'Register Now',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
