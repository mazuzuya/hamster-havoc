import 'dart:math';
import 'hamster_havoc_data.dart' as data;

class ProgressState {
  int bestMeters = 0;
  int seeds = 90;
  int peanuts = 0;
  String selectedWeapon = "seed_gatling";
  String selectedSkin = "classic";
  late Map<String, data.ItemState> weapons;
  late Map<String, data.ItemState> skins;

  ProgressState() {
    weapons = {for (final w in data.weapons) w.id: data.ItemState(unlocked: w.cost == 0)};
    skins = {for (final s in data.skins) s.id: data.ItemState(unlocked: s.cost == 0)};
  }

  void load(Map<String, dynamic>? saved) {
    if (saved == null || saved['version'] != data.saveVersion) return;
    bestMeters = _finiteInt(saved['bestMeters'], 0);
    seeds = _finiteInt(saved['seeds'], seeds);
    peanuts = _finiteInt(saved['peanuts'], 0);
    final selW = saved['selectedWeapon'] as String?;
    selectedWeapon = selW != null && weapons.containsKey(selW) ? selW : selectedWeapon;
    final selS = saved['selectedSkin'] as String?;
    selectedSkin = selS != null && skins.containsKey(selS) ? selS : selectedSkin;
    _mergeCollection(weapons, saved['weapons'] as Map<String, dynamic>?);
    _mergeCollection(skins, saved['skins'] as Map<String, dynamic>?);
  }

  void _mergeCollection(Map<String, data.ItemState> target, Map<String, dynamic>? saved) {
    if (saved == null) return;
    for (final entry in target.entries) {
      final item = saved[entry.key] as Map<String, dynamic>?;
      if (item != null) {
        entry.value.unlocked = item['unlocked'] == true;
        entry.value.level = item['level'] == 2 ? 2 : 1;
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'version': data.saveVersion,
    'bestMeters': bestMeters,
    'seeds': seeds,
    'peanuts': peanuts,
    'selectedWeapon': selectedWeapon,
    'selectedSkin': selectedSkin,
    'weapons': {for (final e in weapons.entries) e.key: {'unlocked': e.value.unlocked, 'level': e.value.level}},
    'skins': {for (final e in skins.entries) e.key: {'unlocked': e.value.unlocked, 'level': e.value.level}},
  };

  static int _finiteInt(dynamic v, int fallback) {
    final n = num.tryParse(v.toString());
    return n != null && n.isFinite ? n.toInt() : fallback;
  }

  data.Weapon get selectedWeaponDef => data.weapons.firstWhere((w) => w.id == selectedWeapon, orElse: () => data.weapons.first);
  data.Skin get selectedSkinDef => data.skins.firstWhere((s) => s.id == selectedSkin, orElse: () => data.skins.first);
}

class PlayerState {
  double y = 0;
  double vy = 0;
  bool grounded = true;
  int jumpsLeft = 2;
  double radius = 31;
  double fireCooldown = 0;
  int ammo = 30;
  double reloadTimer = 0;
  double reloadDuration = 1.1;
  double reloadFlash = 0;
  double jumpLockTimer = 0;
  double spinTimer = 0;
  double spinCooldown = 0;
  double hurtTimer = 0;
  double dashTimer = 0;
  double weaponFlash = 0;
}

class Pickup {
  String kind;
  double x;
  double y;
  double radius;
  bool collected;
  double spin;

  Pickup({required this.kind, required this.x, required this.y, this.radius = 18, this.collected = false, this.spin = 0});
}

class Enemy {
  String kind;
  double x;
  double y;
  double hp;
  double maxHp;
  double vx = 0;
  double radius = 35;
  bool ground = true;
  bool armor = false;
  bool crate = false;
  double shootTimer = 0;
  double stun = 0;
  double slow = 0;

  Enemy({
    required this.kind,
    required this.x,
    required this.y,
    required this.hp,
    required this.maxHp,
    this.vx = 0,
    this.radius = 35,
    this.ground = true,
    this.armor = false,
    this.crate = false,
    this.shootTimer = 0,
    this.stun = 0,
    this.slow = 0,
  });
}

class Hazard {
  String kind;
  double x;
  double y;
  double radius;
  bool warned;

  Hazard({required this.kind, required this.x, required this.y, required this.radius, this.warned = false});
}

class Projectile {
  String kind;
  double x;
  double y;
  double vx;
  double vy;
  double damage;
  double radius;
  int pierce;
  double life = 2;
  bool fromPlayer = false;
  bool returning = false;
  double age = 0;
  bool? slow;
  bool? stun;
  bool pop = false;
  bool popped = false;
  bool deflect = false;
  bool clustered = false;
  double gravity = 0;
  String color = "#fff";
  bool web = false;
  bool zigzag = false;

  Projectile({
    required this.kind,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.damage,
    required this.radius,
    this.pierce = 1,
    this.life = 2,
    this.fromPlayer = false,
    this.returning = false,
    this.age = 0,
    this.pop = false,
    this.popped = false,
    this.deflect = false,
    this.clustered = false,
    this.gravity = 0,
    this.color = "#fff",
    this.web = false,
    this.zigzag = false,
  });
}

class GameEffect {
  String name;
  double x;
  double y;
  double size;
  double t;
  double duration;

  GameEffect({required this.name, required this.x, required this.y, required this.size, this.t = 0, this.duration = 0.32});
}

class Label {
  String text;
  double x;
  double y;
  String color;
  double duration;
  double t;

  Label({required this.text, required this.x, required this.y, required this.color, this.duration = 0.9, this.t = 0});
}

class Boss {
  int level;
  String kind;
  String name;
  double x;
  double y;
  double baseY;
  double hp;
  double maxHp;
  double radius;
  double attackTimer;
  int pattern;
  double t;

  Boss({
    required this.level,
    required this.kind,
    required this.name,
    required this.x,
    required this.y,
    required this.baseY,
    required this.hp,
    required this.maxHp,
    required this.radius,
    this.attackTimer = 1.1,
    this.pattern = 0,
    this.t = 0,
  });
}

class RunState {
  double worldX = 0;
  int levelIndex = 0;
  double levelMeters = 0;
  int meters = 0;
  double speed = 370;
  Boss? boss;
  double bossIntroTimer = 0;
  double defeatAt = 0;
  int hp = 4;
  int maxHp = 4;
  int seeds = 0;
  int peanuts = 0;
  int kills = 0;
  double crateTimer = 0.8;
  double seedTimer = 0.2;
  double enemyTimer = 1.4;
  double hazardTimer = 2.8;
  double biomeNoticeTimer = 1.8;
  String lastBiome = "backyard";
  double slowTimer = 0;
  bool reviveUsed = false;
  bool shieldReady = false;
  late PlayerState player;
  List<Pickup> pickups = [];
  List<Enemy> enemies = [];
  List<Hazard> hazards = [];
  List<Projectile> projectiles = [];
  List<Projectile> enemyProjectiles = [];
  List<GameEffect> effects = [];
  List<Label> labels = [];
}

double clamp(double value, double min, double max) => value.clamp(min, max);

bool circleHit(double ax, double ay, double bx, double by, double radius) {
  final dx = ax - bx;
  final dy = ay - by;
  return dx * dx + dy * dy <= radius * radius;
}

double terrainY(RunState run, double height, double worldX) {
  final biome = run.levelIndex >= 0 && run.levelIndex < data.biomes.length ? data.biomes[run.levelIndex] : data.biomes[0];
  final base = height * 0.69;
  final ridge = sin(worldX * biome.freq) * biome.amp;
  final detail = sin(worldX * biome.freq * 0.43 + 1.7) * biome.amp * 0.32;
  return clamp(base + ridge + detail, height * 0.48, height * 0.83);
}

double terrainSlope(RunState run, double height, double worldX) {
  return (terrainY(run, height, worldX + 12) - terrainY(run, height, worldX - 12)) / 24;
}

data.Biome currentBiome(RunState run) {
  final idx = clamp(run.levelIndex.toDouble(), 0, data.biomes.length - 1).toInt();
  return data.biomes[idx];
}
