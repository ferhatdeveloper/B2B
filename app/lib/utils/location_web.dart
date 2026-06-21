import 'package:web/web.dart' as web;

String currentSearch() => web.window.location.search;

void clearQuery() {
  final loc = web.window.location;
  web.window.history.replaceState(null, '', '${loc.pathname}${loc.hash}');
}
