import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final TextEditingController _funcCtrl = TextEditingController(text: '2*x + 1');
  List<FlSpot> _spots = [];
  String? _errorMessage;

  double _minX = -10.0;
  double _maxX = 10.0;
  double _minY = -10.0;
  double _maxY = 10.0;

  @override
  void initState() {
    super.initState();
    _plotGraph();
  }

  void _plotGraph() {
    String input = _funcCtrl.text.trim().toLowerCase();

    // Clean up if user writes "y=" or "f(x)="
    if (input.startsWith('y=')) {
      input = input.substring(2).trim();
    } else if (input.startsWith('f(x)=')) {
      input = input.substring(5).trim();
    }

    if (input.isEmpty) {
      setState(() {
        _spots = [];
        _errorMessage = 'Please enter an expression';
      });
      return;
    }

    try {
      final parser = Parser();
      final exp = parser.parse(input);
      final ContextModel cm = ContextModel();
      final Variable xVar = Variable('x');

      List<FlSpot> points = [];
      const double step = 0.2;

      for (double x = _minX; x <= _maxX; x += step) {
        cm.bindVariable(xVar, Number(x));
        final double y = exp.evaluate(EvaluationType.REAL, cm);

        if (y.isFinite && !y.isNaN) {
          // Clamp points so extreme values don't break chart bounds
          if (y >= _minY * 2 && y <= _maxY * 2) {
            points.add(FlSpot(double.parse(x.toStringAsFixed(2)), double.parse(y.toStringAsFixed(2))));
          }
        }
      }

      setState(() {
        _spots = points;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _spots = [];
        _errorMessage = 'Invalid formula. Use format like 2*x + 1, x^2, sin(x)';
      });
    }
  }

  Widget _buildQuickTag(String label, String expr) {
    return ActionChip(
      backgroundColor: const Color(0xFF2C2C2E),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      onPressed: () {
        _funcCtrl.text = expr;
        _plotGraph();
      },
    );
  }

  @override
  void dispose() {
    _funcCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Graphing Calculator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Input Bar
                    Row(
                      children: [
                        const Text(
                          'y = ',
                          style: TextStyle(color: Color(0xFFFF9F0A), fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _funcCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            decoration: InputDecoration(
                              hintText: 'e.g., 2*x + 3, x^2 - 4',
                              hintStyle: const TextStyle(color: Colors.white30),
                              filled: true,
                              fillColor: const Color(0xFF1C1C1E),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => _plotGraph(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9F0A),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _plotGraph,
                          child: const Text('Plot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Quick presets
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickTag('y = 2x + 1', '2*x + 1'),
                          const SizedBox(width: 8),
                          _buildQuickTag('y = x²', 'x^2'),
                          const SizedBox(width: 8),
                          _buildQuickTag('y = -x² + 4', '-x^2 + 4'),
                          const SizedBox(width: 8),
                          _buildQuickTag('y = sin(x)', 'sin(x)'),
                          const SizedBox(width: 8),
                          _buildQuickTag('y = cos(x)', 'cos(x)'),
                        ],
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Cartesian Graph View
                    Container(
                      height: 380,
                      padding: const EdgeInsets.only(top: 20, right: 24, left: 10, bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2C2C2E)),
                      ),
                      child: _spots.isEmpty
                          ? const Center(
                              child: Text('No graph data to display', style: TextStyle(color: Colors.white38)),
                            )
                          : LineChart(
                              LineChartData(
                                minX: _minX,
                                maxX: _maxX,
                                minY: _minY,
                                maxY: _maxY,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  horizontalInterval: 2,
                                  verticalInterval: 2,
                                  getDrawingHorizontalLine: (val) => FlLine(
                                    color: val == 0 ? Colors.white54 : const Color(0xFF2C2C2E),
                                    strokeWidth: val == 0 ? 1.5 : 0.8,
                                  ),
                                  getDrawingVerticalLine: (val) => FlLine(
                                    color: val == 0 ? Colors.white54 : const Color(0xFF2C2C2E),
                                    strokeWidth: val == 0 ? 1.5 : 0.8,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 22,
                                      interval: 4,
                                      getTitlesWidget: (val, meta) => Text(
                                        val.toInt().toString(),
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      interval: 4,
                                      getTitlesWidget: (val, meta) => Text(
                                        val.toInt().toString(),
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: const Color(0xFF333333)),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _spots,
                                    isCurved: true,
                                    curveSmoothness: 0.1,
                                    color: const Color(0xFFFF9F0A),
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
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
        ),
      ),
    );
  }
}