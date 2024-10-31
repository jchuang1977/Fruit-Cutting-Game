import 'dart:ui';
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart' hide Game; // Hides the Game class to avoid naming conflicts.
import 'package:flame/rendering.dart';
import 'package:flame/text.dart';
import 'package:flutter/foundation.dart';
import 'package:fruit_cutting_game/common/helpers/app_save_action.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'package:fruit_cutting_game/main_router_game.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// This class represents the route for the pause screen in the game.
class VictoryRoute extends Route {
  /// Constructor for VictoryRoute, sets it to show GameVictoryPage.
  VictoryRoute() : super(GameVictoryPage.new, transparent: true);

  /// When this route is pushed (opened), stop the game time and apply a gray effect to the background.
  @override
  void onPush(Route? previousRoute) {
    previousRoute!
      ..stopTime() // Stops the game's time.
      ..addRenderEffect(
        // Adds a visual effect to the background.
        PaintDecorator.grayscale(opacity: 0.5) // Makes the background gray.
          ..addBlur(3.0), // Adds a blur effect to the background.
      );
  }

  /// When this route is popped (closed), resume game time and remove effects.
  @override
  void onPop(Route nextRoute) {
    nextRoute
      ..resumeTime() // Resumes the game's time.
      ..removeRenderEffect(); // Removes the visual effects from the background.
  }
}

/// This class represents the pause page displayed when the game is paused.
class GameVictoryPage extends Component with TapCallbacks, HasGameReference<MainRouterGame> {
  late TextComponent _textComponent; // Text component to show the "VICTORY" message.

  late TextComponent _timeComponent;

  late TextComponent _scoreComponent;

  final String timezone = 'UTC+7';

  /// Load the components for the pause page.
  @override
  Future<void> onLoad() async {
    final game = findGame()!; // Find the current game instance.

    final textTitlePaint = TextPaint(
      style: const TextStyle(
        fontSize: 80,
        color: AppColors.white,
        fontFamily: 'Marshmallow',
        letterSpacing: 3.0,
      ),
    );

    final textTimePaint = TextPaint(
      style: const TextStyle(
        fontSize: 25,
        color: AppColors.white,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
      ),
    );

    final textScorePaint = TextPaint(
      style: const TextStyle(
        fontSize: 35,
        color: AppColors.white,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
      ),
    );

    // Add the text component to display "VICTORY".
    addAll(
      [
        _textComponent = TextComponent(
          text: 'VICTORY', // The message to display when the game is paused.
          position: game.canvasSize / 2, // Center the text on the canvas.
          anchor: Anchor.center, // Set the anchor point to the center of the text.
          children: [
            // Add a scaling effect to the text to make it pulsate.
            ScaleEffect.to(
              Vector2.all(1.1), // Scale the text up to 110%.
              EffectController(
                duration: 0.3, // Duration of the scaling effect.
                alternate: true, // Make the effect go back and forth.
                infinite: true, // Repeat the effect forever.
              ),
            ),
          ],
          textRenderer: textTitlePaint,
        ),
        _timeComponent = TextComponent(
          text: "", // The message to display.
          position: game.canvasSize / 2, // Center the text on the canvas.
          anchor: Anchor.centerLeft, // Set the anchor point to the center.
          textRenderer: textTimePaint,
        ),
        _scoreComponent = TextComponent(
          text: 'Score: ', // The message to display.
          position: game.canvasSize / 2, // Center the text on the canvas.
          anchor: Anchor.center, // Set the anchor point to the center.
          textRenderer: textScorePaint,
        ),
      ],
    );
  }

  /// Called when the game is resized; updates text position to stay centered.
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size); // Call the superclass method to handle resizing.
    _textComponent.position = Vector2(game.size.x / 2, game.size.y / 2 - 50);
    _timeComponent.position = Vector2(15, 20);
    _scoreComponent.position = Vector2(game.size.x / 2, game.size.y / 2 + 60);

    _scoreComponent.text = 'Score: ${game.getScore()}';
  }

  /// Always returns true, indicating that this component can contain tap events.
  @override
  bool containsLocalPoint(Vector2 point) {
    return true; // Accept all tap events.
  }

  @override
  void update(double dt) {
    super.update(dt);

    DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
    String formattedTime = DateFormat('MM/dd/yyyy HH:mm').format(now);

    if (_timeComponent.text != '$formattedTime ($timezone)') {
      _timeComponent.text = '$formattedTime ($timezone)';
    }
  }

  /// Handle tap up events; navigate back to the previous screen when tapped.
  @override
  Future<void> onTapUp(TapUpEvent event) async {
    await captureAndSaveImage();
    // Save your score
    final GitHubService gitHubService = GitHubService(time: _timeComponent.text, score: game.getScore().toString());
    gitHubService.createIssue();
  }

  Future<void> captureAndSaveImage() async {
    try {
      final PictureRecorder recorder = PictureRecorder();
      final Rect rect = Rect.fromLTWH(0.0, 0.0, game.size.x, game.size.y);
      final Canvas c = Canvas(recorder, rect);

      game.render(c);

      final Image image = await recorder.endRecording().toImage(game.size.x.toInt(), game.size.y.toInt());
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (kIsWeb) {
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "screenshot.png")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/screenshot.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(pngBytes);
      }
      // ignore: empty_catches
    } catch (e) {
      print(e.toString());
    }
  }
}
