import "package:customer/main.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("Customer login view renders", (WidgetTester tester) async {
    await tester.pumpWidget(const CustomerApp());

    expect(find.text("Customer Login"), findsOneWidget);
    expect(find.text("Login"), findsOneWidget);
    expect(find.text("Email"), findsOneWidget);
    expect(find.text("Password"), findsOneWidget);
  });
}
