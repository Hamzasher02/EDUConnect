import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../routes/role_router.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    // Wait for a few milliseconds to show the logo
    await Future.delayed(const Duration(seconds: 2));

    final auth = Get.find<AuthService>();
    if (auth.isLoggedIn) {
      RoleRouter.routeToDashboard(auth.session.value!.role);
    } else {
      // If not logged in, we can either go to publicRanking or login.
      // Given the request, login might be better to "show it for the first time".
      Get.offAllNamed(AppRoutes.publicRanking);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 100, color: AppColors.accentLime),
            SizedBox(height: 24),
            Text(
              'Eddue Connect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: AppColors.accentLime),
          ],
        ),
      ),
    );
  }
}
