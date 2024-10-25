import 'package:flame/components.dart';
import 'package:fruit_cutting_game/common/widgets/button/jagged_button.dart';
import 'package:fruit_cutting_game/common/widgets/button/rounded_button.dart';
import 'package:fruit_cutting_game/common/widgets/text/simple_center_text.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'package:fruit_cutting_game/main_router_game.dart';

class GameEndPage extends Component with HasGameReference<MainRouterGame> {
  late final RoundedButton _button;

  late final JaggedButton _congratulationsComponent;
  late final JaggedButton _nameComponent;
  late final JaggedButton _usernameGitHubComponent;

  @override
  void onLoad() async {
    super.onLoad();

    addAll(
      [
        _congratulationsComponent = JaggedButton(
          text: 'Congratulations to the Winner',
          bgColor: AppColors.darkOrange,
          onPressed: () {},
          borderColor: AppColors.lightGray,
          borderPosition: JaggedBorderPosition.none,
        ),
        _nameComponent = JaggedButton(
          text: 'Name',
          bgColor: AppColors.githubColor,
          onPressed: () {},
          borderColor: AppColors.lightGray,
          borderPosition: JaggedBorderPosition.top,
        ),
        _usernameGitHubComponent = JaggedButton(
          text: 'Github name',
          bgColor: AppColors.githubColor,
          onPressed: () {},
          borderColor: AppColors.lightGray,
          borderPosition: JaggedBorderPosition.bottom,
        ),
        _button = RoundedButton(
          text: 'Save',
          onPressed: () {},
          bgColor: AppColors.blue,
          borderColor: AppColors.white,
        ),
      ],
    );
    ;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    _congratulationsComponent.position = Vector2(game.size.x / 2, game.size.y / 2 - 140);
    _nameComponent.position = Vector2(game.size.x / 2, game.size.y / 2 - 60);
    _usernameGitHubComponent.position = Vector2(game.size.x / 2, game.size.y / 2 + 15);
    _button.position = Vector2(game.size.x / 2, game.size.y / 2 + 110);
  }
}
