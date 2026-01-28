import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/routes/app_routes.dart';

class ResponsiveAdminLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? floatingActionButton;

  const ResponsiveAdminLayout({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final bool isDesktop = constraints.maxWidth >= 1024;

        if (isMobile) {
          return _buildMobileLayout(context);
        } else {
          return _buildDesktopLayout(context, isDesktop);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isExtended) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: isExtended,
            minExtendedWidth: 200,
            backgroundColor: Theme.of(context).cardColor,
            selectedIndex: _getSelectedIndex(),
            onDestinationSelected: (index) => _onItemTapped(index),
            labelType: isExtended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            leading: Column(
              children: [
                SizedBox(height: 20.h),
                Icon(Icons.admin_panel_settings_rounded, size: 32.sp, color: Theme.of(context).primaryColor),
                if (isExtended) ...[
                  SizedBox(height: 12.h),
                  Text("ADMIN", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 2)),
                ],
                SizedBox(height: 40.h),
              ],
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_rounded),
                selectedIcon: Icon(Icons.dashboard_rounded, color: Colors.blue),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_alt_rounded),
                selectedIcon: Icon(Icons.people_alt_rounded, color: Colors.blue),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.smart_toy_rounded),
                selectedIcon: Icon(Icons.smart_toy_rounded, color: Colors.blue),
                label: Text('AI Models'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.home_rounded),
                selectedIcon: Icon(Icons.home_rounded, color: Colors.blue),
                label: Text('App Home'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildHeader(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.w : 32, 
        vertical: isMobile ? 16.h : 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 24.sp : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          CircleAvatar(
            backgroundColor: Colors.grey.withOpacity(0.1),
            child: const Icon(Icons.person_rounded, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings_rounded, size: 48.sp, color: Theme.of(context).primaryColor),
                  SizedBox(height: 8.h),
                  Text("Admin Panel", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18.sp)),
                ],
              ),
            ),
          ),
          _buildDrawerItem(Icons.dashboard_rounded, "Dashboard", 0),
          _buildDrawerItem(Icons.people_alt_rounded, "User Management", 1),
          _buildDrawerItem(Icons.smart_toy_rounded, "AI Configuration", 2),
          const Divider(),
          _buildDrawerItem(Icons.home_rounded, "Back to Home", 3),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    bool isSelected = _getSelectedIndex() == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : null),
      title: Text(title, style: GoogleFonts.outfit(fontWeight: isSelected ? FontWeight.bold : null)),
      selected: isSelected,
      onTap: () => _onItemTapped(index),
    );
  }

  int _getSelectedIndex() {
    final currentRoute = Get.currentRoute;
    if (currentRoute == AppRoutes.adminDashboard) return 0;
    if (currentRoute == AppRoutes.userManagement) return 1;
    if (currentRoute == AppRoutes.aiProvidersAdmin) return 2;
    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        if (Get.currentRoute != AppRoutes.adminDashboard) {
          Get.offNamed(AppRoutes.adminDashboard);
        }
        break;
      case 1:
        if (Get.currentRoute != AppRoutes.userManagement) {
          Get.toNamed(AppRoutes.userManagement);
        }
        break;
      case 2:
        if (Get.currentRoute != AppRoutes.aiProvidersAdmin) {
          Get.toNamed(AppRoutes.aiProvidersAdmin);
        }
        break;
      case 3:
        // Transition back to main app flow cleanly
        Get.offAllNamed(AppRoutes.mainShell);
        break;
    }
  }
}
