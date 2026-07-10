import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.token});

  /// Viene del query param `?token=...` del enlace del correo — null si el
  /// enlace no lo trae, mismo caso que `reset-password.component.ts` trata
  /// como enlace inválido de inmediato, sin llamar al backend.
  final String? token;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _success = false;
  bool _invalidLink = false;

  @override
  void initState() {
    super.initState();
    _invalidLink = widget.token == null;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(token: widget.token!, newPassword: _passwordController.text);
      if (mounted) setState(() => _success = true);
    } catch (_) {
      // Cualquier error se asume enlace inválido/expirado/ya usado, igual
      // que `reset-password.component.ts` — no hay un mensaje genérico aparte.
      if (mounted) setState(() => _invalidLink = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authResetPasswordTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildBody(l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_invalidLink) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.authResetPasswordInvalidLink, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/auth/forgot-password'),
            child: Text(l10n.authResetPasswordRequestNewLink),
          ),
        ],
      );
    }

    if (_success) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.authResetPasswordSuccessMessage, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(onPressed: () => context.go('/auth/login'), child: Text(l10n.authLoginSubmit)),
        ],
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.authResetPasswordSubtitle, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          AppTextField(
            label: l10n.authResetPasswordNewPassword,
            controller: _passwordController,
            obscureText: true,
            validator: (value) =>
                (value == null || value.length < 8) ? l10n.authResetPasswordPasswordTooShort : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.authResetPasswordConfirmPassword,
            controller: _confirmController,
            obscureText: true,
            validator: (value) =>
                value != _passwordController.text ? l10n.authResetPasswordPasswordMismatch : null,
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: l10n.authResetPasswordSubmit,
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
