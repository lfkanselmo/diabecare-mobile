import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../data/local/meal_dao.dart';
import '../../data/remote/food_api_client.dart';
import '../../data/remote/meal_api_client.dart';
import '../../data/repository_impl/food_repository_impl.dart';
import '../../data/repository_impl/meal_repository_impl.dart';
import '../../domain/entities/meal_entry.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/repositories/meal_repository.dart';

part 'nutrition_providers.g.dart';

@Riverpod(keepAlive: true)
MealDao mealDao(Ref ref) => MealDao(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
MealApiClient mealApiClient(Ref ref) => MealApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
FoodApiClient foodApiClient(Ref ref) => FoodApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
MealRepository mealRepository(Ref ref) => MealRepositoryImpl(
  dao: ref.watch(mealDaoProvider),
  apiClient: ref.watch(mealApiClientProvider),
  authRepository: ref.watch(authRepositoryProvider),
  database: ref.watch(appDatabaseProvider),
);

@Riverpod(keepAlive: true)
FoodRepository foodRepository(Ref ref) => FoodRepositoryImpl(ref.watch(foodApiClientProvider));

@riverpod
Stream<List<MealEntry>> mealsByDay(Ref ref, {required DateTime from, required DateTime to}) {
  return ref.watch(mealRepositoryProvider).watchMeals(from: from, to: to);
}
