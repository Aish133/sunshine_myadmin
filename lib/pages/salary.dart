import 'package:flutter/material.dart';
void main() => runApp(Salary());
 class Salary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home
        : Scaffold(appBar
                   : AppBar(title
                            : Text("Container example"),
                           ),
                     body
                   : Container(child
                               : Text("i am inside a container!",
                                      style
                                      : TextStyle(fontSize : 20)),
                              ),
                          ), 
                       );
  }
}