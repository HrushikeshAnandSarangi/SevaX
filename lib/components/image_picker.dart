// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart' as ip;

// class ImagePicker extends StatefulWidget {
//   @override
//   _ImagePickerState createState() => _ImagePickerState();
// }

// class _ImagePickerState extends State<ImagePicker> {
//   File selectedImage;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _pickImage(),
//       child: selectedImage == null
//           ? Container(
//               decoration: ShapeDecoration(
//                 shape: CircleBorder(),
//                 color: Colors.grey[200],
//               ),
//             )
//           : Container(
//               decoration: ShapeDecoration(
//                 shape: CircleBorder(),
//                 image: DecorationImage(
//                   image: FileImage(selectedImage),
//                 ),
//               ),
//             ),
//     );
//   }

//   void _pickImage() async {
//     showBottomSheet(
//       backgroundColor: Colors.black.withAlpha(10),
//       context: context,
//       builder: (context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Expanded(
//               child: GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   color: Colors.black.withAlpha(80),
//                 ),
//               ),
//             ),
//             Container(
//               color: Colors.white,
//               child: ListTile(
//                 title: Text('Camera'),
//                 leading: Icon(Icons.camera_alt),
//                 onTap: () => _openCamera(),
//               ),
//             ),
//             Container(
//               color: Colors.white,
//               child: ListTile(
//                 title: Text('Gallery'),
//                 leading: Icon(Icons.image),
//                 onTap: () => _openGallery(),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future _openCamera() async {
//     Navigator.pop(context);
//     File selectedImage = await ip.ImagePicker.pickImage(
//       source: ip.ImageSource.camera,
//       maxHeight: 300,
//       maxWidth: 300,
//     );
//     processImage(selectedImage);
//   }

//   Future _openGallery() async {
//     Navigator.pop(context);
//     File selectedImage = await ip.ImagePicker.pickImage(
//       source: ip.ImageSource.gallery,
//       maxHeight: 300,
//       maxWidth: 300,
//     );
//     processImage(selectedImage);
//   }

//   void processImage(File selectedImage) {
//     if (selectedImage == null) return;
//     setState(() => this.selectedImage = selectedImage);
//   }
// }
