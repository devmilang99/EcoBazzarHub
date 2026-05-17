import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_bazzar_hub/features/auth/domain/entities/user_entity.dart';
import 'package:eco_bazzar_hub/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eco_bazzar_hub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:eco_bazzar_hub/core/database/app_database.dart';
import 'package:eco_bazzar_hub/core/providers.dart';

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserEntity? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final authRepositoryProvider = Provider((ref) => AuthRepositoryImpl());

final loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);
final signUpUseCaseProvider = Provider(
  (ref) => SignUpUseCase(ref.watch(authRepositoryProvider)),
);
final googleSignInUseCaseProvider = Provider(
  (ref) => GoogleSignInUseCase(ref.watch(authRepositoryProvider)),
);
final googleSilentSignInUseCaseProvider = Provider(
  (ref) => GoogleSilentSignInUseCase(ref.watch(authRepositoryProvider)),
);
final getCurrentUserUseCaseProvider = Provider(
  (ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)),
);
final resetPasswordUseCaseProvider = Provider(
  (ref) => ResetPasswordUseCase(ref.watch(authRepositoryProvider)),
);
final signOutUseCaseProvider = Provider(
  (ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);

// StateNotifier is definitely in flutter_riverpod
class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final SignUpUseCase _signUpUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final GoogleSilentSignInUseCase _googleSilentSignInUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final SignOutUseCase _signOutUseCase;
  final AppDatabase _database;

  AuthViewModel({
    required LoginUseCase loginUseCase,
    required SignUpUseCase signUpUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required GoogleSilentSignInUseCase googleSilentSignInUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required SignOutUseCase signOutUseCase,
    required AppDatabase database,
  }) : _loginUseCase = loginUseCase,
       _signUpUseCase = signUpUseCase,
       _googleSignInUseCase = googleSignInUseCase,
       _googleSilentSignInUseCase = googleSilentSignInUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _signOutUseCase = signOutUseCase,
       _database = database,
       super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _loginUseCase.execute(email, password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _signUpUseCase.execute(email, password, name);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _googleSignInUseCase.execute();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  Future<void> tryAutoLogin() async {
    final currentUser = _getCurrentUserUseCase.execute();
    if (currentUser != null) {
      state = state.copyWith(user: currentUser);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _googleSilentSignInUseCase.execute();
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _resetPasswordUseCase.execute(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _signOutUseCase.execute();
      await _database.clearAllData();
      state = AuthState(user: null, isLoading: false, error: null);
    } catch (e) {
      state = AuthState(user: null, isLoading: false, error: _formatError(e));
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _formatError(dynamic e) {
    final str = e.toString();
    if (str.contains('user-not-found') || str.contains('invalid-credential') || str.contains('wrong-password')) {
      return 'Invalid email or password. Please try again.';
    }
    if (str.contains('email-already-in-use')) {
      return 'This email is already in use. Please try logging in instead.';
    }
    if (str.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }
    return str.replaceAll('Exception: ', '').replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(
    loginUseCase: ref.watch(loginUseCaseProvider),
    signUpUseCase: ref.watch(signUpUseCaseProvider),
    googleSignInUseCase: ref.watch(googleSignInUseCaseProvider),
    googleSilentSignInUseCase: ref.watch(googleSilentSignInUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
    database: ref.watch(databaseProvider),
  );
});
