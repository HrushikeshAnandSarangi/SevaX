import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:sevaexchange/components/dashed_border.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/image_picker/image_picker_dialog_mobile.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/full_screen_widget.dart';

import '../flavor_config.dart';

typedef StringpListCallback = void Function(List<String> imageUrls);

class AddImagesForRequest extends StatefulWidget {
  final StringpListCallback onLinksCreated;
  final List<String> selectedList;

  AddImagesForRequest(
      {required this.onLinksCreated, required this.selectedList});

  @override
  _AddImagesForRequestState createState() => _AddImagesForRequestState();
}

class _AddImagesForRequestState extends State<AddImagesForRequest> {
  List<String> imageUrls = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.selectedList != null) {
      imageUrls.addAll(widget.selectedList);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).add_image,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            S.of(context).images_help_convey_theme_of_request,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            height: 142,
            // width: 700,
            decoration: BoxDecoration(
              border: DashPathBorder.all(
                dashArray: CircularIntervalList<double>(<double>[5.0, 2.5]),
                // borderSide: Border.all(color: FlavorConfig.values.theme.primaryColor),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'lib/assets/images/cv.png',
                  height: 20,
                  width: 20,
                  color: Theme.of(context).primaryColor,
                ),
                Text(
                  S.of(context).choose_image,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                Text(
                  S.of(context).only_images_types_allowed,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Center(
                  child: CustomElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return ImagePickerDialogMobile(
                              imagePickerType: ImagePickerType.REQUEST,
                              onLinkCreated: (link) {
                                imageUrls.add(link);
                                widget.onLinksCreated(imageUrls);
                                setState(() {});
                              },
                              storeImageFile: (file) {},
                              storPdfFile: (file) {},
                              color: Theme.of(context).primaryColor,
                            );
                          });
                    },
                    color: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 2.0,
                    textColor: Colors.white,
                    shape: StadiumBorder(),
                    child: Text(
                      S.of(context).choose,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Text(
                  S.of(context).max_image_size,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                )
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Container(
            height: 100,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: List.generate(
                imageUrls.length,
                (index) => Stack(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return FullScreenImage(
                                imageUrl: imageUrls[index],
                              );
                            });
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(imageUrls[index])),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          imageUrls.removeAt(index);
                          widget.onLinksCreated(imageUrls);
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
