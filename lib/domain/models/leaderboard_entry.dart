class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final String avatarUrl;
  final String country;
  final int eloRating;
  final int gamesWon;
  final int winStreak;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.country,
    required this.eloRating,
    required this.gamesWon,
    required this.winStreak,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['userId'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      country: json['country'] as String? ?? 'Global',
      eloRating: json['eloRating'] as int? ?? 1200,
      gamesWon: json['gamesWon'] as int? ?? 0,
      winStreak: json['winStreak'] as int? ?? 0,
    );
  }
}
