import 'package:flutter/material.dart';
import 'package:pile_image_view/pile_image/model/pile_model.dart';

import '../widget/pile_view.dart';

typedef PileAddCallBack = Function(Offset offset);
typedef PileClickCallBack = Function(PileModel pileModel);

class PileImageView extends StatefulWidget {
  final bool isEditType;
  final Image imageView;
  final List<PileModel> pileList;
  final PileAddCallBack pileAddCallBack;
  final PileClickCallBack pileClickCallBack;

  const PileImageView({Key key, this.isEditType,this.imageView,this.pileList,this.pileAddCallBack,this.pileClickCallBack}) : super(key: key);

  @override
  PileImageViewState createState() => PileImageViewState();
}

class PileImageViewState extends State<PileImageView> {
  PileStatusNotifier notifier = PileStatusNotifier(PileStatus.none);
  Size _imgSize;
  List<PileModel> _pileList;

  @override
  void initState() {
    _imgSize = Size.zero;
    _pileList = widget.pileList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildChild(context);
  }

  void submit() {
    // _pileBloc.add(PileEventPost(_pileList, widget.model.ids));
  }

  void _showPiles() {
    notifier.value = PileStatus.show;
    if (_imgSize == Size.zero) {
      setState(() {
        _imgSize = context.size;
      });
    }
  }

  Widget _buildChild(BuildContext context) {
    var img = GestureDetector(
      onTapDown: (TapDownDetails details) {
        if (widget.isEditType) {
          if (_imgSize == Size.zero) {
            setState(() {
              _imgSize = context.size;
            });
          }
          double gx = details.localPosition.dx;
          double gy = details.localPosition.dy;
          // _openModalBottom4Pile(
          //     context, gx / _imgSize.width, gy / _imgSize.height);
          if(widget.pileAddCallBack!=null){
            widget.pileAddCallBack(Offset(gx / _imgSize.width, gy / _imgSize.height));
          }
        }
      },
      onTap: () {
        if (notifier.value == PileStatus.show) {
          notifier.value = PileStatus.hide;
        } else {
          _showPiles();
        }
      },
      child: widget.imageView,
    );

    var list = <Widget>[];
    if (_pileList.length>0) {
      list = _pileList.map((e) {
        return Positioned(
            left: e.point.dx * _imgSize.width,
            top: e.point.dy * _imgSize.height,
            child: PileView(
              pileStatusNotifier: notifier,
              model: e,
              pointChangeCallBack: (offset, model) {
                if (offset == null) {
                  //只改变角度
                  e.angle = model.angle;
                } else {
                  //改变位置
                  Offset p = Offset(model.point.dx + offset.dx / _imgSize.width,
                      model.point.dy + offset.dy / _imgSize.height);
                  p = Offset(p.dx.clamp(0.0, 1.0 - 3*PileView.PileSize / _imgSize.width),
                      p.dy.clamp(0.0, 1.0 - 3*PileView.PileSize / _imgSize.height));
                  setState(() {
                    model.point = p;
                  });
                }
              },
              txtShowCallBack: (txtValues) {
                Future.delayed(Duration(milliseconds: 200)).then((value) {
                  setState(() {
                    e.textLen = txtValues[0];
                    e.textPos = Offset(
                        txtValues[1] + 1.5*PileView.PileSize,
                        txtValues[2]);
                  });
                });
              },
            ));
      }).toList();

      for (PileModel e in _pileList) {
        // print('PileModel ${e.textPos}  len:${e.textLen}');
        if (e.textLen != null && e.textLen.abs() > 0) {
          list.add(Positioned(
            left: e.point.dx * _imgSize.width + e.textPos.dx + (e.textLen<0?e.textLen:0),
            top: e.point.dy * _imgSize.height + e.textPos.dy-5,
            child: Container(
              // color: Colors.blue.withOpacity(0.5),
              child: InkWell(
                child: Container(
                  width: e.textLen.abs(),
                  height: 24,
                ),
                onTap: () {
                  if(widget.pileClickCallBack!=null){
                    widget.pileClickCallBack(e);
                  }
                },
              ),
            ),
          ));
        }
      }

      if (widget.isEditType) {
        Future.delayed(Duration(milliseconds: 200), () {
          notifier.value = PileStatus.none;
          _showPiles();
        });
      }
    }

    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[img]..addAll(list),
      ),
    );
  }

}
