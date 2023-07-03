import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:Overwatch/locationProvider.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overwatch',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static final Color colorError = Color(0xFFEA5454);
  static final Color colorSuccess = Color(0xFF29C66F);
  Timer t;
  TextEditingController ipController = TextEditingController(text: "192.168.10.101");
  RawDatagramSocket udpSocket;
  List<Widget> receivedMessages = List<Widget>();
  List<Widget> sentMessages = List<Widget>();

  int activationSteps = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose(){
    t.cancel();
    super.dispose();
  }

  startActivationSequence() async {
    setState(() {
      activationSteps = 0;
    });
    await Future.delayed(Duration(milliseconds: 1500));
    setState(() {
      activationSteps = 1;
    });
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      activationSteps = 2;
    });
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      activationSteps = 3;
    });
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      activationSteps = 4;
    });
  }

  pollLocationAndSendToServer({Duration d}) async {
      LocationData location = await LocationProvider.getLocation();
      udpSocket.send(new Utf8Codec().encode("${location.latitude.toString()},${location.longitude.toString()}"), InternetAddress(ipController.text), 9999);

      setState(() {
        if(sentMessages.length == 0) {
          sentMessages.add(Text("${location.latitude.toString()},${location.longitude.toString()}"));
        } else {
          sentMessages.insert(0, Text("${location.latitude.toString()},${location.longitude.toString()}"));
        }
      });
  }

  Future<void> connect(InternetAddress clientAddress, int port) async {
    await Future.wait([RawDatagramSocket.bind(clientAddress, 9999)]).then((values) {
      udpSocket = values[0];
      udpSocket.listen((RawSocketEvent e) {
        print(e);
        switch(e) {
          case RawSocketEvent.read :
            Datagram dg = udpSocket.receive();
            if(dg != null) {
              setState(() {
                receivedMessages.add(Text(Utf8Decoder().convert(dg.data)));
              });
            }
            udpSocket.writeEventsEnabled = true;
            break;
          case RawSocketEvent.write :
            //udpSocket.send(new Utf8Codec().encode('Hello from client'), clientAddress, port);
            break;
          case RawSocketEvent.closed :
            print('Client disconnected.');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SizedBox(
        height: screenSize.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 100,),
            SizedBox(
                height: 100,
                width: screenSize.width * 0.8,
                child: Center(child: Text("OVERWATCH",style: TextStyle(fontSize: 28, color: Colors.grey[100]),))),
            SizedBox(height: 100,),
            SizedBox(
                height: 100,
                child: TextField(
                  controller: ipController,
                )),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  activationSteps >= 0 ? _buildActivationSteps() : Container(),
                  SizedBox(height: 60,),
                  Center(
                    child: SizedBox(
                      height: 70,
                      width: screenSize.width * 0.8,
                      child: activationSteps >= 0 ? _buildLandButton() : _buildStartButton(),
                    ),
                  ),
                  SizedBox(height: 20,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return RaisedButton(
      color: colorSuccess,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      onPressed: () async {
        await connect(InternetAddress.anyIPv4, 9999);
        udpSocket.send(new Utf8Codec().encode("CONNECTION"), InternetAddress(ipController.text), 9999);
        startActivationSequence();
        setState(() {
          if(receivedMessages.length == 0) {
            receivedMessages.add(Text("Connected"));
          } else {
            receivedMessages.insert(0, Text("Connected"));
          }
        });
        t = Timer.periodic(Duration(milliseconds: 1000), (timer) {
          pollLocationAndSendToServer();
        });
      },
      child: Text("Activate", style: TextStyle(fontSize: 22),),
    );
  }

  Widget _buildActivationSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Overwatch dispatched", style: TextStyle(color: activationSteps >= 3 ? Colors.white : Colors.grey[500])),
              Theme(
                data: ThemeData(unselectedWidgetColor: activationSteps > 3 ? Colors.white : Colors.grey[500]),
                child: Checkbox(
                  activeColor: colorSuccess,
                  value: activationSteps > 3,
                  onChanged: (bool value) {  },
                ),
              )
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Calculating flight plan", style: TextStyle(color: activationSteps >= 2 ? Colors.white : Colors.grey[500])),
              Theme(
                data: ThemeData(unselectedWidgetColor: activationSteps > 2 ? Colors.white : Colors.grey[500]),
                child: Checkbox(
                  activeColor: colorSuccess,
                  value: activationSteps > 2,
                  onChanged: (bool value) {  },
                ),
              )
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Pre-flight checks", style: TextStyle(color: activationSteps >= 1 ? Colors.white : Colors.grey[500])),
              Theme(
                data: ThemeData(unselectedWidgetColor: activationSteps > 1 ? Colors.white : Colors.grey[500]),
                child: Checkbox(
                  activeColor: colorSuccess,
                  value: activationSteps > 1,
                  onChanged: (bool value) {  },
                ),
              )
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Connecting to Overwatch", style: TextStyle(color: activationSteps >= 0 ? Colors.white : Colors.grey[500]),),
              Theme(
                data: ThemeData(unselectedWidgetColor: activationSteps > 0 ? Colors.white : Colors.grey[500]),
                child: Checkbox(
                  activeColor: colorSuccess,
                  value: activationSteps > 0,
                  onChanged: (bool value) {  },

                ),
              )
            ],
          ),
        ),],
    );
  }

  Widget _buildLandButton() {
    return RaisedButton(
      color: colorError,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      onPressed: () async {
        setState(() {
          activationSteps = -1;
        });
        t.cancel();
        udpSocket.send(new Utf8Codec().encode("LAND"), InternetAddress(ipController.text), 9999);
        await Future.delayed(Duration(seconds: 1));
        udpSocket.send(new Utf8Codec().encode("LAND"), InternetAddress(ipController.text), 9999);
        await Future.delayed(Duration(seconds: 1));
        udpSocket.send(new Utf8Codec().encode("LAND"), InternetAddress(ipController.text), 9999);
        udpSocket.close();
      },
      child: Text("Land", style: TextStyle(fontSize: 22)),
    );
  }
}
