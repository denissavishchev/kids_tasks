import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_tasks/screens/kid_screens/add_wish_screen.dart';
import '../constants.dart';
import '../screens/history_screen.dart';
import '../screens/kid_screens/main_kid_screen.dart';
import '../screens/parent_screens/main_parent_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/button_widget.dart';

class ParentProvider with ChangeNotifier {

  TextEditingController addTaskNameController = TextEditingController();
  TextEditingController addTaskDescriptionController = TextEditingController();
  TextEditingController addTaskPriceController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  bool isEdit = false;
  bool isLoading = false;
  String imageUrl = '';
  String fileName = '';
  late Reference imageToUpload;
  late XFile? file;
  double stars = 0.0;

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
        return file == null
            ? const Icon(Icons.camera_alt)
            : Image.file(File(file!.path), fit: BoxFit.cover,);
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

  Future<void>addTaskToHistory(context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      int index, String parentName, String parentEmail, String kidName, String kidEmail,
      String taskName, String description, String price, String stars, String url)async {
    Size size = MediaQuery.sizeOf(context);
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
              height: size.height * 0.3,
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
                    children: [
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.clear), color: kBlue,),
                    ],
                  ),
                  Text('Перенести эту задачу в историю?', style: kTextStyle,),
                  ButtonWidget(
                      onTap: () {
                        saveTaskToHistory(parentName, parentEmail, kidName, kidEmail,
                            taskName, description, price, stars).then((v) =>
                            FirebaseFirestore.instance.collection('tasks').doc(
                                snapshot.data?.docs[index].id).delete());
                        if(url != 'false'){
                          FirebaseStorage.instance.refFromURL(url).delete();
                        }
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) =>
                            box.get('role') == 'parent'
                                ? const MainParentScreen()
                                : const MainKidScreen()));
                      },
                      text: 'Добавить')
                ],
              )
          );
        });
  }

  Future<void>saveTaskToHistory(String parentName, String parentEmail, String kidName, String kidEmail,
      String taskName, String description, String price, String stars)async {
    await FirebaseFirestore.instance.collection('history').add({
      'parentName': parentName,
      'parentEmail': parentEmail,
      'kidName': kidName,
      'kidEmail': kidEmail,
      'taskName': taskName,
      'description': description,
      'price': price,
      'stars' : stars,
      'time' : DateTime.now().toString()
    });
  }

  Future searchForEditing(String docId) async{
    isEdit = true;
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.
    instance.collection('tasks').doc(docId).get();
    if(doc.exists){
      Map<String, dynamic>? data = doc.data();
      addTaskNameController.text = data?['taskName'];
      addTaskDescriptionController.text = data?['description'];
      addTaskPriceController.text = data?['price'];
      taskDeadline = data?['deadline'] == 'false' ? DateTime.now() : DateTime.parse(data?['deadline']);
      isDeadline = data?['deadline'] == 'false' ? false : true;
      fileName = data?['imageUrl'];
    }
  }

  Future changePriceStatus(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, int index, String? role)async{
    FirebaseFirestore.instance.collection('tasks').doc(snapshot.data?.docs[index].id).update({
      'price': priceController.text.trim(),
      'priceStatus': role == 'parent' ? 'set' : 'changed'
    });
  }

  Future changeToInProgress(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, int index, context)async{
    FirebaseFirestore.instance.collection('tasks').doc(snapshot.data?.docs[index].id).update({
      'status': 'inProgress'
    });
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) =>
        box.get('role') == 'parent'
            ? const MainParentScreen()
            : const MainKidScreen()));
  }

  Future changeToDone(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, int index, context)async{
    FirebaseFirestore.instance.collection('tasks').doc(snapshot.data?.docs[index].id).update({
      'status': 'done'
    });
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) =>
        box.get('role') == 'parent'
            ? const MainParentScreen()
            : const MainKidScreen()));
  }

  Future changeToChecked(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, int index, context)async{
    FirebaseFirestore.instance.collection('tasks').doc(snapshot.data?.docs[index].id).update({
      'status': 'checked',
      'stars': stars.toString()
    });
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) =>
        box.get('role') == 'parent'
            ? const MainParentScreen()
            : const MainKidScreen()));
  }

  Future changeToPaid(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, int index, context)async{
    FirebaseFirestore.instance.collection('tasks').doc(snapshot.data?.docs[index].id).update({
      'status': 'paid',
    });
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) =>
        box.get('role') == 'parent'
            ? const MainParentScreen()
            : const MainKidScreen()));
  }

  void updateRating(double rating){
    stars = rating;
    notifyListeners();
  }

  Future<void>historyDescription(context, String price, String description,
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, int index,) async{
    Size size = MediaQuery.sizeOf(context);
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
              height: size.height * 0.55,
              width: size.width,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: kGrey,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.clear), color: kBlue,),
                    ],
                  ),
                  Container(
                    height: 60,
                    width: size.width,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kBlue.withOpacity(0.1),
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(4)
                      ),
                    ),
                    child: Text(snapshot.data?.docs[index].get('taskName'),
                      style: kBigTextStyle,),
                  ),
                  Container(
                    height: 200,
                    width: size.width,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: kBlue.withOpacity(0.1),
                        borderRadius: const BorderRadius.all(Radius.circular(4))
                    ),
                    child: Text(snapshot.data?.docs[index].get('description'), style: kTextStyle),
                  ),
                  ButtonWidget(
                      onTap: () => deleteFromHistory(context, snapshot, index),
                      text: 'Удалить из истории')
                ],
              )
          );
        });
  }

  Future<void>deleteFromHistory(context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, int index)async {
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
                  Center(child: Text('Вы уверены?', style: kTextStyle,)),
                  TextButton(
                      onPressed: () {
                        if(snapshot.data?.docs[index].get('imageUrl') != 'false'){
                          FirebaseStorage.instance.refFromURL(snapshot.data?.docs[index].get('imageUrl')).delete();
                        }
                        FirebaseFirestore.instance.collection('history').doc(
                            snapshot.data?.docs[index].id).delete();
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) =>
                            const HistoryScreen()));
                      },
                      child: Text('Да', style: kTextStyle,)
                  )
                ],
              )
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