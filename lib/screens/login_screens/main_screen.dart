import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kids_tasks/screens/kid_screens/main_kid_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/login_provider.dart';
import '../parent_screens/main_parent_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  @override
  void initState() {
    final data = Provider.of<LoginProvider>(context, listen: false);
    data.getRole(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<LoginProvider>(
          builder: (context, data, _){
            return StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot){
                if(data.role == 'parent'){
                  return const MainParentScreen();
                }else if(data.role == 'child'){
                  return const MainKidScreen();
                }else{
                  return SizedBox(
                    height: MediaQuery.sizeOf(context).height,
                      width: MediaQuery.sizeOf(context).width,
                      child: Image.asset('assets/images/bg.png', fit: BoxFit.cover,));
                }
              },
            );
          },
        )
    );
  }
}