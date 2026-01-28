import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/auth_service.dart';
import '../../app/themes/app_colors.dart';
import '../../app/routes/app_routes.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = Get.find<AuthService>();
  
  final RxBool _isLogin = true.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 400.w),
                    padding: EdgeInsets.all(32.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryStart.withOpacity(isDark ? 0.3 : 0.08),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogo(),
                        SizedBox(height: 32.h),
                        Obx(() => Text(
                          _isLogin.value ? "Hi, Welcome Back!" : "Join HireCraft AI",
                          style: GoogleFonts.outfit(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        )),
                        SizedBox(height: 8.h),
                        Text(
                          "Your AI-powered career starts here",
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp, 
                            color: Theme.of(context).textTheme.bodyMedium?.color, 
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32.h),
                        
                        Obx(() => Column(
                          children: [
                            if (!_isLogin.value) ...[
                              _buildTextField(_usernameController, "Username", Icons.person_outline_rounded),
                              SizedBox(height: 16.h),
                            ],
                            _buildTextField(_emailController, "Email Address", Icons.alternate_email_rounded),
                            SizedBox(height: 16.h),
                            _buildTextField(
                              _passwordController, 
                              "Password", 
                              Icons.lock_person_rounded, 
                              isPassword: true,
                              obscureRx: _obscurePassword,
                            ),
                            if (!_isLogin.value) ...[
                              SizedBox(height: 16.h),
                              _buildTextField(
                                _confirmPasswordController, 
                                "Confirm Password", 
                                Icons.lock_reset_rounded, 
                                isPassword: true,
                                obscureRx: _obscureConfirmPassword,
                              ),
                            ],
                          ],
                        )),
                        
                        SizedBox(height: 32.h),
                        _buildMainButton(),
                        SizedBox(height: 24.h),
                        _buildDivider(),
                        SizedBox(height: 24.h),
                        _buildGoogleButton(),
                        SizedBox(height: 32.h),
                        _buildToggleLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryStart, AppColors.primaryEnd],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.bolt_rounded, size: 36.sp, color: Colors.white),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: CircleAvatar(
            radius: 150.r,
            backgroundColor: AppColors.primaryStart.withOpacity(0.05),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: CircleAvatar(
            radius: 100.r,
            backgroundColor: AppColors.primaryEnd.withOpacity(0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, RxBool? obscureRx}) {
    if (isPassword && obscureRx != null) {
      return Obx(() => TextField(
        controller: controller,
        obscureText: obscureRx.value,
      style: GoogleFonts.outfit(fontSize: 15.sp, color: Theme.of(Get.context!).colorScheme.onSurface, fontWeight: FontWeight.w600),
      decoration: _getInputDecoration(label, icon, isPassword: isPassword, obscureRx: obscureRx),
      ));
    }
    return TextField(
      controller: controller,
      style: GoogleFonts.outfit(fontSize: 15.sp, color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
      decoration: _getInputDecoration(label, icon),
    );
  }

  InputDecoration _getInputDecoration(String label, IconData icon, {bool isPassword = false, RxBool? obscureRx}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.outfit(color: const Color(0xFF475569), fontSize: 13.sp, fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, size: 20.sp, color: AppColors.primaryStart),
      suffixIcon: (isPassword && obscureRx != null)
          ? IconButton(
              onPressed: () => obscureRx.toggle(),
              icon: Icon(
                obscureRx.value ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 20.sp,
                color: const Color(0xFF64748B),
              ),
            )
          : null,
      filled: true,
      fillColor: Theme.of(Get.context!).inputDecorationTheme.fillColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Theme.of(Get.context!).dividerColor.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primaryStart, width: 1.5),
      ),
    );
  }

  Widget _buildMainButton() {
    return Obx(() => Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStart.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading.value ? null : _handleAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: _isLoading.value 
          ? SizedBox(
              height: 20.h,
              width: 20.h,
              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Text(
              _isLogin.value ? "Login Now" : "Create Account", 
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
      ),
    ));
  }

  Widget _buildGoogleButton() {
    return OutlinedButton(
      onPressed: _isLoading.value ? null : _handleGoogleSignIn,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
        minimumSize: Size(double.infinity, 54.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        backgroundColor: Theme.of(context).cardColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.network(
            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
            height: 20.h,
            placeholderBuilder: (context) => Icon(Icons.g_mobiledata, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Text(
            "Continue with Google", 
            style: GoogleFonts.outfit(
              color: Theme.of(context).colorScheme.onSurface, 
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text("or", style: GoogleFonts.outfit(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12.sp, fontWeight: FontWeight.bold)),
        ),
        Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ],
    );
  }

  Widget _buildToggleLink() {
    return GestureDetector(
      onTap: () {
        _isLogin.toggle();
        _clearFields(); // Clear fields when toggling
        _animationController.reset();
        _animationController.forward();
      },
      child: Obx(() => RichText(
        text: TextSpan(
          style: GoogleFonts.outfit(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14.sp),
          children: [
            TextSpan(text: _isLogin.value ? "Don't have an account? " : "Already have an account? "),
            TextSpan(
              text: _isLogin.value ? "Sign Up" : "Login",
              style: TextStyle(
                color: AppColors.primaryStart, 
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      )),
    );
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _usernameController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar("Notice", "Please fill in all fields", 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black);
      return;
    }

    if (!_isLogin.value) {
      if (_usernameController.text.isEmpty) {
        Get.snackbar("Notice", "Please enter a username", 
          snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        Get.snackbar("Error", "Passwords do not match", 
          snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    _isLoading.value = true;
    try {
      if (_isLogin.value) {
        await _authService.signIn(_emailController.text.trim(), _passwordController.text.trim());
      } else {
        await _authService.signUp(
          _emailController.text.trim(), 
          _passwordController.text.trim(),
          _usernameController.text.trim(),
        );
      }
      
      if (_authService.isLoggedIn) {
        await _navigateBasedOnRole();
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _handleGoogleSignIn() async {
    _isLoading.value = true;
    try {
      await _authService.signInWithGoogle();
      if (_authService.isLoggedIn) {
        await _navigateBasedOnRole();
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _navigateBasedOnRole() async {
    await Future.delayed(const Duration(seconds: 1));
    if (_authService.isAdmin) {
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else {
      Get.offAllNamed(AppRoutes.mainShell);
    }
  }
}
