import 'package:flutter/material.dart';
import 'package:kids_tasks/providers/login_provider.dart';
import 'package:kids_tasks/widgets/parents_widgets/parent_list_tiles_widget.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/parent_provider.dart';
import '../history_screen.dart';
import 'add_task_screen.dart';


class MainParentScreen extends StatelessWidget {
  const MainParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kGrey,
      body: SafeArea(
          child: Consumer2<ParentProvider, LoginProvider>(
            builder: (context, data, loginData, _){
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          height: size.height * 0.1,
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () => Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) =>
                                      const HistoryScreen())),
                                  icon: const Icon(
                                    Icons.history,
                                    color: kBlue,
                                    size: 32,
                                  )),
                              TextButton(
                                  onLongPress: () => loginData.logOut(context),
                                  onPressed: () {},
                                  child: Text('LogOut',style: kTextStyle,)),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    data.isEdit = false;
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) =>
                                        const AddTaskScreen()));
                                  },
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: kBlue,
                                    size: 32,
                                  ))
                            ],
                          ),
                        ),
                        const ParentListTilesWidget()
                      ],
                    ),
                  ],
                ),
              );
            },
          )
      ),
    );
  }
}


