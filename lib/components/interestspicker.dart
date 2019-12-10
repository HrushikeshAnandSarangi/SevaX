import 'package:flutter/material.dart';

import '../globals.dart';

class InterestsList extends StatefulWidget {
  @override
  State createState() => InterestsListState();
}

class InterestsListState extends State<InterestsList> {
  final TextEditingController interestsCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(right: 25.0, left: 25.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter your Skills',
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(20.0),
                ),
                borderSide: new BorderSide(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
            ),
            controller: interestsCtrl,
            onSubmitted: (text) {
              interests.add(text);
              interestsCtrl.clear();
              setState(() {});
            },
          ),
        ),
        Expanded(
            child: ListView.builder(
                // reverse: true,

                scrollDirection: Axis.horizontal,
                itemCount: interests.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      alignment: Alignment(-1.0, -1.0),
                      padding: EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(
                          interests[index],
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.deepPurple,
                        deleteIconColor: Colors.white,
                        onDeleted: () {
                          setState(() {
                            interests.remove(interests[index]);
                            interests.join(', ');
                          });
                        },
                      ));
                }))
      ],
    ));
  }
}
