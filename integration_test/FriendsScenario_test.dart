import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty_project/LocalNotifications.dart';
import 'package:hedieaty_project/main.dart';
import 'package:integration_test/integration_test.dart';

//to run specific file in integration_test folder: flutter test integration_test/FriendsScenario_test.dart
void main() async {
  await Firebase.initializeApp();
  await NotificationService().initNotification();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Friend-Scenario', () {
    testWidgets('Friend-Scenario-TestCases', (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey('emailField')), findsOneWidget);
      await tester.pumpAndSettle();

      final EmailLoginField = find.byKey(ValueKey('emailField'));
      await tester.enterText(EmailLoginField, 'anasnom2002@gmail.com');

      expect(find.byKey(ValueKey('passwordField')), findsOneWidget);
      await tester.pumpAndSettle();

      final PasswordLoginField = find.byKey(ValueKey('passwordField'));
      await tester.enterText(PasswordLoginField, 'anasahmed');

      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey('loginButton')), findsOneWidget);
      final loginButton = find.byKey(ValueKey('loginButton'));
      await tester.tap(loginButton);

      await tester.pumpAndSettle(Durations.extralong4);
      await tester.pumpAndSettle(Durations.extralong4);
      await tester.pumpAndSettle(Durations.extralong4);

      expect(find.byKey(ValueKey('addFriendOptionsButton')), findsOneWidget);
      await tester.pumpAndSettle();

      final AddFriendButton = find.byKey(ValueKey('addFriendOptionsButton'));
      await tester.tap(AddFriendButton);
      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey('addFriendFromContacts')), findsOneWidget);
      expect(find.byKey(ValueKey('addFriendManually')), findsOneWidget);

      final addFriendManually = find.byKey(ValueKey('addFriendManually'));
      await tester.tap(addFriendManually);
      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey('addFriendManuallyNameTextFormField')),
          findsOneWidget);
      final friendNameFormField =
          find.byKey(ValueKey('addFriendManuallyNameTextFormField'));
      await tester.enterText(friendNameFormField, 'testingFriend');

      expect(find.byKey(ValueKey('addFriendManuallyPhoneTextFormField')),
          findsOneWidget);
      final friendPhoneFormField =
          find.byKey(ValueKey('addFriendManuallyPhoneTextFormField'));
      await tester.enterText(friendPhoneFormField, '201122283875');

      expect(find.byKey(ValueKey('addFriendManuallyEmailTextFormField')),
          findsOneWidget);
      final friendEmailFormField =
          find.byKey(ValueKey('addFriendManuallyEmailTextFormField'));
      await tester.enterText(friendEmailFormField, 'test@gmail.com');

      expect(find.byKey(ValueKey('addFriendManuallyProfilePicTextFormField')),
          findsOneWidget);
      final friendProfilePicFormField =
          find.byKey(ValueKey('addFriendManuallyProfilePicTextFormField'));
      await tester.enterText(friendProfilePicFormField,
          'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=100');

      expect(find.text('Save'), findsOneWidget);
      final addFriendSubmitButton =
          find.byKey(ValueKey('addFriendManuallySubmitButton'));
      await tester.tap(addFriendSubmitButton);
      await tester.pumpAndSettle(Durations.extralong1);
      await tester.pumpAndSettle(Durations.extralong4);
      await tester.pumpAndSettle(Durations.extralong4);
      await tester.pumpAndSettle(Durations.extralong4);
      await tester.pumpAndSettle(Durations.extralong4);

      expect(find.text('User1Friend'), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.text('User1Friend'));
      await tester.pumpAndSettle(Durations.extralong4);

      expect(find.text('Event'), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Event'));
      await tester.pumpAndSettle(Durations.extralong4);

      expect(find.text('Gift1'), findsOneWidget);
      expect(find.byKey(ValueKey('pledgingGiftsButton')), findsOneWidget);
      final pledgeGiftButton = find.byKey(ValueKey('pledgingGiftsButton'));
      await tester.tap(pledgeGiftButton);
      await tester.pumpAndSettle(Durations.extralong4);

      expect(find.byKey(ValueKey('viewPledgedGiftsButton')), findsOneWidget);
      final viewPledgeGiftsButton = find.byKey(ValueKey('viewPledgedGiftsButton'));
      await tester.tap(viewPledgeGiftsButton);
      await tester.pumpAndSettle();

      //await tester.pageBack(); // Go back to previous screen
      //await tester.pumpAndSettle(Durations.extralong4);
    });
  });
}
