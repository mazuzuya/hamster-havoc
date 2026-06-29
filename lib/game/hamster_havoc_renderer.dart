import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'hamster_havoc_data.dart';
import 'hamster_havoc_state.dart';
import 'hamster_havoc_sprites.dart';
import 'hamster_havoc_engine.dart';

class GamePainter extends CustomPainter {
  final GameEngine engine;
  final Map<String, SpriteSheet> sprites;
  final Map<String, ui.Image> terrainTileImages = {};
  bool showPlayer = true;

  GamePainter({required this.engine, required this.sprites});

  @override
  void paint(Canvas canvas, Size size) {
    final r = engine.run;
    if (r == null) return;
    final ctx = canvas;
    final w = size.width;
    final h = size.height;

    drawBackdrop(ctx, w, h);
    drawTerrain(ctx, w, h);
    drawPickups(ctx, w, h);
    drawHazards(ctx, w, h);
    drawEnemies(ctx, w, h);
    drawBoss(ctx, w, h);
    drawProjectiles(ctx, w, h);
    if (showPlayer) drawPlayer(ctx, w, h);
    else drawDefeatPlayer(ctx, w, h);
    drawEffects(ctx, w, h);
    drawLabels(ctx, w, h);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  // ---- HELPER METHODS ----

  double scrPX() => min(engine.gameWidth * 0.3, 150.0);
  double w2s(double x) => scrPX() + (x - engine.run!.worldX);
  double s2w(double sx) => engine.run!.worldX + (sx - scrPX());

  void _drawFrameAnchored(Canvas ctx, ui.Image img, Frame? frame, double x, double y, double scale, {double alpha = 1, double rotation = 0}) {
    if (frame == null) return;
    final src = frame.source;
    final crop = frame.content;
    final anchor = frame.anchor;
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(rotation);
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
    ctx.drawImageRect(
      img,
      Rect.fromLTWH(crop.left, crop.top, crop.width, crop.height),
      Rect.fromLTWH(
        -(anchor.dx - crop.left) * scale,
        -(anchor.dy - crop.top) * scale,
        crop.width * scale,
        crop.height * scale,
      ),
      paint,
    );
    ctx.restore();
  }

  void _drawFrameByHeight(Canvas ctx, ui.Image img, Frame? frame, double x, double footY, double h, {double alpha = 1, double rotation = 0}) {
    if (frame == null) return;
    final crop = frame.content;
    final ratio = crop.width / crop.height;
    final w = h * ratio;
    ctx.save();
    ctx.translate(x, footY - h * 0.5);
    ctx.rotate(rotation);
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
    ctx.drawImageRect(
      img,
      Rect.fromLTWH(crop.left, crop.top, crop.width, crop.height),
      Rect.fromLTWH(-w * 0.5, -h * 0.5, w, h),
      paint,
    );
    ctx.restore();
  }

  void _drawFrameInCell(Canvas ctx, ui.Image img, Frame? frame, double x, double y, double w, double h) {
    if (frame == null) return;
    final source = frame.source;
    final crop = frame.content;
    final scaleX = w / source.width;
    final scaleY = h / source.height;
    final paint = Paint()..color = Colors.white;
    ctx.drawImageRect(
      img,
      Rect.fromLTWH(crop.left, crop.top, crop.width, crop.height),
      Rect.fromLTWH(
        x + (crop.left - source.left) * scaleX,
        y + (crop.top - source.top) * scaleY,
        crop.width * scaleX,
        crop.height * scaleY,
      ),
      paint,
    );
  }

  void _roundRect(Canvas ctx, double x, double y, double w, double h, double r, {bool fill = true}) {
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    if (fill) ctx.drawRRect(rect, Paint()..color = Colors.black.withValues(alpha: 0.36));
    else ctx.drawRRect(rect, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  // ---- GLOW / TRAIL HELPERS ----

  void _drawGlow(Canvas ctx, double x, double y, double radius, Color color, double intensity) {
    final r = radius * 2.4;
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(x, y), r,
        [color.withValues(alpha: 0.0), color.withValues(alpha: intensity * 0.45), color.withValues(alpha: 0.0)],
        [0.0, 0.35, 1.0],
      );
    ctx.drawOval(Rect.fromCenter(center: Offset(x, y), width: r * 2, height: r * 1.6), paint);
  }

  void _drawTrail(Canvas ctx, double vx, double vy, Color color, int count, double spread) {
    final speed = sqrt(vx * vx + vy * vy);
    if (speed < 1) return;
    final dx = -vx / speed;
    final dy = -vy / speed;
    for (int i = 1; i <= count; i++) {
      final t = i / count;
      final px = dx * i * spread;
      final py = dy * i * spread;
      final alpha = (1 - t) * 0.5;
      final sz = (1 - t * 0.6);
      ctx.drawOval(
        Rect.fromCenter(center: Offset(px, py), width: 8 * sz, height: 5 * sz),
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
  }

  void _drawSparkles(Canvas ctx, double x, double y, Color color, int count, double seed, double t) {
    final rng = Random(seed.toInt());
    for (int i = 0; i < count; i++) {
      final a = rng.nextDouble() * pi * 2 + t * 3;
      final r = 4 + rng.nextDouble() * 14;
      final sx = x + cos(a) * r;
      final sy = y + sin(a) * r;
      final sz = 1.5 + rng.nextDouble() * 2;
      ctx.drawRect(
        Rect.fromCenter(center: Offset(sx, sy), width: sz, height: sz),
        Paint()..color = color.withValues(alpha: 0.7),
      );
    }
  }

  void _drawFireTrail(Canvas ctx, double vx, double vy, double t) {
    final speed = sqrt(vx * vx + vy * vy);
    if (speed < 1) return;
    final dx = -vx / speed;
    final dy = -vy / speed;
    for (int i = 1; i <= 6; i++) {
      final ft = i / 6;
      final px = dx * i * 12;
      final py = dy * i * 12 + sin(t * 8 + i) * 3;
      final alpha = (1 - ft) * 0.6;
      final radius = (1 - ft * 0.5) * 7;
      final c = i < 3 ? const Color(0xFFFF6B1A) : i < 5 ? const Color(0xFFFFD34D) : const Color(0xFFFFFFFF);
      ctx.drawCircle(Offset(px, py), radius, Paint()..color = c.withValues(alpha: alpha));
    }
  }

  void _drawRingPulse(Canvas ctx, double x, double y, double baseRadius, Color color, double t) {
    for (int i = 0; i < 3; i++) {
      final pulse = ((t * 2.5 + i * 0.33) % 1.0);
      final r = baseRadius + pulse * 20;
      final alpha = (1 - pulse) * 0.5;
      ctx.drawCircle(Offset(x, y), r, Paint()..color = color.withValues(alpha: alpha)..style = PaintingStyle.stroke..strokeWidth = 3);
    }
  }

  // ---- RENDER FUNCTIONS ----

  void drawBackdrop(Canvas ctx, double w, double h) {
    final r = engine.run!;
    final biome = currentBiome(r);
    if (biome.id == "backyard" && sprites.containsKey("backyard")) {
      final img = sprites["backyard"]!.image;
      final scale = max(w / img.width, h / img.height);
      final iw = img.width * scale;
      final ih = img.height * scale;
      ctx.drawImageRect(img, Offset.zero & Size(img.width.toDouble(), img.height.toDouble()), Offset((w - iw) / 2, (h - ih) / 2) & Size(iw, ih), Paint()..color = Colors.white);
    } else {
      drawBiomeBaseBackground(ctx, w, h, biome);
    }
    ctx.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = biome.skyTint);
    drawBiomeSilhouettes(ctx, w, h, biome);
    drawLevelAmbience(ctx, w, h, biome);
  }

  void drawBiomeBaseBackground(Canvas ctx, double w, double h, Biome biome) {
    final palettes = biomePalettes[biome.id] ?? [0xFF61c9ff, 0xFF8ed957, 0xFFfff6a7];
    final gradPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero, Offset(0, h),
        [Color(palettes[0]), Color(palettes[1]), Color(palettes[2])],
        [0.0, 0.52, 1.0],
      );
    ctx.drawRect(Rect.fromLTWH(0, 0, w, h), gradPaint);

    final r = engine.run!;
    final offset = -((r.worldX * 0.08) % 220);

    ctx.save();
    ctx.clipRect(Rect.fromLTWH(0, 0, w, h));
    final alpha = Paint()..color = Colors.white.withValues(alpha: 0.34);

    switch (biome.id) {
      case "attic":
        ctx.drawRect(Rect.zero, Paint()..color = const Color(0x562A1A13));
        for (double x = offset - 120; x < w + 180; x += 110) {
          ctx.drawRect(Rect.fromLTWH(x, 0, 48, h), alpha);
        }
        break;
      case "cafe":
        for (double x = offset - 160; x < w + 220; x += 190) {
          ctx.drawOval(Rect.fromCenter(center: Offset(x + 80, h * 0.18), width: 140, height: 48), Paint()..color = const Color.fromRGBO(255, 220, 150, 0.28));
          ctx.drawRect(Rect.fromLTWH(x + 74, h * 0.18, 12, h * 0.62), Paint()..color = const Color.fromRGBO(255, 220, 150, 0.28));
        }
        break;
      case "sewer":
        for (double x = offset - 160; x < w + 220; x += 190) {
          ctx.drawRect(Rect.fromLTWH(x, h * 0.18, 86, h * 0.28), Paint()..color = const Color.fromRGBO(236, 72, 255, 0.6)..style = PaintingStyle.stroke..strokeWidth = 5);
        }
        break;
      case "factory":
        for (double x = offset - 120; x < w + 200; x += 95) {
          final path = Path()..moveTo(x, h * 0.12)..lineTo(x + 75, h * 0.78);
          ctx.drawPath(path, Paint()..color = const Color.fromRGBO(250, 204, 21, 0.34)..style = PaintingStyle.stroke..strokeWidth = 3);
        }
        break;
      case "bamboo":
        for (int i = 0; i < 4; i++) {
          ctx.drawRect(Rect.fromLTWH(0, h * (0.18 + i * 0.12), w, h * 0.06), Paint()..color = const Color.fromRGBO(240, 253, 244, 0.16));
        }
        break;
      case "thrift":
        for (double x = offset - 140; x < w + 180; x += 90) {
          _roundRect(ctx, x, h * 0.16, 54, h * 0.48, 12);
        }
        break;
      case "gym":
        for (double y = h * 0.14; y < h * 0.75; y += 44) {
          ctx.drawLine(Offset(0, y), Offset(w, y), Paint()..color = const Color.fromRGBO(255, 255, 255, 0.18)..strokeWidth = 2);
        }
        break;
      case "den":
        for (double x = offset - 120; x < w + 200; x += 90) {
          final p = Path()..moveTo(x, h * 0.66)..lineTo(x + 18, h * 0.18)..lineTo(x + 42, h * 0.66)..close();
          ctx.drawPath(p, Paint()..color = const Color.fromRGBO(196, 181, 253, 0.22));
        }
        break;
      case "citadel":
        for (double x = offset - 150; x < w + 220; x += 150) {
          ctx.drawRect(Rect.fromLTWH(x + 22, h * 0.16, 42, h * 0.28), Paint()..color = const Color.fromRGBO(125, 47, 38, 0.55));
          final p = Path()..moveTo(x + 22, h * 0.16)..lineTo(x + 64, h * 0.16)..lineTo(x + 43, h * 0.24)..close();
          ctx.drawPath(p, Paint()..color = const Color.fromRGBO(125, 47, 38, 0.55));
        }
        break;
    }
    ctx.restore();
  }

  void drawLevelAmbience(Canvas ctx, double w, double h, Biome biome) {
    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final count = biome.id == "backyard" ? 12 : 18;
    final r = engine.run!;
    ctx.save();
    for (int i = 0; i < count; i++) {
      final seed = i * 97.13;
      final x = (seed + t * (18 + biome.level * 2) - r.worldX * 0.04) % (w + 80) - 40;
      final y = (seed * 1.73 + sin(t + i) * 20) % (h * 0.62);
      Color c;
      switch (biome.id) {
        case "backyard": c = const Color.fromRGBO(255, 255, 255, 0.65); break;
        case "attic": c = const Color.fromRGBO(245, 222, 179, 0.35); break;
        case "cafe": c = const Color.fromRGBO(255, 245, 210, 0.28); break;
        case "sewer": c = const Color.fromRGBO(132, 255, 63, 0.45); break;
        case "factory": c = i % 2 == 0 ? const Color.fromRGBO(250, 204, 21, 0.55) : const Color.fromRGBO(96, 165, 250, 0.45); break;
        case "bamboo": c = const Color.fromRGBO(187, 247, 208, 0.5); break;
        case "thrift": c = const Color.fromRGBO(244, 114, 182, 0.38); break;
        case "gym": c = const Color.fromRGBO(255, 255, 255, 0.32); break;
        case "den": c = const Color.fromRGBO(167, 139, 250, 0.58); break;
        default: c = const Color.fromRGBO(253, 230, 138, 0.45);
      }
      ctx.drawRect(Rect.fromLTWH(x, y, biome.id == "thrift" ? 8.0 : biome.id == "citadel" ? 4.0 : 2.0, biome.id == "factory" ? 8.0 : biome.id == "citadel" ? 12.0 : 2.0), Paint()..color = c);
    }
    ctx.restore();
  }

  void drawBiomeSilhouettes(Canvas ctx, double w, double h, Biome biome) {
    final r = engine.run!;
    final offset = -((r.worldX * 0.18) % 180);
    ctx.save();
    ctx.clipRect(Rect.fromLTWH(0, 0, w, h));
    final a = Paint()..color = Colors.white.withValues(alpha: 0.62);

    switch (biome.id) {
      case "attic":
        for (double x = offset - 180; x < w + 220; x += 180) {
          ctx.drawRect(Rect.fromLTWH(x, h * 0.18, 108, h * 0.58), Paint()..color = const Color(0xFF5a3927));
        }
        break;
      case "cafe":
        for (double x = offset - 200; x < w + 200; x += 190) {
          _roundRect(ctx, x, h * 0.25, 118, 72, 16);
        }
        break;
      case "sewer":
        for (double x = offset - 220; x < w + 220; x += 210) {
          ctx.drawCircle(Offset(x + 90, h * 0.38), 70, Paint()..color = const Color.fromRGBO(92, 255, 189, 0.5)..style = PaintingStyle.stroke..strokeWidth = 18);
        }
        break;
      case "factory":
        for (double x = offset - 180; x < w + 220; x += 160) {
          ctx.drawRect(Rect.fromLTWH(x, h * 0.17, 94, h * 0.5), Paint()..color = const Color.fromRGBO(30, 36, 46, 0.68));
        }
        for (double x = offset - 80; x < w + 100; x += 80) {
          ctx.drawRect(Rect.fromLTWH(x, h * 0.54, 44, 8), Paint()..color = const Color.fromRGBO(255, 208, 64, 0.38));
        }
        break;
      case "bamboo":
        for (double x = offset - 160; x < w + 180; x += 58) {
          ctx.drawLine(Offset(x, h * 0.12), Offset(x + 38, h * 0.72), Paint()..color = const Color.fromRGBO(34, 90, 50, 0.62)..strokeWidth = 18);
        }
        break;
      case "thrift":
        for (double x = offset - 160; x < w + 220; x += 150) {
          _roundRect(ctx, x, h * 0.24, 110, 170, 14);
        }
        break;
      case "gym":
        for (double x = offset - 190; x < w + 220; x += 190) {
          ctx.drawLine(Offset(x, h * 0.25), Offset(x + 170, h * 0.25), Paint()..color = const Color.fromRGBO(203, 213, 225, 0.45)..strokeWidth = 10);
          ctx.drawCircle(Offset(x + 25, h * 0.25), 30, Paint()..color = const Color.fromRGBO(203, 213, 225, 0.45)..style = PaintingStyle.stroke..strokeWidth = 10);
          ctx.drawCircle(Offset(x + 145, h * 0.25), 30, Paint()..color = const Color.fromRGBO(203, 213, 225, 0.45)..style = PaintingStyle.stroke..strokeWidth = 10);
        }
        break;
      case "den":
        for (double x = offset - 140; x < w + 180; x += 120) {
          final p = Path()..moveTo(x, h * 0.6)..lineTo(x + 28, h * 0.28)..lineTo(x + 58, h * 0.6)..close();
          ctx.drawPath(p, Paint()..color = const Color.fromRGBO(139, 92, 246, 0.42));
        }
        break;
      case "citadel":
        for (double x = offset - 200; x < w + 240; x += 190) {
          ctx.drawRect(Rect.fromLTWH(x, h * 0.2, 120, h * 0.46), Paint()..color = const Color.fromRGBO(58, 37, 30, 0.62));
          final p = Path()..moveTo(x, h * 0.2)..lineTo(x + 60, h * 0.1)..lineTo(x + 120, h * 0.2)..close();
          ctx.drawPath(p, Paint()..color = const Color.fromRGBO(58, 37, 30, 0.62));
        }
        for (double x = offset - 100; x < w + 160; x += 110) {
          ctx.drawRect(Rect.fromLTWH(x, h * 0.34, 52, 86), Paint()..color = const Color.fromRGBO(250, 204, 21, 0.36));
        }
        break;
    }
    ctx.restore();
  }

  void drawTerrain(Canvas ctx, double w, double h) {
    final r = engine.run!;
    final biome = currentBiome(r);

    final path = Path()..moveTo(0, h + 4);
    for (double sx = 0; sx <= w + 12; sx += 12) {
      path.lineTo(sx, terrainY(r, h, s2w(sx)));
    }
    path.lineTo(w, h + 4);
    path.close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, h * 0.48), Offset(0, h),
        [biome.ridge, biome.shadow], [0.0, 1.0],
      );
    ctx.drawPath(path, fillPaint);

    // Terrain pattern
    final frameName = terrainFrameByBiome[biome.id] ?? "backyard_grass";
    final sheet = advancedTerrainFrames.contains(frameName) ? sprites["advancedTerrain"] : sprites["terrain"];
    final frame = sheet?.byName[frameName];

    if (frame != null && sheet != null) {
      ctx.save();
      ctx.clipPath(path);
      final src = frame.source;
      // Create pattern-like tile
      ctx.translate(-((r.worldX * 0.7) % 320), 0);
      final alpha = (biome.id == "factory" || biome.id == "sewer") ? 0.72 : 0.58;
      for (double tx = -340; tx < w + 700; tx += src.width) {
        for (double ty = h * 0.38; ty < h * 0.72; ty += src.height) {
          ctx.drawImageRect(
            sheet.image,
            Rect.fromLTWH(src.left, src.top, src.width, src.height),
            Rect.fromLTWH(tx, ty, src.width, src.height),
            Paint()..color = Colors.white.withValues(alpha: alpha),
          );
        }
      }
      ctx.restore();
    }

    // Stroke terrain line
    ctx.drawPath(path, Paint()..color = biome.color..style = PaintingStyle.stroke..strokeWidth = 5);

    // Fringe
    drawTerrainFringe(ctx, w, h, biome);

    // Highlight curves
    ctx.save();
    for (double sx = -40 - ((r.worldX * 0.9) % 92); sx < w + 80; sx += 92) {
      final wx = s2w(sx);
      final y = terrainY(r, h, wx) + 18;
      final curve = Path()..moveTo(sx, y)..quadraticBezierTo(sx + 28, y + 10, sx + 58, y + 2);
      ctx.drawPath(curve, Paint()..color = const Color.fromRGBO(255, 244, 170, 0.28)..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    ctx.restore();
  }

  void drawTerrainFringe(Canvas ctx, double w, double h, Biome biome) {
    final r = engine.run!;
    ctx.save();
    for (double sx = -24 - ((r.worldX * 1.4) % 42); sx < w + 60; sx += 42) {
      final wx = s2w(sx);
      final y = terrainY(r, h, wx);
      Color c = const Color(0xFF9cf05c);
      switch (biome.id) {
        case "factory": c = ((sx + r.worldX) ~/ 42) % 2 == 1 ? const Color(0xFFfacc15) : const Color(0xFF303640); break;
        case "sewer": c = const Color.fromRGBO(134, 255, 88, 0.72); break;
        case "attic": c = const Color.fromRGBO(58, 35, 22, 0.7); break;
        case "cafe": c = const Color(0xFFf5cf86); break;
      }
      ctx.drawOval(Rect.fromCenter(center: Offset(sx, y - 3), width: 30, height: 10), Paint()..color = c);
    }
    ctx.restore();
  }

  void drawPickups(Canvas ctx, double w, double h) {
    final r = engine.run!;
    final sheet = sprites["props"];
    if (sheet == null) return;
    for (final pickup in r.pickups) {
      final x = w2s(pickup.x);
      if (x < -80 || x > w + 80) continue;
      final frame = sheet.byName[pickup.kind];
      _drawFrameByHeight(ctx, sheet.image, frame, x, pickup.y + 16, pickup.kind == "golden_peanut" ? 34 : 28, rotation: sin(pickup.spin) * 0.25);
    }
  }

  void drawHazards(Canvas ctx, double w, double h) {
    final r = engine.run!;
    final sheet = sprites["props"];
    if (sheet == null) return;
    for (final hazard in r.hazards) {
      final x = w2s(hazard.x);
      if (x < -100 || x > w + 100) continue;
      _drawFrameByHeight(ctx, sheet.image, sheet.byName[hazard.kind], x, hazard.y + 8, hazard.kind == "mud_puddle" ? 46 : 54, alpha: hazard.warned ? 1 : 0.7);
      if (hazard.warned && hazard.x - r.worldX < w * 0.45) drawWarning(ctx, x, hazard.y - 70);
    }
  }

  void drawWarning(Canvas ctx, double x, double y) {
    final path = Path()..moveTo(x, y - 14)..lineTo(x + 14, y + 12)..lineTo(x - 14, y + 12)..close();
    ctx.drawPath(path, Paint()..color = const Color.fromRGBO(255, 238, 88, 0.92));
  }

  (SpriteSheet?, Frame?) entityArt(String kind) {
    final sheet = advancedEntityKinds.contains(kind) ? sprites["advancedEntities"] : sprites["props"];
    return (sheet, sheet?.byName[kind]);
  }

  void drawEnemies(Canvas ctx, double w, double h) {
    final r = engine.run!;
    for (final enemy in r.enemies) {
      final x = w2s(enemy.x);
      if (x < -160 || x > w + 180) continue;
      final (sheet, frame) = entityArt(enemy.kind);
      if (sheet == null || frame == null) continue;
      final size = enemy.kind == "bulking_lizard" ? 92.0 : enemy.kind == "royal_guard" ? 86.0 : enemy.kind == "armored_weasel" || enemy.kind == "mecha_fox" ? 78.0 : enemy.kind == "owl_sniper" || enemy.kind == "toxic_frog" ? 58.0 : enemy.kind == "crow_bomber" ? 52.0 : enemy.kind == "wood_crate" ? 62.0 : enemy.kind == "moth_swarm" ? 72.0 : 58.0;
      _drawFrameByHeight(ctx, sheet.image, frame, x, enemy.y + 2, size, alpha: enemy.stun > 0 ? 0.65 : 1);
      if (!enemy.crate && enemy.hp < enemy.maxHp) {
        ctx.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 25, enemy.y - size - 12, 50, 6), const Radius.circular(4)), Paint()..color = const Color.fromRGBO(0, 0, 0, 0.36));
        ctx.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 25, enemy.y - size - 12, 50 * clamp(enemy.hp / enemy.maxHp, 0, 1), 6), const Radius.circular(4)), Paint()..color = enemy.armor ? const Color(0xFFfacc15) : const Color(0xFFef4444));
      }
    }
  }

  void drawBoss(Canvas ctx, double w, double h) {
    final r = engine.run!;
    final boss = r.boss;
    if (boss == null) return;

    final animated = bossAnimationFor(boss.kind);
    final (sheet, frame) = animated ?? entityArt(boss.kind);
    final x = w2s(boss.x);
    final size = boss.level >= 10 ? 170.0 : boss.level >= 8 ? 145.0 : 124.0;

    ctx.save();
    if (r.bossIntroTimer > 0 && (DateTime.now().millisecondsSinceEpoch ~/ 90) % 2 == 1) {
      ctx.save();
    }
    if (sheet != null && frame != null) {
      _drawFrameByHeight(ctx, sheet.image, frame, x, boss.y + size * 0.45, size, rotation: sin(boss.t * 1.5) * 0.04);
    } else {
      ctx.drawCircle(Offset(x, boss.y), boss.radius, Paint()..color = const Color(0xFF7c2d12));
    }
    ctx.restore();

    // HP bar
    final barW = min(w * 0.42, 220.0);
    final barX = clamp(x - barW * 0.5, 18.0, w - barW - 18);
    final barY = max(94.0, boss.y - size * 0.64);
    ctx.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(barX, barY, barW, 20), const Radius.circular(10)), Paint()..color = const Color.fromRGBO(5, 10, 18, 0.72));
    ctx.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(barX + 3, barY + 3, (barW - 6) * clamp(boss.hp / boss.maxHp, 0, 1), 14), const Radius.circular(7)), Paint()..color = const Color(0xFFef4444));
  }

  (SpriteSheet?, Frame?)? bossAnimationFor(String kind) {
    final sheetA = sprites["bossAnimA"];
    final sheetB = sprites["bossAnimB"];
    SpriteSheet? sheet;
    List<Frame>? frames;
    if (sheetA?.animations.containsKey(kind) == true) {
      sheet = sheetA;
      frames = sheetA!.animations[kind];
    } else if (sheetB?.animations.containsKey(kind) == true) {
      sheet = sheetB;
      frames = sheetB!.animations[kind];
    }
    if (sheet == null || frames == null || frames.isEmpty) return null;
    final idx = ((DateTime.now().millisecondsSinceEpoch / 150).floor() % frames.length);
    return (sheet, frames[idx]);
  }

  void drawProjectiles(Canvas ctx, double w, double h) {
    final r = engine.run!;
    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;

    // ─── Player projectiles ───
    for (final proj in r.projectiles) {
      final x = w2s(proj.x);
      if (x < -100 || x > w + 140) continue;
      final angle = atan2(proj.vy, proj.vx);
      final colorMap = <String, Color>{
        "seed": const Color(0xFF3b2b1b), "walnut": const Color(0xFF9a5d2f),
        "laser": const Color(0xFFff3b73), "carrot": const Color(0xFFff8a22),
        "cheese": const Color(0xFFffd34d), "peanut": const Color(0xFFd18937),
        "twig": const Color(0xFF7c4a24), "sonic": const Color(0xFF88f7ff),
        "melon": const Color(0xFF151515), "corn": const Color(0xFFffe15c),
      };
      final c = colorMap[proj.kind] ?? Colors.white;

      ctx.save();
      ctx.translate(x, proj.y);
      ctx.rotate(angle);

      switch (proj.kind) {
        // ── LASER: neon beam with bright glow + afterglow trail ──
        case "laser":
          _drawGlow(ctx, 0, 0, 24, c, 1.2);
          _drawTrail(ctx, proj.vx, proj.vy, const Color(0xFFff3b73), 5, 16);
          final pulse = 0.7 + sin(t * 30) * 0.3;
          ctx.drawRect(Rect.fromLTWH(-20, -2, 66, 4), Paint()..color = c.withValues(alpha: pulse));
          ctx.drawRect(Rect.fromLTWH(-30, -7, 86, 14), Paint()..color = c.withValues(alpha: 0.25));
          ctx.drawRect(Rect.fromLTWH(-16, -1, 58, 2), Paint()..color = Colors.white.withValues(alpha: pulse * 0.9));
          break;

        // ── SONIC: expanding ripple rings + cyan glow ──
        case "sonic":
          _drawGlow(ctx, 0, 0, proj.radius * 1.2, c, 1.0);
          _drawRingPulse(ctx, 0, 0, proj.radius * 0.7, c, t);
          ctx.drawArc(Rect.fromCircle(center: Offset.zero, radius: proj.radius), -1.1, 2.2, false, Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = 5);
          ctx.drawArc(Rect.fromCircle(center: Offset.zero, radius: proj.radius * 0.65), -1.1, 2.2, false, Paint()..color = Colors.white.withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = 2);
          break;

        // ── WALNUT: large round with brown glow + dust trail ──
        case "walnut":
          _drawGlow(ctx, 0, 0, proj.radius * 1.3, const Color(0xFF9a5d2f), 0.8);
          _drawTrail(ctx, proj.vx, proj.vy, const Color(0xFFD4A76A), 4, 14);
          ctx.drawOval(Rect.fromCenter(center: Offset.zero, width: proj.radius * 2.6, height: proj.radius * 2.2), Paint()..color = c);
          ctx.drawOval(Rect.fromCenter(center: Offset(-proj.radius * 0.3, 0), width: proj.radius * 1.6, height: proj.radius * 1.3), Paint()..color = const Color(0xFFC4823E).withValues(alpha: 0.6));
          ctx.drawOval(Rect.fromCenter(center: Offset(proj.radius * 0.35, -proj.radius * 0.2), width: proj.radius * 0.5, height: proj.radius * 0.4), Paint()..color = const Color(0xFF6B3F1A));
          break;

        // ── CARROT: missile with fire trail + glowing tip ──
        case "carrot":
          _drawFireTrail(ctx, proj.vx, proj.vy, t);
          _drawGlow(ctx, proj.radius * 0.8, 0, 18, const Color(0xFFFF6B1A), 1.0);
          ctx.save();
          ctx.rotate(sin(t * 12) * 0.1);
          ctx.drawOval(Rect.fromCenter(center: Offset.zero, width: proj.radius * 2.8, height: proj.radius * 1.5), Paint()..color = c);
          ctx.drawOval(Rect.fromCenter(center: Offset(proj.radius * 0.9, 0), width: proj.radius * 1.2, height: proj.radius * 1.1), Paint()..color = const Color(0xFF2D8B2D));
          for (int i = 0; i < 3; i++) {
            ctx.drawOval(Rect.fromCenter(center: Offset(-proj.radius * 0.6 + i * proj.radius * 0.4, 0), width: proj.radius * 0.35, height: proj.radius * 0.9), Paint()..color = const Color(0xFFE67E22).withValues(alpha: 0.7));
          }
          ctx.restore();
          break;

        // ── CHEESE: yellow chunks with particle trail + slow wisps ──
        case "cheese":
          _drawGlow(ctx, 0, 0, proj.radius * 1.1, const Color(0xFFFFD34D), 0.7);
          _drawTrail(ctx, proj.vx, proj.vy, const Color(0xFFFFE873), 5, 12);
          ctx.drawOval(Rect.fromCenter(center: Offset.zero, width: proj.radius * 2.5, height: proj.radius * 1.8), Paint()..color = c);
          for (int i = 0; i < 4; i++) {
            final a = i * pi / 2 + t * 4;
            ctx.drawCircle(Offset(cos(a) * proj.radius * 0.5, sin(a) * proj.radius * 0.35), 3, Paint()..color = const Color(0xFFE6A82C).withValues(alpha: 0.8));
          }
          if (proj.slow == true) {
            _drawSparkles(ctx, 0, 0, const Color(0xCC88f7ff), 5, proj.x * 0.1, t);
          }
          break;

        // ── PEANUT: with stun sparkles + electric arcs ──
        case "peanut":
          _drawGlow(ctx, 0, 0, proj.radius * 1.2, const Color(0xFFd18937), 0.6);
          _drawTrail(ctx, proj.vx, proj.vy, const Color(0xFFE8A84F), 4, 11);
          ctx.drawOval(Rect.fromCenter(center: Offset(-proj.radius * 0.3, 0), width: proj.radius * 1.3, height: proj.radius * 1.5), Paint()..color = c);
          ctx.drawOval(Rect.fromCenter(center: Offset(proj.radius * 0.3, 0), width: proj.radius * 1.3, height: proj.radius * 1.5), Paint()..color = c);
          ctx.drawOval(Rect.fromCenter(center: Offset(-proj.radius * 0.3, 0), width: proj.radius * 0.9, height: proj.radius * 1.1), Paint()..color = const Color(0xFFB5702E).withValues(alpha: 0.5));
          if (proj.stun == true) {
            for (int i = 0; i < 3; i++) {
              final a = t * 6 + i * 2.1;
              ctx.drawArc(Rect.fromCircle(center: Offset.zero, radius: proj.radius * 1.4 + sin(t * 10 + i) * 3), a, 0.8, false, Paint()..color = const Color(0xCCfbbf24)..style = PaintingStyle.stroke..strokeWidth = 2);
            }
          }
          break;

        // ── TWIG: boomerang with swirling leaf particles ──
        case "twig":
          _drawGlow(ctx, 0, 0, proj.radius * 1.2, const Color(0xFF7c4a24), 0.5);
          for (int i = 0; i < 5; i++) {
            final a = t * 8 + i * 1.25;
            final r = proj.radius * 0.8 + sin(t * 5 + i) * 8;
            ctx.save();
            ctx.translate(cos(a) * r, sin(a) * r * 0.5);
            ctx.rotate(a);
            ctx.drawOval(Rect.fromCenter(center: Offset.zero, width: 8, height: 4), Paint()..color = const Color(0xFF4CAF50).withValues(alpha: 0.7));
            ctx.restore();
          }
          ctx.save();
          ctx.rotate(t * 8);
          ctx.drawOval(Rect.fromCenter(center: Offset.zero, width: proj.radius * 2.8, height: proj.radius * 1.0), Paint()..color = c);
          ctx.drawOval(Rect.fromCenter(center: Offset.zero, width: proj.radius * 2.0, height: proj.radius * 0.6), Paint()..color = const Color(0xFF5C3517));
          ctx.restore();
          break;

        // ── MELON: sniper round with green tracer + sharp glow ──
        case "melon":
          _drawGlow(ctx, 0, 0, 16, const Color(0xFF22c55e), 1.0);
          _drawTrail(ctx, proj.vx, proj.vy, const Color(0xFF4ADE80), 8, 18);
          ctx.drawOval(Rect.fromCenter(center: Offset.zero, width: proj.radius * 2.2, height: proj.radius * 1.2), Paint()..color = c);
          ctx.drawOval(Rect.fromCenter(center: Offset(proj.radius * 0.4, 0), width: proj.radius * 1.0, height: proj.radius * 0.8), Paint()..color = const Color(0xFF1a1a1a));
          ctx.drawRect(Rect.fromLTWH(-proj.radius * 1.5, -1, proj.radius * 3, 2), Paint()..color = const Color(0xCC4ADE80));
          break;

        // ── CORN: cob with yellow burst + pop effect ──
        case "corn":
          _drawGlow(ctx, 0, 0, proj.radius * 1.1, const Color(0xFFffe15c), 0.8);
          _drawTrail(ctx, proj.vx, proj.vy, const Color(0xFFFFE873), 4, 10);
          ctx.drawOval(Rect.fromCenter(center: Offset.zero, width: proj.radius * 2.5, height: proj.radius * 1.6), Paint()..color = c);
          for (int i = 0; i < 5; i++) {
            final oy = (i - 2) * proj.radius * 0.28;
            ctx.drawCircle(Offset(0, oy), proj.radius * 0.22, Paint()..color = const Color(0xFFE6B800).withValues(alpha: 0.7));
          }
          if (proj.popped) {
            _drawSparkles(ctx, 0, 0, const Color(0xFFFFE873), 8, proj.x * 0.1, t);
            ctx.drawCircle(Offset.zero, proj.radius * 1.5, Paint()..color = const Color(0x44FFE873));
          }
          break;

        // ── SEED: small seed with golden spark trail ──
        default:
          _drawGlow(ctx, 0, 0, proj.radius * 1.5, const Color(0xFFfacc15), 0.6);
          _drawTrail(ctx, proj.vx, proj.vy, const Color(0xFFfde047), 5, 12);
          ctx.drawOval(Rect.fromCenter(center: Offset.zero, width: proj.radius * 2.7, height: proj.radius * 1.44), Paint()..color = c);
          ctx.drawOval(Rect.fromCenter(center: Offset(proj.radius * 0.3, 0), width: proj.radius * 1.0, height: proj.radius * 0.8), Paint()..color = const Color(0xFF6B4A2E).withValues(alpha: 0.5));
          break;
      }
      ctx.restore();
    }

    // ─── Enemy projectiles ───
    for (final shot in r.enemyProjectiles) {
      final x = w2s(shot.x);
      if (x < -100 || x > w + 120) continue;
      Color c;
      try { c = Color(int.parse('0xFF${shot.color.substring(1)}')); } catch (_) { c = Colors.white; }

      ctx.save();
      ctx.translate(x, shot.y);

      // Glow halo for all enemy projectiles
      _drawGlow(ctx, 0, 0, shot.radius * 1.5, c, 0.6);

      switch (shot.kind) {
        case "laser":
        case "slash":
          ctx.rotate(atan2(shot.vy, shot.vx));
          _drawTrail(ctx, shot.vx, shot.vy, c, 5, 16);
          ctx.drawRect(Rect.fromLTWH(-shot.radius * 1.6, -shot.radius * 0.45, shot.radius * 3.2, shot.radius * 0.9), Paint()..color = c);
          ctx.drawRect(Rect.fromLTWH(-shot.radius * 1.4, -shot.radius * 0.2, shot.radius * 2.8, shot.radius * 0.4), Paint()..color = Colors.white.withValues(alpha: 0.5));
          break;

        case "spike":
        case "magic":
          ctx.rotate(atan2(shot.vy, shot.vx) + sin(t * 8) * 0.15);
          _drawSparkles(ctx, 0, 0, c, 4, shot.x * 0.1, t);
          final path = Path()
            ..moveTo(shot.radius, 0)
            ..lineTo(-shot.radius * 0.6, shot.radius * 0.8)
            ..lineTo(-shot.radius * 0.35, 0)
            ..lineTo(-shot.radius * 0.6, -shot.radius * 0.8)
            ..close();
          ctx.drawPath(path, Paint()..color = c);
          ctx.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 1.5);
          break;

        case "bomb":
          _drawFireTrail(ctx, shot.vx, shot.vy, t);
          ctx.drawCircle(Offset.zero, shot.radius, Paint()..color = c);
          ctx.drawCircle(Offset.zero, shot.radius * 0.7, Paint()..color = const Color(0xFF6B3F1A).withValues(alpha: 0.6));
          final fuseX = cos(t * 12) * shot.radius * 0.5;
          ctx.drawCircle(Offset(fuseX, -shot.radius * 0.8), 3 + sin(t * 20) * 1.5, Paint()..color = const Color(0xFFFF4500));
          break;

        case "acid":
          _drawTrail(ctx, shot.vx, shot.vy, const Color(0xFF84ff3f), 4, 10);
          ctx.drawCircle(Offset.zero, shot.radius, Paint()..color = c);
          for (int i = 0; i < 3; i++) {
            final a = t * 5 + i * 2.1;
            ctx.drawCircle(Offset(cos(a) * shot.radius * 0.5, sin(a) * shot.radius * 0.5), shot.radius * 0.2, Paint()..color = const Color(0xFF4ADE80).withValues(alpha: 0.6));
          }
          break;

        case "cannon":
          _drawTrail(ctx, shot.vx, shot.vy, const Color(0xFF64748b), 6, 14);
          ctx.drawCircle(Offset.zero, shot.radius, Paint()..color = c);
          ctx.drawCircle(Offset.zero, shot.radius * 0.65, Paint()..color = const Color(0xFF334155));
          ctx.drawCircle(Offset.zero, shot.radius * 0.3, Paint()..color = const Color(0xFF1E293B));
          break;

        case "plate":
          ctx.rotate(atan2(shot.vy, shot.vx));
          _drawTrail(ctx, shot.vx, shot.vy, const Color(0xFFcbd5e1), 4, 12);
          ctx.drawOval(Rect.fromCenter(center: Offset.zero, width: shot.radius * 2.2, height: shot.radius * 0.8), Paint()..color = c);
          ctx.drawOval(Rect.fromCenter(center: Offset.zero, width: shot.radius * 1.6, height: shot.radius * 0.5), Paint()..color = const Color(0xFF94A3B8).withValues(alpha: 0.6));
          break;

        case "moth":
          ctx.rotate(sin(t * 10 + shot.x * 0.01) * 0.4);
          _drawSparkles(ctx, 0, 0, c, 3, shot.x * 0.1, t);
          ctx.drawOval(Rect.fromCenter(center: Offset(-shot.radius * 0.5, 0), width: shot.radius * 1.2, height: shot.radius * 1.8), Paint()..color = c.withValues(alpha: 0.8));
          ctx.drawOval(Rect.fromCenter(center: Offset(shot.radius * 0.5, 0), width: shot.radius * 1.2, height: shot.radius * 1.8), Paint()..color = c.withValues(alpha: 0.8));
          ctx.drawCircle(Offset.zero, shot.radius * 0.3, Paint()..color = const Color(0xFFf0abfc));
          break;

        case "whey":
          _drawTrail(ctx, shot.vx, shot.vy, const Color(0xFFfef3c7), 5, 12);
          ctx.drawCircle(Offset.zero, shot.radius, Paint()..color = c);
          for (int i = 0; i < 4; i++) {
            final a = t * 4 + i * 1.57;
            ctx.drawCircle(Offset(cos(a) * shot.radius * 0.6, sin(a) * shot.radius * 0.6), shot.radius * 0.18, Paint()..color = Colors.white.withValues(alpha: 0.6));
          }
          break;

        default:
          // Web, feather, boss generic, etc.
          ctx.drawCircle(Offset.zero, shot.radius, Paint()..color = c);
          if (shot.web) {
            ctx.rotate(t * 2);
            for (int i = 0; i < 6; i++) {
              ctx.rotate(pi / 3);
              ctx.drawLine(Offset.zero, Offset(shot.radius, 0), Paint()..color = Colors.white.withValues(alpha: 0.75)..strokeWidth = 1.5);
            }
            ctx.drawCircle(Offset.zero, shot.radius * 0.5, Paint()..color = Colors.white.withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = 1);
          } else {
            ctx.drawCircle(Offset.zero, shot.radius * 0.6, Paint()..color = Colors.white.withValues(alpha: 0.35));
          }
          break;
      }
      ctx.restore();
    }
  }

  void drawPlayer(Canvas ctx, double w, double h) {
    final r = engine.run!;
    final sheet = sprites["player"];
    if (sheet == null) return;
    final p = r.player;
    final anim = p.spinTimer > 0 ? sheet.animations["spin"] : sheet.animations["run"];
    if (anim == null || anim.isEmpty) return;
    final idx = ((DateTime.now().millisecondsSinceEpoch / (p.spinTimer > 0 ? 50 : 80)).floor() % anim.length);
    final frame = anim[idx];
    final scale = p.spinTimer > 0 ? 0.24 : 0.255;
    final alpha = p.hurtTimer > 0 && (DateTime.now().millisecondsSinceEpoch ~/ 80) % 2 == 0 ? 0.55 : 1.0;
    final px = scrPX();
    final footY = p.y + p.radius;

    drawSkinAura(ctx, px, p.y + 3);

    if (p.spinTimer > 0 || sprites["playerSkinBodies"]?.byName[engine.progress.selectedSkin] == null) {
      _drawFrameAnchored(ctx, sheet.image, frame, px, footY, scale, alpha: alpha, rotation: p.spinTimer > 0 ? DateTime.now().millisecondsSinceEpoch * 0.018 : 0);
    } else {
      final skinSheet = sprites["playerSkinBodies"]!;
      final skinFrame = skinSheet.byName[engine.progress.selectedSkin] ?? skinSheet.byName["classic"];
      final bodyBob = p.grounded ? sin(DateTime.now().millisecondsSinceEpoch / 85.0) * 2.4 : 0.0;
      final bodyTilt = clamp(terrainSlope(r, h, r.worldX) * 0.22, -0.28, 0.22);
      _drawFrameAnchored(ctx, skinSheet.image, skinFrame, px, footY + bodyBob, 0.245, alpha: alpha, rotation: bodyTilt);
      drawSelectedWeapon(ctx, px, p.y, alpha, bodyTilt);
    }

    if (r.shieldReady || p.dashTimer > 0) {
      ctx.drawCircle(Offset(scrPX() + 2, p.y + 3), p.dashTimer > 0 ? 54 : 45, Paint()..color = (r.shieldReady ? const Color(0xD96EEBFF) : const Color(0xE6FFE478))..style = PaintingStyle.stroke..strokeWidth = 4);
    }
  }

  void drawSkinAura(Canvas ctx, double px, double py) {
    final skin = engine.progress.selectedSkin;
    final level = engine.progress.skins[skin]?.level ?? 1;
    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final pulse = 0.5 + sin(t * 5) * 0.5;
    ctx.save();
    ctx.translate(px, py);

    switch (skin) {
      case "ninja":
        final strokePaint = Paint()..color = (level == 2 ? const Color.fromRGBO(68, 255, 155, 0.95) : const Color.fromRGBO(68, 255, 155, 0.55))..style = PaintingStyle.stroke..strokeWidth = level == 2 ? 5.0 : 3;
        for (int i = 0; i < 4; i++) {
          final path = Path()..moveTo(-78 - i * 15.0, 18 - i * 10.0)..quadraticBezierTo(-34, -24 - pulse * 12, 28 + i * 6.0, -8 + i * 5.0);
          ctx.drawPath(path, strokePaint);
        }
        break;
      case "mecha":
        final mp = Paint()..color = ((level == 2 || engine.run?.shieldReady == true) ? const Color.fromRGBO(84, 220, 255, 0.88) : const Color.fromRGBO(84, 220, 255, 0.45))..style = PaintingStyle.stroke..strokeWidth = 3;
        for (double r = 42; r <= 58; r += 16) {
          final hexPath = Path();
          for (int i = 0; i < 6; i++) {
            final angle = t * 0.9 + i * pi / 3;
            final hx = cos(angle) * r;
            final hy = sin(angle) * r;
            i == 0 ? hexPath.moveTo(hx, hy) : hexPath.lineTo(hx, hy);
          }
          hexPath.close();
          ctx.drawPath(hexPath, mp);
        }
        break;
      case "agent_h":
        ctx.drawArc(Rect.fromCircle(center: Offset.zero, radius: 46 + (pulse * 6)), -0.8, 1.7, false, Paint()..color = const Color.fromRGBO(255, 222, 67, 0.8)..style = PaintingStyle.stroke..strokeWidth = 3);
        drawTinySparkles(ctx, const Color(0xCCffe15f), t, level == 2 ? 9 : 5);
        break;
      case "pirate":
        drawTinySparkles(ctx, const Color(0xCCfbbf24), t * 1.2, level == 2 ? 10 : 6);
        ctx.drawArc(Rect.fromCircle(center: Offset(0, 5), radius: 48 + pulse * 9), 0.35, pi * 1.1, false, Paint()..color = const Color.fromRGBO(255, 190, 72, 0.62)..style = PaintingStyle.stroke..strokeWidth = 4);
        break;
      case "astronaut":
        for (int i = 0; i < 3; i++) {
          ctx.drawOval(Rect.fromCenter(center: Offset(0, -4), width: (108 + i * 16).toDouble(), height: (36 + i * 12).toDouble()), Paint()..color = const Color.fromRGBO(132, 225, 255, 0.78)..style = PaintingStyle.stroke..strokeWidth = 3);
        }
        drawTinySparkles(ctx, const Color(0xCCbff3ff), t, level == 2 ? 8 : 4);
        break;
      case "zombie":
        for (int i = 0; i < (level == 2 ? 10 : 6); i++) {
          final angle = t * 1.7 + i * 1.9;
          final r = 26.0 + ((i * 17 + t * 22) % 48);
          ctx.drawCircle(Offset(cos(angle) * r, sin(angle * 1.2) * 28), 4 + (i % 3).toDouble(), Paint()..color = const Color.fromRGBO(91, 255, 86, 0.35));
        }
        break;
      case "knight":
        ctx.drawArc(Rect.fromCircle(center: Offset(0, 2), radius: 48 + pulse * 5), pi * 0.75, pi * 1.5, false, Paint()..color = const Color.fromRGBO(226, 232, 240, 0.82)..style = PaintingStyle.stroke..strokeWidth = 4);
        for (int i = 0; i < 7; i++) {
          final a = -0.2 + i * 0.38;
          ctx.drawLine(Offset(cos(a) * 45, sin(a) * 45), Offset(cos(a) * 63, sin(a) * 63), Paint()..color = const Color.fromRGBO(255, 255, 255, 0.5)..strokeWidth = 2);
        }
        break;
      case "wizard":
        for (int i = 0; i < 4; i++) {
          final a = t * (0.9 + i * 0.12) + i * 1.4;
          ctx.drawCircle(Offset(cos(a) * 38, sin(a) * 24), 7 + pulse * 3, Paint()..color = const Color.fromRGBO(206, 107, 255, 0.78)..style = PaintingStyle.stroke..strokeWidth = 3);
        }
        drawTinySparkles(ctx, const Color(0xCCf0abfc), t, level == 2 ? 9 : 5);
        break;
      case "gym_bro":
        for (int i = 0; i < 3; i++) {
          ctx.drawArc(Rect.fromCircle(center: Offset.zero, radius: 40 + i * 14 + pulse * 8), 0.2 + i, pi * 0.9 + i, false, Paint()..color = (level == 2 ? const Color.fromRGBO(255, 91, 91, 0.95) : const Color.fromRGBO(255, 145, 77, 0.7))..style = PaintingStyle.stroke..strokeWidth = 5);
        }
        break;
      default:
        drawTinySparkles(ctx, const Color(0xCCfff6a7), t, level == 2 ? 7 : 3);
    }
    ctx.restore();
  }

  void drawTinySparkles(Canvas ctx, Color c, double t, int count) {
    final paint = Paint()..color = c;
    for (int i = 0; i < count; i++) {
      final angle = t * (1.2 + i * 0.08) + i * 2.31;
      final r = 32.0 + ((i * 19 + t * 18) % 34);
      ctx.save();
      ctx.translate(cos(angle) * r, sin(angle * 1.1) * r * 0.65);
      ctx.rotate(angle);
      ctx.drawRect(Rect.fromLTWH(-2, -7, 4, 14), paint);
      ctx.drawRect(Rect.fromLTWH(-7, -2, 14, 4), paint);
      ctx.restore();
    }
  }

  void drawSelectedWeapon(Canvas ctx, double px, double py, double alpha, double bodyTilt) {
    final sheet = sprites["weaponCutouts"];
    final frame = sheet?.byName[engine.progress.selectedWeapon];
    if (sheet == null || frame == null) return;

    final weaponHeights = {"walnut_cannon": 44.0, "laser_pointer": 30.0, "carrot_missile": 36.0, "cheese_thrower": 32.0, "peanut_splat": 36.0, "boomerang_twig": 34.0, "sonic_squeak": 36.0, "melon_sniper": 31.0, "corn_cob": 33.0, "seed_gatling": 36.0};
    final gripTuning = {"walnut_cannon": [0.29, 0.62, 1.0], "laser_pointer": [0.25, 0.58, 0.0], "carrot_missile": [0.27, 0.6, 1.0], "cheese_thrower": [0.25, 0.6, 0.0], "peanut_splat": [0.25, 0.6, 1.0], "boomerang_twig": [0.34, 0.62, 0.0], "sonic_squeak": [0.28, 0.6, 0.0], "melon_sniper": [0.22, 0.58, 2.0], "corn_cob": [0.27, 0.6, 0.0], "seed_gatling": [0.29, 0.6, 1.0]};

    final p = engine.run?.player;
    final recoil = p != null && p.weaponFlash > 0 ? -5.0 : 0.0;
    final floatBob = p != null && p.grounded ? sin(DateTime.now().millisecondsSinceEpoch / 90.0) * 1.1 : -2.0;
    final footY = py + (p?.radius ?? 31.0);
    final gripX = px + 24 + recoil;
    final gripY = footY - 40 + floatBob;

    final gt = gripTuning[engine.progress.selectedWeapon] ?? [0.28, 0.6, 0.0];
    final h = weaponHeights[engine.progress.selectedWeapon] ?? 36.0;
    _drawWeaponAtGrip(ctx, sheet.image, frame, gripX, gripY + gt[2], h, gt[0], gt[1], alpha, bodyTilt * 0.18 + (((p?.weaponFlash ?? 0) > 0) ? -0.06 : 0));
  }

  void _drawWeaponAtGrip(Canvas ctx, ui.Image img, Frame frame, double gripX, double gripY, double height, double gripU, double gripV, double alpha, double rotation) {
    final crop = frame.content;
    final scale = height / crop.height;
    final localGripX = crop.width * gripU;
    final localGripY = crop.height * gripV;
    ctx.save();
    ctx.translate(gripX, gripY);
    ctx.rotate(rotation);
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
    ctx.drawImageRect(
      img,
      Rect.fromLTWH(crop.left, crop.top, crop.width, crop.height),
      Rect.fromLTWH(-localGripX * scale, -localGripY * scale, crop.width * scale, crop.height * scale),
      paint,
    );
    ctx.restore();
  }

  void drawDefeatPlayer(Canvas ctx, double w, double h) {
    final r = engine.run!;
    final anim = defeatAnimationFor(engine.progress.selectedSkin);
    final elapsed = r.defeatAt > 0 ? (DateTime.now().millisecondsSinceEpoch / 1000.0 - r.defeatAt) : 0.0;
    final px = scrPX();
    final footY = terrainY(r, h, r.worldX) + 2;
    if (anim != null) {
      final idx = min(anim.$2.length - 1, (elapsed * 5).floor());
      _drawFrameAnchored(ctx, anim.$1.image, anim.$2[idx], px, footY, 0.255, rotation: sin(elapsed * 7) * 0.04);
    }
  }

  (SpriteSheet, List<Frame>)? defeatAnimationFor(String skin) {
    final sheetA = sprites["defeatAnimA"];
    final sheetB = sprites["defeatAnimB"];
    if (sheetA?.animations.containsKey(skin) == true) return (sheetA!, sheetA.animations[skin]!);
    if (sheetB?.animations.containsKey(skin) == true) return (sheetB!, sheetB.animations[skin]!);
    return null;
  }

  void drawEffects(Canvas ctx, double w, double h) {
    final r = engine.run!;
    final sheet = sprites["effects"];
    if (sheet == null) return;
    for (final e in r.effects) {
      final frames = sheet.animations[e.name];
      if (frames == null || frames.isEmpty) continue;
      final idx = min(frames.length - 1, ((e.t / e.duration) * frames.length).floor());
      _drawFrameByHeight(ctx, sheet.image, frames[idx], e.x, e.y + e.size * 0.5, e.size, alpha: 1 - e.t / e.duration);
    }
  }

  void drawLabels(Canvas ctx, double w, double h) {
    final r = engine.run!;
    for (final label in r.labels) {
      final alpha = 1 - label.t / label.duration;
      Color c;
      try { c = Color(int.parse('0xFF${label.color.substring(1)}')); } catch (_) { c = Colors.white; }
      final tp = TextPainter(text: TextSpan(text: label.text, style: TextStyle(color: c.withValues(alpha: alpha), fontSize: 22, fontWeight: FontWeight.w800)), textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(ctx, Offset(label.x - tp.width / 2, label.y));
    }
  }

  void drawGameOverShade(Canvas ctx, double w, double h) {
    ctx.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color.fromRGBO(4, 8, 16, 0.36));
  }
}


