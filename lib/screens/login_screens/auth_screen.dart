import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/login_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LoginProvider>(
          builder: (context, data, _){
            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot){
                if(snapshot.hasData){
                  return const MainScreen();
                }else{
                  return const LoginScreen();
                }
              },
            );
          }
      )
    );
  }
}