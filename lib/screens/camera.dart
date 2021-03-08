import 'dart:io';
import 'dart:io' as Io;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oreo_sign/screens/sucess.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';

bool isWeb = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

class Camera extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  //global variables:
  File imageFile;
  String finalPath;
  List outputs;
  bool loading = false;

  Future<void> storeSharedPrefs(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  //restore string value
  Future<String> restoreSharedPrefs(String key, String inputValue) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);

    if (value == null) {
      return null;
    }

    setState(() {
      inputValue = value;
    });

    return inputValue;
  }

  //open device gallery / camera depend from argument input
  _getPhoto(BuildContext context, ImageSource source) async {
    //get Image file:
    File selected = await ImagePicker.pickImage(source: source);
    //store file path:
    storeSharedPrefs('image', selected.path);
    //set selected image
    this.setState(() {
      imageFile = selected;
      print('image path is:  ${selected.path}');
    });
    imageResize(imageFile);
    classifyImage(imageFile);
    //close dialog
    Navigator.of(context).pop();
  }

  imageResize(File im) async {
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(im.path);
    imageFile = await FlutterNativeImage.compressImage(im.path,
        targetWidth: 64, targetHeight: 64);
  }

  //create option dialog:
  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: Text(
              'Load picture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.panorama,
                          color: Colors.grey[200],
                          size: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Gallery',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                    onTap: () {
                      _getPhoto(context, ImageSource.gallery);
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.camera,
                          color: Colors.grey[200],
                          size: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Camera',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                    onTap: () {
                      // _openCamera(context);
                      _getPhoto(context, ImageSource.camera);
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  sendFirebase(File image) {
    print(outputs);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Success()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.indigo,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Center(
                child: imageFile == null
                    ? Text(
                        'Try the letter A',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 30,
                            fontStyle: FontStyle.italic),
                      )
                    : sendFirebase(imageFile),
                //       : Image.file(
                // // image was found we can navigate to other screen and send data to firebase
                // imageFile,
                // width: 400,
                //   height: 400,
                // ),
              ),
              RaisedButton(
                color: Colors.blueAccent,
                onPressed: () {
                  _showChoiceDialog(context);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.picture_in_picture,
                      color: Colors.grey[200],
                      size: 20,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'add image',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    loading = true;
    loadModel().then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 5,
        imageStd: 5,
        numResults: 27,
        threshold: 0.1);
    setState(() {
      loading = false;
      outputs = output;
    });
    print(image.path);
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
