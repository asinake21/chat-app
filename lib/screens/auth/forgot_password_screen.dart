import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.resetPassword(_emailController.text.trim());
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Password reset link has been sent to ${_emailController.text.trim()}!',
          );
          Navigator.pop(context);
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
                  'Reset Password',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the email address associated with your student account. We will send you instructions to reset your password.',
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),

                // Email Input
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Enter your student email',
                  labelText: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  enabled: !authProvider.isLoading,
                ),
                const SizedBox(height: 32),

                // Action Button
                CustomButton(
                  text: 'Send Reset Link',
                  onPressed: _handlePasswordReset,
                  isLoading: authProvider.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
