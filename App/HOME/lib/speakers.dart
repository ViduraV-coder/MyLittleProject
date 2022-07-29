import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home/server.dart';

class Speakers extends StatefulWidget {
  const Speakers({Key? key, required this.title, required this.server})
      : super(key: key);

  final String title;
  final Server server;

  @override
  State<Speakers> createState() => _SpeakersState();
}

class _SpeakersState extends State<Speakers> {
  bool toggle1 = false;
  bool toggle2 = false;
  bool toggle3 = false;

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

  @override
  void initState() {
    setState(() {
      toggle1 = widget.server.getCeiling;
      toggle2 = widget.server.getTable;
      toggle3 = widget.server.getSub;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control It!'),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  height: 40.0,
                  width: 100.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: toggle3 ? Colors.blue : Colors.white,
                  ),
                  child: Stack(children: <Widget>[
                    AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                        top: 3.0,
                        left: toggle3 ? 60.0 : 0.0,
                        right: toggle3 ? 0.0 : 60.0,
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                toggle3 = !toggle3;
                              });
                              widget.server
                                  .postData('sub', toggle3 ? 'true' : 'false')
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
                              child: toggle3
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
                  height: 20,
                  width: 0,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 4),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      splashColor: Colors.blue,
                      icon: toggle1
                          ? Image.asset('assets/speakers/Ceiling_toggle_2.png')
                          : Image.asset('assets/speakers/Ceiling_toggle_1.png'),
                      iconSize: 200.0,
                      onPressed: () {
                        setState(() {
                          toggle1 = !toggle1;
                        });
                        widget.server
                            .postData('ceiling', toggle1 ? 'true' : 'false')
                            .then((String result) {
                          toast(result);
                        });
                      },
                    )),
                const SizedBox(
                  height: 300,
                  width: 0,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 4),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      splashColor: Colors.blue,
                      icon: toggle2
                          ? Image.asset('assets/speakers/Toggle_desktop_on.png')
                          : Image.asset(
                              'assets/speakers/Toggle_desktop_off.png'),
                      iconSize: 200.0,
                      onPressed: () {
                        setState(() {
                          toggle2 = !toggle2;
                        });
                        widget.server
                            .postData('table', toggle2 ? 'true' : 'false')
                            .then((String result) {
                          toast(result);
                        });
                      },
                    )),
              ],
            ),
          ]),
    );
  }
}
