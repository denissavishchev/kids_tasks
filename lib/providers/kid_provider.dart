import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_tasks/screens/kid_screens/add_wish_screen.dart';
import '../constants.dart';

class KidProvider with ChangeNotifier {

  String imageUrl = '';
  String fileName = '';
  late Reference imageToUpload;
  late XFile? file;
  bool isLoading = false;

  static const wishKey = Key('wishes');

  TextEditingController addWishNameController = TextEditingController();

  Box box = Hive.box('data');

  Future pickAnImage()async{
    ImagePicker image = ImagePicker();
    file = await image.pickImage(source: ImageSource.camera);
    if(file == null) return;
    fileName = DateTime.now().millisecondsSinceEpoch.toString();
    imageToUpload = FirebaseStorage.instance.ref().child('wishes').child(fileName);
    notifyListeners();
  }

  Future addWishToBase(context)async{
    isLoading = true;
    notifyListeners();
    if(fileName != ''){
      try{
        await imageToUpload.putFile(File(file!.path));
        imageUrl = await imageToUpload.getDownloadURL();
      }catch(e){
        return;
      }
    }
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.
    instance.collection('users').doc(box.get('email').toLowerCase()).get();
    String name = doc.data()?['name'];
        await FirebaseFirestore.instance.collection('wishes').add({
          'wish': addWishNameController.text,
          'kidEmail': box.get('email'),
          'kidName' : name,
          'imageUrl' : fileName == '' ? 'false' : imageUrl,
          'time' : DateTime.now().toString()
        });
        addWishNameController.clear();
        imageUrl = '';
        fileName = '';
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) =>
            const AddWishScreen()));
    isLoading = false;
    notifyListeners();
  }

  Future showWishDescription(context, AsyncSnapshot<QuerySnapshot<Map<String,
      dynamic>>> snapshot, int index) {
    Size size = MediaQuery.sizeOf(context);
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: size.height,
              width: size.width,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: kGrey,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
             child: Image.network(snapshot.data?.docs[index].get('imageUrl'), fit: BoxFit.cover),
            ),
          );
        });
  }

}