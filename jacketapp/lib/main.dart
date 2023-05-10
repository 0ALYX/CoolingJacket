import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//added dependencies then import
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _temperatureText =
      '00°'; // Add this variable to store the temperature text
    //initialized bluetooth variable
  late BluetoothConnection _connection;
  List<int> data = []; ////////////////
   double temperature_body = 00.0;


  String _connectedYesNo = "Loading...";
  Color _colorConnectedYesNo = Colors.black;
  String _txtButtonCheckReload = "CHECK";

  List<bool> _switchValues = [true, true, true];
  String _selectedText = ' ';
  Color _selectedColor1 = Colors.white;
  Color _selectedColor2 = Colors.white;
  Color _selectedTextColor1 = Colors.black;
  Color _selectedTextColor2 = Colors.black;

  _MyAppState() {
    _connect();
  }

  //bluetooth connection (if able to connect)
  bool get isConnected => (_connection.isConnected);

  Future<void> _connect() async {
    try {
      //if true then connected if false then display message
       BluetoothConnection connection = await BluetoothConnection.toAddress("98:D3:91:FE:48:71");
      
      Fluttertoast.showToast(
        msg: 'Connected to the bluetooth device',
      );
      print('Connected to the bluetooth device');
      setState(() {
        _connectedYesNo = "Connected.";
        _connection = connection;
        
        //_colorConnectedYesNo = Colors.green;
        //_txtButtonCheckReload = "CHECK";
      
      });
      _connection.input?.listen(onDataReceived);
      
    } catch (exception) {
      try {
        if (isConnected) {
          Fluttertoast.showToast(
            msg: 'Already connected to the device',
          );
          print('Already connected to the device');
          setState(() {
            _connectedYesNo = "Connected.";
            //_colorConnectedYesNo = Colors.green;
            //_txtButtonCheckReload = "CHECK";
          });
        } else {
          Fluttertoast.showToast(
            msg: 'Cannot connect, exception occured',
          );
          print('Cannot connect, exception occured');
          setState(() {
            _connectedYesNo = "Not connected!";
            //_colorConnectedYesNo = Colors.red;
            //_txtButtonCheckReload = "RELOAD";
          }
          
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Cannot connect, probably not initialized connection',
        );
        print('Cannot connect, probably not initialized connection');
        setState(() {
          _connectedYesNo = "Not connected!";
          //_colorConnectedYesNo = Colors.red;
          //_txtButtonCheckReload = "RELOAD";
        });
      }
    }
  }

  void waitLoading() {
    setState(() {
      //_connectedYesNo = "Loading...";
      //_colorConnectedYesNo = Colors.black;
      //_txtButtonCheckReload = "CHECK";
    });
  }

  void _reloadOrCheck() {
    waitLoading();
    _connect();
  }

  Future<void> _sendData(String data) async {
    _connection.output
        .add(Uint8List.fromList(utf8.encode(data))); // Sending data
    await _connection.output.allSent;
  }
  
  //switches
  void _setSwitchState(int _switchType) {
    if (_connectedYesNo == "Connected.") {
      setState(() {
        if (_switchType == 0) {
          _sendData("b");
        } 
        else if (_switchType == 1) {
          _sendData("a");
        }
        // else if (_switchType == 2) {
        //   if (_bulbImgPathChildrensRoom == "images/light_off.png" &&
        //       _clrButtonChildrensRoom == Colors.green &&
        //       _txtButtonChildrensRoom == "TURN ON") {
        //     //_bulbImgPathChildrensRoom = "images/light_on.png";
        //     //_clrButtonChildrensRoom = Colors.red;
        //     //_txtButtonChildrensRoom = "TURN OFF";
        //     _sendData("e");
        //   } else {
        //     //_bulbImgPathChildrensRoom = "images/light_off.png";
        //     //_clrButtonChildrensRoom = Colors.green;
        //     //_txtButtonChildrensRoom = "TURN ON";
        //     _sendData("f");
        //   }
        // } else if (_switchType == 3) {
        //   if (_bulbImgPathKitchen == "images/light_off.png" &&
        //       _clrButtonKitchen == Colors.green &&
        //       _txtButtonKitchen == "TURN ON") {
        //     //_bulbImgPathKitchen = "images/light_on.png";
        //     //_clrButtonKitchen = Colors.red;
        //     //_txtButtonKitchen = "TURN OFF";
        //     _sendData("g");
        //   } else {
        //     //_bulbImgPathKitchen = "images/light_off.png";
        //     //_clrButtonKitchen = Colors.green;
        //     //_txtButtonKitchen = "TURN ON";
        //     _sendData("h");
        //   }
        // }
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Cannot send data!\nYou are not connected.',
      );
    }
  }

/////////////////////////////////////////////////////////////////////

  void _updateSelectedColors(String text, Color color1, Color color2,
      Color textColor1, Color textColor2) {
    setState(() {
      _selectedText = text;
      _selectedColor1 = color1;
      _selectedColor2 = color2;
      _selectedTextColor1 = textColor1;
      _selectedTextColor2 = textColor2;
    });
  }

  GestureDetector _buildTab(
      String text, VoidCallback onTap, Color backgroundColor, Color textColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(text == 'Body' ? 25 : 0),
            bottomLeft: Radius.circular(text == 'Body' ? 25 : 0),
            topRight: Radius.circular(text == 'Body' ? 25 : 0),
            bottomRight: Radius.circular(text == 'Body' ? 25 : 0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallBox(
      int index, IconData icon, String text, Color backgroundColor) {
    return Container(
      margin: const EdgeInsets.all(5),
      width: 151,
      height: 107,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: backgroundColor,
      ),
      child: Stack(
        children: [
          Positioned(
              top: 10,
              left: 10,
              child: Icon(icon, size: 24, color: Colors.white)),
          if (index != 2 && index != 3)
            Positioned(
              top: 10,
              right: 10,
              child: Switch(
                ///////////////////////
                value: _switchValues[index],
                onChanged: (bool value) =>
                    setState(() => _switchValues[index] = value),
              ),
            ),
          Positioned(
              bottom: 10,
              left: 10,
              child: Text(text,
                  style: TextStyle(fontSize: 18, color: Colors.white))),
        ],
      ),
    );
  }
///////////need accurate data
void onDataReceived(List<int> data) {
  String message = String.fromCharCodes(data).trim();
  print('Received data: $message');

  setState(() {
    temperature_body = double.tryParse(message) ?? temperature_body;
  });
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFF1F5FD),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                   
                    _buildTab(
                      'Body',
                      () {
                        _updateSelectedColors(
                            'Body',
                            Colors.white,
                            Color.fromARGB(255, 253, 181, 123),
                            Color(0xFFB3B3B3),
                            Colors.white);
                        /*setState(() {
                          ///////////////////
                          _temperatureText =
                              (String.fromCharCodes(data)); // Update the temperature text
                        });*/
                      },
                      _selectedColor2,
                      _selectedTextColor2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              //Small boxes
              Container(
                width: 324,
                height: 193,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: _selectedColor1,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: _selectedColor1 == Color(0xFF22AFFF)
                        ? Color(0xFF22AFFF)
                        : Color(0xFFFFA184),
                  ),
                  child: SizedBox(
                    width: 324,
                    height: 193,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedText,
                          style: TextStyle(
                              fontSize: 20,
                              color: _selectedColor1 == Color(0xFF22AFFF)
                                  ? _selectedTextColor1
                                  : Colors.white),
                        ),
                        Text(
                          '${temperature_body.toStringAsFixed(2)}°C', // Use the _temperatureText variable here
                          style: TextStyle(
                              fontSize: 75,
                              color: _selectedColor1 == Color(0xFF22AFFF)
                                  ? _selectedTextColor1
                                  : Colors.white),
                        ),
                        Text(
                          'Current Temperature',
                          style: TextStyle(
                              fontSize: 15,
                              color: _selectedColor1 == Color(0xFF22AFFF)
                                  ? _selectedTextColor1
                                  : Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                children: [
                  _buildSmallBox(0, FontAwesomeIcons.powerOff, 'Power',
                      Color.fromARGB(255, 179, 179, 179)),
                  _buildSmallBox(1, FontAwesomeIcons.fan, 'Cooling Fans',
                      Color.fromARGB(255, 223, 216, 153)),
                  _buildSmallBox(2, FontAwesomeIcons.bluetooth, _connectedYesNo,
                      Color.fromARGB(255, 108, 187, 233)),
                  _buildSmallBox(3, FontAwesomeIcons.batteryEmpty, 'Battery',
                      Color.fromARGB(255, 171, 214, 153)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
