import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_colors.dart';
import 'app/services/teacher_service.dart';
import 'app/services/auth_service.dart';
import 'app/services/school_data_service.dart';
import 'app/services/audit_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();

  // Core Services
  Get.put(AuditService());
  Get.put(SchoolDataService());
  Get.put(TeacherService());
  Get.put(AuthService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EduConnect Super Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlack,
        scaffoldBackgroundColor: AppColors.primaryBlack,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentLime,
          surface: AppColors.primaryBlack,
        ),
        fontFamily: 'Roboto', // Default falllback
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
