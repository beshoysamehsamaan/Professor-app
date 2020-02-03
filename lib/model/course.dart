import 'package:firebase_database/firebase_database.dart';

class Course {
  String _id ;
  String _name;
  String _hours;
  String _numofstud;
  String _department;
  String _description;
  String _material ;

  Course(this._id,this._name,this._hours,
      this._numofstud,this._department,
      this._description
      , this._material
      );


  Course.map(dynamic obj){
    this._name = obj['name'];
    this._hours = obj['hours'];
    this._numofstud = obj['numofstud'];
    this._department = obj['department'];
    this._description = obj['description'];
    this._material = obj['material'];
  }

  String get id => _id;
  String get name => _name;
  String get hours => _hours;
  String get numofstud => _numofstud;
  String get department => _department;
  String get description => _description;
  String get material => _material;

  Course.fromSnapShot(DataSnapshot snapshot){
    _id = snapshot.key;
    _name = snapshot.value['name'];
    _hours = snapshot.value['hours'];
    _numofstud = snapshot.value['numofstud'];
    _department = snapshot.value['department'];
    _description = snapshot.value['description'];
    _material = snapshot.value['material'];
  }
}