import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/notification_controller.dart';
import '../services/user_service.dart';
import '../services/token_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import '../views/attendances/attendance_selection_screen.dart';
import '../views/classes/class_list_screen.dart';
import '../views/profile/profile_screen.dart'; // Tab thứ 4

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  final UserService _userService = UserService();
  final TokenService _tokenService = TokenService();
  Map<String, dynamic>? _userProfile;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final res = await _userService.getMyProfile();
    if (res['success'] == true) {
      final userData = res['data'];
      setState(() {
        _userProfile = userData;
        if (userData != null && userData['role'] != null) {
          _userRole = userData['role'].toString().toLowerCase();
        }
      });
      if (userData != null && userData['role'] != null) {
        await _tokenService.saveUserRole(_userRole!);
      }
    }
  }

  void _handleLogout() async {
    await _tokenService.clearAll();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cửa sổ hiển thị phụ thuộc vào vai trò
    final bool isUserOnly = _userRole == 'user';
    
    final List<Widget> screens = [
      HomeScreen(userProfile: _userProfile, userRole: _userRole),
      if (!isUserOnly) AttendanceSelectionScreen(userRole: _userRole, userProfile: _userProfile),
      ClassListScreen(userRole: _userRole, userProfile: _userProfile),
      ProfileScreen(userProfile: _userProfile, onLogout: _handleLogout),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      // AppBar chính (chỉ hiển thị cho tab 1, 2, 3)
      appBar: (_selectedIndex == 1 || _selectedIndex == 2) && !isUserOnly ? AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Theme.of(context).cardColor,
        toolbarHeight: 70,
        title: Text(
          _selectedIndex == 1 ? "Điểm danh" : "Lớp học",
          style: AppTextStyles.titleLarge.copyWith(color: Theme.of(context).textTheme.titleLarge?.color, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ) : null,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          Consumer<NotificationController>(
            builder: (context, controller, _) {
              if (controller.latestNotification == null) return const SizedBox.shrink();
              
              final note = controller.latestNotification!;
              return Positioned(
                top: 10,
                left: 16,
                right: 16,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween(begin: -100.0, end: 0.0),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(note.icon, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                note.title,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                note.message,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close, color: Colors.white, size: 18),
                          onPressed: () => controller.broadcast("", ""),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryDeep,
          unselectedItemColor: AppColors.textLight,
          selectedLabelStyle: AppTextStyles.labelLarge.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTextStyles.labelLarge.copyWith(fontSize: 10),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.grid_view_rounded)), 
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.grid_view_rounded)), 
              label: "Trang chủ"
            ),
            if (!isUserOnly)
              const BottomNavigationBarItem(
                icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.qr_code_scanner_rounded)), 
                activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.qr_code_scanner_rounded)), 
                label: "Điểm danh"
              ),
            const BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.class_outlined)), 
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.class_rounded)), 
              label: "Lớp học"
            ),
            const BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_rounded)), 
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_rounded)), 
              label: "Cá nhân"
            ),
          ],
        ),
      ),
    );
  }
}