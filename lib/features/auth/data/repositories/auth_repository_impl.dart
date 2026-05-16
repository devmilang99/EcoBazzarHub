import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Use named constructor or default for newer versions
  // For Android, Google Sign-In usually finds the configuration automatically.
  // However, on some environments or for specific features, providing the webClientId (client_type: 3) is required.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '951552864785-ds2sh0mf6boaqjl2olmib7ot47uqf5en.apps.googleusercontent.com',
  );

  @override
  Future<UserEntity?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapFirebaseUserToEntity(credential.user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signUp(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      return _mapFirebaseUserToEntity(credential.user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      // Ensure a completely fresh state before showing the picker.
      // We try to disconnect first to clear any cached session that might persist.
      try {
        await _auth.signOut();
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect();
      } catch (_) {
        // Ignore errors during initial cleanup
      }
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
          
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        throw Exception('Google Authentication failed: Missing tokens. Please check your Firebase/Google Console configuration.');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw Exception('Firebase Sign-In failed: No user returned after credential verification.');
      }
      
      return _mapFirebaseUserToEntity(userCredential.user);
    } catch (e) {
      if (e.toString().contains('sign_in_failed')) {
        throw Exception(
          'Google Sign-In Failed: This is often caused by a missing SHA-1 fingerprint in Firebase Console. '
          'Please ensure you have added your debug and release SHA-1 keys to the Firebase project settings.',
        );
      }
      if (e is FirebaseAuthException) {
        throw Exception('Firebase Auth Error (${e.code}): ${e.message}');
      }
      throw Exception('Sign-in error: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> signInWithGoogleSilently() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .signInSilently();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return _mapFirebaseUserToEntity(userCredential.user);
    } catch (e) {
      return null;
    }
  }

  @override
  UserEntity? getCurrentUser() {
    return _mapFirebaseUserToEntity(_auth.currentUser);
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      // Disconnect helps ensure a fresh account picker and clears cached tokens more thoroughly
      await _googleSignIn.disconnect();
    } catch (_) {
      // Ignore errors during sign-out/disconnect if already signed out
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  UserEntity? _mapFirebaseUserToEntity(User? user) {
    if (user == null) return null;
    final isGoogleUser = user.providerData.any(
      (info) => info.providerId == 'google.com',
    );
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
      isGoogleUser: isGoogleUser,
    );
  }
}
