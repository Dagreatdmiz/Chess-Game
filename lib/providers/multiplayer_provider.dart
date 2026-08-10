import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/game_session.dart';
import '../services/firestore_service.dart';
import '../services/lan_multiplayer_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final lanServiceProvider = Provider<LanMultiplayerService>((ref) => LanMultiplayerService());

class MultiplayerState {
  final bool isSearchingMatch;
  final String? roomCode;
  final String? hostIp;
  final List<LanHostInfo> lanHosts;
  final bool isLanConnected;

  const MultiplayerState({
    this.isSearchingMatch = false,
    this.roomCode,
    this.hostIp,
    this.lanHosts = const [],
    this.isLanConnected = false,
  });

  MultiplayerState copyWith({
    bool? isSearchingMatch,
    String? roomCode,
    String? hostIp,
    List<LanHostInfo>? lanHosts,
    bool? isLanConnected,
  }) {
    return MultiplayerState(
      isSearchingMatch: isSearchingMatch ?? this.isSearchingMatch,
      roomCode: roomCode ?? this.roomCode,
      hostIp: hostIp ?? this.hostIp,
      lanHosts: lanHosts ?? this.lanHosts,
      isLanConnected: isLanConnected ?? this.isLanConnected,
    );
  }
}

final multiplayerProvider = StateNotifierProvider<MultiplayerNotifier, MultiplayerState>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  final lan = ref.watch(lanServiceProvider);
  return MultiplayerNotifier(firestore, lan);
});

class MultiplayerNotifier extends StateNotifier<MultiplayerState> {
  final FirestoreService _firestore;
  final LanMultiplayerService _lan;

  MultiplayerNotifier(this._firestore, this._lan) : super(const MultiplayerState());

  void startMatchmaking() {
    state = state.copyWith(isSearchingMatch: true);
  }

  void cancelMatchmaking() {
    state = state.copyWith(isSearchingMatch: false);
  }

  Future<GameSession> createRoomCode(String hostName, TimerMode timerMode) async {
    final session = await _firestore.createPrivateRoom(hostName: hostName, timerMode: timerMode);
    state = state.copyWith(roomCode: session.roomCode);
    return session;
  }

  Future<GameSession?> joinRoomCode(String code, String guestName) async {
    return await _firestore.joinPrivateRoom(roomCode: code, guestName: guestName);
  }

  Future<String?> startLanHost(String hostName) async {
    final ip = await _lan.startHost(hostName);
    state = state.copyWith(hostIp: ip);
    return ip;
  }

  void discoverLanGames() {
    _lan.discoverLanHosts().listen((hosts) {
      state = state.copyWith(lanHosts: hosts);
    });
  }

  Future<bool> connectLan(String ip) async {
    final success = await _lan.connectToHost(ip);
    state = state.copyWith(isLanConnected: success);
    return success;
  }
}
