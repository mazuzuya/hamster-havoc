import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'hamster_havoc_data.dart';
import 'hamster_havoc_state.dart';
import 'hamster_havoc_engine.dart';
import 'hamster_havoc_renderer.dart';
import 'hamster_havoc_sprites.dart' as sprites;
import 'hamster_havoc_audio.dart';
import 'hamster_havoc_storage.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final GameEngine engine = GameEngine();
  late final Ticker _ticker;
  double _lastTime = 0;
  bool loaded = false;
  bool started = false;
  bool running = false;
  bool paused = false;
  String shopReturnAction = "idle";
  bool showShop = false;
  bool showResult = false;
  bool showPause = false;
  bool victory = false;
  String shopTab = "weapons";
  String overlayPrompt = "Loading ridges...";
  bool _divePressed = false;
  bool showLevelSelect = false;
  String? _shopNudge;
  Offset? _activePointer;
  Offset? _pointerOrigin;

  final Map<String, sprites.SpriteSheet> _sprites = {};

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      GameAudio.instance.init();
      final progress = await HamsterHavocStorage.loadProgress();
      engine.progress = progress;
      final backyard = await sprites.loadImage('assets/images/backyard_backdrop.webp')
          .then((img) => sprites.SpriteSheet(image: img, byName: {}, animations: {}));
      final player = await sprites.loadSheet('assets/images/player_sprite_sheet-transparent.webp', 'assets/json/player_sprite_sheet-transparent.frames.json');
      final props = await sprites.loadSheet('assets/images/enemy_prop_atlas-transparent.webp', 'assets/json/enemy_prop_atlas-transparent.frames.json');
      final wicons = await sprites.loadSheet('assets/images/weapon_icon_atlas-transparent.webp', 'assets/json/weapon_icon_atlas-transparent.frames.json');
      final skicons = await sprites.loadSheet('assets/images/skin_icon_atlas-transparent.webp', 'assets/json/skin_icon_atlas-transparent.frames.json');
      final effects = await sprites.loadSheet('assets/images/effect_sheet-transparent.webp', 'assets/json/effect_sheet-transparent.frames.json');
      final terrain = await sprites.loadSheet('assets/images/terrain_texture_atlas-transparent.webp', 'assets/json/terrain_texture_atlas-transparent.frames.json');
      final actionUi = await sprites.loadSheet('assets/images/action_ui_atlas-transparent.webp', 'assets/json/action_ui_atlas-transparent.frames.json');
      final advEntities = await sprites.loadSheet('assets/images/advanced_enemy_boss_atlas-transparent.webp', 'assets/json/advanced_enemy_boss_atlas-transparent.frames.json');
      final advTerrain = await sprites.loadSheet('assets/images/advanced_terrain_texture_atlas-transparent.webp', 'assets/json/advanced_terrain_texture_atlas-transparent.frames.json');
      final skinBodies = await sprites.loadSheet('assets/images/player_skin_body_atlas-transparent.webp', 'assets/json/player_skin_body_atlas-transparent.frames.json');
      final cutouts = await sprites.loadSheet('assets/images/weapon_cutout_atlas-transparent.webp', 'assets/json/weapon_cutout_atlas-transparent.frames.json');
      final bossA = await sprites.loadSheet('assets/images/boss_animation_sheet_a-transparent.webp', 'assets/json/boss_animation_sheet_a-transparent.frames.json');
      final bossB = await sprites.loadSheet('assets/images/boss_animation_sheet_b-transparent.webp', 'assets/json/boss_animation_sheet_b-transparent.frames.json');
      final defeatA = await sprites.loadSheet('assets/images/skin_defeat_sheet_a-transparent.webp', 'assets/json/skin_defeat_sheet_a-transparent.frames.json');
      final defeatB = await sprites.loadSheet('assets/images/skin_defeat_sheet_b-transparent.webp', 'assets/json/skin_defeat_sheet_b-transparent.frames.json');

      _sprites["backyard"] = backyard;
      _sprites["player"] = player;
      _sprites["props"] = props;
      _sprites["weapons"] = wicons;
      _sprites["skins"] = skicons;
      _sprites["effects"] = effects;
      _sprites["terrain"] = terrain;
      _sprites["actionUi"] = actionUi;
      _sprites["advancedEntities"] = advEntities;
      _sprites["advancedTerrain"] = advTerrain;
      _sprites["playerSkinBodies"] = skinBodies;
      _sprites["weaponCutouts"] = cutouts;
      _sprites["bossAnimA"] = bossA;
      _sprites["bossAnimB"] = bossB;
      _sprites["defeatAnimA"] = defeatA;
      _sprites["defeatAnimB"] = defeatB;

      setState(() {
        loaded = true;
        overlayPrompt = "Tap to run";
        engine.resize(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
        engine.resetRun(false);
      });
      _pumpFrame();
    } catch (e) {
      setState(() => overlayPrompt = "Asset load failed - tap to retry");
    }
  }

  void _tick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1000000.0;
    final dt = _lastTime == 0 ? 0.0 : min(now - _lastTime, 0.033);
    _lastTime = now;
    if (loaded && running && !paused && started) engine.update(dt);
    if (engine.run != null && running && engine.run!.hp <= 0) {
      _endRun(false);
    }
    if (engine.run?.boss != null && engine.run!.boss!.hp <= 0) {
      engine.defeatBoss();
      if (engine.run!.levelIndex >= biomes.length) {
        _endRun(true);
      }
    }
    setState(() {});
  }

  void _pumpFrame() {
    _ticker.start();
  }

  void _startGame() {
    if (!loaded || started) return;
    setState(() {
      started = true;
      running = true;
      paused = false;
    });
    engine.resetRun(true);
    engine.resize(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    GameAudio.instance.startBgm();
  }

  void _endRun(bool won) {
    if (!running) return;
    final r = engine.run!;
    running = false;
    paused = false;
    victory = won;
    if (!won) r.defeatAt = DateTime.now().millisecondsSinceEpoch / 1000.0;
    engine.progress.bestMeters = max(engine.progress.bestMeters, r.meters);
    engine.progress.seeds += r.seeds;
    engine.progress.peanuts += r.peanuts + (r.meters ~/ 500);
    HamsterHavocStorage.saveProgress(engine.progress);
    GameAudio.instance.stopBgm();
    setState(() => showResult = true);
  }

  void _retry() {
    setState(() {
      showResult = false;
      showPause = false;
      showShop = false;
      running = true;
      paused = false;
    });
    engine.resetRun(true);
    GameAudio.instance.startBgm();
  }

  void _togglePause() {
    if (!started || !running) return;
    setState(() {
      paused = true;
      showPause = true;
    });
    GameAudio.instance.pauseBgm();
  }

  void _continueRun() {
    setState(() {
      paused = false;
      showPause = false;
    });
    GameAudio.instance.resumeBgm();
  }

  void _openShop(String tab) {
    setState(() {
      shopReturnAction = running ? "resume" : started ? "retry" : "idle";
      paused = true;
      showResult = false;
      showPause = false;
      showShop = true;
      shopTab = tab;
    });
  }

  void _closeShop() {
    setState(() {
      showShop = false;
    });
    if (shopReturnAction == "resume") {
      setState(() {
        running = true;
        paused = false;
      });
    } else if (shopReturnAction == "retry") {
      _retry();
    }
  }

  void _buyOrSelect(String id, String tab) {
    final dynamic items = tab == "weapons" ? weapons : skins;
    final dynamic item = items.firstWhere((i) => i.id == id);
    final collection = tab == "weapons" ? engine.progress.weapons : engine.progress.skins;
    final state = collection[id]!;

    if (!state.unlocked) {
      if (engine.progress.seeds < (item.cost as int)) {
        _showNudge("Need ${(item.cost as int) - engine.progress.seeds} more seeds 🌻");
        return;
      }
      engine.progress.seeds -= item.cost as int;
      state.unlocked = true;
      if (tab == "weapons") engine.progress.selectedWeapon = id;
      else engine.progress.selectedSkin = id;
      HamsterHavocStorage.saveProgress(engine.progress);
      GameAudio.instance.play('buy');
    } else if (state.level < 2) {
      if (engine.progress.seeds < (item.upgradeCost as int)) {
        _showNudge("Need ${(item.upgradeCost as int) - engine.progress.seeds} more seeds 🌻");
        return;
      }
      engine.progress.seeds -= item.upgradeCost as int;
      state.level = 2;
      HamsterHavocStorage.saveProgress(engine.progress);
      GameAudio.instance.play('buy');
    } else {
      if (tab == "weapons") engine.progress.selectedWeapon = id;
      else engine.progress.selectedSkin = id;
      HamsterHavocStorage.saveProgress(engine.progress);
      GameAudio.instance.play('click');
    }
    setState(() {});
  }

  void _showNudge(String msg) {
    _shopNudge = msg;
    setState(() {});
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (_shopNudge == msg) setState(() => _shopNudge = null);
    });
  }

  void _debugCoins() {
    engine.progress.seeds = 99999;
    engine.progress.peanuts = 999;
    if (engine.run != null) {
      engine.run!.seeds = max(engine.run!.seeds, 9999);
      engine.run!.labels.add(Label(text: "Test coins on", x: MediaQuery.of(context).size.width * 0.5, y: MediaQuery.of(context).size.height * 0.22, color: "#fff6a7", duration: 0.9));
    }
    setState(() {});
  }

  void _onPointerDown(PointerDownEvent e) {
    if (!running || paused) return;
    _activePointer = e.position;
    _pointerOrigin = e.position;
    if (e.position.dx < MediaQuery.of(context).size.width * 0.5) {
      _divePressed = true;
      engine.jump();
    } else {
      engine.shoot();
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    if (_activePointer != null && _pointerOrigin != null) {
      final dx = e.position.dx - _pointerOrigin!.dx;
      final dy = (e.position.dy - _pointerOrigin!.dy).abs();
      if (dx > 44 && dy < 80) engine.spin();
      _activePointer = null;
      _pointerOrigin = null;
    }
    _divePressed = false;
  }

  void _onKey(KeyEvent e) {
    if (e is KeyDownEvent) {
      if (e.logicalKey == LogicalKeyboardKey.space) engine.jump();
      if (e.logicalKey == LogicalKeyboardKey.arrowDown) _divePressed = true;
      if (e.logicalKey == LogicalKeyboardKey.keyX) engine.shoot();
      if (e.logicalKey == LogicalKeyboardKey.shiftLeft || e.logicalKey == LogicalKeyboardKey.shiftRight) engine.spin();
      if (e.logicalKey == LogicalKeyboardKey.keyP) _togglePause();
    } else if (e is KeyUpEvent) {
      if (e.logicalKey == LogicalKeyboardKey.arrowDown) _divePressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    engine.resize(size.width, size.height);

    return Material(
      type: MaterialType.transparency,
      child: KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: _onKey,
        child: Stack(
          children: [
            // Game canvas
            Listener(
              onPointerDown: _onPointerDown,
              onPointerUp: _onPointerUp,
              onPointerCancel: (_) { _divePressed = false; },
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size(size.width, size.height),
                  painter: GamePainter(engine: engine, sprites: _sprites)
                    ..showPlayer = !(engine.run != null && started && !running && engine.run!.hp <= 0),
                ),
              ),
            ),

          // HUD
          if (loaded && started) _buildHud(size),

          // Shoot button
          if (loaded && started && running) Positioned(
            right: 10,
            bottom: max(100, MediaQuery.of(context).padding.bottom + 94),
            child: GestureDetector(
              onTap: () => engine.shoot(),
              child: Container(
                width: min(size.width * 0.2, 98),
                height: min(size.height * 0.12, 110),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(9, 14, 24, 0.7),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: Center(child: _buildShootIcon())),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        engine.run?.player.reloadTimer != null && engine.run!.player.reloadTimer > 0 ? "RELOAD" : "${engine.run?.player.ammo ?? 0}/${engine.ammoCapacity()}",
                        style: const TextStyle(color: Color(0xFFfff6a7), fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Touch hints
          if (loaded && started && running) Positioned(
            left: 9, right: 9, bottom: max(53, MediaQuery.of(context).padding.bottom + 45),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Left tap/hold", style: TextStyle(color: Colors.white70, fontSize: 11)),
                Text("Button shoot · swipe spin", style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),

          // Start overlay with logo
          if (!started) GestureDetector(
            onTap: loaded ? _startGame : () { _loadAssets(); setState(() => overlayPrompt = "Loading ridges..."); },
            child: Container(
              color: const Color.fromRGBO(5, 12, 20, 0.18),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png',
                      width: min(size.width * 0.6, 300),
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(16, 25, 38, 0.72),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(overlayPrompt, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pause button
          if (loaded && started && running) Positioned(
            top: max(68, MediaQuery.of(context).padding.top + 64),
            right: 10,
            child: GestureDetector(
              onTap: _togglePause,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(16, 25, 38, 0.68),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.pause, color: Colors.white, size: 18),
              ),
            ),
          ),

          // Level select button
          if (loaded && started) Positioned(
            top: max(68, MediaQuery.of(context).padding.top + 64),
            right: running ? 60 : 10,
            child: GestureDetector(
              onTap: () => setState(() => showLevelSelect = !showLevelSelect),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(16, 25, 38, 0.68),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Center(child: Text("Lv", style: TextStyle(color: Color(0xFFfff6a7), fontSize: 11, fontWeight: FontWeight.w900))),
              ),
            ),
          ),

          // Level select panel
          if (showLevelSelect) _buildLevelSelectPanel(size),



          // Mute toggle
          if (loaded && started) Positioned(
            top: max(68, MediaQuery.of(context).padding.top + 64),
            left: 10,
            child: GestureDetector(
              onTap: () { GameAudio.instance.toggleMute(); setState(() {}); },
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(16, 25, 38, 0.68),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Icon(
                  GameAudio.instance.muted ? Icons.volume_off : Icons.volume_up,
                  color: GameAudio.instance.muted ? Colors.white38 : const Color(0xFF7dd3fc),
                  size: 18,
                ),
              ),
            ),
          ),

          // Result panel
          if (showResult) _buildResultPanel(size),

          // Pause panel
          if (showPause) _buildPausePanel(size),

          // Shop panel
          if (showShop) _buildShopPanel(size),

          // HP bar hint - game over shade drawn by painter
        ],
      ),
      ),
    );
  }

  Widget _buildHud(Size size) {
    final r = engine.run;
    final weapon = engine.progress.selectedWeaponDef;
    final skin = engine.progress.selectedSkinDef;
    final biome = r != null ? currentBiome(r) : biomes[0];
    final pct = r != null ? clamp(r.levelMeters / biome.length, 0, 1) : 0.0;

    return SafeArea(
      child: Stack(
        children: [
          // ── TOP-LEFT: Distance + Best ──
          Positioned(
            top: 6, left: 6,
            child: _glassPill(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 4, height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(colors: [Color(0xFF7dd3fc), Color(0xFF38bdf8)]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${r?.meters ?? 0}m", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFfff6a7), height: 1.1)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, size: 10, color: Color(0xFFfbbf24)),
                          const SizedBox(width: 3),
                          Text("${engine.progress.bestMeters}", style: const TextStyle(fontSize: 11, color: Color(0xBBffffff), height: 1.1)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── TOP-RIGHT: HP + Boss HP ──
          Positioned(
            top: 6, right: 6,
            child: _glassPill(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Player HP bar
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, size: 11, color: Color(0xFFef4444)),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 4.5, color: Colors.white12,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: clamp((r?.hp ?? 4) / (r?.maxHp ?? 4), 0, 1),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [const Color(0xFFef4444), const Color(0xFFf87171)]),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text("${r?.hp ?? 4}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFfff6a7))),
                    ],
                  ),
                  if (r?.boss != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("💀", style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 3),
                        SizedBox(
                          width: 70,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              height: 3.5, color: Colors.white10,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: clamp(r!.boss!.hp / r.boss!.maxHp, 0, 1),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)]),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text("${max(0, r!.boss!.hp.ceil())}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFfbbf24))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── TOP-CENTER: Level Progress ──
          if (r != null) Positioned(
            top: 6, left: 0, right: 0,
            child: Center(
              child: _glassPill(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Lv${min(biome.level, 10)}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFfff6a7))),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: min(size.width * 0.22, 130),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          height: 3, color: Colors.white10,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: r.boss != null ? 1 : pct,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [Color(0xFF22c55e), Color(0xFFfde047), Color(0xFFfb923c)]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text("${(pct * 100).round()}%", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFfff6a7))),
                  ],
                ),
              ),
            ),
          ),

          // ── BOTTOM: Weapon + Skin Bar ──
          if (r != null) Positioned(
            left: 6, right: 6, bottom: max(4, MediaQuery.of(context).padding.bottom + 4),
            child: Row(
              children: [
                // Weapon
                Expanded(
                  child: _glassPill(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(colors: [const Color(0xFF38bdf8).withValues(alpha: 0.2), const Color(0xFF0284c7).withValues(alpha: 0.1)]),
                            border: Border.all(color: const Color(0xFF38bdf8).withValues(alpha: 0.3)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildMiniIcon("weapons", weapon.id),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(weapon.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text("Lv${engine.progress.weapons[weapon.id]?.level ?? 1}", style: TextStyle(fontSize: 8, color: Colors.white.withValues(alpha: 0.5))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Skin
                Expanded(
                  child: _glassPill(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(colors: [const Color(0xFFe879f9).withValues(alpha: 0.2), const Color(0xFFa21caf).withValues(alpha: 0.1)]),
                            border: Border.all(color: const Color(0xFFe879f9).withValues(alpha: 0.3)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildMiniIcon("skins", skin.id),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(skin.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text("Lv${engine.progress.skins[skin.id]?.level ?? 1}", style: TextStyle(fontSize: 8, color: Colors.white.withValues(alpha: 0.5))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassPill({required Widget child, EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0x990A0E14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildMiniIcon(String category, String id) {
    final sheet = category == "weapons" ? _sprites["weapons"] : _sprites["skins"];
    final frame = sheet?.byName[id];
    if (frame == null || sheet == null) return const SizedBox.shrink();
    return CustomPaint(
      size: const Size(28, 28),
      painter: _ShopIconPainter(sheet: sheet, frame: frame),
    );
  }

  Widget _hudBox({required Widget child, EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(16, 25, 38, 0.68),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
      ),
      child: child,
    );
  }

  Widget _buildShootIcon() {
    final weapon = engine.progress.selectedWeaponDef;
    final sheet = _sprites["weapons"];
    final frameName = weapon.id;
    final frame = sheet?.byName[frameName];
    if (frame == null || sheet == null) return const SizedBox.shrink();
    return CustomPaint(
      size: const Size(80, 80),
      painter: _ShootIconPainter(sheet: sheet, frame: frame),
    );
  }

  Widget _buildResultPanel(Size size) {
    final r = engine.run!;
    final seedsEarned = r.seeds;
    final peanutsEarned = r.peanuts + (r.meters ~/ 500);
    return Center(
      child: Container(
        width: min(size.width * 0.92, 540),
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: victory ? const Color(0xFFfde047).withValues(alpha: 0.5) : const Color(0xFF7dd3fc).withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(color: (victory ? const Color(0xFFfde047) : const Color(0xFF7dd3fc)).withValues(alpha: 0.18), blurRadius: 48, spreadRadius: -6),
            const BoxShadow(color: Colors.black54, blurRadius: 34, offset: Offset(0, 12)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: (victory ? const Color(0xFFfde047) : const Color(0xFF7dd3fc)).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: (victory ? const Color(0xFFfde047) : const Color(0xFF7dd3fc)).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(victory ? Icons.emoji_events : Icons.flag, size: 14, color: victory ? const Color(0xFFfde047) : const Color(0xFF7dd3fc)),
                  const SizedBox(width: 6),
                  Text(victory ? "GUILD CLEARED" : "RUN COMPLETE",
                    style: TextStyle(color: victory ? const Color(0xFFfde047) : const Color(0xFF7dd3fc), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.4)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Distance hero
            RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900),
                children: [
                  TextSpan(text: "${r.meters}", style: const TextStyle(fontSize: 56, color: Color(0xFFfff6a7))),
                  const TextSpan(text: "m", style: TextStyle(fontSize: 28, color: Colors.white54)),
                ],
              ),
            ),
            if (!victory) Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text("Best: ${max(engine.progress.bestMeters, r.meters)}m",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 18),
            // Rewards row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Row(
                children: [
                  Expanded(child: _rewardChip(
                    icon: const Text("🌻", style: TextStyle(fontSize: 24)),
                    value: "+$seedsEarned",
                    label: "Seeds",
                    accent: const Color(0xFFfde047),
                  )),
                  Container(width: 1, height: 38, color: Colors.white.withValues(alpha: 0.08)),
                  Expanded(child: _rewardChip(
                    icon: const Text("🥜", style: TextStyle(fontSize: 20)),
                    value: "+$peanutsEarned",
                    label: "Peanuts",
                    accent: const Color(0xFFfbbf24),
                  )),
                  Container(width: 1, height: 38, color: Colors.white.withValues(alpha: 0.08)),
                  Expanded(child: _rewardChip(
                    icon: const Icon(Icons.emoji_events, size: 20, color: Color(0xFFfbbf24)),
                    value: "${r.kills}",
                    label: "Kills",
                    accent: const Color(0xFFfb923c),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _premiumButton(
                  label: "Retry",
                  icon: Icons.refresh,
                  primary: true,
                  onTap: _retry,
                ),
                const SizedBox(width: 10),
                _premiumButton(
                  label: "Armory",
                  icon: Icons.storefront,
                  primary: false,
                  onTap: () => _openShop("weapons"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rewardChip({required Widget icon, required String value, required String label, required Color accent}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w900, height: 1.1)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
      ],
    );
  }

  Widget _premiumButton({required String label, required IconData icon, required bool primary, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          gradient: primary
            ? const LinearGradient(colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)])
            : LinearGradient(colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.04)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primary ? const Color(0xFFFfde047).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.12), width: 1.2),
          boxShadow: primary ? [BoxShadow(color: const Color(0xFFf59e0b).withValues(alpha: 0.35), blurRadius: 16, spreadRadius: -2)] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: primary ? const Color(0xFF301d05) : Colors.white),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(
              color: primary ? const Color(0xFF301d05) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPausePanel(Size size) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: const Color.fromRGBO(5, 12, 20, 0.36),
        child: Center(
          child: Container(
            width: min(size.width * 0.8, 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(12, 20, 32, 0.96),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Paused", style: TextStyle(color: Color(0xFFa7f3d0), fontSize: 12, letterSpacing: 2)),
                Text("${engine.run?.meters ?? 0}m", style: const TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: Color(0xFFfff6a7))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: _continueRun, style: _btnStyle(), child: const Text("Continue")),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () => _openShop("weapons"), style: _btnStyle(ghost: true), child: const Text("Armory")),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _retry, style: _btnStyle(), child: const Text("Retry")),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _btnStyle({bool ghost = false}) {
    return ElevatedButton.styleFrom(
      backgroundColor: ghost ? Colors.white12 : const Color(0xFFf59e0b),
      foregroundColor: ghost ? Colors.white : const Color(0xFF301d05),
      shape: const StadiumBorder(),
    );
  }

  Widget _buildShopPanel(Size size) {
    final List<dynamic> items = shopTab == "weapons" ? weapons : skins;
    final collection = shopTab == "weapons" ? engine.progress.weapons : engine.progress.skins;
    final sheet = shopTab == "weapons" ? _sprites["weapons"] : _sprites["skins"];
    final isWeapons = shopTab == "weapons";

    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: min(size.width * 0.95, 820),
            height: size.height * 0.72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isWeapons ? const Color(0xFF7dd3fc).withValues(alpha: 0.3) : const Color(0xFFf0abfc).withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(color: (isWeapons ? const Color(0xFF7dd3fc) : const Color(0xFFf0abfc)).withValues(alpha: 0.15), blurRadius: 40, spreadRadius: -5),
                BoxShadow(color: Colors.black54, blurRadius: 30, offset: const Offset(0, 10)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isWeapons ? [const Color(0xFF7dd3fc).withValues(alpha: 0.15), Colors.transparent] : [const Color(0xFFf0abfc).withValues(alpha: 0.15), Colors.transparent],
                      ),
                      border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                    ),
                    child: Row(
                      children: [
                        // Currency
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("${engine.progress.seeds}", style: const TextStyle(color: Color(0xFFfff6a7), fontSize: 18, fontWeight: FontWeight.w900)),
                              const SizedBox(width: 4),
                              const Text("🌻", style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 12),
                              Text("${engine.progress.peanuts}", style: const TextStyle(color: Color(0xFFfbbf24), fontSize: 16, fontWeight: FontWeight.w900)),
                              const SizedBox(width: 4),
                              const Text("🥜", style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _closeShop,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text("Close", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                  // Tab bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        _tabButton("⚔️  Weapons", "weapons"),
                        const SizedBox(width: 8),
                        _tabButton("🎭  Skins", "skins"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Nudge notification
                  if (_shopNudge != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: AnimatedOpacity(
                        opacity: _shopNudge != null ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFef4444).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_shopNudge!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),

                  // Items grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.86,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final state = collection[item.id]!;
                          final selected = isWeapons ? engine.progress.selectedWeapon == item.id : engine.progress.selectedSkin == item.id;
                          final unlocked = state.unlocked;
                          final level = state.level;
                          String action = "";
                          bool disabled = false;
                          if (!unlocked) { action = "${item.cost}"; }
                          else if (level < 2) { action = "${item.upgradeCost}"; }
                          else if (selected) { action = "✓"; disabled = true; }
                          else { action = "Equip"; }

                          final bool isMaxLevel = unlocked && level >= 2 && selected;
                          final accent = isWeapons ? const Color(0xFF7dd3fc) : const Color(0xFFf0abfc);

                          return GestureDetector(
                            onTap: disabled ? null : () => _buyOrSelect(item.id, shopTab),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: selected
                                    ? [accent.withValues(alpha: 0.2), accent.withValues(alpha: 0.05)]
                                    : [Colors.white.withValues(alpha: 0.06), Colors.white.withValues(alpha: 0.02)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected ? accent.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.08),
                                  width: selected ? 1.5 : 1,
                                ),
                                boxShadow: selected ? [
                                  BoxShadow(color: accent.withValues(alpha: 0.2), blurRadius: 12, spreadRadius: -2),
                                ] : null,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        // Item icon
                                        Container(
                                          width: 44, height: 44,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: unlocked
                                                ? [accent.withValues(alpha: 0.15), accent.withValues(alpha: 0.05)]
                                                : [Colors.white.withValues(alpha: 0.04), Colors.transparent],
                                            ),
                                            border: Border.all(color: accent.withValues(alpha: unlocked ? 0.25 : 0.05)),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: sheet != null && sheet.byName.containsKey(item.id)
                                              ? CustomPaint(
                                                  size: const Size(44, 44),
                                                  painter: _ShopIconPainter(sheet: sheet, frame: sheet.byName[item.id]!, locked: !unlocked),
                                                )
                                              : null,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // Name + trait
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.name,
                                                style: TextStyle(
                                                  color: selected ? const Color(0xFFfff6a7) : Colors.white.withValues(alpha: unlocked ? 0.95 : 0.5),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -0.2,
                                                ),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              // Level stars
                                              if (unlocked) Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.star, size: 12, color: level >= 1 ? const Color(0xFFfbbf24) : Colors.white24),
                                                  const SizedBox(width: 2),
                                                  Icon(Icons.star, size: 12, color: level >= 2 ? const Color(0xFFfbbf24) : Colors.white24),
                                                ],
                                              ),
                                              if (!unlocked)
                                                Text(item.trait, style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    // Trait text + buy button row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            level == 2 ? item.level2 : item.trait,
                                            style: TextStyle(color: Colors.white.withValues(alpha: unlocked ? 0.6 : 0.3), fontSize: 9),
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          height: 28,
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            gradient: disabled ? null : LinearGradient(
                                              colors: isWeapons ? [const Color(0xFF38bdf8), const Color(0xFF0284c7)] : [const Color(0xFFe879f9), const Color(0xFFa21caf)],
                                            ),
                                            color: disabled ? Colors.white.withValues(alpha: 0.06) : null,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: disabled ? Colors.white.withValues(alpha: 0.08) : Colors.transparent),
                                          ),
                                          child: Center(
                                            child: Text(
                                              action,
                                              style: TextStyle(
                                                color: disabled ? Colors.white.withValues(alpha: 0.3) : Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String label, String tab) {
    final active = shopTab == tab;
    final isWeapons = tab == "weapons";
    final accent = isWeapons ? const Color(0xFF38bdf8) : const Color(0xFFe879f9);
    return GestureDetector(
      onTap: () => setState(() => shopTab = tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          gradient: active ? LinearGradient(colors: [accent, accent.withValues(alpha: 0.6)]) : null,
          color: active ? null : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? accent.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildLevelSelectPanel(Size size) {
    return Positioned(
      top: max(115, MediaQuery.of(context).padding.top + 110),
      right: 10,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(12, 20, 32, 0.96),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Level", style: TextStyle(color: Color(0xFFfff6a7), fontSize: 13, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            ...biomes.map((b) => GestureDetector(
              onTap: () {
                engine.jumpToLevel(b.level - 1);
                setState(() {
                  showLevelSelect = false;
                  running = true;
                  paused = false;
                  started = true;
                  showResult = false;
                  showPause = false;
                  showShop = false;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: engine.run != null && engine.run!.levelIndex == b.level - 1 ? const Color(0xFFfacc15).withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: b.color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text("Lv${b.level} ${b.name}", style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    GameAudio.instance.dispose();
    super.dispose();
  }
}

class _ShootIconPainter extends CustomPainter {
  final sprites.SpriteSheet sheet;
  final sprites.Frame frame;

  _ShootIconPainter({required this.sheet, required this.frame});

  @override
  void paint(Canvas canvas, Size size) {
    final crop = frame.content;
    final scaleX = size.width / frame.source.width;
    final scaleY = size.height / frame.source.height;
    canvas.drawImageRect(
      sheet.image,
      Rect.fromLTWH(crop.left, crop.top, crop.width, crop.height),
      Rect.fromLTWH(
        (crop.left - frame.source.left) * scaleX + 10,
        (crop.top - frame.source.top) * scaleY + 10,
        crop.width * scaleX * 0.75,
        crop.height * scaleY * 0.75,
      ),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ShopIconPainter extends CustomPainter {
  final sprites.SpriteSheet sheet;
  final sprites.Frame frame;
  final bool locked;

  _ShopIconPainter({required this.sheet, required this.frame, this.locked = false});

  @override
  void paint(Canvas canvas, Size size) {
    final crop = frame.content;
    canvas.drawImageRect(
      sheet.image,
      Rect.fromLTWH(crop.left, crop.top, crop.width, crop.height),
      Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
      Paint()..color = locked ? Colors.white.withValues(alpha: 0.55) : Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
