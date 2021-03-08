import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:oreo_sign/screens/sucess.dart';
import 'package:tflite/tflite.dart';
import '../model.dart';
import 'HomeView.dart';

class TestView extends StatefulWidget {
  final Chapter chapter;

  Function returnHome;
  Function moveToTest;

  TestView({this.chapter, this.returnHome, this.moveToTest});

  createState() => TestViewState();
}

class TestViewState extends State<TestView> {
  Color green = const Color.fromRGBO(0, 128, 0, 1);
  Color blue = const Color.fromRGBO(0, 0, 250, 1);

  List<String> answers = [];

  var normal = TextStyle(fontSize: 18, fontWeight: FontWeight.normal);
  var bold = TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

  int currentUnit = 0;
  final double passMark = 0.5;

  bool completed = false;

  void addAnswer(String answer) {
    print(answer);
    answers.add(answer);
  }

  void removeAnswer() {
    print(answers.removeLast());
  }

  double getScore() {
    double correct = 0;
    for (int i = 0; i < widget.chapter.units.length; i++) {
      if (answers.length > i && widget.chapter.units[i].unitID == answers[i]) {
        correct += 1;
      }
    }
    return correct;
  }

  void progress() {
    //Set State
    setState(() {
      if (currentUnit + 1 < widget.chapter.units.length) {
        currentUnit += 1;
      } else {
        completed = true;
      }
    });
  }

  Widget getView() {
    if (!completed) {
      //In Session
      return Column(children: [
        SizedBox(height: 10),
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Testing: ${widget.chapter.title}",
              style: bold,
            )),
        SizedBox(height: 10),
        Align(
            alignment: Alignment.centerLeft,
            child: Text("Question ${currentUnit + 1} of 26", style: normal)),
        SizedBox(height: 20),
        new TestUnitView(
            unit: widget.chapter.units[currentUnit],
            progress: () => {progress()},
            addAnswer: (String s) => {addAnswer(s)},
            removeAnswer: () => {removeAnswer()})
      ]);
    } else {
      //Completed
      return Column(children: [
        SizedBox(height: 20),
        Align(
            alignment: Alignment.center,
            child: Text(
                "You Answered ${getScore().toInt()}/${widget.chapter.units.length} Correctly",
                style: normal)),
        SizedBox(height: 20),
        Align(
            alignment: Alignment.center,
            child: Text(
                passMark * widget.chapter.units.length.toDouble() < getScore()
                    ? "You Passed"
                    : "Try Again",
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: passMark * widget.chapter.units.length.toDouble() <
                            getScore()
                        ? green
                        : blue))),
        SizedBox(height: 30),
        Align(
            alignment: Alignment.center,
            child: Text(
                passMark * widget.chapter.units.length.toDouble() < getScore()
                    ? "You did amazing!  Try out a different category to learn some more signs"
                    : "Great Effort!\n\nTry out the learning session again to help improve your score",
                textAlign: TextAlign.center,
                style: normal)),
        SizedBox(height: 40),
        button("Finish 🥳", () => {widget.returnHome()})
      ]);
    }
  }

  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(10), child: getView());
  }
}

class TestUnitView extends StatefulWidget {
  TestUnitView({this.unit, this.progress, this.addAnswer, this.removeAnswer});

  final ChapterUnit unit;
  Function progress;
  Function addAnswer;
  Function removeAnswer;

  createState() => TestUnitViewState();
}

class TestUnitViewState extends State<TestUnitView> {
  File imageFile;
  String finalPath;
  File displayImage;
  List outputs;
  bool loading = false;

  Color green = const Color.fromRGBO(0, 128, 0, 1);
  Color red = const Color.fromRGBO(250, 0, 0, 1);

  var normal = TextStyle(fontSize: 18, fontWeight: FontWeight.normal);
  var bold = TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

  bool correct;

  Widget answerReviewView(bool correct) {
    return Column(children: [
      Align(
          alignment: Alignment.center,
          child: Text("Your sign was", style: normal)),
      SizedBox(height: 10),
      Align(
          alignment: Alignment.center,
          child: Text(correct ? "Correct" : "Incorrect",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: correct ? green : darkBlue))),
      SizedBox(height: 40),
      Center(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Image.file(
          imageFile,
        ),
        Image.asset('assets/images/${widget.unit.image}')
      ])),
      SizedBox(height: 40),
      Align(
          alignment: Alignment.center,
          child: Text(
            correct
                ? "You nailed this sign!"
                : "Good try, have another go using the correct example on the right!",
            style: normal,
            textAlign: TextAlign.center,
          )),
      SizedBox(height: 20),
      button("Retry 🛠", () => {widget.removeAnswer(), resetAnswer()}),
      SizedBox(height: 30),
      button("Next 👌", () => {nextQuestion()})
    ]);
  }

  Widget inSessionView() {
    return Column(children: [
      Align(
          alignment: Alignment.center,
          child: Text("How do you sign the letter...", style: normal)),
      SizedBox(height: 10),
      Align(
          alignment: Alignment.center,
          child: Text("\"${widget.unit.unit}\"",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold))),
      SizedBox(height: 20),
      button("Take Picture", () => {openImageSelector()}),
      SizedBox(height: 40),
      Align(
          alignment: Alignment.center,
          child: Text("Show us your sign by taking a picture of it",
              style: normal)),
      /*
      SizedBox(height: 20),
      Align(alignment: Alignment.centerLeft,child:Text("Tips",style:bold)),
      SizedBox(height: 20),
      Align(alignment: Alignment.centerLeft,child:Text("1.Make sure your hand is in the middle of the picture\n2.Use a well lit room\n3.Try to make sure only your hand is in the picture",style:normal)),
      */
    ]);
  }

  Future<void> openImageSelector() async {
    //Get Image
    await _showChoiceDialog(context);
    //Store Image
    //On Completion
    checkAnswer(outputs.first["label"]);
  }

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
    await imageResize(imageFile, 64, 64);
    await classifyImage(imageFile);
    //close dialog
    Navigator.of(context).pop();
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

  imageResize(File im, int x, int y) async {
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(im.path);
    imageFile = await FlutterNativeImage.compressImage(im.path,
        targetWidth: x, targetHeight: y);
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

  void checkAnswer(String answer) {
    //Process Answer
    String answerReturned = answer;

    setState(() {
      correct = answerReturned == widget.unit.unitID ? true : false;
    });

    widget.addAnswer(answerReturned);
  }

  void resetAnswer() {
    setState(() {
      correct = null;
    });
  }

  void nextQuestion() {
    resetAnswer();
    setState(() {
      widget.progress();
    });
  }

  Widget getView() {
    if (correct == null) {
      return inSessionView();
    } else {
      if (correct) {
        return answerReviewView(true);
      } else {
        return answerReviewView(false);
      }
    }
  }

  Widget build(BuildContext context) {
    return getView(); //answerReviewView(true);
  }
}
