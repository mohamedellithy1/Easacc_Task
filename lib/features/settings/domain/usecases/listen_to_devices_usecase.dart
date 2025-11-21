import '../entities/device_entity.dart';
import '../repositories/settings_repository.dart';

class ListenToDevicesUseCase {
  final SettingsRepository repository;

  ListenToDevicesUseCase(this.repository);

  Stream<List<DeviceEntity>> call() {
    return repository.deviceStream;
  }
}
