import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Game;
import 'package:fruit_cutting_game/main_router_game.dart';
import 'package:fruit_cutting_game/web_title_switcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Flame.device.fullScreen();
  Flame.device.setLandscape();

  runApp(
    WebTitleSwitcher(
      child: GameWidget(
        game: MainRouterGame(),
      ),
    ),
  );
}
