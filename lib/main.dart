import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:google_fonts/google_fonts.dart';

// Internal Imports
import 'ui/components/app_colors.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/community_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/plan_screen.dart';
import 'ui/screens/destination_list_screen.dart';
import 'services/api_client.dart'; // Ensure this path is correct

void main() async {
  // 1. Ensure Flutter bindings are initialized for async calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize ApiClient (Loads token from SharedPreferences)
  await ApiClient.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yatrika',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
        ),
        textTheme: GoogleFonts.ubuntuTextTheme(
          const TextTheme(
            bodyMedium: TextStyle(color: AppColors.text),
          ),
        ),
        fontFamily: GoogleFonts.ubuntu().fontFamily,
        useMaterial3: true,
      ),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // 3. Check if a token exists to set the initial login state
    _checkInitialLoginStatus();
  }

  void _checkInitialLoginStatus() {
    // We check the headers; if 'Authorization' exists, ApiClient has a token.
    final headers = ApiClient.headers();
    if (headers.containsKey('Authorization')) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  void _handleLogin() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  List<Widget> get _screens => [
        TourBookHome(onProfileTap: () => setState(() => _currentIndex = 4)),
        const DestinationListScreen(),
        PlanScreen(
          onBack: () => setState(() => _currentIndex = 0),
          onNavigateToDiscover: () => setState(() => _currentIndex = 1),
        ),
        const CommunityScreen(),
        ProfileScreen(
          isLoggedIn: _isLoggedIn,
          onLogin: _handleLogin,
          // If you add a logout button to ProfileScreen, pass this callback:
          onLogout: _handleLogout, 
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use IndexedStack to preserve the state of each screen
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent, // Smoother transition
        color: Colors.white,
        buttonBackgroundColor: AppColors.primary,
        height: 70,
        index: _currentIndex,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          CurvedNavigationBarItem(
            child: Icon(Icons.home_outlined, color: AppColors.text),
            label: 'Home',
            labelStyle: TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.search, color: AppColors.text),
            label: 'Discover',
            labelStyle: TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.add_circle_outline, color: AppColors.text),
            label: 'Plan',
            labelStyle: TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.article_outlined, color: AppColors.text),
            label: 'Posts',
            labelStyle: TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.person_outline, color: AppColors.text),
            label: 'Profile',
            labelStyle: TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}