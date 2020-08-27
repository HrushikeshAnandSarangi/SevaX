import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';

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

  void openStockImages(context, onChanged) async {
    imagePicker.dismissDialog();
    FocusScope.of(context).requestFocus(FocusNode());
    _parentStockSelectionBottomsheet(
        context,
        (image) => {
              _listener.userImage(image, 'stock_image'),
              Navigator.pop(context)
            });
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

void _parentStockSelectionBottomsheet(BuildContext mcontext, onChanged) {
  showModalBottomSheet(
    context: mcontext,
    isScrollControlled: true,
    builder: (BuildContext bc) {
      return SearchStockImages(
          keepOnBackPress: false,
          showBackBtn: false,
          isFromHome: false,
          onChanged: onChanged);
    },
  );
}

class SearchStockImages extends StatefulWidget {
  final bool keepOnBackPress;
  final bool showBackBtn;
  final bool isFromHome;
  final ValueChanged onChanged;

  SearchStockImages({
    @required this.keepOnBackPress,
    @required this.showBackBtn,
    @required this.isFromHome,
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
    return new Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        automaticallyImplyLeading: true,
        title: Text(
          AppLocalizations.of(context)
              .translate('image_picker', 'stock_images'),
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Stack(children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: Text(this.catSelected > -1 ? AppLocalizations.of(context)
                    .translate('image_picker', 'choose_image'): "Choose a category",
                    style: TextStyle(
                      fontSize: 20,
                    )))
          ]),
          Expanded(
            child: StockImageListingView(this.onCatSelected, this.catSelected, this.widget.onChanged),
          ),
        ],
      ),
    );
  }
}



class StockImageListingView extends StatelessWidget {
  const StockImageListingView(this.onCatSelected, this.catSelected, this.onChanged);
  final ValueChanged onChanged;
  final int catSelected;
  final ValueChanged onCatSelected;

  staggeredtilesView(childs, bool isimages) {
    List<Widget> categoriesList = [];
    List<StaggeredTile> staggeredtiles = [];
    print('hey');
    print(childs.length);
    for (var i = 0; i < childs.length; i++) {
      categoriesList.add(new _Tile(childs[i]['image'],
          isimages ? childs[i]['index']: i, childs[i]['name'], isimages ? (index) => {
            this.onChanged(childs[i]['image'])
          } : this.onCatSelected));
      staggeredtiles.add(new StaggeredTile.fit(childs[i]['fit']));
    }
    return new StaggeredGridView.count(
        primary: false,
        crossAxisCount: 4,
        mainAxisSpacing: 0.0,
        crossAxisSpacing: 0.0,
        children: categoriesList,
        staggeredTiles: staggeredtiles
    );
  }
  @override
  Widget build(BuildContext context) {
    List childs = categories[0]['children'];
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
        child: new Column(
          children: <Widget>[
            new Image.network(source),
            title != null ? new Padding(
              padding: const EdgeInsets.all(4.0),
              child: new Column(
                children: <Widget>[
                  new Text(
                    title,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ) : Text("")
          ],
        ));
  }
}
