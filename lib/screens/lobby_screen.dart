import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/hamster_havoc_audio.dart';
import '../game/hamster_havoc_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await GameAudio.instance.init();
    await GameAudio.instance.startBgm();
    if (mounted) setState(() => _ready = true);
  }

  void _enterGame() {
    if (!_ready) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _enterGame,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/lobby.png',
                fit: BoxFit.fitHeight,
              ),
            ),
            if (!_ready)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFfff6a7),
                ),
              ),

          ],
        ),
      ),
    );
  }
}
