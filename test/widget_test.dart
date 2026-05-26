import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:campus_link/main.dart';
import 'package:campus_link/providers/auth_provider.dart';
import 'package:campus_link/providers/post_provider.dart';
import 'package:campus_link/providers/comment_provider.dart';
import 'package:campus_link/providers/theme_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PostProvider()),
          ChangeNotifierProvider(create: (_) => CommentProvider()),
        ],
        child: const CampusLinkApp(),
      ),
    );

    // Verify that splash screen details are showing (e.g. app title)
    expect(find.text('CampusLink'), findsOneWidget);
  });
}
