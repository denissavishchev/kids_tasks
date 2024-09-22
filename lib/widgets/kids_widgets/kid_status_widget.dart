import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';

class KidStatusWidget extends StatelessWidget {
  const KidStatusWidget({
    super.key,
    required this.snapshot,
    required this.index,
    required this.name,
    this.border = true,
    required this.title,
  });

  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot;
  final int index;
  final String name;
  final bool border;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          border: border ? Border.all(
            width: 0.5,
            color: snapshot.data?.docs[index].get('status') == name
                ? kWhite : Colors.transparent,) : null
      ),
      child: Text(title,
        style: snapshot.data?.docs[index].get('status') == name &&
            snapshot.data?.docs[index].get('priceStatus') == 'changed'
            ? kOrangeTextStyle
            : snapshot.data?.docs[index].get('status') == name &&
            snapshot.data?.docs[index].get('priceStatus') == 'set'
            ? kTextStyleWhite
            : kSmallTextStyleWhite,),
    );
  }
}