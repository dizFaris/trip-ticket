import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:image/image.dart' as img;

class TripPhotoPicker extends StatefulWidget {
  final List<int>? initialPhoto;
  final void Function(List<int>?) onPhotoSelected;
  final bool enabled;

  const TripPhotoPicker({
    super.key,
    this.initialPhoto,
    required this.onPhotoSelected,
    this.enabled = true,
  });

  @override
  State<TripPhotoPicker> createState() => _TripPhotoPickerState();
}

class _TripPhotoPickerState extends State<TripPhotoPicker> {
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhoto != null) {
      _imageData = Uint8List.fromList(widget.initialPhoto!);
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      try {
        final originalBytes = result.files.single.bytes!;

        debugPrint("Original size: ${originalBytes.length} bytes");

        final decoded = img.decodeImage(originalBytes);

        if (decoded == null) {
          debugPrint("Image decoding failed");
          return;
        }

        final resized = img.copyResize(
          decoded,
          width: 480,
          interpolation: img.Interpolation.cubic,
        );

        int quality = 75;
        List<int> compressedBytes = img.encodeJpg(resized, quality: quality);

        while (compressedBytes.length > 50000 && quality > 30) {
          quality -= 5;
          compressedBytes = img.encodeJpg(resized, quality: quality);
        }

        setState(() {
          _imageData = Uint8List.fromList(compressedBytes);
        });

        debugPrint("Compressed size: ${compressedBytes.length} bytes");

        widget.onPhotoSelected(compressedBytes);
      } catch (e) {
        debugPrint("Error processing image: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 400,
      child: Column(
        children: [
          Container(
            width: 280,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: widget.enabled ? Colors.black12 : Colors.blueGrey[300],
            ),
            child: _imageData != null
                ? Image.memory(
                    _imageData!,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    width: 250,
                    height: 300,
                  )
                : const Center(child: Icon(Icons.photo)),
          ),
          const SizedBox(height: 8),
          widget.enabled
              ? ElevatedButton.icon(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(100, 36),
                  ),
                  icon: _imageData == null
                      ? const Icon(Icons.add)
                      : const Icon(Icons.edit),
                  label: _imageData == null
                      ? Text("Add photo")
                      : Text("Edit photo"),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
