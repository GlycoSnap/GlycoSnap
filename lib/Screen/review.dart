import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:glycosnap/Screen/meal_provider.dart';
import 'package:intl/intl.dart';

class SalesData {
  final String day;
  final double sales;

  SalesData(this.day, this.sales);
}

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  late TooltipBehavior _tooltipBehavior;
  String selectedDay = '';
  List<SalesData> salesData = [];
  double totalGlycemicLoad = 0;
  double totalCalories = 0;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _loadMealData();
  }

  Future<void> _loadMealData() async {
    try {
      final mealProvider = Provider.of<MealProvider>(context, listen: false);
      await mealProvider.fetchMeals();
      if (mounted) {
        _updateChartData(mealProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading meal data: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _updateChartData(MealProvider mealProvider) {
    // Get all meals
    final allMeals = [
      ...mealProvider.breakfast,
      ...mealProvider.lunch,
      ...mealProvider.supper,
    ];

    // Group meals by day of the week
    final Map<String, List<Meal>> mealsByDay = {};
    for (var meal in allMeals) {
      final date = DateTime.parse(meal.createdAt);
      final dayOfWeek = DateFormat('EEE').format(date);
      if (!mealsByDay.containsKey(dayOfWeek)) {
        mealsByDay[dayOfWeek] = [];
      }
      mealsByDay[dayOfWeek]!.add(meal);
    }

    // Initialize data for all days of the week
    final Map<String, double> dailyTotals = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    // Calculate totals for each day
    mealsByDay.forEach((day, meals) {
      final totalGL = meals.fold<double>(
        0,
        (sum, meal) => sum + meal.glycemicLoad,
      );
      dailyTotals[day] = totalGL;
    });

    // Convert to SalesData list
    salesData = dailyTotals.entries
        .map((entry) => SalesData(entry.key, entry.value))
        .toList();

    // Calculate overall totals
    totalGlycemicLoad = allMeals.fold<double>(
      0,
      (sum, meal) => sum + meal.glycemicLoad,
    );

    // Update UI
    if (mounted) {
      setState(() {});
    }
  }

  void _onDateChange(DateTime date) {
    setState(() {
      selectedDay = _getDayString(date);
      // Filter data for selected day
      final selectedDayData = salesData.firstWhere(
        (data) => data.day == selectedDay,
        orElse: () => SalesData(selectedDay, 0),
      );
      totalGlycemicLoad = selectedDayData.sales;
    });
  }

  String _getDayString(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final EasyInfiniteDateTimelineController controller =
        EasyInfiniteDateTimelineController();
    final mealProvider = Provider.of<MealProvider>(context);

    // Only update chart data when necessary
    if (!mealProvider.isLoading && mounted) {
      _updateChartData(mealProvider);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        toolbarHeight: 80,
        title: Container(
          child: Text(
            'Weekly review',
            style: TextStyle(
              fontFamily: 'OpenSauce',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
      body: mealProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMealData,
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          EasyDateTimeLine(
                            initialDate: DateTime.now(),
                            onDateChange: _onDateChange,
                            headerProps: EasyHeaderProps(
                              monthPickerType: MonthPickerType.dropDown,
                              dateFormatter:
                                  DateFormatter.fullDateDMonthAsStrY(),
                              monthStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Poppins',
                              ),
                              selectedDateStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            dayProps: EasyDayProps(
                              dayStructure: DayStructure.dayStrDayNum,
                              activeDayStyle: DayStyle(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                    ],
                                  ),
                                ),
                              ),
                              inactiveDayStyle: DayStyle(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                                dayNumStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Poppins',
                                ),
                                dayStrStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              primaryYAxis: NumericAxis(
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              legend: Legend(
                                isVisible: true,
                                textStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              tooltipBehavior: _tooltipBehavior,
                              series: <CartesianSeries>[
                                LineSeries<SalesData, String>(
                                  name: 'Glycemic Load',
                                  dataSource: salesData,
                                  color: Theme.of(context).colorScheme.primary,
                                  xValueMapper: (SalesData sales, _) =>
                                      sales.day,
                                  yValueMapper: (SalesData sales, _) =>
                                      sales.sales,
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: true,
                                    textStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  markerSettings: MarkerSettings(
                                    isVisible: true,
                                    shape: DataMarkerType.circle,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderWidth: 2,
                                    borderColor:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                                if (selectedDay.isNotEmpty)
                                  ColumnSeries<SalesData, String>(
                                    name: 'Selected day',
                                    dataSource: salesData,
                                    xValueMapper: (SalesData sales, _) =>
                                        sales.day,
                                    yValueMapper: (SalesData sales, _) =>
                                        selectedDay == sales.day
                                            ? sales.sales
                                            : 0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                              ],
                            ),
                          ),

                          // Daily summary
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Daily summary',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildSummaryCard(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        width: 370,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Theme.of(context).colorScheme.secondary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 15,
              left: 6,
              child: CircularPercentIndicator(
                animation: true,
                animationDuration: 3000,
                radius: 70.0,
                lineWidth: 11.0,
                percent: totalGlycemicLoad / 100, // Assuming 100 is max
                progressColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            Positioned(
              top: 38,
              left: 28,
              child: CircularPercentIndicator(
                animation: true,
                animationDuration: 3000,
                radius: 48.0,
                lineWidth: 10.0,
                percent: totalCalories / 2000, // Assuming 2000 is max
                progressColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
            Positioned(
              top: 50,
              left: 160,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        context,
                        Theme.of(context).colorScheme.primary,
                        'Glycemic Load',
                      ),
                      const SizedBox(height: 20),
                      _buildLegendItem(
                        context,
                        Theme.of(context).colorScheme.onPrimary,
                        'Calories',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 50,
              left: 310,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalGlycemicLoad.toStringAsFixed(1),
                    style: TextStyle(
                      fontFamily: 'OpenSauce',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${totalCalories.toStringAsFixed(0)} cal',
                    style: TextStyle(
                      fontFamily: 'OpenSauce',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'OpenSauce',
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
