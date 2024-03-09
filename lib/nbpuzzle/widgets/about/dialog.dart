// import 'package:qnc_app/nbpuzzle/links.dart';
import 'package:qnc_app/constant.dart';
import 'package:qnc_app/nbpuzzle/utils/url.dart';
import 'package:flutter/material.dart';
// import 'package:package_info/package_info.dart';

class AboutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 24);

    Padding horizontalPadding(Widget child) {
      return Padding(
        padding: padding,
        child: child,
      );
    }

    return SimpleDialog(
      title: Text('About'),
      children: <Widget>[
        horizontalPadding(
            const Text('Number Block Puzzle is a free and open source app '
                'written with Flutter. It features beautiful design and '
                'smooth animations.')),
        const SizedBox(height: 8),
        // horizontalPadding(
        //     const Text('You can compete with your friends online. '
        //         'The complexity of puzzles is similar from game to game.')),
        const SizedBox(height: 24),
        ListTile(
          leading: Icon(Icons.code, size: 24),
          contentPadding: padding,
          title: const Text('Join development'),
          onTap: () {
            launchUrl(Constant.URL_REPOSITORY);
          },
        ),
        ListTile(
          leading: Icon(Icons.bug_report, size: 24),
          contentPadding: padding,
          title: const Text('Send bug report'),
          onTap: () {
            launchUrl(Constant.URL_FEEDBACK);
          },
        ),
        const SizedBox(height: 24),
        // FutureBuilder<PackageInfo>(
        //   future: PackageInfo.fromPlatform(),
        //   builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        //     String text;
        //     if (snapshot.data != null) {
        //       final buildVersion = snapshot.data!.version;
        //       final buildNumber = snapshot.data!.buildNumber;
        //       text = 'Number Block Puzzle v' + buildVersion + "-" + buildNumber;
        //     } else {
        //       text = 'Number Block Puzzle, web version';
        //     }
        //     return horizontalPadding(
        //       Semantics(
        //         label: "App version",
        //         child: Text(
        //           text,
        //           style: Theme.of(context).textTheme.bodySmall,
        //         ),
        //       ),
        //     );
        //   },
        // )
      ],
    );
  }
}
