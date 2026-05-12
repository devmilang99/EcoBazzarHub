import '../entities/user_entity.dart';

abstract class IAuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> signUp(String email, String password, String name);
  Future<UserEntity?> signInWithGoogle();
  Future<UserEntity?> signInWithGoogleSilently();
  UserEntity? getCurrentUser();
  Future<void> signOut();
  Future<void> resetPassword(String email);
}
