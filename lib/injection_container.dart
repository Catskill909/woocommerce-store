import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woocommerce_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:woocommerce_app/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:woocommerce_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:woocommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:woocommerce_app/features/auth/presentation/providers/auth_provider.dart';

class ConfigurationException implements Exception {
  final String message;
  const ConfigurationException(this.message);
  
  @override
  String toString() => 'ConfigurationException: $message';
}

final getIt = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Environment variables
  final baseUrl = dotenv.get('WOOCOMMERCE_SITE_URL');
  final consumerKey = dotenv.get('WOOCOMMERCE_CONSUMER_KEY');
  final consumerSecret = dotenv.get('WOOCOMMERCE_CONSUMER_SECRET');
  final jwtSecret = dotenv.get('JWT_SECRET');

  if (baseUrl.isEmpty || consumerKey.isEmpty || consumerSecret.isEmpty || jwtSecret.isEmpty) {
    throw const ConfigurationException('Missing required environment variables');
  }

  // Register remote data source with required parameters
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      client: getIt<http.Client>(),
      baseUrl: baseUrl,
      consumerKey: consumerKey,
      consumerSecret: consumerSecret,
      secureStorage: getIt<FlutterSecureStorage>(),
      jwtBaseUrl: dotenv.get('JWT_BASE_URL'),
    ),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  // Providers
  getIt.registerFactory<AuthProvider>(
    () => AuthProvider(
      getIt<AuthRepository>(),
    ),
  );
}
