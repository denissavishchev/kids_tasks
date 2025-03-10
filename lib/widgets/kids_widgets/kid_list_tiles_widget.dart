import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/parent_provider.dart';
import '../../screens/kid_screens/kids_description_screen.dart';
import 'kid_basic_container_widget.dart';

class KidListTilesWidget extends StatelessWidget {
  const KidListTilesWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Consumer<ParentProvider>(
        builder: (context, data, _){
          return SizedBox(
              height: size.height * 0.8,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index){
                          if(snapshot.data?.docs[index].get('kidEmail').toLowerCase()
                              == data.box.get('email').toLowerCase()){
                            return GestureDetector(
                              onTap: () {
                                data.priceController.text = snapshot.data?.docs[index].get('price');
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) =>
                                        KidsDescriptionScreen(index: index, snapshot: snapshot)));
                              },
                              child: KidBasicContainerWidget(
                                snapshot: snapshot,
                                index: index,
                                nameOf: 'parentName',
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        });
                  }else{
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )
          );
        });
  }
}