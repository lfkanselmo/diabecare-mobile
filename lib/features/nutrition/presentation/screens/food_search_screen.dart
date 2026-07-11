import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/food.dart';
import '../providers/nutrition_providers.dart';

/// Resuelve con el [Food] elegido, o `null` si el usuario cancela — mismo
/// patrón de "búsqueda con selección" que `barcode-scanner`.
class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final _controller = TextEditingController();
  List<Food> _results = const [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() => _results = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(query.trim()));
  }

  Future<void> _search(String query) async {
    setState(() => _isSearching = true);
    try {
      final results = await ref.read(foodRepositoryProvider).search(query);
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nutritionFoodSearchTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  labelText: l10n.nutritionFoodSearchHint,
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: _results.isEmpty
                  ? Center(child: Text(l10n.nutritionFoodSearchEmpty))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final food = _results[index];
                        return ListTile(
                          title: Text(food.name),
                          subtitle: Text('${food.caloriesPer100g.toStringAsFixed(0)} kcal / 100g'),
                          onTap: () => Navigator.of(context).pop(food),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
