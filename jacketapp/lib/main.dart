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
  //String _temperatureText = '00°'; // Add this variable to store the temperature text
    //initialized bluetooth variable
  late BluetoothConnection _connection;
  List<int> data = []; ////////////////
  //double temperature_body = 00.0;


  String _connectedYesNo = "Loading...";
  Color _colorConnectedYesNo = Colors.black;
  String _txtButtonCheckReload = "CHECK";

  List<bool> _switchValues = [true, false];
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
        _connectedYesNo = "Connected";
        _connection = connection;
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
            _connectedYesNo = "Connected";
          });
        } else {
          Fluttertoast.showToast(
            msg: 'Cannot connect, exception occured',
          );
          print('Cannot connect, exception occured');
          setState(() {
            _connectedYesNo = "Not connected!";
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
    if (_connectedYesNo == "Connected") {
      setState(() {
        if (_switchValues[0]) {
          _sendData("b");
          debugPrint("Sent data: b");
          Text(
            selectedTab == 'Peltier Plates'
                ? '0.00°C'
                : '0.00°C',
            style: TextStyle(
                fontSize: 75,
                color: selectedTab == 'Peltier Plates'
                    ? Colors.grey
                    : Colors.grey),
          );
        }
         else {
          _sendData("a");
          debugPrint("Sent data: a");
          Text(
            selectedTab == 'Peltier Plates'
                ? '${peltierTemperature.toStringAsFixed(2)}°C'
                : '${bodyTemperature.toStringAsFixed(2)}°C',
            style: TextStyle(
                fontSize: 75,
                color: selectedTab == 'Peltier Plates'
                    ? Colors.white
                    : Colors.white),
          );
        }

        if (_switchValues[1]) {
          _sendData("a");
          debugPrint("Sent data: a");
        }
         else {
          _sendData("b");
          debugPrint("Sent data: b");
        }
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Cannot control fans!\nYou are not connected.',
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
        constraints: BoxConstraints(minWidth: 0, maxWidth: 150),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.3),
          //     offset: Offset(0, 4),
          //     blurRadius: 10,
          //     spreadRadius: 0,
          //   ),
          // ],
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(text == 'Peltier Plates' ? 25 : 0),
            bottomLeft: Radius.circular(text == 'Peltier Plates' ? 25 : 0),
            topRight: Radius.circular(text == 'Body' ? 25 : 0),
            bottomRight: Radius.circular(text == 'Body' ? 25 : 0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBox(
    int index, IconData icon, String text, Color backgroundColor) {
    return Container(
      margin: const EdgeInsets.all(5),
      width: 300,
      height: 107,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: backgroundColor,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 15,
            left: 15,
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          if (index != 2 && index != 3)
            Positioned(
              top: 10,
              right: 10,
              child: Switch(
                value: _switchValues[index],
                onChanged: (bool value) {
                  setState(() {
                    _switchValues[index] = value;
                  });
                  _setSwitchState(index);
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withOpacity(0.5),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.5),
              ),
            ),
          Positioned(
            bottom: 15,
            left: 15,
            child: Text(text,
                style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  ///////////need to split diff data///
  String receivedData = '';
  double peltierTemperature = 0.0;
  double bodyTemperature = 0.0;
  Timer? debounceTimer;

  void onDataReceived(List<int> data) {
    String message = String.fromCharCodes(data).trim();
    receivedData += message;
    print('Received data: $receivedData');

    if (debounceTimer != null && debounceTimer!.isActive) {
      debounceTimer!.cancel();
    }
    debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (receivedData.contains(',')) {
        List<String> readings = receivedData.split(',');

        if (readings.length >= 2) {
          String temp1String = readings[0].trim();
          String temp2String = readings[1].trim();

          double? parsedTemp1 = double.tryParse(temp1String);
          double? parsedTemp2 = double.tryParse(temp2String);

          if (parsedTemp1 != null && parsedTemp2 != null) {
            setState(() {
              peltierTemperature = parsedTemp1;
              bodyTemperature = parsedTemp2;
            });
          }
        }
        receivedData = ''; // Reset the receivedData variable after parsing the values
      }
    });
  }

  Widget _buildShadowedBox(Widget child) {
    return Container(
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            spreadRadius: 0,
            blurRadius: 11,
            offset: Offset(1, 5),
          ),
        ],
      ),
      child: child,
    );
  }


  String selectedTab = 'Peltier Plates';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Cooling Jacket',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color:Colors.white,
              ),
            ),
          ),
          elevation: 0,
          backgroundColor: selectedTab == 'Peltier Plates'
                ? Color(0xFF22AFFF)
                : Color(0xFFFFA184),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    _buildTab(
                      'Peltier Plates',
                      () {
                        setState(() {
                          selectedTab = 'Peltier Plates';
                        });
                      },
                      selectedTab == 'Peltier Plates'
                          ? Color(0xFF22AFFF)
                          : Color.fromARGB(255, 230, 229, 229),
                      selectedTab == 'Peltier Plates'
                          ? Colors.white
                          : Color.fromARGB(255, 122, 122, 122),
                    ),
                    _buildTab(
                      'Body',
                      () {
                        setState(() {
                          selectedTab = 'Body';
                        });
                      },
                      selectedTab == 'Body'
                          ? Color(0xFFFFA184)
                          : Color.fromARGB(255, 230, 229, 229),
                      selectedTab == 'Body'
                          ? Colors.white 
                          : Color.fromARGB(255, 122, 122, 122),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Small boxes
              Container(
                width: 324,
                height: 193,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: selectedTab == 'Peltier Plates'
                      ? Color(0xFF22AFFF)
                      : Color(0xFFFFA184),
                  boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 4),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: selectedTab == 'Peltier Plates'
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
                          selectedTab == 'Peltier Plates'
                              ? 'Peltier Temperature'
                              : 'Body Temperature',
                          style: TextStyle(
                              fontSize: 21,
                              color: selectedTab == 'Peltier Plates'
                                  ? Colors.white
                                  : Colors.white),
                        ),
                        Text(
                          selectedTab == 'Peltier Plates'
                              ? '${peltierTemperature.toStringAsFixed(2)}°C'
                              : '${bodyTemperature.toStringAsFixed(2)}°C',
                          style: TextStyle(
                              fontSize: 75,
                              color: selectedTab == 'Peltier Plates'
                                  ? Colors.white
                                  : Colors.white),
                        ),
                        Text(
                          'Current Temperature',
                          style: TextStyle(
                              fontSize: 17,
                              color: selectedTab == 'Peltier Plates'
                                  ? Colors.white
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
                  _buildShadowedBox(
                    _buildSmallBox(
                      0,
                      FontAwesomeIcons.powerOff,
                      'Power',
                      Color.fromARGB(255, 147, 204, 122),
                    ),
                  ),
                  _buildShadowedBox(
                    _buildSmallBox(
                      1,
                      FontAwesomeIcons.fan,
                      'Cooling Fans',
                      Color.fromARGB(255, 237, 171, 117),
                    ),
                  ),
                  _buildShadowedBox(
                    _buildSmallBox(
                      2,
                      FontAwesomeIcons.bluetooth,
                      _connectedYesNo,
                      Color.fromARGB(255, 104, 180, 223),
                    ),
                  ),
                    // _buildShadowedBox(
                    //   _buildSmallBox(
                    //     3,
                    //     FontAwesomeIcons.batteryEmpty,
                    //     'Battery',
                    //     Color.fromARGB(255, 171, 214, 153),
                    //   ),
                    // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
