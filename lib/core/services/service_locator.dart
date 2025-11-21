import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_with_facebook_usecase.dart';
import '../../features/auth/domain/usecases/login_with_google_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/settings/data/datasources/device_discovery_service.dart';
import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_url_usecase.dart';
import '../../features/settings/domain/usecases/save_url_usecase.dart';
import '../../features/settings/domain/usecases/scan_devices_usecase.dart';
import '../../features/settings/domain/usecases/listen_to_devices_usecase.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(
    () =>
        AuthCubit(loginWithGoogleUseCase: sl(), loginWithFacebookUseCase: sl()),
  );

  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithFacebookUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      facebookAuth: sl(),
    ),
  );

  sl.registerFactory(
    () => SettingsCubit(
      saveUrlUseCase: sl(),
      getUrlUseCase: sl(),
      scanDevicesUseCase: sl(),
      listenToDevicesUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => SaveUrlUseCase(sl()));
  sl.registerLazySingleton(() => GetUrlUseCase(sl()));
  sl.registerLazySingleton(() => ScanDevicesUseCase(sl()));
  sl.registerLazySingleton(() => ListenToDevicesUseCase(sl()));

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: sl(),
      deviceDiscoveryService: sl(),
    ),
  );

  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<DeviceDiscoveryService>(
    () => DeviceDiscoveryServiceImpl(),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn.instance);
  sl.registerLazySingleton(() => FacebookAuth.instance);
}
