import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TagView extends StatelessWidget {
  const TagView({
    required this.tagTitle,
  });

  final String tagTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 3, top: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Container(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              top: 3,
              bottom: 3,
            ),
            child: Text(
              tagTitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
