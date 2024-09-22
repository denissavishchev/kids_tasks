import 'package:fluttertoast/fluttertoast.dart';
import '../constants.dart';

void toast(String text, bool happy){
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: happy ? kBlue : kRed,
      textColor: happy ? kDarkGrey : kGrey,
      fontSize: 20
  );
}

