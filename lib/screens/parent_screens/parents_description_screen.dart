import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/parent_provider.dart';
import '../kid_screens/main_kid_screen.dart';
import 'add_task_screen.dart';
import 'main_parent_screen.dart';

class ParentsDescriptionScreen extends StatelessWidget {
  const ParentsDescriptionScreen({super.key,
    required this.index,
    required this.snapshot
  });

  final int index;
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: kGrey,
      resizeToAvoidBottomInset: true,
      body: Consumer<ParentProvider>(
          builder: (context, data, _){
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60,),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(snapshot.data?.docs[index].get(data.box.get('role') == 'parent'
                            ? 'kidName' : 'parentName'),
                          style: kBigTextStyle,),
                        IconButton(
                          onPressed: () => Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) =>
                              data.box.get('role') == 'parent'
                                 ? const MainParentScreen()
                                 : const MainKidScreen())),
                          icon: const Icon(Icons.close, size: 40,), color: kBlue,)
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 104,
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              Divider(color: kBlue.withOpacity(0.2), height: 0.1,),
                              Container(
                                width: size.width,
                                padding: const EdgeInsets.only(left: 12),
                                color: kBlue.withOpacity(0.1),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text('Цена: ',
                                          style: kTextStyle.copyWith(
                                              color: kBlue.withOpacity(0.6)),),
                                        Text(snapshot.data?.docs[index].get('price'),
                                          style: kTextStyle,),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 300,
                          padding: const EdgeInsets.all(12),
                          margin: EdgeInsets.fromLTRB(12, 12,
                              snapshot.data?.docs[index].get('imageUrl') == 'false' ? 12 : 3, 0),
                          decoration: BoxDecoration(
                              color: kBlue.withOpacity(0.1),
                              borderRadius: const BorderRadius.all(Radius.circular(4))
                          ),
                          child: Text(snapshot.data?.docs[index].get('description'), style: kTextStyle),
                        ),
                      ),
                      snapshot.data?.docs[index].get('imageUrl') == 'false'
                          ? const SizedBox.shrink()
                          : Expanded(
                        child: Container(
                          height: 300,
                          clipBehavior: Clip.hardEdge,
                          margin: const EdgeInsets.fromLTRB(3, 12, 12, 0),
                          decoration: BoxDecoration(
                            color: kBlue.withOpacity(0.3),
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Image.network(snapshot.data?.docs[index].get('imageUrl'), fit: BoxFit.cover),
                        ),)
                    ],
                  ),
                  snapshot.data?.docs[index].get('status') == 'price'
                  ? _buildPrice(snapshot, data, context, size)
                  : snapshot.data?.docs[index].get('status') == 'inProgress'
                  ? _buildInProgress(snapshot, data, context, size)
                  : snapshot.data?.docs[index].get('status') == 'done'
                  ? _buildDone(snapshot, data, context, size)
                  : snapshot.data?.docs[index].get('status') == 'checked'
                  ? _buildChecked(snapshot, data, context, size)
                  : _buildComplete(snapshot),
                  const SizedBox(height: 20,),
                  data.box.get('role') == 'parent' && snapshot.data?.docs[index].get('status') == 'paid'
                  ? IconButton(
                      onPressed: () => data.addTaskToHistory(context, snapshot, index,
                          snapshot.data?.docs[index].get('parentName'),
                          snapshot.data?.docs[index].get('parentEmail'),
                          snapshot.data?.docs[index].get('kidName'),
                          snapshot.data?.docs[index].get('kidEmail'),
                          snapshot.data?.docs[index].get('taskName'),
                          snapshot.data?.docs[index].get('description'),
                          snapshot.data?.docs[index].get('price'),
                          snapshot.data?.docs[index].get('stars'),
                          snapshot.data?.docs[index].get('imageUrl'),),
                      icon: const Icon(Icons.history, size: 32, color: kBlue,))
                  : data.box.get('role') == 'parent'
                      && snapshot.data?.docs[index].get('status') == 'price'
                      && snapshot.data?.docs[index].get('priceStatus') == 'set'
                  ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        Expanded(child: Text('Вы можете редактировать задачу, пока она находится в процессе обсуждения цены и не подтверждена ребенком', style: kTextStyle,)),
                        IconButton(
                            onPressed: () {
                              data.searchForEditing(snapshot.data!.docs[index].id.toString());
                              Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) =>
                              const AddTaskScreen()));
                            },

                            icon: const Icon(Icons.edit, size: 32, color: kBlue,))
                      ],
                    ),
                  )
                      : const SizedBox.shrink()
                ],
              ),
            );
          }),
    );
  }

  _buildComplete(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
    return Padding(
        padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const SizedBox(height: 8,),
          Center(
            child: RatingBar(
              initialRating: double.parse(snapshot.data?.docs[index].get('stars')),
              ignoreGestures: true,
              allowHalfRating: false,
              itemCount: 3,
              itemSize: 60,
              ratingWidget: RatingWidget(
                full: const Icon(Icons.star,
                    color: kGrey,
                    shadows: [
                      BoxShadow(
                          color: kBlue,
                          blurRadius: 9,
                          spreadRadius: 6,
                          offset: Offset(0.5, 0.5)
                      )
                    ]),
                empty: const Icon(Icons.star_border,
                    color: kGrey,
                    shadows: [
                      BoxShadow(
                          color: kBlue,
                          blurRadius: 9,
                          spreadRadius: 6,
                          offset: Offset(0.5, 0.5)
                      )
                    ]), half: const SizedBox.shrink(),
              ),
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              onRatingUpdate: (r){},
            ),
          ),
          const SizedBox(height: 8,),
          Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                  width: 2,
                  color: snapshot.data?.docs[index].get('status') == 'paid'
                      ? kGreen : kRed),
              borderRadius: const BorderRadius.all(Radius.circular(12))
            ),
            child: Center(child: Text(
              'Оплачено',
              style: snapshot.data?.docs[index].get('status') == 'paid'
                  ? kGreenTextStyle : kRedTextStyle,)),
          )
        ],
      ),
    );
  }

  _buildChecked(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, ParentProvider data, context, Size size) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: data.box.get('role') == 'child'
          ? Column(
        children: [
          Center(
            child: RatingBar(
              initialRating: double.parse(snapshot.data?.docs[index].get('stars')),
              ignoreGestures: true,
              allowHalfRating: false,
              itemCount: 3,
              itemSize: 60,
              ratingWidget: RatingWidget(
                full: const Icon(Icons.star,
                    color: kGrey,
                    shadows: [
                      BoxShadow(
                          color: kBlue,
                          blurRadius: 9,
                          spreadRadius: 6,
                          offset: Offset(0.5, 0.5)
                      )
                    ]),
                empty: const Icon(Icons.star_border,
                    color: kGrey,
                    shadows: [
                      BoxShadow(
                          color: kBlue,
                          blurRadius: 9,
                          spreadRadius: 6,
                          offset: Offset(0.5, 0.5)
                      )
                    ]), half: const SizedBox.shrink(),
              ),
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              onRatingUpdate: (r){},
            ),
          ),
          const SizedBox(height: 8,),
          Text('Если задание оплачено, завершите его', style: kTextStyle,),
          const SizedBox(height: 8,),
          ChangeButtonWidget(
            index: index,
            snapshot: snapshot,
            onTap: () => data.changeToPaid(snapshot, index, context),
            text: 'Оплачено',
          ),
        ],
      )
          : _buildComplete(snapshot),
    );
  }

  _buildDone(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, ParentProvider data, context, Size size) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: data.box.get('role') == 'parent'
          ? Column(
          children: [
            Text('Проверьте выполненную работу и поставьте оценку...', style: kTextStyle,),
            const SizedBox(height: 8,),
            Center(
              child: AbsorbPointer(
                absorbing: snapshot.data?.docs[index].get('parentEmail').toLowerCase()
                    != data.box.get('email').toLowerCase(),
                child: RatingBar(
                initialRating: 0,
                allowHalfRating: false,
                itemCount: 3,
                itemSize: 60,
                ratingWidget: RatingWidget(
                  full: const Icon(Icons.star,
                      color: kGrey,
                      shadows: [
                        BoxShadow(
                            color: kBlue,
                            blurRadius: 9,
                            spreadRadius: 6,
                            offset: Offset(0.5, 0.5)
                        )
                      ]),
                  empty: Icon(Icons.star_border,
                      color: snapshot.data?.docs[index].get('parentEmail').toLowerCase()
                          == data.box.get('email').toLowerCase()
                      ? kGrey
                      : kGrey.withOpacity(0.2),
                      shadows: [
                        BoxShadow(
                            color: snapshot.data?.docs[index].get('parentEmail').toLowerCase()
                      == data.box.get('email').toLowerCase()
                                ? kBlue
                                : kBlue.withOpacity(0.2),
                            blurRadius: 9,
                            spreadRadius: 6,
                            offset: const Offset(0.5, 0.5)
                        )
                      ]), half: const SizedBox.shrink(),
                ),
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                onRatingUpdate: (rating) => data.updateRating(rating),
                            ),
              ),
          ),
          const SizedBox(height: 8,),
          Text('...и не забывайте об оплате', style: kTextStyle,),
          const SizedBox(height: 8,),
          AbsorbPointer(
            absorbing: snapshot.data?.docs[index].get('parentEmail').toLowerCase()
                != data.box.get('email').toLowerCase(),
            child: Opacity(
              opacity: snapshot.data?.docs[index].get('parentEmail').toLowerCase()
                  != data.box.get('email').toLowerCase() ? 0.2 : 1,
              child: ChangeButtonWidget(
                index: index,
                snapshot: snapshot,
                onTap: () => data.stateQuestion(context, 'changeToChecked', snapshot, index),
                text: 'Оценить',
              ),
            ),
          )
        ],
      )
          : Text('Ждем, пока ${data.box.get('role') == 'parent'
          ? snapshot.data?.docs[index].get('kidName')
          : snapshot.data?.docs[index].get('parentName')
      } оценит работу и заплатит', style: kTextStyle,),
    );
  }

  _buildInProgress(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, ParentProvider data, context, Size size) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: data.box.get('role') == 'child'
          ? Column(
        children: [
          ChangeButtonWidget(
            index: index,
            snapshot: snapshot,
            onTap: () => data.changeToDone(snapshot, index, context),
            text: 'Я сделал',
          )
        ],
      )
          : Text('Ждем, пока ${data.box.get('role') == 'parent'
          ? snapshot.data?.docs[index].get('kidName')
          : snapshot.data?.docs[index].get('parentName')
      } закончит задание', style: kTextStyle,),
    );
  }

  _buildPrice(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, ParentProvider data, context, Size size) {
    return Padding(
            padding: const EdgeInsets.all(12.0),
             child:  (snapshot.data?.docs[index].get('priceStatus') == 'set' && data.box.get('role') == 'child') ||
                 (snapshot.data?.docs[index].get('priceStatus') == 'changed' && data.box.get('role') == 'parent')
            ? Column(
              children: [
                const SizedBox(height: 18,),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: data.priceController,
                        cursorColor: kDarkGrey,
                        style: const TextStyle(color: kWhite),
                        decoration: textFieldDecoration.copyWith(
                            label: const Text('Цена', style: TextStyle(color: kWhite),),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          data.changePriceStatus(snapshot, index, data.box.get('role'));
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) =>
                              data.box.get('role') == 'parent'
                              ? const MainParentScreen()
                              : const MainKidScreen()));
                        },
                        icon: const Icon(Icons.change_circle_outlined, color: kWhite, size: 36,)
                    )
                  ],
                ),
                const SizedBox(height: 12,),
                ChangeButtonWidget(
                  index: index,
                  snapshot: snapshot,
                  onTap: () => data.stateQuestion(context, 'changeToInProgress', snapshot, index),
                  text: 'Принять цену и изменить статус',),
              ],
            )
            : Text('Ждем, пока ${data.box.get('role') == 'parent'
                 ? snapshot.data?.docs[index].get('kidName')
                 : snapshot.data?.docs[index].get('parentName')
             } примет цену', style: kTextStyle,),
          );
  }
}

class ChangeButtonWidget extends StatelessWidget {
  const ChangeButtonWidget({
    super.key,
    required this.index,
    required this.snapshot,
    required this.onTap,
    required this.text,
  });

  final int index;
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot;
  final Function() onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Consumer<ParentProvider>(
        builder: (context, data, _){
          return GestureDetector(
            onTap: onTap,
            child: Container(
              width: size.width * 0.6,
              height: 50,
              margin: const EdgeInsets.fromLTRB(12, 0, 0, 4),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(width: 1, color: kBlue.withOpacity(0.8)),
                  gradient: LinearGradient(
                      colors: [
                        kBlue.withOpacity(0.4),
                        kBlue.withOpacity(0.6)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 2,
                        offset: const Offset(0, 1)
                    ),
                    BoxShadow(
                      color: kGrey.withOpacity(0.2),
                      blurRadius: 2,
                      spreadRadius: 2,
                    ),
                  ]
              ),
              child: Center(
                child: Text(text,
                  style: kTextStyleGrey,
                  textAlign: TextAlign.center,),
              ),
            ),
          );
        });
  }
}
