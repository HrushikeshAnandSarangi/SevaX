import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

// DateTime now = DateTime.now();

Future<DateTime> openDateTimePicker({
  BuildContext context,
  DateTime dateTime,
  // GlobalKey key,
}) async {
  // final Size size = MediaQuery.of(context).size;
  // RenderBox renderBox = key.currentContext.findRenderObject();
  // Size parentSize = renderBox.size;
  // Offset parentPosition = renderBox.localToGlobal(Offset.zero);

  // final Size dialogSize = Size(280, 410);
  // double leftOffset = size.width - parentPosition.dx > dialogSize.width
  //     ? parentPosition.dx
  //     : MediaQuery.of(context).size.width - dialogSize.width;
  // log('${size.width} ${parentPosition.dx} ${leftOffset}');
  // bool _isDialogBottom = parentPosition.dy >
  //     (MediaQuery.of(context).size.height / 3) + parentSize.height;

  // List<Widget> children = [
  //   Positioned(
  //     top: _isDialogBottom
  //         ? parentPosition.dy - parentSize.height
  //         : parentPosition.dy + parentSize.height,
  //     left: parentPosition.dx + 12,
  //     child: ClipPath(
  //       clipper: _isDialogBottom ? ReverseArrowClipper() : ArrowClipper(),
  //       child: Container(
  //         height: 20,
  //         width: 10,
  //         color: Colors.white,
  //       ),
  //     ),
  //   ),
  //   Positioned(
  //     top: _isDialogBottom
  //         ? parentPosition.dy - dialogSize.height + 36
  //         : parentSize.height + parentPosition.dy + 18,
  //     left: leftOffset,
  //     child: Material(
  //       color: Colors.transparent,
  //       child: CombinedDateTimePicker(
  //         selectedDateTime:
  //             DateTime(now.year, now.month, now.day, 12), //dateTime
  //       ),
  //     ),
  //   ),
  // ];
  DateTime now = dateTime ?? DateTime.now();
  return showDialog<DateTime>(
      context: context,
      builder: (context) => Dialog(
            child: CombinedDateTimePicker(
              selectedDateTime: DateTime(
                now.year,
                now.month,
                now.day,
                dateTime != null ? now.hour : 12,
                dateTime != null ? now.minute : 0,
              ),
            ),
          )
      // builder: (context)=>Stack(
      //   fit: StackFit.expand,
      //   children:
      //       List<Widget>.from(_isDialogBottom ? children.reversed : children),
      // ),
      );
}
