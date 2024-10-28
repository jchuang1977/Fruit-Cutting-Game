import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';
import 'package:flame/text.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_router.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'package:fruit_cutting_game/main_router_game.dart';
import 'package:fruit_cutting_game/presentation/game/game.dart';

/// This class represents the route for the Game Save screen.
class SaveRoute extends Route {
  /// Constructor for GameSaveRoute, setting it to show GameSavePage.
  SaveRoute() : super(GameSavePage.new, transparent: true);

  /// When this route is pushed, stop the game time and apply a gray effect to the background.
  @override
  void onPush(Route? previousRoute) {
    previousRoute!
      ..stopTime() // Stops the game's time.
      ..addRenderEffect(
        // Adds a visual effect to the background.
        PaintDecorator.grayscale(opacity: 0.5) // Makes the background gray.
          ..addBlur(3.0), // Adds a blur effect.
      );
  }

  /// When this route is popped (removed), resume game time and remove effects.
  @override
  void onPop(Route nextRoute) {
    // Find any children routes that are of type GamePage.
    final routeChildren = nextRoute.children.whereType<GamePage>();
    if (routeChildren.isNotEmpty) {
      final gamePage = routeChildren.first; // Get the first GamePage.
      gamePage.removeAll(gamePage.children); // Remove all components from GamePage.
    }

    nextRoute
      ..resumeTime() // Resumes the game's time.
      ..removeRenderEffect(); // Removes the visual effects.
  }
}

/// This class represents the Game Save page displayed after the game ends.
class GameSavePage extends Component with TapCallbacks, HasGameReference<MainRouterGame> {
  late TextComponent _textNameComponent;

  late TextComponent _textExamComponent;

  /// Load the components for the Game Save page.
  @override
  FutureOr<void> onLoad() {
    final game = findGame()!; // Find the current game instance.

    final textNamePaint = TextPaint(
      style: const TextStyle(
        fontSize: 60,
        color: AppColors.white,
        fontFamily: 'Marshmallow',
        letterSpacing: 4.0,
      ),
    );

    final textExamPaint = TextPaint(
      style: const TextStyle(
        fontSize: 30,
        color: AppColors.white,
        fontFamily: 'Marshmallow',
        letterSpacing: 2.0,
      ),
    );

    // Add the text component to display "Game Save".
    addAll(
      [
        _textNameComponent = TextComponent(
          text: 'Type Your Name', // The message to display.
          position: game.canvasSize / 2, // Center the text on the canvas.
          anchor: Anchor.center, // Set the anchor point to the center.
          textRenderer: textNamePaint,
          children: [
            // Add a scaling effect to the text.
            ScaleEffect.to(
              Vector2.all(1.1), // Scale the text up to 110%.
              EffectController(
                duration: 0.6, // Duration of the scaling effect.
                alternate: true, // Make the effect go back and forth.
                infinite: true, // Repeat the effect forever.
              ),
            ),
          ],
        ),
        _textExamComponent = TextComponent(
          text: 'Example: ChunhThanhDe', // The message to display.
          position: game.canvasSize / 2, // Center the text on the canvas.
          anchor: Anchor.center, // Set the anchor point to the center.
          textRenderer: textExamPaint,
        )
      ],
    );
  }

  /// Called when the game is resized; updates text position to stay centered.
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size); // Call the superclass method.
    // _textTitleComponent.position = Vector2(game.size.x / 2, game.size.y / 2 - 80); // Recenter the text component.
    _textNameComponent.position = Vector2(game.size.x / 2, game.size.y / 2 - 30);
    _textExamComponent.position = Vector2(game.size.x / 2, game.size.y / 2 + 60);
  }

  /// Always returns true, indicating that this component can contain tap events.
  @override
  bool containsLocalPoint(Vector2 point) {
    return true; // Accept all tap events.
  }

  @override
  void update(double dt) {
    super.update(dt);

    _textNameComponent.text = game.showName() != "" ? game.showName() : "Type Your Name";
  }

  /// Handle tap up events; navigate to the home page when tapped.
  @override
  void onTapUp(TapUpEvent event) {
    game.router // Access the game's router.
      ..pop() // Go back to the previous route.
      ..pushNamed(AppRouter.homePage, replace: true); // Push the home page route.
  }
}
