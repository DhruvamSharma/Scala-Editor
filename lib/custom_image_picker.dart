import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// TODO 3: create a class with stateful widget and name it custom_image_picker.dart
class CustomImagePicker extends StatefulWidget {
  const CustomImagePicker({required this.onImagePicked, Key? key})
      : super(key: key);
  // TODO 5: Create a function to receive the image as callback
  final Function onImagePicked;
  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final ImagePicker picker = ImagePicker();
        // Pick an image
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);
        // to avoid asynchronous gaps
        if (mounted && image != null) {
          widget.onImagePicked(image);
        }
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width,
        child: const Icon(
          Icons.add_a_photo_outlined,
          color: Colors.white,
        ),
      ),
    );
  }
}
