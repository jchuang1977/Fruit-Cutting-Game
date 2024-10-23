import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fruit_cutting_game/common/widgets/button/rounded_button.dart';
import 'package:fruit_cutting_game/core/configs/assets/app_images.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_router.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'package:fruit_cutting_game/main_router_game.dart';
import 'package:fruit_cutting_game/presentation/home/widgets/tutorial_component.dart';

class HomePage extends Component with HasGameReference<MainRouterGame> {
  late final RoundedButton _button;

  late final TextComponent _ediblesTextComponent;

  late final TextComponent _bombTextComponent;

  @override
  void onLoad() async {
    print("game.size.y: " + game.size.y.toString());
    super.onLoad();

    final textTitlePaint = TextPaint(
      style: const TextStyle(
        fontSize: 26,
        color: AppColors.white,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
        fontWeight: FontWeight.bold,
      ),
    );

    addAll(
      [
        _button = RoundedButton(
          text: 'Start',
          onPressed: () {
            game.router.pushNamed(AppRouter.gamePage);
          },
          bgColor: AppColors.blue,
          borderColor: AppColors.white,
        ),
        _ediblesTextComponent = TextComponent(
          text: 'Edibles',
          position: Vector2(45, 10), // Cách trái 40 pixels và ở trên cùng 10 pixels
          anchor: Anchor.topLeft, // Gán anchor là topLeft để văn bản nằm ở vị trí này
          textRenderer: textTitlePaint,
        ),
        TutorialListComponent(
          isLeft: true,
          fruits: [
            TutorialComponent(text: 'Apple', imagePath: AppImages.apple, isLeft: true),
            TutorialComponent(text: 'Banana', imagePath: AppImages.banana, isLeft: true),
            TutorialComponent(text: 'Cherry', imagePath: AppImages.cherry, isLeft: true),
            TutorialComponent(text: 'Kiwi', imagePath: AppImages.kiwi, isLeft: true),
            TutorialComponent(text: 'Orange', imagePath: AppImages.orange, isLeft: true),
          ],
        )..position = Vector2(0, 50),
        _bombTextComponent = TextComponent(
          text: 'Bomb',
          position: Vector2(game.size.x - 45, 10),
          anchor: Anchor.topRight,
          textRenderer: textTitlePaint,
        ),
        TutorialListComponent(
          isLeft: false,
          fruits: [
            TutorialComponent(text: 'Bomp', imagePath: AppImages.bomb, isLeft: false),
            TutorialComponent(text: 'Flame', imagePath: AppImages.flame, isLeft: false),
            TutorialComponent(text: 'Flutter', imagePath: AppImages.flutter, isLeft: false),
          ],
        )..position = Vector2(0, 50),
      ],
    );
    ;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // button in center of page
    _button.position = size / 2;
    _bombTextComponent.position = Vector2(game.size.x - 45, 10);
  }
}
