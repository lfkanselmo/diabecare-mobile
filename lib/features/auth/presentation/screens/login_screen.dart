import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/network/api_error.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(authProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    final state = ref.read(authProvider);
    if (state.hasError) {
      final l10n = AppLocalizations.of(context)!;
      final code = extractApiErrorCode(state.error!);
      final message = switch (code) {
        'ACCOUNT_SUSPENDED' => l10n.authLoginErrorSuspended,
        'INVALID_CREDENTIALS' => l10n.authLoginErrorInvalidCredentials,
        _ => l10n.authLoginErrorGeneric,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.authLoginSubtitle,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: l10n.authLoginEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return l10n.authLoginEmailRequired;
                      if (!value.contains('@')) return l10n.authLoginEmailInvalid;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: l10n.authLoginPassword,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      tooltip: _obscurePassword ? l10n.authLoginShowPassword : l10n.authLoginHidePassword,
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? l10n.authLoginPasswordRequired : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/auth/forgot-password'),
                      child: Text(l10n.authLoginForgotPassword),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppPrimaryButton(
                    label: l10n.authLoginSubmit,
                    isLoading: authState.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.authLoginNoAccount),
                      TextButton(
                        onPressed: () => context.push('/auth/register'),
                        child: Text(l10n.authLoginRegisterHere),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
