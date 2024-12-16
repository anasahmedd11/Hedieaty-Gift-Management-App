import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hedieaty_project/Friends/AddFriendManually.dart';
import 'package:hedieaty_project/Friends/FriendsList.dart';
import 'package:hedieaty_project/OnBoarding/Login.dart';
import 'Notifications/LocalNotifications.dart';
import 'firebase_options.dart';

final theme = ThemeData(
  useMaterial3: true,
  textTheme: GoogleFonts.latoTextTheme(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();

  NotificationService().initNotification();

  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      initialRoute: '/Sign_in',
      //FirebaseAuth.instance.currentUser == null ? '/Sign_in' : '/Home',
      routes: {
        '/Sign_in': (context) => const LoginScreen(),
        '/Home': (context) => const HomePage(),
        '/Add': (context) => const AddFriend(),
      },
    );
  }
}
