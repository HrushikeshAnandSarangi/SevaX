import 'package:flutter/material.dart';

import '../globals.dart';

class SkillsList extends StatefulWidget {
  @override
  State createState() => SkillsListState();
}

class SkillsListState extends State<SkillsList> {
  final TextEditingController skillsCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(right: 25.0, left: 25.0),
          child: TextField(
            controller: skillsCtrl,
            onSubmitted: (text) {
              skills.add(text);
              skillsCtrl.clear();
              setState(() {});
            },
          ),
        ),
        Expanded(
            child: ListView.builder(
                // reverse: true,

                scrollDirection: Axis.horizontal,
                itemCount: skills.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      alignment: Alignment(-1.0, -1.0),
                      padding: EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(
                          skills[index],
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.deepPurple,
                        deleteIconColor: Colors.white,
                        onDeleted: () {
                          setState(() {
                            skills.remove(skills[index]);
                            skills.join(', ');
                          });
                        },
                      ));
                }))
      ],
    ));
  }
}
