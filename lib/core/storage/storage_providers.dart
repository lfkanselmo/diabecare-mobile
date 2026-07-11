import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';

part 'storage_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => AppDatabase();
