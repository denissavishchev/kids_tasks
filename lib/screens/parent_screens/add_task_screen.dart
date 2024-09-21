import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/parent_provider.dart';
import '../../widgets/button_widget.dart';
import 'main_parent_screen.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kGrey,
      body: SafeArea(
        child: Consumer<ParentProvider>(
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
                                    const MainParentScreen())),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: kBlue,
                                  size: 32,
                                )),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 18,),
                        Form(
                          // key: data.taskKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 18,),
                              TextFormField(
                                controller: data.addTaskNameController,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                cursorColor: kDarkGrey,
                                decoration: textFieldDecoration.copyWith(
                                    label: Text('task',)),
                                maxLength: 64,
                                validator: (value){
                                  if(value == null || value.isEmpty) {
                                    return 'thisFieldCannotBeEmpty';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18,),
                              TextFormField(
                                controller: data.addTaskDescriptionController,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.multiline,
                                minLines: 1,
                                maxLines: 5,
                                cursorColor: kDarkGrey,
                                decoration: textFieldDecoration.copyWith(
                                    label: Text('description',)),
                                maxLength: 256,
                              ),
                              const SizedBox(height: 18,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: data.addTaskPriceController,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      keyboardType: TextInputType.multiline,
                                      cursorColor: kDarkGrey,
                                      decoration: textFieldDecoration.copyWith(
                                          label: Text('price',)),
                                      maxLength: 64,
                                    ),
                                  ),
                                  Visibility(
                                    // visible: data.selectedKidName != '',
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 12.0),
                                      child: GestureDetector(
                                        // onTap: () =>
                                        //   data.showWishList(context, data),
                                        child: Container(
                                          width: 55,
                                          height: 55,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(12)),
                                            color: kDarkGrey,
                                          ),
                                          child: const Icon(Icons.favorite, color: kBlue,),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18,),
                        GestureDetector(
                          onTap: () => data.isEdit ? null : data.pickAnImage(),
                          child: Container(
                            width: 100,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: kBlue.withOpacity(0.3),
                              borderRadius: const BorderRadius.all(Radius.circular(4)),
                            ),
                            child: data.image(),
                          ),
                        ),
                        const SizedBox(height: 30,),
                        ButtonWidget(
                          onTap: () => data.addTaskToBase(context),
                          // onTap: () => data.isEdit
                          //         ? data.editTaskInBase(context, data.editDocId)
                          //         : data.addTaskToBase(context),
                          text: data.isEdit ? 'edit' : 'add',
                        ),
                        SizedBox(
                          height: 10,
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('wishes')
                                  .snapshots(),
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  return ListView.builder(
                                      itemCount: snapshot.data?.docs.length,
                                      itemBuilder: (context, index){
                                //         for(int w = 0; w < snapshot.data!.docs.length;){
                                //           if(snapshot.data?.docs[index].get('parent${w}Name').toLowerCase() == data.email
                                //           && snapshot.data?.docs[index].get('kidName') == data.selectedKidName){
                                //             data.wishList.addAll({'${snapshot.data?.docs[index].get('wish')}' : '${snapshot.data?.docs[index].get('imageUrl')}'});
                                //             return const SizedBox.shrink();
                                //           }else{
                                //             return const SizedBox.shrink();
                                //           }
                                // }
                                        return null;
                                }
                                  );
                                }else{
                                  return const CircularProgressIndicator();
                                }
                              }
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.viewInsetsOf(context).bottom == 0
                              ? size.height * 0.05 : size.height * 0.4,),
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
    );
  }
}



