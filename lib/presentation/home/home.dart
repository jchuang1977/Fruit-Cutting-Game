import 'package:flame/components.dart';
import 'package:fruit_cutting_game/common/widgets/button/rounded_button.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'package:fruit_cutting_game/game.dart';

class HomePage extends Component with HasGameReference<MainRouterGame> {
  late final RoundedButton _button;

  @override
  void onLoad() async {
    super.onLoad();

    add(
      _button = RoundedButton(
        text: 'Start',
        onPressed: () {},
        bgColor: AppColors.blue,
        borderColor: AppColors.white,
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // button in center of page
    _button.position = size / 2;
  }
}
