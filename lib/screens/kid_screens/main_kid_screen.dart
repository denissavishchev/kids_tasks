import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/kid_provider.dart';
import '../../providers/login_provider.dart';
import '../../widgets/kids_widgets/kid_list_tiles_widget.dart';
import 'add_wish_screen.dart';

class MainKidScreen extends StatelessWidget {
  const MainKidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Consumer2<KidProvider, LoginProvider>(
        builder: (context, data, loginData, _){
          return Container(
            height: size.height,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/bg.png'),
                  fit: BoxFit.cover
                )
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      height: size.height * 0.1,
                      child: Row(
                        children: [
                          TextButton(
                            onLongPress: () => loginData.logOut(context),
                            onPressed: () {},
                            child: Text('LogOut',style: kTextStyle,)),
                          const Spacer(),
                          IconButton(
                              onPressed: () =>
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) =>
                                      const AddWishScreen())),
                              icon: const Icon(
                                Icons.favorite,
                                color: kOrange,
                                size: 42,
                              ))
                        ],
                      ),
                    ),
                    const KidListTilesWidget()
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
