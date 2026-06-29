import 'dart:ui';

const double levelLength = 320;
const double gravity = 1450;
const int saveVersion = 1;

final List<Biome> biomes = [
  Biome(level: 1, id: "backyard", name: "Sunny Backyard", start: 0, exclusiveEnemy: "rat_charger", bossKind: "rat_charger", bossName: "Bully Rat Boss", color: const Color(0xFF8ed957), ridge: const Color(0xFF69bf3d), shadow: const Color(0xFF236c30), skyTint: const Color.fromRGBO(66, 178, 255, 0.08), amp: 58, freq: 0.0062),
  Biome(level: 2, id: "attic", name: "Dusty Attic", start: levelLength, exclusiveEnemy: "spider_trapper", bossKind: "spider_trapper", bossName: "Web Queen", color: const Color(0xFFb48758), ridge: const Color(0xFF8e633f), shadow: const Color(0xFF4e3326), skyTint: const Color.fromRGBO(82, 45, 25, 0.35), amp: 72, freq: 0.0084),
  Biome(level: 3, id: "cafe", name: "Bustling Cafe", start: levelLength * 2, exclusiveEnemy: "caffeine_roach", bossKind: "caffeine_roach", bossName: "Caffeine Roach", color: const Color(0xFFd2a968), ridge: const Color(0xFFb77d3d), shadow: const Color(0xFF5c341e), skyTint: const Color.fromRGBO(255, 168, 80, 0.24), amp: 88, freq: 0.0102),
  Biome(level: 4, id: "sewer", name: "Neon Sewers", start: levelLength * 3, exclusiveEnemy: "toxic_frog", bossKind: "toxic_frog", bossName: "Toxic Spitter", color: const Color(0xFF34d399), ridge: const Color(0xFF177b63), shadow: const Color(0xFF073d35), skyTint: const Color.fromRGBO(0, 255, 163, 0.34), amp: 64, freq: 0.012),
  Biome(level: 5, id: "factory", name: "Cyborg Factory", start: levelLength * 4, exclusiveEnemy: "mecha_fox", bossKind: "mecha_fox", bossName: "Mecha Fox", color: const Color(0xFFf2c84b), ridge: const Color(0xFF68707a), shadow: const Color(0xFF222932), skyTint: const Color.fromRGBO(34, 40, 52, 0.55), amp: 96, freq: 0.0094),
  Biome(level: 6, id: "bamboo", name: "Bamboozle Forest", start: levelLength * 5, exclusiveEnemy: "ninja_weasel", bossKind: "ninja_weasel", bossName: "Mist Assassin", color: const Color(0xFF86efac), ridge: const Color(0xFF3f9b55), shadow: const Color(0xFF17462c), skyTint: const Color.fromRGBO(114, 255, 176, 0.25), amp: 104, freq: 0.0078),
  Biome(level: 7, id: "thrift", name: "Thrift Warehouse", start: levelLength * 6, exclusiveEnemy: "moth_swarm", bossKind: "moth_swarm", bossName: "Moth Swarm", color: const Color(0xFFf0abfc), ridge: const Color(0xFF9d6bd1), shadow: const Color(0xFF3b2457), skyTint: const Color.fromRGBO(236, 72, 153, 0.2), amp: 78, freq: 0.009),
  Biome(level: 8, id: "gym", name: "Iron Gym", start: levelLength * 7, exclusiveEnemy: "bulking_lizard", bossKind: "bulking_lizard", bossName: "Bulking Lizard", color: const Color(0xFFf97316), ridge: const Color(0xFF53565f), shadow: const Color(0xFF1f2229), skyTint: const Color.fromRGBO(249, 115, 22, 0.25), amp: 112, freq: 0.0088),
  Biome(level: 9, id: "den", name: "Hedgehog Den", start: levelLength * 8, exclusiveEnemy: "spiky_hedgehog", bossKind: "spiky_hedgehog", bossName: "Spiky Tank", color: const Color(0xFFa78bfa), ridge: const Color(0xFF6247a6), shadow: const Color(0xFF25133d), skyTint: const Color.fromRGBO(124, 58, 237, 0.32), amp: 84, freq: 0.0125),
  Biome(level: 10, id: "citadel", name: "Guild Citadel", start: levelLength * 9, exclusiveEnemy: "royal_guard", bossKind: "boss_silhouette", bossName: "Guild Madking", color: const Color(0xFFfde68a), ridge: const Color(0xFF8b7a66), shadow: const Color(0xFF34251e), skyTint: const Color.fromRGBO(251, 191, 36, 0.22), amp: 118, freq: 0.0108),
];

final List<Weapon> weapons = [
  const Weapon(id: "seed_gatling", name: "Seed Gatling", trait: "Fast seed stream", level2: "Twin spread barrel", cost: 0, upgradeCost: 70),
  const Weapon(id: "walnut_cannon", name: "Walnut Cannon", trait: "Explosive walnut", level2: "Cluster shrapnel", cost: 140, upgradeCost: 210),
  const Weapon(id: "laser_pointer", name: "Laser Pointer", trait: "Pierces armor", level2: "Prism ricochet", cost: 170, upgradeCost: 250),
  const Weapon(id: "carrot_missile", name: "Carrot Missile", trait: "Homing carrot", level2: "Double volley", cost: 210, upgradeCost: 310),
  const Weapon(id: "cheese_thrower", name: "Cheese Thrower", trait: "Slow cone spray", level2: "Sticky puddle", cost: 170, upgradeCost: 260),
  const Weapon(id: "peanut_splat", name: "Peanut Splat", trait: "Close shotgun", level2: "Mini stun chunks", cost: 150, upgradeCost: 230),
  const Weapon(id: "boomerang_twig", name: "Boomerang Twig", trait: "Returns through foes", level2: "Sharper return", cost: 190, upgradeCost: 280),
  const Weapon(id: "sonic_squeak", name: "Sonic Squeak", trait: "Deflects shots", level2: "Bigger shockwave", cost: 220, upgradeCost: 330),
  const Weapon(id: "melon_sniper", name: "Melon Sniper", trait: "High damage line", level2: "Pierces 3 foes", cost: 190, upgradeCost: 290),
  const Weapon(id: "corn_cob", name: "Corn-Cob Shot", trait: "Three-shot burst", level2: "Popcorn burst", cost: 160, upgradeCost: 240),
];

final Map<String, List<double>> weaponAmmo = {
  "seed_gatling": [30, 42, 1.1],
  "walnut_cannon": [4, 5, 1.85],
  "laser_pointer": [12, 16, 1.45],
  "carrot_missile": [6, 8, 1.65],
  "cheese_thrower": [24, 30, 1.35],
  "peanut_splat": [8, 10, 1.35],
  "boomerang_twig": [5, 7, 1.25],
  "sonic_squeak": [6, 8, 1.7],
  "melon_sniper": [5, 6, 1.55],
  "corn_cob": [12, 15, 1.4],
};

final Map<String, String> terrainFrameByBiome = {
  "backyard": "backyard_grass",
  "attic": "attic_planks",
  "cafe": "cafe_table",
  "sewer": "neon_slime",
  "factory": "factory_metal",
  "bamboo": "bamboo_forest",
  "thrift": "thrift_cloth",
  "gym": "iron_gym",
  "den": "crystal_den",
  "citadel": "guild_marble",
};

final Set<String> advancedEntityKinds = {
  "caffeine_roach", "toxic_frog", "mecha_fox", "ninja_weasel",
  "moth_swarm", "bulking_lizard", "spiky_hedgehog", "royal_guard",
  "boss_silhouette", "castle_cannon",
};

final Set<String> advancedTerrainFrames = {
  "bamboo_forest", "thrift_cloth", "iron_gym", "crystal_den", "guild_marble",
};

final List<Skin> skins = [
  const Skin(id: "classic", name: "Classic", trait: "Clean starter", level2: "+5% seed drops", cost: 0, upgradeCost: 60),
  const Skin(id: "ninja", name: "Ninja", trait: "+speed dash", level2: "Dash invincible", cost: 120, upgradeCost: 190),
  const Skin(id: "mecha", name: "Mecha", trait: "+1 HP", level2: "Run shield", cost: 150, upgradeCost: 240),
  const Skin(id: "agent_h", name: "Agent H", trait: "+10% seeds", level2: "Coin magnet", cost: 160, upgradeCost: 260),
  const Skin(id: "pirate", name: "Pirate", trait: "+loot chance", level2: "+3s powerups", cost: 150, upgradeCost: 230),
  const Skin(id: "astronaut", name: "Astronaut", trait: "Floatier jumps", level2: "Triple jump", cost: 170, upgradeCost: 260),
  const Skin(id: "zombie", name: "Zombie", trait: "10% revive", level2: "One sure revive", cost: 190, upgradeCost: 310),
  const Skin(id: "knight", name: "Knight", trait: "Melee armor", level2: "Reflect thorns", cost: 180, upgradeCost: 280),
  const Skin(id: "wizard", name: "Wizard", trait: "Skill cooldown", level2: "+2s skills", cost: 170, upgradeCost: 270),
  const Skin(id: "gym_bro", name: "Gym Bro", trait: "+spin damage", level2: "Wide armor break", cost: 160, upgradeCost: 250),
];

final Map<String, List<double>> enemyStats = {
  "wood_crate": [1.2, 0, 35],
  "rat_charger": [1.8, -70, 33],
  "armored_weasel": [4.2, -28, 43],
  "owl_sniper": [2.2, -8, 33],
  "crow_bomber": [1.7, -25, 31],
  "spider_trapper": [1.9, -42, 29],
  "caffeine_roach": [1.5, -140, 28],
  "toxic_frog": [2.6, -20, 36],
  "mecha_fox": [4.8, -38, 44],
  "ninja_weasel": [2.2, -160, 32],
  "moth_swarm": [2.4, -60, 42],
  "bulking_lizard": [6.5, -22, 52],
  "spiky_hedgehog": [3.4, -185, 38],
  "royal_guard": [5.2, -115, 48],
  "castle_cannon": [3.2, -8, 36],
};

const Map<String, List<int>> biomePalettes = {
  "attic": [0xFF211712, 0xFF5a3927, 0xFFb88758],
  "cafe": [0xFF40210f, 0xFF9a5f31, 0xFFf0b76d],
  "sewer": [0xFF061a24, 0xFF073d35, 0xFF18b981],
  "factory": [0xFF111827, 0xFF303640, 0xFFfacc15],
  "bamboo": [0xFF10291b, 0xFF246b3a, 0xFFa7f3d0],
  "thrift": [0xFF221534, 0xFF6d3b8f, 0xFFf0abfc],
  "gym": [0xFF141414, 0xFF44403c, 0xFFf97316],
  "den": [0xFF13091f, 0xFF3b2457, 0xFFa78bfa],
  "citadel": [0xFF263042, 0xFF64748b, 0xFFfde68a],
};

class Biome {
  final int level;
  final String id;
  final String name;
  final double start;
  final double length;
  final String exclusiveEnemy;
  final String bossKind;
  final String bossName;
  final Color color;
  final Color ridge;
  final Color shadow;
  final Color skyTint;
  final double amp;
  final double freq;

  const Biome({
    required this.level,
    required this.id,
    required this.name,
    required this.start,
    this.length = 320,
    required this.exclusiveEnemy,
    required this.bossKind,
    required this.bossName,
    required this.color,
    required this.ridge,
    required this.shadow,
    required this.skyTint,
    required this.amp,
    required this.freq,
  });
}

class Weapon {
  final String id;
  final String name;
  final String trait;
  final String level2;
  final int cost;
  final int upgradeCost;

  const Weapon({
    required this.id,
    required this.name,
    required this.trait,
    required this.level2,
    required this.cost,
    required this.upgradeCost,
  });
}

class Skin {
  final String id;
  final String name;
  final String trait;
  final String level2;
  final int cost;
  final int upgradeCost;

  const Skin({
    required this.id,
    required this.name,
    required this.trait,
    required this.level2,
    required this.cost,
    required this.upgradeCost,
  });
}

class ItemState {
  bool unlocked;
  int level;

  ItemState({required this.unlocked, this.level = 1});

  factory ItemState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ItemState(unlocked: false);
    return ItemState(
      unlocked: json['unlocked'] == true,
      level: json['level'] == 2 ? 2 : 1,
    );
  }
}
