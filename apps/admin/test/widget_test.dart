import "package:admin/main.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("Admin login view renders", (WidgetTester tester) async {
    await tester.pumpWidget(const AdminApp());

    expect(find.text("Admin Login"), findsOneWidget);
    expect(find.text("Login"), findsOneWidget);
    expect(find.text("Email"), findsOneWidget);
    expect(find.text("Password"), findsOneWidget);
  });
}
