import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MemeGeneratorScreen extends StatefulWidget {
  const MemeGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<MemeGeneratorScreen> createState() => _MemeGeneratorScreenState();
}

class _MemeGeneratorScreenState extends State<MemeGeneratorScreen> {

  final ImagePicker imagePicker = ImagePicker();
  XFile? imgXFile;
  final _valueNewFile = ValueNotifier<bool>(false);
  final _textController = TextEditingController();

  final key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _textController.text = 'Здесь мог бы быть ваш мем';
  }


  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      border: Border.all(
        color: Colors.white,
        width: 2,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: RepaintBoundary(
        key: key,
        child: Center(
          child: ColoredBox(
            color: Colors.black,
            child: DecoratedBox(
              decoration: decoration,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: DecoratedBox(
                        decoration: decoration,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: getImageFromGallery,
                              onDoubleTap: getImageFromPhoto,
                              child: ValueListenableBuilder(
                                valueListenable: _valueNewFile,
                                builder: (_, value, __) {
                                  _valueNewFile.value = false;
                                  final path = imgXFile?.path;
                                  return (path != null)
                                    ? Image.file(
                                      File(path),
                                       fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                      'https://i.cbc.ca/1.6713656.1679693029!/fileImage/httpImage/image.jpg_gen/derivatives/16x9_780/this-is-fine.jpg',
                                      fit: BoxFit.cover,
                                    );
                                }
                              )
                            )
                          )
                        ),
                      ),
                    ),
                    TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 10,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Impact',
                        fontSize: 40,
                        color: Colors.white,
                      ),
                      mouseCursor: SystemMouseCursors.text,
                      decoration: const InputDecoration(
                        border: InputBorder.none
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.save_as_sharp,),
        onPressed: () async {
          RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
          Image image = await boundary.toImage() as Image;
          ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
          Uint8List pngBytes = byteData.buffer.asUint8List();
          print(pngBytes);
          final directory = (await getExternalStorageDirectory()).path;
          File imgFile = File('$directory/layout2.pdf');
          imgFile.writeAsBytes(pngBytes);
        },
      ),
    );
  }


  Future<void> getImageFromGallery() async {
    imgXFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (imgXFile == null) return;
    _valueNewFile.value = true;
  }

  Future<void> getImageFromPhoto() async {
    imgXFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (imgXFile == null) return;
    _valueNewFile.value = true;
  }
}
