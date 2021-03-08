import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../model.dart';
import 'LearningView.dart';
import 'TestingView.dart';

var white = Color.fromRGBO(255, 255, 255, 1);
var black = Color.fromRGBO(0, 0, 0, 1);
var lightBlue = Color.fromRGBO(200, 238, 253, 1);
var peacockBlue = Color.fromRGBO(62, 143, 255, 1);
var darkBlue = Color.fromRGBO(0, 5, 203, 1);
var red = Color.fromRGBO(200, 0, 0, 1);

Widget button(String title, Function action) {
  return ConstrainedBox(
      constraints: BoxConstraints.tightFor(height: 100),
      child: TextButton(
          onPressed: () => {action()},
          child: Container(
              decoration: BoxDecoration(
                  color: white,
                  border: Border.all(color: peacockBlue, width: 7),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 3))
                  ]),
              child: Center(
                  child: ConstrainedBox(
                      constraints: BoxConstraints.tightFor(
                          width: double.infinity, height: 90),
                      child: Center(
                          child: ConstrainedBox(
                              constraints: BoxConstraints.tightFor(height: 130),
                              child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(title,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 20,
                                                color: black)),
                                      ])))))))));
}

class HomeView extends StatefulWidget {
  static var a = new ChapterUnit(
      unit: "A",
      unitID: "A",
      image: "asign.jpg",
      tips: "1.Make a fist\n2.Release your thumb");
  static var b = new ChapterUnit(
      unit: "B",
      unitID: "B",
      image: "bsign.jpg",
      tips: "1.Point your fingers straight up\n2.Tuck in your thumb");
  static var c = new ChapterUnit(
      unit: "C",
      unitID: "C",
      image: "csign.jpg",
      tips:
          "1.Shape the letter c in your hand\n2.Pretend your eating a sandwich🥪");
  static var alphabet = Chapter(title: "Alphabet 📖", units: [a, b, c]);

  static var numbers = Chapter(title: "Numbers", units: [a, b, c]);

  @override
  createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  int selectedPage = 0;

  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'OreoSign',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          backgroundColor: lightBlue,
          body: pages()[selectedPage],
          bottomNavigationBar: bottomNavbar(),
          resizeToAvoidBottomInset: false,
        ));
  }

  List<Widget> pages() {
    return [chapterMenu(true), chapterMenu(false)];
  }

  void pushToView(Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }

  void pushToLearnForChapter(bool learn, Chapter chapter) {
    pushToView(Scaffold(
        appBar: AppBar(title: Text("OreoSign")),
        backgroundColor: white,
        body: ListView(
          children: [
            learn
                ? LearnView(
                    chapter: chapter,
                    returnHome: () => {Navigator.pop(context)},
                    moveToTest: () => {print("moved to test")})
                : TestView(
                    chapter: chapter,
                    returnHome: () => {Navigator.pop(context)},
                    moveToTest: () => {print("moved to test")}),
          ],
        )));
  }

  Widget chapterMenu(bool learnView) {
    return Stack(children: [
      Center(
          child:
              //NOTE: USING ListWheelScrollView renders button tap useless
              ListView(
                  //itemExtent: 300,
                  //diameterRatio: 3,
                  children: [
            SizedBox(height: 210),
            chapterCard(
                "Alphabet 📖",
                !learnView ? "Practice your ABC's!" : "Learn your ABC's!",
                () => {
                      pushToLearnForChapter(
                          learnView ? true : false, HomeView.alphabet)
                    }),
            chapterCard(
                "Numbers 🎲",
                !learnView
                    ? "Practice your numbers!"
                    : "Learn your numbers from 1-10!",
                () => {}),
            chapterCard(
                "Fruits 🍒",
                !learnView
                    ? "Practice your fruit signs!"
                    : "Sign your favourite fruits!",
                () => {}),
          ])),
      Column(children: [
        titleContainer(learnView),
      ])
    ]);
  }

  Widget chapterCard(String title, String message, Function action) {
    return ConstrainedBox(
        constraints: BoxConstraints.tightFor(height: 300),
        child: Padding(
            padding: EdgeInsets.all(20),
            child: TextButton(
                onPressed: () => {action()},
                child: Container(
                    decoration: BoxDecoration(
                        color: white,
                        border: Border.all(color: peacockBlue, width: 20),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 8,
                              offset: Offset(0, 3))
                        ]),
                    child: Center(
                        child: ConstrainedBox(
                            constraints: BoxConstraints.tightFor(
                                width: double.infinity, height: 300),
                            child: Center(
                                child: ConstrainedBox(
                                    constraints:
                                        BoxConstraints.tightFor(height: 130),
                                    child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(title,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 30,
                                                      color: black)),
                                              Text(message,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 20,
                                                      color: black))
                                            ]))))))))));
  }

  Widget titleContainer(bool learnView) {
    return SizedBox(
        width: double.infinity,
        height: 250,
        child: Stack(children: [
          Container(
            color: white,
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(children: [
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Image.asset(learnView
                        ? 'assets/images/oreo.png'
                        : 'assets/images/glass.png')),
                SizedBox(height: 15),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Image.asset(learnView
                        ? 'assets/images/learn.png'
                        : 'assets/images/test.png')),
                SizedBox(height: 15),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      learnView
                          ? "Complete the sessions below to learn how to sign in ASL!"
                          : "Complete the sessions below to test your ASL knowledge!",
                      style: TextStyle(fontSize: 18),
                    )),
              ]))
        ]));
  }

  Widget mainContainer() {
    return ListView(
      children: [Text("Hey")],
    );
  }

  Widget bottomNavbar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Text("🍪", style: TextStyle(fontSize: 20)), label: "Learn"),
        BottomNavigationBarItem(
            icon: Text("🥛", style: TextStyle(fontSize: 20)), label: "Test")
      ],
      selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color.fromRGBO(0, 0, 0, 1)),
      unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color.fromRGBO(0, 0, 0, 1)),
      backgroundColor: peacockBlue,
      selectedItemColor: white,
      unselectedItemColor: Color.fromRGBO(255, 255, 255, 0.5),
      currentIndex: selectedPage,
      onTap: (int index) {
        setState(() {
          selectedPage = index;
        });
      },
    );
  }
}
