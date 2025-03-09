import 'package:firebase_auth/firebase_auth.dart';
import 'package:tote_app/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<({UserCredential? user, String? error})> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Sync user with our database
      if (userCredential.user != null) {
        try {
          await _userService.syncUserWithDatabase(userCredential.user!);
        } catch (e) {
          print('Warning: Failed to sync user with database: $e');
          // Continue even if database sync fails - the user is still authenticated
        }
      }
      
      return (user: userCredential, error: null);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "Couldn't find your account";
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password. Try again or click "Forgot password" to reset it';
          break;
        case 'invalid-email':
          errorMessage = 'Enter a valid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
      return (user: null, error: errorMessage);
    } catch (e) {
      print('Unexpected error during sign in: $e');
      return (user: null, error: 'An error occurred. Please try again.');
    }
  }

  // Create user with email and password
  Future<({UserCredential? user, String? error})> createUserWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user in our database
      if (userCredential.user != null) {
        try {
          await _userService.syncUserWithDatabase(userCredential.user!);
        } catch (e) {
          print('Warning: Failed to sync user with database: $e');
          // Continue even if database sync fails - the user is still authenticated
        }
      }
      
      return (user: userCredential, error: null);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Enter a valid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          errorMessage = 'Password should be at least 6 characters';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
      return (user: null, error: errorMessage);
    } catch (e) {
      print('Unexpected error during sign up: $e');
      return (user: null, error: 'An error occurred. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
} 