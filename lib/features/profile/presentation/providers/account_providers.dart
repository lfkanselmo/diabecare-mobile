import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/remote/account_api_client.dart';
import '../../data/remote/device_api_key_api_client.dart';
import '../../data/remote/session_api_client.dart';
import '../../data/repository_impl/account_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';

part 'account_providers.g.dart';

@Riverpod(keepAlive: true)
AccountApiClient accountApiClient(Ref ref) => AccountApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
DeviceApiKeyApiClient deviceApiKeyApiClient(Ref ref) => DeviceApiKeyApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
SessionApiClient sessionApiClient(Ref ref) => SessionApiClient(ref.watch(apiDioProvider));

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) => AccountRepositoryImpl(
  accountApiClient: ref.watch(accountApiClientProvider),
  deviceApiKeyApiClient: ref.watch(deviceApiKeyApiClientProvider),
  sessionApiClient: ref.watch(sessionApiClientProvider),
  authRepository: ref.watch(authRepositoryProvider),
  secureAuthStorage: ref.watch(secureAuthStorageProvider),
);
