import 'package:flutter/material.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class LoadingViewIndicator extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget loadingIndicator;
  final bool showChildInBackground;

  const LoadingViewIndicator({
    Key? key,
    required this.isLoading,
    required this.loadingIndicator,
    required this.child,
    this.showChildInBackground = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Stack(
            fit: StackFit.expand,
            children: [
              child,
              Container(
                color: Colors.black.withOpacity(0.6),
              ),
              Center(
                child: LoadingIndicator(),
              ),
            ],
          )
        : child;
  }
}
