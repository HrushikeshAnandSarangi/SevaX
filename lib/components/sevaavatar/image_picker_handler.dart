import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevaexchange/l10n/l10n.dart';

import './image_picker_dialog.dart';
import './imagecategorieslist.dart';

class ImagePickerHandler {
  ImagePickerDialog imagePicker;
  AnimationController _controller;
  ImagePickerListener _listener;

  ImagePickerHandler(this._listener, this._controller);

  void openCamera() async {
    imagePicker.dismissDialog();
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    cropImage(image.path);
  }

  void openGallery() async {
    imagePicker.dismissDialog();
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    cropImage(image.path);
  }

  void openStockImages(context) async {
    imagePicker.dismissDialog();
    FocusScope.of(context).requestFocus(FocusNode());
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchStockImages(
          // keepOnBackPress: false,
          // showBackBtn: false,
          // isFromHome: false,
          onChanged: (image) {
            _listener.userImage(image, 'stock_image');
            Navigator.pop(context);
          },
        ),
      ),
    );
    // _parentStockSelectionBottomsheet(context, (image) {
    //   log("inside stock images onchanged callback");
    //   _listener.userImage(image, 'stock_image');
    //   Navigator.pop(context);
    // });
  }

  addImageUrl() async {
    _listener.addWebImageUrl();
  }

  void init() {
    imagePicker = ImagePickerDialog(this, _controller);
    imagePicker.initState();
  }

  Future cropImage(String path) async {
    File croppedFile;
    ImageCropper.cropImage(
      sourcePath: path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 200,
      maxHeight: 200,
    ).then((value) {
      if (value != null) {
        croppedFile = value;
        _listener.userImage(croppedFile, '');
      }
    });
  }

  void showDialog(BuildContext context) {
    imagePicker.getImage(context);
  }
}

abstract class ImagePickerListener {
  void userImage(dynamic _image, String type);
  addWebImageUrl();
}

// void _parentStockSelectionBottomsheet(BuildContext mcontext, onChanged) {
//   showModalBottomSheet(
//     context: mcontext,
//     isScrollControlled: true,
//     builder: (BuildContext bc) {
//       return SearchStockImages(
//           keepOnBackPress: false,
//           showBackBtn: false,
//           isFromHome: false,
//           onChanged: onChanged);
//     },
//   );
// }

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

  onCatSelected(dynamic index) {
    print(index);
    setState(() => this.catSelected = index);
  }

  build(context) {
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
                    ? S.of(context).choose_image
                    : "Choose a category",
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
    print('hey');
    print(childs.length);
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
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      children: categoriesList,
      staggeredTiles: staggeredtiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    print(catSelected);
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
          CachedNetworkImage(
            imageUrl: source,
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
