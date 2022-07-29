import 'package:flutter/material.dart';
import 'package:knob_widget/knob_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home/server.dart';

class Fan extends StatefulWidget {
  const Fan({Key? key, required this.title, required this.server})
      : super(key: key);

  final String title;
  final Server server;

  @override
  State<Fan> createState() => _FanState();
}

class _FanState extends State<Fan> {
  bool toggle1 = false;

  final double _minimum = 0;
  final double _maximum = 100;

  late KnobController _controller;
  late double _knobValue;

  void toast(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void valueChangedListener(double value) {
    if (mounted) {
      setState(() {
        _knobValue = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _knobValue = _minimum;
    _controller = KnobController(
      initial: _knobValue,
      minimum: _minimum,
      maximum: _maximum,
      startAngle: 0,
      endAngle: 180,
    );
    _controller.addOnValueChangedListener(valueChangedListener);

    setState(() {
      toggle1 = widget.server.getFan;
      _controller.setCurrentValue((widget.server.getSpeed).toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control It!'),
      ),
      body: Column(children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              height: 40.0,
              width: 100.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: toggle1 ? Colors.blue : Colors.white,
              ),
              child: Stack(children: <Widget>[
                AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                    top: 3.0,
                    left: toggle1 ? 60.0 : 0.0,
                    right: toggle1 ? 0.0 : 60.0,
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            toggle1 = !toggle1;
                          });
                          widget.server
                              .postData('fan', toggle1 ? 'true' : 'false')
                              .then((String result) {
                            toast(result);
                          });
                        },
                        splashFactory: NoSplash.splashFactory,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return RotationTransition(
                                turns: animation, child: child);
                          },
                          child: toggle1
                              ? Icon(Icons.check_circle,
                                  color: Colors.white,
                                  size: 35.0,
                                  key: UniqueKey())
                              : Icon(Icons.remove_circle_outline,
                                  color: Colors.blue,
                                  size: 35.0,
                                  key: UniqueKey()),
                        )))
              ]),
            ),
            const SizedBox(
              height: 300,
              width: 0,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              child: Knob(
                controller: _controller,
                width: 200,
                height: 200,
                style: const KnobStyle(
                  tickOffset: 10,
                  labelOffset: 10,
                  minorTicksPerInterval: 10,
                ),
              ),
              onTap: () {
                widget.server
                    .postData('speed', _knobValue.round().toString())
                    .then((String result) {
                  toast(result);
                });
              },
            )
          ],
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _controller.removeOnValueChangedListener(valueChangedListener);
    super.dispose();
  }
}
