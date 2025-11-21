import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/device_discovery_service.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final DeviceDiscoveryService deviceDiscoveryService;

  SettingsRepositoryImpl({
    required this.localDataSource,
    required this.deviceDiscoveryService,
  });

  @override
  Future<Either<Failure, String>> getUrl() async {
    try {
      final url = await localDataSource.getUrl();
      if (url != null) {
        return Right(url);
      } else {
        return const Left(CacheFailure('No URL saved'));
      }
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveUrl(String url) async {
    try {
      await localDataSource.saveUrl(url);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DeviceEntity>>> scanDevices() async {
    try {
      final devices = await deviceDiscoveryService.scanDevices();
      return Right(devices);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<DeviceEntity>> get deviceStream =>
      deviceDiscoveryService.deviceStream;
}
