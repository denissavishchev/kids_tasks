import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../screens/parent_screens/main_parent_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ParentProvider with ChangeNotifier {

  TextEditingController addTaskNameController = TextEditingController();
  TextEditingController addTaskDescriptionController = TextEditingController();
  TextEditingController addTaskPriceController = TextEditingController();

  bool isEdit = false;
  bool isLoading = false;
  String imageUrl = '';
  String fileName = '';
  late Reference imageToUpload;
  late XFile? file;

  DateTime taskDeadline = DateTime.now();
  bool isDeadline = false;

  List<String> status = ['price', 'inProgress', 'done', 'checked', 'paid'];
  List<String> statusRu = ['Цена', 'В процессе', 'Выполнено', 'Проверено', 'Оплачено'];
  Map<String, String> wishList = {};

  Box box = Hive.box('data');

  Future addTaskToBase(context)async {
    isLoading = true;
    notifyListeners();
    if (fileName != '') {
      try {
        await imageToUpload.putFile(File(file!.path));
        imageUrl = await imageToUpload.getDownloadURL();
      } catch (e) {
        return;
      }
    }
    await FirebaseFirestore.instance.collection('tasks').add({
      'priceStatus': 'set',
      'parentName': box.get('name'),
      'parentEmail': box.get('email'),
      'kidName': 'Daniel',
      'kidEmail': 'daniel@kid.com',
      'taskName': addTaskNameController.text,
      'description': addTaskDescriptionController.text,
      'status': 'price',
      'price': addTaskPriceController.text,
      'deadline': 'false',
      'stars': '0',
      'imageUrl': fileName == '' ? 'false' : imageUrl,
      'time': DateTime.now().toString()
    });
    addTaskNameController.clear();
    addTaskDescriptionController.clear();
    addTaskPriceController.clear();
    taskDeadline = DateTime.now();
    isDeadline = false;
    imageUrl = '';
    fileName = '';
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) =>
        const MainParentScreen()));
    isLoading = false;
    notifyListeners();
  }

  Future pickAnImage()async{
    ImagePicker image = ImagePicker();
    file = await image.pickImage(source: ImageSource.camera);
    if(file == null) return;
    fileName = DateTime.now().millisecondsSinceEpoch.toString();
    imageToUpload = FirebaseStorage.instance.ref().child('images').child(fileName);
    notifyListeners();
  }

  Widget image(){
    if(isEdit){
      if(fileName == 'false'){
        return const SizedBox.shrink();
      }else if(fileName.contains('https://firebasestorage')){
        return Image.network(fileName);
      }
    }else{
      if(fileName == ''){
        return const Icon(Icons.camera_alt);
      }else{
        return Image.file(File(file!.path), fit: BoxFit.cover,);
      }
    }
    return const Center(child: CircularProgressIndicator());
  }

  Future showWishList(context, ParentProvider data) {
    Size size = MediaQuery.sizeOf(context);
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: size.height * 0.6,
            width: size.width,
            decoration: const BoxDecoration(
              color: kGrey,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: wishList.isNotEmpty
                ? ListView.builder(
                itemCount: wishList.length,
                itemBuilder: (context, index){
                  String wish = wishList.keys.elementAt(index);
                  String image = wishList.values.elementAt(index);
                  return GestureDetector(
                    onTap: () => addWishToField(context, wish),
                    child: Container(
                      width: size.width,
                      height: image == 'false'
                          ? 50 : 100,
                      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                          color: kDarkGrey,
                          borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(wish, style: kTextStyle,),
                          image == 'false'
                              ? const SizedBox.shrink()
                              : Image.network(image),
                        ],
                      ),
                    ),
                  );
                })
                : Center(child: Text('У ребенка нет желаний', style: kBigTextStyle,)),
          );
        });
  }

  void addWishToField(context, String wish){
    addTaskPriceController.text = wish;
    notifyListeners();
    Navigator.of(context).pop();
  }

}