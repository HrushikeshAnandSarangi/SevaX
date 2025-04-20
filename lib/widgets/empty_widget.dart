import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class EmptyWidget extends StatelessWidget {
  final String title;
  final String sub_title;
  final double titleFontSize;

  const EmptyWidget(
      {Key? key,
      required this.title,
      required this.sub_title,
      required this.titleFontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.i(MediaQuery.of(context).size);
    return Container(
      padding: EdgeInsets.all(15),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Image.asset(
                'images/icons/empty_widget.png',
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize ?? 22,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                sub_title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
