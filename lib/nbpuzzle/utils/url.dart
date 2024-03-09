import 'package:url_launcher/url_launcher.dart';

void launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}
