import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/pickers/adaptive_date_picker.dart';
import '../../../../shared/widgets/pickers/adaptive_segmented_control.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/meal_item.dart';
import '../../domain/entities/meal_item_calculator.dart';
import '../../domain/entities/meal_type.dart';
import '../providers/nutrition_providers.dart';
import 'barcode_scanner_screen.dart';
import 'food_search_screen.dart';

class MealRegisterScreen extends ConsumerStatefulWidget {
  const MealRegisterScreen({super.key});

  @override
  ConsumerState<MealRegisterScreen> createState() => _MealRegisterScreenState();
}

class _MealRegisterScreenState extends ConsumerState<MealRegisterScreen> {
  final _notesController = TextEditingController();
  final _uuid = const Uuid();

  MealType _mealType = MealType.breakfast;
  DateTime _consumedAt = DateTime.now();
  final List<MealItem> _items = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickConsumedAt() async {
    final date = await showAppDatePicker(
      context: context,
      initialDate: _consumedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_consumedAt));
    if (time == null) return;

    setState(() {
      _consumedAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _addFromSearch() async {
    final food = await Navigator.of(context).push<Food>(MaterialPageRoute(builder: (_) => const FoodSearchScreen()));
    if (food == null || !mounted) return;
    await _promptQuantityAndAdd(
      name: food.name,
      caloriesPer100g: food.caloriesPer100g,
      carbsPer100g: food.carbsPer100g,
      proteinsPer100g: food.proteinsPer100g,
      fatsPer100g: food.fatsPer100g,
    );
  }

  Future<void> _scanBarcode() async {
    final l10n = AppLocalizations.of(context)!;
    final barcode = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
    if (barcode == null || !mounted) return;

    final info = await ref.read(foodRepositoryProvider).lookupByBarcode(barcode);
    if (!mounted) return;
    if (info == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.nutritionFoodNotFound)));
      return;
    }
    await _promptQuantityAndAdd(
      name: info.name,
      caloriesPer100g: info.caloriesPer100g,
      carbsPer100g: info.carbsPer100g,
      proteinsPer100g: info.proteinsPer100g,
      fatsPer100g: info.fatsPer100g,
      foodCode: info.barcode,
    );
  }

  Future<void> _promptQuantityAndAdd({
    required String name,
    required double caloriesPer100g,
    required double carbsPer100g,
    double? proteinsPer100g,
    double? fatsPer100g,
    String? foodCode,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: '100');
    final quantity = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l10n.nutritionQuantityGrams),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.nutritionCancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(double.tryParse(controller.text)),
            child: Text(l10n.nutritionAdd),
          ),
        ],
      ),
    );
    if (quantity == null || quantity <= 0) return;

    setState(() {
      _items.add(
        MealItemCalculator.buildFromPer100g(
          id: _uuid.v4(),
          foodName: name,
          quantityGrams: quantity,
          caloriesPer100g: caloriesPer100g,
          carbsPer100g: carbsPer100g,
          proteinsPer100g: proteinsPer100g,
          fatsPer100g: fatsPer100g,
          foodCode: foodCode,
        ),
      );
    });
  }

  void _removeItem(String id) {
    setState(() => _items.removeWhere((i) => i.id == id));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.nutritionNoItemsError)));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(mealRepositoryProvider)
          .register(
            mealType: _mealType,
            consumedAt: _consumedAt,
            items: _items,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.nutritionSuccessMessage)));
        context.go('/nutrition/history');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.nutritionErrorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.nutritionMealRegisterTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.nutritionMealType, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              AdaptiveSegmentedControl<MealType>(
                options: {
                  MealType.breakfast: l10n.nutritionMealTypeBreakfast,
                  MealType.lunch: l10n.nutritionMealTypeLunch,
                  MealType.dinner: l10n.nutritionMealTypeDinner,
                  MealType.snack: l10n.nutritionMealTypeSnack,
                },
                selected: _mealType,
                onChanged: (value) => setState(() => _mealType = value),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickConsumedAt,
                child: InputDecorator(
                  decoration: InputDecoration(labelText: l10n.nutritionConsumedAt),
                  child: Text(_consumedAt.toString()),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addFromSearch,
                      icon: const Icon(Icons.search),
                      label: Text(l10n.nutritionAddFood),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _scanBarcode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(l10n.nutritionScanBarcode),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_items.isNotEmpty)
                ..._items.map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.foodName),
                      subtitle: Text('${item.quantityGrams.toStringAsFixed(0)}g — ${item.calories} kcal'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: l10n.commonDelete,
                        onPressed: () => _removeItem(item.id),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              AppTextField(label: l10n.nutritionNotes, controller: _notesController),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: _isSaving ? l10n.nutritionSaving : l10n.nutritionSave,
                isLoading: _isSaving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
