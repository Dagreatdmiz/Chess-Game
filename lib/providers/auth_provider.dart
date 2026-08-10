import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/player_profile.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, PlayerProfile?>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthNotifier(service);
});

class AuthNotifier extends StateNotifier<PlayerProfile?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(PlayerProfile.defaultGuest());

  Future<void> signInAsGuest() async {
    state = await _authService.signInAsGuest();
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = await _authService.signInWithEmail(email, password);
  }

  Future<void> signInWithGoogle() async {
    state = await _authService.signInWithGoogle();
  }

  Future<void> signInWithApple() async {
    state = await _authService.signInWithApple();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = null;
  }
}
