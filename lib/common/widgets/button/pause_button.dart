import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fruit_cutting_game/main_router_game.dart';
import 'simple_button.dart';

class PauseButtonCustom extends SimpleButton
    with HasGameReference<MainRouterGame> {
  PauseButtonCustom({VoidCallback? onPressed})
      : super(
          Path()
            ..moveTo(14, 10)
            ..lineTo(14, 30)
            ..moveTo(26, 10)
            ..lineTo(26, 30),
          position: Vector2(60, 10),
        ) {
    super.action = onPressed ?? () => () {};
  }
}
