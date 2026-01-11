import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

// Internal Imports
import 'ui/components/app_colors.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/community_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/plan_screen.dart';
import 'ui/screens/destination_list_screen.dart';
import 'ui/screens/plan_with_ai_screen.dart';
import 'ui/screens/itinerary_screen.dart';
import 'ui/screens/tour_packages_screen.dart';
import 'ui/screens/package_details_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/register_screen.dart';
import 'ui/screens/community_post_detail.dart';
import 'services/api_client.dart'; // Ensure this path is correct
import 'routes/app_routes.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized for async calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize ApiClient (Loads token from SharedPreferences)
  await ApiClient.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<bool> _isLoggedIn = ValueNotifier<bool>(false);
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _checkInitialLoginStatus();
    _router = _buildRouter();
  }

  void _checkInitialLoginStatus() {
    // We check the headers; if 'Authorization' exists, ApiClient has a token.
    final headers = ApiClient.headers();
    if (headers.containsKey('Authorization')) {
      _isLoggedIn.value = true;
    }
  }

  void _handleLogin() {
    _isLoggedIn.value = true;
  }

  void _handleLogout() {
    _isLoggedIn.value = false;
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: AppRoutes.home,
      refreshListenable: _isLoggedIn,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainScaffold(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (context, state) => TourBookHome(
                    onProfileTap: () => context.go(AppRoutes.profile),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.discover,
                  builder: (context, state) => const DestinationListScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.plan,
                  builder: (context, state) => const PlanScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.posts,
                  builder: (context, state) => const CommunityScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.profile,
                  builder: (context, state) => ProfileScreen(
                    isLoggedIn: _isLoggedIn.value,
                    onLogin: _handleLogin,
                    onLogout: _handleLogout,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.destinations,
          builder: (context, state) => const DestinationListScreen(),
        ),
        GoRoute(
          path: AppRoutes.planAi,
          builder: (context, state) => const PlanWithAIScreen(),
        ),
        GoRoute(
          path: AppRoutes.planItinerary,
          builder: (context, state) => const ItineraryScreen(),
        ),
        GoRoute(
          path: AppRoutes.packages,
          builder: (context, state) => TourPackagesScreen(
            isLoggedIn: _isLoggedIn.value,
          ),
        ),
        GoRoute(
          path: AppRoutes.packageDetail,
          builder: (context, state) {
            final args = state.extra as PackageDetailsArgs;
            return PackageDetailsScreen(
              packageTitle: args.packageTitle,
              packagePrice: args.packagePrice,
              isLoggedIn: args.isLoggedIn,
              itineraryId: args.itineraryId,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) {
            final args = state.extra as LoginScreenArgs?;
            return LoginScreen(
              onLoginSuccess: args?.onLoginSuccess,
              onGuestContinue: args?.onGuestContinue,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) {
            final args = state.extra as RegisterScreenArgs?;
            return RegisterScreen(
              onRegisterSuccess: args?.onRegisterSuccess,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.communityPost,
          builder: (context, state) {
            final args = state.extra as CommunityPostDetailArgs;
            return CommunityPostDetail(feed: args.feed);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _isLoggedIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
      routerConfig: _router,
    );
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent, // Smoother transition
        color: Colors.white,
        buttonBackgroundColor: AppColors.primary,
        height: 70,
        index: navigationShell.currentIndex,
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
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
