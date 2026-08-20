import 'package:flutter/material.dart';

class CalcButton extends StatelessWidget {
  final String text;
  final Color fillColor;
  final Color textColor;
  final VoidCallback onPressed;
  final bool isWide;

  const CalcButton({
    super.key,
    required this.text,
    required this.fillColor,
    required this.textColor,
    required this.onPressed,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: isWide ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SizedBox(
          height: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: fillColor,
              shape: isWide ? const StadiumBorder() : const CircleBorder(),
              padding: EdgeInsets.zero,
              elevation: 0,
            ),
            onPressed: onPressed,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 30,
                  color: textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}