import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home/Temppage.dart';
import 'package:home/speakers.dart';
import 'package:home/fan.dart';
import 'package:home/server.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(const MyApp());
}
final String title = "Control It!";

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        canvasColor: const Color(0xFF191818),
      ),
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool _toggle1 = false;
  bool _toggle2 = false;

  final Server _server = new Server();

  void _toast(message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  Future<void> _checkConnectivityState() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.wifi) {
      _server.fetchPosts().then((String result){
        setState(() {
          _toggle1 = _server.getLight1;
          _toggle2 = _server.getLight2;
        });
        if(result != "Data Fetching successful!"){
          showCupertinoModalPopup(context: context, builder:
              (context) => TempPage(message: "Error!\n\n Can't fetch data\n\n Make sure that the mobile device is connected to your local home network and the Arduino device is online"));
        }else{
          _toast(result);
        }
      });
    } else {
          showCupertinoModalPopup(context: context, builder:
              (context) => TempPage(message: "Error!\n\n Not connected to the home network\n Please connect to your home network and try again"));
    }
  }

  @override
  void initState() {
    _checkConnectivityState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                      icon: _toggle1
                          ? Image.asset('assets/lights/light_on_1000px.png')
                          : Image.asset('assets/lights/light_off_1000px.png'),
                      iconSize: 120.0,
                      onPressed: () {
                        setState(() {
                          _toggle1 = !_toggle1;
                        });
                        _server.postData('light1', _toggle1 ? 'true' : 'false').then((String result){
                          _toast(result);
                        });
                      },
                    )),
                const SizedBox(
                  height: 220,
                  width: 20,
                ),
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 4),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      splashRadius: 120,
                      splashColor: Colors.blue,
                      icon: _toggle2
                          ? Image.asset('assets/lights/light_on_1000px.png')
                          : Image.asset('assets/lights/light_off_1000px.png'),
                      iconSize: 120.0,
                      onPressed: () {
                        setState(() {
                          _toggle2 = !_toggle2;
                        });
                        _server.postData('light2', _toggle2 ? 'true' : 'false').then((String result){
                          _toast(result);
                        });
                      },
                    )),
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
                    splashRadius: 120,
                    splashColor: Colors.blue,
                    icon: Image.asset('assets/speakers/subwoofer_1000px.png'),
                    iconSize: 120.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  Speakers(title: widget.title,server: _server))
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 100,
                  width: 20,
                ),
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 4),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      splashRadius: 120,
                      splashColor: Colors.blue,
                      icon: Image.asset('assets/ceiling_fan_on_1000px.png'),
                      iconSize: 120.0,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Fan(title: widget.title,server: _server))
                        );
                      },
                    ))
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
                    splashRadius: 120,
                    splashColor: Colors.blue,
                    icon: Image.asset('assets/turn_off_all.jpg'),
                    iconSize: 120.0,
                    onPressed: () {
                      _server.postData('off', 'false').then((String result){
                        _toast(result);
                        setState(() {
                          _toggle1 = false;
                          _toggle2 = false;
                        });
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 220,
                  width: 0,
                ),
              ],
            ),
          ]),
    );
  }
}
