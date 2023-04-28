import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      '17°'; // Add this variable to store the temperature text
      late BluetoothConnection connection;

  List<bool> _switchValues = [true, true, true];
  String _selectedText = 'Peltier Plates';
  Color _selectedColor1 = Colors.white;
  Color _selectedColor2 = Colors.white;
  Color _selectedTextColor1 = Color(0xFFB3B3B3);
  Color _selectedTextColor2 = Colors.black;

   _MyAppState(){
    _connect();
  }

  bool get isConnected => (connection.isConnected);

  Future<void> _connect() async {
    try {
      connection = await BluetoothConnection.toAddress("00:21:07:00:07:EE");
      Fluttertoast.showToast( msg: 'Connected to the bluetooth device', );
      print('Connected to the bluetooth device');
      setState(() {
        //_connectedYesNo = "Connected.";
        //_colorConnectedYesNo = Colors.green;
        //_txtButtonCheckReload = "CHECK";
      });
    }
    catch (exception) {
      try {
        if (isConnected){
          Fluttertoast.showToast( msg: 'Already connected to the device', );
          print('Already connected to the device');
          setState(() {
            //_connectedYesNo = "Connected.";
            //_colorConnectedYesNo = Colors.green;
            //_txtButtonCheckReload = "CHECK";
          });
        }
        else{
          Fluttertoast.showToast( msg: 'Cannot connect, exception occured', );
          print('Cannot connect, exception occured');
          setState(() {
            //_connectedYesNo = "Not connected!";
            //_colorConnectedYesNo = Colors.red;
            //_txtButtonCheckReload = "RELOAD";
          });
        }
      }
      catch (e){
        Fluttertoast.showToast( msg: 'Cannot connect, probably not initialized connection', );
        print('Cannot connect, probably not initialized connection');
        setState(() {
          //_connectedYesNo = "Not connected!";
          //_colorConnectedYesNo = Colors.red;
          //_txtButtonCheckReload = "RELOAD";
        });
      }
    }
  }

  Future<void> _sendData(String data) async {
      connection.output.add(Uint8List.fromList(utf8.encode(data))); // Sending data
      await connection.output.allSent;
  }  


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
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(text == 'Peltier Plates' ? 25 : 0),
            bottomLeft: Radius.circular(text == 'Peltier Plates' ? 25 : 0),
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
      margin: EdgeInsets.all(5),
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
          if (index != 3)
            Positioned(
              top: 10,
              right: 10,
              child: Switch(
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFF1F5FD),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTab(
                      'Peltier Plates',
                      () {
                        _updateSelectedColors(
                            'Peltier Plates',
                            Color(0xFF22AFFF),
                            Colors.white,
                            Colors.white,
                            Color(0xFFB3B3B3));
                        setState(() {
                          _temperatureText =
                              '17°'; // Update the temperature text
                        });
                      },
                      _selectedColor1,
                      _selectedTextColor1,
                    ),
                    _buildTab(
                      'Body',
                      () {
                        _updateSelectedColors(
                            'Body',
                            Colors.white,
                            Color.fromARGB(255, 253, 181, 123),
                            Color(0xFFB3B3B3),
                            Colors.white);
                        setState(() {
                          _temperatureText =
                              '34°'; // Update the temperature text
                        });
                      },
                      _selectedColor2,
                      _selectedTextColor2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
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
                          _temperatureText, // Use the _temperatureText variable here
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
              Wrap(
                children: [
                  _buildSmallBox(0, FontAwesomeIcons.powerOff, 'Power',
                      Color.fromARGB(255, 179, 179, 179)),
                  _buildSmallBox(1, FontAwesomeIcons.bluetooth, 'Bluetooth',
                      Color.fromARGB(255, 108, 187, 233)),
                  _buildSmallBox(2, FontAwesomeIcons.fan, 'Cooling Fans',
                      Color.fromARGB(255, 223, 216, 153)),
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