/*
 * @Author: xikan
 * @Email: lileilei1119@foxmail.com
 */ 
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:pile_image_view/pile_image/model/pile_model.dart';

typedef PileEditFinish = Function(PileModel model);

class PileEditView extends StatefulWidget {

  final PileModel model;
  final PileEditFinish pileEditFinish;

  const PileEditView({Key key, this.model,this.pileEditFinish}) : super(key: key);

  @override
  _PileEditViewState createState() => _PileEditViewState();
}

class _PileEditViewState extends State<PileEditView> {

  Color _selColor;
  List<Color> colorList;

  @override
  void initState() {
    colorList = [Colors.blue,Colors.black,Colors.white];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 16,right: 16,top: 32,
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _buildTitle(
                    '序号：', EdgeInsets.only(left: 16, top: 16, bottom: 10)),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    color: Colors.white,
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      inputFormatters: [LengthLimitingTextInputFormatter(20)],
                      decoration: InputDecoration(
                        hintText: '请输入序号',
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                          widget.model.index = val;
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: <Widget>[
                _buildTitle(
                    '名称：', EdgeInsets.only(left: 16, top: 16, bottom: 10)),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    color: Colors.white,
                    child: TextFormField(
                      inputFormatters: [LengthLimitingTextInputFormatter(20)],
                      decoration: InputDecoration(
                        hintText: '请输入名称',
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        widget.model.value = val;
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: <Widget>[
                _buildTitle('颜色：', EdgeInsets.only(left: 16)),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: colorList.map((e) => _buildColorItem(e)).toList(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              onPressed: () => this._submitted(),
              color: Colors.blue,
              child: Container(
                  width: getScreenW(context) - 32,
                  height: 44,
                  alignment: Alignment.center,
                  child: Text('确定',
                      style: TextStyle(fontSize: 20, color: Colors.white))),
            ),
            SizedBox(height: 16),
          ],
        ));
  }

  double getScreenW(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width;
  }

  _buildTitle(String title, [EdgeInsetsGeometry m = EdgeInsets.zero]) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: m,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildColorItem(Color color){
    bool isSel = _selColor == color;
    double radius = 38;
   return Container(
     padding: EdgeInsets.all(8),
     child: InkWell(
       onTap: (){
         setState(() {
           _selColor = color;
         });
       },
       child: Stack(
         children: [
           SizedBox.fromSize(
           size: Size.square(radius),
           child: DecoratedBox(
               decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(4.0),
                   border: isSel?Border.all(color: Colors.red,width: 2):null,
                   shape: BoxShape.rectangle, color: color)),
         ),
           Offstage(
             offstage: !isSel,
             child: Container(
               width: radius,
               height: radius,
               child: Align(
                 alignment: FractionalOffset(0.8, 0.8),
                 child: Icon(Icons.check_circle,color: Colors.red,size: 14,),
               ),
             ),
           )
         ],
       ),
     ),
   );
  }

  void _submitted() {
    if(widget.pileEditFinish!=null){
      widget.model.color = _selColor;
      widget.pileEditFinish(widget.model);
    }
  }
}
