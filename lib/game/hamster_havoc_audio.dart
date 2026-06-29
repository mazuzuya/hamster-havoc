import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class GameAudio {
  GameAudio._();
  static final GameAudio instance = GameAudio._();

  static const int _rate = 22050;
  final Map<String, Uint8List> _cache = {};
  AudioPlayer? _bgmPlayer;
  bool muted = false;
  double volume = 0.45;
  double bgmVolume = 0.35;
  bool _ready = false;
  bool _bgmPlaying = false;

  final Random _rng = Random(42);

  static const List<String> _assetSounds = [
    'dash',
    'shoot_seed_gatling',
    'shoot_walnut_cannon',
    'shoot_laser_pointer',
    'shoot_carrot_missile',
    'shoot_cheese_thrower',
    'shoot_peanut_splat',
    'shoot_boomerang_twig',
    'shoot_sonic_squeak',
    'shoot_melon_sniper',
    'shoot_corn_cob',
    'boss_shoot',
    'hit',
    'enemyDie',
    'bossHit',
    'playerHurt',
    'pickup',
    'reload',
    'bossDefeat',
    'levelUp',
    'buy',
    'click',
    'jump',
  ];

  AudioContext _noFocusContext() => AudioContext(
    android: AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: false,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {AVAudioSessionOptions.mixWithOthers},
    ),
  );

  Future<void> init() async {
    if (_ready) return;
    await AudioPlayer.global.setAudioContext(_noFocusContext());
    await _loadAllAssets();
    _generateFallbacks();
    _ready = true;
  }

  Future<void> _loadAllAssets() async {
    for (final name in _assetSounds) {
      try {
        final data = await rootBundle.load('assets/audio/$name.wav');
        _cache[name] = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      } catch (_) {}
    }
  }

  void _generateFallbacks() {
    if (!_cache.containsKey('dash')) _cache['dash'] = _wrap(_sfxDash());
    if (!_cache.containsKey('shoot_seed_gatling')) _cache['shoot_seed_gatling'] = _wrap(_sfxSeedGatling());
    if (!_cache.containsKey('shoot_walnut_cannon')) _cache['shoot_walnut_cannon'] = _wrap(_sfxWalnutCannon());
    if (!_cache.containsKey('shoot_laser_pointer')) _cache['shoot_laser_pointer'] = _wrap(_sfxLaserPointer());
    if (!_cache.containsKey('shoot_carrot_missile')) _cache['shoot_carrot_missile'] = _wrap(_sfxCarrotMissile());
    if (!_cache.containsKey('shoot_cheese_thrower')) _cache['shoot_cheese_thrower'] = _wrap(_sfxCheeseThrower());
    if (!_cache.containsKey('shoot_peanut_splat')) _cache['shoot_peanut_splat'] = _wrap(_sfxPeanutSplat());
    if (!_cache.containsKey('shoot_boomerang_twig')) _cache['shoot_boomerang_twig'] = _wrap(_sfxBoomerangTwig());
    if (!_cache.containsKey('shoot_sonic_squeak')) _cache['shoot_sonic_squeak'] = _wrap(_sfxSonicSqueak());
    if (!_cache.containsKey('shoot_melon_sniper')) _cache['shoot_melon_sniper'] = _wrap(_sfxMelonSniper());
    if (!_cache.containsKey('shoot_corn_cob')) _cache['shoot_corn_cob'] = _wrap(_sfxCornCob());
    if (!_cache.containsKey('boss_shoot')) _cache['boss_shoot'] = _wrap(_sfxBossShoot());
    if (!_cache.containsKey('hit')) _cache['hit'] = _wrap(_sfxHit());
    if (!_cache.containsKey('enemyDie')) _cache['enemyDie'] = _wrap(_sfxEnemyDie());
    if (!_cache.containsKey('bossHit')) _cache['bossHit'] = _wrap(_sfxBossHit());
    if (!_cache.containsKey('playerHurt')) _cache['playerHurt'] = _wrap(_sfxPlayerHurt());
    if (!_cache.containsKey('pickup')) _cache['pickup'] = _wrap(_sfxPickup());
    if (!_cache.containsKey('reload')) _cache['reload'] = _wrap(_sfxReload());
    if (!_cache.containsKey('bossDefeat')) _cache['bossDefeat'] = _wrap(_sfxBossDefeat());
    if (!_cache.containsKey('levelUp')) _cache['levelUp'] = _wrap(_sfxLevelUp());
    if (!_cache.containsKey('buy')) _cache['buy'] = _wrap(_sfxBuy());
    if (!_cache.containsKey('click')) _cache['click'] = _wrap(_sfxClick());
    if (!_cache.containsKey('jump')) _cache['jump'] = _wrap(_sfxJump());
  }

  Future<void> play(String name) async {
    if (muted || !_ready) return;
    try {
      final player = AudioPlayer();
      player.setAudioContext(_noFocusContext());
      await player.setVolume(volume);
      await player.play(AssetSource('audio/$name.wav'));
      player.onPlayerComplete.listen((_) { player.dispose(); }, onError: (_) { player.dispose(); });
    } catch (e) {
      debugPrint('SFX error ($name): $e');
    }
  }

  Future<void> playShoot(String weaponId) async => play('shoot_$weaponId');
  Future<void> playBossShoot() async => play('boss_shoot');
  Future<void> playDash() async => play('dash');

  Future<void> startBgm() async {
    if (!_ready || muted || _bgmPlaying) return;
    try {
      if (_bgmPlayer == null) {
        _bgmPlayer = AudioPlayer();
        _bgmPlayer!.setAudioContext(_noFocusContext());
        await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
        await _bgmPlayer!.setVolume(bgmVolume);
      }
      await _bgmPlayer!.play(AssetSource('audio/bgm.mp3'));
      _bgmPlaying = true;
    } catch (e) {
      debugPrint('BGM play error: $e');
    }
  }

  Future<void> stopBgm() async {
    if (!_bgmPlaying) return;
    try { await _bgmPlayer?.stop(); _bgmPlaying = false; } catch (_) {}
  }

  Future<void> pauseBgm() async {
    try { await _bgmPlayer?.pause(); } catch (_) {}
  }

  Future<void> resumeBgm() async {
    if (muted) return;
    try { await _bgmPlayer?.resume(); } catch (_) {}
  }

  Future<void> setVolume(double v) async { volume = v; }
  Future<void> setBgmVolume(double v) async { bgmVolume = v; if (_bgmPlayer != null) { try { await _bgmPlayer!.setVolume(v); } catch (_) {} } }

  Future<void> setMuted(bool m) async {
    muted = m;
    if (m) { await stopBgm(); } else { await resumeBgm(); }
  }

  void toggleMute() { setMuted(!muted); }

  Future<void> dispose() async {
    await stopBgm();
    if (_bgmPlayer != null) { try { await _bgmPlayer!.dispose(); } catch (_) {} }
    _ready = false;
  }

  Uint8List _wrap(Int16List samples) {
    final dataSize = samples.length * 2;
    final buf = ByteData(44 + dataSize);
    buf.setUint8(0, 0x52); buf.setUint8(1, 0x49); buf.setUint8(2, 0x46); buf.setUint8(3, 0x46);
    buf.setUint32(4, 36 + dataSize, Endian.little);
    buf.setUint8(8, 0x57); buf.setUint8(9, 0x41); buf.setUint8(10, 0x56); buf.setUint8(11, 0x45);
    buf.setUint8(12, 0x66); buf.setUint8(13, 0x6D); buf.setUint8(14, 0x74); buf.setUint8(15, 0x20);
    buf.setUint32(16, 16, Endian.little);
    buf.setUint16(20, 1, Endian.little); buf.setUint16(22, 1, Endian.little);
    buf.setUint32(24, _rate, Endian.little); buf.setUint32(28, _rate * 2, Endian.little);
    buf.setUint16(32, 2, Endian.little); buf.setUint16(34, 16, Endian.little);
    buf.setUint8(36, 0x64); buf.setUint8(37, 0x61); buf.setUint8(38, 0x74); buf.setUint8(39, 0x61);
    buf.setUint32(40, dataSize, Endian.little);
    for (int i = 0; i < samples.length; i++) { buf.setInt16(44 + i * 2, samples[i], Endian.little); }
    return buf.buffer.asUint8List();
  }

  double _wave(double phase, String type) {
    switch (type) {
      case 'sine': return sin(phase);
      case 'square': return sin(phase) >= 0 ? 1.0 : -1.0;
      case 'saw': return ((phase / (2 * pi)) % 1.0) * 2.0 - 1.0;
      case 'noise': return _rng.nextDouble() * 2.0 - 1.0;
      default: return sin(phase);
    }
  }

  Int16List _sweep(double duration, double fStart, double fEnd, {String wave = 'sine', double decay = 0.05, double vol = 0.5, double attack = 0.003, double noiseMix = 0.0}) {
    final n = (duration * _rate).toInt();
    final out = Int16List(n);
    double phase = 0;
    for (int i = 0; i < n; i++) {
      final t = i / _rate;
      final prog = i / n;
      final freq = fStart + (fEnd - fStart) * prog;
      phase += 2 * pi * freq / _rate;
      double s = _wave(phase, wave);
      if (noiseMix > 0) s = s * (1 - noiseMix) + _wave(0, 'noise') * noiseMix;
      final env = t < attack ? t / attack : exp(-t / decay);
      out[i] = (s * env * vol * 32767).clamp(-32768, 32767).toInt();
    }
    return out;
  }

  Int16List _tone(double duration, double freq, {String wave = 'sine', double decay = 0.05, double vol = 0.5, double attack = 0.003}) =>
    _sweep(duration, freq, freq, wave: wave, decay: decay, vol: vol, attack: attack);

  Int16List _arpeggio(double duration, List<double> freqs, {String wave = 'square', double decay = 0.06, double vol = 0.4}) {
    final n = (duration * _rate).toInt();
    final out = Int16List(n);
    final segLen = n ~/ freqs.length;
    double phase = 0;
    for (int i = 0; i < n; i++) {
      final seg = (i ~/ segLen).clamp(0, freqs.length - 1);
      final freq = freqs[seg];
      final localT = (i % segLen) / _rate;
      phase += 2 * pi * freq / _rate;
      double s = _wave(phase, wave);
      final env = localT < 0.003 ? localT / 0.003 : exp(-localT / decay);
      out[i] = (s * env * vol * 32767).clamp(-32768, 32767).toInt();
    }
    return out;
  }

  Int16List _concat(List<Int16List> parts) {
    int total = 0;
    for (final p in parts) { total += p.length; }
    final out = Int16List(total);
    int off = 0;
    for (final p in parts) { out.setRange(off, off + p.length, p); off += p.length; }
    return out;
  }

  Int16List _sfxDash() => _sweep(0.28, 220, 680, wave: 'saw', decay: 0.08, vol: 0.45, noiseMix: 0.12);
  Int16List _sfxSeedGatling() => _sweep(0.055, 1400, 600, wave: 'square', decay: 0.018, vol: 0.38, noiseMix: 0.08);
  Int16List _sfxWalnutCannon() => _concat([_sweep(0.04, 120, 60, wave: 'square', decay: 0.015, vol: 0.5), _sweep(0.18, 180, 30, wave: 'noise', decay: 0.09, vol: 0.45)]);
  Int16List _sfxLaserPointer() => _sweep(0.12, 2200, 1800, wave: 'sine', decay: 0.04, vol: 0.42);
  Int16List _sfxCarrotMissile() => _concat([_sweep(0.08, 180, 420, wave: 'saw', decay: 0.03, vol: 0.4), _sweep(0.06, 0, 0, wave: 'noise', decay: 0.02, vol: 0.35)]);
  Int16List _sfxCheeseThrower() => _concat([_sweep(0.03, 600, 300, wave: 'noise', decay: 0.012, vol: 0.3), _sweep(0.08, 400, 200, wave: 'saw', decay: 0.03, vol: 0.25)]);
  Int16List _sfxPeanutSplat() => _concat([_sweep(0.04, 200, 80, wave: 'square', decay: 0.015, vol: 0.45), _sweep(0.1, 0, 0, wave: 'noise', decay: 0.04, vol: 0.4)]);
  Int16List _sfxBoomerangTwig() => _sweep(0.15, 380, 520, wave: 'saw', decay: 0.06, vol: 0.38);
  Int16List _sfxSonicSqueak() => _sweep(0.2, 800, 400, wave: 'sine', decay: 0.07, vol: 0.4, noiseMix: 0.05);
  Int16List _sfxMelonSniper() => _concat([_tone(0.02, 1600, wave: 'square', decay: 0.008, vol: 0.35), _sweep(0.12, 900, 200, wave: 'saw', decay: 0.05, vol: 0.38)]);
  Int16List _sfxCornCob() => _sweep(0.07, 700, 350, wave: 'square', decay: 0.025, vol: 0.35, noiseMix: 0.1);
  Int16List _sfxBossShoot() => _concat([_tone(0.06, 160, wave: 'square', decay: 0.02, vol: 0.5), _sweep(0.15, 200, 80, wave: 'saw', decay: 0.06, vol: 0.45, noiseMix: 0.15)]);
  Int16List _sfxHit() => _sweep(0.06, 0, 0, wave: 'noise', decay: 0.018, vol: 0.4);
  Int16List _sfxEnemyDie() => _sweep(0.16, 420, 70, wave: 'square', decay: 0.06, vol: 0.45, noiseMix: 0.15);
  Int16List _sfxBossHit() => _tone(0.09, 130, wave: 'sine', decay: 0.03, vol: 0.35);
  Int16List _sfxPlayerHurt() => _sweep(0.22, 320, 70, wave: 'saw', decay: 0.09, vol: 0.5, noiseMix: 0.2);
  Int16List _sfxPickup() => _sweep(0.1, 520, 920, wave: 'sine', decay: 0.045, vol: 0.35);
  Int16List _sfxReload() => _concat([_tone(0.04, 220, wave: 'square', decay: 0.015, vol: 0.25), _tone(0.07, 360, wave: 'square', decay: 0.025, vol: 0.25)]);
  Int16List _sfxBossDefeat() => _arpeggio(0.45, [523, 659, 784, 1047], wave: 'square', decay: 0.08, vol: 0.4);
  Int16List _sfxLevelUp() => _arpeggio(0.35, [440, 523, 659, 880], wave: 'sine', decay: 0.07, vol: 0.4);
  Int16List _sfxBuy() => _sweep(0.13, 660, 880, wave: 'sine', decay: 0.05, vol: 0.4);
  Int16List _sfxClick() => _tone(0.03, 800, wave: 'square', decay: 0.008, vol: 0.25);
  Int16List _sfxJump() => _sweep(0.05, 300, 520, wave: 'sine', decay: 0.02, vol: 0.3);
}
