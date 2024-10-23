import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'package:fruit_cutting_game/main_router_game.dart';

class TutorialListComponent extends PositionComponent with HasGameReference<MainRouterGame> {
  final List<TutorialComponent> fruits;
  final bool isLeft;

  TutorialListComponent({
    required this.fruits,
    required this.isLeft,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    for (var fruit in fruits) {
      add(fruit);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (var i = 0; i < fruits.length; i++) {
      // Tính toán vị trí x cho các fruits
      double xPosition = isLeft
          ? 30 // Bên trái
          : game.size.x - 30; // Bên phải

      // Cập nhật vị trí của fruit
      fruits[i].position = Vector2(xPosition, i * game.size.y / 6 + 20);
    }
  }
}

class TutorialComponent extends PositionComponent with HasGameReference<MainRouterGame> {
  final String text;
  final String imagePath;
  final bool isLeft;

  late Vector2 imageSize;

  TutorialComponent({
    required this.text,
    required this.imagePath,
    required this.isLeft,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 23,
        color: AppColors.white,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
        fontWeight: FontWeight.w400,
      ),
    );

    final image = await Flame.images.load(imagePath);
    final sprite = Sprite(image);

    final imageSize = Vector2(game.size.y / 8, game.size.y / 8);

    final spriteComponent = SpriteComponent(
      sprite: sprite,
      size: imageSize,
    )..position = Vector2(isLeft ? 0 : -50, 0); // Vị trí của ảnh

    final textComponent = TextComponent(
      text: text,
      position: Vector2(isLeft ? 70 : -70, imageSize.y / 2),
      anchor: isLeft ? Anchor.centerLeft : Anchor.centerRight,
      textRenderer: textPaint,
    );

    add(spriteComponent);
    add(textComponent);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    imageSize = Vector2(game.size.y / 8, game.size.y / 8);
  }
}
