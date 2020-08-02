/*
 * @Author: xikan
 * @Email: lileilei1119@foxmail.com
 */ 
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pile_image_view/pile_image/model/pile_model.dart';

typedef PointChangeCallBack = Function(Offset offset, PileModel model);
typedef TxtShowCallBack = Function(List<double> txtValues);

class PileStatusNotifier extends ValueNotifier<PileStatus> {
  PileStatusNotifier(value) : super(value);
}

enum PileStatus {
  none,
  show,
  hide,
} 

class PileView extends StatefulWidget {

  static const double PileSize = 10.0;

  const PileView({
    Key key,
    this.size = PileSize,
    this.duration = const Duration(milliseconds: 1000),
    this.controller,
    this.pileStatusNotifier,
    this.model,
    this.pointChangeCallBack,
    this.txtShowCallBack,
  }) : super(key: key);

  final double size;
  final Duration duration;
  final AnimationController controller;
  final PileStatusNotifier pileStatusNotifier;
  final PileModel model;
  final PointChangeCallBack pointChangeCallBack;
  final TxtShowCallBack txtShowCallBack;

  @override
  _PileViewState createState() => _PileViewState();
}

class _PileViewState extends State<PileView>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  Animation<double> _textAnimation;
  Animation<Offset> _lineAnimation;
  bool _isHide;
  double _radius;
  Color _color;

  @override
  void initState() {
    super.initState();

    _isHide = true;
    _radius = widget.size / 2;
    _color = widget.model.color;

    _controller = (widget.controller ??
        AnimationController(vsync: this, duration: widget.duration))
      ..addListener(() {
        setState(() {});
      });

    _textAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0.6, 1.0, curve: Curves.easeInOut)));

    _animation = Tween(begin: 0.0, end: 2.0).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut)));

    widget.pileStatusNotifier.addListener(() {
      if (widget.pileStatusNotifier.value == PileStatus.show) {
        setState(() {
          _isHide = false;
        });
        _controller.forward();
      } else if (widget.pileStatusNotifier.value == PileStatus.hide) {
        _controller.reverse().whenComplete(() {
          setState(() {
            _isHide = true;
          });
          if(widget.txtShowCallBack!=null){
              widget.txtShowCallBack([0,0,0]);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var pileLinePainter = PileLinePainter(
      lineColor: _color.withOpacity(1.0),
      width: 1.0,
      begin: Offset(_radius, _radius),
      end: _lineAnimation?.value,
      opacity: _textAnimation.value,
      angle: widget.model.angle,
      txt: widget.model.value,
      txtShowCallBack: (txtValues) {
        if(widget.txtShowCallBack != null){
          if(_isHide){
            widget.txtShowCallBack([0,0,0]);
          }else{
            widget.txtShowCallBack(txtValues);
          }
        }
      },
    );

    if (_lineAnimation == null) {
      _lineAnimation = Tween(
              begin: Offset(_radius, _radius),
              end: Offset(pileLinePainter.getEndOffsetX(), _radius))
          .animate(CurvedAnimation(
              parent: _controller,
              curve: Interval(0.0, 0.5, curve: Curves.easeInOut)));

      pileLinePainter.end = _lineAnimation?.value;
    }

    return Offstage(
      offstage: _isHide,
      child: GestureDetector(
        onTap: () {
          nextAngle();
        },
        onPanStart: (detail) {},
        onPanUpdate: (detail) {
          if (widget.pointChangeCallBack != null) {
            widget.pointChangeCallBack(detail.delta, widget.model);
          }
        },
        onPanEnd: (detail) {},
        child: Stack(
          children: [
            Container(
              width: widget.size * 3,
              height: widget.size * 3,
              color: Colors.transparent,
              child: Center(
                child: Stack(children: [
                  Container(
                    child: CustomPaint(
                      foregroundPainter: pileLinePainter,
                    ),
                  ),
                  Transform.scale(
                    scale: _animation.value.abs(),
                    child: SizedBox.fromSize(
                        size: Size.square(widget.size),
                        child: _itemBuilder(0, 0.6)),
                  ),
                  Transform.scale(
                    scale: _animation.value.abs() > 0 ? 1 : 0,
                    child: SizedBox.fromSize(
                        size: Size.square(widget.size),
                        child: _itemBuilder(1, 0.8)),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  nextAngle() {
    _lineAnimation = null;
    widget.model.angle += 45;
    if (widget.model.angle == 180) {
      widget.model.angle += 45;
    } else if (widget.model.angle == 360) {
      widget.model.angle = 45;
    }
    setState(() {});
    if (widget.pointChangeCallBack != null) {
      widget.pointChangeCallBack(null, widget.model);
    }
  }

  Widget _itemBuilder(int index, opacity) => DecoratedBox(
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: _color.withOpacity(opacity)));
}

class PileLinePainter extends CustomPainter {
  Color lineColor;
  double width;
  Offset begin;
  Offset end;
  double opacity;
  double angle;
  String txt;

  int padding = 8;

  TxtShowCallBack txtShowCallBack;

  PileLinePainter(
      {this.lineColor,
      this.width,
      this.begin,
      this.end,
      this.opacity,
      this.angle,
      this.txt,
      this.txtShowCallBack});

  @override
  void paint(Canvas canvas, Size size) {
    Paint _paint = new Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    TextPainter textPainter = _getTextPainter(txt)..layout();

    List<double> values = _getCalValues(textPainter);
    double len = values[0];
    double radiusX = values[1];
    double radiusY = values[2];

    Offset middleOffset = Offset(begin.dx + radiusX, begin.dy + radiusY);
    Offset endOffset = Offset(end.dx, middleOffset.dy);
    double step = end.dx - begin.dx;
    if (step.abs() <= radiusX.abs()) {
      double stepY = (radiusY > 0 ? step.abs() : -step.abs());
      stepY = radiusY == 0 ? 0 : stepY;
      endOffset = Offset(begin.dx + step, begin.dy + stepY);
      canvas.drawLine(begin, endOffset, _paint);
    } else {
      canvas.drawLine(begin, middleOffset, _paint);
      canvas.drawLine(middleOffset, endOffset, _paint);
    }

    textPainter.paint(
        canvas,
        Offset(
            len < 0
                ? endOffset.dx + padding / 2
                : middleOffset.dx + padding / 2,
            endOffset.dy - 18));
  }

  @override
  bool shouldRepaint(PileLinePainter oldDelegate) {
    if (oldDelegate.angle == this.angle) {
      return false;
    } else {
      return true;
    }
  }

  TextPainter _getTextPainter(String msg) {
    return new TextPainter(
        text: TextSpan(
            style: new TextStyle(
                color: lineColor.withOpacity(opacity), fontSize: 12),
            text: msg),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
  }

  List<double> _getCalValues(TextPainter textPainter) {
    double radiusX = 0;
    double radiusY = 0;
    double len = textPainter.width + padding; //txt.length * 20.0;
    switch (angle?.toInt()) {
      case 45:
        radiusX = 24;
        radiusY = -24;
        break;
      case 90:
        radiusX = 24;
        radiusY = 0;
        break;
      case 135:
        radiusX = 24;
        radiusY = 24;
        break;
      case 225:
        len = -len;
        radiusX = -24;
        radiusY = 24;
        break;
      case 270:
        len = -len;
        radiusX = -24;
        radiusY = 0;
        break;
      case 315:
        len = -len;
        radiusX = -24;
        radiusY = -24;
        break;
    }
    List<double> txtValues = [len, radiusX, radiusY];
    if (txtValues.length == 3 && txtShowCallBack != null) {
      txtShowCallBack(txtValues);
    }
    return txtValues;
  }

  double getEndOffsetX() {
    TextPainter textPainter = _getTextPainter(txt)..layout();
    List<double> values = _getCalValues(textPainter);
    double len = values[0];
    double radiusX = values[1];
    return begin.dx + radiusX + len;
  }
}
