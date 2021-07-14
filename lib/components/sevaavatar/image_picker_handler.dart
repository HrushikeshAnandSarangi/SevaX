import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import './image_picker_dialog.dart';
import './imagecategorieslist.dart';

import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

class ImagePickerHandler {
  ImagePickerDialog imagePicker;
  AnimationController _controller;
  ImagePickerListener _listener;
  bool isCover;

  ImagePickerHandler(this._listener, this._controller, this.isCover);

  void openCamera() async {
    imagePicker.dismissDialog();
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    cropImage(pickedFile.path);
  }

  void openGallery() async {
    imagePicker.dismissDialog();
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery).then((value) {
      log('open gallery image ${value.path}');
      cropImage(value.path);
    });
    
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

  addImageUrl() async {
    imagePicker.dismissDialog();
    _listener.addWebImageUrl();
  }

  addStockImageUrl(String image, bool isCover) async {
    logger.e('HERE 1');

    if (isCover) {
      isCover ? imagePicker.dismissDialog() : null;
      //crop functionality for stock image selection for cover photo
      File imageToCrop = await utils.urlToFile(image);
      cropImage(imageToCrop.path);

      globals.isFromOnBoarding ? null : imagePicker.dismissDialog();
      _listener.userImage(image, 'stock_image');
    } else {
      globals.isFromOnBoarding ? null : imagePicker.dismissDialog();
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
    ImageCropper.cropImage(
      sourcePath: path,
      aspectRatio: CropAspectRatio(
        ratioX: isCover ? 2.0 : 1.0,
        ratioY: 1.0,
      ),
      maxWidth: isCover ? 620 : 200,
      maxHeight: isCover ? 150 : 200,
    ).then((value) {
      if (value != null) {
        croppedFile = value;
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
  // final bool isFromHome;
  final ValueChanged onChanged;

  SearchStockImages({
    // @required this.keepOnBackPress,
    // @required this.showBackBtn,
    // @required this.isFromHome,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() {
    return SearchStockImagesViewState();
  }
}

class SearchStockImagesViewState extends State<SearchStockImages>
    with TickerProviderStateMixin {
  num catSelected = -1;
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
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                this.catSelected > -1
                    ? S.of(context).choose_image +
                            ' from ${categories[catSelected]['name'] ?? ''}' ??
                        ''
                    : "Choose Category",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            )
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
    List<StaggeredTile> staggeredtiles = [];
    for (var i = 0; i < childs.length; i++) {
      categoriesList.add(_Tile(
          childs[i]['image'],
          isimages ? childs[i]['index'] : i,
          childs[i]['name'],
          isimages
              ? (index) => {this.onChanged(childs[i]['image'])}
              : this.onCatSelected));
      staggeredtiles.add(
        StaggeredTile.fit(
          childs[i]['fit'],
        ),
      );
    }
    return StaggeredGridView.count(
      padding: EdgeInsets.all(4),
      primary: false,
      crossAxisCount: 4,
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      children: categoriesList,
      staggeredTiles: staggeredtiles,
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
