import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/image_composition.dart' as composition;
import 'package:flutter/material.dart';
import 'package:fruit_cutting_game/common/helpers/app_utils.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_configs.dart';
import 'package:fruit_cutting_game/data/models/fruit_model.dart';
import 'package:fruit_cutting_game/presentation/game/game.dart';

/// A component representing a fruit in the game.
/// This class manages the fruit's behavior, movement, and interactions.
class FruitComponent extends SpriteComponent {
  Vector2 velocity; // Speed and direction of the fruit.
  final Vector2 pageSize; // Size of the game page.
  final double acceleration; // Acceleration applied to the fruit's velocity.
  final FruitModel fruit; // Data model for the fruit.
  final composition.Image image; // Image representing the fruit.
  late Vector2 _initPosition; // Initial position of the fruit.
  bool canDragOnShape = false; // Flag to determine if the fruit can be dragged.
  GamePage parentComponent; // Reference to the game page.
  bool divided; // Flag indicating if the fruit has been cut.

  /// Constructor for the `FruitComponent` class.
  ///
  /// - `parentComponent`: The parent game page that contains this fruit.
  /// - `p`: The position of the fruit on the screen.
  /// - `size`: Optional size of the fruit.
  /// - `velocity`: Required initial velocity of the fruit.
  /// - `acceleration`: Required acceleration for the fruit.
  /// - `pageSize`: Required size of the game page.
  /// - `image`: Required image for the fruit.
  /// - `fruit`: Required fruit model.
  /// - `angle`: Optional initial angle of rotation.
  /// - `anchor`: Optional anchor point for positioning.
  /// - `divided`: Indicates if the fruit is already cut.
  FruitComponent(
    this.parentComponent,
    Vector2 p, {
    Vector2? size, // Optional size.
    required this.velocity, // Required velocity.
    required this.acceleration, // Required acceleration.
    required this.pageSize, // Required page size.
    required this.image, // Required image.
    required this.fruit, // Required fruit model.
    double? angle, // Optional rotation angle.
    Anchor? anchor, // Optional anchor point.
    this.divided = false, // Default divided state.
  }) : super(
          sprite: Sprite(image), // Initialize sprite with the fruit's image.
          position: p, // Set position of the fruit.
          size: size, // Set size of the fruit.
          anchor: anchor ?? Anchor.center, // Set anchor, default is center.
          angle: angle, // Set angle of rotation.
        ) {
    _initPosition = p; // Store initial position.
    canDragOnShape = false; // Initially, dragging is disabled.
  }

  @override
  void update(double dt) {
    // Update the fruit's state.
    super.update(dt); // Call parent class's update method.
    if (_initPosition.distanceTo(position) > 60) {
      canDragOnShape = true; // Enable dragging if moved far enough.
    }
    angle += .5 * dt; // Rotate the fruit based on time.
    angle %= 2 * pi; // Keep angle within 0 to 2π.

    // Update position based on velocity and gravity.
    position += Vector2(velocity.x, -(velocity.y * dt - .5 * AppConfig.gravity * dt * dt));

    // Update vertical velocity with acceleration and gravity.
    velocity.y += (AppConfig.acceleration + AppConfig.gravity) * dt;

    // Remove fruit if it goes off-screen.
    if ((position.y - AppConfig.objSize) > pageSize.y) {
      removeFromParent(); // Remove the fruit from the game.

      // Increment mistake count if the fruit is not divided and is not a bomb.
      if (!divided && !fruit.isBomb) {
        parentComponent.addMistake();
      }
    }
  }

  /// Handles touch events on the fruit.
  ///
  /// - `vector2`: The point where the fruit was touched.
  void touchAtPoint(Vector2 vector2) {
    if (divided && !canDragOnShape) {
      return; // Prevent dragging if already divided.
    }
    if (fruit.isBomb) {
      parentComponent.gameOver(); // Trigger game over if a bomb is touched.
      return;
    }

    // Calculate the angle of the touch relative to the fruit's center.
    final a = AppUtils.getAngleOfTouchPont(center: position, initAngle: angle, touch: vector2);

    // Check if the touch is along the vertical or horizontal axis.
    if (a < 45 || (a > 135 && a < 225) || a > 315) {
      // Create two half images for a vertical cut.
      final dividedImage1 = composition.ImageComposition()..add(image, Vector2(0, 0), source: Rect.fromLTWH(0, 0, image.width.toDouble(), image.height / 2)),
          dividedImage2 = composition.ImageComposition()..add(image, Vector2(0, 0), source: Rect.fromLTWH(0, image.height / 2, image.width.toDouble(), image.height / 2));

      parentComponent.addAll([
        // Add both halves to the game.
        FruitComponent(
          parentComponent,
          center - Vector2(size.x / 2 * cos(angle), size.x / 2 * sin(angle)),
          fruit: fruit,
          image: dividedImage2.composeSync(),
          acceleration: acceleration,
          velocity: Vector2(velocity.x - 2, velocity.y),
          pageSize: pageSize,
          divided: true, // Mark as divided.
          size: Vector2(size.x, size.y / 2),
          angle: angle,
          anchor: Anchor.topLeft,
        ),
        FruitComponent(
          parentComponent,
          center + Vector2(size.x / 4 * cos(angle + 3 * pi / 2), size.x / 4 * sin(angle + 3 * pi / 2)),
          size: Vector2(size.x, size.y / 2),
          angle: angle,
          anchor: Anchor.center,
          fruit: fruit,
          image: dividedImage1.composeSync(),
          acceleration: acceleration,
          velocity: Vector2(velocity.x + 2, velocity.y),
          pageSize: pageSize,
          divided: true, // Mark as divided.
        )
      ]);
    } else {
      // Create two half images for a horizontal cut.
      final dividedImage1 = composition.ImageComposition()..add(image, Vector2(0, 0), source: Rect.fromLTWH(0, 0, image.width / 2, image.height.toDouble())),
          dividedImage2 = composition.ImageComposition()..add(image, Vector2(0, 0), source: Rect.fromLTWH(image.width / 2, 0, image.width / 2, image.height.toDouble()));

      parentComponent.addAll([
        // Add both halves to the game.
        FruitComponent(
          parentComponent,
          center - Vector2(size.x / 4 * cos(angle), size.x / 4 * sin(angle)),
          size: Vector2(size.x / 2, size.y),
          angle: angle,
          anchor: Anchor.center,
          fruit: fruit,
          image: dividedImage1.composeSync(),
          acceleration: acceleration,
          velocity: Vector2(velocity.x - 2, velocity.y),
          pageSize: pageSize,
          divided: true, // Mark as divided.
        ),
        FruitComponent(
          parentComponent,
          center + Vector2(size.x / 2 * cos(angle + 3 * pi / 2), size.x / 2 * sin(angle + 3 * pi / 2)),
          size: Vector2(size.x / 2, size.y),
          angle: angle,
          anchor: Anchor.topLeft,
          fruit: fruit,
          image: dividedImage2.composeSync(),
          acceleration: acceleration,
          velocity: Vector2(velocity.x + 2, velocity.y),
          pageSize: pageSize,
          divided: true, // Mark as divided.
        )
      ]);
    }

    parentComponent.addScore(); // Update score when the fruit is cut.
    removeFromParent(); // Remove the original fruit from the game.
  }
}
