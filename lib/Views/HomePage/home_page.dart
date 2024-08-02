import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  int _selectedToggleIndex = 0;
  String _userName = '';

  Future<void> _pickImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select image source'),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: Text('Gallery'),
            ),
          ],
        );
      },
    );

    if (source != null) {
      final XFile? pickedImage = await _picker.pickImage(source: source);
      setState(() {
        _image = pickedImage;
      });
    }
  }

  GlobalKey widgetKey = GlobalKey();

  Future<File?> getFileFromWidget() async {
    try {
      RenderRepaintBoundary boundary =
          widgetKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

      if (boundary.debugNeedsPaint) {
        // Wait a brief moment to ensure the widget is painted
        await Future.delayed(const Duration(milliseconds: 20));
      }

      // Convert boundary to image
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);

      // Convert image to byte data
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception("Failed to convert image to ByteData");
      }

      // Convert byte data to Uint8List
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // Get temporary directory
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      // Create the file path
      File file =
          File('$tempPath/QA${DateTime.now().millisecondsSinceEpoch}.png');

      // Write the byte data to the file
      await file.writeAsBytes(pngBytes);

      // Return the created file
      return file;
    } catch (e) {
      print('Error capturing widget as image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('ImageTager'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RepaintBoundary(
              key: widgetKey,
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  // alignment: AlignmentDirectional(0,0 ),
                  children: [
                    Container(
                      height: size.height * 0.5,
                      width: size.width,
                      margin: EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 2,
                            offset: Offset(3, 3),
                          )
                        ],
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        image: _image != null
                            ? DecorationImage(
                                image: FileImage(File(_image!.path)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _image == null
                          ? Center(
                              child: Text(
                                'Tap to select an image',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 20),
                              ),
                            )
                          : null,
                    ),
                    _userName.isNotEmpty || _image != null
                        ? Positioned(
                            top: _selectedToggleIndex == 0 ||
                                    _selectedToggleIndex == 1
                                ? 2
                                : null,
                            bottom: _selectedToggleIndex == 2 ||
                                    _selectedToggleIndex == 3
                                ? 2
                                : null,
                            left: _selectedToggleIndex == 0 ||
                                    _selectedToggleIndex == 2
                                ? 2
                                : null,
                            right: _selectedToggleIndex == 1 ||
                                    _selectedToggleIndex == 3
                                ? 2
                                : null,
                            child: Container(
                              margin: EdgeInsets.all(20),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize
                                    .min, // Ensure the Row only takes as much space as needed
                                children: [
                                  CircleAvatar(
                                    radius: 14, // Size of the circle
                                    backgroundImage: _image != null
                                        ? FileImage(File(_image!.path))
                                        : null,
                                    child: _image == null
                                        ? Icon(Icons.person, size: 14)
                                        : null,
                                  ),
                                  // SizedBox(width: ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      _userName.isNotEmpty
                                          ? _userName
                                          : 'No name entered',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            TextField(
              onChanged: (text) {
                setState(() {
                  _userName = text;
                });
              },
              decoration: InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Position',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            ToggleButtons(
              isSelected:
                  List.generate(4, (index) => _selectedToggleIndex == index),
              onPressed: (int index) {
                setState(() {
                  _selectedToggleIndex = index;
                });
              },
              children: <Widget>[
                Image.asset(
                  'lib/assets/top_left.png',
                  color: _selectedToggleIndex == 0 ? Colors.grey : Colors.blue,
                  height: size.height * 0.08,
                  width: size.width * 0.08,
                ),
                Image.asset('lib/assets/top_right.png',
                    color:
                        _selectedToggleIndex == 1 ? Colors.grey : Colors.blue,
                    height: size.height * 0.08,
                    width: size.width * 0.08),
                Image.asset('lib/assets/bottom_left.png',
                    color:
                        _selectedToggleIndex == 2 ? Colors.grey : Colors.blue,
                    height: size.height * 0.08,
                    width: size.width * 0.08),
                Image.asset('lib/assets/bottom_right.png',
                    color:
                        _selectedToggleIndex == 3 ? Colors.grey : Colors.blue,
                    height: size.height * 0.08,
                    width: size.width * 0.08),
              ],
              borderRadius: BorderRadius.circular(8),
              selectedBorderColor: Colors.blue,
              selectedColor: Colors.white,
              fillColor: Colors.blue,
              color: Colors.black,
              borderColor: Colors.grey,
            ),
            SizedBox(height: 20),
            Center(
              child: CupertinoButton.filled(
                disabledColor: Colors.blue,
                onPressed: () async {
                  File? imageFile = await getFileFromWidget();
                  if (imageFile != null) {
                    final result =
                        await ImageGallerySaver.saveFile(imageFile.path);
                    if (result['isSuccess']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved in Gallery')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save image')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error capturing widget')),
                    );
                  }
                },
                child: Text('Download'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
