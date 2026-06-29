import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

class Frame {
  final String name;
  final ui.Rect source;
  final ui.Rect content;
  final ui.Offset anchor;

  const Frame({
    required this.name,
    required this.source,
    required this.content,
    required this.anchor,
  });

  factory Frame.fromJson(Map<String, dynamic> json) {
    return Frame(
      name: json['name'] as String,
      source: _rectFromJson(json['source'] as Map<String, dynamic>),
      content: _rectFromJson(json['content'] as Map<String, dynamic>? ?? json['source']),
      anchor: _offsetFromJson(json['anchor'] as Map<String, dynamic>? ?? {'x': 0, 'y': 0}),
    );
  }

  static ui.Rect _rectFromJson(Map<String, dynamic> json) {
    return ui.Rect.fromLTWH(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
      (json['w'] as num).toDouble(),
      (json['h'] as num).toDouble(),
    );
  }

  static ui.Offset _offsetFromJson(Map<String, dynamic> json) {
    return ui.Offset(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    );
  }
}

class SpriteSheet {
  final ui.Image image;
  final Map<String, Frame> byName;
  final Map<String, List<Frame>> animations;

  const SpriteSheet({
    required this.image,
    required this.byName,
    required this.animations,
  });
}

final Map<String, SpriteSheet> _cache = {};

Future<ui.Image> loadImage(String assetPath) async {
  final data = await rootBundle.load(assetPath);
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  return frame.image;
}

Future<Map<String, dynamic>> loadJson(String assetPath) async {
  final str = await rootBundle.loadString(assetPath);
  return json.decode(str) as Map<String, dynamic>;
}

Future<SpriteSheet> loadSheet(String imagePath, String jsonPath) async {
  if (_cache.containsKey(imagePath)) return _cache[imagePath]!;

  final results = await Future.wait([
    loadImage(imagePath),
    loadJson(jsonPath),
  ]);

  final image = results[0] as ui.Image;
  final data = results[1] as Map<String, dynamic>;

  final framesList = (data['frames'] as List<dynamic>)
      .map((f) => Frame.fromJson(f as Map<String, dynamic>))
      .toList();

  final byName = <String, Frame>{};
  for (final frame in framesList) {
    byName[frame.name] = frame;
  }

  final animations = <String, List<Frame>>{};
  final animsList = (data['animations'] as List<dynamic>?) ?? [];
  for (final anim in animsList) {
    final a = anim as Map<String, dynamic>;
    final name = a['name'] as String;
    final frames = (a['frames'] as List<dynamic>)
        .map((f) {
          if (f is String) return byName[f]!;
          return Frame.fromJson(f as Map<String, dynamic>);
        })
        .toList();
    animations[name] = frames;
  }

  final sheet = SpriteSheet(image: image, byName: byName, animations: animations);
  _cache[imagePath] = sheet;
  return sheet;
}

Map<String, SpriteSheet> get spriteCache => _cache;
