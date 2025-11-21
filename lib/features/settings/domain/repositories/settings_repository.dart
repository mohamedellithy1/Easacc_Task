import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/device_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failure, void>> saveUrl(String url);
  Future<Either<Failure, String>> getUrl();
  Future<Either<Failure, List<DeviceEntity>>> scanDevices();
  Stream<List<DeviceEntity>> get deviceStream;
}
