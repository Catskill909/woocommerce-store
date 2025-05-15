import 'package:flutter_test/flutter_test.dart';
import 'package:woocommerce_app/main.dart';
import 'package:woocommerce_app/screens/product_listing_screen.dart'; // Import the ProductListingScreen

void main() {
  testWidgets('MyApp has a title and starts with a ProductListingScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp()); // Added 'const' for better performance

    final titleFinder = find.text('WooCommerce App');
    expect(titleFinder, findsOneWidget);

    final productListingFinder = find.byType(ProductListingScreen);
    expect(productListingFinder, findsOneWidget);
  });
}
