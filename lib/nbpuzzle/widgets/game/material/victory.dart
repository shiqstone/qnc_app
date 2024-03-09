// import 'package:qnc_app/constant.dart';
import 'package:qnc_app/nbpuzzle/data/result.dart';
// import 'package:qnc_app/nbpuzzle/play_games.dart';
import 'package:qnc_app/nbpuzzle/utils/time_format.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GameVictoryDialog extends StatelessWidget {
  final Result result;

  final String Function(int) timeFormatter;

  GameVictoryDialog({
    required this.result,
    this.timeFormatter = formatElapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormatted = timeFormatter(result.time);
    final actions = <Widget>[
      new TextButton(
        child: new Text("Share"),
        onPressed: () {
          Share.share("I have solved the Number Block Puzzle's "
              "${result.size}x${result.size} puzzle in $timeFormatted "
              // "with just ${result.steps} steps! Check it out: ${Constant.URL_REPOSITORY}");
              "with just ${result.steps} steps! ");
        },
      ),
      new TextButton(
        child: new Text("Close"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ];

    // if (PlayGamesContainer.of(context) != null && PlayGamesContainer.of(context)!.isSupported) {
    //   actions.insert(
    //     0,
    //     new TextButton(
    //       child: new Text("Leaderboard"),
    //       onPressed: () {
    //         final playGames = PlayGamesContainer.of(context);
    //         playGames?.showLeaderboard(
    //           key: PlayGames.getLeaderboardOfSize(result.size),
    //         );
    //       },
    //     ),
    //   );
    // }

    return AlertDialog(
      title: Center(
        child: Text(
          "Congratulations!",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("You've successfuly completed the ${result.size}x${result.size} puzzle"),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Time:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    timeFormatted,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Steps:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${result.steps}',
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: actions,
    );
  }
}
