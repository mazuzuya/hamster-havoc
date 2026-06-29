import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// ── Pure PNG generator ───
class PngGen {
  static final List<int> _crcTable = _buildCrc();
  static List<int> _buildCrc() {
    final t = List<int>.filled(256, 0);
    for (int n = 0; n < 256; n++) {
      var c = n;
      for (int k = 0; k < 8; k++) c = (c & 1) != 0 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1);
      t[n] = c;
    }
    return t;
  }

  static int _crc32(List<int> d) {
    int c = 0xFFFFFFFF;
    for (final b in d) c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
    return (c ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }

  static Uint8List _chunk(String type, List<int> data) {
    final tb = type.codeUnits;
    final p = [...tb, ...data];
    final crc = _crc32(p);
    final buf = ByteData(4 + p.length + 4);
    buf.setUint32(0, data.length);
    for (int i = 0; i < p.length; i++) buf.setUint8(4 + i, p[i]);
    buf.setUint32(4 + p.length, crc);
    return buf.buffer.asUint8List();
  }

  static Future<void> save(String path, int w, int h, Uint8List px) async {
    final sig = [137, 80, 78, 71, 13, 10, 26, 10];
    final ihdr = ByteData(13);
    ihdr.setUint32(0, w); ihdr.setUint32(4, h);
    ihdr.setUint8(8, 8); ihdr.setUint8(9, 6);
    ihdr.setUint8(10, 0); ihdr.setUint8(11, 0); ihdr.setUint8(12, 0);
    final rowSize = w * 4 + 1;
    final scanlines = Uint8List(h * rowSize);
    for (int y = 0; y < h; y++) {
      scanlines[y * rowSize] = 0;
      scanlines.setRange(y * rowSize + 1, y * rowSize + 1 + w * 4, px, y * w * 4);
    }
    final compressed = ZLibCodec().encode(scanlines);
    await File(path).writeAsBytes([
      ...sig, ..._chunk('IHDR', ihdr.buffer.asUint8List()),
      ..._chunk('IDAT', compressed), ..._chunk('IEND', []),
    ]);
  }
}

// ── Pixel art drawing helpers ───
class Canvas {
  final int w, h;
  final Uint8List px;
  Canvas(this.w, this.h) : px = Uint8List(w * h * 4);

  void set(int x, int y, int r, int g, int b, {int a = 255}) {
    if (x < 0 || x >= w || y < 0 || y >= h) return;
    final i = (y * w + x) * 4;
    final srcA = a / 255;
    final dstA = px[i + 3] / 255;
    final outA = srcA + dstA * (1 - srcA);
    if (outA > 0) {
      px[i]     = ((r * srcA + px[i] * dstA * (1 - srcA)) / outA).round().clamp(0, 255);
      px[i + 1] = ((g * srcA + px[i + 1] * dstA * (1 - srcA)) / outA).round().clamp(0, 255);
      px[i + 2] = ((b * srcA + px[i + 2] * dstA * (1 - srcA)) / outA).round().clamp(0, 255);
      px[i + 3] = (outA * 255).round().clamp(0, 255);
    }
  }

  void fillRect(int x, int y, int rw, int rh, int r, int g, int b, {int a = 255}) {
    for (int dy = 0; dy < rh; dy++) {
      for (int dx = 0; dx < rw; dx++) set(x + dx, y + dy, r, g, b, a: a);
    }
  }

  void fillCircle(int cx, int cy, int radius, int r, int g, int b, {int a = 255}) {
    for (int y = -radius; y <= radius; y++) {
      for (int x = -radius; x <= radius; x++) {
        if (x * x + y * y <= radius * radius) set(cx + x, cy + y, r, g, b, a: a);
      }
    }
  }

  void drawLine(int x0, int y0, int x1, int y1, int r, int g, int b, {int a = 255}) {
    final dx = (x1 - x0).abs(), dy = (y1 - y0).abs();
    final sx = x0 < x1 ? 1 : -1, sy = y0 < y1 ? 1 : -1;
    var err = dx - dy;
    var x = x0, y = y0;
    while (true) {
      set(x, y, r, g, b, a: a);
      if (x == x1 && y == y1) break;
      final e2 = 2 * err;
      if (e2 > -dy) { err -= dy; x += sx; }
      if (e2 < dx) { err += dx; y += sy; }
    }
  }

  void fillEllipse(int cx, int cy, int rx, int ry, int r, int g, int b, {int a = 255}) {
    for (int y = -ry; y <= ry; y++) {
      for (int x = -rx; x <= rx; x++) {
        if ((x * x) / (rx * rx) + (y * y) / (ry * ry) <= 1) set(cx + x, cy + y, r, g, b, a: a);
      }
    }
  }

  void fillPolygon(List<(int, int)> points, int r, int g, int b, {int a = 255}) {
    if (points.length < 3) return;
    int minY = points.map((p) => p.$2).reduce((a, b) => a < b ? a : b);
    int maxY = points.map((p) => p.$2).reduce((a, b) => a > b ? a : b);
    for (int y = minY; y <= maxY; y++) {
      List<int> intersections = [];
      for (int i = 0; i < points.length; i++) {
        final (x1, y1) = points[i];
        final (x2, y2) = points[(i + 1) % points.length];
        if ((y1 <= y && y2 > y) || (y2 <= y && y1 > y)) {
          intersections.add((x1 + (y - y1) * (x2 - x1) ~/ (y2 - y1)).clamp(0, w - 1));
        }
      }
      intersections.sort();
      for (int i = 0; i < intersections.length - 1; i += 2) {
        fillRect(intersections[i], y, intersections[i + 1] - intersections[i] + 1, 1, r, g, b, a: a);
      }
    }
  }

  void outlineCircle(int cx, int cy, int radius, int r, int g, int b, {int a = 255}) {
    for (int angle = 0; angle < 360; angle++) {
      final rad = angle * pi / 180;
      final x = (cx + cos(rad) * radius).round();
      final y = (cy + sin(rad) * radius).round();
      set(x, y, r, g, b, a: a);
    }
  }

  void outlineEllipse(int cx, int cy, int rx, int ry, int r, int g, int b, {int a = 255}) {
    for (int angle = 0; angle < 360; angle++) {
      final rad = angle * pi / 180;
      final x = (cx + cos(rad) * rx).round();
      final y = (cy + sin(rad) * ry).round();
      set(x, y, r, g, b, a: a);
    }
  }
}

// ─── Draw Laser Pointer weapon ───
void drawLaserPointer(Canvas c) {
  // Colors (r, g, b)
  const pawFurR = 218, pawFurG = 152, pawFurB = 82;
  const pawFurDarkR = 186, pawFurDarkG = 120, pawFurDarkB = 58;
  const pawFurLightR = 240, pawFurLightG = 178, pawFurLightB = 110;
  const pawPadR = 255, pawPadG = 190, pawPadB = 140;
  const bodyRedR = 220, bodyRedG = 45, bodyRedB = 45;
  const bodyRedDarkR = 170, bodyRedDarkG = 25, bodyRedDarkB = 25;
  const bodyRedLightR = 255, bodyRedLightG = 90, bodyRedLightB = 80;
  const gripBlackR = 38, gripBlackG = 38, gripBlackB = 42;
  const gripDarkR = 22, gripDarkG = 22, gripDarkB = 26;
  const gripLightR = 58, gripLightG = 58, gripLightB = 65;
  const crystalRedR = 255, crystalRedG = 30, crystalRedB = 60;
  const crystalLightR = 255, crystalLightG = 120, crystalLightB = 140;
  const crystalGlowR = 255, crystalGlowG = 80, crystalGlowB = 100;
  const metalGrayR = 140, metalGrayG = 145, metalGrayB = 155;
  const metalDarkR = 80, metalDarkG = 85, metalDarkB = 95;
  const outlineR = 28, outlineG = 18, outlineB = 12;

  // ─ HAMSTER PAW (holding from bottom-left) ──
  c.fillEllipse(32, 72, 22, 16, pawFurR, pawFurG, pawFurB);
  c.fillEllipse(32, 72, 20, 14, pawFurLightR, pawFurLightG, pawFurLightB);

  // Fingers wrapping around grip
  c.fillEllipse(44, 52, 8, 6, pawFurR, pawFurG, pawFurB);
  c.fillEllipse(44, 51, 6, 4, pawFurLightR, pawFurLightG, pawFurLightB);
  c.fillEllipse(48, 60, 7, 5, pawFurR, pawFurG, pawFurB);
  c.fillEllipse(48, 59, 5, 3, pawFurLightR, pawFurLightG, pawFurLightB);
  c.fillEllipse(50, 68, 7, 5, pawFurR, pawFurG, pawFurB);
  c.fillEllipse(50, 67, 5, 3, pawFurLightR, pawFurLightG, pawFurLightB);
  c.fillEllipse(46, 78, 8, 6, pawFurR, pawFurG, pawFurB);
  c.fillEllipse(46, 77, 6, 4, pawFurLightR, pawFurLightG, pawFurLightB);

  // Paw pad
  c.fillEllipse(30, 74, 10, 8, pawPadR, pawPadG, pawPadB);

  // Paw outline
  c.outlineEllipse(32, 72, 22, 16, outlineR, outlineG, outlineB);
  c.outlineEllipse(44, 52, 8, 6, outlineR, outlineG, outlineB);
  c.outlineEllipse(48, 60, 7, 5, outlineR, outlineG, outlineB);
  c.outlineEllipse(50, 68, 7, 5, outlineR, outlineG, outlineB);
  c.outlineEllipse(46, 78, 8, 6, outlineR, outlineG, outlineB);

  // ── LASER POINTER BODY ──
  c.fillEllipse(72, 48, 32, 14, bodyRedR, bodyRedG, bodyRedB);
  c.fillEllipse(72, 46, 30, 11, bodyRedLightR, bodyRedLightG, bodyRedLightB);

  // Body segments (rings)
  c.fillEllipse(58, 48, 3, 14, bodyRedDarkR, bodyRedDarkG, bodyRedDarkB);
  c.fillEllipse(86, 48, 3, 14, bodyRedDarkR, bodyRedDarkG, bodyRedDarkB);

  // Grip (black handle)
  c.fillEllipse(50, 48, 10, 16, gripBlackR, gripBlackG, gripBlackB);
  c.fillEllipse(50, 46, 8, 13, gripLightR, gripLightG, gripLightB);

  // Grip texture lines
  for (int i = 0; i < 4; i++) {
    c.drawLine(44, 40 + i * 4, 56, 40 + i * 4, gripDarkR, gripDarkG, gripDarkB);
  }

  // Grip outline
  c.outlineEllipse(50, 48, 10, 16, outlineR, outlineG, outlineB);

  // Metal collar between grip and body
  c.fillEllipse(58, 48, 4, 15, metalGrayR, metalGrayG, metalGrayB);
  c.fillEllipse(58, 46, 3, 12, metalDarkR, metalDarkG, metalDarkB);
  c.outlineEllipse(58, 48, 4, 15, outlineR, outlineG, outlineB);

  // ── LASER CRYSTAL TIP ──
  c.fillPolygon([
    (104, 48), (118, 40), (126, 48), (118, 56),
  ], crystalRedR, crystalRedG, crystalRedB);

  c.fillPolygon([
    (106, 48), (116, 42), (122, 48), (116, 54),
  ], crystalLightR, crystalLightG, crystalLightB);

  c.fillPolygon([
    (110, 46), (116, 44), (120, 48), (116, 52),
  ], crystalGlowR, crystalGlowG, crystalGlowB, a: 180);

  // Crystal tip point
  c.set(126, 48, 255, 200, 200);
  c.set(127, 48, 255, 150, 150, a: 180);

  // Crystal outline
  c.drawLine(104, 48, 118, 40, outlineR, outlineG, outlineB);
  c.drawLine(118, 40, 126, 48, outlineR, outlineG, outlineB);
  c.drawLine(126, 48, 118, 56, outlineR, outlineG, outlineB);
  c.drawLine(118, 56, 104, 48, outlineR, outlineG, outlineB);

  // ── LASER BEAM (emitting from tip) ──
  c.fillEllipse(136, 48, 12, 6, crystalGlowR, crystalGlowG, crystalGlowB, a: 80);
  c.fillEllipse(148, 48, 8, 4, crystalLightR, crystalLightG, crystalLightB, a: 60);
  c.fillEllipse(158, 48, 5, 3, crystalRedR, crystalRedG, crystalRedB, a: 40);

  // Beam core
  c.drawLine(126, 48, 165, 48, 255, 100, 120, a: 200);
  c.drawLine(126, 47, 160, 47, 255, 180, 190, a: 150);
  c.drawLine(126, 49, 160, 49, 255, 180, 190, a: 150);

  // ── BODY DETAILS ──
  // Button on top
  c.fillEllipse(72, 36, 5, 3, gripBlackR, gripBlackG, gripBlackB);
  c.fillEllipse(72, 35, 4, 2, gripLightR, gripLightG, gripLightB);
  c.outlineEllipse(72, 36, 5, 3, outlineR, outlineG, outlineB);

  // Red indicator light
  c.fillCircle(80, 42, 2, 255, 50, 50);
  c.set(80, 42, 255, 200, 200);

  // Seam line on body
  c.drawLine(62, 48, 100, 48, bodyRedDarkR, bodyRedDarkG, bodyRedDarkB, a: 120);

  // Body outline
  c.outlineEllipse(72, 48, 32, 14, outlineR, outlineG, outlineB);

  // ── SHADOW under weapon ──
  c.fillEllipse(72, 88, 40, 4, 0, 0, 0, a: 40);

  // ── FUR TEXTURE on paw ─
  final rng = Random(42);
  for (int i = 0; i < 15; i++) {
    final fx = 20 + rng.nextInt(20);
    final fy = 62 + rng.nextInt(20);
    c.set(fx, fy, pawFurDarkR, pawFurDarkG, pawFurDarkB, a: 80);
  }
}

// ─── Main ───
void main() async {
  const w = 192, h = 128;
  final canvas = Canvas(w, h);

  drawLaserPointer(canvas);

  await PngGen.save('weapon_laser_pointer.png', w, h, canvas.px);
  print('Generated weapon_laser_pointer.png (${w}x${h})');

  // Icon version 64x64
  const sw = 64, sh = 64;
  final iconPx = Uint8List(sw * sh * 4);
  for (int y = 0; y < sh; y++) {
    for (int x = 0; x < sw; x++) {
      final srcX = (x * w / sw).toInt();
      final srcY = (y * h / sh).toInt();
      final si = (srcY * w + srcX) * 4;
      final di = (y * sw + x) * 4;
      iconPx[di] = canvas.px[si];
      iconPx[di + 1] = canvas.px[si + 1];
      iconPx[di + 2] = canvas.px[si + 2];
      iconPx[di + 3] = canvas.px[si + 3];
    }
  }
  await PngGen.save('weapon_laser_pointer_icon.png', sw, sh, iconPx);
  print('Generated weapon_laser_pointer_icon.png (${sw}x${sh})');
}
