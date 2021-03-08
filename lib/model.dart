import 'package:flutter/cupertino.dart';

class SpecialityModel {
  String imgAssetPath;
  String speciality;
  int noOfQuestions;
  Color backgroundColor;
  SpecialityModel(
      {this.imgAssetPath,
      this.speciality,
      this.noOfQuestions,
      this.backgroundColor});
}

class Chapter {
  Chapter({this.title, this.units});

  //The minimum word descriptor of this chapter
  String title;
  //A collection of units
  List<ChapterUnit> units;
}

//The learning and testing material for a specific unit in a chapter
class ChapterUnit {
  ChapterUnit({this.unit, this.unitID, this.image, this.tips});
  //The specific unit to be learned e.g: a word, a number, an emotion
  String unit;
  //The representation of this unit for api use
  String unitID;
  //Path to image in assets
  String image;
  //Tips,seperated by \n to indicate new lines
  String tips;
}
