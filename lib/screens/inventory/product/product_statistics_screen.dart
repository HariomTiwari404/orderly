import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orderly/components/components/blurred_card.dart';
import 'package:orderly/components/components/const.dart';
import 'package:orderly/models/product.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProductStatisticsScreen extends StatefulWidget {
  final Product product;

  const ProductStatisticsScreen({super.key, required this.product});

  @override
  _ProductStatisticsScreenState createState() =>
      _ProductStatisticsScreenState();
}

class _ProductStatisticsScreenState extends State<ProductStatisticsScreen> {
  late Timer _timer;
  late List<ChartData> _profitData;
  late List<ChartData> _investmentData;
  late List<ChartData> _revenueData;
  DateTime _lastUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    _profitData = _filterValidChartData(_getProfitData());
    _investmentData = _filterValidChartData(_getInvestmentData());
    _revenueData = _filterValidChartData(_getRevenueData());

    // Start a timer to update the chart every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _updateChartData();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateChartData() {
    DateTime now = DateTime.now();
    if (now.difference(_lastUpdateTime).inSeconds >= 1) {
      _lastUpdateTime = now;

      // Add a dummy data point to simulate time progression
      _profitData.add(
          ChartData(now, _profitData.isNotEmpty ? _profitData.last.amount : 0));
      _investmentData.add(ChartData(
          now, _investmentData.isNotEmpty ? _investmentData.last.amount : 0));
      _revenueData.add(ChartData(
          now, _revenueData.isNotEmpty ? _revenueData.last.amount : 0));

      // Remove old data to keep the chart focused on the recent time window
      if (_profitData.length > 100) _profitData.removeAt(0);
      if (_investmentData.length > 100) _investmentData.removeAt(0);
      if (_revenueData.length > 100) _revenueData.removeAt(0);
    }
  }

  List<ChartData> _filterValidChartData(List<ChartData> data) {
    return data
        .where((item) => !item.amount.isNaN && !item.amount.isInfinite)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: backgroundGradient,
            child: Column(
              children: [
                const SizedBox(
                    height:
                        120), // Adjust this to move content below the AppBar
                Expanded(
                  // Ensures full screen utilization
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummarySection(),
                          const SizedBox(height: 20),
                          _buildChartSection(),
                          const SizedBox(height: 20),
                          _buildAdditionalInsights(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 20, // Adjust as needed to position the AppBar correctly
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: SafeArea(
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                      title: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(
                            5.0), // Padding inside the container
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(20), // Rounded corners
                        ),
                        child: Text(
                          '${widget.product.name} Statistics',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return BlurredCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Overview',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const Divider(color: Colors.white),
            Text(
              'Total Quantity: ${widget.product.quantity}',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Profit: ₹${_calculateTotalProfit().toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 18, color: Color.fromARGB(255, 0, 255, 132)),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Investment: ₹${_calculateTotalInvestment().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, color: Colors.redAccent),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Revenue: ₹${_calculateTotalRevenue().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    if (_profitData.isEmpty ||
        _investmentData.isEmpty ||
        _revenueData.isEmpty) {
      return const Center(
        child: Text(
          'No data available for the charts',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    double minProfit =
        _profitData.map((data) => data.amount).reduce((a, b) => a < b ? a : b);
    double maxProfit =
        _profitData.map((data) => data.amount).reduce((a, b) => a > b ? a : b);
    double minInvestment = _investmentData
        .map((data) => data.amount)
        .reduce((a, b) => a < b ? a : b);
    double maxInvestment = _investmentData
        .map((data) => data.amount)
        .reduce((a, b) => a > b ? a : b);
    double minRevenue =
        _revenueData.map((data) => data.amount).reduce((a, b) => a < b ? a : b);
    double maxRevenue =
        _revenueData.map((data) => data.amount).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 400, // Fixed height for the chart
      child: BlurredCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SfCartesianChart(
            plotAreaBorderColor: Colors.transparent,
            zoomPanBehavior: ZoomPanBehavior(
              enablePanning: true,
              enablePinching: true,
              zoomMode: ZoomMode.x,
            ),
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat('MMM dd, HH:mm'),
              intervalType: DateTimeIntervalType.minutes, // For real-time feel
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
              labelStyle: TextStyle(color: Colors.grey[400]),
            ),
            primaryYAxis: NumericAxis(
              majorGridLines:
                  const MajorGridLines(width: 0.5, color: Colors.grey),
              axisLine: const AxisLine(width: 0),
              labelStyle: TextStyle(color: Colors.grey[400]),
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: '',
              format: 'point.x : point.y',
              textStyle: const TextStyle(color: Colors.black),
              color: Colors.white,
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
              textStyle: const TextStyle(color: Colors.white),
            ),
            series: <CartesianSeries>[
              LineSeries<ChartData, DateTime>(
                name: 'Profit',
                dataSource: _profitData,
                xValueMapper: (ChartData data, _) => data.time,
                yValueMapper: (ChartData data, _) => data.amount,
                pointColorMapper: (ChartData data, _) {
                  return interpolateColor(
                    data.amount,
                    minProfit,
                    maxProfit,
                    Colors.green,
                    const Color.fromARGB(255, 194, 215, 232),
                  );
                },
                enableTooltip: true,
                width: 3,
              ),
              LineSeries<ChartData, DateTime>(
                name: 'Investment',
                dataSource: _investmentData,
                xValueMapper: (ChartData data, _) => data.time,
                yValueMapper: (ChartData data, _) => data.amount,
                pointColorMapper: (ChartData data, _) {
                  return interpolateColor(
                    data.amount,
                    minInvestment,
                    maxInvestment,
                    Colors.red,
                    Colors.purple,
                  );
                },
                enableTooltip: true,
                width: 3,
              ),
              LineSeries<ChartData, DateTime>(
                name: 'Revenue',
                dataSource: _revenueData,
                xValueMapper: (ChartData data, _) => data.time,
                yValueMapper: (ChartData data, _) => data.amount,
                pointColorMapper: (ChartData data, _) {
                  return interpolateColor(
                    data.amount,
                    minRevenue,
                    maxRevenue,
                    Colors.blue,
                    Colors.cyan,
                  );
                },
                enableTooltip: true,
                width: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInsights() {
    return BlurredCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Insights',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const Divider(color: Colors.white),
            _buildInsightRow(
              'Total Units Sold:',
              widget.product.salesHistory
                  .fold<int>(
                    0,
                    (sum, sale) => sum + sale.quantitySold,
                  )
                  .toString(),
            ),
            const SizedBox(height: 10),
            _buildInsightRow(
              'Average Selling Price:',
              '₹${(_calculateTotalRevenue() / widget.product.salesHistory.fold<int>(1, (sum, sale) => sum + sale.quantitySold)).toStringAsFixed(2)}',
            ),
            const SizedBox(height: 10),
            _buildInsightRow(
              'Highest Investment Date:',
              _getHighestInvestmentDate(),
            ),
            const SizedBox(height: 10),
            _buildInsightRow(
              'Profit Margin:',
              _getProfitMargin(),
            ),
          ],
        ),
      ),
    );
  }

  String _getProfitMargin() {
    double totalInvestment = _calculateTotalInvestment();
    if (totalInvestment == 0) {
      return 'N/A'; // or '0%' if that's more appropriate for your use case
    }
    double profitMargin = (_calculateTotalProfit() / totalInvestment) * 100;
    return '${profitMargin.toStringAsFixed(2)}%';
  }

  Widget _buildInsightRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  double _calculateTotalProfit() {
    double totalProfit = 0;
    for (var sale in widget.product.salesHistory) {
      totalProfit +=
          (sale.sellingPrice - widget.product.costPrice) * sale.quantitySold;
    }
    return totalProfit;
  }

  double _calculateTotalInvestment() {
    double totalInvestment = 0;
    for (var investment in widget.product.investmentHistory) {
      totalInvestment += investment.amount;
    }
    return totalInvestment;
  }

  double _calculateTotalRevenue() {
    double totalRevenue = 0;
    for (var sale in widget.product.salesHistory) {
      totalRevenue += sale.sellingPrice * sale.quantitySold;
    }
    return totalRevenue;
  }

  String _getHighestInvestmentDate() {
    if (widget.product.investmentHistory.isEmpty) return 'N/A';
    var highestInvestment = widget.product.investmentHistory.reduce(
      (curr, next) => curr.amount > next.amount ? curr : next,
    );
    return DateFormat('MMM dd, yyyy').format(highestInvestment.date);
  }

  List<ChartData> _getProfitData() {
    double cumulativeProfit = 0;
    return widget.product.salesHistory.map((sale) {
      double profit =
          (sale.sellingPrice - widget.product.costPrice) * sale.quantitySold;
      if (profit.isNaN || profit.isInfinite) {
        profit = 0;
      }
      cumulativeProfit += profit;
      return ChartData(sale.date, cumulativeProfit);
    }).toList();
  }

  List<ChartData> _getInvestmentData() {
    double cumulativeInvestment = 0;
    return widget.product.investmentHistory.map((investment) {
      double amount = investment.amount;
      if (amount.isNaN || amount.isInfinite) {
        amount = 0;
      }
      cumulativeInvestment += amount;
      return ChartData(investment.date, cumulativeInvestment);
    }).toList();
  }

  List<ChartData> _getRevenueData() {
    double cumulativeRevenue = 0;
    return widget.product.salesHistory.map((sale) {
      double revenue = sale.sellingPrice * sale.quantitySold;
      if (revenue.isNaN || revenue.isInfinite) {
        revenue = 0;
      }
      cumulativeRevenue += revenue;
      return ChartData(sale.date, cumulativeRevenue);
    }).toList();
  }

  Color interpolateColor(double value, double minValue, double maxValue,
      Color startColor, Color endColor) {
    double t = (value - minValue) / (maxValue - minValue);
    return Color.lerp(startColor, endColor, t) ?? startColor;
  }
}

class ChartData {
  ChartData(this.time, this.amount);
  final DateTime time;
  final double amount;
}
