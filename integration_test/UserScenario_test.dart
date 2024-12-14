import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty_project/main.dart';
import 'package:integration_test/integration_test.dart';

void main() async {
  await Firebase.initializeApp();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User-Scenario', () {
    testWidgets('User-Scenario-TestCases', (tester) async {

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey('emailField')), findsOneWidget);
      await tester.pumpAndSettle();

      final EmailLoginField = find.byKey(ValueKey('emailField'));
      await tester.enterText(EmailLoginField, 'anasnom2002@gmail.com');

      final PasswordLoginField = find.byKey(ValueKey('passwordField'));
      await tester.enterText(PasswordLoginField, 'anasahmed');

      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey('loginButton')), findsOneWidget);
      final loginButton = find.byKey(ValueKey('loginButton'));
      await tester.tap(loginButton);

      await tester.pumpAndSettle(Durations.extralong4);
      await tester.pumpAndSettle(Durations.extralong4);
      expect(find.text('Create Your Own Event/List.'), findsOneWidget);
      await tester.pumpAndSettle();

      final addItemButton = find.text('Create Your Own Event/List.');
      await tester.tap(addItemButton);
      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey('addUserEventNameTextFormField')),
          findsOneWidget);
      await tester.pumpAndSettle();

      final NametextFormField =
          find.byKey(ValueKey('addUserEventNameTextFormField'));
      await tester.enterText(NametextFormField, 'Testt Event');

      final DatetextFormField =
          find.byKey(ValueKey('addUserEventDateTextFormField'));
      await tester.enterText(DatetextFormField, '13-12-2024');

      final LocationtextFormField =
          find.byKey(ValueKey('addUserEventLocationTextFormField'));
      await tester.enterText(LocationtextFormField, 'Testing Location');

      final DescriptiontextFormField =
          find.byKey(ValueKey('addUserEventDescriptionTextFormField'));
      await tester.enterText(DescriptiontextFormField, 'Testing Description');

      final StatustextFormField =
          find.byKey(ValueKey('addUserEventStatusTextFormField'));
      await tester.enterText(StatustextFormField, 'Current');

      final addUserEventSubmitButton =
          find.byKey(ValueKey('addUserEventSubmitButton'));
      await tester.tap(addUserEventSubmitButton);
      await tester.pumpAndSettle(Durations.extralong4); //extra long to handle animation and FireStore retrieval

      expect(find.byKey(ValueKey('createEventButton')), findsNothing);
      //expect(find.byKey(ValueKey('addUserEvent')), findsOneWidget);
      await tester.pumpAndSettle(Durations.extralong4);

      expect(find.text('Testt Event'), findsOneWidget);
      // expect(find.text('13-12-2024'), findsOneWidget);
      //expect(find.text('Testing Location'), findsOneWidget);
      // expect(find.text('Testing Description'), findsOneWidget);
      //expect(find.text('Current'), findsOneWidget);

      await tester.pumpAndSettle();
      await tester.tap(find.text('Testt Event'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
      final addGift = find.byIcon(Icons.add);
      await tester.tap(addGift);
      await tester.pumpAndSettle(Durations.extralong4);

      await tester.pumpAndSettle();

      // Enter text into the text field
      final GiftNametextFormField =
          find.byKey(ValueKey('addGiftNameTextFormField'));
      await tester.enterText(GiftNametextFormField, 'Test Gift');

      final GiftDescriptiontextFormField =
          find.byKey(ValueKey('addGiftDescriptionTextFormField'));
      await tester.enterText(GiftDescriptiontextFormField, 'Test Description');

      final GiftCategorytextFormField =
          find.byKey(ValueKey('addGiftCategoryTextFormField'));
      await tester.enterText(GiftCategorytextFormField, 'Testing Category');

      final GiftPricetextFormField =
          find.byKey(ValueKey('addGiftPriceTextFormField'));
      await tester.enterText(GiftPricetextFormField, '100');

      final GiftImageURLtextFormField =
          find.byKey(ValueKey('addGiftImageTextFormField'));
      await tester.enterText(GiftImageURLtextFormField,
          'https://images.pexels.com/photos/3394668/pexels-photo-3394668.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500');

      final addUserGiftSubmitButton =
          find.byKey(ValueKey('addUserGiftSubmitButton'));
      await tester.tap(addUserGiftSubmitButton);
      await tester.pumpAndSettle(Durations.extralong4);

      // tearDown(() async {
      //   await FirebaseAuth.instance.signOut();
      // });
    });
  });
}
