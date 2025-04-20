import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/ui/screens/reported_members/widgets/zoom_image.dart';

class Attachment extends StatelessWidget {
  final String? attachment;

  const Attachment({Key? key, this.attachment}) : super(key: key);

  static Route<dynamic> route({String? attachment}) {
    return MaterialPageRoute(
      builder: (context) => Attachment(
        attachment: attachment,
      ),
      fullscreenDialog: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).attachment,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Center(
        child: ZoomableImage(
          CachedNetworkImageProvider(attachment!),
          scale: 1.0,
        ),
      ),
    );
  }
}
