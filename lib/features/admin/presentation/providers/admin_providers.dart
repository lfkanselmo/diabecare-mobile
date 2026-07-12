import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/remote/admin_api_client.dart';
import '../../data/repository_impl/admin_repository_impl.dart';
import '../../domain/repositories/admin_repository.dart';

part 'admin_providers.g.dart';

@Riverpod(keepAlive: true)
AdminApiClient adminApiClient(Ref ref) => AdminApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
AdminRepository adminRepository(Ref ref) => AdminRepositoryImpl(ref.watch(adminApiClientProvider));
