import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/parent_provider.dart';
import '../stars_widget.dart';
import '../status_widget.dart';

class BasicContainerWidget extends StatelessWidget {
  const BasicContainerWidget({
    super.key,
    this.height = 120,
    required this.snapshot,
    required this.index,
    required this.nameOf,
  });

  final double height;
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot;
  final int index;
  final String nameOf;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Consumer<ParentProvider>(
        builder: (context, data, _){
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 3, 3, 12),
                    width: size.width,
                    height: height,
                    decoration: BoxDecoration(
                        color: kGrey,
                        border: Border.all(width: 1, color: kBlue.withOpacity(0.2)),
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              spreadRadius: 2,
                              offset: const Offset(0, 6)
                          ),
                          BoxShadow(
                            color: kGrey.withOpacity(0.2),
                            blurRadius: 2,
                            spreadRadius: 2,
                          ),
                        ]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(snapshot.data?.docs[index].get(nameOf),
                                style: kBigTextStyle,),
                              Text(snapshot.data?.docs[index].get('parentName'),
                                style: kBigTextStyle.copyWith(color: kBlue.withOpacity(0.5)),),
                            ],
                          ),
                        ),
                        Container(
                          height: 65,
                          width: double.infinity,
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kBlue.withOpacity(0.1),
                            borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(4)
                            ),
                          ),
                          child: Text(snapshot.data?.docs[index].get('taskName'),
                            style: kBigTextStyle,),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Text('Цена: ',
                                style: kTextStyle.copyWith(
                                    color: kBlue.withOpacity(0.6)),),
                              Expanded(
                                child: Text(snapshot.data?.docs[index].get('price'),
                                  style: kTextStyle,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  maxLines: 1,),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(3, 0, 12, 12),
                    width: size.width,
                    height: height,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                        color: kGrey,
                        border: Border.all(width: 1, color: kBlue.withOpacity(0.2)),
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              spreadRadius: 2,
                              offset: const Offset(0, 6)
                          ),
                          BoxShadow(
                            color: kGrey.withOpacity(0.2),
                            blurRadius: 2,
                            spreadRadius: 2,
                          ),
                        ]
                    ),
                    child: snapshot.data?.docs[index].get('status') == 'checked' ||
                        snapshot.data?.docs[index].get('status') == 'paid'
                        ? StarsWidget(
                            stars: double.parse(snapshot.data?.docs[index].get('stars')).toInt(),
                            snapshot: snapshot,
                            index: index,)
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(3, (i){
                            return StatusWidget(
                              snapshot: snapshot,
                              index: index,
                              name: data.status[i],
                              title: data.statusRu[i],
                            );
                          }),
                        ),
                      ),
                    )
                  ],
                ),
              );
            });
  }
}