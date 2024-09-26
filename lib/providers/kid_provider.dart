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

  Future<void>deleteWish(context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, int index)async {
    Size size = MediaQuery.sizeOf(context);
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
              height: size.height * 0.15,
              width: size.width,
              margin: const EdgeInsets.only(bottom: 300),
              decoration: const BoxDecoration(
                color: kGrey,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.clear), color: kBlue,),
                    ],
                  ),
                  Center(child: Text('Удалить это желание?', style: kTextStyle,)),
                  TextButton(
                      onPressed: () {
                        if(snapshot.data?.docs[index].get('imageUrl') != 'false') {
                          FirebaseStorage.instance.refFromURL(
                              snapshot.data?.docs[index].get('imageUrl')).delete();
                        }
                        FirebaseFirestore.instance.collection('wishes').doc(
                            snapshot.data?.docs[index].id).delete();
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) =>
                            const AddWishScreen()));
                      },
                      child: Text('Да', style: kTextStyle,)
                  )
                ],
              )
          );
        });
  }

}