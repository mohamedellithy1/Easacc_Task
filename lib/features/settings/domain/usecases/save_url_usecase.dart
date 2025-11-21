import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/settings_repository.dart';

class SaveUrlUseCase implements UseCase<void, String> {
  final SettingsRepository repository;

  SaveUrlUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String url) {
    return repository.saveUrl(url);
  }
}

