import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators/auth_validators.dart';
import '../../application/auth_controller.dart';

class AuthForm extends ConsumerStatefulWidget {
  final bool isLogin;

  const AuthForm({
    super.key,
    required this.isLogin,
  });

  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();
    if (errorString.contains('network-request-failed')) {
      return 'Ошибка сети. Проверьте подключение к интернету.';
    } else if (errorString.contains('weak-password')) {
      return 'Пароль слишком слабый. Используйте минимум 6 символов.';
    } else if (errorString.contains('email-already-in-use')) {
      return 'Этот email уже зарегистрирован.';
    } else if (errorString.contains('user-not-found')) {
      return 'Пользователь не найден.';
    } else if (errorString.contains('wrong-password')) {
      return 'Неверный пароль.';
    } else if (errorString.contains('invalid-email')) {
      return 'Неверный формат email.';
    } else if (errorString.contains('too-many-requests')) {
      return 'Слишком много запросов. Попробуйте позже.';
    }
    return 'Произошла ошибка: ${errorString.split(']').last.trim()}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final authController = ref.read(authControllerProvider.notifier);

    if (widget.isLogin) {
      await authController.signInWithEmailAndPassword(email, password);
    } else {
      await authController.signUpWithEmailAndPassword(email, password);
    }

    final authState = ref.read(authControllerProvider);
    if (authState.hasError && mounted) {
      final errorMessage = _getErrorMessage(authState.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: AuthValidators.emailValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            obscureText: !_isPasswordVisible,
            validator: AuthValidators.passwordValidator,
            textInputAction: widget.isLogin ? TextInputAction.done : TextInputAction.next,
          ),
          if (!widget.isLogin) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isConfirmPasswordVisible,
              validator: (value) => AuthValidators.confirmPasswordValidator(
                value, 
                _passwordController.text,
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.isLogin ? 'Sign In' : 'Sign Up',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}