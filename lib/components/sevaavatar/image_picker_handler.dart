import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'
    show StaggeredGrid, StaggeredGridTile;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/utils.dart';
import './image_picker_dialog.dart';
import './imagecategorieslist.dart';

import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

class ImagePickerHandler {
  late ImagePickerDialog imagePicker;
  final AnimationController _controller;
  final ImagePickerListener _listener;
  final bool isCover;

  ImagePickerHandler(this._listener, this._controller, this.isCover);

  void openCamera(BuildContext context) async {
    imagePicker.dismissDialog(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      cropImage(pickedFile.path);
    }
  }

  void openGallery(BuildContext context) async {
    imagePicker.dismissDialog(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      log('open gallery image ${pickedFile.path}');
      cropImage(pickedFile.path);
    }
  }

//  void openStockImages(context) async {
//    globals.isFromOnBoarding ? imagePicker.dismissDialog() : null;
//
//    FocusScope.of(context).requestFocus(FocusNode());
//    Navigator.of(context)
//        .push(
//      MaterialPageRoute(
//        builder: (context) => SearchStockImages(
//          // keepOnBackPress: false,
//          // showBackBtn: false,
//          // isFromHome: false,
//          onChanged: (image) {
//            _listener.userImage(image, 'stock_image');
//            Navigator.pop(context);
//          },
//        ),
//      ),
//    )
//        .then((value) {
//      globals.isFromOnBoarding ? imagePicker.dismissDialog() : null;
//    });
//  }

  addImageUrl(BuildContext context) async {
    imagePicker.dismissDialog(context);
    _listener.addWebImageUrl();
  }

  addStockImageUrl(BuildContext context, String image, bool isCover) async {
    logger.e('HERE 1');

    if (isCover) {
      isCover ? imagePicker.dismissDialog(context) : null;
      //crop functionality for stock image selection for cover photo
      File imageToCrop = await utils.urlToFile(image);
      cropImage(imageToCrop.path);

      globals.isFromOnBoarding ? null : imagePicker.dismissDialog(context);
      _listener.userImage(image, 'stock_image');
    } else {
      globals.isFromOnBoarding ? null : imagePicker.dismissDialog(context);
      _listener.userImage(image, 'stock_image');
    }
  }

  void init() {
    imagePicker = ImagePickerDialog(this, _controller, isCover);
    imagePicker.initState();
  }

  Future cropImage(String path) async {
    log('event cover cropImage path ${path}');

    File croppedFile;
    ImageCropper()
        .cropImage(
      sourcePath: path,
      aspectRatio: CropAspectRatio(
        ratioX: isCover ? 3 / 1 : 1.0,
        ratioY: 1.0,
      ),
      maxWidth: isCover ? 620 : 200,
      maxHeight: isCover ? 150 : 200,
    )
        .then((value) {
      if (value != null) {
        croppedFile = File(value.path);
        log('event cover cropedImage path ${croppedFile.path}');
        _listener.userImage(croppedFile, '');
      }
    });
  }

  void showDialog(BuildContext context, {bool isOnboarding = false}) {
    FocusScope.of(context).requestFocus(new FocusNode());
    imagePicker.getImage(context, isOnboarding: isOnboarding);
  }
}

abstract class ImagePickerListener {
  void userImage(dynamic _image, String type);

  addWebImageUrl();
}

class SearchStockImages extends StatefulWidget {
  // final bool keepOnBackPress;
  // final bool showBackBtn;
  final Color themeColor;
  final ValueChanged onChanged;
  SearchStockImages({
    // @required this.keepOnBackPress,
    // @required this.showBackBtn,
    // @required this.isFromHome,
    required this.onChanged,
    required this.themeColor,
  });

  @override
  State<StatefulWidget> createState() {
    return SearchStockImagesViewState();
  }
}

class SearchStockImagesViewState extends State<SearchStockImages>
    with TickerProviderStateMixin {
  int catSelected = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onCatSelected(dynamic index) {
    setState(() => this.catSelected = index);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        elevation: 0.5,
        automaticallyImplyLeading: true,
        title: Text(
          S.of(context).gallery,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Stack(children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        catSelected = -1;
                        setState(() {});
                      },
                      child: Text(
                        'Choose Category',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: HexColor('#F5A623')),
                      ),
                    ),
                    this.catSelected > -1
                        ? Icon(
                            Icons.arrow_forward_ios,
                            color: HexColor('#F5A623'),
                            size: 20,
                          )
                        : Container(),
                    Text(
                      this.catSelected > -1
                          ? '${categories[catSelected]['name'] ?? ''}'
                          : '',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ],
                ))
          ]),
          Expanded(
            child: StockImageListingView(
              this.onCatSelected,
              this.catSelected,
              this.widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class StockImageListingView extends StatelessWidget {
  const StockImageListingView(
      this.onCatSelected, this.catSelected, this.onChanged);

  final ValueChanged onChanged;
  final int catSelected;
  final ValueChanged onCatSelected;

  staggeredtilesView(childs, bool isimages) {
    List<Widget> categoriesList = [];
    List<StaggeredGridTile> staggeredtiles = [];
    for (var i = 0; i < childs.length; i++) {
      categoriesList.add(_Tile(
          childs[i]['image'],
          isimages ? childs[i]['index'] : i,
          childs[i]['name'],
          isimages
              ? (index) => {this.onChanged(childs[i]['image'])}
              : this.onCatSelected));
      staggeredtiles.add(
        StaggeredGridTile.fit(
          crossAxisCellCount: childs[i]['fit'],
          child: Container(),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(4),
      child: StaggeredGrid.count(
        crossAxisCount: 4,
        mainAxisSpacing: 1.0,
        crossAxisSpacing: 1.0,
        children: List.generate(
          categoriesList.length,
          (index) => StaggeredGridTile.fit(
            crossAxisCellCount: childs[index]['fit'],
            child: categoriesList[index],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (catSelected > -1) {
      List childs = categories[catSelected]['children'];
      return staggeredtilesView(childs, true);
    } else {
      return staggeredtilesView(categories, false);
    }
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.source, this.index, this.title, this.onChanged);

  final String source;
  final int index;
  final String title;
  final ValueChanged onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        this.onChanged(index);
      },
      child: Column(
        children: <Widget>[
          Image.network(
            source,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 2),
          title != null
              ? Text(
                  title,
                  style: const TextStyle(color: Colors.grey),
                )
              : Container(),
        ],
      ),
    );
  }
}
