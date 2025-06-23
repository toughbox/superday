import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'constants/colors.dart';
import 'constants/themes.dart';
import 'constants/strings.dart';
import 'services/goal_provider.dart';
import 'services/web_goal_provider.dart';
import 'services/goal_provider_interface.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  //화면 세로고정
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const SuperDayApp());
}

class SuperDayApp extends StatelessWidget {
  const SuperDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GoalProviderInterface>(
      create: (context) => kIsWeb ? WebGoalProvider() : GoalProvider(),
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppThemes.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
