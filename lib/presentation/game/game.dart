import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:fruit_cutting_game/common/widgets/button/back_button.dart';
import 'package:fruit_cutting_game/common/widgets/button/pause_button.dart';
import 'package:fruit_cutting_game/presentation/game/widgets/fruit_component.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_configs.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_router.dart';
import 'package:fruit_cutting_game/main_router_game.dart';

/// The main game page where the gameplay happens.
class GamePage extends Component with DragCallbacks, HasGameReference<MainRouterGame> {
  final Random random = Random(); // Random number generator for fruit timings
  late List<double> fruitsTime; // List to hold the timing for when fruits appear
  late double time; // Current elapsed time
  late double countDown; // Countdown timer for the start of the game
  TextComponent? _countdownTextComponent; // Component to display countdown
  TextComponent? _mistakeTextComponent; // Component to display mistake count
  TextComponent? _scoreTextComponent; // Component to display score
  bool _countdownFinished = false; // Flag to check if countdown is finished
  late int mistakeCount; // Number of mistakes made by the player
  late int score; // Player's score

  /// Called when the component is added to the game.
  @override
  void onMount() {
    super.onMount();

    // Initialize game variables
    fruitsTime = []; // List to store timings for fruit appearances
    countDown = 3; // Start countdown from 3 seconds
    mistakeCount = 0; // Initialize mistake count to zero (no mistakes at the start)
    score = 0; // Set initial score to zero
    time = 0; // No time has passed at the start
    _countdownFinished = false; // Countdown has not finished yet

    double initTime = 0; // Variable to store the initial time for fruit generation

    // Generate timings for when fruits will appear
    for (int i = 0; i < 40; i++) {
      // Loop to create 40 fruit appearance timings
      if (i != 0) {
        initTime = fruitsTime.last; // Get the last recorded time for the previous fruit
      }

      // Generate random milliseconds between 0 and 0.99 seconds
      final milliSecondTime = random.nextInt(100) / 100;

      // Calculate the next fruit appearance time by adding a random value to the last time
      final componentTime = random.nextInt(1) + milliSecondTime + initTime;
      fruitsTime.add(componentTime); // Add the calculated time to the fruitsTime list
    }

    // Add game components to the page
    addAll(
      [
        // Back button to return to the previous screen
        BackButtonCustom(
          onPressed: () {
            removeAll(children); // Remove all child components
            game.router.pop(); // Navigate back in the game
          },
        ),
        // Pause button to pause the game
        PauseButtonCustom(),
        // Countdown text component to show remaining time
        _countdownTextComponent = TextComponent(
          text: '${countDown.toInt() + 1}', // Display countdown number
          size: Vector2.all(50), // Set size of the text
          position: game.size / 2, // Center position
          anchor: Anchor.center, // Anchor point for centering
        ),
        // Mistake text component to show the number of mistakes
        _mistakeTextComponent = TextComponent(
          text: 'Mistake: $mistakeCount',
          // 10 is padding
          position: Vector2(game.size.x - 10, 10),
          anchor: Anchor.topRight,
        ),
        // Score text component to show the current score
        _scoreTextComponent = TextComponent(
          text: 'Score: $score', // Display score
          position: Vector2(game.size.x - 10, _mistakeTextComponent!.position.y + 40), // Position below mistakes
          anchor: Anchor.topRight, // Anchor point for top right
        ),
      ],
    );
  }

  /// Updates the game state every frame.
  @override
  void update(double dt) {
    super.update(dt); // Call the superclass update

    if (!_countdownFinished) {
      countDown -= dt; // Decrease countdown by the time since last frame

      // Update the countdown text component with the current countdown
      _countdownTextComponent?.text = (countDown.toInt() + 1).toString();

      // Check if the countdown has finished
      if (countDown < 0) {
        _countdownFinished = true; // Set countdown finished flag
      }
    } else {
      // Remove the countdown text component once finished
      _countdownTextComponent?.removeFromParent();

      time += dt; // Increment time by the time since last frame

      // Check which fruits should appear based on the current time
      fruitsTime.where((Element) => Element < time).toList().forEach(
        (element) {
          final gameSize = game.size; // Get the size of the game area

          // Generate a random horizontal position for the fruit
          double posX = random.nextInt(gameSize.x.toInt()).toDouble();

          Vector2 fruitPosition = Vector2(posX, gameSize.y); // Set fruit position at the bottom
          Vector2 velocity = Vector2(0, game.maxVerticalVelocity); // Set vertical velocity

          final randFruit = game.fruits.random(); // Get a random fruit

          // Add a new fruit component to the game
          add(
            FruitComponent(
              this,
              fruitPosition,
              acceleration: AppConfig.acceleration, // Set fruit's acceleration
              fruit: randFruit, // Specify which fruit
              size: AppConfig.shapeSize, // Set size of the fruit
              image: game.images.fromCache(randFruit.image), // Load fruit image
              pageSize: gameSize, // Pass game size
              velocity: velocity, // Set velocity
            ),
          );
          fruitsTime.remove(element);
        },
      );
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    componentsAtPoint(event.canvasPosition).forEach((element) {
      if (element is FruitComponent) {
        if (element.canDragOnShape) {
          element.touchAtPoint(event.canvasPosition);
        }
      }
    });
  }

  /// Navigate to the game over screen.
  void gameOver() {
    game.router.pushNamed(AppRouter.gameOver); // Navigate to game over route
  }

  /// Increment the player's score by one and update the score display.
  void addScore() {
    score++; // Increase score by one
    _scoreTextComponent?.text = 'Score: $score'; // Update score display
  }

  /// Increment the mistake count and update the mistake display.
  void addMistake() {
    mistakeCount++; // Increase mistake count by one
    _mistakeTextComponent?.text = 'Mistake: $mistakeCount'; // Update mistake display
    // Check if the player has made too many mistakes
    if (mistakeCount >= 3) {
      gameOver(); // End the game if mistakes exceed limit
    }
  }
}
