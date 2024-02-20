import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

enum ColorLabel {
  blue('Blue', Colors.blue),
  pink('Pink', Colors.pink),
  green('Green', Colors.green),
  yellow('Orange', Colors.orange),
  black('Black', Colors.black),
  grey('Grey', Colors.grey);

  const ColorLabel(this.label, this.color);
  final String label;
  final Color color;
}

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
  final _textControllerUrl = TextEditingController();
  final _colorController = TextEditingController();
  var _count = 2;
  var selectedColor = ColorLabel.black;
  final key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _textController.text = 'Здесь мог бы быть ваш мем';
    _textControllerUrl.text = 'https://i.cbc.ca/1.6713656.1679693029!/fileImage/httpImage/image.jpg_gen/derivatives/16x9_780/this-is-fine.jpg';

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
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
         title: Row(
           children: [
             const Icon(Icons.label_important_outline_sharp,
               color: Colors.white,
             ),
             const SizedBox(width: 10,),
             Expanded(
               child: TextField(
                 controller: _textControllerUrl,
                 minLines: 1,
                 maxLines: 1,
                 textAlign: TextAlign.center,
                 style: const TextStyle(
                   fontFamily: 'Impact',
                   fontSize: 16,
                   color: Colors.white,
                 ),
                 mouseCursor: SystemMouseCursors.text,
                 decoration: const InputDecoration(
                     border: InputBorder.none
                 ),
                 onSubmitted: (_) => setState(() {

                 }),
               ),
             ),
             const SizedBox(width: 10,),
             ElevatedButton(onPressed: () => setState(() {
               imgXFile= null;
               }),
              style:  const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.black)
              ),
              child: const Icon(Icons.save_alt, color: Colors.white),
             ),

           ],
         ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.black,
              child: Row(
                children: [
                  DropdownMenu<ColorLabel>(
                    textStyle: const TextStyle(color: Colors.white),
                    menuStyle: const MenuStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.white),
                      surfaceTintColor: MaterialStatePropertyAll(Colors.white),
                    ),
                    initialSelection: ColorLabel.black,
                    controller: _colorController,
                    requestFocusOnTap: true,
                    onSelected: (ColorLabel? color) {
                      setState(() {
                        selectedColor = color??ColorLabel.black;
                        FocusScope.of(context).unfocus();
                      });
                    },
                    dropdownMenuEntries: ColorLabel.values
                        .map<DropdownMenuEntry<ColorLabel>>(
                            (ColorLabel color) {
                          return DropdownMenuEntry<ColorLabel>(
                            value: color,
                            label: color.label,
                            //enabled: color.label != 'Grey',
                            style: MenuItemButton.styleFrom(
                              foregroundColor: color.color,
                            ),
                          );
                        }).toList(),
                  ),
                  DropdownMenu<int>(
                    textStyle: const TextStyle(color: Colors.white),
                    menuStyle: const MenuStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.white),
                      surfaceTintColor: MaterialStatePropertyAll(Colors.white),
                    ),
                    initialSelection: _count,
                    //controller: _colorController,
                    requestFocusOnTap: true,
                    onSelected: (int? num) {
                      setState(() {
                        _count = num??2;
                        FocusScope.of(context).unfocus();
                      });
                    },
                    dropdownMenuEntries: [
                      for(int i = 1; i < 5; i++)DropdownMenuEntry<int>(
                        value: i,
                        label: i.toString(),
                        //enabled: color.label != 'Grey',
                        style: MenuItemButton.styleFrom(
                          foregroundColor: Colors.black,
                        )
                      )

                    ],

                  ),
                ],
              ),
            ),
            RepaintBoundary(
              key: key,
              child: Center(
                child: ColoredBox(
                  color: selectedColor.color,
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
                                              _textControllerUrl.text,
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
                            maxLines: _count,
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
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.grey,
            child: const Icon(Icons.share,),
            onPressed: () async {
              var boundary = key.currentContext?.findRenderObject();
              if (boundary == null || boundary is! RenderRepaintBoundary) return;
              var image = await boundary.toImage();
              var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
              if (byteData == null) return;
              Uint8List pngBytes = byteData.buffer.asUint8List();

              final directory = await getApplicationCacheDirectory();
              File file = File('${directory.path}/image.jpg');
              await file.writeAsBytes(pngBytes);
              await Share.shareFiles(
                  [file.path],
                  text: 'Great Meme!!!',

              );
              //Share.shareFiles(['${directory.path}/image1.jpg', '${directory.path}/image2.jpg']);
            }),
          const SizedBox(width: 10,),
          FloatingActionButton(
            backgroundColor: Colors.grey,
            child: const Icon(Icons.save_as_sharp,),
            onPressed: () async {
              var boundary = key.currentContext?.findRenderObject();
              if (boundary == null || boundary is! RenderRepaintBoundary) return;
              var image = await boundary.toImage();
              var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
              if (byteData == null) return;
              Uint8List pngBytes = byteData.buffer.asUint8List();
              final params = SaveFileDialogParams(
                  sourceFilePath: null,
                  data: pngBytes,
                  fileName: 'fileName.png'
              );
              await FlutterFileDialog.saveFile(params: params);
            },
          ),
        ],
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
