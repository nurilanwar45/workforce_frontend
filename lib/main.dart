import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_colors.dart';
import 'widgets/custom_bottom_nav.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/leave_permit_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/camera_attendance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Modern status bar overlay styling matching SSI Peach/Coral theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.peachBackground,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Check saved session (Auto-Login)
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  final bool isLoggedIn = token != null && token.isNotEmpty;

  runApp(FrontendTmMobileApp(initialLoggedIn: isLoggedIn));
}

class FrontendTmMobileApp extends StatelessWidget {
  final bool initialLoggedIn;

  const FrontendTmMobileApp({
    super.key,
    required this.initialLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SSI Presensi Online',
      theme: getAppTheme(),
      home: initialLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openCameraAttendance() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CameraAttendanceScreen(isClockIn: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 4 Main Screens corresponding to Bottom Navigation Tabs
    final screens = [
      HomeScreen(
        onNavigateToHistory: () => _onTabSelected(1),
        onNavigateToPermit: () => _onTabSelected(2),
        onNavigateToProfile: () => _onTabSelected(3),
      ),
      const HistoryScreen(),
      const LeavePermitScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.peachBackground,
      // IndexedStack preserves state across tab switching
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // Center Docked Floating Action Button in Coral Orange with Scan Camera Icon
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _openCameraAttendance,
        backgroundColor: AppColors.primaryCoral,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.camera_alt_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      // Bottom Navigation Bar with Curved Cutout
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}