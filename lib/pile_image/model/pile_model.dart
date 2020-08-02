/*
 * @Author: xikan
 * @Email: lileilei1119@foxmail.com
 */ 
import 'dart:ui';

import 'package:flutter/material.dart';
/// parentId : "97883e5e06324325b218708e01339d8e"
/// color : "0x000000"
/// createTime : "2018-09-26 02:04:40"
/// ids : "3a4f078ad58e4ee8bd5f86c5a4969e17"
/// index : "1"
/// angle : 45.0
/// textPos : "{147, 67.5}"
/// userId : "cd6a4a3ed6924001a86965744cb9fb60"
/// value : "you "
/// point : "{0.31555554199218749, 0.25530488819705516}"

class PileModel {
  String parentId;
  Color color;
  String createTime;
  String ids;
  String index;
  double angle;
  Offset textPos;
  String userId;
  String value;
  Offset point;
  double textLen;

  PileModel({this.parentId, this.color=Colors.black, this.createTime, this.ids, this.index, this.angle=90.0, this.textPos, this.userId, this.value, this.point});

  PileModel.map(dynamic obj) {
    this.parentId = obj["parentId"];
    this.color = str2Color(obj["color"]);
    this.createTime = obj["createTime"];
    this.ids = obj["ids"];
    this.index = obj["index"];
    this.angle = obj["angle"]??90.0;
    this.textPos = str2Offset(obj["textPos"]);
    this.userId = obj["userId"];
    this.value = obj["value"];
    this.point = str2Offset(obj["point"]);
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["parentId"] = parentId;
    map["color"] = color.toString();
    map["createTime"] = createTime;
    map["ids"] = ids;
    map["index"] = index;
    map["angle"] = angle;
    map["textPos"] = "{${textPos.dx},${textPos.dy}}";
    map["userId"] = userId;
    map["value"] = value;
    map["point"] = "{${point.dx},${point.dy}}";
    return map;
  }

  Offset str2Offset(String str){
    Offset result = Offset(0,0);
    if(str.isNotEmpty){
      List arr = str.split(",");
      if(arr.length==2){
        String xStr = arr[0];
        xStr = xStr.replaceAll("{", "");
        String yStr = arr[1];
        yStr = yStr.replaceAll("}", "");
        if(xStr.isNotEmpty && yStr.isNotEmpty){
          result = Offset(double.parse(xStr),double.parse(yStr));
        }
      }
    }
    return result;
  }

  Color str2Color(String str){
    Color result = Colors.white;
    if(str!=null && str.isNotEmpty){
      result = Color(int.parse(str));
    }
    return result;
  }

  bool isEqual(PileModel p){
    return (this.ids==p.ids && this.color==p.color && this.index==p.index
    && this.value==this.value && this.angle==p.angle
    && this.point==p.point);
  }

}