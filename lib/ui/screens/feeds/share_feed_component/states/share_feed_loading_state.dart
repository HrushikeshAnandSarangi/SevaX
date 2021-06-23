import 'package:flutter/material.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class LoadingComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingIndicator(),
    );
  }
}
