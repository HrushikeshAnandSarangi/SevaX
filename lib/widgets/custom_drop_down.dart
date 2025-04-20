import 'package:flutter/material.dart';

class CustomDropdownView extends StatefulWidget {
  final Widget defaultWidget;
  final List<Widget> listWidgetItem;
  final Function(bool isDropdownOpened) onTapDropdown;
  final BoxDecoration? decorationDropdown;
  final double? elevationShadow;
  final bool? isNeedCloseDropdown;
  final LayerLink? layerLink;

  const CustomDropdownView({
    Key? key,
    required this.defaultWidget,
    required this.onTapDropdown,
    this.decorationDropdown,
    this.elevationShadow,
    this.isNeedCloseDropdown,
    required this.listWidgetItem,
    this.layerLink,
  }) : super(key: key);

  @override
  State<CustomDropdownView> createState() => CustomDropdownViewState();
}

class CustomDropdownViewState extends State<CustomDropdownView> {
  late double height;
  late double width;
  late double xPosition;
  late double yPosition;
  late OverlayEntry floatingDropdown;
  bool isDropdownOpened = false;
  final LabeledGlobalKey privateKey = LabeledGlobalKey("");

  void findDropdownData() {
    RenderBox renderBox =
        privateKey.currentContext?.findRenderObject() as RenderBox;
    height = renderBox.size.height;
    width = renderBox.size.width;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    xPosition = offset.dx;
    yPosition = offset.dy;
  }

  OverlayEntry _createFloatingDropdown() {
    return OverlayEntry(builder: (context) {
      return Positioned(
        left: xPosition,
        top: yPosition + height,
        child: CompositedTransformFollower(
          link: widget.layerLink ?? LayerLink(),
          showWhenUnlinked: false,
          child: DropdownDialog(
            decorationDropdown: widget.decorationDropdown,
            elevationShadow: widget.elevationShadow,
            listWidgetItem: widget.listWidgetItem,
          ),
        ),
      );
    });
  }

  void closeDropdown() {
    floatingDropdown.remove();
    setState(() {
      isDropdownOpened = false;
      widget.onTapDropdown(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNeedCloseDropdown == true) {
      closeDropdown();
    }
    return GestureDetector(
      key: privateKey,
      onTap: () {
        if (isDropdownOpened) {
          closeDropdown();
        } else {
          setState(() {
            findDropdownData();
            floatingDropdown = _createFloatingDropdown();
            Overlay.of(context).insert(floatingDropdown);
            isDropdownOpened = true;
            widget.onTapDropdown(true);
          });
        }
      },
      child: widget.defaultWidget,
    );
  }
}

class DropdownDialog extends StatelessWidget {
  final BoxDecoration? decorationDropdown;
  final double? elevationShadow;
  final List<Widget> listWidgetItem;

  const DropdownDialog({
    Key? key,
    this.decorationDropdown,
    this.elevationShadow,
    required this.listWidgetItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 5,
        ),
        Material(
          elevation: elevationShadow ?? 20,
          child: Container(
            decoration: decorationDropdown ??
                BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
            child: Column(children: listWidgetItem),
          ),
        ),
      ],
    );
  }
}
