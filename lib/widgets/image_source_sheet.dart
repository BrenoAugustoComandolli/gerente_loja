import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {
  const ImageSourceSheet({this.onImageSelected, Key? key}) : super(key: key);

  final Function(File)? onImageSelected;

  void imageSelected(File? image) async {
    if (image != null) {
      CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      );
      final File imageFile = File(croppedImage!.path);
      onImageSelected!(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              XFile? image =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              imageSelected(File(image!.path));
            },
            child: const Text(
              "Câmera",
            ),
          ),
          TextButton(
            onPressed: () async {
              XFile? image =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              imageSelected(File(image!.path));
            },
            child: const Text(
              "Galeria",
            ),
          ),
        ],
      ),
    );
  }
}
