class PlayerProfile {
  final String id;
  final String username;
  final String email;
  final String avatarUrl;
  final String country;
  final int currentRating;
  final int highestRating;
  final int gamesPlayed;
  final int gamesWon;
  final int gamesLost;
  final int draws;
  final String favoriteOpening;
  final Duration totalPlayTime;
  final List<String> achievements;
  final List<String> friends;
  final bool isGuest;

  const PlayerProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.country,
    this.currentRating = 1200,
    this.highestRating = 1200,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.draws = 0,
    this.favoriteOpening = 'Ruy Lopez',
    this.totalPlayTime = Duration.zero,
    this.achievements = const ['First Victory', 'Academy Beginner'],
    this.friends = const [],
    this.isGuest = false,
  });

  double get winPercentage => gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0.0;

  PlayerProfile copyWith({
    String? username,
    String? email,
    String? avatarUrl,
    String? country,
    int? currentRating,
    int? highestRating,
    int? gamesPlayed,
    int? gamesWon,
    int? gamesLost,
    int? draws,
    String? favoriteOpening,
    Duration? totalPlayTime,
    List<String>? achievements,
    List<String>? friends,
    bool? isGuest,
  }) {
    return PlayerProfile(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      country: country ?? this.country,
      currentRating: currentRating ?? this.currentRating,
      highestRating: highestRating ?? this.highestRating,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      draws: draws ?? this.draws,
      favoriteOpening: favoriteOpening ?? this.favoriteOpening,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      achievements: achievements ?? this.achievements,
      friends: friends ?? this.friends,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  factory PlayerProfile.defaultGuest() {
    return const PlayerProfile(
      id: 'guest_101',
      username: 'GrandmasterGuest',
      email: 'guest@chessmaster.com',
      avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=ChessMaster',
      country: 'United States',
      currentRating: 1250,
      highestRating: 1310,
      gamesPlayed: 14,
      gamesWon: 9,
      gamesLost: 3,
      draws: 2,
      isGuest: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'country': country,
      'currentRating': currentRating,
      'highestRating': highestRating,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'draws': draws,
      'favoriteOpening': favoriteOpening,
      'totalPlayTimeSeconds': totalPlayTime.inSeconds,
      'achievements': achievements,
      'friends': friends,
      'isGuest': isGuest,
    };
  }

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
      country: json['country'] as String,
      currentRating: json['currentRating'] as int? ?? 1200,
      highestRating: json['highestRating'] as int? ?? 1200,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      gamesLost: json['gamesLost'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      favoriteOpening: json['favoriteOpening'] as String? ?? 'Ruy Lopez',
      totalPlayTime: Duration(seconds: json['totalPlayTimeSeconds'] as int? ?? 0),
      achievements: List<String>.from(json['achievements'] ?? []),
      friends: List<String>.from(json['friends'] ?? []),
      isGuest: json['isGuest'] as bool? ?? false,
    );
  }
}
