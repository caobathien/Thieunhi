import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'theme/notification_controller.dart';

// Import các wrapper và auth
import 'main/main_wrapper.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/splash/splash_screen.dart';

// Import các màn hình tính năng
import 'views/attendances/attendance_selection_screen.dart';
import 'views/assignment/class_assignment_screen.dart';
import 'views/profile/profile_screen.dart';
import 'views/term/term_summary_screen.dart';
import 'views/user/user_management_screen.dart';
import 'views/feedback/feedback_submit_screen.dart';
import 'main/about_screen.dart';
import 'views/children/child_list_screen.dart';
import 'views/auth/change_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TNTT Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainWrapper(),
        '/profile': (context) => const ProfileScreen(),
        '/attendance': (context) => const AttendanceSelectionScreen(),
        '/assignment': (context) => const ClassAssignmentScreen(),
        '/summary': (context) => const TermSummaryScreen(),
        '/management': (context) => const UserManagementScreen(),
        '/feedback': (context) => const FeedbackSubmitScreen(),
        '/about': (context) => const AboutScreen(),
        '/children': (context) => const ChildListScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
      },
    );
  }
}