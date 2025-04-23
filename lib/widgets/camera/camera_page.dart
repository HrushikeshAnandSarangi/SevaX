import 'dart:async';
import 'package:universal_io/io.dart' as io;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/image_caption_model.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/widgets/camera/selected_image_preview.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<CameraPage> {
  late CameraController controller;
  int _cameraIndex = 0;
  bool _cameraNotAvailable = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _initCamera(int index) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(widget.cameras[index], ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        logger.e(controller.value.errorDescription);
        _showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {
        _cameraIndex = index;
      });
    }
  }

  void _onSwitchCamera() {
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }
    final newIndex =
        _cameraIndex + 1 == widget.cameras.length ? 0 : _cameraIndex + 1;
    _initCamera(newIndex);
  }

  void _onTakePictureButtonPress() {
    _takePicture().then((filePath) {
      if (filePath != null) {
        navigateToImagePreview(io.File(filePath));
      }
    });
  }

  void navigateToImagePreview(io.File file) {
    Navigator.push<ImageCaptionModel>(context, MaterialPageRoute(
      builder: (context) {
        return SelectedImagePreview(file: file);
      },
    )).then((ImageCaptionModel? imageCaptionModel) {
      Navigator.of(context).pop(imageCaptionModel);
    });
  }

  Future<void> _onGalleryButtonPress() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile?.path != null) {
      navigateToImagePreview(io.File(pickedFile!.path));
    }
  }

  // String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> _takePicture() async {
    if (!controller.value.isInitialized || controller.value.isTakingPicture) {
      return '';
    }
    // final Directory extDir = await getApplicationDocumentsDirectory();
    // final String dirPath = '${extDir.path}/Pictures/sevax';
    // await Directory(dirPath).create(recursive: true);
    // final String filePath = '$dirPath/${_timestamp()}.jpg';

    try {
      var xFile = await controller.takePicture();
      return xFile.path;
    } on CameraException catch (e) {
      _showCameraException(e);
      return '';
    }
  }

  void _showCameraException(CameraException e) {
    _showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  Widget _buildControlBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        IconButton(
          color: Colors.white,
          icon: Icon(Icons.insert_photo),
          onPressed: _onGalleryButtonPress,
        ),
        GestureDetector(
          onTap: _onTakePictureButtonPress,
          child: Container(
            height: 80.0,
            width: 80.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 5.0,
              ),
            ),
          ),
        ),
        IconButton(
          color: Colors.white,
          icon: Icon(Icons.switch_camera),
          onPressed: _onSwitchCamera,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.cameras == null || widget.cameras.isEmpty) {
      setState(() {
        _cameraNotAvailable = true;
      });
    }
    _initCamera(_cameraIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraNotAvailable) {
      return Center(
        child: Text(S.of(context).camera_not_available),
      );
    }

    final stack = Stack(
      children: <Widget>[
        Container(
          color: Colors.black,
          child: Center(
            child: controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: 1 / controller.value.aspectRatio,
                    child: CameraPreview(controller),
                  )
                : Text(S.of(context).loading_camera),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            _buildControlBar(),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                S.of(context).tap_for_photo,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
            )
          ],
        )
      ],
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: stack,
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (controller != null) {
      controller.dispose();
    }
  }
}
