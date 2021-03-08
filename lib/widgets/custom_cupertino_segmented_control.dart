import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCupertinoSegmentedControl extends StatelessWidget {
  const CustomCupertinoSegmentedControl({
    Key key,
    @required this.titles,
    @required this.selectedIndex,
    @required this.onChanged,
    this.style,
  })  : assert(titles != null && titles.length > 1),
        assert(selectedIndex != null),
        super(key: key);

  final List<String> titles;
  final ValueChanged<int> onChanged;
  final int selectedIndex;
  final TextStyle style;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: CupertinoSegmentedControl<int>(
        selectedColor: Theme.of(context).primaryColor,
        children: Map<int, Widget>.fromIterable(
          titles,
          value: (item) => Text(
            item.toString(),
            style:
                style ?? TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          key: (item) => titles.indexOf(item),
        ),
        borderColor: Theme.of(context).primaryColor,
        groupValue: selectedIndex,
        onValueChanged: (int val) {
          if (val != selectedIndex) {
            onChanged?.call(val);
          }
        },
      ),
    );
  }
}
