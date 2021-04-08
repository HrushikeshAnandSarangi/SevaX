import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/dashed_border.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/image_picker/image_picker_dialog_mobile.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:sevaexchange/widgets/full_screen_widget.dart';

import '../flavor_config.dart';
typedef StringpListCallback = void Function(
    List<String> imageUrls);
class AddImagesForRequest extends StatefulWidget {
  final StringpListCallback onLinksCreated;
  final List<String> selectedList;


  AddImagesForRequest({this.onLinksCreated, this.selectedList});

  @override
  _AddImagesForRequestState createState() => _AddImagesForRequestState();
}

class _AddImagesForRequestState extends State<AddImagesForRequest> {
  List<String> imageUrls=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.selectedList != null) {
      imageUrls = widget.selectedList;
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add images',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5,),
          Text(
            'Images helps to convey the theme of your request',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 15,),

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
                  color: FlavorConfig.values.theme.primaryColor,
                ),
                Text(
                  'Choose Images',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                Text(
                  'Files Supported: PNG,JPEG',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Center(
                  child: RaisedButton(
                    onPressed: (){
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
                            );
                          });
                    },
                    shape: StadiumBorder(),
                    child: Text(
                      S.of(context).choose,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Text(
                  'Maximum size: 5MB',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                )
              ],
            ),
          ),
           SizedBox(height: 8,),
           Container(
             height: 100,
             child: ListView(
               shrinkWrap: true,
               scrollDirection: Axis.horizontal,
               children:
                 List.generate(
                   imageUrls.length,
                       (index) => Stack(
                     children: <Widget>[
                       InkWell(
                         onTap: (){
                           showDialog(
                               context: context,
                               builder: (BuildContext dialogContext) {
                                 return FullScreenImage(
                                  imageUrl: imageUrls[index],
                                 );
                               });
                         },
                         child: Container(
                           width:100,
                           height:100,
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
                             setState(() {
                             });
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
