import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../widgets/calc_button.dart';

class ScientificScreen extends StatefulWidget {
  const ScientificScreen({super.key});

  @override
  State<ScientificScreen> createState() => _ScientificScreenState();
}

class _ScientificScreenState extends State<ScientificScreen> {
  String _display = '0';
  String _expression = '';
  bool _resetNext = false;
  bool _isRad = true;

  static const Color _btnGray = Color(0xFFA5A5A5);
  static const Color _btnDarkGray = Color(0xFF333333);
  static const Color _btnSciGray = Color(0xFF242426);
  static const Color _btnOrange = Color(0xFFFF9F0A);

  double _factorial(double n) {
    if (n < 0 || n != n.floorToDouble()) return double.nan;
    if (n <= 1) return 1;
    double res = 1;
    for (int i = 2; i <= n.toInt(); i++) {
      res *= i;
    }
    return res;
  }

  void _handlePress(String text) {
    setState(() {
      if (text == 'AC') {
        _display = '0';
        _expression = '';
        _resetNext = false;
      } else if (text == 'Rad' || text == 'Deg') {
        _isRad = !_isRad;
      } else if (text == '+/-') {
        if (_display != '0' && _display != 'Error') {
          _display = _display.startsWith('-') ? _display.substring(1) : '-$_display';
        }
      } else if (text == '%') {
        final val = double.tryParse(_display);
        if (val != null) _display = (val / 100).toString();
      } else if (text == 'π') {
        _display = math.pi.toString();
        _resetNext = true;
      } else if (text == 'e') {
        _display = math.e.toString();
        _resetNext = true;
      } else if (text == 'x!') {
        final val = double.tryParse(_display);
        if (val != null) {
          final res = _factorial(val);
          _display = res.isNaN ? 'Error' : (res % 1 == 0 ? res.toInt().toString() : res.toString());
          _resetNext = true;
        }
      } else if (text == 'x²') {
        final val = double.tryParse(_display);
        if (val != null) {
          final res = val * val;
          _display = (res % 1 == 0) ? res.toInt().toString() : res.toString();
          _resetNext = true;
        }
      } else if (text == '√') {
        final val = double.tryParse(_display);
        if (val != null && val >= 0) {
          final res = math.sqrt(val);
          _display = (res % 1 == 0) ? res.toInt().toString() : res.toString();
          _resetNext = true;
        } else {
          _display = 'Error';
        }
      } else if (['sin', 'cos', 'tan', 'ln', 'log'].contains(text)) {
        final val = double.tryParse(_display);
        if (val != null) {
          double res = 0;
          final radVal = _isRad ? val : (val * math.pi / 180.0);
          switch (text) {
            case 'sin':
              res = math.sin(radVal);
              break;
            case 'cos':
              res = math.cos(radVal);
              break;
            case 'tan':
              res = math.tan(radVal);
              break;
            case 'ln':
              res = val > 0 ? math.log(val) : double.nan;
              break;
            case 'log':
              res = val > 0 ? (math.log(val) / math.ln10) : double.nan;
              break;
          }
          _display = res.isNaN ? 'Error' : (res % 1 == 0 ? res.toInt().toString() : res.toStringAsPrecision(8).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), ""));
          _resetNext = true;
        }
      } else if (['+', '-', '×', '÷', '^', '(', ')'].contains(text)) {
        if (text == '(' || text == ')') {
          _expression += text;
        } else {
          final op = text == '×' ? '*' : (text == '÷' ? '/' : text);
          _expression += '$_display $op ';
          _resetNext = true;
        }
      } else if (text == '=') {
        if (_expression.isNotEmpty) {
          final fullExp = '$_expression$_display'.replaceAll(' ', '');
          try {
            final exp = Parser().parse(fullExp);
            final res = exp.evaluate(EvaluationType.REAL, ContextModel());
            _display = (res % 1 == 0)
                ? res.toInt().toString()
                : res.toStringAsPrecision(8).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
          } catch (_) {
            _display = 'Error';
          }
          _expression = '';
          _resetNext = true;
        }
      } else {
        if (_display == '0' || _resetNext || _display == 'Error') {
          _display = (text == '.') ? '0.' : text;
          _resetNext = false;
        } else if (text == '.') {
          if (!_display.contains('.')) _display += '.';
        } else {
          _display += text;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Scientific', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Display Header
                Container(
                  height: 140,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_expression.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            _expression,
                            style: const TextStyle(fontSize: 24, color: Color(0xFFA5A5A5)),
                          ),
                        ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _display,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 72,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Keypad Layout (5-column scientific format)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(children: [
                            CalcButton(text: _isRad ? 'Rad' : 'Deg', fillColor: _btnSciGray, textColor: const Color(0xFFFF9F0A), onPressed: () => _handlePress(_isRad ? 'Rad' : 'Deg')),
                            CalcButton(text: '(', fillColor: _btnSciGray, textColor: Colors.white, onPressed: () => _handlePress('(')),
                            CalcButton(text: ')', fillColor: _btnSciGray, textColor: Colors.white, onPressed: () => _handlePress(')')),
                            CalcButton(text: _display == '0' ? 'AC' : 'C', fillColor: _btnGray, textColor: Colors.black, onPressed: () => _handlePress('AC')),
                            CalcButton(text: '÷', fillColor: _btnOrange, textColor: Colors.white, onPressed: () => _handlePress('÷')),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            CalcButton(text: 'sin', fillColor: _btnSciGray, textColor: Colors.white, onPressed: () => _handlePress('sin')),
                            CalcButton(text: 'ln', fillColor: _btnSciGray, textColor: Colors.white, onPressed: () => _handlePress('ln')),
                            CalcButton(text: '7', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('7')),
                            CalcButton(text: '8', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('8')),
                            CalcButton(text: '9', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('9')),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            CalcButton(text: 'cos', fillColor: _btnSciGray, textColor: Colors.white, onPressed: () => _handlePress('cos')),
                            CalcButton(text: 'log', fillColor: _btnSciGray, textColor: Colors.white, onPressed: () => _handlePress('log')),
                            CalcButton(text: '4', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('4')),
                            CalcButton(text: '5', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('5')),
                            CalcButton(text: '6', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('6')),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            CalcButton(text: 'tan', fillColor: _btnSciGray, textColor: Colors.white, onPressed: () => _handlePress('tan')),
                            CalcButton(text: '√', fillColor: _btnSciGray, textColor: Colors.white, onPressed: () => _handlePress('√')),
                            CalcButton(text: '1', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('1')),
                            CalcButton(text: '2', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('2')),
                            CalcButton(text: '3', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('3')),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            CalcButton(text: 'π', fillColor: _btnSciGray, textColor: Colors.white, onPressed: () => _handlePress('π')),
                            CalcButton(text: 'x²', fillColor: _btnSciGray, textColor: Colors.white, onPressed: () => _handlePress('x²')),
                            CalcButton(text: '0', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('0')),
                            CalcButton(text: '.', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('.')),
                            CalcButton(text: '=', fillColor: _btnOrange, textColor: Colors.white, onPressed: () => _handlePress('=')),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            CalcButton(text: 'e', fillColor: _btnSciGray, textColor: Colors.white, onPressed: () => _handlePress('e')),
                            CalcButton(text: 'x!', fillColor: _btnSciGray, textColor: Colors.white, onPressed: () => _handlePress('x!')),
                            CalcButton(text: '^', fillColor: _btnSciGray, textColor: Colors.white, onPressed: () => _handlePress('^')),
                            CalcButton(text: '×', fillColor: _btnOrange, textColor: Colors.white, onPressed: () => _handlePress('×')),
                            CalcButton(text: '-', fillColor: _btnOrange, textColor: Colors.white, onPressed: () => _handlePress('-')),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}