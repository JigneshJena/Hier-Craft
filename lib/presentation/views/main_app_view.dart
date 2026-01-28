import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_view.dart';
import 'resume_builder_view.dart';
import 'domain_view.dart';
import 'resume_checker_view.dart';
import '../../app/themes/app_colors.dart';
import '../../app/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../widgets/animated_bottom_nav_bar_fab.dart';

class MainAppView extends StatefulWidget {
  const MainAppView({super.key});

  @override
  State<MainAppView> createState() => _MainAppViewState();
}

class _MainAppViewState extends State<MainAppView> {
  int _currentIndex = 0;

  // Pages Mapping
  final List<Widget> _pages = const [
    HomeView(),              // 0: Home
    ResumeBuilderView(),     // 1: Resume Builder
    DomainView(),            // (FAB): AI Interview (Handled by FAB)
    ResumeCheckerView(),     // 2: Resume Checker
    UserSettingsView(),      // 3: Settings
  ];

  // Map Bottom Nav Index to Page Index
  // Since FAB is the middle one, we skip it in the Page list if we use it differently, 
  // but here we can just map it normally.
  
  final List<BottomNavItemFAB> _navItems = const [
    BottomNavItemFAB(
      icon: Icons.home_outlined, 
      selectedIcon: Icons.home_rounded, 
      label: 'Home'
    ),
    BottomNavItemFAB(
      icon: Icons.description_outlined, 
      selectedIcon: Icons.description_rounded, 
      label: 'Builder'
    ),
    BottomNavItemFAB(
      icon: Icons.fact_check_outlined, 
      selectedIcon: Icons.fact_check_rounded, 
      label: 'Checker'
    ),
    BottomNavItemFAB(
      icon: Icons.settings_outlined, 
      selectedIcon: Icons.settings_rounded, 
      label: 'Settings'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: RepaintBoundary(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            const HomeView(),          // index 0
            const ResumeBuilderView(), // index 1
            const ResumeCheckerView(),  // index 2
            const UserSettingsView(),   // index 3
            const DomainView(),         // index 4 (Hidden from nav items, called by FAB)
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavBarWithFAB(
        currentIndex: _currentIndex > 3 ? 100 : _currentIndex, // Hide selection if on FAB page
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navItems,
        centerIcon: Icons.psychology_rounded,
        centerLabel: 'Interview',
        onCenterTap: () {
          setState(() {
            _currentIndex = 4; // DomainView
          });
        },
      ),
    );
  }
}

class UserSettingsView extends StatelessWidget {
  const UserSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = Get.find<AuthService>();
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Settings',
                style: GoogleFonts.outfit(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 32.h),
              
              // Profile Summary
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(Icons.person_rounded, size: 30.sp, color: Colors.white),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authService.user?.email?.split('@')[0].capitalizeFirst ?? 'User',
                            style: GoogleFonts.outfit(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            authService.user?.email ?? '',
                            style: GoogleFonts.outfit(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32.h),
              _buildSectionTitle('General'),
              SizedBox(height: 12.h),
              
              // Appearance Selection
              _buildSettingTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: isDark ? 'Dark Mode' : 'Light Mode',
                isDark: isDark,
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) => Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light),
                  activeColor: AppColors.primaryStart,
                ),
                onTap: () {
                  Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                },
              ),
              
              _buildSettingTile(
                icon: Icons.history_rounded,
                title: 'Interview History',
                subtitle: 'View your past sessions',
                isDark: isDark,
                onTap: () => Get.toNamed('/history'),
              ),

              _buildSettingTile(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Manage alerts',
                isDark: isDark,
                onTap: () {},
              ),
              
              SizedBox(height: 24.h),
              _buildSectionTitle('Danger Zone'),
              SizedBox(height: 12.h),
              _buildSettingTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                isDark: isDark,
                color: AppColors.accentRose,
                onTap: () => authService.signOut().then((_) => Get.offAllNamed(AppRoutes.auth)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryStart,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
  }) {
    final activeColor = color ?? AppColors.primaryStart;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: activeColor, size: 20.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ?? Icon(Icons.chevron_right_rounded, color: Colors.grey.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
