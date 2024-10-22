import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';

import 'package:fruit_cutting_game/core/configs/assets/app_images.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_configs.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_router.dart';
import 'package:fruit_cutting_game/data/models/fruit_model.dart';
import 'package:fruit_cutting_game/presentation/game/game.dart';
import 'package:fruit_cutting_game/presentation/game_over/game_over.dart';
import 'package:fruit_cutting_game/presentation/game_pause/game_pause.dart';
import 'package:fruit_cutting_game/presentation/home/home.dart';

/// Main game class that extends FlameGame
class MainRouterGame extends FlameGame {
  late final RouterComponent router;
  late double maxVerticalVelocity;

  // List of available fruits in the game
  final List<FruitModel> fruits = [
    FruitModel(image: AppImages.apple),
    FruitModel(image: AppImages.banana),
    FruitModel(image: AppImages.kiwi),
    FruitModel(image: AppImages.orange),
    FruitModel(image: AppImages.peach),
    FruitModel(image: AppImages.pineapple),
    FruitModel(image: AppImages.bomb, isBomb: true),
  ];

  @override
  void onLoad() async {
    super.onLoad();

    // Load images for all fruits in the list.
    for (final fruit in fruits) {
      await images.load(fruit.image);
    }

    addAll(
      [
        ParallaxComponent(
          parallax: Parallax(
            [
              await ParallaxLayer.load(
                ParallaxImageData(AppImages.homeBG),
              ),
            ],
          ),
        ),
        // Set up the router for navigating between different game screens.
        router = RouterComponent(
          initialRoute: AppRouter.homePage,
          routes: {
            AppRouter.homePage: Route(HomePage.new),
            AppRouter.gamePage: Route(GamePage.new),
            AppRouter.gameOver: GameOverRoute(),
            AppRouter.gamePause: PauseRoute(),
          },
        )
      ],
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    getMaxVerticalVelocity(size);
  }

  /// Calculate the maximum vertical velocity based on the game size.
  void getMaxVerticalVelocity(Vector2 size) {
    // Formula to calculate maximum vertical velocity.
    maxVerticalVelocity = sqrt(2 * (AppConfig.gravity.abs() + AppConfig.acceleration.abs()) * (size.y - AppConfig.objSize * 2)); // Adjust for the object's size.
  }
}
