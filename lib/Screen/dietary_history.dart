import 'package:flutter/material.dart';
import 'package:glycosnap/Screen/meal_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DietaryHistory extends StatefulWidget {
  const DietaryHistory({super.key});

  @override
  State<DietaryHistory> createState() => _DietaryHistoryState();
}

class _DietaryHistoryState extends State<DietaryHistory> {
  String selectedPeriod = 'Week';
  final List<String> periods = ['Week', 'Month', 'Year'];

  @override
  void initState() {
    super.initState();
    // Fetch meals when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MealProvider>(context, listen: false).fetchMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final mealProvider = Provider.of<MealProvider>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.surface,
        toolbarHeight: 80,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Dietary History',
          style: TextStyle(
            fontFamily: 'OpenSauce',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<MealProvider>(context, listen: false).fetchMeals();
        },
        child: mealProvider.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period Selector
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.02),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: periods.map((period) {
                            final isSelected = period == selectedPeriod;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPeriod = period;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04,
                                  vertical: size.height * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  period,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : colorScheme.onSurface,
                                    fontFamily: 'Poppins',
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),

                      // Glycemic Load Chart
                      Container(
                        padding: EdgeInsets.all(size.width * 0.04),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Glycemic Load Trend',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: size.height * 0.02),
                            SizedBox(
                              height: size.height * 0.3,
                              child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(
                                  labelStyle: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                primaryYAxis: NumericAxis(
                                  labelStyle: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                series: <CartesianSeries<ChartData, String>>[
                                  LineSeries<ChartData, String>(
                                    dataSource: _getChartData(mealProvider),
                                    xValueMapper: (ChartData data, _) =>
                                        data.date,
                                    yValueMapper: (ChartData data, _) =>
                                        data.value,
                                    color: colorScheme.primary,
                                    markerSettings: MarkerSettings(
                                      isVisible: true,
                                      shape: DataMarkerType.circle,
                                      color: colorScheme.primary,
                                      borderWidth: 2,
                                      borderColor: colorScheme.surface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),

                      // Meal History
                      Text(
                        'Meal History',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      _buildMealHistoryList(mealProvider, size, colorScheme),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  List<ChartData> _getChartData(MealProvider mealProvider) {
    final allMeals = [
      ...mealProvider.breakfast,
      ...mealProvider.lunch,
      ...mealProvider.supper,
    ];

    // Group meals by date
    final Map<String, double> dailyTotals = {};
    for (var meal in allMeals) {
      final date = DateFormat('MMM d').format(DateTime.parse(meal.createdAt));
      dailyTotals[date] = (dailyTotals[date] ?? 0) + meal.glycemicLoad;
    }

    // Convert to chart data
    return dailyTotals.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
  }

  Widget _buildMealHistoryList(
      MealProvider mealProvider, Size size, ColorScheme colorScheme) {
    final allMeals = [
      ...mealProvider.breakfast,
      ...mealProvider.lunch,
      ...mealProvider.supper,
    ];

    if (allMeals.isEmpty) {
      return Center(
        child: Text(
          'No meals recorded yet',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      );
    }

    // Sort meals by date
    allMeals.sort((a, b) =>
        DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: allMeals.length,
      itemBuilder: (context, index) {
        final meal = allMeals[index];
        final date = DateTime.parse(meal.createdAt);
        final formattedDate = DateFormat('MMM d, y').format(date);
        final time = DateFormat('h:mm a').format(date);

        String category;
        Color categoryColor;
        if (meal.glycemicLoad >= 20) {
          category = "High";
          categoryColor = Colors.red;
        } else if (meal.glycemicLoad >= 11) {
          category = "Medium";
          categoryColor = Colors.orange;
        } else {
          category = "Low";
          categoryColor = Colors.green;
        }

        return Container(
          margin: EdgeInsets.only(bottom: size.height * 0.02),
          padding: EdgeInsets.all(size.width * 0.04),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    meal.name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.03,
                      vertical: size.height * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: categoryColor,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Glycemic Load: ${meal.glycemicLoad.toStringAsFixed(1)}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: size.height * 0.005),
              Text(
                '$formattedDate at $time',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ChartData {
  final String date;
  final double value;

  ChartData(this.date, this.value);
}
