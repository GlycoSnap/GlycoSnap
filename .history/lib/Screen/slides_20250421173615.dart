import 'package:flutter/material.dart';
import 'package:glycosnap/Screen/signup_questions.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:get/get.dart';


class Slides extends StatefulWidget {
  const Slides({super.key});

  @override
  _SlidesState createState() => _SlidesState();
}

class _SlidesState extends State<Slides> {
  final PageController _pageController = PageController();
  int selectedPage = 0;

  void nextPage() {
    if (selectedPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Get.to(() => const SignUpQuestions(), 
      transition: Transition.zoom,
      duration: const Duration(milliseconds: 500));
    }
  }
  void goToSlideThree() {
    setState(() {
      selectedPage = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    const pageCount = 3;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                selectedPage = index;
              });
            },
            children: [
              const SlideOne(),
              const SlideTwo(),
              SlideThree(goToSlideThree: goToSlideThree),
            ],
          ),
          Positioned(
            bottom: 50,
            left: 50,
            child: PageViewDotIndicator(
              currentItem: selectedPage,
              count: pageCount,
              unselectedColor: colorLight,
              selectedColor: colorDark,
              size: const Size(27, 27),
              unselectedSize: const Size(15, 15),
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.zero,
              fadeEdges: false,
              onItemClicked: (index) {
                setState(() {
                  selectedPage = index;
                });
              },
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 10, color: colorLight),
          borderRadius: BorderRadius.circular(100),
        ),
        backgroundColor: backgroundColor1,
        foregroundColor: colorDark,
        onPressed: nextPage,
        child: const Icon(Icons.arrow_circle_right),
      ),
    );
  }
}

class SlideOne extends StatelessWidget {
  const SlideOne({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: size.height * 0.35,
            width: size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/1.png"),
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              Text(
                "Welcome to",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'OpenSauce',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: colorDark,
                  height: 1.2,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Glyco",
                      style: TextStyle(
                        fontFamily: 'OpenSauce',
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff027a8f),
                      ),
                    ),
                    TextSpan(
                      text: "Snap",
                      style: TextStyle(
                        fontFamily: 'OpenSauce',
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff071332),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "GlycoSnap is your all in one companion\n"
                "for effortless glucose management.\n"
                "Harness the power of image-assisted\n"
                "nutrition tracking and personalized\n"
                "insights to take control of your health.\n"
                "Get ready to say goodbye to guess-work\n"
                "and hello to a healthier, happier you",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'OpenSauce',
                  fontSize: 16,
                  color: black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SlideTwo extends StatelessWidget {
  const SlideTwo({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: size.height * 0.60,
            width: size.width * 0.85,
            decoration: BoxDecoration(
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("images/2.jpg"),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.62,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                Text(
                  "Snap or upload a photo of your plate,\n"
                  "and our intelligent image recognition\n"
                  "technology will analyze the content,\n"
                  "identify the foods and provide\n"
                  "you with their glycemic load\n"
                  "information\n",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'OpenSauce',
                    fontSize: 16,
                    color: black,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SlideThree extends StatelessWidget {
  final VoidCallback? goToSlideThree;

  const SlideThree({super.key, this.goToSlideThree});
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: size.height * 0.42,
            width: size.width * 0.90,
            margin: const EdgeInsets.only(top: 70),
            decoration: BoxDecoration(
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("images/3.png"),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.55,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                Text(
                  "Based on the glycemic load analysis,\n"
                  "GlycoSnap will offer personalized diet\n"
                  "recommendations for portion control\n"
                  "and healthier food choices.\n",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'OpenSauce',
                    fontSize: 16,
                    color: black,
                  ),
                )],
            ),
          ),
        ),
      ],
    );
  }
}



class PageViewDotIndicator extends StatelessWidget {
  final int currentItem;
  final int count;
  final Color unselectedColor;
  final Color selectedColor;
  final Size size;
  final Size unselectedSize;
  final Duration duration;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final bool fadeEdges;
  final void Function(int) onItemClicked;

  const PageViewDotIndicator({super.key,
    required this.currentItem,
    required this.count,
    required this.unselectedColor,
    required this.selectedColor,
    required this.size,
    required this.unselectedSize,
    required this.duration,
    required this.margin,
    required this.padding,
    required this.alignment,
    required this.fadeEdges,
    required this.onItemClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(count, (index) {
        bool isSelected = index == currentItem;
        return GestureDetector(
          onTap: () {
            Get.to(() => index, transition: Transition.zoom);
          },
          child: AnimatedContainer(
            duration: duration,
            margin: margin,
            padding: padding,
            alignment: alignment,
            width: isSelected ? size.width : unselectedSize.width,
            height: isSelected ? size.height : unselectedSize.height,
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : unselectedColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
