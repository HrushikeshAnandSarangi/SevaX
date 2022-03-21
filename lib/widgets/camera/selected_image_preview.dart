import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/image_caption_model.dart';
import 'package:sevaexchange/ui/screens/message/widgets/message_input.dart';

class SelectedImagePreview extends StatefulWidget {
  final File file;

  const SelectedImagePreview({Key key, this.file}) : super(key: key);

  @override
  _SelectedImagePreviewState createState() => _SelectedImagePreviewState();
}

class _SelectedImagePreviewState extends State<SelectedImagePreview> {
  File _file;
  TextEditingController textController = TextEditingController();
  final profanityDetector = ProfanityDetector();
  bool isProfane = false;
  String errorText = '';
  @override
  void initState() {
    super.initState();
    _file = widget.file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.crop_rotate),
            onPressed: () {
              ImageCropper().cropImage(sourcePath: _file.path).then((File file) {
                if (file != null) {
                  setState(() {
                    _file = file;
                  });
                }
              });
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.insert_emoticon),
          //   onPressed: () {},
          // ),
          // IconButton(
          //   icon: Icon(Icons.text_fields),
          //   onPressed: () {},
          // ),
          // IconButton(
          //   icon: Icon(Icons.edit),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            Center(
              child: Image.file(_file),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MessageInput(
                    handleChange: (String value) {
                      if (value.length < 2) {
                        setState(() {
                          isProfane = false;
                          errorText = '';
                        });
                      }
                    },
                    textController: textController,
                    handleSubmitted: (String value) {
                      send(_file, value);
                    },
                    hideCameraIcon: true,
                    hintText: S.of(context).add_caption,
                    onSend: () {
                      send(_file, textController.text);
                    },
                  ),
                  isProfane
                      ? Container(
                          margin: EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            errorText,
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        )
                      : Offstage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void send(File file, String caption) {
    if (caption != null && caption.isNotEmpty) {
      if (profanityDetector.isProfaneString(caption)) {
        setState(() {
          isProfane = true;
          errorText = S.of(context).profanity_text_alert;
        });
      } else {
        setState(() {
          isProfane = false;
          errorText = '';
        });
        ImageCaptionModel model = ImageCaptionModel(file, caption);
        Navigator.of(context).pop<ImageCaptionModel>(model);
      }
    } else {
      isProfane = false;
      errorText = '';
      ImageCaptionModel model = ImageCaptionModel(file, caption);
      Navigator.of(context).pop<ImageCaptionModel>(model);
    }
  }
}
