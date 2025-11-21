import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/settings_repository.dart';

class GetUrlUseCase implements UseCase<String, NoParams> {
  final SettingsRepository repository;

  GetUrlUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return repository.getUrl();
  }
}

