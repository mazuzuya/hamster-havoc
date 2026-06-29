import 'dart:math';
import 'dart:ui';
import 'hamster_havoc_audio.dart';
import 'hamster_havoc_data.dart';
import 'hamster_havoc_state.dart';

class GameConfig {
  double startSpeed = 370;
  double difficultyRamp = 0.23;
  double spawnRate = 1;
  int seedValue = 1;
  double effectsIntensity = 1;
}

class GameEngine {
  final GameConfig config = GameConfig();
  ProgressState progress = ProgressState();
  RunState? run;
  late double gameWidth;
  late double gameHeight;

  void resize(double w, double h) {
    gameWidth = w;
    gameHeight = h;
  }

  void jumpToLevel(int levelIndex) {
    final idx = clamp(levelIndex.toDouble(), 0, biomes.length - 1).toInt();
    final maxHp = 4 + (progress.selectedSkin == "mecha" ? 1 : 0);
    final skinState = progress.skins[progress.selectedSkin]!;
    run = RunState()
      ..levelIndex = idx
      ..levelMeters = 0
      ..meters = idx * levelLength.toInt()
      ..speed = config.startSpeed
      ..maxHp = maxHp
      ..hp = maxHp
      ..lastBiome = biomes[idx].id
      ..shieldReady = progress.selectedSkin == "mecha" && skinState.level == 2;
    final p = PlayerState()
      ..ammo = ammoCapacity()
      ..jumpsLeft = progress.selectedSkin == "astronaut" && skinState.level == 2 ? 3 : 2
      ..y = gameHeight * 0.62;
    run!.player = p;
    final ground = terrainY(run!, gameHeight, run!.worldX);
    p.y = ground - p.radius;
    p.grounded = true;
  }

  void resetRun(bool shouldStart) {
    final skinState = progress.skins[progress.selectedSkin]!;
    final maxHp = 4 + (progress.selectedSkin == "mecha" ? 1 : 0);

    run = RunState()
      ..maxHp = maxHp
      ..hp = maxHp
      ..speed = config.startSpeed
      ..shieldReady = progress.selectedSkin == "mecha" && skinState.level == 2;
    final p = PlayerState()
      ..y = gameHeight * 0.62
      ..jumpsLeft = progress.selectedSkin == "astronaut" && skinState.level == 2 ? 3 : 2
      ..ammo = ammoCapacity();
    run!.player = p;
    final ground = terrainY(run!, gameHeight, run!.worldX);
    p.y = ground - p.radius;
    p.grounded = true;
  }

  int ammoCapacity() {
    final weapon = weapons.firstWhere((w) => w.id == progress.selectedWeapon, orElse: () => weapons.first);
    final level = progress.weapons[weapon.id]?.level ?? 1;
    final values = weaponAmmo[weapon.id] ?? weaponAmmo["seed_gatling"]!;
    return (level == 2 ? values[1] : values[0]).toInt();
  }

  double reloadDuration() {
    final weapon = weapons.firstWhere((w) => w.id == progress.selectedWeapon, orElse: () => weapons.first);
    final level = progress.weapons[weapon.id]?.level ?? 1;
    final values = weaponAmmo[weapon.id] ?? weaponAmmo["seed_gatling"]!;
    return max(0.65, values[2] * (level == 2 ? 0.9 : 1));
  }

  void startReload({bool force = false}) {
    if (run == null) return;
    final r = run!;
    if (!force && r.player.reloadTimer > 0) return;
    r.player.reloadDuration = reloadDuration();
    r.player.reloadTimer = r.player.reloadDuration;
    r.player.fireCooldown = max(r.player.fireCooldown, 0.15);
    r.labels.add(Label(text: "Reload!", x: screenPlayerX() + 60, y: r.player.y - 58, color: "#ffe15f", duration: 0.75));
  }

  double screenPlayerX() => min(gameWidth * 0.3, 150);
  double worldToScreenX(double x) => screenPlayerX() + (x - run!.worldX);
  double screenToWorldX(double sx) => run!.worldX + (sx - screenPlayerX());

  void jump() {
    if (run == null) return;
    final r = run!;
    if (r.player.jumpLockTimer > 0) {
      r.labels.add(Label(text: "Webbed!", x: screenPlayerX(), y: r.player.y - 54, color: "#dbeafe", duration: 0.55));
      return;
    }
    final skin = progress.selectedSkin;
    final floatBonus = skin == "astronaut" ? 0.9 : 1.0;
    if (r.player.grounded) {
      r.player.vy = -620 * floatBonus;
      r.player.grounded = false;
      r.player.jumpsLeft = skin == "astronaut" && (progress.skins["astronaut"]?.level ?? 1) == 2 ? 2 : 1;
      r.labels.add(Label(text: "Hop!", x: screenPlayerX(), y: r.player.y - 50, color: "#fff6a7"));
      GameAudio.instance.play('jump');
    } else if (r.player.jumpsLeft > 0) {
      r.player.vy = -560 * floatBonus;
      r.player.jumpsLeft--;
      addEffect("dash_swirl", screenPlayerX(), r.player.y + 12, 62);
    }
  }

  void spin() {
    if (run == null) return;
    final r = run!;
    if (r.player.spinCooldown > 0) return;
    final level = progress.skins[progress.selectedSkin]?.level ?? 1;
    r.player.spinTimer = progress.selectedSkin == "gym_bro" ? 0.62 : 0.48;
    r.player.spinCooldown = progress.selectedSkin == "wizard" ? 0.72 : 1.05;
    if (progress.selectedSkin == "ninja" && level == 2) r.player.dashTimer = 0.42;
    addEffect("dash_swirl", screenPlayerX(), r.player.y + 10, 88);
    GameAudio.instance.playDash();
  }

  void shoot() {
    if (run == null) return;
    final r = run!;
    if (r.player.fireCooldown > 0) return;
    final weapon = weapons.firstWhere((w) => w.id == progress.selectedWeapon, orElse: () => weapons.first);
    final level = progress.weapons[weapon.id]?.level ?? 1;
    if (r.player.reloadTimer > 0) return;
    if (r.player.ammo <= 0) {
      startReload(force: true);
      return;
    }
    r.player.ammo--;
    final originX = r.worldX + 54;
    final originY = r.player.y - 18;
    r.player.weaponFlash = 0.08;
    addEffect("muzzle_flash", screenPlayerX() + 52, originY, 38);
    GameAudio.instance.playShoot(weapon.id);

    void addProjectile(double vx, double vy, double damage, double radius, String kind, {int pierce = 1, double life = 2, bool? slow, bool? stun, bool pop = false, bool deflect = false}) {
      r.projectiles.add(Projectile(kind: kind, x: originX, y: originY, vx: vx, vy: vy, damage: damage, radius: radius, pierce: pierce, life: life, fromPlayer: true, pop: pop, deflect: deflect));
    }

    switch (weapon.id) {
      case "walnut_cannon":
        addProjectile(560, -70, level == 2 ? 3.2 : 2.6, 18, "walnut", pierce: 1);
        r.player.fireCooldown = 0.75;
        break;
      case "laser_pointer":
        addProjectile(1300, 0, 1.8, 7, "laser", pierce: level == 2 ? 4 : 2, life: 0.26);
        r.player.fireCooldown = 0.28;
        break;
      case "carrot_missile":
        final count = level == 2 ? 2 : 1;
        for (int i = 0; i < count; i++) {
          addProjectile(470, -80 + i * 130, 1.7, 14, "carrot", pierce: 1);
        }
        r.player.fireCooldown = 0.62;
        break;
      case "cheese_thrower":
        for (int i = 0; i < 5; i++) {
          addProjectile(410 + i * 18, (i - 2) * 35.0, 0.7, level == 2 ? 18.0 : 14, "cheese", pierce: 1, life: 0.62, slow: level == 2 ? true : null);
        }
        r.player.fireCooldown = 0.22;
        break;
      case "peanut_splat":
        for (int i = 0; i < 5; i++) {
          addProjectile(520, (i - 2) * 110.0, level == 2 ? 1.15 : 0.95, 13, "peanut", pierce: 1, stun: level == 2 ? true : null);
        }
        r.player.fireCooldown = 0.5;
        break;
      case "boomerang_twig":
        addProjectile(600, -20, level == 2 ? 1.4 : 1.0, 18, "twig", pierce: 4);
        r.player.fireCooldown = 0.8;
        break;
      case "sonic_squeak":
        addProjectile(460, 0, level == 2 ? 1.25 : 0.9, level == 2 ? 50.0 : 34, "sonic", pierce: 6, life: 0.75, deflect: true);
        r.player.fireCooldown = 0.65;
        break;
      case "melon_sniper":
        addProjectile(1050, 0, 2.2, 9, "melon", pierce: level == 2 ? 3 : 1);
        r.player.fireCooldown = 0.6;
        break;
      case "corn_cob":
        for (int i = 0; i < 3; i++) {
          addProjectile(660, (i - 1) * 58.0, level == 2 ? 0.85 : 0.7, 10, "corn", pierce: 1, pop: level == 2);
        }
        r.player.fireCooldown = 0.38;
        break;
      default: // seed_gatling
        final spread = level == 2 ? [-90.0, 0.0, 90.0] : [0.0];
        for (final vy in spread) {
          addProjectile(760, vy, 0.62, 8, "seed", pierce: 1);
        }
        r.player.fireCooldown = level == 2 ? 0.12 : 0.1;
    }
    if (r.player.ammo <= 0) startReload(force: true);
  }

  void addEffect(String name, double x, double y, double size) {
    if (config.effectsIntensity <= 0) return;
    run!.effects.add(GameEffect(name: name, x: x, y: y, size: size * config.effectsIntensity));
  }

  void addImpactBurst(double x, double y, String kind) {
    final r = run!;
    if (config.effectsIntensity <= 0) return;
    for (int i = 0; i < 4; i++) {
      final angle = Random().nextDouble() * pi * 2;
      final dist = 8 + Random().nextDouble() * 18;
      r.effects.add(GameEffect(
        name: "enemy_hit",
        x: x + cos(angle) * dist,
        y: y + sin(angle) * dist,
        size: 12 + Random().nextDouble() * 16,
        duration: 0.22,
      ));
    }
  }

  void update(double dt) {
    if (run == null) return;
    final r = run!;
    final p = r.player;
    final biome = currentBiome(r);

    // Biome change notice
    if (biome.id != r.lastBiome) {
      r.lastBiome = biome.id;
      r.biomeNoticeTimer = 2.1;
      r.labels.add(Label(text: biome.name, x: gameWidth * 0.5, y: gameHeight * 0.25, color: "#ffffff", duration: 1.5));
      GameAudio.instance.play('levelUp');
    }

    // Cooldown timers
    p.fireCooldown = max(0, p.fireCooldown - dt);
    if (p.reloadTimer > 0) {
      p.reloadTimer = max(0, p.reloadTimer - dt);
      if (p.reloadTimer == 0) {
        p.ammo = ammoCapacity();
        p.reloadFlash = 0.34;
        addEffect("pickup_spark", screenPlayerX() + 78, p.y - 32, 52);
        GameAudio.instance.play('reload');
      }
    }
    p.reloadFlash = max(0, p.reloadFlash - dt);
    p.spinCooldown = max(0, p.spinCooldown - dt);
    p.spinTimer = max(0, p.spinTimer - dt);
    p.dashTimer = max(0, p.dashTimer - dt);
    p.hurtTimer = max(0, p.hurtTimer - dt);
    p.weaponFlash = max(0, p.weaponFlash - dt);
    p.jumpLockTimer = max(0, p.jumpLockTimer - dt);
    r.slowTimer = max(0, r.slowTimer - dt);
    r.bossIntroTimer = max(0, r.bossIntroTimer - dt);
    r.biomeNoticeTimer = max(0, r.biomeNoticeTimer - dt);

    // Speed calculation
    final slope = terrainSlope(r, gameHeight, r.worldX);
    final downhill = max(0.0, slope);
    final slowPenalty = r.slowTimer > 0 ? 0.58 : 1.0;
    final downhillBoost = p.grounded ? downhill * 130 : 0;
    r.speed = (config.startSpeed + r.meters * config.difficultyRamp + downhillBoost) * slowPenalty;
    if (biome.id == "sewer") r.speed *= 1.08;
    if (biome.id == "factory" && sin(r.worldX * 0.01) > 0.55) r.speed *= 1.12;
    if (biome.id == "bamboo" && p.grounded && downhill > 0.6) p.vy -= 18;
    if (biome.id == "thrift") r.speed *= 0.88;

    if (r.boss != null) {
      r.speed = 115;
      r.worldX += r.speed * dt;
      r.levelMeters = biome.length;
    } else {
      r.worldX += r.speed * dt;
      r.levelMeters += (r.speed * dt) / 18;
      if (r.levelMeters >= biome.length) startBoss(biome);
    }
    r.meters = (r.levelIndex * levelLength + min(r.levelMeters, biome.length)).toInt();

    // Gravity & physics
    final g = gravity * (progress.selectedSkin == "astronaut" ? 0.82 : 1.0);
    p.vy += g * dt;
    p.y += p.vy * dt;
    final ground = terrainY(r, gameHeight, r.worldX) - p.radius;
    if (p.y >= ground && p.vy >= 0) {
      p.y = ground;
      p.vy = 0;
      p.grounded = true;
      p.jumpsLeft = progress.selectedSkin == "astronaut" && (progress.skins["astronaut"]?.level ?? 1) == 2 ? 3 : 2;
    } else {
      p.grounded = false;
    }

    // Spawning & boss
    if (r.boss != null) {
      updateBoss(dt);
    } else {
      r.seedTimer -= dt * config.spawnRate;
      r.crateTimer -= dt * config.spawnRate;
      r.enemyTimer -= dt * config.spawnRate;
      r.hazardTimer -= dt * config.spawnRate;
      if (r.seedTimer <= 0) { spawnSeedTrail(); r.seedTimer = 1.15 + Random().nextDouble() * 0.8; }
      if (r.crateTimer <= 0) { spawnCrate(); r.crateTimer = 4.2 + Random().nextDouble() * 2.3; }
      if (r.enemyTimer <= 0) { spawnEnemy(); r.enemyTimer = clamp(2.6 - r.meters / 900, 1.05, 2.6) + Random().nextDouble() * 0.75; }
      if (r.hazardTimer <= 0) { spawnHazard(); r.hazardTimer = clamp(3.4 - r.meters / 1000, 1.6, 3.4) + Random().nextDouble() * 0.8; }
    }

    updatePickups(dt);
    updateEnemies(dt);
    updateProjectiles(dt);
    updateHazards();
    updateEffects(dt);
  }

  void spawnSeedTrail() {
    final r = run!;
    final start = r.worldX + gameWidth * (0.75 + Random().nextDouble() * 0.35);
    final count = 5 + Random().nextInt(3);
    for (int i = 0; i < count; i++) {
      final x = start + i * 42;
      final y = terrainY(r, gameHeight, x) - 78 - sin(i / max(1, count - 1).toDouble() * pi) * (70 + Random().nextDouble() * 30);
      r.pickups.add(Pickup(kind: Random().nextDouble() > 0.96 ? "golden_peanut" : "sunflower_seed", x: x, y: y, spin: Random().nextDouble() * 6));
    }
  }

  void spawnCrate() {
    final r = run!;
    final x = r.worldX + gameWidth * (0.95 + Random().nextDouble() * 0.45);
    r.enemies.add(Enemy(kind: "wood_crate", x: x, y: terrainY(r, gameHeight, x), hp: 1.2, maxHp: 1.2, radius: 35, ground: true, crate: true));
  }

  void spawnEnemy() {
    final r = run!;
    final meters = r.meters;
    final biome = currentBiome(r);
    final choices = <String>[biome.exclusiveEnemy, "wood_crate"];
    if (biome.level >= 2) choices.add("spider_trapper");
    if (biome.level >= 3) { choices.add("caffeine_roach"); choices.add("owl_sniper"); }
    if (biome.level >= 4) { choices.add("toxic_frog"); choices.add("crow_bomber"); }
    if (biome.level >= 5) { choices.add("mecha_fox"); choices.add("armored_weasel"); }
    if (biome.level >= 6) choices.add("ninja_weasel");
    if (biome.level >= 7) choices.add("moth_swarm");
    if (biome.level >= 8) choices.add("bulking_lizard");
    if (biome.level >= 9) choices.add("spiky_hedgehog");
    if (biome.level >= 10) { choices.add("royal_guard"); choices.add("castle_cannon"); }
    final kind = choices[Random().nextInt(choices.length)];
    final x = r.worldX + gameWidth * (1.05 + Random().nextDouble() * 0.45);
    final ground = terrainY(r, gameHeight, x);
    final stats = enemyStats[kind]!;
    final isFlying = ["owl_sniper", "crow_bomber", "toxic_frog", "moth_swarm", "castle_cannon"].contains(kind);
    r.enemies.add(Enemy(
      kind: kind,
      x: x,
      y: ["owl_sniper", "toxic_frog", "castle_cannon"].contains(kind) ? ground - 215 : isFlying ? gameHeight * (0.27 + Random().nextDouble() * 0.14) : ground,
      hp: stats[0] + meters * 0.001,
      maxHp: stats[0] + meters * 0.001,
      vx: stats[1],
      radius: stats[2],
      ground: !isFlying,
      armor: kind == "armored_weasel" || kind == "mecha_fox" || kind == "spiky_hedgehog",
      crate: kind == "wood_crate",
      shootTimer: 0.7 + Random().nextDouble() * 1.2,
    ));
  }

  void spawnHazard() {
    final r = run!;
    final x = r.worldX + gameWidth * (1.05 + Random().nextDouble() * 0.45);
    final biome = currentBiome(r).id;
    final kind = (biome == "sewer" || biome == "factory") ? (Random().nextDouble() > 0.35 ? "thorn_spikes" : "mud_puddle") : (Random().nextDouble() > 0.5 ? "mud_puddle" : "thorn_spikes");
    r.hazards.add(Hazard(kind: kind, x: x, y: terrainY(r, gameHeight, x), radius: kind == "mud_puddle" ? 38 : 31));
  }

  void startBoss(Biome biome) {
    final r = run!;
    r.levelMeters = biome.length;
    r.enemies.clear();
    r.hazards.clear();
    r.pickups.retainWhere((p) => p.x < r.worldX + gameWidth * 0.6);
    final hp = 13.0 + biome.level * 5.5;
    r.boss = Boss(
      level: biome.level, kind: biome.bossKind, name: biome.bossName,
      x: r.worldX + gameWidth * 0.72, y: gameHeight * 0.45, baseY: gameHeight * 0.45,
      hp: hp, maxHp: hp, radius: biome.level >= 8 ? 78 : 64,
    );
    r.bossIntroTimer = 2;
    r.player.ammo = max(r.player.ammo, (ammoCapacity() * 0.45).ceil());
    r.labels.add(Label(text: "BOSS: ${biome.bossName}", x: gameWidth * 0.5, y: gameHeight * 0.27, color: "#fff6a7", duration: 1.8));
    GameAudio.instance.play('playerHurt');
  }

  void updateBoss(double dt) {
    final r = run!;
    final boss = r.boss;
    if (boss == null) return;
    boss.t += dt;
    boss.x += (r.worldX + gameWidth * 0.72 - boss.x) * dt * 2.4;
    boss.y = boss.baseY + sin(boss.t * (1.3 + boss.level * 0.08)) * (24 + boss.level * 1.5);
    if (boss.kind == "spiky_hedgehog") boss.y = terrainY(r, gameHeight, boss.x) - 70 + sin(boss.t * 3) * 18;
    if (boss.kind == "royal_guard" || boss.kind == "boss_silhouette") boss.y += sin(boss.t * 2.4) * 18;
    boss.attackTimer -= dt;
    if (boss.attackTimer <= 0 && r.bossIntroTimer <= 0) {
      bossAttack(boss);
      boss.pattern++;
      boss.attackTimer = clamp(1.8 - boss.level * 0.075, 0.85, 1.8);
    }
  }

  void bossAttack(Boss boss) {
    final r = run!;
    final px = r.worldX;
    final py = r.player.y;
    final fromX = boss.x - boss.radius * 0.5;
    final fromY = boss.y - 20;
    GameAudio.instance.playBossShoot();

    void addShot(double vx, double vy, double radius, {String kind = "boss", double gravity = 80, String color = "#fef08a", bool web = false, bool zigzag = false}) {
      r.enemyProjectiles.add(Projectile(kind: kind, x: fromX, y: fromY, vx: vx, vy: vy, damage: 1, radius: radius, life: 4, gravity: gravity, color: color, web: web, zigzag: zigzag));
    }

    switch (boss.level) {
      case 1:
        addShot(-430, 26 * 1.2, 13, color: "#b08968");
        addShot(-430, -18 * 1.2, 13, color: "#b08968");
        break;
      case 2:
        for (final o in [-35.0, 0.0, 35.0]) addShot(-360, o * 1.5, 18, web: true, gravity: 50, color: "#e8f5ff");
        break;
      case 3:
        for (int i = 0; i < 4; i++) addShot(-360 - i * 55, i % 2 == 0 ? 170 : -120.0, 12, zigzag: true, color: "#fbbf24");
        break;
      case 4:
        final speed = 520.0 + boss.pattern * 8;
        final dx = px - fromX;
        final dy = py - fromY;
        final len = (dx * dx + dy * dy).isNaN ? 1.0 : max(1.0, sqrt(dx * dx + dy * dy));
        for (final o in [-0.55, -0.25, 0.1]) {
          addShot((dx / len) * speed, (dy / len) * speed + o * 260, 15, gravity: 620, color: "#84ff3f", kind: "acid");
        }
        break;
      case 5:
        r.enemyProjectiles.add(Projectile(kind: "laser", x: fromX, y: py - 10, vx: -560, vy: 0, damage: 1, radius: 16, life: 4, gravity: 0, color: "#fb7185"));
        r.enemyProjectiles.add(Projectile(kind: "bomb", x: fromX + 30, y: fromY - 35, vx: -150, vy: 210, damage: 1, radius: 17, life: 4, gravity: 520, color: "#94a3b8"));
        break;
      case 6:
        for (int i = 0; i < 3; i++) r.enemyProjectiles.add(Projectile(kind: "slash", x: fromX + i * 10, y: gameHeight * (0.28 + i * 0.16), vx: -500, vy: 120 - i * 80, damage: 1, radius: 18, life: 4, gravity: 0, color: "#7cff9e"));
        break;
      case 7:
        for (int i = 0; i < 5; i++) addShot(-300 - i * 35.0, sin(i.toDouble()) * 90, 15, gravity: 20, color: "#f0abfc", kind: "moth");
        break;
      case 8:
        r.enemyProjectiles.add(Projectile(kind: "plate", x: fromX, y: terrainY(r, gameHeight, fromX) - 100, vx: -520, vy: -80, damage: 1, radius: 26, life: 4, gravity: 700, color: "#cbd5e1"));
        r.enemyProjectiles.add(Projectile(kind: "whey", x: fromX - 20, y: fromY, vx: -350, vy: 170, damage: 1, radius: 18, life: 4, web: true, gravity: 450, color: "#fef3c7"));
        break;
      case 9:
        for (int i = 0; i < 3; i++) r.enemyProjectiles.add(Projectile(kind: "spike", x: fromX, y: terrainY(r, gameHeight, fromX) - 40 - i * 35, vx: -470 - i * 50.0, vy: -120 + i * 80, damage: 1, radius: 16, life: 4, gravity: 380, color: "#c4b5fd"));
        break;
      default:
        for (int i = 0; i < 5; i++) {
          final angle = -2.9 + i * 0.35;
          r.enemyProjectiles.add(Projectile(kind: "magic", x: fromX, y: fromY, vx: cos(angle) * 430, vy: sin(angle) * 300, damage: 1, radius: 16, life: 4, gravity: 80, color: i % 2 == 1 ? "#fbbf24" : "#60a5fa"));
        }
        if (boss.pattern % 3 == 0) r.enemyProjectiles.add(Projectile(kind: "cannon", x: fromX - 70, y: gameHeight * 0.22, vx: -170, vy: 360, damage: 1, radius: 24, life: 4, gravity: 520, color: "#64748b"));
    }
  }

  void defeatBoss() {
    final r = run!;
    final defeated = r.boss!;
    r.boss = null;
    r.enemyProjectiles.clear();
    addEffect("crate_pop", gameWidth * 0.72, defeated.y, 128);
    r.labels.add(Label(text: "${defeated.name} cleared!", x: gameWidth * 0.5, y: gameHeight * 0.28, color: "#a7f3d0", duration: 1.5));
    r.seeds += 20 + defeated.level * 5;
    r.peanuts += defeated.level % 2 == 0 ? 1 : 0;
    GameAudio.instance.play('bossDefeat');
    r.levelIndex++;
    r.levelMeters = 0;
    r.meters = (r.levelIndex * levelLength).toInt();
    r.lastBiome = currentBiome(r).id;
    r.biomeNoticeTimer = 2;
    r.seedTimer = 0.4;
    r.enemyTimer = 1.2;
    r.hazardTimer = 2.4;
    r.player.ammo = ammoCapacity();
    r.player.reloadTimer = 0;
    r.labels.add(Label(text: "Level ${currentBiome(r).level}: ${currentBiome(r).name}", x: gameWidth * 0.5, y: gameHeight * 0.24, color: "#fff6a7", duration: 1.6));
  }

  void updatePickups(double dt) {
    final r = run!;
    final px = r.worldX;
    final py = r.player.y;
    final magnet = progress.selectedSkin == "agent_h" && (progress.skins["agent_h"]?.level ?? 1) == 2;
    for (final pickup in r.pickups) {
      pickup.spin += dt * 5;
      if (magnet && (pickup.x - px).abs() < 180) {
        pickup.x += (px - pickup.x) * dt * 3.2;
        pickup.y += (py - pickup.y) * dt * 3.2;
      }
      if (!pickup.collected && circleHit(px, py, pickup.x, pickup.y, magnet ? 60 : 34)) {
        pickup.collected = true;
        if (pickup.kind == "golden_peanut") r.peanuts++;
        else r.seeds += seedGain();
        addEffect("pickup_spark", worldToScreenX(pickup.x), pickup.y, 38);
        GameAudio.instance.play('pickup');
      }
    }
    r.pickups.retainWhere((p) => !p.collected && p.x > r.worldX - 160);
  }

  int seedGain() {
    double gain = config.seedValue.toDouble();
    if (progress.selectedSkin == "agent_h") gain *= 1.1;
    if (progress.selectedSkin == "classic" && (progress.skins["classic"]?.level ?? 1) == 2) gain *= 1.05;
    return max(1, gain.round());
  }

  void updateEnemies(double dt) {
    final r = run!;
    final px = r.worldX;
    final py = r.player.y;
    for (final enemy in r.enemies) {
      enemy.stun = max(0, enemy.stun - dt);
      enemy.slow = max(0, enemy.slow - dt);
      if (enemy.ground) enemy.y = terrainY(r, gameHeight, enemy.x);
      if (enemy.stun <= 0) enemy.x += enemy.vx * dt * (enemy.slow > 0 ? 0.45 : 1);
      if (enemy.kind == "caffeine_roach") enemy.y += sin(DateTime.now().millisecondsSinceEpoch * 0.018 + enemy.x * 0.03) * 2.8;
      if (enemy.kind == "ninja_weasel") enemy.y += sin(DateTime.now().millisecondsSinceEpoch * 0.01 + enemy.x) * 1.7;
      if (enemy.kind == "spiky_hedgehog") enemy.x -= max(0.0, terrainSlope(r, gameHeight, enemy.x)) * 70 * dt;
      if (enemy.kind == "crow_bomber") enemy.y += sin(DateTime.now().millisecondsSinceEpoch * 0.005 + enemy.x) * 0.24;
      enemy.shootTimer -= dt;
      if (enemy.shootTimer <= 0) {
        enemyShoot(enemy);
        enemy.shootTimer = enemy.kind == "owl_sniper" ? 1.65 : enemy.kind == "crow_bomber" ? 1.25 : ["toxic_frog", "castle_cannon"].contains(enemy.kind) ? 1.35 : 2.25;
      }
      if (r.player.spinTimer > 0 && circleHit(px, py, enemy.x, enemy.y - enemy.radius * 0.55, spinRadius())) {
        enemy.hp = 0;
      } else if (circleHit(px, py, enemy.x, enemy.y - enemy.radius * 0.55, enemy.radius + r.player.radius * 0.76)) {
        if (r.player.dashTimer > 0) damageEnemy(enemy, 6, true);
        else hurtPlayer(enemy.kind == "armored_weasel" ? 2 : 1);
      }
    }
    r.enemies.retainWhere((enemy) {
      if (enemy.hp <= 0) {
        r.kills += enemy.crate ? 0 : 1;
        addEffect(enemy.crate ? "crate_pop" : "enemy_hit", worldToScreenX(enemy.x), enemy.y - enemy.radius, enemy.crate ? 80.0 : 70);
        if (enemy.crate || Random().nextDouble() < (progress.selectedSkin == "pirate" ? 0.55 : 0.25)) {
          r.pickups.add(Pickup(kind: Random().nextDouble() < 0.08 ? "golden_peanut" : "sunflower_seed", x: enemy.x, y: enemy.y - 50));
        }
        GameAudio.instance.play('enemyDie');
        return false;
      }
      return enemy.x > r.worldX - 190;
    });
  }

  double spinRadius() {
    return progress.selectedSkin == "gym_bro" && (progress.skins["gym_bro"]?.level ?? 1) == 2 ? 98 : 72;
  }

  void enemyShoot(Enemy enemy) {
    final r = run!;
    switch (enemy.kind) {
      case "owl_sniper": r.enemyProjectiles.add(Projectile(kind: "feather", x: enemy.x - 20, y: enemy.y - 20, vx: -430, vy: 115, damage: 1, radius: 10, life: 3)); break;
      case "crow_bomber": r.enemyProjectiles.add(Projectile(kind: "bomb", x: enemy.x, y: enemy.y + 16, vx: -70, vy: 250, damage: 1, radius: 15, life: 3, gravity: 650)); break;
      case "spider_trapper": r.enemyProjectiles.add(Projectile(kind: "web", x: enemy.x - 15, y: enemy.y - 32, vx: -360, vy: -45, damage: 1, radius: 18, life: 2.5, web: true)); break;
      case "toxic_frog": r.enemyProjectiles.add(Projectile(kind: "acid", x: enemy.x - 18, y: enemy.y - 28, vx: -330, vy: -120, damage: 1, radius: 14, life: 3, gravity: 560, color: "#84ff3f")); break;
      case "castle_cannon": r.enemyProjectiles.add(Projectile(kind: "cannon", x: enemy.x - 18, y: enemy.y - 20, vx: -250, vy: 250, damage: 1, radius: 18, life: 3, gravity: 520, color: "#64748b")); break;
      case "royal_guard": r.enemyProjectiles.add(Projectile(kind: "magic", x: enemy.x - 30, y: enemy.y - 55, vx: -450, vy: -40, damage: 1, radius: 14, life: 3, gravity: 120, color: "#60a5fa")); break;
    }
  }

  void updateProjectiles(double dt) {
    final r = run!;
    for (final proj in r.projectiles) {
      // Homing carrot
      if (proj.kind == "carrot") {
        final target = nearestEnemy(proj);
        if (target != null) {
          final lead = _carrotLead(proj, target);
          final desired = atan2(lead.dy - proj.y, lead.dx - proj.x);
          proj.vx += cos(desired) * 1650 * dt;
          proj.vy += sin(desired) * 1650 * dt;
          final speed = proj.vx * proj.vx + proj.vy * proj.vy;
          final sp = speed > 0 ? sqrt(speed) : 1.0;
          final targetSpeed = target is Boss ? 650.0 : 720.0;
          proj.vx = (proj.vx / sp) * targetSpeed;
          proj.vy = (proj.vy / sp) * targetSpeed;
          proj.radius = max(proj.radius, 17);
        }
      }
      // Boomerang
      if (proj.kind == "twig") {
        proj.age += dt;
        if (proj.age > 0.55) proj.returning = true;
        if (proj.returning) {
          final dx = r.worldX - proj.x;
          final dy = r.player.y - proj.y;
          final len = sqrt(dx * dx + dy * dy);
          final l = len > 0 ? len : 1.0;
          proj.vx = (dx / l) * 720;
          proj.vy = (dy / l) * 720;
        }
      }
      proj.x += proj.vx * dt;
      proj.y += proj.vy * dt;
      proj.life -= dt;
      if (proj.pop && proj.life < 1.38 && !proj.popped) {
        proj.popped = true;
        proj.radius = 24;
      }
      // Hit enemies
      for (final enemy in r.enemies) {
        if (enemy.hp > 0 && circleHit(proj.x, proj.y, enemy.x, enemy.y - enemy.radius * 0.55, proj.radius + enemy.radius * 0.7)) {
          double damage = proj.damage;
          if (enemy.armor && !["walnut", "laser", "melon", "sonic"].contains(proj.kind)) damage *= 0.35;
          damageEnemy(enemy, damage, proj.kind == "sonic");
          addEffect("enemy_hit", worldToScreenX(enemy.x), enemy.y - enemy.radius, 34);
          addImpactBurst(worldToScreenX(proj.x), proj.y, proj.kind);
          proj.pierce--;
          if (proj.pierce <= 0) break;
        }
      }
      // Hit boss
      if (r.boss != null && r.boss!.hp > 0 && proj.pierce > 0 && circleHit(proj.x, proj.y, r.boss!.x, r.boss!.y, proj.radius + r.boss!.radius * 0.75)) {
        double damage = proj.damage;
        if (r.boss!.kind == "mecha_fox" && !["walnut", "laser", "melon", "sonic"].contains(proj.kind)) damage *= 0.45;
        if (r.boss!.kind == "bulking_lizard" && proj.kind != "walnut") damage *= 0.65;
        if (r.boss!.kind == "spiky_hedgehog" && proj.x < r.boss!.x) damage *= 0.55;
        r.boss!.hp -= damage;
        addEffect("enemy_hit", worldToScreenX(r.boss!.x), r.boss!.y, 48);
        addImpactBurst(worldToScreenX(proj.x), proj.y, proj.kind);
        proj.pierce--;
      }
    }

    // Enemy projectiles
    for (final shot in r.enemyProjectiles) {
      if (shot.zigzag) shot.vy += sin(DateTime.now().millisecondsSinceEpoch * 0.015 + shot.x * 0.02) * 1100 * dt;
      shot.vy += (shot.gravity > 0 ? shot.gravity : 80.0) * dt;
      shot.x += shot.vx * dt;
      shot.y += shot.vy * dt;
      shot.life -= dt;
      if (shot.y > terrainY(r, gameHeight, shot.x) && ["bomb", "acid", "plate", "cannon", "whey"].contains(shot.kind)) shot.life = 0;
      if (circleHit(r.worldX, r.player.y, shot.x, shot.y, shot.radius + r.player.radius * 0.65)) {
        if (r.player.spinTimer > 0) {
          shot.life = 0;
          addEffect("enemy_hit", worldToScreenX(shot.x), shot.y, 48);
          GameAudio.instance.play('hit');
          continue;
        }
        if (shot.web) {
          r.slowTimer = 3;
          r.player.jumpLockTimer = max(r.player.jumpLockTimer, 3.0);
        } else {
          hurtPlayer(1);
        }
        addEffect(shot.web ? "dash_swirl" : "enemy_hit", worldToScreenX(shot.x), shot.y, 48);
        shot.life = 0;
      }
    }

    r.projectiles.retainWhere((p) => p.life > 0 && p.pierce > 0 && p.x < r.worldX + gameWidth + 260 && p.x > r.worldX - 180);
    r.enemyProjectiles.retainWhere((s) => s.life > 0 && s.x > r.worldX - 180);
  }

  dynamic nearestEnemy(Projectile proj) {
    final r = run!;
    dynamic best = r.boss;
    double bestDist = double.infinity;
    if (best != null) {
      final dx = (best as Boss).x - proj.x;
      final dy = best.y - proj.y;
      bestDist = dx * dx + dy * dy;
    }
    for (final enemy in r.enemies) {
      final dx = enemy.x - proj.x;
      final dy = enemy.y - proj.y;
      final dist = dx * dx + dy * dy;
      if (dx > -40 && dist < bestDist) {
        best = enemy;
        bestDist = dist;
      }
    }
    return best;
  }

  Offset _carrotLead(Projectile proj, dynamic target) {
    final r = run!;
    final targetVx = target is Boss ? r.speed * 0.42 : (target.vx ?? 0);
    final targetVy = target is Boss ? cos((target.t ?? 0) * 2) * 55 : (target.ground ? terrainSlope(r, gameHeight, target.x) * (target.vx ?? 0) : 0.0);
    final distance = sqrt((target.x - proj.x) * (target.x - proj.x) + (target.y - proj.y) * (target.y - proj.y));
    final travelTime = clamp(distance / 720, 0.08, target is Boss ? 0.42 : 0.62);
    return Offset(
      target.x + targetVx * travelTime,
      target.y - (target.radius ?? 36) * 0.58 + targetVy * travelTime,
    );
  }

  void damageEnemy(Enemy enemy, double damage, bool melee) {
    double d = damage;
    if (enemy.armor && melee && progress.selectedSkin == "gym_bro" && (progress.skins["gym_bro"]?.level ?? 1) == 2) d *= 2.4;
    enemy.hp -= d;
    if (melee && progress.selectedSkin == "knight" && (progress.skins["knight"]?.level ?? 1) == 2) enemy.hp -= 0.8;
  }

  void updateHazards() {
    final r = run!;
    for (final hazard in r.hazards) {
      hazard.y = terrainY(r, gameHeight, hazard.x);
      if (!hazard.warned && hazard.x - r.worldX < gameWidth * 0.58) hazard.warned = true;
      if (circleHit(r.worldX, r.player.y + r.player.radius * 0.4, hazard.x, hazard.y - 12, hazard.radius + 20)) {
        if (hazard.kind == "mud_puddle") r.slowTimer = 2.3;
        else hurtPlayer(1);
        hazard.x = r.worldX - 999;
      }
    }
    r.hazards.retainWhere((h) => h.x > r.worldX - 160);
  }

  void hurtPlayer(int amount) {
    final r = run!;
    if (r.player.hurtTimer > 0 || r.player.dashTimer > 0) return;
    if (r.shieldReady) {
      r.shieldReady = false;
      r.labels.add(Label(text: "Shield!", x: screenPlayerX(), y: r.player.y - 70, color: "#9efcff"));
      r.player.hurtTimer = 0.8;
      return;
    }
    double damage = amount.toDouble();
    if (progress.selectedSkin == "knight") damage *= 0.55;
    r.hp -= max(1, damage.round());
    r.player.hurtTimer = 0.95;
    addEffect("enemy_hit", screenPlayerX(), r.player.y - 10, 78);
    GameAudio.instance.play('playerHurt');
    if (r.hp <= 0) maybeReviveOrEnd();
  }

  bool maybeReviveOrEnd() {
    final r = run!;
    if (progress.selectedSkin == "zombie" && !r.reviveUsed) {
      final level = progress.skins["zombie"]!.level;
      if (level == 2 || Random().nextDouble() < 0.1) {
        r.reviveUsed = true;
        r.hp = max(1, (r.maxHp * 0.3).ceil());
        r.player.hurtTimer = 1.4;
        r.labels.add(Label(text: "Revived!", x: screenPlayerX(), y: r.player.y - 80, color: "#92ff75", duration: 1.2));
        for (final enemy in r.enemies) {
          if ((enemy.x - r.worldX).abs() < 220) enemy.hp -= 4;
        }
        return true;
      }
    }
    return false;
  }

  void updateEffects(double dt) {
    final r = run!;
    for (final e in r.effects) e.t += dt;
    for (final l in r.labels) { l.t += dt; l.y -= dt * 24; }
    r.effects.retainWhere((e) => e.t < e.duration);
    r.labels.retainWhere((l) => l.t < l.duration);
  }
}
