import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/pickers/adaptive_date_picker.dart';
import '../../domain/entities/biological_sex.dart';
import '../../domain/entities/diabetes_type.dart';
import '../../domain/entities/register_data.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _accountFormKey = GlobalKey<FormState>();
  final _profileFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _heightController = TextEditingController();

  int _step = 0;
  DateTime? _dateOfBirth;
  DateTime? _diagnosisDate;
  DiabetesType? _diabetesType;
  BiologicalSex? _biologicalSex;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _goToProfileStep() {
    if (_accountFormKey.currentState?.validate() ?? false) {
      setState(() => _step = 1);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;
    if (_dateOfBirth == null || _diagnosisDate == null || _diabetesType == null || _biologicalSex == null) {
      return;
    }

    await ref.read(authProvider.notifier).register(
      RegisterData(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        diabetesType: _diabetesType!,
        diagnosisDate: _diagnosisDate!,
        heightCm: double.parse(_heightController.text),
        biologicalSex: _biologicalSex!,
        termsAccepted: _termsAccepted,
      ),
    );

    if (!mounted) return;
    final state = ref.read(authProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.authRegisterErrorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authRegisterSubtitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _step == 0 ? _buildAccountStep(l10n) : _buildProfileStep(l10n, authState.isLoading),
        ),
      ),
    );
  }

  Widget _buildAccountStep(AppLocalizations l10n) {
    return Form(
      key: _accountFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.authRegisterStepAccount, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.authRegisterEmail,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return l10n.authRegisterEmailRequired;
              if (!value.contains('@')) return l10n.authRegisterEmailInvalid;
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.authRegisterPassword,
            controller: _passwordController,
            obscureText: true,
            validator: (value) =>
                (value == null || value.length < 8) ? l10n.authRegisterPasswordMinLength : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.authRegisterConfirmPassword,
            controller: _confirmPasswordController,
            obscureText: true,
            validator: (value) =>
                value != _passwordController.text ? l10n.authRegisterPasswordMismatch : null,
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(label: l10n.authRegisterNext, onPressed: _goToProfileStep),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.authRegisterHasAccount),
              TextButton(onPressed: () => context.pop(), child: Text(l10n.authRegisterLoginHere)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStep(AppLocalizations l10n, bool isLoading) {
    return Form(
      key: _profileFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.authRegisterStepProfile, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.authRegisterFullName,
            controller: _fullNameController,
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? l10n.authRegisterFullNameRequired : null,
          ),
          const SizedBox(height: 16),
          _DatePickerField(
            label: l10n.authRegisterDateOfBirth,
            value: _dateOfBirth,
            errorText: _dateOfBirth == null ? l10n.authRegisterDateOfBirthRequired : null,
            lastDate: DateTime.now(),
            onPicked: (date) => setState(() => _dateOfBirth = date),
          ),
          const SizedBox(height: 16),
          // TODO(fase-1): reemplazar por las etiquetas traducidas del catálogo
          // `/metadata/diabetes-types` (ver MetadataService de la web) una vez
          // que exista el bootstrap de metadata post-login en el móvil.
          DropdownButtonFormField<DiabetesType>(
            initialValue: _diabetesType,
            decoration: InputDecoration(labelText: l10n.authRegisterDiabetesType),
            items: DiabetesType.values
                .map((type) => DropdownMenuItem(value: type, child: Text(type.wireValue)))
                .toList(),
            onChanged: (value) => setState(() => _diabetesType = value),
            validator: (value) => value == null ? l10n.authRegisterDiabetesTypeRequired : null,
          ),
          const SizedBox(height: 16),
          _DatePickerField(
            label: l10n.authRegisterDiagnosisDate,
            value: _diagnosisDate,
            errorText: _diagnosisDate == null ? l10n.authRegisterDiagnosisDateRequired : null,
            lastDate: DateTime.now(),
            onPicked: (date) => setState(() => _diagnosisDate = date),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.authRegisterHeightCm,
            controller: _heightController,
            keyboardType: TextInputType.number,
            validator: (value) {
              final parsed = double.tryParse(value ?? '');
              return parsed == null ? l10n.authRegisterHeightRequired : null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<BiologicalSex>(
            initialValue: _biologicalSex,
            decoration: InputDecoration(labelText: l10n.authRegisterBiologicalSex),
            items: [
              DropdownMenuItem(value: BiologicalSex.female, child: Text(l10n.authRegisterSexFemale)),
              DropdownMenuItem(value: BiologicalSex.male, child: Text(l10n.authRegisterSexMale)),
              DropdownMenuItem(
                value: BiologicalSex.notSpecified,
                child: Text(l10n.authRegisterSexUnspecified),
              ),
            ],
            onChanged: (value) => setState(() => _biologicalSex = value),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _termsAccepted,
            onChanged: (value) => setState(() => _termsAccepted = value ?? false),
            title: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(text: '${l10n.authRegisterTermsPrefix} '),
                  TextSpan(
                    text: l10n.authRegisterTermsLink,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () => context.push('/legal/privacy'),
                  ),
                ],
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _step = 0),
                  child: Text(l10n.authRegisterBack),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppPrimaryButton(
                  label: l10n.authRegisterSubmit,
                  isLoading: isLoading,
                  onPressed: _termsAccepted ? _submit : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onPicked,
    required this.lastDate,
    this.errorText,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPicked;
  final DateTime lastDate;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showAppDatePicker(
          context: context,
          initialDate: value ?? DateTime(lastDate.year - 30),
          firstDate: DateTime(1900),
          lastDate: lastDate,
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, errorText: value == null ? errorText : null),
        child: Text(value == null ? '' : '${value!.year}-${value!.month}-${value!.day}'),
      ),
    );
  }
}
