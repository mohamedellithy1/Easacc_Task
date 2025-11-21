import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/usecases/get_url_usecase.dart';
import '../../domain/usecases/listen_to_devices_usecase.dart';
import '../../domain/usecases/save_url_usecase.dart';
import '../../domain/usecases/scan_devices_usecase.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SaveUrlUseCase saveUrlUseCase;
  final GetUrlUseCase getUrlUseCase;
  final ScanDevicesUseCase scanDevicesUseCase;
  final ListenToDevicesUseCase listenToDevicesUseCase;

  StreamSubscription<List<DeviceEntity>>? _deviceSubscription;

  SettingsCubit({
    required this.saveUrlUseCase,
    required this.getUrlUseCase,
    required this.scanDevicesUseCase,
    required this.listenToDevicesUseCase,
  }) : super(SettingsInitial());

  @override
  Future<void> close() {
    _deviceSubscription?.cancel();
    return super.close();
  }

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    final result = await getUrlUseCase(NoParams());
    result.fold(
      (failure) => emit(const SettingsLoaded(url: '')), 
      (url) => emit(SettingsLoaded(url: url)),
    );
   
    scanDevices();
  }

  Future<void> saveUrl(String url) async {
    final currentState = state;
    emit(SettingsLoading());
    final result = await saveUrlUseCase(url);
    result.fold((failure) => emit(SettingsError(failure.message)), (_) {
      emit(UrlSaved());
      if (currentState is SettingsLoaded) {
        emit(currentState.copyWith(url: url));
      } else {
        emit(SettingsLoaded(url: url));
      }
    });
  }

  Future<void> scanDevices() async {
    _deviceSubscription ??= listenToDevicesUseCase().listen((devices) {
      final currentState = state;
      if (currentState is SettingsLoaded) {
        emit(currentState.copyWith(devices: devices));
      } else {
        emit(SettingsLoaded(devices: devices));
      }
    });

    final currentState = state;
    if (currentState is! SettingsLoaded) {
      emit(SettingsLoading());
    }

    final result = await scanDevicesUseCase(NoParams());

    result.fold((failure) => emit(SettingsError(failure.message)), (devices) {
      final currentState = state;
      if (currentState is SettingsLoaded) {
        emit(currentState.copyWith(devices: devices));
      } else {
        emit(SettingsLoaded(devices: devices));
      }
    });
  }
}
