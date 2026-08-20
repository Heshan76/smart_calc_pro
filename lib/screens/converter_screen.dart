import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  int _selectedCategory = 0; // 0: Length, 1: Weight, 2: Temperature

  final TextEditingController _fromCtrl = TextEditingController();
  final TextEditingController _toCtrl = TextEditingController();

  String _fromUnit = 'Meter';
  String _toUnit = 'Kilometer';

  final Map<String, double> _lengthFactors = {
    'Millimeter': 0.001,
    'Centimeter': 0.01,
    'Meter': 1.0,
    'Kilometer': 1000.0,
    'Inch': 0.0254,
    'Foot': 0.3048,
    'Yard': 0.9144,
    'Mile': 1609.344,
  };

  final Map<String, double> _weightFactors = {
    'Milligram': 0.000001,
    'Gram': 0.001,
    'Kilogram': 1.0,
    'Metric Ton': 1000.0,
    'Ounce': 0.0283495,
    'Pound (lbs)': 0.453592,
  };

  final List<String> _tempUnits = ['Celsius', 'Fahrenheit', 'Kelvin'];

  @override
  void initState() {
    super.initState();
    _updateCategoryDefaults(0);
  }

  void _updateCategoryDefaults(int index) {
    setState(() {
      _selectedCategory = index;
      _fromCtrl.clear();
      _toCtrl.clear();
      if (index == 0) {
        _fromUnit = 'Meter';
        _toUnit = 'Kilometer';
      } else if (index == 1) {
        _fromUnit = 'Kilogram';
        _toUnit = 'Pound (lbs)';
      } else {
        _fromUnit = 'Celsius';
        _toUnit = 'Fahrenheit';
      }
    });
  }

  void _convert() {
    final double? val = double.tryParse(_fromCtrl.text);
    if (val == null) {
      _toCtrl.clear();
      return;
    }

    double result = 0.0;

    if (_selectedCategory == 0) {
      // Length conversion via Base (Meters)
      final inMeters = val * (_lengthFactors[_fromUnit] ?? 1.0);
      result = inMeters / (_lengthFactors[_toUnit] ?? 1.0);
    } else if (_selectedCategory == 1) {
      // Weight conversion via Base (Kilograms)
      final inKg = val * (_weightFactors[_fromUnit] ?? 1.0);
      result = inKg / (_weightFactors[_toUnit] ?? 1.0);
    } else {
      // Temperature conversion
      if (_fromUnit == _toUnit) {
        result = val;
      } else if (_fromUnit == 'Celsius' && _toUnit == 'Fahrenheit') {
        result = (val * 9 / 5) + 32;
      } else if (_fromUnit == 'Celsius' && _toUnit == 'Kelvin') {
        result = val + 273.15;
      } else if (_fromUnit == 'Fahrenheit' && _toUnit == 'Celsius') {
        result = (val - 32) * 5 / 9;
      } else if (_fromUnit == 'Fahrenheit' && _toUnit == 'Kelvin') {
        result = (val - 32) * 5 / 9 + 273.15;
      } else if (_fromUnit == 'Kelvin' && _toUnit == 'Celsius') {
        result = val - 273.15;
      } else if (_fromUnit == 'Kelvin' && _toUnit == 'Fahrenheit') {
        result = (val - 273.15) * 9 / 5 + 32;
      }
    }

    _toCtrl.text = (result % 1 == 0)
        ? result.toInt().toString()
        : result.toStringAsPrecision(7).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  List<String> get _currentUnitList {
    if (_selectedCategory == 0) return _lengthFactors.keys.toList();
    if (_selectedCategory == 1) return _weightFactors.keys.toList();
    return _tempUnits;
  }

  Widget _buildUnitDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF2C2C2E),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF9F0A)),
          items: _currentUnitList
              .map((u) => DropdownMenuItem(value: u, child: Text(u)))
              .toList(),
          onChanged: (val) {
            onChanged(val);
            _convert();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Unit Converter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Category Segment Selector
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<int>(
                      backgroundColor: const Color(0xFF1C1C1E),
                      thumbColor: const Color(0xFFFF9F0A),
                      groupValue: _selectedCategory,
                      children: const {
                        0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Length', style: TextStyle(color: Colors.white))),
                        1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Weight', style: TextStyle(color: Colors.white))),
                        2: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Temp', style: TextStyle(color: Colors.white))),
                      },
                      onValueChanged: (val) {
                        if (val != null) _updateCategoryDefaults(val);
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // From Input Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('From', style: TextStyle(color: Colors.grey, fontSize: 16)),
                            _buildUnitDropdown(_fromUnit, (val) {
                              if (val != null) setState(() => _fromUnit = val);
                            }),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _fromCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w300),
                          decoration: const InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.white30),
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => _convert(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Swap Button
                  IconButton(
                    icon: const Icon(Icons.swap_vert_circle, color: Color(0xFFFF9F0A), size: 40),
                    onPressed: () {
                      setState(() {
                        final temp = _fromUnit;
                        _fromUnit = _toUnit;
                        _toUnit = temp;
                      });
                      _convert();
                    },
                  ),

                  const SizedBox(height: 16),

                  // To Output Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('To', style: TextStyle(color: Colors.grey, fontSize: 16)),
                            _buildUnitDropdown(_toUnit, (val) {
                              if (val != null) setState(() => _toUnit = val);
                            }),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _toCtrl,
                          readOnly: true,
                          style: const TextStyle(color: Color(0xFFFF9F0A), fontSize: 32, fontWeight: FontWeight.w400),
                          decoration: const InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.white30),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}