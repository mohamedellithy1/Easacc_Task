import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/auth_utils.dart';
import '../../domain/usecases/login_with_facebook_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final LoginWithFacebookUseCase loginWithFacebookUseCase;

  AuthCubit({
    required this.loginWithGoogleUseCase,
    required this.loginWithFacebookUseCase,
  }) : super(AuthInitial());

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    final result = await loginWithGoogleUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> loginWithFacebook() async {
    emit(AuthLoading());
    final result = await loginWithFacebookUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> logoutUser() async {
    await logout();
    emit(AuthInitial());
  }
}
