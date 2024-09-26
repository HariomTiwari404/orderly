import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:orderly/components/components/blurred_card.dart';
import 'package:orderly/components/components/const.dart';
import 'package:orderly/database_helper.dart';
import 'package:orderly/models/product.dart';
import 'package:orderly/screens/inventory/product/product_statistics_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  double totalInvestment = 0;
  double totalProfit = 0;
  double totalRevenue = 0;
  List<Product> mostSoldProducts = [];
  List<Product> mostProfitableProducts = [];

  @override
  void initState() {
    super.initState();
    _calculateCombinedStatistics();
  }

  Future<void> _calculateCombinedStatistics() async {
    final inventories = await DatabaseHelper().fetchInventories();
    double investment = 0;
    double profit = 0;
    double revenue = 0;
    List<Product> products = [];

    for (var inventory in inventories) {
      final fetchedProducts =
          await DatabaseHelper().fetchProducts(inventory.id!);
      for (var product in fetchedProducts) {
        investment += _calculateTotalInvestment(product);
        profit += _calculateTotalProfit(product);
        revenue += _calculateTotalRevenue(product);
        products.add(product);
      }
    }

    // Sort products by quantity sold and get the top 5
    products.sort((a, b) => _calculateTotalQuantitySold(b)
        .compareTo(_calculateTotalQuantitySold(a)));
    mostSoldProducts = products.take(5).toList();

    // Sort products by profit and get the top 5
    products.sort(
        (a, b) => _calculateTotalProfit(b).compareTo(_calculateTotalProfit(a)));
    mostProfitableProducts = products.take(5).toList();

    setState(() {
      totalInvestment = investment;
      totalProfit = profit;
      totalRevenue = revenue;
    });
  }

  double _calculateTotalInvestment(Product product) {
    double totalInvestment = 0;
    for (var investment in product.investmentHistory) {
      totalInvestment += investment.amount;
    }
    return totalInvestment;
  }

  double _calculateTotalProfit(Product product) {
    double totalProfit = 0;
    for (var sale in product.salesHistory) {
      totalProfit +=
          (sale.sellingPrice - product.costPrice) * sale.quantitySold;
    }
    return totalProfit;
  }

  double _calculateTotalRevenue(Product product) {
    double totalRevenue = 0;
    for (var sale in product.salesHistory) {
      totalRevenue += sale.sellingPrice * sale.quantitySold;
    }
    return totalRevenue;
  }

  int _calculateTotalQuantitySold(Product product) {
    return product.salesHistory.fold(0, (sum, sale) => sum + sale.quantitySold);
  }

  void _navigateToProductStatistics(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductStatisticsScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: backgroundGradient,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                        height:
                            50), // Adjust this to move content below the AppBar
                    _buildSummarySection(),
                    const SizedBox(height: 10),
                    _buildPieChartSection(),
                    const SizedBox(height: 10),
                    _buildMostSoldProductsSection(),
                    const SizedBox(height: 20),
                    _buildMostProfitableProductsSection(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 1, // Adjust as needed to position the AppBar correctly
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
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10.0),
                        decoration: const BoxDecoration(),
                        child: Lottie.network(
                          'https://lottie.host/a0814928-e9e9-4b9f-8696-edd13dd35b21/lCS1oX14SF.json',
                          width: 60,
                          height: 30,
                          fit: BoxFit.cover,
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
              'Overall Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.white70),
            Text(
              'Total Investment: ₹${totalInvestment.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Profit: ₹${totalProfit.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Revenue: ₹${totalRevenue.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartSection() {
    return SizedBox(
      height: 400,
      child: BlurredCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SfCircularChart(
            legend: Legend(
              isVisible: true,
              overflowMode: LegendItemOverflowMode.wrap,
              position: LegendPosition.bottom,
            ),
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: _getPieChartData(),
                xValueMapper: (ChartData data, _) => data.category,
                yValueMapper: (ChartData data, _) => data.amount,
                pointColorMapper: (ChartData data, _) {
                  switch (data.category) {
                    case 'Investment':
                      return Colors.red;
                    case 'Profit':
                      return Colors.green;
                    case 'Revenue':
                      return Colors.blue;
                    default:
                      return Colors.grey;
                  }
                },
                dataLabelMapper: (ChartData data, _) =>
                    '${data.category}: ₹${data.amount.toStringAsFixed(2)}',
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  useSeriesColor: true,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<ChartData> _getPieChartData() {
    return [
      ChartData('Investment', totalInvestment),
      ChartData('Profit', totalProfit),
      ChartData('Revenue', totalRevenue),
    ];
  }

  Widget _buildMostSoldProductsSection() {
    return mostSoldProducts.isEmpty
        ? const Text('No sales data available.')
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top 5 Most Sold Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...mostSoldProducts.map((product) {
                return BlurredCard(
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                          'Total Sold: ${_calculateTotalQuantitySold(product)} units'),
                      trailing: Text(
                          'Revenue: ₹${_calculateTotalRevenue(product).toStringAsFixed(2)}'),
                      onTap: () => _navigateToProductStatistics(product),
                    ),
                  ),
                );
              }),
            ],
          );
  }

  Widget _buildMostProfitableProductsSection() {
    return mostProfitableProducts.isEmpty
        ? const Text('No sales data available.')
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top 5 Most Profitable Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...mostProfitableProducts.map((product) {
                return BlurredCard(
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                          'Total Profit: ₹${_calculateTotalProfit(product).toStringAsFixed(2)}'),
                      trailing: Text(
                          'Revenue: ₹${_calculateTotalRevenue(product).toStringAsFixed(2)}'),
                      onTap: () => _navigateToProductStatistics(product),
                    ),
                  ),
                );
              }),
            ],
          );
  }
}

class ChartData {
  ChartData(this.category, this.amount);
  final String category;
  final double amount;
}
