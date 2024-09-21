import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:kids_tasks/providers/login_provider.dart';
import 'package:kids_tasks/providers/parent_provider.dart';
import 'package:kids_tasks/screens/login_screens/auth_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('data');
  await Firebase.initializeApp(
      // options: const FirebaseOptions(
      //     apiKey: '',
      //     appId: '1:442746995740:android:08e5d1b9a5191e5fdf0bd9',
      //     messagingSenderId: 'sendid',
      //     projectId: 'kidstasks-dddee',
      //     storageBucket: 'kidstasks-dddee.appspot.com',
      //     authDomain: 'kidstasks-dddee.firebaseapp.com'
      // )
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ParentProvider>(create: (_) => ParentProvider()),
      ChangeNotifierProvider<LoginProvider>(create: (_) => LoginProvider()),
    ],
    builder: (context, child){
      return ScreenUtilInit(
          designSize: const Size(720, 1560),
      builder: (_, child) =>const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthScreen(),
        ),
      );
    },
  ));
}



