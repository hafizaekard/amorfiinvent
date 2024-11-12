import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesData {
  const SalesData(this.year, this.sales);
  final String year;
  final double sales;
}

class DummyPage extends StatefulWidget {
  const DummyPage({super.key});

  @override
  State<DummyPage> createState() => _DummyPageState();
}

class _DummyPageState extends State<DummyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(height: 600, child: SfCartesianChart(
            // Initialize category axis
            primaryXAxis: const CategoryAxis(
              arrangeByIndex: true,
              axisLine: AxisLine(width: 0),
              // interval: 1,
              name: 'Year',
            ),

            series: [
              LineSeries<SalesData, String>(
                // Bind data source
                dataSource: const <SalesData>[
                  SalesData('Jan', 35),
                  SalesData('Feb', 28),
                  SalesData('Mar', 34),
                  SalesData('Apr', 32),
                  SalesData('May', 40),
                  SalesData('Jun', 50),
                  SalesData('Dec', 80)
                ],
                xValueMapper: (SalesData sales, _) => sales.year,
                yValueMapper: (SalesData sales, _) => sales.sales,
                // Enable data label
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),),
      ),
    );
  }
}