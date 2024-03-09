import 'package:provider/provider.dart';
import 'package:qnc_app/nbpuzzle/ui.dart';
import 'package:qnc_app/nbpuzzle/widgets/game/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class NbPuzzleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Number Blocks Puzzle';
    return _NbPuzzleMaterialApp(title: title);
  }
}

abstract class _NbPuzzlePlatformApp extends StatelessWidget {
  final String title;

  _NbPuzzlePlatformApp({required this.title});
}

class _NbPuzzleMaterialApp extends _NbPuzzlePlatformApp {
  _NbPuzzleMaterialApp({required String title}) : super(title: title);

  @override
  Widget build(BuildContext context) {
    final ui = ConfigUiContainer.of(context);

    ThemeData applyDecor(ThemeData theme) => theme.copyWith(
          primaryColor: Colors.blue,
          dialogTheme: const DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          ),
          textTheme: theme.textTheme.apply(fontFamily: 'ManRope'),
          primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'ManRope'),
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.amberAccent),
        );

    final baseDarkTheme = applyDecor(ThemeData(
      brightness: Brightness.dark,
      canvasColor: Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        background: Colors.black,
      ),
      cardColor: Color(0xFF1E1E1E),
    ));
    final baseLightTheme = applyDecor(ThemeData.light());

    ThemeData darkTheme;
    ThemeData lightTheme;
    if (ui?.useDarkTheme == null) {
      // auto
      darkTheme = baseDarkTheme;
      lightTheme = baseLightTheme;
    } else if (ui?.useDarkTheme == true) {
      // dark
      darkTheme = baseDarkTheme;
      lightTheme = baseDarkTheme;
    } else {
      // light
      darkTheme = baseLightTheme;
      lightTheme = baseLightTheme;
    }

    return ChangeNotifierProvider(
        create: (context) => QncAppStateProvider(),
        child: MaterialApp(
          title: title,
          darkTheme: darkTheme,
          theme: lightTheme,
          home: Container(
            child: Builder(
              builder: (context) {
                bool useDarkTheme;
                if (ui?.useDarkTheme == null) {
                  var platformBrightness = MediaQuery.of(context).platformBrightness;
                  useDarkTheme = platformBrightness == Brightness.dark;
                } else {
                  useDarkTheme = ui!.useDarkTheme!;
                }
                final overlay = useDarkTheme ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
                SystemChrome.setSystemUIOverlayStyle(
                  overlay.copyWith(
                    statusBarColor: Colors.transparent,
                  ),
                );
                return GamePage();
              },
            ),
          ),
        ));
  }
}

class QncAppStateProvider extends ChangeNotifier {
  int _balance = 0;
  String? _token;

  int get balance => _balance;

  String? get token => _token;

  void updateBalance(int newBalance) {
    _balance = newBalance;
    notifyListeners();
  }

  void updateToken(String? token) {
    _token = token;
    notifyListeners();
  }
}
