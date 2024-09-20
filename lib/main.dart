import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kids_tasks/providers/parent_provider.dart';
import 'package:kids_tasks/screens/main_screen.dart';
import 'package:kids_tasks/screens/parent_screens/main_parent_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
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
      // ChangeNotifierProvider<KidProvider>(create: (_) => KidProvider()),
    ],
    builder: (context, child){
      return ScreenUtilInit(
          designSize: const Size(720, 1560),
      builder: (_, child) =>const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainParentScreen(),
        ),
      );
    },
  ));
}



