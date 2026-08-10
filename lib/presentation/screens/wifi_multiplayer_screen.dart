import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/engine/chess_piece.dart';
import '../../domain/models/game_session.dart';
import '../../providers/auth_provider.dart';
import '../../providers/multiplayer_provider.dart';
import '../widgets/glass_card.dart';
import 'game_screen.dart';

class WifiMultiplayerScreen extends ConsumerStatefulWidget {
  const WifiMultiplayerScreen({super.key});

  @override
  ConsumerState<WifiMultiplayerScreen> createState() => _WifiMultiplayerScreenState();
}

class _WifiMultiplayerScreenState extends ConsumerState<WifiMultiplayerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _manualIpController = TextEditingController();
  bool _isHosting = false;
  String? _hostIp;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _startHosting() async {
    final user = ref.read(authProvider);
    final ip = await ref.read(multiplayerProvider.notifier).startLanHost(user?.username ?? 'Host_Player');
    setState(() {
      _isHosting = true;
      _hostIp = ip ?? '192.168.1.100';
    });

    // Listen for client connection
    final lanService = ref.read(lanServiceProvider);
    lanService.onConnectionStatus.listen((connected) {
      if (connected && mounted) {
        final session = GameSession(
          id: 'lan_session_${DateTime.now().millisecondsSinceEpoch}',
          gameType: GameType.wifiLan,
          timerMode: TimerMode.tenMin,
          playerWhiteName: user?.username ?? 'Host Player',
          playerBlackName: 'LAN Opponent',
          hostIp: _hostIp,
          userColor: PieceColor.white,
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => GameScreen(session: session)),
        );
      }
    });
  }

  void _connectToHost(String ip) async {
    final user = ref.read(authProvider);
    final success = await ref.read(multiplayerProvider.notifier).connectLan(ip);

    if (success && mounted) {
      final session = GameSession(
        id: 'lan_session_${DateTime.now().millisecondsSinceEpoch}',
        gameType: GameType.wifiLan,
        timerMode: TimerMode.tenMin,
        playerWhiteName: 'LAN Host',
        playerBlackName: user?.username ?? 'Guest Player',
        hostIp: ip,
        userColor: PieceColor.black,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GameScreen(session: session)),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _manualIpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.read(multiplayerProvider.notifier).discoverLanGames();
    final mpState = ref.watch(multiplayerProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('WiFi / Local LAN Match', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.wifi_tethering), text: 'Host Game'),
            Tab(icon: Icon(Icons.search), text: 'Join Game'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Host Tab
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isHosting) ...[
                  const Icon(Icons.router, size: 72, color: AppColors.primaryGold),
                  const SizedBox(height: 16),
                  const Text(
                    'Host a Local Network Game',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Other players on the same Wi-Fi network will see your room automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _startHosting,
                      icon: const Icon(Icons.play_arrow, color: Colors.black),
                      label: const Text('START HOSTING SERVER', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ] else ...[
                  const SpinKitPulse(color: AppColors.primaryGold, size: 80),
                  const SizedBox(height: 24),
                  const Text(
                    'Broadcasting LAN Host Signal...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Host IP: ${_hostIp ?? "192.168.1.100"}',
                    style: const TextStyle(fontSize: 16, color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Waiting for opponent to connect...',
                    style: TextStyle(color: AppColors.textSecondaryDark),
                  ),
                ],
              ],
            ),
          ),

          // Join Tab
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEARBY LAN HOSTS',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: mpState.lanHosts.isEmpty
                      ? const GlassCard(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SpinKitFadingCircle(color: AppColors.primaryGold, size: 36),
                                SizedBox(height: 16),
                                Text(
                                  'Scanning local Wi-Fi subnet...',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Ensure opponent has started hosting',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: mpState.lanHosts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, index) {
                            final host = mpState.lanHosts[index];
                            return GlassCard(
                              onTap: () => _connectToHost(host.ip),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(Icons.wifi, color: AppColors.primaryGold),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          host.hostName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                        ),
                                        Text(
                                          'IP: ${host.ip}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 16),

                // Manual IP Input
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualIpController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Enter Host IP (e.g. 192.168.1.50)',
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.login, color: AppColors.primaryGold),
                        onPressed: () {
                          if (_manualIpController.text.isNotEmpty) {
                            _connectToHost(_manualIpController.text.trim());
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
