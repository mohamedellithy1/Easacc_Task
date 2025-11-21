import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/device_entity.dart';
import '../repositories/settings_repository.dart';

class ScanDevicesUseCase implements UseCase<List<DeviceEntity>, NoParams> {
  final SettingsRepository repository;

  ScanDevicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<DeviceEntity>>> call(NoParams params) {
    return repository.scanDevices();
  }
}

