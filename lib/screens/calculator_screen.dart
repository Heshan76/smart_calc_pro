import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../widgets/calc_button.dart';
import 'bmi_screen.dart';
import 'scientific_screen.dart';
import 'converter_screen.dart';
import 'graph_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  bool _resetNext = false;

  static const Color _btnGray = Color(0xFFA5A5A5);
  static const Color _btnDarkGray = Color(0xFF333333);
  static const Color _btnOrange = Color(0xFFFF9F0A);

  void _handlePress(String text) {
    setState(() {
      if (text == 'AC') {
        _display = '0';
        _expression = '';
        _resetNext = false;
      } else if (text == '+/-') {
        if (_display != '0' && _display != 'Error') {
          _display = _display.startsWith('-') ? _display.substring(1) : '-$_display';
        }
      } else if (text == '%') {
        final val = double.tryParse(_display);
        if (val != null) {
          _display = (val / 100).toString();
        }
      } else if (['+', '-', '×', '÷'].contains(text)) {
        final op = text == '×' ? '*' : (text == '÷' ? '/' : text);
        _expression = '$_display $op ';
        _resetNext = true;
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
          if (!_display.contains('.')) {
            _display += '.';
          }
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
        elevation: 0,
        actions: [
          // Graphing Calculator Button
          IconButton(
            icon: const Icon(Icons.show_chart, color: Colors.white, size: 30),
            tooltip: 'Graphing Calculator',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GraphScreen()),
            ),
          ),
          // Unit Converter Button
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: Colors.white, size: 30),
            tooltip: 'Unit Converter',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConverterScreen()),
            ),
          ),
          // Scientific Mode Button
          IconButton(
            icon: const Icon(Icons.science_outlined, color: Colors.white, size: 28),
            tooltip: 'Scientific Calculator',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScientificScreen()),
            ),
          ),
          // BMI Mode Button
          IconButton(
            icon: const Icon(Icons.monitor_weight_outlined, color: Colors.white, size: 30),
            tooltip: 'BMI Calculator',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BmiScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Prominent Display Area
                Container(
                  height: 180,
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
                            style: const TextStyle(
                              fontSize: 32,
                              color: Color(0xFFA5A5A5),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _display,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 96,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Keypad Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(children: [
                            CalcButton(text: _display == '0' ? 'AC' : 'C', fillColor: _btnGray, textColor: Colors.black, onPressed: () => _handlePress('AC')),
                            CalcButton(text: '+/-', fillColor: _btnGray, textColor: Colors.black, onPressed: () => _handlePress('+/-')),
                            CalcButton(text: '%', fillColor: _btnGray, textColor: Colors.black, onPressed: () => _handlePress('%')),
                            CalcButton(text: '÷', fillColor: _btnOrange, textColor: Colors.white, onPressed: () => _handlePress('÷')),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            CalcButton(text: '7', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('7')),
                            CalcButton(text: '8', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('8')),
                            CalcButton(text: '9', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('9')),
                            CalcButton(text: '×', fillColor: _btnOrange, textColor: Colors.white, onPressed: () => _handlePress('×')),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            CalcButton(text: '4', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('4')),
                            CalcButton(text: '5', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('5')),
                            CalcButton(text: '6', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('6')),
                            CalcButton(text: '-', fillColor: _btnOrange, textColor: Colors.white, onPressed: () => _handlePress('-')),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            CalcButton(text: '1', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('1')),
                            CalcButton(text: '2', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('2')),
                            CalcButton(text: '3', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('3')),
                            CalcButton(text: '+', fillColor: _btnOrange, textColor: Colors.white, onPressed: () => _handlePress('+')),
                          ]),
                        ),
                        Expanded(
                          child: Row(children: [
                            CalcButton(text: '0', fillColor: _btnDarkGray, textColor: Colors.white, isWide: true, onPressed: () => _handlePress('0')),
                            CalcButton(text: '.', fillColor: _btnDarkGray, textColor: Colors.white, onPressed: () => _handlePress('.')),
                            CalcButton(text: '=', fillColor: _btnOrange, textColor: Colors.white, onPressed: () => _handlePress('=')),
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