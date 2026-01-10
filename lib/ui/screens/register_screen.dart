import 'package:flutter/material.dart';
import '../components/app_colors.dart';
import '../../services/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.onRegisterSuccess});

  final VoidCallback? onRegisterSuccess;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // All controllers required by your backend DTO
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _handleRegister() async {
    // Basic validation
    if (_emailController.text.isEmpty || _usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Please fill in all required fields");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post(
        '/api/auth/register',
        body: {
          'email': _emailController.text.trim(),
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
        },
      );

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );
        
        // Save token and trigger success callback
        if (response['accessToken'] != null) {
          ApiClient.setAuthToken(response['accessToken']);
          if (widget.onRegisterSuccess != null) {
            widget.onRegisterSuccess!();
          }
        }
        
        // Return to login or home
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: const Icon(Icons.chevron_left, color: AppColors.text),
                ),
              ),

              const SizedBox(height: 32),
              const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28)),
              const SizedBox(height: 8),
              const Text('Sign up to start planning your dream trips', style: TextStyle(color: AppColors.subtext, fontSize: 15)),

              const SizedBox(height: 32),

              // Name Row (First & Last Name)
              Row(
                children: [
                  Expanded(child: _buildLabelledField('First Name', _firstNameController, hint: 'John', icon: Icons.person_outline)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildLabelledField('Last Name', _lastNameController, hint: 'Doe', icon: Icons.person_outline)),
                ],
              ),

              const SizedBox(height: 20),
              _buildLabelledField('Username', _usernameController, hint: 'johndoe123', icon: Icons.alternate_email),
              
              const SizedBox(height: 20),
              _buildLabelledField('Email', _emailController, hint: 'email@example.com', icon: Icons.email_outlined, type: TextInputType.emailAddress),

              const SizedBox(height: 20),
              _buildLabelledField('Phone Number', _phoneController, hint: '+1 234...', icon: Icons.phone_outlined, type: TextInputType.phone),

              const SizedBox(height: 20),
              // Password
              _buildLabelledField(
                'Password', 
                _passwordController, 
                hint: '••••••••', 
                icon: Icons.lock_outline, 
                isPassword: true, 
                obscure: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword)
              ),

              const SizedBox(height: 20),
              // Confirm Password
              _buildLabelledField(
                'Confirm Password', 
                _confirmPasswordController, 
                hint: '••••••••', 
                icon: Icons.lock_outline, 
                isPassword: true, 
                obscure: _obscureConfirmPassword,
                onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)
              ),

              const SizedBox(height: 20),

              // Terms checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24, height: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('I agree to the Terms of Service and Privacy Policy', style: TextStyle(color: AppColors.subtext, fontSize: 13)),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Register button - Now connected to _handleRegister
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_agreeToTerms && !_isLoading) ? _handleRegister : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.stroke,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 32),
              // ... keep your existing social buttons and sign-in link ...
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to keep UI clean
  Widget _buildLabelledField(String label, TextEditingController controller, {required String hint, required IconData icon, bool isPassword = false, bool obscure = false, VoidCallback? onToggle, TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.stroke),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: type,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.subtext),
              prefixIcon: Icon(icon, color: AppColors.subtext),
              suffixIcon: isPassword ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.subtext),
                onPressed: onToggle,
              ) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}