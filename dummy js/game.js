const ASSET_KEYS = {
  backdrop: "BACKYARD_BACKDROP",
  player: "PLAYER_SPRITE_SHEET",
  props: "ENEMY_PROP_ATLAS",
  weaponIcons: "WEAPON_ICON_ATLAS",
  skinIcons: "SKIN_ICON_ATLAS",
  effects: "EFFECT_SHEET",
  terrain: "TERRAIN_TEXTURE_ATLAS",
  actionUi: "ACTION_UI_ATLAS",
  advancedEntities: "ADVANCED_ENEMY_BOSS_ATLAS",
  advancedTerrain: "ADVANCED_TERRAIN_TEXTURE_ATLAS",
  playerSkinBodies: "PLAYER_SKIN_BODY_ATLAS",
  weaponCutouts: "WEAPON_CUTOUT_ATLAS",
  bossAnimA: "BOSS_ANIMATION_SHEET_A",
  bossAnimB: "BOSS_ANIMATION_SHEET_B",
  defeatAnimA: "SKIN_DEFEAT_SHEET_A",
  defeatAnimB: "SKIN_DEFEAT_SHEET_B",
};

const SAVE_VERSION = 1;
const GRAVITY = 1450;

const LEVEL_LENGTH = 320;

const BIOMES = [
  {
    level: 1,
    id: "backyard",
    name: "Sunny Backyard",
    start: 0,
    length: LEVEL_LENGTH,
    exclusiveEnemy: "rat_charger",
    bossKind: "rat_charger",
    bossName: "Bully Rat Boss",
    color: "#8ed957",
    ridge: "#69bf3d",
    shadow: "#236c30",
    skyTint: "rgba(66, 178, 255, 0.08)",
    amp: 58,
    freq: 0.0062,
  },
  {
    level: 2,
    id: "attic",
    name: "Dusty Attic",
    start: LEVEL_LENGTH,
    length: LEVEL_LENGTH,
    exclusiveEnemy: "spider_trapper",
    bossKind: "spider_trapper",
    bossName: "Web Queen",
    color: "#b48758",
    ridge: "#8e633f",
    shadow: "#4e3326",
    skyTint: "rgba(82, 45, 25, 0.35)",
    amp: 72,
    freq: 0.0084,
  },
  {
    level: 3,
    id: "cafe",
    name: "Bustling Cafe",
    start: LEVEL_LENGTH * 2,
    length: LEVEL_LENGTH,
    exclusiveEnemy: "caffeine_roach",
    bossKind: "caffeine_roach",
    bossName: "Caffeine Roach",
    color: "#d2a968",
    ridge: "#b77d3d",
    shadow: "#5c341e",
    skyTint: "rgba(255, 168, 80, 0.24)",
    amp: 88,
    freq: 0.0102,
  },
  {
    level: 4,
    id: "sewer",
    name: "Neon Sewers",
    start: LEVEL_LENGTH * 3,
    length: LEVEL_LENGTH,
    exclusiveEnemy: "toxic_frog",
    bossKind: "toxic_frog",
    bossName: "Toxic Spitter",
    color: "#34d399",
    ridge: "#177b63",
    shadow: "#073d35",
    skyTint: "rgba(0, 255, 163, 0.34)",
    amp: 64,
    freq: 0.012,
  },
  {
    level: 5,
    id: "factory",
    name: "Cyborg Factory",
    start: LEVEL_LENGTH * 4,
    length: LEVEL_LENGTH,
    exclusiveEnemy: "mecha_fox",
    bossKind: "mecha_fox",
    bossName: "Mecha Fox",
    color: "#f2c84b",
    ridge: "#68707a",
    shadow: "#222932",
    skyTint: "rgba(34, 40, 52, 0.55)",
    amp: 96,
    freq: 0.0094,
  },
  {
    level: 6,
    id: "bamboo",
    name: "Bamboozle Forest",
    start: LEVEL_LENGTH * 5,
    length: LEVEL_LENGTH,
    exclusiveEnemy: "ninja_weasel",
    bossKind: "ninja_weasel",
    bossName: "Mist Assassin",
    color: "#86efac",
    ridge: "#3f9b55",
    shadow: "#17462c",
    skyTint: "rgba(114, 255, 176, 0.25)",
    amp: 104,
    freq: 0.0078,
  },
  {
    level: 7,
    id: "thrift",
    name: "Thrift Warehouse",
    start: LEVEL_LENGTH * 6,
    length: LEVEL_LENGTH,
    exclusiveEnemy: "moth_swarm",
    bossKind: "moth_swarm",
    bossName: "Moth Swarm",
    color: "#f0abfc",
    ridge: "#9d6bd1",
    shadow: "#3b2457",
    skyTint: "rgba(236, 72, 153, 0.2)",
    amp: 78,
    freq: 0.009,
  },
  {
    level: 8,
    id: "gym",
    name: "Iron Gym",
    start: LEVEL_LENGTH * 7,
    length: LEVEL_LENGTH,
    exclusiveEnemy: "bulking_lizard",
    bossKind: "bulking_lizard",
    bossName: "Bulking Lizard",
    color: "#f97316",
    ridge: "#53565f",
    shadow: "#1f2229",
    skyTint: "rgba(249, 115, 22, 0.25)",
    amp: 112,
    freq: 0.0088,
  },
  {
    level: 9,
    id: "den",
    name: "Hedgehog Den",
    start: LEVEL_LENGTH * 8,
    length: LEVEL_LENGTH,
    exclusiveEnemy: "spiky_hedgehog",
    bossKind: "spiky_hedgehog",
    bossName: "Spiky Tank",
    color: "#a78bfa",
    ridge: "#6247a6",
    shadow: "#25133d",
    skyTint: "rgba(124, 58, 237, 0.32)",
    amp: 84,
    freq: 0.0125,
  },
  {
    level: 10,
    id: "citadel",
    name: "Guild Citadel",
    start: LEVEL_LENGTH * 9,
    length: LEVEL_LENGTH,
    exclusiveEnemy: "royal_guard",
    bossKind: "boss_silhouette",
    bossName: "Guild Madking",
    color: "#fde68a",
    ridge: "#8b7a66",
    shadow: "#34251e",
    skyTint: "rgba(251, 191, 36, 0.22)",
    amp: 118,
    freq: 0.0108,
  },
];

const WEAPONS = [
  ["seed_gatling", "Seed Gatling", "Fast seed stream", "Twin spread barrel", 0, 70],
  ["walnut_cannon", "Walnut Cannon", "Explosive walnut", "Cluster shrapnel", 140, 210],
  ["laser_pointer", "Laser Pointer", "Pierces armor", "Prism ricochet", 170, 250],
  ["carrot_missile", "Carrot Missile", "Homing carrot", "Double volley", 210, 310],
  ["cheese_thrower", "Cheese Thrower", "Slow cone spray", "Sticky puddle", 170, 260],
  ["peanut_splat", "Peanut Splat", "Close shotgun", "Mini stun chunks", 150, 230],
  ["boomerang_twig", "Boomerang Twig", "Returns through foes", "Sharper return", 190, 280],
  ["sonic_squeak", "Sonic Squeak", "Deflects shots", "Bigger shockwave", 220, 330],
  ["melon_sniper", "Melon Sniper", "High damage line", "Pierces 3 foes", 190, 290],
  ["corn_cob", "Corn-Cob Shot", "Three-shot burst", "Popcorn burst", 160, 240],
].map(([id, name, trait, level2, cost, upgradeCost]) => ({ id, name, trait, level2, cost, upgradeCost }));

const WEAPON_AMMO = {
  seed_gatling: [30, 42, 1.1],
  walnut_cannon: [4, 5, 1.85],
  laser_pointer: [12, 16, 1.45],
  carrot_missile: [6, 8, 1.65],
  cheese_thrower: [24, 30, 1.35],
  peanut_splat: [8, 10, 1.35],
  boomerang_twig: [5, 7, 1.25],
  sonic_squeak: [6, 8, 1.7],
  melon_sniper: [5, 6, 1.55],
  corn_cob: [12, 15, 1.4],
};

const TERRAIN_FRAME_BY_BIOME = {
  backyard: "backyard_grass",
  attic: "attic_planks",
  cafe: "cafe_table",
  sewer: "neon_slime",
  factory: "factory_metal",
  bamboo: "bamboo_forest",
  thrift: "thrift_cloth",
  gym: "iron_gym",
  den: "crystal_den",
  citadel: "guild_marble",
};

const ADVANCED_ENTITY_KINDS = new Set([
  "caffeine_roach",
  "toxic_frog",
  "mecha_fox",
  "ninja_weasel",
  "moth_swarm",
  "bulking_lizard",
  "spiky_hedgehog",
  "royal_guard",
  "boss_silhouette",
  "castle_cannon",
]);

const ADVANCED_TERRAIN_FRAMES = new Set(["bamboo_forest", "thrift_cloth", "iron_gym", "crystal_den", "guild_marble"]);

const SKINS = [
  ["classic", "Classic", "Clean starter", "+5% seed drops", 0, 60],
  ["ninja", "Ninja", "+speed dash", "Dash invincible", 120, 190],
  ["mecha", "Mecha", "+1 HP", "Run shield", 150, 240],
  ["agent_h", "Agent H", "+10% seeds", "Coin magnet", 160, 260],
  ["pirate", "Pirate", "+loot chance", "+3s powerups", 150, 230],
  ["astronaut", "Astronaut", "Floatier jumps", "Triple jump", 170, 260],
  ["zombie", "Zombie", "10% revive", "One sure revive", 190, 310],
  ["knight", "Knight", "Melee armor", "Reflect thorns", 180, 280],
  ["wizard", "Wizard", "Skill cooldown", "+2s skills", 170, 270],
  ["gym_bro", "Gym Bro", "+spin damage", "Wide armor break", 160, 250],
].map(([id, name, trait, level2, cost, upgradeCost]) => ({ id, name, trait, level2, cost, upgradeCost }));

function defaultProgress() {
  return {
    version: SAVE_VERSION,
    bestMeters: 0,
    seeds: 90,
    peanuts: 0,
    selectedWeapon: "seed_gatling",
    selectedSkin: "classic",
    weapons: Object.fromEntries(WEAPONS.map((weapon) => [weapon.id, { unlocked: weapon.cost === 0, level: 1 }])),
    skins: Object.fromEntries(SKINS.map((skin) => [skin.id, { unlocked: skin.cost === 0, level: 1 }])),
  };
}

function normalizeProgress(saved) {
  const base = defaultProgress();
  if (!saved || saved.version !== SAVE_VERSION) return base;
  return {
    ...base,
    bestMeters: finiteNumber(saved.bestMeters, 0),
    seeds: finiteNumber(saved.seeds, base.seeds),
    peanuts: finiteNumber(saved.peanuts, 0),
    selectedWeapon: WEAPONS.some((weapon) => weapon.id === saved.selectedWeapon) ? saved.selectedWeapon : base.selectedWeapon,
    selectedSkin: SKINS.some((skin) => skin.id === saved.selectedSkin) ? saved.selectedSkin : base.selectedSkin,
    weapons: mergeCollection(base.weapons, saved.weapons),
    skins: mergeCollection(base.skins, saved.skins),
  };
}

function mergeCollection(base, saved = {}) {
  const result = { ...base };
  for (const id of Object.keys(result)) {
    const item = saved[id];
    if (item) result[id] = { unlocked: Boolean(item.unlocked), level: item.level === 2 ? 2 : 1 };
  }
  return result;
}

function finiteNumber(value, fallback) {
  return Number.isFinite(Number(value)) ? Number(value) : fallback;
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function circleHit(a, b, radius) {
  const dx = a.x - b.x;
  const dy = a.y - b.y;
  return dx * dx + dy * dy <= radius * radius;
}

function urlFor(assets, id, fallback) {
  try {
    return assets?.get ? assets.get(id) : fallback;
  } catch {
    return fallback;
  }
}

function frameUrlFromImage(url) {
  return url.replace(/\.webp(?:\?.*)?$/u, ".frames.json");
}

function imagePromise(url) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.decoding = "async";
    image.onload = () => resolve(image);
    image.onerror = () => reject(new Error(`Could not load ${url}`));
    image.src = url;
  });
}

async function loadSheet(url) {
  const [image, frames] = await Promise.all([
    imagePromise(url),
    fetch(frameUrlFromImage(url)).then((response) => {
      if (!response.ok) throw new Error(`Could not load frame data for ${url}`);
      return response.json();
    }),
  ]);
  return { image, frames, byName: indexFrames(frames), animations: indexAnimations(frames) };
}

function indexFrames(sheet) {
  return Object.fromEntries(sheet.frames.map((frame) => [frame.name, frame]));
}

function indexAnimations(sheet) {
  return Object.fromEntries((sheet.animations || []).map((animation) => [animation.name, animation.frames]));
}

function drawFrameAnchored(ctx, image, frame, x, y, scale, alpha = 1, rotation = 0) {
  if (!frame) return;
  const source = frame.source;
  const crop = frame.content || source;
  const anchor = frame.anchor || { x: source.x + source.w * 0.5, y: source.y + source.h };
  ctx.save();
  ctx.globalAlpha *= alpha;
  ctx.translate(x, y);
  ctx.rotate(rotation);
  ctx.drawImage(
    image,
    crop.x,
    crop.y,
    crop.w,
    crop.h,
    -(anchor.x - crop.x) * scale,
    -(anchor.y - crop.y) * scale,
    crop.w * scale,
    crop.h * scale,
  );
  ctx.restore();
}

function drawFrameByHeight(ctx, image, frame, x, footY, height, alpha = 1, rotation = 0) {
  if (!frame) return;
  const crop = frame.content || frame.source;
  const ratio = crop.w / crop.h;
  const width = height * ratio;
  ctx.save();
  ctx.globalAlpha *= alpha;
  ctx.translate(x, footY - height * 0.5);
  ctx.rotate(rotation);
  ctx.drawImage(image, crop.x, crop.y, crop.w, crop.h, -width * 0.5, -height * 0.5, width, height);
  ctx.restore();
}

function drawFrameInCell(ctx, image, frame, x, y, w, h) {
  if (!frame) return;
  const source = frame.source;
  const crop = frame.content || source;
  const scaleX = w / source.w;
  const scaleY = h / source.h;
  ctx.drawImage(
    image,
    crop.x,
    crop.y,
    crop.w,
    crop.h,
    x + (crop.x - source.x) * scaleX,
    y + (crop.y - source.y) * scaleY,
    crop.w * scaleX,
    crop.h * scaleY,
  );
}

export function createGame({ mount, sdk, ready, tweaks, assets }) {
  let shell;
  let canvas;
  let ctx;
  let overlay;
  let overlayTitle;
  let overlayPrompt;
  let hud;
  let shopPanel;
  let pausePanel;
  let resultPanel;
  let shootControl;
  let shootIconCanvas;
  let shootIconContext;
  let resizeObserver;
  let raf = 0;
  let lastTime = 0;
  let width = 1;
  let height = 1;
  let dpr = 1;
  let loaded = false;
  let started = false;
  let running = false;
  let paused = false;
  let shopReturnAction = "idle";
  let progress = defaultProgress();
  let run;
  let audioHandle = null;
  let audioContext = null;
  let activePointer = null;
  const pressed = { dive: false };
  const unsubscribes = [];
  const media = {
    backdrop: null,
    player: null,
    props: null,
    weapons: null,
    skins: null,
    effects: null,
    terrain: null,
    actionUi: null,
    advancedEntities: null,
    advancedTerrain: null,
    playerSkinBodies: null,
    weaponCutouts: null,
    bossAnimA: null,
    bossAnimB: null,
    defeatAnimA: null,
    defeatAnimB: null,
  };
  const terrainPatterns = new Map();
  const config = {
    startSpeed: readTweak("startSpeed", 370),
    difficultyRamp: readTweak("difficultyRamp", 0.23),
    spawnRate: readTweak("spawnRate", 1),
    seedValue: readTweak("seedValue", 1),
    effectsIntensity: readTweak("effectsIntensity", 1),
  };

  function readTweak(key, fallback) {
    try {
      const value = tweaks?.get?.(key);
      return Number.isFinite(Number(value)) ? Number(value) : fallback;
    } catch {
      return fallback;
    }
  }

  function subscribeTweaks() {
    for (const key of Object.keys(config)) {
      try {
        const unsubscribe = tweaks?.subscribe?.(key, (value) => {
          const numeric = Number(value);
          if (Number.isFinite(numeric)) config[key] = numeric;
        });
        if (typeof unsubscribe === "function") unsubscribes.push(unsubscribe);
      } catch {
        // Live tuning is optional in local preview.
      }
    }
  }

  async function preload() {
    const urls = {
      backdrop: urlFor(assets, ASSET_KEYS.backdrop, "/generated-assets/backyard_backdrop.webp"),
      player: urlFor(assets, ASSET_KEYS.player, "/generated-assets/player_sprite_sheet-transparent.webp"),
      props: urlFor(assets, ASSET_KEYS.props, "/generated-assets/enemy_prop_atlas-transparent.webp"),
      weapons: urlFor(assets, ASSET_KEYS.weaponIcons, "/generated-assets/weapon_icon_atlas-transparent.webp"),
      skins: urlFor(assets, ASSET_KEYS.skinIcons, "/generated-assets/skin_icon_atlas-transparent.webp"),
      effects: urlFor(assets, ASSET_KEYS.effects, "/generated-assets/effect_sheet-transparent.webp"),
      terrain: urlFor(assets, ASSET_KEYS.terrain, "/generated-assets/terrain_texture_atlas-transparent.webp"),
      actionUi: urlFor(assets, ASSET_KEYS.actionUi, "/generated-assets/action_ui_atlas-transparent.webp"),
      advancedEntities: urlFor(assets, ASSET_KEYS.advancedEntities, "/generated-assets/advanced_enemy_boss_atlas-transparent.webp"),
      advancedTerrain: urlFor(assets, ASSET_KEYS.advancedTerrain, "/generated-assets/advanced_terrain_texture_atlas-transparent.webp"),
      playerSkinBodies: urlFor(assets, ASSET_KEYS.playerSkinBodies, "/generated-assets/player_skin_body_atlas-transparent.webp"),
      weaponCutouts: urlFor(assets, ASSET_KEYS.weaponCutouts, "/generated-assets/weapon_cutout_atlas-transparent.webp"),
      bossAnimA: urlFor(assets, ASSET_KEYS.bossAnimA, "/generated-assets/boss_animation_sheet_a-transparent.webp"),
      bossAnimB: urlFor(assets, ASSET_KEYS.bossAnimB, "/generated-assets/boss_animation_sheet_b-transparent.webp"),
      defeatAnimA: urlFor(assets, ASSET_KEYS.defeatAnimA, "/generated-assets/skin_defeat_sheet_a-transparent.webp"),
      defeatAnimB: urlFor(assets, ASSET_KEYS.defeatAnimB, "/generated-assets/skin_defeat_sheet_b-transparent.webp"),
    };
    const [
      saved,
      backdrop,
      player,
      props,
      weapons,
      skins,
      effects,
      terrain,
      actionUi,
      advancedEntities,
      advancedTerrain,
      playerSkinBodies,
      weaponCutouts,
      bossAnimA,
      bossAnimB,
      defeatAnimA,
      defeatAnimB,
    ] = await Promise.all([
      sdk.gameState.load().catch(() => null),
      imagePromise(urls.backdrop),
      loadSheet(urls.player),
      loadSheet(urls.props),
      loadSheet(urls.weapons),
      loadSheet(urls.skins),
      loadSheet(urls.effects),
      loadSheet(urls.terrain),
      loadSheet(urls.actionUi),
      loadSheet(urls.advancedEntities),
      loadSheet(urls.advancedTerrain),
      loadSheet(urls.playerSkinBodies),
      loadSheet(urls.weaponCutouts),
      loadSheet(urls.bossAnimA),
      loadSheet(urls.bossAnimB),
      loadSheet(urls.defeatAnimA),
      loadSheet(urls.defeatAnimB),
    ]);
    progress = normalizeProgress(saved);
    media.backdrop = backdrop;
    media.player = player;
    media.props = props;
    media.weapons = weapons;
    media.skins = skins;
    media.effects = effects;
    media.terrain = terrain;
    media.actionUi = actionUi;
    media.advancedEntities = advancedEntities;
    media.advancedTerrain = advancedTerrain;
    media.playerSkinBodies = playerSkinBodies;
    media.weaponCutouts = weaponCutouts;
    media.bossAnimA = bossAnimA;
    media.bossAnimB = bossAnimB;
    media.defeatAnimA = defeatAnimA;
    media.defeatAnimB = defeatAnimB;
    loaded = true;
    overlayPrompt.textContent = "Tap to run";
    resetRun(false);
    renderHud();
    render(0);
  }

  function ammoCapacity(weapon = selectedWeapon()) {
    const level = progress.weapons[weapon.id]?.level || 1;
    const values = WEAPON_AMMO[weapon.id] || WEAPON_AMMO.seed_gatling;
    return level === 2 ? values[1] : values[0];
  }

  function reloadDuration(weapon = selectedWeapon()) {
    const level = progress.weapons[weapon.id]?.level || 1;
    const values = WEAPON_AMMO[weapon.id] || WEAPON_AMMO.seed_gatling;
    return Math.max(0.65, values[2] * (level === 2 ? 0.9 : 1));
  }

  function startReload(force = false) {
    if (!run || (!force && run.player.reloadTimer > 0)) return;
    run.player.reloadDuration = reloadDuration();
    run.player.reloadTimer = run.player.reloadDuration;
    run.player.fireCooldown = Math.max(run.player.fireCooldown, 0.15);
    addLabel("Reload!", screenPlayerX() + 60, run.player.y - 58, "#ffe15f", 0.75);
    haptic(18);
  }

  function makeRun() {
    const skinState = progress.skins[progress.selectedSkin] || { level: 1 };
    const maxHp = 4 + (progress.selectedSkin === "mecha" ? 1 : 0);
    return {
      worldX: 0,
      levelIndex: 0,
      levelMeters: 0,
      meters: 0,
      speed: config.startSpeed,
      boss: null,
      bossIntroTimer: 0,
      defeatAt: 0,
      hp: maxHp,
      maxHp,
      seeds: 0,
      peanuts: 0,
      kills: 0,
      crateTimer: 0.8,
      seedTimer: 0.2,
      enemyTimer: 1.4,
      hazardTimer: 2.8,
      biomeNoticeTimer: 1.8,
      lastBiome: "backyard",
      slowTimer: 0,
      reviveUsed: false,
      shieldReady: progress.selectedSkin === "mecha" && skinState.level === 2,
      player: {
        y: height * 0.62,
        vy: 0,
        grounded: true,
        jumpsLeft: progress.selectedSkin === "astronaut" && skinState.level === 2 ? 3 : 2,
        radius: 31,
        fireCooldown: 0,
        ammo: ammoCapacity(),
        reloadTimer: 0,
        reloadDuration: reloadDuration(),
        reloadFlash: 0,
        jumpLockTimer: 0,
        spinTimer: 0,
        spinCooldown: 0,
        hurtTimer: 0,
        dashTimer: 0,
        weaponFlash: 0,
      },
      pickups: [],
      enemies: [],
      hazards: [],
      projectiles: [],
      enemyProjectiles: [],
      effects: [],
      labels: [],
    };
  }

  function resetRun(shouldStart = true) {
    run = makeRun();
    const ground = terrainY(run.worldX);
    run.player.y = ground - run.player.radius;
    if (shouldStart) {
      running = true;
      paused = false;
      started = true;
      overlay.hidden = true;
      resultPanel.hidden = true;
      pausePanel.hidden = true;
      shopPanel.hidden = true;
    }
  }

  function currentBiome() {
    return BIOMES[clamp(run?.levelIndex ?? 0, 0, BIOMES.length - 1)] || BIOMES[0];
  }

  function levelProgressRatio() {
    if (!run) return 0;
    return clamp(run.levelMeters / currentBiome().length, 0, 1);
  }

  function terrainY(worldX) {
    const biome = run ? currentBiome() : BIOMES[0];
    const base = height * 0.69;
    const ridge = Math.sin(worldX * biome.freq) * biome.amp;
    const detail = Math.sin(worldX * biome.freq * 0.43 + 1.7) * biome.amp * 0.32;
    return clamp(base + ridge + detail, height * 0.48, height * 0.83);
  }

  function terrainSlope(worldX) {
    return (terrainY(worldX + 12) - terrainY(worldX - 12)) / 24;
  }

  async function persistProgress() {
    try {
      await sdk.gameState.save(progress);
    } catch {
      // Preview may not persist; the run remains playable.
    }
  }

  async function unlockAudio() {
    if (audioContext) return;
    try {
      audioHandle = await sdk.audio.getContext();
      await audioHandle.unlock();
      audioContext = audioHandle.context;
    } catch {
      audioContext = null;
    }
  }

  function sound(kind) {
    if (!audioContext) return;
    const now = audioContext.currentTime;
    const osc = audioContext.createOscillator();
    const gain = audioContext.createGain();
    const presets = {
      jump: [420, 660, 0.09],
      shoot: [840, 560, 0.045],
      seed: [980, 1320, 0.06],
      hit: [180, 90, 0.12],
      boom: [90, 55, 0.18],
      buy: [520, 1040, 0.12],
    };
    const [a, b, duration] = presets[kind] || presets.seed;
    osc.type = kind === "boom" ? "sawtooth" : "triangle";
    osc.frequency.setValueAtTime(a, now);
    osc.frequency.exponentialRampToValueAtTime(Math.max(40, b), now + duration);
    gain.gain.setValueAtTime(0.001, now);
    gain.gain.exponentialRampToValueAtTime(0.045, now + 0.01);
    gain.gain.exponentialRampToValueAtTime(0.001, now + duration);
    osc.connect(gain);
    gain.connect(audioContext.destination);
    osc.start(now);
    osc.stop(now + duration + 0.02);
  }

  function haptic(ms = 22) {
    try {
      if (sdk.device?.haptics?.isSupported?.()) sdk.device.haptics.vibrate(ms);
    } catch {
      // Haptics are best-effort.
    }
  }

  function jump() {
    if (!running || paused) return;
    if (run.player.jumpLockTimer > 0) {
      addLabel("Webbed!", screenPlayerX(), run.player.y - 54, "#dbeafe", 0.55);
      return;
    }
    const skin = progress.selectedSkin;
    const floatBonus = skin === "astronaut" ? 0.9 : 1;
    if (run.player.grounded) {
      run.player.vy = -620 * floatBonus;
      run.player.grounded = false;
      run.player.jumpsLeft = skin === "astronaut" && progress.skins.astronaut.level === 2 ? 2 : 1;
      addLabel("Hop!", screenPlayerX(), run.player.y - 50, "#fff6a7");
    } else if (run.player.jumpsLeft > 0) {
      run.player.vy = -560 * floatBonus;
      run.player.jumpsLeft -= 1;
      addEffect("dash_swirl", screenPlayerX(), run.player.y + 12, 62);
    }
    sound("jump");
  }

  function spin() {
    if (!running || paused || run.player.spinCooldown > 0) return;
    const level = progress.skins[progress.selectedSkin]?.level || 1;
    run.player.spinTimer = progress.selectedSkin === "gym_bro" ? 0.62 : 0.48;
    run.player.spinCooldown = progress.selectedSkin === "wizard" ? 0.72 : 1.05;
    if (progress.selectedSkin === "ninja" && level === 2) run.player.dashTimer = 0.42;
    addEffect("dash_swirl", screenPlayerX(), run.player.y + 10, 88);
    sound("boom");
    haptic(32);
  }

  function shoot() {
    if (!running || paused || run.player.fireCooldown > 0) return;
    const weapon = selectedWeapon();
    const level = progress.weapons[weapon.id]?.level || 1;
    if (run.player.reloadTimer > 0) {
      haptic(12);
      return;
    }
    if (run.player.ammo <= 0) {
      startReload(true);
      sound("hit");
      return;
    }
    run.player.ammo -= 1;
    const origin = { x: run.worldX + 54, y: run.player.y - 18 };
    run.player.weaponFlash = 0.08;
    addEffect("muzzle_flash", screenPlayerX() + 52, origin.y, 38);
    sound("shoot");
    const add = (projectile) => run.projectiles.push({ life: 2, fromPlayer: true, ...projectile });
    if (weapon.id === "walnut_cannon") {
      add({ kind: "walnut", x: origin.x, y: origin.y, vx: 560, vy: -70, damage: level === 2 ? 3.2 : 2.6, radius: 18, pierce: 1 });
      run.player.fireCooldown = 0.75;
    } else if (weapon.id === "laser_pointer") {
      add({ kind: "laser", x: origin.x, y: origin.y, vx: 1300, vy: 0, damage: 1.8, radius: 7, pierce: level === 2 ? 4 : 2, life: 0.26 });
      run.player.fireCooldown = 0.28;
    } else if (weapon.id === "carrot_missile") {
      const count = level === 2 ? 2 : 1;
      for (let i = 0; i < count; i += 1) add({ kind: "carrot", x: origin.x, y: origin.y + i * 16 - 8, vx: 470, vy: -80 + i * 130, damage: 1.7, radius: 14, pierce: 1 });
      run.player.fireCooldown = 0.62;
    } else if (weapon.id === "cheese_thrower") {
      for (let i = 0; i < 5; i += 1) add({ kind: "cheese", x: origin.x, y: origin.y + (i - 2) * 9, vx: 410 + i * 18, vy: (i - 2) * 35, damage: 0.7, radius: level === 2 ? 18 : 14, pierce: 1, slow: level === 2 ? 1.4 : 0.8, life: 0.62 });
      run.player.fireCooldown = 0.22;
    } else if (weapon.id === "peanut_splat") {
      for (let i = 0; i < 5; i += 1) add({ kind: "peanut", x: origin.x, y: origin.y, vx: 520, vy: (i - 2) * 110, damage: level === 2 ? 1.15 : 0.95, radius: 13, pierce: 1, stun: level === 2 ? 0.35 : 0 });
      run.player.fireCooldown = 0.5;
    } else if (weapon.id === "boomerang_twig") {
      add({ kind: "twig", x: origin.x, y: origin.y, vx: 600, vy: -20, damage: level === 2 ? 1.4 : 1, radius: 18, pierce: 4, returning: false, age: 0 });
      run.player.fireCooldown = 0.8;
    } else if (weapon.id === "sonic_squeak") {
      add({ kind: "sonic", x: origin.x, y: origin.y, vx: 460, vy: 0, damage: level === 2 ? 1.25 : 0.9, radius: level === 2 ? 50 : 34, pierce: 6, life: 0.75, deflect: true });
      run.player.fireCooldown = 0.65;
    } else if (weapon.id === "melon_sniper") {
      add({ kind: "melon", x: origin.x, y: origin.y - 5, vx: 1050, vy: 0, damage: 2.2, radius: 9, pierce: level === 2 ? 3 : 1 });
      run.player.fireCooldown = 0.6;
    } else if (weapon.id === "corn_cob") {
      for (let i = 0; i < 3; i += 1) add({ kind: "corn", x: origin.x, y: origin.y + (i - 1) * 10, vx: 660, vy: (i - 1) * 58, damage: level === 2 ? 0.85 : 0.7, radius: 10, pierce: 1, pop: level === 2 });
      run.player.fireCooldown = 0.38;
    } else {
      const spread = level === 2 ? [-90, 0, 90] : [0];
      for (const vy of spread) add({ kind: "seed", x: origin.x, y: origin.y, vx: 760, vy, damage: 0.62, radius: 8, pierce: 1 });
      run.player.fireCooldown = level === 2 ? 0.12 : 0.1;
    }
    if (run.player.ammo <= 0) startReload(true);
  }

  function selectedWeapon() {
    return WEAPONS.find((weapon) => weapon.id === progress.selectedWeapon) || WEAPONS[0];
  }

  function selectedSkin() {
    return SKINS.find((skin) => skin.id === progress.selectedSkin) || SKINS[0];
  }

  function screenPlayerX() {
    return Math.min(width * 0.3, 150);
  }

  function worldToScreenX(x) {
    return screenPlayerX() + (x - run.worldX);
  }

  function screenToWorldX(x) {
    return run.worldX + (x - screenPlayerX());
  }

  function spawnSeedTrail() {
    const start = run.worldX + width * (0.75 + Math.random() * 0.35);
    const count = 5 + Math.floor(Math.random() * 3);
    for (let i = 0; i < count; i += 1) {
      const x = start + i * 42;
      const y = terrainY(x) - 78 - Math.sin(i / Math.max(1, count - 1) * Math.PI) * (70 + Math.random() * 30);
      run.pickups.push({ kind: Math.random() > 0.96 ? "golden_peanut" : "sunflower_seed", x, y, radius: 18, collected: false, spin: Math.random() * 6 });
    }
  }

  function spawnCrate() {
    const x = run.worldX + width * (0.95 + Math.random() * 0.45);
    run.enemies.push({ kind: "wood_crate", x, y: terrainY(x), hp: 1.2, maxHp: 1.2, radius: 35, ground: true, crate: true, armor: false, shootTimer: 0 });
  }

  function spawnEnemy() {
    const meters = run.meters;
    const level = currentBiome();
    const choices = [level.exclusiveEnemy, "wood_crate"];
    if (level.level >= 2) choices.push("spider_trapper");
    if (level.level >= 3) choices.push("caffeine_roach", "owl_sniper");
    if (level.level >= 4) choices.push("toxic_frog", "crow_bomber");
    if (level.level >= 5) choices.push("mecha_fox", "armored_weasel");
    if (level.level >= 6) choices.push("ninja_weasel");
    if (level.level >= 7) choices.push("moth_swarm");
    if (level.level >= 8) choices.push("bulking_lizard");
    if (level.level >= 9) choices.push("spiky_hedgehog");
    if (level.level >= 10) choices.push("royal_guard", "castle_cannon");
    const kind = choices[Math.floor(Math.random() * choices.length)];
    const x = run.worldX + width * (1.05 + Math.random() * 0.45);
    const ground = terrainY(x);
    const stats = {
      wood_crate: [1.2, 0, 35],
      rat_charger: [1.8, -70, 33],
      armored_weasel: [4.2, -28, 43],
      owl_sniper: [2.2, -8, 33],
      crow_bomber: [1.7, -25, 31],
      spider_trapper: [1.9, -42, 29],
      caffeine_roach: [1.5, -140, 28],
      toxic_frog: [2.6, -20, 36],
      mecha_fox: [4.8, -38, 44],
      ninja_weasel: [2.2, -160, 32],
      moth_swarm: [2.4, -60, 42],
      bulking_lizard: [6.5, -22, 52],
      spiky_hedgehog: [3.4, -185, 38],
      royal_guard: [5.2, -115, 48],
      castle_cannon: [3.2, -8, 36],
    }[kind];
    run.enemies.push({
      kind,
      x,
      y: kind === "owl_sniper" || kind === "toxic_frog" || kind === "castle_cannon" ? ground - 215 : kind === "crow_bomber" || kind === "moth_swarm" ? height * (0.27 + Math.random() * 0.14) : ground,
      hp: stats[0] + meters * 0.001,
      maxHp: stats[0] + meters * 0.001,
      vx: stats[1],
      radius: stats[2],
      ground: !["owl_sniper", "crow_bomber", "toxic_frog", "moth_swarm", "castle_cannon"].includes(kind),
      armor: kind === "armored_weasel" || kind === "mecha_fox" || kind === "spiky_hedgehog",
      crate: kind === "wood_crate",
      shootTimer: 0.7 + Math.random() * 1.2,
      stun: 0,
      slow: 0,
    });
  }

  function spawnHazard() {
    const x = run.worldX + width * (1.05 + Math.random() * 0.45);
    const biome = currentBiome().id;
    let kind = Math.random() > 0.5 ? "mud_puddle" : "thorn_spikes";
    if (biome === "sewer" || biome === "factory") kind = Math.random() > 0.35 ? "thorn_spikes" : "mud_puddle";
    run.hazards.push({ kind, x, y: terrainY(x), radius: kind === "mud_puddle" ? 38 : 31, warned: false });
  }

  function update(dt) {
    if (!running || paused || !run) return;
    const player = run.player;
    const biome = currentBiome();
    if (biome.id !== run.lastBiome) {
      run.lastBiome = biome.id;
      run.biomeNoticeTimer = 2.1;
      addLabel(biome.name, width * 0.5, height * 0.25, "#ffffff", 1.5);
    }

    player.fireCooldown = Math.max(0, player.fireCooldown - dt);
    if (player.reloadTimer > 0) {
      player.reloadTimer = Math.max(0, player.reloadTimer - dt);
      if (player.reloadTimer === 0) {
        player.ammo = ammoCapacity();
        player.reloadFlash = 0.34;
        addEffect("pickup_spark", screenPlayerX() + 78, player.y - 32, 52);
        sound("buy");
      }
    }
    player.reloadFlash = Math.max(0, player.reloadFlash - dt);
    player.spinCooldown = Math.max(0, player.spinCooldown - dt);
    player.spinTimer = Math.max(0, player.spinTimer - dt);
    player.dashTimer = Math.max(0, player.dashTimer - dt);
    player.hurtTimer = Math.max(0, player.hurtTimer - dt);
    player.weaponFlash = Math.max(0, player.weaponFlash - dt);
    player.jumpLockTimer = Math.max(0, player.jumpLockTimer - dt);
    run.slowTimer = Math.max(0, run.slowTimer - dt);
    run.bossIntroTimer = Math.max(0, run.bossIntroTimer - dt);
    run.biomeNoticeTimer = Math.max(0, run.biomeNoticeTimer - dt);

    const slope = terrainSlope(run.worldX);
    const downhill = Math.max(0, slope);
    const diveBoost = pressed.dive && player.grounded ? 120 : 0;
    const slowPenalty = run.slowTimer > 0 ? 0.58 : 1;
    const level = currentBiome();
    run.speed = (config.startSpeed + run.meters * config.difficultyRamp + downhill * 130 + diveBoost) * slowPenalty;
    if (currentBiome().id === "sewer") run.speed *= 1.08;
    if (currentBiome().id === "factory" && Math.sin(run.worldX * 0.01) > 0.55) run.speed *= 1.12;
    if (currentBiome().id === "bamboo" && player.grounded && downhill > 0.6) player.vy -= 18;
    if (currentBiome().id === "thrift") run.speed *= 0.88;
    if (run.boss) {
      run.speed = 115 + diveBoost * 0.35;
      run.worldX += run.speed * dt;
      run.levelMeters = level.length;
    } else {
      run.worldX += run.speed * dt;
      run.levelMeters += (run.speed * dt) / 18;
      if (run.levelMeters >= level.length) startBoss(level);
    }
    run.meters = Math.floor(run.levelIndex * LEVEL_LENGTH + Math.min(run.levelMeters, level.length));

    const gravity = GRAVITY * (progress.selectedSkin === "astronaut" ? 0.82 : 1) + (pressed.dive ? 900 : 0);
    player.vy += gravity * dt;
    player.y += player.vy * dt;
    const ground = terrainY(run.worldX) - player.radius;
    if (player.y >= ground && player.vy >= 0) {
      player.y = ground;
      player.vy = 0;
      player.grounded = true;
      player.jumpsLeft = progress.selectedSkin === "astronaut" && progress.skins.astronaut.level === 2 ? 3 : 2;
    } else {
      player.grounded = false;
    }

    if (run.boss) {
      updateBoss(dt);
    } else {
      run.seedTimer -= dt * config.spawnRate;
      run.crateTimer -= dt * config.spawnRate;
      run.enemyTimer -= dt * config.spawnRate;
      run.hazardTimer -= dt * config.spawnRate;
      if (run.seedTimer <= 0) {
        spawnSeedTrail();
        run.seedTimer = 1.15 + Math.random() * 0.8;
      }
      if (run.crateTimer <= 0) {
        spawnCrate();
        run.crateTimer = 4.2 + Math.random() * 2.3;
      }
      if (run.enemyTimer <= 0) {
        spawnEnemy();
        run.enemyTimer = clamp(2.6 - run.meters / 900, 1.05, 2.6) + Math.random() * 0.75;
      }
      if (run.hazardTimer <= 0) {
        spawnHazard();
        run.hazardTimer = clamp(3.4 - run.meters / 1000, 1.6, 3.4) + Math.random() * 0.8;
      }
    }

    updatePickups(dt);
    updateEnemies(dt);
    updateProjectiles(dt);
    updateHazards();
    updateEffects(dt);
    renderHud();
  }

  function startBoss(level) {
    run.levelMeters = level.length;
    run.enemies = [];
    run.hazards = [];
    run.pickups = run.pickups.filter((pickup) => pickup.x < run.worldX + width * 0.6);
    const hp = 13 + level.level * 5.5;
    run.boss = {
      level: level.level,
      kind: level.bossKind,
      name: level.bossName,
      x: run.worldX + width * 0.72,
      y: height * 0.45,
      baseY: height * 0.45,
      hp,
      maxHp: hp,
      radius: level.level >= 8 ? 78 : 64,
      attackTimer: 1.1,
      pattern: 0,
      t: 0,
    };
    run.bossIntroTimer = 2;
    run.player.ammo = Math.max(run.player.ammo, Math.ceil(ammoCapacity() * 0.45));
    addLabel(`BOSS: ${level.bossName}`, width * 0.5, height * 0.27, "#fff6a7", 1.8);
    sound("boom");
    haptic(60);
  }

  function updateBoss(dt) {
    const boss = run.boss;
    if (!boss) return;
    boss.t += dt;
    boss.x += (run.worldX + width * 0.72 - boss.x) * dt * 2.4;
    boss.y = boss.baseY + Math.sin(boss.t * (1.3 + boss.level * 0.08)) * (24 + boss.level * 1.5);
    if (boss.kind === "spiky_hedgehog") boss.y = terrainY(boss.x) - 70 + Math.sin(boss.t * 3) * 18;
    if (boss.kind === "royal_guard" || boss.kind === "boss_silhouette") boss.y += Math.sin(boss.t * 2.4) * 18;
    boss.attackTimer -= dt;
    if (boss.attackTimer <= 0 && run.bossIntroTimer <= 0) {
      bossAttack(boss);
      boss.pattern += 1;
      boss.attackTimer = clamp(1.8 - boss.level * 0.075, 0.85, 1.8);
    }
    if (boss.hp <= 0) defeatBoss();
  }

  function bossAttack(boss) {
    const px = run.worldX;
    const py = run.player.y;
    const fromX = boss.x - boss.radius * 0.5;
    const fromY = boss.y - 20;
    const aim = (speed = 420, gravity = 150) => {
      const dx = px - fromX;
      const dy = py - fromY;
      const len = Math.hypot(dx, dy) || 1;
      return { vx: (dx / len) * speed, vy: (dy / len) * speed - gravity * 0.25 };
    };
    const add = (shot) => run.enemyProjectiles.push({ life: 4, radius: 14, web: false, gravity: 90, color: "#fef08a", ...shot });
    if (boss.level === 1) {
      for (const offset of [-26, 18]) add({ kind: "boss", x: fromX, y: fromY + offset, vx: -430, vy: offset * 1.2, radius: 13, color: "#b08968" });
    } else if (boss.level === 2) {
      for (const offset of [-35, 0, 35]) add({ kind: "web", x: fromX, y: fromY + offset, vx: -360, vy: offset * 1.5, radius: 18, web: true, gravity: 50, color: "#e8f5ff" });
    } else if (boss.level === 3) {
      for (let i = 0; i < 4; i += 1) add({ kind: "spark", x: fromX - i * 20, y: fromY + Math.sin(i) * 42, vx: -360 - i * 55, vy: (i % 2 ? 170 : -120), radius: 12, zigzag: true, color: "#fbbf24" });
    } else if (boss.level === 4) {
      for (const offset of [-0.55, -0.25, 0.1]) {
        const v = aim(520 + boss.pattern * 8, -120);
        add({ kind: "acid", x: fromX, y: fromY, vx: v.vx, vy: v.vy + offset * 260, radius: 15, gravity: 620, color: "#84ff3f" });
      }
    } else if (boss.level === 5) {
      add({ kind: "laser", x: fromX, y: py - 10, vx: -560, vy: 0, radius: 16, gravity: 0, color: "#fb7185" });
      add({ kind: "bomb", x: fromX + 30, y: fromY - 35, vx: -150, vy: 210, radius: 17, gravity: 520, color: "#94a3b8" });
    } else if (boss.level === 6) {
      for (let i = 0; i < 3; i += 1) add({ kind: "slash", x: fromX + i * 10, y: height * (0.28 + i * 0.16), vx: -500, vy: 120 - i * 80, radius: 18, gravity: 0, color: "#7cff9e" });
    } else if (boss.level === 7) {
      for (let i = 0; i < 5; i += 1) add({ kind: "moth", x: fromX + i * 12, y: height * (0.25 + i * 0.1), vx: -300 - i * 35, vy: Math.sin(i) * 90, radius: 15, gravity: 20, color: "#f0abfc" });
    } else if (boss.level === 8) {
      add({ kind: "plate", x: fromX, y: terrainY(fromX) - 100, vx: -520, vy: -80, radius: 26, gravity: 700, color: "#cbd5e1" });
      add({ kind: "whey", x: fromX - 20, y: fromY, vx: -350, vy: 170, radius: 18, web: true, gravity: 450, color: "#fef3c7" });
    } else if (boss.level === 9) {
      for (let i = 0; i < 3; i += 1) add({ kind: "spike", x: fromX, y: terrainY(fromX) - 40 - i * 35, vx: -470 - i * 50, vy: -120 + i * 80, radius: 16, gravity: 380, color: "#c4b5fd" });
    } else {
      for (let i = 0; i < 5; i += 1) {
        const angle = -2.9 + i * 0.35;
        add({ kind: "magic", x: fromX, y: fromY, vx: Math.cos(angle) * 430, vy: Math.sin(angle) * 300, radius: 16, gravity: 80, color: i % 2 ? "#fbbf24" : "#60a5fa" });
      }
      if (boss.pattern % 3 === 0) add({ kind: "cannon", x: fromX - 70, y: height * 0.22, vx: -170, vy: 360, radius: 24, gravity: 520, color: "#64748b" });
    }
    sound("hit");
  }

  async function defeatBoss() {
    const defeated = run.boss;
    if (!defeated) return;
    run.boss = null;
    run.enemyProjectiles = [];
    addEffect("crate_pop", width * 0.72, defeated.y, 128);
    addLabel(`${defeated.name} cleared!`, width * 0.5, height * 0.28, "#a7f3d0", 1.5);
    run.seeds += 20 + defeated.level * 5;
    run.peanuts += defeated.level % 2 === 0 ? 1 : 0;
    sound("boom");
    haptic(90);
    if (run.levelIndex >= BIOMES.length - 1) {
      await endRun(true);
      return;
    }
    run.levelIndex += 1;
    run.levelMeters = 0;
    run.meters = run.levelIndex * LEVEL_LENGTH;
    run.lastBiome = currentBiome().id;
    run.biomeNoticeTimer = 2;
    run.seedTimer = 0.4;
    run.enemyTimer = 1.2;
    run.hazardTimer = 2.4;
    run.player.ammo = ammoCapacity();
    run.player.reloadTimer = 0;
    addLabel(`Level ${currentBiome().level}: ${currentBiome().name}`, width * 0.5, height * 0.24, "#fff6a7", 1.6);
    await persistProgress();
  }

  function updatePickups(dt) {
    const px = run.worldX;
    const py = run.player.y;
    const magnet = progress.selectedSkin === "agent_h" && progress.skins.agent_h.level === 2;
    for (const pickup of run.pickups) {
      pickup.spin += dt * 5;
      if (magnet && Math.abs(pickup.x - px) < 180) {
        pickup.x += (px - pickup.x) * dt * 3.2;
        pickup.y += (py - pickup.y) * dt * 3.2;
      }
      if (!pickup.collected && circleHit({ x: px, y: py }, pickup, magnet ? 60 : 34)) {
        pickup.collected = true;
        if (pickup.kind === "golden_peanut") run.peanuts += 1;
        else run.seeds += seedGain();
        addEffect("pickup_spark", worldToScreenX(pickup.x), pickup.y, 38);
        sound("seed");
      }
    }
    run.pickups = run.pickups.filter((pickup) => !pickup.collected && pickup.x > run.worldX - 160);
  }

  function seedGain() {
    let gain = config.seedValue;
    if (progress.selectedSkin === "agent_h") gain *= 1.1;
    if (progress.selectedSkin === "classic" && progress.skins.classic.level === 2) gain *= 1.05;
    return Math.max(1, Math.round(gain));
  }

  function updateEnemies(dt) {
    const playerWorld = { x: run.worldX, y: run.player.y };
    for (const enemy of run.enemies) {
      enemy.stun = Math.max(0, enemy.stun - dt);
      enemy.slow = Math.max(0, enemy.slow - dt);
      if (enemy.ground) enemy.y = terrainY(enemy.x);
      if (enemy.stun <= 0) enemy.x += (enemy.vx || 0) * dt * (enemy.slow > 0 ? 0.45 : 1);
      if (enemy.kind === "caffeine_roach") enemy.y += Math.sin(performance.now() * 0.018 + enemy.x * 0.03) * 2.8;
      if (enemy.kind === "ninja_weasel") enemy.y += Math.sin(performance.now() * 0.01 + enemy.x) * 1.7;
      if (enemy.kind === "spiky_hedgehog") enemy.x -= Math.max(0, terrainSlope(enemy.x)) * 70 * dt;
      if (enemy.kind === "crow_bomber") enemy.y += Math.sin(performance.now() * 0.005 + enemy.x) * 0.24;
      enemy.shootTimer -= dt;
      if (enemy.shootTimer <= 0) {
        enemyShoot(enemy);
        enemy.shootTimer = enemy.kind === "owl_sniper" ? 1.65 : enemy.kind === "crow_bomber" ? 1.25 : ["toxic_frog", "castle_cannon"].includes(enemy.kind) ? 1.35 : 2.25;
      }
      if (run.player.spinTimer > 0 && circleHit(playerWorld, { x: enemy.x, y: enemy.y - enemy.radius * 0.55 }, spinRadius())) {
        damageEnemy(enemy, progress.selectedSkin === "gym_bro" ? 3.6 : 1.8, true);
      } else if (circleHit(playerWorld, { x: enemy.x, y: enemy.y - enemy.radius * 0.55 }, enemy.radius + run.player.radius * 0.76)) {
        if (run.player.dashTimer > 0) damageEnemy(enemy, 6, true);
        else hurtPlayer(enemy.kind === "armored_weasel" ? 2 : 1);
      }
    }
    run.enemies = run.enemies.filter((enemy) => {
      if (enemy.hp <= 0) {
        run.kills += enemy.crate ? 0 : 1;
        const sx = worldToScreenX(enemy.x);
        addEffect(enemy.crate ? "crate_pop" : "enemy_hit", sx, enemy.y - enemy.radius, enemy.crate ? 80 : 70);
        if (enemy.crate || Math.random() < (progress.selectedSkin === "pirate" ? 0.55 : 0.25)) {
          run.pickups.push({ kind: Math.random() < 0.08 ? "golden_peanut" : "sunflower_seed", x: enemy.x, y: enemy.y - 50, radius: 18, collected: false, spin: 0 });
        }
        sound(enemy.crate ? "boom" : "hit");
        return false;
      }
      return enemy.x > run.worldX - 190;
    });
  }

  function spinRadius() {
    return progress.selectedSkin === "gym_bro" && progress.skins.gym_bro.level === 2 ? 98 : 72;
  }

  function enemyShoot(enemy) {
    if (enemy.kind === "owl_sniper") {
      run.enemyProjectiles.push({ kind: "feather", x: enemy.x - 20, y: enemy.y - 20, vx: -430, vy: 115, radius: 10, life: 3, web: false });
    } else if (enemy.kind === "crow_bomber") {
      run.enemyProjectiles.push({ kind: "bomb", x: enemy.x, y: enemy.y + 16, vx: -70, vy: 250, radius: 15, life: 3, web: false });
    } else if (enemy.kind === "spider_trapper") {
      run.enemyProjectiles.push({ kind: "web", x: enemy.x - 15, y: enemy.y - 32, vx: -360, vy: -45, radius: 18, life: 2.5, web: true });
    } else if (enemy.kind === "toxic_frog") {
      run.enemyProjectiles.push({ kind: "acid", x: enemy.x - 18, y: enemy.y - 28, vx: -330, vy: -120, radius: 14, life: 3, web: false, gravity: 560, color: "#84ff3f" });
    } else if (enemy.kind === "castle_cannon") {
      run.enemyProjectiles.push({ kind: "cannon", x: enemy.x - 18, y: enemy.y - 20, vx: -250, vy: 250, radius: 18, life: 3, web: false, gravity: 520, color: "#64748b" });
    } else if (enemy.kind === "royal_guard") {
      run.enemyProjectiles.push({ kind: "magic", x: enemy.x - 30, y: enemy.y - 55, vx: -450, vy: -40, radius: 14, life: 3, web: false, gravity: 120, color: "#60a5fa" });
    }
  }

  function updateProjectiles(dt) {
    for (const projectile of run.projectiles) {
      if (projectile.kind === "carrot") {
        const target = nearestEnemy(projectile);
        if (target) {
          const lead = carrotLeadPoint(projectile, target);
          const desired = Math.atan2(lead.y - projectile.y, lead.x - projectile.x);
          projectile.vx += Math.cos(desired) * 1650 * dt;
          projectile.vy += Math.sin(desired) * 1650 * dt;
          const speed = Math.hypot(projectile.vx, projectile.vy) || 1;
          const targetSpeed = target === run.boss ? 650 : 720;
          projectile.vx = (projectile.vx / speed) * targetSpeed;
          projectile.vy = (projectile.vy / speed) * targetSpeed;
          projectile.radius = Math.max(projectile.radius, 17);
        }
      }
      if (projectile.kind === "twig") {
        projectile.age += dt;
        if (projectile.age > 0.55) projectile.returning = true;
        if (projectile.returning) {
          const dx = run.worldX - projectile.x;
          const dy = run.player.y - projectile.y;
          const len = Math.hypot(dx, dy) || 1;
          projectile.vx = (dx / len) * 720;
          projectile.vy = (dy / len) * 720;
          projectile.damage = progress.weapons.boomerang_twig.level === 2 ? 2.1 : 1.2;
        }
      }
      projectile.x += projectile.vx * dt;
      projectile.y += projectile.vy * dt;
      projectile.life -= dt;
      if (projectile.pop && projectile.life < 1.38 && !projectile.popped) {
        projectile.popped = true;
        projectile.radius = 24;
      }
      for (const enemy of run.enemies) {
        if (enemy.hp > 0 && circleHit(projectile, { x: enemy.x, y: enemy.y - enemy.radius * 0.55 }, projectile.radius + enemy.radius * 0.7)) {
          let damage = projectile.damage;
          if (enemy.armor && !["walnut", "laser", "melon", "sonic"].includes(projectile.kind)) damage *= 0.35;
          damageEnemy(enemy, damage, projectile.kind === "sonic");
          if (projectile.slow) enemy.slow = projectile.slow;
          if (projectile.stun) enemy.stun = projectile.stun;
          addEffect("enemy_hit", worldToScreenX(enemy.x), enemy.y - enemy.radius, 34);
          projectile.pierce -= 1;
          if (projectile.kind === "walnut" && projectile.pierce <= 0) walnutCluster(projectile);
          if (projectile.pierce <= 0) break;
        }
      }
      if (run.boss && run.boss.hp > 0 && projectile.pierce > 0 && circleHit(projectile, { x: run.boss.x, y: run.boss.y }, projectile.radius + run.boss.radius * 0.75)) {
        let damage = projectile.damage;
        if (run.boss.kind === "mecha_fox" && !["walnut", "laser", "melon", "sonic"].includes(projectile.kind)) damage *= 0.45;
        if (run.boss.kind === "bulking_lizard" && projectile.kind !== "walnut") damage *= 0.65;
        if (run.boss.kind === "spiky_hedgehog" && projectile.x < run.boss.x) damage *= 0.55;
        run.boss.hp -= damage;
        addEffect("enemy_hit", worldToScreenX(run.boss.x), run.boss.y, 48);
        projectile.pierce -= 1;
        if (projectile.kind === "walnut" && projectile.pierce <= 0) walnutCluster(projectile);
      }
      if (projectile.kind === "sonic") {
        for (const shot of run.enemyProjectiles) {
          if (circleHit(projectile, shot, projectile.radius + shot.radius)) shot.life = 0;
        }
      }
    }
    for (const shot of run.enemyProjectiles) {
      if (shot.zigzag) shot.vy += Math.sin(performance.now() * 0.015 + shot.x * 0.02) * 1100 * dt;
      shot.vy += (Number.isFinite(shot.gravity) ? shot.gravity : shot.kind === "bomb" ? 650 : 80) * dt;
      shot.x += shot.vx * dt;
      shot.y += shot.vy * dt;
      shot.life -= dt;
      if (shot.y > terrainY(shot.x) && ["bomb", "acid", "plate", "cannon", "whey"].includes(shot.kind)) shot.life = 0;
      if (circleHit({ x: run.worldX, y: run.player.y }, shot, shot.radius + run.player.radius * 0.65)) {
        if (shot.web) {
          run.slowTimer = 3;
          run.player.jumpLockTimer = Math.max(run.player.jumpLockTimer, 3);
        }
        else hurtPlayer(1);
        addEffect(shot.web ? "dash_swirl" : "enemy_hit", worldToScreenX(shot.x), shot.y, 48);
        shot.life = 0;
      }
    }
    run.projectiles = run.projectiles.filter((projectile) => projectile.life > 0 && projectile.pierce > 0 && projectile.x < run.worldX + width + 260 && projectile.x > run.worldX - 180);
    run.enemyProjectiles = run.enemyProjectiles.filter((shot) => shot.life > 0 && shot.x > run.worldX - 180);
  }

  function walnutCluster(projectile) {
    if (progress.weapons.walnut_cannon?.level !== 2 || projectile.clustered) return;
    projectile.clustered = true;
    for (const angle of [-0.7, 0, 0.7]) {
      run.projectiles.push({ kind: "walnut", x: projectile.x, y: projectile.y, vx: Math.cos(angle) * 420, vy: Math.sin(angle) * 420, damage: 0.8, radius: 10, pierce: 1, life: 0.7 });
    }
  }

  function carrotLeadPoint(projectile, target) {
    const targetVx = target === run.boss ? run.speed * 0.42 : target.vx || 0;
    const targetVy = target === run.boss ? Math.cos((target.t || 0) * 2) * 55 : target.ground ? terrainSlope(target.x) * (target.vx || 0) : 0;
    const distance = Math.hypot(target.x - projectile.x, target.y - projectile.y);
    const travelTime = clamp(distance / 720, 0.08, target === run.boss ? 0.42 : 0.62);
    return {
      x: target.x + targetVx * travelTime,
      y: target.y - (target.radius || 36) * 0.58 + targetVy * travelTime,
    };
  }

  function nearestEnemy(projectile) {
    let best = null;
    let bestDistance = Infinity;
    if (run.boss) {
      best = run.boss;
      const dx = run.boss.x - projectile.x;
      const dy = run.boss.y - projectile.y;
      bestDistance = dx * dx + dy * dy;
    }
    for (const enemy of run.enemies) {
      const dx = enemy.x - projectile.x;
      const dy = enemy.y - projectile.y;
      const distance = dx * dx + dy * dy;
      if (dx > -40 && distance < bestDistance) {
        best = enemy;
        bestDistance = distance;
      }
    }
    return best;
  }

  function damageEnemy(enemy, damage, melee = false) {
    if (enemy.armor && melee && progress.selectedSkin === "gym_bro" && progress.skins.gym_bro.level === 2) damage *= 2.4;
    enemy.hp -= damage;
    if (melee && progress.selectedSkin === "knight" && progress.skins.knight.level === 2) enemy.hp -= 0.8;
  }

  function updateHazards() {
    const playerPoint = { x: run.worldX, y: run.player.y + run.player.radius * 0.4 };
    for (const hazard of run.hazards) {
      hazard.y = terrainY(hazard.x);
      if (!hazard.warned && hazard.x - run.worldX < width * 0.58) hazard.warned = true;
      if (circleHit(playerPoint, { x: hazard.x, y: hazard.y - 12 }, hazard.radius + 20)) {
        if (hazard.kind === "mud_puddle") run.slowTimer = 2.3;
        else hurtPlayer(1);
        hazard.x = run.worldX - 999;
      }
    }
    run.hazards = run.hazards.filter((hazard) => hazard.x > run.worldX - 160);
  }

  function hurtPlayer(amount) {
    if (run.player.hurtTimer > 0 || run.player.dashTimer > 0) return;
    if (run.shieldReady) {
      run.shieldReady = false;
      addLabel("Shield!", screenPlayerX(), run.player.y - 70, "#9efcff");
      run.player.hurtTimer = 0.8;
      sound("hit");
      return;
    }
    let damage = amount;
    if (progress.selectedSkin === "knight") damage *= 0.55;
    run.hp -= Math.max(1, Math.round(damage));
    run.player.hurtTimer = 0.95;
    addEffect("enemy_hit", screenPlayerX(), run.player.y - 10, 78);
    sound("hit");
    haptic(50);
    if (run.hp <= 0) maybeReviveOrEnd();
  }

  function maybeReviveOrEnd() {
    if (progress.selectedSkin === "zombie" && !run.reviveUsed) {
      const level = progress.skins.zombie.level;
      if (level === 2 || Math.random() < 0.1) {
        run.reviveUsed = true;
        run.hp = Math.max(1, Math.ceil(run.maxHp * 0.3));
        run.player.hurtTimer = 1.4;
        addLabel("Revived!", screenPlayerX(), run.player.y - 80, "#92ff75", 1.2);
        for (const enemy of run.enemies) if (Math.abs(enemy.x - run.worldX) < 220) enemy.hp -= 4;
        return;
      }
    }
    endRun();
  }

  function updateEffects(dt) {
    for (const effect of run.effects) effect.t += dt;
    for (const label of run.labels) {
      label.t += dt;
      label.y -= dt * 24;
    }
    run.effects = run.effects.filter((effect) => effect.t < effect.duration);
    run.labels = run.labels.filter((label) => label.t < label.duration);
  }

  async function endRun(victory = false) {
    if (!running) return;
    running = false;
    paused = false;
    if (!victory) run.defeatAt = performance.now();
    const previousBest = progress.bestMeters;
    const meters = Math.floor(run.meters);
    progress.bestMeters = Math.max(progress.bestMeters, meters);
    const milestonePeanuts = Math.floor(meters / 500);
    progress.seeds += run.seeds;
    progress.peanuts += run.peanuts + milestonePeanuts;
    await persistProgress();
    if (Number.isFinite(meters)) {
      sdk.leaderboard.submit(meters).catch(() => {});
    }
    resultPanel.hidden = false;
    resultPanel.innerHTML = `
      <div class="panel result-card">
        <p class="eyebrow">${victory ? "Guild Cleared" : "Run Complete"}</p>
        <h2>${meters}m</h2>
        <p>${victory ? "All 10 bosses defeated!" : meters > previousBest ? "New best ridge!" : `${Math.max(0, previousBest - meters)}m to beat best`}</p>
        <div class="reward-row"><span>+${run.seeds} seeds</span><span>+${run.peanuts + milestonePeanuts} peanuts</span></div>
        <div class="button-row">
          <button data-action="retry">Retry</button>
          <button data-action="shop">Armory</button>
        </div>
      </div>`;
    resultPanel.querySelector('[data-action="retry"]').addEventListener("click", () => resetRun(true));
    resultPanel.querySelector('[data-action="shop"]').addEventListener("click", () => openShop());
  }

  function addEffect(name, x, y, size) {
    if (config.effectsIntensity <= 0) return;
    run.effects.push({ name, x, y, size: size * config.effectsIntensity, t: 0, duration: 0.32 });
  }

  function addLabel(text, x, y, color, duration = 0.9) {
    run.labels.push({ text, x, y, color, duration, t: 0 });
  }

  function render(time) {
    if (!ctx) return;
    const dt = lastTime ? Math.min(0.033, (time - lastTime) / 1000) : 0;
    lastTime = time;
    update(dt);
    draw();
    raf = requestAnimationFrame(render);
  }

  function draw() {
    ctx.clearRect(0, 0, width, height);
    drawBackdrop();
    if (!run) return;
    drawTerrain();
    drawPickups();
    drawHazards();
    drawEnemies();
    drawBoss();
    drawProjectiles();
    if (!running && started && run.hp <= 0) drawDefeatPlayer();
    else drawPlayer();
    drawEffects();
    drawLabels();
    if (!running && started) drawGameOverShade();
  }

  function drawBackdrop() {
    const biome = run ? currentBiome() : BIOMES[0];
    if (biome.id === "backyard" && media.backdrop) {
      const scale = Math.max(width / media.backdrop.width, height / media.backdrop.height);
      const w = media.backdrop.width * scale;
      const h = media.backdrop.height * scale;
      ctx.drawImage(media.backdrop, (width - w) / 2, (height - h) / 2, w, h);
    } else {
      drawBiomeBaseBackground(biome);
    }
    ctx.fillStyle = biome.skyTint;
    ctx.fillRect(0, 0, width, height);
    drawBiomeSilhouettes(biome);
    drawLevelAmbience(biome);
  }

  function drawBiomeBaseBackground(biome) {
    const palettes = {
      attic: ["#211712", "#5a3927", "#b88758"],
      cafe: ["#40210f", "#9a5f31", "#f0b76d"],
      sewer: ["#061a24", "#073d35", "#18b981"],
      factory: ["#111827", "#303640", "#facc15"],
      bamboo: ["#10291b", "#246b3a", "#a7f3d0"],
      thrift: ["#221534", "#6d3b8f", "#f0abfc"],
      gym: ["#141414", "#44403c", "#f97316"],
      den: ["#13091f", "#3b2457", "#a78bfa"],
      citadel: ["#263042", "#64748b", "#fde68a"],
    }[biome.id] || ["#61c9ff", "#8ed957", "#fff6a7"];
    const gradient = ctx.createLinearGradient(0, 0, 0, height);
    gradient.addColorStop(0, palettes[0]);
    gradient.addColorStop(0.52, palettes[1]);
    gradient.addColorStop(1, palettes[2]);
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, width, height);

    const offset = run ? -((run.worldX * 0.08) % 220) : 0;
    ctx.save();
    ctx.globalAlpha = 0.34;
    if (biome.id === "attic") {
      ctx.fillStyle = "#2a1a13";
      for (let x = offset - 120; x < width + 180; x += 110) ctx.fillRect(x, 0, 48, height);
      ctx.fillStyle = "rgba(255, 230, 166, 0.22)";
      ctx.beginPath();
      ctx.moveTo(width * 0.18, 0);
      ctx.lineTo(width * 0.42, height * 0.72);
      ctx.lineTo(width * 0.58, height * 0.72);
      ctx.lineTo(width * 0.38, 0);
      ctx.fill();
    } else if (biome.id === "cafe") {
      ctx.fillStyle = "rgba(255, 220, 150, 0.28)";
      for (let x = offset - 160; x < width + 220; x += 190) {
        ctx.beginPath();
        ctx.ellipse(x + 80, height * 0.18, 70, 24, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.fillRect(x + 74, height * 0.18, 12, height * 0.62);
      }
    } else if (biome.id === "sewer") {
      ctx.strokeStyle = "rgba(236, 72, 255, 0.6)";
      ctx.lineWidth = 5;
      for (let x = offset - 160; x < width + 220; x += 190) {
        ctx.strokeRect(x, height * 0.18, 86, height * 0.28);
        ctx.beginPath();
        ctx.moveTo(x + 20, height * 0.2);
        ctx.lineTo(x + 20, height * 0.44);
        ctx.lineTo(x + 72, height * 0.44);
        ctx.stroke();
      }
    } else if (biome.id === "factory") {
      ctx.strokeStyle = "rgba(250, 204, 21, 0.34)";
      ctx.lineWidth = 3;
      for (let x = offset - 120; x < width + 200; x += 95) {
        ctx.beginPath();
        ctx.moveTo(x, height * 0.12);
        ctx.lineTo(x + 75, height * 0.78);
        ctx.stroke();
      }
    } else if (biome.id === "bamboo") {
      ctx.fillStyle = "rgba(240, 253, 244, 0.16)";
      for (let i = 0; i < 4; i += 1) ctx.fillRect(0, height * (0.18 + i * 0.12), width, height * 0.06);
    } else if (biome.id === "thrift") {
      ctx.fillStyle = "rgba(255, 255, 255, 0.11)";
      for (let x = offset - 140; x < width + 180; x += 90) roundRect(ctx, x, height * 0.16, 54, height * 0.48, 12, true);
    } else if (biome.id === "gym") {
      ctx.strokeStyle = "rgba(255,255,255,0.18)";
      ctx.lineWidth = 2;
      for (let y = height * 0.14; y < height * 0.75; y += 44) {
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(width, y);
        ctx.stroke();
      }
    } else if (biome.id === "den") {
      ctx.fillStyle = "rgba(196, 181, 253, 0.22)";
      for (let x = offset - 120; x < width + 200; x += 90) {
        ctx.beginPath();
        ctx.moveTo(x, height * 0.66);
        ctx.lineTo(x + 18, height * 0.18);
        ctx.lineTo(x + 42, height * 0.66);
        ctx.fill();
      }
    } else if (biome.id === "citadel") {
      ctx.fillStyle = "rgba(125, 47, 38, 0.55)";
      for (let x = offset - 150; x < width + 220; x += 150) {
        ctx.fillRect(x + 22, height * 0.16, 42, height * 0.28);
        ctx.beginPath();
        ctx.moveTo(x + 22, height * 0.16);
        ctx.lineTo(x + 64, height * 0.16);
        ctx.lineTo(x + 43, height * 0.24);
        ctx.fill();
      }
    }
    ctx.restore();
  }

  function drawLevelAmbience(biome) {
    const t = performance.now() / 1000;
    const count = biome.id === "backyard" ? 12 : 18;
    ctx.save();
    for (let i = 0; i < count; i += 1) {
      const seed = i * 97.13;
      const x = (seed + t * (18 + biome.level * 2) - (run?.worldX || 0) * 0.04) % (width + 80) - 40;
      const y = (seed * 1.73 + Math.sin(t + i) * 20) % (height * 0.62);
      if (biome.id === "backyard") {
        ctx.fillStyle = "rgba(255,255,255,0.65)";
        ctx.beginPath();
        ctx.ellipse(x, y, 3, 2, Math.sin(t + i), 0, Math.PI * 2);
        ctx.fill();
      } else if (biome.id === "attic") {
        ctx.fillStyle = "rgba(245, 222, 179, 0.35)";
        ctx.fillRect(x, y, 2, 2);
      } else if (biome.id === "cafe") {
        ctx.strokeStyle = "rgba(255, 245, 210, 0.28)";
        ctx.beginPath();
        ctx.arc(x, y, 8 + (i % 4) * 3, 0, Math.PI * 1.2);
        ctx.stroke();
      } else if (biome.id === "sewer") {
        ctx.fillStyle = "rgba(132, 255, 63, 0.45)";
        ctx.beginPath();
        ctx.arc(x, y, 2 + (i % 3), 0, Math.PI * 2);
        ctx.fill();
      } else if (biome.id === "factory") {
        ctx.fillStyle = i % 2 ? "rgba(250, 204, 21, 0.55)" : "rgba(96, 165, 250, 0.45)";
        ctx.fillRect(x, y, 3, 8);
      } else if (biome.id === "bamboo") {
        ctx.fillStyle = "rgba(187, 247, 208, 0.5)";
        ctx.beginPath();
        ctx.ellipse(x, y, 9, 3, 0.7, 0, Math.PI * 2);
        ctx.fill();
      } else if (biome.id === "thrift") {
        ctx.fillStyle = "rgba(244, 114, 182, 0.38)";
        ctx.fillRect(x, y, 8, 3);
      } else if (biome.id === "gym") {
        ctx.fillStyle = "rgba(255,255,255,0.32)";
        ctx.beginPath();
        ctx.arc(x, y, 2, 0, Math.PI * 2);
        ctx.fill();
      } else if (biome.id === "den") {
        ctx.fillStyle = "rgba(167, 139, 250, 0.58)";
        ctx.beginPath();
        ctx.moveTo(x, y - 5);
        ctx.lineTo(x + 4, y);
        ctx.lineTo(x, y + 5);
        ctx.lineTo(x - 4, y);
        ctx.fill();
      } else {
        ctx.fillStyle = "rgba(253, 230, 138, 0.45)";
        ctx.fillRect(x, y, 4, 12);
      }
    }
    ctx.restore();
  }

  function drawBiomeSilhouettes(biome) {
    const offset = run ? -((run.worldX * 0.18) % 180) : 0;
    ctx.save();
    ctx.globalAlpha = 0.62;
    if (biome.id === "attic") {
      ctx.fillStyle = "#5a3927";
      for (let x = offset - 180; x < width + 220; x += 180) ctx.fillRect(x, height * 0.18, 108, height * 0.58);
      ctx.fillStyle = "rgba(255, 230, 170, 0.2)";
      ctx.fillRect(width * 0.58, 0, width * 0.22, height * 0.62);
    } else if (biome.id === "cafe") {
      ctx.fillStyle = "rgba(80, 45, 30, 0.35)";
      for (let x = offset - 200; x < width + 200; x += 190) roundRect(ctx, x, height * 0.25, 118, 72, 16, true);
    } else if (biome.id === "sewer") {
      ctx.strokeStyle = "rgba(92, 255, 189, 0.5)";
      ctx.lineWidth = 18;
      for (let x = offset - 220; x < width + 220; x += 210) {
        ctx.beginPath();
        ctx.arc(x + 90, height * 0.38, 70, 0, Math.PI * 2);
        ctx.stroke();
      }
    } else if (biome.id === "factory") {
      ctx.fillStyle = "rgba(30, 36, 46, 0.68)";
      for (let x = offset - 180; x < width + 220; x += 160) ctx.fillRect(x, height * 0.17, 94, height * 0.5);
      ctx.fillStyle = "rgba(255, 208, 64, 0.38)";
      for (let x = offset - 80; x < width + 100; x += 80) ctx.fillRect(x, height * 0.54, 44, 8);
    } else if (biome.id === "bamboo") {
      ctx.strokeStyle = "rgba(34, 90, 50, 0.62)";
      ctx.lineWidth = 18;
      for (let x = offset - 160; x < width + 180; x += 58) {
        ctx.beginPath();
        ctx.moveTo(x, height * 0.12);
        ctx.lineTo(x + 38, height * 0.72);
        ctx.stroke();
      }
      ctx.fillStyle = "rgba(230, 255, 230, 0.18)";
      ctx.fillRect(0, height * 0.2, width, height * 0.55);
    } else if (biome.id === "thrift") {
      ctx.fillStyle = "rgba(90, 42, 110, 0.55)";
      for (let x = offset - 160; x < width + 220; x += 150) roundRect(ctx, x, height * 0.24, 110, 170, 14, true);
      ctx.fillStyle = "rgba(245, 158, 11, 0.3)";
      for (let x = offset - 90; x < width + 180; x += 125) ctx.fillRect(x, height * 0.53, 82, 58);
    } else if (biome.id === "gym") {
      ctx.strokeStyle = "rgba(203, 213, 225, 0.45)";
      ctx.lineWidth = 10;
      for (let x = offset - 190; x < width + 220; x += 190) {
        ctx.beginPath();
        ctx.moveTo(x, height * 0.25);
        ctx.lineTo(x + 170, height * 0.25);
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(x + 25, height * 0.25, 30, 0, Math.PI * 2);
        ctx.arc(x + 145, height * 0.25, 30, 0, Math.PI * 2);
        ctx.stroke();
      }
    } else if (biome.id === "den") {
      ctx.fillStyle = "rgba(139, 92, 246, 0.42)";
      for (let x = offset - 140; x < width + 180; x += 120) {
        ctx.beginPath();
        ctx.moveTo(x, height * 0.6);
        ctx.lineTo(x + 28, height * 0.28);
        ctx.lineTo(x + 58, height * 0.6);
        ctx.closePath();
        ctx.fill();
      }
    } else if (biome.id === "citadel") {
      ctx.fillStyle = "rgba(58, 37, 30, 0.62)";
      for (let x = offset - 200; x < width + 240; x += 190) {
        ctx.fillRect(x, height * 0.2, 120, height * 0.46);
        ctx.beginPath();
        ctx.moveTo(x, height * 0.2);
        ctx.lineTo(x + 60, height * 0.1);
        ctx.lineTo(x + 120, height * 0.2);
        ctx.fill();
      }
      ctx.fillStyle = "rgba(250, 204, 21, 0.36)";
      for (let x = offset - 100; x < width + 160; x += 110) ctx.fillRect(x, height * 0.34, 52, 86);
    }
    ctx.restore();
  }

  function terrainPatternFor(biome) {
    const frameName = TERRAIN_FRAME_BY_BIOME[biome.id] || TERRAIN_FRAME_BY_BIOME.backyard;
    if (terrainPatterns.has(frameName)) return terrainPatterns.get(frameName);
    const sheet = ADVANCED_TERRAIN_FRAMES.has(frameName) ? media.advancedTerrain : media.terrain;
    const frame = sheet?.byName?.[frameName];
    if (!sheet || !frame) return null;
    const source = frame.source;
    const tile = document.createElement("canvas");
    tile.width = source.w;
    tile.height = source.h;
    const tileCtx = tile.getContext("2d");
    tileCtx.fillStyle = biome.ridge;
    tileCtx.fillRect(0, 0, tile.width, tile.height);
    tileCtx.drawImage(sheet.image, source.x, source.y, source.w, source.h, 0, 0, source.w, source.h);
    const pattern = ctx.createPattern(tile, "repeat");
    terrainPatterns.set(frameName, pattern);
    return pattern;
  }

  function drawTerrain() {
    const biome = currentBiome();
    ctx.beginPath();
    ctx.moveTo(0, height + 4);
    for (let sx = 0; sx <= width + 12; sx += 12) {
      const y = terrainY(screenToWorldX(sx));
      ctx.lineTo(sx, y);
    }
    ctx.lineTo(width, height + 4);
    ctx.closePath();
    const fill = ctx.createLinearGradient(0, height * 0.48, 0, height);
    fill.addColorStop(0, biome.ridge);
    fill.addColorStop(1, biome.shadow);
    ctx.fillStyle = fill;
    ctx.fill();
    const pattern = terrainPatternFor(biome);
    if (pattern) {
      ctx.save();
      ctx.clip();
      ctx.globalAlpha = biome.id === "factory" || biome.id === "sewer" ? 0.72 : 0.58;
      ctx.translate(-((run.worldX * 0.7) % 320), 0);
      ctx.fillStyle = pattern;
      ctx.fillRect(-340, height * 0.38, width + 700, height * 0.72);
      ctx.restore();
    }
    ctx.lineWidth = 5;
    ctx.strokeStyle = biome.color;
    ctx.stroke();
    drawTerrainFringe(biome);
    ctx.save();
    ctx.globalAlpha = 0.28;
    ctx.strokeStyle = "#fff4aa";
    ctx.lineWidth = 2;
    for (let sx = -40 - ((run.worldX * 0.9) % 92); sx < width + 80; sx += 92) {
      const wx = screenToWorldX(sx);
      const y = terrainY(wx) + 18;
      ctx.beginPath();
      ctx.moveTo(sx, y);
      ctx.quadraticCurveTo(sx + 28, y + 10, sx + 58, y + 2);
      ctx.stroke();
    }
    ctx.restore();
  }

  function drawTerrainFringe(biome) {
    ctx.save();
    ctx.globalAlpha = 0.88;
    for (let sx = -24 - ((run.worldX * 1.4) % 42); sx < width + 60; sx += 42) {
      const wx = screenToWorldX(sx);
      const y = terrainY(wx);
      const lean = terrainSlope(wx) * 16;
      if (biome.id === "factory") {
        ctx.fillStyle = Math.floor((sx + run.worldX) / 42) % 2 ? "#facc15" : "#303640";
        ctx.save();
        ctx.translate(sx, y + 4);
        ctx.rotate(Math.atan(terrainSlope(wx)));
        ctx.fillRect(-14, -5, 28, 8);
        ctx.restore();
      } else if (biome.id === "sewer") {
        ctx.fillStyle = "rgba(134, 255, 88, 0.72)";
        ctx.beginPath();
        ctx.ellipse(sx + lean * 0.1, y + 4, 16, 5, 0, 0, Math.PI * 2);
        ctx.fill();
      } else if (biome.id === "attic") {
        ctx.strokeStyle = "rgba(58, 35, 22, 0.7)";
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.moveTo(sx - 16, y + 2);
        ctx.lineTo(sx + 18, y + 6 + lean * 0.06);
        ctx.stroke();
      } else {
        ctx.fillStyle = biome.id === "cafe" ? "#f5cf86" : "#9cf05c";
        ctx.beginPath();
        ctx.ellipse(sx, y - 3, 15, 5, Math.atan(terrainSlope(wx)), 0, Math.PI * 2);
        ctx.fill();
      }
    }
    ctx.restore();
  }

  function drawPickups() {
    const sheet = media.props;
    if (!sheet) return;
    for (const pickup of run.pickups) {
      const x = worldToScreenX(pickup.x);
      if (x < -80 || x > width + 80) continue;
      const frame = sheet.byName[pickup.kind];
      drawFrameByHeight(ctx, sheet.image, frame, x, pickup.y + 16, pickup.kind === "golden_peanut" ? 34 : 28, 1, Math.sin(pickup.spin) * 0.25);
    }
  }

  function drawHazards() {
    const sheet = media.props;
    if (!sheet) return;
    for (const hazard of run.hazards) {
      const x = worldToScreenX(hazard.x);
      if (x < -100 || x > width + 100) continue;
      drawFrameByHeight(ctx, sheet.image, sheet.byName[hazard.kind], x, hazard.y + 8, hazard.kind === "mud_puddle" ? 46 : 54, hazard.warned ? 1 : 0.7);
      if (hazard.warned && hazard.x - run.worldX < width * 0.45) drawWarning(x, hazard.y - 70);
    }
  }

  function drawWarning(x, y) {
    ctx.save();
    ctx.fillStyle = "rgba(255, 238, 88, 0.92)";
    ctx.beginPath();
    ctx.moveTo(x, y - 14);
    ctx.lineTo(x + 14, y + 12);
    ctx.lineTo(x - 14, y + 12);
    ctx.closePath();
    ctx.fill();
    ctx.fillStyle = "#332300";
    ctx.font = "800 16px Nunito, sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("!", x, y + 7);
    ctx.restore();
  }

  function entityArt(kind) {
    const sheet = ADVANCED_ENTITY_KINDS.has(kind) ? media.advancedEntities : media.props;
    return { sheet, frame: sheet?.byName?.[kind] };
  }

  function drawEnemies() {
    for (const enemy of run.enemies) {
      const x = worldToScreenX(enemy.x);
      if (x < -160 || x > width + 180) continue;
      const { sheet, frame } = entityArt(enemy.kind);
      if (!sheet || !frame) continue;
      const size = enemy.kind === "bulking_lizard" ? 92 : enemy.kind === "royal_guard" ? 86 : enemy.kind === "armored_weasel" || enemy.kind === "mecha_fox" ? 78 : enemy.kind === "owl_sniper" || enemy.kind === "toxic_frog" ? 58 : enemy.kind === "crow_bomber" ? 52 : enemy.kind === "wood_crate" ? 62 : enemy.kind === "moth_swarm" ? 72 : 58;
      drawFrameByHeight(ctx, sheet.image, frame, x, enemy.y + 2, size, enemy.stun > 0 ? 0.65 : 1);
      if (!enemy.crate && enemy.hp < enemy.maxHp) {
        ctx.fillStyle = "rgba(0,0,0,0.36)";
        roundRect(ctx, x - 25, enemy.y - size - 12, 50, 6, 4, true);
        ctx.fillStyle = enemy.armor ? "#facc15" : "#ef4444";
        roundRect(ctx, x - 25, enemy.y - size - 12, 50 * clamp(enemy.hp / enemy.maxHp, 0, 1), 6, 4, true);
      }
    }
  }

  function drawBoss() {
    const boss = run.boss;
    if (!boss) return;
    const animated = bossAnimationFor(boss.kind);
    const { sheet, frame } = animated || entityArt(boss.kind);
    const x = worldToScreenX(boss.x);
    const size = boss.level >= 10 ? 170 : boss.level >= 8 ? 145 : 124;
    ctx.save();
    ctx.globalAlpha = run.bossIntroTimer > 0 && Math.floor(performance.now() / 90) % 2 ? 0.72 : 1;
    if (sheet && frame) drawFrameByHeight(ctx, sheet.image, frame, x, boss.y + size * 0.45, size, 1, Math.sin(boss.t * 1.5) * 0.04);
    else {
      ctx.fillStyle = "#7c2d12";
      ctx.beginPath();
      ctx.arc(x, boss.y, boss.radius, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.restore();
    const barW = Math.min(width * 0.42, 220);
    const barX = clamp(x - barW * 0.5, 18, width - barW - 18);
    const barY = Math.max(94, boss.y - size * 0.64);
    ctx.save();
    ctx.fillStyle = "rgba(5, 10, 18, 0.72)";
    roundRect(ctx, barX, barY, barW, 20, 10, true);
    ctx.fillStyle = "#ef4444";
    roundRect(ctx, barX + 3, barY + 3, (barW - 6) * clamp(boss.hp / boss.maxHp, 0, 1), 14, 7, true);
    ctx.fillStyle = "#fff6a7";
    ctx.font = "900 13px Nunito, sans-serif";
    ctx.textAlign = "center";
    ctx.fillText(boss.name, barX + barW * 0.5, barY - 6);
    ctx.restore();
  }

  function bossAnimationFor(kind) {
    const sheet = media.bossAnimA?.animations?.[kind] ? media.bossAnimA : media.bossAnimB?.animations?.[kind] ? media.bossAnimB : null;
    if (!sheet) return null;
    const frames = sheet.animations[kind];
    const frameIndex = Math.floor((performance.now() / 150) % frames.length);
    return { sheet, frame: frames[frameIndex] };
  }

  function drawProjectiles() {
    for (const projectile of run.projectiles) {
      const x = worldToScreenX(projectile.x);
      if (x < -80 || x > width + 120) continue;
      ctx.save();
      ctx.translate(x, projectile.y);
      const angle = Math.atan2(projectile.vy, projectile.vx);
      ctx.rotate(angle);
      const color = {
        seed: "#3b2b1b",
        walnut: "#9a5d2f",
        laser: "#ff3b73",
        carrot: "#ff8a22",
        cheese: "#ffd34d",
        peanut: "#d18937",
        twig: "#7c4a24",
        sonic: "#88f7ff",
        melon: "#151515",
        corn: "#ffe15c",
      }[projectile.kind] || "#fff";
      ctx.fillStyle = color;
      if (projectile.kind === "laser") {
        ctx.fillRect(-18, -3, 62, 6);
        ctx.globalAlpha = 0.35;
        ctx.fillRect(-28, -8, 82, 16);
      } else if (projectile.kind === "sonic") {
        ctx.strokeStyle = color;
        ctx.lineWidth = 4;
        ctx.beginPath();
        ctx.arc(0, 0, projectile.radius, -1.1, 1.1);
        ctx.stroke();
      } else {
        ctx.beginPath();
        ctx.ellipse(0, 0, projectile.radius * 1.35, projectile.radius * 0.72, 0, 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.restore();
    }
    for (const shot of run.enemyProjectiles) {
      const x = worldToScreenX(shot.x);
      ctx.save();
      ctx.translate(x, shot.y);
      ctx.fillStyle = shot.color || (shot.web ? "#e8f5ff" : shot.kind === "bomb" ? "#48424a" : "#d9edf7");
      if (["laser", "slash"].includes(shot.kind)) {
        ctx.rotate(Math.atan2(shot.vy, shot.vx));
        ctx.fillRect(-shot.radius * 1.6, -shot.radius * 0.45, shot.radius * 3.2, shot.radius * 0.9);
      } else if (["spike", "magic"].includes(shot.kind)) {
        ctx.beginPath();
        ctx.moveTo(shot.radius, 0);
        ctx.lineTo(-shot.radius * 0.6, shot.radius * 0.8);
        ctx.lineTo(-shot.radius * 0.35, 0);
        ctx.lineTo(-shot.radius * 0.6, -shot.radius * 0.8);
        ctx.closePath();
        ctx.fill();
      } else {
        ctx.beginPath();
        ctx.arc(0, 0, shot.radius, 0, Math.PI * 2);
        ctx.fill();
      }
      if (shot.web) {
        ctx.strokeStyle = "rgba(255,255,255,0.75)";
        for (let i = 0; i < 6; i += 1) {
          ctx.rotate(Math.PI / 3);
          ctx.beginPath();
          ctx.moveTo(0, 0);
          ctx.lineTo(shot.radius, 0);
          ctx.stroke();
        }
      }
      ctx.restore();
    }
  }

  function drawSkinAura(px, py) {
    const skin = progress.selectedSkin;
    const level = progress.skins[skin]?.level || 1;
    const t = performance.now() / 1000;
    const pulse = 0.5 + Math.sin(t * 5) * 0.5;
    ctx.save();
    ctx.translate(px, py);
    ctx.globalCompositeOperation = "screen";
    if (skin === "ninja") {
      ctx.strokeStyle = level === 2 ? "rgba(68, 255, 155, 0.95)" : "rgba(68, 255, 155, 0.55)";
      ctx.lineWidth = level === 2 ? 5 : 3;
      for (let i = 0; i < 4; i += 1) {
        ctx.beginPath();
        ctx.moveTo(-78 - i * 15, 18 - i * 10);
        ctx.quadraticCurveTo(-34, -24 - pulse * 12, 28 + i * 6, -8 + i * 5);
        ctx.stroke();
      }
    } else if (skin === "mecha") {
      ctx.strokeStyle = level === 2 || run.shieldReady ? "rgba(84, 220, 255, 0.88)" : "rgba(84, 220, 255, 0.45)";
      ctx.lineWidth = 3;
      for (let r = 42; r <= 58; r += 16) {
        ctx.beginPath();
        for (let i = 0; i < 6; i += 1) {
          const angle = t * 0.9 + i * Math.PI / 3;
          const x = Math.cos(angle) * r;
          const y = Math.sin(angle) * r;
          if (i === 0) ctx.moveTo(x, y);
          else ctx.lineTo(x, y);
        }
        ctx.closePath();
        ctx.stroke();
      }
    } else if (skin === "agent_h") {
      ctx.strokeStyle = "rgba(255, 222, 67, 0.8)";
      ctx.lineWidth = 3;
      for (let i = 0; i < 3; i += 1) {
        ctx.beginPath();
        ctx.arc(0, 0, 46 + i * 13 + pulse * 6, -0.8 + i, 0.9 + i);
        ctx.stroke();
      }
      drawTinySparkles("#ffe15f", t, level === 2 ? 9 : 5);
    } else if (skin === "pirate") {
      drawTinySparkles("#fbbf24", t * 1.2, level === 2 ? 10 : 6);
      ctx.strokeStyle = "rgba(255, 190, 72, 0.62)";
      ctx.lineWidth = 4;
      ctx.beginPath();
      ctx.arc(0, 5, 48 + pulse * 9, 0.35, Math.PI * 1.45);
      ctx.stroke();
    } else if (skin === "astronaut") {
      ctx.strokeStyle = "rgba(132, 225, 255, 0.78)";
      ctx.lineWidth = 3;
      for (let i = 0; i < 3; i += 1) {
        ctx.beginPath();
        ctx.ellipse(0, -4, 54 + i * 8, 18 + i * 6, t * 0.6 + i, 0, Math.PI * 2);
        ctx.stroke();
      }
      drawTinySparkles("#bff3ff", t, level === 2 ? 8 : 4);
    } else if (skin === "zombie") {
      ctx.fillStyle = "rgba(91, 255, 86, 0.35)";
      for (let i = 0; i < (level === 2 ? 10 : 6); i += 1) {
        const angle = t * 1.7 + i * 1.9;
        const r = 26 + ((i * 17 + t * 22) % 48);
        ctx.beginPath();
        ctx.arc(Math.cos(angle) * r, Math.sin(angle * 1.2) * 28, 4 + (i % 3), 0, Math.PI * 2);
        ctx.fill();
      }
    } else if (skin === "knight") {
      ctx.strokeStyle = "rgba(226, 232, 240, 0.82)";
      ctx.lineWidth = 4;
      ctx.beginPath();
      ctx.arc(0, 2, 48 + pulse * 5, Math.PI * 0.75, Math.PI * 2.25);
      ctx.stroke();
      ctx.strokeStyle = "rgba(255, 255, 255, 0.5)";
      for (let i = 0; i < 7; i += 1) {
        const angle = -0.2 + i * 0.38;
        ctx.beginPath();
        ctx.moveTo(Math.cos(angle) * 45, Math.sin(angle) * 45);
        ctx.lineTo(Math.cos(angle) * 63, Math.sin(angle) * 63);
        ctx.stroke();
      }
    } else if (skin === "wizard") {
      ctx.strokeStyle = "rgba(206, 107, 255, 0.78)";
      ctx.lineWidth = 3;
      for (let i = 0; i < 4; i += 1) {
        const a = t * (0.9 + i * 0.12) + i * 1.4;
        ctx.beginPath();
        ctx.arc(Math.cos(a) * 38, Math.sin(a) * 24, 7 + pulse * 3, 0, Math.PI * 2);
        ctx.stroke();
      }
      drawTinySparkles("#f0abfc", t, level === 2 ? 9 : 5);
    } else if (skin === "gym_bro") {
      ctx.strokeStyle = level === 2 ? "rgba(255, 91, 91, 0.95)" : "rgba(255, 145, 77, 0.7)";
      ctx.lineWidth = 5;
      for (let i = 0; i < 3; i += 1) {
        ctx.beginPath();
        ctx.arc(0, 0, 40 + i * 14 + pulse * 8, 0.2 + i, Math.PI * 1.1 + i);
        ctx.stroke();
      }
    } else {
      drawTinySparkles("#fff6a7", t, level === 2 ? 7 : 3);
    }
    ctx.restore();
  }

  function drawTinySparkles(color, t, count) {
    ctx.fillStyle = color;
    for (let i = 0; i < count; i += 1) {
      const angle = t * (1.2 + i * 0.08) + i * 2.31;
      const r = 32 + ((i * 19 + t * 18) % 34);
      ctx.save();
      ctx.translate(Math.cos(angle) * r, Math.sin(angle * 1.1) * r * 0.65);
      ctx.rotate(angle);
      ctx.fillRect(-2, -7, 4, 14);
      ctx.fillRect(-7, -2, 14, 4);
      ctx.restore();
    }
  }

  function drawPlayer() {
    const sheet = media.player;
    if (!sheet) return;
    const player = run.player;
    const animation = player.spinTimer > 0 ? sheet.animations.spin : sheet.animations.run;
    const index = Math.floor((performance.now() / (player.spinTimer > 0 ? 50 : 80)) % animation.length);
    const frame = animation[index];
    const scale = player.spinTimer > 0 ? 0.24 : 0.255;
    const alpha = player.hurtTimer > 0 && Math.floor(performance.now() / 80) % 2 === 0 ? 0.55 : 1;
    const px = screenPlayerX();
    const footY = player.y + player.radius;
    drawSkinAura(px, player.y + 3);
    if (player.spinTimer > 0 || !media.playerSkinBodies?.byName?.[progress.selectedSkin]) {
      drawFrameAnchored(ctx, sheet.image, frame, px, footY, scale, alpha, player.spinTimer > 0 ? performance.now() * 0.018 : 0);
    } else {
      const skinFrame = media.playerSkinBodies.byName[progress.selectedSkin] || media.playerSkinBodies.byName.classic;
      const bodyBob = player.grounded ? Math.sin(performance.now() / 85) * 2.4 : 0;
      const bodyTilt = clamp(terrainSlope(run.worldX) * 0.22, -0.28, 0.22);
      drawFrameAnchored(ctx, media.playerSkinBodies.image, skinFrame, px, footY + bodyBob, 0.245, alpha, bodyTilt);
      drawSelectedWeapon(px, player.y, alpha, bodyTilt);
    }
    if (run.shieldReady || player.dashTimer > 0) {
      ctx.save();
      ctx.strokeStyle = run.shieldReady ? "rgba(110, 235, 255, 0.85)" : "rgba(255, 228, 120, 0.9)";
      ctx.lineWidth = 4;
      ctx.beginPath();
      ctx.arc(screenPlayerX() + 2, player.y + 3, player.dashTimer > 0 ? 54 : 45, 0, Math.PI * 2);
      ctx.stroke();
      ctx.restore();
    }
  }

  function defeatAnimationFor(skin) {
    const sheet = media.defeatAnimA?.animations?.[skin] ? media.defeatAnimA : media.defeatAnimB?.animations?.[skin] ? media.defeatAnimB : null;
    if (!sheet) return null;
    return { sheet, frames: sheet.animations[skin] };
  }

  function drawDefeatPlayer() {
    const anim = defeatAnimationFor(progress.selectedSkin);
    const elapsed = run.defeatAt ? (performance.now() - run.defeatAt) / 1000 : 0;
    const px = screenPlayerX();
    const footY = terrainY(run.worldX) + 2;
    if (anim) {
      const index = Math.min(anim.frames.length - 1, Math.floor(elapsed * 5));
      drawFrameAnchored(ctx, anim.sheet.image, anim.frames[index], px, footY, 0.255, 1, Math.sin(elapsed * 7) * 0.04);
    } else {
      drawPlayer();
    }
    ctx.save();
    ctx.fillStyle = "rgba(255, 246, 167, 0.9)";
    ctx.font = "900 22px Nunito, sans-serif";
    ctx.textAlign = "center";
    for (let i = 0; i < 3; i += 1) {
      const angle = elapsed * 2 + i * Math.PI * 0.66;
      ctx.fillText("★", px + Math.cos(angle) * 38, footY - 82 + Math.sin(angle) * 13);
    }
    ctx.restore();
  }

  function drawSelectedWeapon(px, py, alpha, bodyTilt) {
    const sheet = media.weaponCutouts;
    const frame = sheet?.byName?.[progress.selectedWeapon];
    if (!sheet || !frame) return;
    const weaponHeights = {
      walnut_cannon: 44,
      laser_pointer: 30,
      carrot_missile: 36,
      cheese_thrower: 32,
      peanut_splat: 36,
      boomerang_twig: 34,
      sonic_squeak: 36,
      melon_sniper: 31,
      corn_cob: 33,
      seed_gatling: 36,
    };
    const recoil = run.player.weaponFlash > 0 ? -5 : 0;
    const floatBob = run.player.grounded ? Math.sin(performance.now() / 90) * 1.1 : -2;
    const footY = py + run.player.radius;
    const gripX = px + 24 + recoil;
    const gripY = footY - 40 + floatBob;
    const gripTuning = {
      walnut_cannon: [0.29, 0.62, 1],
      laser_pointer: [0.25, 0.58, 0],
      carrot_missile: [0.27, 0.6, 1],
      cheese_thrower: [0.25, 0.6, 0],
      peanut_splat: [0.25, 0.6, 1],
      boomerang_twig: [0.34, 0.62, 0],
      sonic_squeak: [0.28, 0.6, 0],
      melon_sniper: [0.22, 0.58, 2],
      corn_cob: [0.27, 0.6, 0],
      seed_gatling: [0.29, 0.6, 1],
    }[progress.selectedWeapon] || [0.28, 0.6, 0];
    drawWeaponAtGrip(
      sheet.image,
      frame,
      gripX,
      gripY + gripTuning[2],
      weaponHeights[progress.selectedWeapon] || 36,
      gripTuning[0],
      gripTuning[1],
      alpha,
      bodyTilt * 0.18 + (run.player.weaponFlash > 0 ? -0.06 : 0),
    );
  }

  function drawWeaponAtGrip(image, frame, gripX, gripY, height, gripU, gripV, alpha, rotation) {
    const crop = frame.content || frame.source;
    const scale = height / crop.h;
    const localGripX = crop.w * gripU;
    const localGripY = crop.h * gripV;
    ctx.save();
    ctx.globalAlpha *= alpha;
    ctx.translate(gripX, gripY);
    ctx.rotate(rotation);
    ctx.drawImage(
      image,
      crop.x,
      crop.y,
      crop.w,
      crop.h,
      -localGripX * scale,
      -localGripY * scale,
      crop.w * scale,
      crop.h * scale,
    );
    ctx.restore();
  }

  function drawEffects() {
    const sheet = media.effects;
    if (!sheet) return;
    for (const effect of run.effects) {
      const frames = sheet.animations[effect.name];
      if (!frames) continue;
      const index = Math.min(frames.length - 1, Math.floor((effect.t / effect.duration) * frames.length));
      drawFrameByHeight(ctx, sheet.image, frames[index], effect.x, effect.y + effect.size * 0.5, effect.size, 1 - effect.t / effect.duration);
    }
  }

  function drawLabels() {
    ctx.save();
    ctx.textAlign = "center";
    ctx.lineWidth = 5;
    ctx.font = "800 22px Nunito, sans-serif";
    for (const label of run.labels) {
      ctx.globalAlpha = 1 - label.t / label.duration;
      ctx.strokeStyle = "rgba(0,0,0,0.45)";
      ctx.fillStyle = label.color;
      ctx.strokeText(label.text, label.x, label.y);
      ctx.fillText(label.text, label.x, label.y);
    }
    ctx.restore();
  }

  function drawGameOverShade() {
    ctx.fillStyle = "rgba(4, 8, 16, 0.36)";
    ctx.fillRect(0, 0, width, height);
  }

  function renderHud() {
    if (!hud || !run) return;
    const weapon = selectedWeapon();
    const skin = selectedSkin();
    const biome = currentBiome();
    hud.querySelector("[data-distance]").textContent = `${Math.floor(run.meters)}m`;
    hud.querySelector("[data-best]").textContent = `Best ${Math.floor(progress.bestMeters)}m`;
    hud.querySelector("[data-hp]").textContent = `${Math.max(0, run.hp)}/${run.maxHp}`;
    hud.querySelector("[data-seeds]").textContent = `${run.seeds}`;
    const percent = Math.round(levelProgressRatio() * 100);
    const remaining = Math.max(0, Math.ceil(biome.length - run.levelMeters));
    hud.querySelector("[data-biome]").textContent = run.boss ? `Boss: ${run.boss.name}` : biome.name;
    hud.querySelector("[data-level]").textContent = `LEVEL ${biome.level}/10`;
    hud.querySelector("[data-level-percent]").textContent = run.boss ? "BOSS" : `${percent}%`;
    hud.querySelector("[data-level-meta]").textContent = run.boss ? "Defeat the boss" : `${remaining}m to boss`;
    hud.querySelector("[data-level-fill]").style.setProperty("--level", `${run.boss ? 100 : percent}%`);
    const bossHp = hud.querySelector("[data-boss-hp]");
    if (run.boss) {
      bossHp.hidden = false;
      bossHp.querySelector("span").textContent = `${Math.max(0, Math.ceil(run.boss.hp))}/${Math.ceil(run.boss.maxHp)}`;
      bossHp.querySelector("i").style.setProperty("--boss", `${clamp(run.boss.hp / run.boss.maxHp, 0, 1) * 100}%`);
    } else {
      bossHp.hidden = true;
    }
    hud.querySelector("[data-weapon]").textContent = `${weapon.name} L${progress.weapons[weapon.id]?.level || 1}`;
    hud.querySelector("[data-skin]").textContent = `${skin.name} L${progress.skins[skin.id]?.level || 1}`;
    const ammoText = run.player.reloadTimer > 0 ? "RELOAD" : `${run.player.ammo}/${ammoCapacity(weapon)}`;
    hud.querySelector("[data-ammo]").textContent = ammoText;
    const bar = hud.querySelector("[data-reload-bar]");
    const reloadProgress = run.player.reloadTimer > 0 ? 1 - run.player.reloadTimer / run.player.reloadDuration : run.player.ammo / ammoCapacity(weapon);
    bar.style.setProperty("--reload", `${clamp(reloadProgress, 0, 1) * 100}%`);
    paintShootIcon(weapon);
  }

  function paintShootIcon(weapon = selectedWeapon()) {
    if (!shootIconContext || !media.weapons) return;
    const ctx2 = shootIconContext;
    ctx2.clearRect(0, 0, shootIconCanvas.width, shootIconCanvas.height);
    const reloading = run?.player?.reloadTimer > 0;
    const flash = run?.player?.reloadFlash > 0;
    const center = 48;
    const progressRatio = reloading ? 1 - run.player.reloadTimer / run.player.reloadDuration : run.player.ammo / ammoCapacity(weapon);
    const bg = ctx2.createRadialGradient(center, center, 8, center, center, 48);
    bg.addColorStop(0, reloading ? "#451a03" : "#fff3a3");
    bg.addColorStop(1, reloading ? "#f97316" : "#f59e0b");
    ctx2.fillStyle = bg;
    ctx2.beginPath();
    ctx2.arc(center, center, 43, 0, Math.PI * 2);
    ctx2.fill();
    ctx2.lineWidth = 5;
    ctx2.strokeStyle = "rgba(0,0,0,0.5)";
    ctx2.stroke();
    ctx2.strokeStyle = reloading ? "#fde68a" : "#7dd3fc";
    ctx2.lineWidth = 6;
    ctx2.beginPath();
    ctx2.arc(center, center, 42, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * clamp(progressRatio, 0, 1));
    ctx2.stroke();

    const sheet = reloading ? media.actionUi : media.weapons;
    const frameName = reloading ? "reload_spin" : weapon.id;
    const frame = sheet?.byName?.[frameName];
    if (frame && sheet) drawFrameInCell(ctx2, sheet.image, frame, 18, 14, 60, 60);
    if (flash && media.actionUi?.byName?.reload_flash) {
      ctx2.globalAlpha = run.player.reloadFlash / 0.34;
      drawFrameInCell(ctx2, media.actionUi.image, media.actionUi.byName.reload_flash, 2, 0, 92, 92);
      ctx2.globalAlpha = 1;
    }

    const ammo = run?.player?.ammo ?? ammoCapacity(weapon);
    const capacity = ammoCapacity(weapon);
    const pipCount = Math.min(12, capacity);
    for (let i = 0; i < pipCount; i += 1) {
      const angle = -Math.PI * 0.86 + (i / Math.max(1, pipCount - 1)) * Math.PI * 1.72;
      const filled = i < Math.ceil((ammo / capacity) * pipCount) && !reloading;
      ctx2.fillStyle = filled ? "#fff6a7" : "rgba(255,255,255,0.28)";
      ctx2.beginPath();
      ctx2.arc(center + Math.cos(angle) * 36, center + Math.sin(angle) * 36, 3.2, 0, Math.PI * 2);
      ctx2.fill();
    }
  }

  function showPause() {
    if (!started || !running) return;
    paused = true;
    pausePanel.hidden = false;
    pausePanel.innerHTML = `
      <div class="panel pause-card">
        <p class="eyebrow">Paused</p>
        <h2>${Math.floor(run.meters)}m</h2>
        <div class="button-row"><button data-action="continue">Continue</button><button data-action="shop">Armory</button><button data-action="retry">Retry</button></div>
      </div>`;
    pausePanel.querySelector('[data-action="continue"]').addEventListener("click", () => {
      paused = false;
      pausePanel.hidden = true;
    });
    pausePanel.querySelector('[data-action="shop"]').addEventListener("click", () => openShop());
    pausePanel.querySelector('[data-action="retry"]').addEventListener("click", () => resetRun(true));
  }

  function openShop(tab = "weapons") {
    shopReturnAction = running ? "resume" : started ? "retry" : "idle";
    paused = running;
    resultPanel.hidden = true;
    pausePanel.hidden = true;
    shopPanel.hidden = false;
    renderShop(tab);
  }

  function closeShop() {
    shopPanel.hidden = true;
    if (shopReturnAction === "resume") {
      running = true;
      paused = false;
    } else if (shopReturnAction === "retry") {
      resetRun(true);
    }
    shopReturnAction = "idle";
  }

  function renderShop(tab) {
    const items = tab === "weapons" ? WEAPONS : SKINS;
    const collection = tab === "weapons" ? progress.weapons : progress.skins;
    shopPanel.innerHTML = `
      <div class="panel shop-card">
        <div class="shop-top">
          <div><p class="eyebrow">Armory</p><h2>${progress.seeds} seeds · ${progress.peanuts} peanuts</h2></div>
          <button class="ghost" data-action="close">${shopReturnAction === "retry" ? "Start Run" : "Done"}</button>
        </div>
        <div class="tabs"><button class="${tab === "weapons" ? "active" : ""}" data-tab="weapons">Weapons</button><button class="${tab === "skins" ? "active" : ""}" data-tab="skins">Skins</button></div>
        <div class="shop-grid">
          ${items.map((item) => shopItemHtml(item, collection[item.id], tab)).join("")}
        </div>
      </div>`;
    shopPanel.querySelector('[data-action="close"]').addEventListener("click", closeShop);
    for (const button of shopPanel.querySelectorAll("[data-tab]")) button.addEventListener("click", () => renderShop(button.dataset.tab));
    for (const button of shopPanel.querySelectorAll("[data-buy]")) button.addEventListener("click", () => buyOrSelect(button.dataset.buy, tab));
    paintShopIcons(tab);
  }

  function shopItemHtml(item, state, tab) {
    const selected = tab === "weapons" ? progress.selectedWeapon === item.id : progress.selectedSkin === item.id;
    const unlocked = Boolean(state?.unlocked);
    const level = state?.level || 1;
    const action = !unlocked ? `Buy ${item.cost}` : level < 2 ? `L2 ${item.upgradeCost}` : selected ? "Equipped" : "Equip";
    const lockedClass = unlocked ? "" : "locked";
    return `
      <article class="shop-item ${selected ? "selected" : ""} ${lockedClass}">
        <canvas width="96" height="96" data-icon="${item.id}"></canvas>
        <div class="shop-copy"><strong>${item.name}</strong><span>${level === 2 ? item.level2 : item.trait}</span></div>
        <button ${selected && level === 2 ? "disabled" : ""} data-buy="${item.id}">${action}</button>
      </article>`;
  }

  function paintShopIcons(tab) {
    const sheet = tab === "weapons" ? media.weapons : media.skins;
    if (!sheet) return;
    for (const icon of shopPanel.querySelectorAll("canvas[data-icon]")) {
      const iconCtx = icon.getContext("2d");
      iconCtx.clearRect(0, 0, icon.width, icon.height);
      drawFrameInCell(iconCtx, sheet.image, sheet.byName[icon.dataset.icon], 8, 8, 80, 80);
    }
  }

  function applyLoadoutToCurrentRun(previousWeapon, previousSkin) {
    if (!run) return;
    const maxHp = 4 + (progress.selectedSkin === "mecha" ? 1 : 0);
    const hpDelta = maxHp - run.maxHp;
    run.maxHp = maxHp;
    run.hp = clamp(run.hp + Math.max(0, hpDelta), 1, run.maxHp);
    if (previousSkin !== progress.selectedSkin) {
      const skinState = progress.skins[progress.selectedSkin] || { level: 1 };
      run.shieldReady = progress.selectedSkin === "mecha" && skinState.level === 2;
      run.player.jumpsLeft = progress.selectedSkin === "astronaut" && skinState.level === 2 ? 3 : 2;
      run.player.jumpLockTimer = 0;
      addLabel(`${selectedSkin().name}!`, screenPlayerX(), run.player.y - 76, "#fff6a7", 0.95);
    }
    if (previousWeapon !== progress.selectedWeapon) {
      run.player.ammo = ammoCapacity();
      run.player.reloadTimer = 0;
      run.player.reloadDuration = reloadDuration();
      addLabel(`${selectedWeapon().name}!`, screenPlayerX() + 70, run.player.y - 54, "#7dd3fc", 0.95);
    } else {
      run.player.ammo = Math.min(run.player.ammo, ammoCapacity());
      run.player.reloadDuration = reloadDuration();
    }
  }

  async function buyOrSelect(id, tab) {
    const items = tab === "weapons" ? WEAPONS : SKINS;
    const item = items.find((candidate) => candidate.id === id);
    const collection = tab === "weapons" ? progress.weapons : progress.skins;
    if (!item || !collection[id]) return;
    const previousWeapon = progress.selectedWeapon;
    const previousSkin = progress.selectedSkin;
    const state = collection[id];
    if (!state.unlocked) {
      if (progress.seeds < item.cost) return addShopNudge("Need more seeds");
      progress.seeds -= item.cost;
      state.unlocked = true;
      if (tab === "weapons") progress.selectedWeapon = id;
      else progress.selectedSkin = id;
      sound("buy");
    } else if (state.level < 2) {
      if (progress.seeds < item.upgradeCost) return addShopNudge("Need more seeds");
      progress.seeds -= item.upgradeCost;
      state.level = 2;
      sound("buy");
    } else if (tab === "weapons") progress.selectedWeapon = id;
    else progress.selectedSkin = id;
    await persistProgress();
    if (running) applyLoadoutToCurrentRun(previousWeapon, previousSkin);
    else resetRun(false);
    renderShop(tab);
    renderHud();
  }

  function addShopNudge(text) {
    const existing = shopPanel.querySelector(".shop-nudge");
    if (existing) existing.remove();
    const nudge = document.createElement("p");
    nudge.className = "shop-nudge";
    nudge.textContent = text;
    shopPanel.querySelector(".shop-card").append(nudge);
    setTimeout(() => nudge.remove(), 1200);
  }

  function onPointerDown(event) {
    if (!running || paused) return;
    activePointer = { id: event.pointerId, x: event.clientX, y: event.clientY };
    canvas.setPointerCapture(event.pointerId);
    if (event.clientX < width * 0.5) {
      pressed.dive = true;
      jump();
    } else {
      shoot();
    }
  }

  function onPointerUp(event) {
    if (activePointer && activePointer.id === event.pointerId) {
      const dx = event.clientX - activePointer.x;
      const dy = Math.abs(event.clientY - activePointer.y);
      if (dx > 44 && dy < 80) spin();
      activePointer = null;
    }
    pressed.dive = false;
  }

  function onKeyDown(event) {
    if (event.code === "Space") jump();
    if (event.code === "ArrowDown") pressed.dive = true;
    if (event.code === "KeyX") shoot();
    if (event.code === "ShiftLeft" || event.code === "ShiftRight") spin();
    if (event.code === "KeyP") showPause();
  }

  function onKeyUp(event) {
    if (event.code === "ArrowDown") pressed.dive = false;
  }

  async function startFromOverlay() {
    if (!loaded || started) return;
    await unlockAudio();
    resetRun(true);
    sound("buy");
  }

  function resize() {
    const rect = mount.getBoundingClientRect();
    width = Math.max(1, rect.width);
    height = Math.max(1, rect.height);
    dpr = Math.min(2, window.devicePixelRatio || 1);
    canvas.width = Math.floor(width * dpr);
    canvas.height = Math.floor(height * dpr);
    canvas.style.width = `${width}px`;
    canvas.style.height = `${height}px`;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    if (run?.player?.grounded) run.player.y = terrainY(run.worldX) - run.player.radius;
  }

  function roundRect(context, x, y, w, h, r, fill) {
    const radius = Math.min(r, Math.abs(w) * 0.5, Math.abs(h) * 0.5);
    context.beginPath();
    context.moveTo(x + radius, y);
    context.arcTo(x + w, y, x + w, y + h, radius);
    context.arcTo(x + w, y + h, x, y + h, radius);
    context.arcTo(x, y + h, x, y, radius);
    context.arcTo(x, y, x + w, y, radius);
    context.closePath();
    if (fill) context.fill();
    else context.stroke();
  }

  return {
    start() {
      shell = document.createElement("section");
      shell.className = "ridge-runner game-surface";
      shell.innerHTML = `
        <canvas class="ridge-canvas" aria-label="Hamster Havoc ridge runner playfield"></canvas>
        <div class="hud" aria-live="polite">
          <div class="hud-stack"><b data-distance>0m</b><span data-best>Best 0m</span></div>
          <div class="hud-stack right"><b>HP <span data-hp>4/4</span></b><span>Seeds <span data-seeds>0</span></span></div>
          <div class="level-progress">
            <div><b data-level>LEVEL 1/10</b><span data-biome>Sunny Backyard</span></div>
            <strong data-level-percent>0%</strong>
            <i data-level-fill></i>
            <em data-level-meta>320m to boss</em>
          </div>
          <div class="boss-hp" data-boss-hp hidden><b>Boss HP</b><i></i><span>0/0</span></div>
          <button class="pause-button" aria-label="Pause">Ⅱ</button>
          <button class="debug-coin-button" type="button" aria-label="Add unlimited test currency">∞</button>
          <button class="shoot-control" type="button" aria-label="Shoot weapon" data-shoot-control>
            <canvas width="96" height="96" data-shoot-icon></canvas>
            <span data-ammo>30/30</span>
            <i data-reload-bar></i>
          </button>
          <div class="loadout"><span data-weapon>Seed Gatling L1</span><span data-skin>Classic L1</span></div>
          <div class="touch-hints"><span>Left tap/hold</span><span>Button shoot · swipe spin</span></div>
        </div>
        <button class="start-overlay" type="button">
          <span class="start-title">Hamster Havoc</span>
          <span class="start-prompt">Loading ridges…</span>
        </button>
        <div class="modal result-panel" hidden></div>
        <div class="modal pause-panel" hidden></div>
        <div class="modal shop-panel" hidden></div>`;
      mount.replaceChildren(shell);
      canvas = shell.querySelector("canvas");
      ctx = canvas.getContext("2d");
      overlay = shell.querySelector(".start-overlay");
      overlayTitle = shell.querySelector(".start-title");
      overlayPrompt = shell.querySelector(".start-prompt");
      hud = shell.querySelector(".hud");
      shopPanel = shell.querySelector(".shop-panel");
      pausePanel = shell.querySelector(".pause-panel");
      resultPanel = shell.querySelector(".result-panel");
      shootControl = shell.querySelector("[data-shoot-control]");
      shootIconCanvas = shell.querySelector("[data-shoot-icon]");
      shootIconContext = shootIconCanvas.getContext("2d");
      overlayTitle.textContent = "Hamster Havoc";
      resizeObserver = new ResizeObserver(resize);
      resizeObserver.observe(mount);
      resize();
      subscribeTweaks();
      overlay.addEventListener("pointerdown", startFromOverlay);
      canvas.addEventListener("pointerdown", onPointerDown);
      canvas.addEventListener("pointerup", onPointerUp);
      canvas.addEventListener("pointercancel", onPointerUp);
      shootControl.addEventListener("pointerdown", (event) => {
        event.preventDefault();
        event.stopPropagation();
        shoot();
      });
      shell.querySelector(".debug-coin-button").addEventListener("click", () => {
        progress.seeds = 99999;
        progress.peanuts = 999;
        if (run) {
          run.seeds = Math.max(run.seeds, 9999);
          addLabel("Test coins on", width * 0.5, height * 0.22, "#fff6a7", 0.9);
        }
        persistProgress();
        renderHud();
      });
      shell.querySelector(".pause-button").addEventListener("click", showPause);
      window.addEventListener("keydown", onKeyDown);
      window.addEventListener("keyup", onKeyUp);
      ready;
      preload().catch(() => {
        overlayPrompt.textContent = "Asset load failed — tap to retry";
        overlay.addEventListener("pointerdown", () => window.location.reload(), { once: true });
      });
      resetRun(false);
      raf = requestAnimationFrame(render);
    },
    destroy() {
      cancelAnimationFrame(raf);
      for (const unsubscribe of unsubscribes) unsubscribe();
      resizeObserver?.disconnect();
      window.removeEventListener("keydown", onKeyDown);
      window.removeEventListener("keyup", onKeyUp);
      audioHandle?.dispose?.();
      mount.replaceChildren();
    },
    sdk,
    ready,
    tweaks,
    assets,
  };
}
