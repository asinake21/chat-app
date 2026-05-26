import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../core/routes/app_routes.dart';

// Screen for new students to register an account
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Global key for form validation, plus controllers for name, email and password
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle signup. If successful, automatically log in and clear the navigation stack to home.
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
        if (mounted) {
          Helpers.showSnackBar(context, 'Account created successfully!');
          // Navigate to Home screen and pop all auth screens from history
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join CampusLink to start sharing and interacting with fellow students.',
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 32),

                // Name, Email, and Password registration fields
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Enter your full name',
                  labelText: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: Validators.validateUsername,
                  enabled: !authProvider.isLoading,
                ),
                const SizedBox(height: 20),
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
                  hintText: 'Create a password (min 6 chars)',
                  labelText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: Validators.validatePassword,
                  enabled: !authProvider.isLoading,
                ),
                const SizedBox(height: 32),

                // Submit button for registration
                CustomButton(
                  text: 'Sign Up',
                  onPressed: _handleRegister,
                  isLoading: authProvider.isLoading,
                ),
                const SizedBox(height: 24),

                // Takes user back to the sign in page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: theme.hintColor),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Sign In',
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
