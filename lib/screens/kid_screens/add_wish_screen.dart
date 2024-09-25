import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/kid_provider.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/kids_widgets/wishes_tiles_list_widget.dart';
import 'main_kid_screen.dart';

class AddWishScreen extends StatelessWidget {
  const AddWishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/bg_wish.png'),
                fit: BoxFit.cover
            )
        ),
        child: SafeArea(
            child: Consumer<KidProvider>(
              builder: (context, data, _){
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 18,),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () => Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) =>
                                        const MainKidScreen())),
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new,
                                      color: kWhite,
                                      size: 32,
                                    )),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 18,),
                            Form(
                              key: KidProvider.wishKey,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: kOrange.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, -10)
                                        )
                                      ]
                                    ),
                                    child: TextFormField(
                                      controller: data.addWishNameController,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      cursorColor: kWhite,
                                      style: const TextStyle(color: kWhite),
                                      decoration: textFieldKidDecoration.copyWith(
                                          label: const Text('Желание', style: TextStyle(color: kWhite))),
                                      maxLength: 64,
                                      validator: (value){
                                        if(value == null || value.isEmpty) {
                                          return 'Это поле не может быть пустым';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            const SizedBox(height: 12,),
                            GestureDetector(
                              onTap: () => data.pickAnImage(),
                              child: Container(
                                width: 100,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: kOrange.withOpacity(0.8),
                                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                                ),
                                child: data.fileName == ''
                                    ? const Icon(Icons.camera_alt)
                                    : data.file == null
                                    ? const Icon(Icons.camera_alt)
                                    : Image.file(File(data.file!.path), fit: BoxFit.cover,),
                              ),
                            ),
                            const SizedBox(height: 30,),
                            ButtonWidget(
                              onTap: () => data.addWishToBase(context),
                              text: 'Добавить',
                            ),
                            SizedBox(
                              height: size.height * 0.05,),
                            const WishesTilesListWidget()
                          ],
                        ),
                      ),
                    ),
                    data.isLoading
                        ? Container(
                          width: size.width,
                          height: size.height,
                          color: kGrey.withOpacity(0.5),
                          child: const Center(child: CircularProgressIndicator(color: kBlue,),),
                    ) : const SizedBox.shrink()
                  ],
                );
              },
            )
        ),
      ),
    );
  }
}
