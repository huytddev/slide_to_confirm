import 'package:flutter/material.dart';

class ConfirmationSlider extends StatefulWidget {
  /// Height of the slider. Defaults to 70.
  final double height;

  /// Width of the slider. Defaults to 300.
  final double width;

  /// The color of the background of the slider. Defaults to Colors.white.
  final Color backgroundColor;

  /// The color of the background of the slider when it has been slide to the end. By giving a value here, the background color
  /// will gradually change from backgroundColor to backgroundColorEnd when the user slides. Is not used by default.
  final Color? backgroundColorEnd;

  /// The color of the moving element of the slider. Defaults to Colors.blueAccent.
  final Color foregroundColor;

  /// The color of the icon on the moving element if icon is IconData. Defaults to Colors.white.
  final Color iconColor;

  /// The button widget used on the moving element of the slider. Defaults to Icon(Icons.chevron_right).
  final Widget sliderButtonContent;

  /// The shadow below the slider. Defaults to BoxShadow(color: Colors.black38, offset: Offset(0, 2),blurRadius: 2,spreadRadius: 0,).
  final BoxShadow? shadow;

  /// The text showed below the foreground. Used to specify the functionality to the user. Defaults to "Slide to confirm".
  final String text;

  /// The style of the text. Defaults to TextStyle(color: Colors.black26, fontWeight: FontWeight.bold,).
  final TextStyle? textStyle;

  /// The callback when slider is completed. This is the only required field.
  final VoidCallback onConfirmation;

  /// The callback when slider is pressed.
  final VoidCallback? onTapDown;

  /// The callback when slider is release.
  final VoidCallback? onTapUp;

  /// The shape of the moving element of the slider. Defaults to a circular border radius
  final BorderRadius? foregroundShape;

  /// The shape of the background of the slider. Defaults to a circular border radius
  final BorderRadius? backgroundShape;

  /// Stick the slider to the end
  final bool stickToEnd;

  const ConfirmationSlider({
    Key? key,
    this.height = 70,
    this.width = 300,
    this.backgroundColor = Colors.white,
    this.backgroundColorEnd,
    this.foregroundColor = Colors.blueAccent,
    this.iconColor = Colors.white,
    this.shadow,
    this.sliderButtonContent = const Icon(
      Icons.chevron_right,
      color: Colors.white,
      size: 35,
    ),
    this.text = "Slide to confirm",
    this.textStyle,
    required this.onConfirmation,
    this.onTapDown,
    this.onTapUp,
    this.foregroundShape,
    this.backgroundShape,
    this.stickToEnd = false,
  }) : assert(height >= 25 && width >= 250);

  @override
  State<StatefulWidget> createState() {
    return ConfirmationSliderState();
  }
}

class ConfirmationSliderState extends State<ConfirmationSlider> {
  double _position = 0;
  int _duration = 0;

  double getPosition() {
    if (_position < 0) {
      return 0;
    } else if (_position > widget.width - widget.height) {
      return widget.width - widget.height;
    } else {
      return _position;
    }
  }

  void updatePosition(details) {
    if (details is DragEndDetails) {
      setState(() {
        _duration = 400;
        if (widget.stickToEnd && _position > widget.width - widget.height) {
          _position = widget.width - widget.height;
        } else {
          _position = 0;
        }
      });
    } else if (details is DragUpdateDetails) {
      setState(() {
        _duration = 0;
        _position = details.localPosition.dx - (widget.height / 2);
      });
    }
  }

  void sliderReleased(details) {
    if (_position > widget.width - widget.height) {
      widget.onConfirmation();
    }
    updatePosition(details);
  }

  Color calculateBackground() {
    if (widget.backgroundColorEnd != null) {
      double percent;

      // calculates the percentage of the position of the slider
      if (_position > widget.width - widget.height) {
        percent = 1.0;
      } else if (_position / (widget.width - widget.height) > 0) {
        percent = _position / (widget.width - widget.height);
      } else {
        percent = 0.0;
      }

      int red = widget.backgroundColorEnd!.red;
      int green = widget.backgroundColorEnd!.green;
      int blue = widget.backgroundColorEnd!.blue;

      return Color.alphaBlend(
          Color.fromRGBO(red, green, blue, percent), widget.backgroundColor);
    } else {
      return widget.backgroundColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    BoxShadow shadow;
    if (widget.shadow == null) {
      shadow = BoxShadow(
        color: Colors.black38,
        offset: Offset(0, 2),
        blurRadius: 2,
        spreadRadius: 0,
      );
    } else {
      shadow = widget.shadow!;
    }

    TextStyle style;
    if (widget.textStyle == null) {
      style = TextStyle(
        color: Colors.black26,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = widget.textStyle!;
    }
    bool isFinish = getPosition() + widget.height == widget.width;
    return AnimatedContainer(
      duration: Duration(milliseconds: _duration),
      curve: Curves.ease,
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: widget.backgroundShape ??
            BorderRadius.all(Radius.circular(widget.height)),
        color: widget.backgroundColorEnd != null
            ? this.calculateBackground()
            : isFinish ? Colors.transparent : widget.backgroundColor,
        // boxShadow: <BoxShadow>[shadow],
      ),
      child: Stack(
        children: <Widget>[
          Visibility(
            visible: !isFinish,
            child: Center(
              child: Text(
                widget.text,
                style: style,
              ),
            ),
          ),
          Visibility(
            visible: !isFinish,
            child: Positioned(
              // left: widget.height / 2,
              child: AnimatedContainer(
                height: widget.height,
                width: getPosition() + widget.height,
                duration: Duration(milliseconds: _duration),
                curve: Curves.ease,
                decoration: BoxDecoration(
                  borderRadius: widget.backgroundShape ??
                      BorderRadius.all(Radius.circular(widget.height)),
                  color: widget.backgroundColorEnd != null ? this
                      .calculateBackground() : widget.foregroundColor,
                ),
              ),
            ),
          ),
          Visibility(
            visible: !isFinish,
            child: AnimatedPositioned(
              duration: Duration(milliseconds: _duration),
              curve: Curves.bounceOut,
              left: getPosition(),
              top: 0,
              child: GestureDetector(
                onTapDown: (_) =>
                widget.onTapDown != null
                    ? widget.onTapDown!()
                    : null,
                onTapUp: (_) =>
                widget.onTapUp != null
                    ? widget.onTapUp!()
                    : null,
                onPanUpdate: (details) {
                  updatePosition(details);
                },
                onPanEnd: (details) {
                  if (widget.onTapUp != null) widget.onTapUp!();
                  if(!isFinish) sliderReleased(details);
                },
                child: Container(
                  height: widget.height,
                  width: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: widget.foregroundShape ??
                        BorderRadius.all(Radius.circular(widget.height / 2)),
                    color: widget.foregroundColor,
                  ),
                  child: widget.sliderButtonContent,
                ),
              ),
            ),
          ),
          Visibility(
              visible: getPosition() + widget.height == widget.width,
              child: AnimatedPositioned(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.bounceOut,
                  left: 0,
                  top: 0,
                  child: AnimatedContainer(
                    height: widget.height,
                    width: getPosition() + widget.height,
                    curve: Curves.ease,
                    decoration: BoxDecoration(
                      borderRadius: widget.backgroundShape ??
                          BorderRadius.all(Radius.circular(widget.height)),
                      color: Color(0xff1AD268).withOpacity(0.2),
                    ),
                    duration: Duration(milliseconds: 1000),
                    child: Center(
                      child: Text("Đã xác thực", style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1AD268)),
                      ),),)
              ))
        ],
      ),
    );
  }
}
