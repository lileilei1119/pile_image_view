/*
 * @Author: xikan
 * @Email: lileilei1119@foxmail.com
 */

import 'package:flutter/material.dart';
import 'package:pile_image_view/pile_image/model/pile_model.dart';
import 'package:pile_image_view/pile_image/widget/pile_edit_view.dart';
import 'package:pile_image_view/pile_image/widget/pile_image_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'PileImageView',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PileModel> data;
  bool _isEditType;
  @override
  void initState() {
    data = [];
    _isEditType = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PileImageView'),
        actions: <Widget>[
          FlatButton(
            child:Text(_isEditType?'预览模式':'编辑模式',style: TextStyle(color: Colors.white),),
            onPressed: (){
              setState(() {
                _isEditType = !_isEditType;
              });
            },
          )
        ],
      ),
      body: PileImageView(
        imageView: Image.asset('assets/demo.jpg'),
        isEditType: _isEditType,
        pileList: data,
        pileAddCallBack: (offset) {
          _openModalBottom4Pile(context, offset.dx, offset.dy);
        },
        pileClickCallBack: (pileModel) {
          showDialog(
              context: context,
              child: AlertDialog(
                content: new Text(
                  "你点击了${pileModel.value}",
                  style: new TextStyle(fontSize: 30.0, color: Colors.black),
                ),
              ));
        },
      ),
    );
  }

  Future _openModalBottom4Pile(
      BuildContext context, double dx, double dy) async {
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          PileModel model = PileModel(point: Offset(dx, dy));
          return SingleChildScrollView(
              child: PileEditView(
            model: model,
            pileEditFinish: (PileModel model) {
              Future.delayed(Duration(milliseconds: 200), () {
                Navigator.of(context).pop();
              });
              setState(() {
                data.add(model);
              });
            },
          ));
        });
  }
}
