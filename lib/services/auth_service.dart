import '../domain/models/player_profile.dart';

class AuthService {
  PlayerProfile? _currentUser;

  PlayerProfile? get currentUser => _currentUser;

  Future<PlayerProfile> signInAsGuest() async {
    _currentUser = PlayerProfile.defaultGuest();
    return _currentUser!;
  }

  Future<PlayerProfile> signInWithEmail(String email, String password) async {
    // Firebase Auth integration point + offline fallback session
    final username = email.contains('@') ? email.split('@')[0] : 'Player';
    _currentUser = PlayerProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      username: username.toUpperCase(),
      email: email,
      avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=$username',
      country: 'United States',
      currentRating: 1200,
    );
    return _currentUser!;
  }

  Future<PlayerProfile> signInWithGoogle() async {
    _currentUser = const PlayerProfile(
      id: 'google_usr_99',
      username: 'GrandmasterGoogle',
      email: 'user.google@chessmaster.com',
      avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=GoogleChess',
      country: 'Global',
      currentRating: 1350,
      highestRating: 1400,
    );
    return _currentUser!;
  }

  Future<PlayerProfile> signInWithApple() async {
    _currentUser = const PlayerProfile(
      id: 'apple_usr_88',
      username: 'GrandmasterApple',
      email: 'user.apple@chessmaster.com',
      avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=AppleChess',
      country: 'United States',
      currentRating: 1300,
    );
    return _currentUser!;
  }

  Future<void> signOut() async {
    _currentUser = null;
  }
}
