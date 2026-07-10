import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).forgotPassword(_emailController.text.trim());
      if (mounted) setState(() => _submitted = true);
    } on DioException catch (e) {
      // El backend responde siempre 200 exista o no la cuenta
      // (anti-enumeración) — cualquier error que no sea rate-limit se trata
      // igual que un éxito, mismo comportamiento que `forgot-password.component.ts`.
      if (mounted) {
        if (e.response?.statusCode == 429) {
          setState(() => _errorMessage = l10n.authForgotPasswordErrorRateLimit);
        } else {
          setState(() => _submitted = true);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authForgotPasswordTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _submitted
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.authForgotPasswordSuccessMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(l10n.authForgotPasswordBackToLogin),
                      ),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.authForgotPasswordSubtitle, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        AppTextField(
                          label: l10n.authLoginEmail,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return l10n.authLoginEmailRequired;
                            if (!value.contains('@')) return l10n.authLoginEmailInvalid;
                            return null;
                          },
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ],
                        const SizedBox(height: 24),
                        AppPrimaryButton(
                          label: l10n.authForgotPasswordSubmit,
                          isLoading: _isLoading,
                          onPressed: _submit,
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
