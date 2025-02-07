import 'package:flutter/material.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
      backgroundColor: const Color(0xffFDFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xffFDFFFF),
        toolbarHeight: 80,
        title: Container(
          child: const Text(
            'Weekly review',
            style: TextStyle(
              fontFamily: 'OpenSauce',
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10),
            decoration: const BoxDecoration(
              color: Color(0xffFDFFFF),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EasyDateTimeLine(
                    initialDate: DateTime.now(),
                    onDateChange: _onDateChange,
                    headerProps: const EasyHeaderProps(
                      monthPickerType: MonthPickerType.dropDown,
                      dateFormatter: DateFormatter.fullDateDMonthAsStrY(),
                    ),
                    dayProps: const EasyDayProps(
                      dayStructure: DayStructure.dayStrDayNum,
                      activeDayStyle: DayStyle(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xff47B2A5),
                              Color.fromARGB(255, 46, 116, 169),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: SfCartesianChart(
                      primaryXAxis: const CategoryAxis(),
                      legend: const Legend(isVisible: true),
                      tooltipBehavior: _tooltipBehavior,
                      series: <CartesianSeries>[
                        LineSeries<SalesData, String>(
                          name: 'Glycemic Load',
                          dataSource: salesData,
                          color: const Color.fromARGB(255, 10, 113, 113),
                          xValueMapper: (SalesData sales, _) => sales.day,
                          yValueMapper: (SalesData sales, _) => sales.sales,
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                          markerSettings: const MarkerSettings(
                            isVisible: true,
                            shape: DataMarkerType.circle,
                            color: Color.fromARGB(255, 10, 113, 113),
                          ),
                        ),
                        if (selectedDay.isNotEmpty)
                          ColumnSeries<SalesData, String>(
                            name: 'Selected day',
                            dataSource: salesData,
                            xValueMapper: (SalesData sales, _) => sales.day,
                            yValueMapper: (SalesData sales, _) =>
                                selectedDay == sales.day ? sales.sales : 0,
                            color: const Color(0xff83AFAF).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                      ],
                    ),
                  ),

                  //breakfast
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 194, 227, 226),
                    ),
                    child: Row(
                    children: [
                      Padding(padding: const EdgeInsets.fromLTRB(20, 10, 30, 10),
                        child: ClipOval(
                          child: Image.asset(
                            'images/breakfast.jpeg',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover, 
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Breakfast',
                          style: TextStyle(
                            fontFamily: 'OpenSauce',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),),
                          const SizedBox(height: 10),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Glycemic Load: ',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '78',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Calories: ',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '876',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  ),
                  ),

                  //lunch
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 194, 227, 226),
                    ),
                    child: Row(
                    children: [
                      Padding(padding: const EdgeInsets.fromLTRB(20, 10, 30, 10),
                        child: ClipOval(
                          child: Image.asset(
                            'images/lunch.jpeg',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover, 
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lunch',
                          style: TextStyle(
                            fontFamily: 'OpenSauce',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),),
                          const SizedBox(height: 10),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Glycemic Load: ',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '36',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Calories: ',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '1127',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  ),
                  ),

                  //supper
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 194, 227, 226),
                    ),
                    child: Row(
                    children: [
                      Padding(padding: const EdgeInsets.fromLTRB(20, 10, 30, 10),
                        child: ClipOval(
                          child: Image.asset(
                            'images/supper.jpeg',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover, 
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Supper',
                          style: TextStyle(
                            fontFamily: 'OpenSauce',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),),
                          const SizedBox(height: 10),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Glycemic Load: ',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '56',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Calories: ',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: '635',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  ),
                  ),


                  const Text('Daily summary',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 370,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: const Color(0xffBEE1DD),
                            ),
                          ),
                          Positioned(
                            top: 15,
                            left: 6,
                            child: CircularPercentIndicator(
                              animation: true,
                              animationDuration: 3000,
                              radius: 70.0,
                              lineWidth: 11.0,
                              percent: 0.6,
                              progressColor: const Color(0xff071332),
                              backgroundColor: white,
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
                              progressColor: const Color(0xff3BBF80),
                              backgroundColor: white,
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
                                    Row(
                                      children: [
                                        Container(
                                          width: 20.0,
                                          height: 20.0,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xff071332),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Text(
                                            'Glycemic Load',
                                            style: TextStyle(
                                              fontFamily: 'OpenSauce',
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Container(
                                          width: 20.0,
                                          height: 20.0,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xff3BBF80),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Text(
                                            'Calories',
                                            style: TextStyle(
                                              fontFamily: 'OpenSauce',
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Positioned(
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
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  '763 cal',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
