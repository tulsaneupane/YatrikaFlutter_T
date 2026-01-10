import 'package:flutter/material.dart';
import '../components/app_colors.dart';
import '../../services/api_client.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.isLoggedIn = false,
    this.onLogin,
    this.onLogout,
  });

  final bool isLoggedIn;
  final VoidCallback? onLogin;
  final VoidCallback? onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>?> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _initFetch();
  }

  void _initFetch() {
    if (widget.isLoggedIn) {
      _userProfileFuture = _fetchUserProfile();
    }
  }

  // Refresh data when login status changes
  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoggedIn && !oldWidget.isLoggedIn) {
      setState(() {
        _userProfileFuture = _fetchUserProfile();
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    try {
      // Calls your GET /api/auth/me endpoint
      final response = await ApiClient.get('/api/auth/me');
      return response;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  Future<void> _handleLogout() async {
    await ApiClient.logout();
    if (widget.onLogout != null) {
      widget.onLogout!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn) {
      return _GuestProfileView(onLogin: widget.onLogin);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _userProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data;
            final firstName = userData?['firstName'] ?? 'User';
            final lastName = userData?['lastName'] ?? '';
            final username = userData?['username'] ?? 'username';
            final email = userData?['email'] ?? 'Not set';
            final phone = userData?['phoneNumber'] ?? 'Add phone';

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _userProfileFuture = _fetchUserProfile();
                });
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileHeader(onLogout: _handleLogout),
                    const SizedBox(height: 16),
                    _ProfileCard(
                      fullName: '$firstName $lastName',
                      username: '@$username',
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel(title: 'Account Settings'),
                    const SizedBox(height: 8),
                    _SettingsGroup(
                      children: [
                        ProfileTile(
                          icon: Icons.mail_outline,
                          title: 'Email',
                          subtitle: email,
                        ),
                        ProfileTile(
                          icon: Icons.phone_outlined,
                          title: 'Phone Number',
                          subtitle: phone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _AboutYouCard(userData: userData),
                    const SizedBox(height: 32),
                    Center(
                      child: TextButton.icon(
                        onPressed: _handleLogout,
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- LOGGED IN COMPONENTS ---

class _ProfileHeader extends StatelessWidget {
  final VoidCallback onLogout;
  const _ProfileHeader({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Manage your personal info', style: TextStyle(color: AppColors.subtext)),
          ],
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz),
          onSelected: (val) => val == 'logout' ? onLogout() : null,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'logout', child: Text('Logout', style: TextStyle(color: Colors.red))),
          ],
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String fullName;
  final String username;
  const _ProfileCard({required this.fullName, required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(username, style: const TextStyle(color: AppColors.subtext)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(color: AppColors.subtext, fontWeight: FontWeight.bold, fontSize: 13));
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(children: children),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const ProfileTile({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}

class _AboutYouCard extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const _AboutYouCard({this.userData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 24),
          Text('First Name: ${userData?['firstName'] ?? '---'}'),
          const SizedBox(height: 8),
          Text('Last Name: ${userData?['lastName'] ?? '---'}'),
        ],
      ),
    );
  }
}

// --- UNIQUE GUEST VIEW ---

class _GuestProfileView extends StatelessWidget {
  final VoidCallback? onLogin;
  const _GuestProfileView({this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 320,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Yatrika', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Text('Your Travel\nJournal Awaits', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, height: 1.1)),
                      const SizedBox(height: 10),
                      Text('Sign in to sync your trips and explore more.', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const _FeatureGrid(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(onLoginSuccess: onLogin)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("Sign In / Create Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("or continue with", style: TextStyle(color: AppColors.subtext, fontSize: 12))),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialBtn(icon: Icons.g_mobiledata, color: Colors.red, label: "Google"),
                      const SizedBox(width: 20),
                      _SocialBtn(icon: Icons.facebook, color: Colors.blue.shade800, label: "Facebook"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.4,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _FCard(icon: Icons.auto_awesome, title: "AI Planner"),
        _FCard(icon: Icons.favorite_border, title: "Favorites"),
        _FCard(icon: Icons.public, title: "Community"),
        _FCard(icon: Icons.history, title: "Trip History"),
      ],
    );
  }
}

class _FCard extends StatelessWidget {
  final IconData icon;
  final String title;
  const _FCard({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.stroke)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _SocialBtn({required this.icon, required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.stroke), color: Colors.white),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}