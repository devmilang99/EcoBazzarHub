import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;
  LoginUseCase(this.repository);

  Future<UserEntity?> execute(String email, String password) {
    return repository.login(email, password);
  }
}

class SignUpUseCase {
  final IAuthRepository repository;
  SignUpUseCase(this.repository);

  Future<UserEntity?> execute(String email, String password, String name) {
    return repository.signUp(email, password, name);
  }
}

class GoogleSignInUseCase {
  final IAuthRepository repository;
  GoogleSignInUseCase(this.repository);

  Future<UserEntity?> execute() {
    return repository.signInWithGoogle();
  }
}

class GoogleSilentSignInUseCase {
  final IAuthRepository repository;
  GoogleSilentSignInUseCase(this.repository);

  Future<UserEntity?> execute() {
    return repository.signInWithGoogleSilently();
  }
}

class GetCurrentUserUseCase {
  final IAuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  UserEntity? execute() {
    return repository.getCurrentUser();
  }
}

class ResetPasswordUseCase {
  final IAuthRepository repository;
  ResetPasswordUseCase(this.repository);

  Future<void> execute(String email) {
    return repository.resetPassword(email);
  }
}
