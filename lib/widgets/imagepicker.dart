import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.Imagepicker});
  final void Function(File pickedimage) Imagepicker;
  @override
  State<StatefulWidget> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedimageFile;
  void _pickimage() async {
    final pickedimage = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 150, imageQuality: 50);

    if (pickedimage == null) {
      return;
    }
    setState(() {
      _pickedimageFile = File(pickedimage.path);
    });
    widget.Imagepicker(_pickedimageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickedimageFile != null ? FileImage(_pickedimageFile!) : null,
        ),
        TextButton.icon(
          onPressed: () {
            _pickimage();
          },
          icon: const Icon(Icons.image),
          label: Text(
            'Add Image',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        )
      ],
    );
  }
}
