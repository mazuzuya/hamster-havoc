import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// Pure Dart PNG generator — no external packages needed
class PngGenerator {
  static final List<int> _crcTable = _buildCrcTable();

  static List<int> _buildCrcTable() {
    final table = List<int>.filled(256, 0);
    for (int n = 0; n < 256; n++) {
      var c = n;
      for (int k = 0; k < 8; k++) {
        c = (c & 1) != 0 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1);
      }
      table[n] = c;
    }
    return table;
  }

  static int _crc32(List<int> data) {
    int c = 0xFFFFFFFF;
    for (final b in data) {
      c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
    }
    return (c ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }

  static Uint8List _chunk(String type, List<int> data) {
    final typeBytes = type.codeUnits;
    final payload = [...typeBytes, ...data];
    final crc = _crc32(payload);
    final buf = ByteData(4 + payload.length + 4);
    buf.setUint32(0, data.length);
    for (int i = 0; i < payload.length; i++) {
      buf.setUint8(4 + i, payload[i]);
    }
    buf.setUint32(4 + payload.length, crc);
    return buf.buffer.asUint8List();
  }

  static Future<void> generate(
    String path,
    int width,
    int height,
    Uint8List pixels, // RGBA, length = width * height * 4
  ) async {
    final signature = [137, 80, 78, 71, 13, 10, 26, 10];

    // IHDR: width(4) height(4) bitDepth(1) colorType(1) compression(1) filter(1) interlace(1)
    final ihdrData = ByteData(13);
    ihdrData.setUint32(0, width);
    ihdrData.setUint32(4, height);
    ihdrData.setUint8(8, 8);  // 8-bit
    ihdrData.setUint8(9, 6);  // RGBA
    ihdrData.setUint8(10, 0); // zlib
    ihdrData.setUint8(11, 0); // no filter
    ihdrData.setUint8(12, 0); // no interlace

    // Build scanlines: each row = filter byte (0) + pixel data
    final rowSize = width * 4 + 1;
    final scanlines = Uint8List(height * rowSize);
    for (int y = 0; y < height; y++) {
      scanlines[y * rowSize] = 0; // filter: None
      scanlines.setRange(
        y * rowSize + 1,
        y * rowSize + 1 + width * 4,
        pixels,
        y * width * 4,
      );
    }

    // Compress with zlib
    final compressed = ZLibCodec().encode(scanlines);

    final file = File(path);
    await file.writeAsBytes([
      ...signature,
      ..._chunk('IHDR', ihdrData.buffer.asUint8List()),
      ..._chunk('IDAT', compressed),
      ..._chunk('IEND', []),
    ]);
  }
}

// ─── Test: generate a 64x64 test image ───
void main() async {
  const w = 64, h = 64;
  final pixels = Uint8List(w * h * 4);

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final i = (y * w + x) * 4;
      // Gradient: red→blue diagonal, with alpha
      pixels[i]     = (x * 4).clamp(0, 255).toInt();     // R
      pixels[i + 1] = (y * 4).clamp(0, 255).toInt();     // G
      pixels[i + 2] = ((x + y) * 2).clamp(0, 255).toInt(); // B
      pixels[i + 3] = 255; // A
    }
  }

  // Draw a white circle in the center
  const cx = 32, cy = 32, cr = 20;
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final dx = x - cx, dy = y - cy;
      if (dx * dx + dy * dy <= cr * cr) {
        final i = (y * w + x) * 4;
        pixels[i]     = 255;
        pixels[i + 1] = 255;
        pixels[i + 2] = 255;
        pixels[i + 3] = 255;
      }
    }
  }

  await PngGenerator.generate('test_output.png', w, h, pixels);
  print('Generated test_output.png (${w}x${h})');
}
