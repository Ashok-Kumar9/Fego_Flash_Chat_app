import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {

  final Function onPressed;
  final String textOnButton;
  final Color color;

  RoundedButton({required this.textOnButton, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: (){onPressed();},
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            textOnButton,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
