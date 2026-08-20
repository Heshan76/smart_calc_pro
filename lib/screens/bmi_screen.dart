import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String _heightUnit = 'cm'; // cm, m, ft, in
  String _weightUnit = 'kg'; // kg, g, lbs

  double? _bmi;
  String _resultText = '';
  Color _statusColor = Colors.white;

  void _calculate() {
    final double? rawHeight = double.tryParse(_heightCtrl.text);
    final double? rawWeight = double.tryParse(_weightCtrl.text);

    if (rawHeight == null || rawWeight == null || rawHeight <= 0 || rawWeight <= 0) return;

    // Convert height to meters
    double heightInMeters;
    switch (_heightUnit) {
      case 'cm':
        heightInMeters = rawHeight / 100;
        break;
      case 'm':
        heightInMeters = rawHeight;
        break;
      case 'ft':
        heightInMeters = rawHeight * 0.3048;
        break;
      case 'in':
        heightInMeters = rawHeight * 0.0254;
        break;
      default:
        heightInMeters = rawHeight / 100;
    }

    // Convert weight to kg
    double weightInKg;
    switch (_weightUnit) {
      case 'kg':
        weightInKg = rawWeight;
        break;
      case 'g':
        weightInKg = rawWeight / 1000;
        break;
      case 'lbs':
        weightInKg = rawWeight * 0.45359237;
        break;
      default:
        weightInKg = rawWeight;
    }

    final bmi = weightInKg / (heightInMeters * heightInMeters);

    setState(() {
      _bmi = bmi;
      if (bmi < 18.5) {
        _resultText = 'Underweight';
        _statusColor = Colors.amber;
      } else if (bmi < 25.0) {
        _resultText = 'Normal weight';
        _statusColor = Colors.greenAccent;
      } else if (bmi < 30.0) {
        _resultText = 'Overweight';
        _statusColor = const Color(0xFFFF9F0A);
      } else {
        _resultText = 'Obese';
        _statusColor = Colors.redAccent;
      }
    });
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('BMI Calculator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEIGHT SECTION ---
                  const Text('Height', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _heightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'Enter height in $_heightUnit',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1C1C1E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<String>(
                      backgroundColor: const Color(0xFF2C2C2E),
                      thumbColor: const Color(0xFFFF9F0A),
                      groupValue: _heightUnit,
                      children: const {
                        'cm': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('cm', style: TextStyle(color: Colors.white))),
                        'm': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('m', style: TextStyle(color: Colors.white))),
                        'ft': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('foot', style: TextStyle(color: Colors.white))),
                        'in': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('inch', style: TextStyle(color: Colors.white))),
                      },
                      onValueChanged: (val) {
                        if (val != null) {
                          setState(() => _heightUnit = val);
                          if (_bmi != null) _calculate();
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- WEIGHT SECTION ---
                  const Text('Weight', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'Enter weight in $_weightUnit',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1C1C1E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<String>(
                      backgroundColor: const Color(0xFF2C2C2E),
                      thumbColor: const Color(0xFFFF9F0A),
                      groupValue: _weightUnit,
                      children: const {
                        'kg': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('kg', style: TextStyle(color: Colors.white))),
                        'g': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('g', style: TextStyle(color: Colors.white))),
                        'lbs': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('lbs', style: TextStyle(color: Colors.white))),
                      },
                      onValueChanged: (val) {
                        if (val != null) {
                          setState(() => _weightUnit = val);
                          if (_bmi != null) _calculate();
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Calculate Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9F0A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _calculate,
                      child: const Text('Calculate BMI', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  // Result display
                  if (_bmi != null) ...[
                    const SizedBox(height: 36),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _bmi!.toStringAsFixed(1),
                            style: TextStyle(fontSize: 64, fontWeight: FontWeight.w300, color: _statusColor),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _resultText,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: _statusColor),
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}