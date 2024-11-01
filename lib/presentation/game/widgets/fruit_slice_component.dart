import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'dart:math';

class FruitSliceComponent extends ParticleSystemComponent {
  FruitSliceComponent(Vector2 position)
      : super(
          particle: Particle.generate(
            count: 100, // Increase the particle count for a very dense effect
            lifespan: 1.0, // Increase lifespan to make particles visible longer
            generator: (i) {
              final random = Random();
              final colors = [
                AppColors.darkOrange,
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.blue,
              ];
              return AcceleratedParticle(
                acceleration: Vector2(
                  (random.nextDouble() - 0.5) * 100, // Lower acceleration for a gentler spread
                  (random.nextDouble() - 0.5) * 100,
                ),
                speed: Vector2(
                  (random.nextDouble() - 0.5) * 150, // Reduce speed for slower particles
                  (random.nextDouble() - 0.5) * 150,
                ),
                position: position,
                child: CircleParticle(
                  radius: 2 + random.nextDouble() * 4, // Random radius between 2 and 6
                  paint: Paint()..color = colors[random.nextInt(colors.length)],
                ),
              );
            },
          ),
        );
}
