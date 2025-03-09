import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tote_app/models/user_model.dart';
import 'package:tote_app/services/user_service.dart';
import 'package:tote_app/providers/auth_provider.dart';

// User service provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// Current user provider
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserModel?>>((ref) {
  final authState = ref.watch(authStateProvider);
  final userService = ref.watch(userServiceProvider);
  
  return CurrentUserNotifier(userService, authState);
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final UserService _userService;
  final AsyncValue<User?> _authState;
  
  CurrentUserNotifier(this._userService, this._authState) : super(const AsyncValue.loading()) {
    _init();
  }
  
  Future<void> _init() async {
    _authState.whenData((firebaseUser) async {
      if (firebaseUser == null) {
        state = const AsyncValue.data(null);
      } else {
        await _syncUser(firebaseUser);
      }
    });
  }
  
  Future<void> _syncUser(User firebaseUser) async {
    state = const AsyncValue.loading();
    try {
      final user = await _userService.syncUserWithDatabase(firebaseUser);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    final currentUser = state.value;
    if (currentUser == null) return;
    
    state = const AsyncValue.loading();
    try {
      final updatedUser = await _userService.updateUserProfile(
        currentUser.id, 
        profileData
      );
      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
} 