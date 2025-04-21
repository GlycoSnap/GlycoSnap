import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
  int visit = 0;

  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  String selectedDay = '';
  final List<SalesData> salesData = [
    SalesData('Mon', 35),
    SalesData('Tue', 28),
    SalesData('Wed', 34),
    SalesData('Thu', 32),
    SalesData('Fri', 60),
    SalesData('Sat', 18),
    SalesData('Sun', 30),
  ];

  void _onDateChange(DateTime date) {
    setState(() {
      selectedDay = _getDayString(date);
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
      body: ListView(
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
                      dateFormatter: DateFormatter.fullDateDMonthAsStrY(),
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
                          borderRadius: BorderRadius.all(Radius.circular(8)),
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
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        dayNumStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Poppins',
                        ),
                        dayStrStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
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
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      primaryYAxis: NumericAxis(
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      legend: Legend(
                        isVisible: true,
                        textStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      tooltipBehavior: _tooltipBehavior,
                      series: <CartesianSeries>[
                        LineSeries<SalesData, String>(
                          name: 'Glycemic Load',
                          dataSource: salesData,
                          color: Theme.of(context).colorScheme.primary,
                          xValueMapper: (SalesData sales, _) => sales.day,
                          yValueMapper: (SalesData sales, _) => sales.sales,
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            textStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          markerSettings: MarkerSettings(
                            isVisible: true,
                            shape: DataMarkerType.circle,
                            color: Theme.of(context).colorScheme.primary,
                            borderWidth: 2,
                            borderColor: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        if (selectedDay.isNotEmpty)
                          ColumnSeries<SalesData, String>(
                            name: 'Selected day',
                            dataSource: salesData,
                            xValueMapper: (SalesData sales, _) => sales.day,
                            yValueMapper: (SalesData sales, _) =>
                                selectedDay == sales.day ? sales.sales : 0,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                      ],
                    ),
                  ),

                  // Meal cards
                  _buildMealCard(
                    context,
                    'Breakfast',
                    'images/breakfast.jpeg',
                    '78',
                    '876',
                  ),
                  _buildMealCard(
                    context,
                    'Lunch',
                    'images/lunch.jpeg',
                    '36',
                    '1127',
                  ),
                  _buildMealCard(
                    context,
                    'Supper',
                    'images/supper.jpeg',
                    '56',
                    '635',
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
    );
  }

  Widget _buildMealCard(BuildContext context, String mealName, String imagePath,
      String glycemicLoad, String calories) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 30, 10),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealName,
                  style: TextStyle(
                    fontFamily: 'OpenSauce',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  context,
                  'Glycemic Load: ',
                  glycemicLoad,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Calories: ',
                  '$calories cal',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              fontFamily: 'OpenSauce',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontFamily: 'OpenSauce',
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
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
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
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
                percent: 0.6,
                progressColor: colorScheme.primary,
                backgroundColor: colorScheme.surface,
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
                percent: 0.4,
                progressColor: Theme.of(context).colorScheme.secondary,
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
                        Theme.of(context).colorScheme.secondary,
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
                    '54.6',
                    style: TextStyle(
                      fontFamily: 'OpenSauce',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '763 cal',
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