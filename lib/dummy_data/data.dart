import 'package:flutter/cupertino.dart';
import '../model.dart';

List<SpecialityModel> getSpeciality() {
  List<SpecialityModel> specialities = new List<SpecialityModel>();
  SpecialityModel specialityModel = new SpecialityModel();

  //1
  specialityModel.noOfQuestions = 10;
  specialityModel.speciality = "Alphabet";
  specialityModel.imgAssetPath = "assets/omega.svg";
  specialityModel.backgroundColor = Color(0xffFBB97C);
  specialities.add(specialityModel);

  specialityModel = new SpecialityModel();

  //2
  specialityModel.noOfQuestions = 17;
  specialityModel.speciality = "Food";
  specialityModel.imgAssetPath = "assets/food.svg";
  specialityModel.backgroundColor = Color(0xffF69383);
  specialities.add(specialityModel);

  specialityModel = new SpecialityModel();

  //3
  specialityModel.noOfQuestions = 27;
  specialityModel.speciality = "Places";
  specialityModel.imgAssetPath = "assets/travel.svg";
  specialityModel.backgroundColor = Color(0xffEACBCB);
  specialities.add(specialityModel);

  specialityModel = new SpecialityModel();

  return specialities;
}
