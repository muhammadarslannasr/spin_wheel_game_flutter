import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with TickerProviderStateMixin {
  List<double> sectors = [
    100,
    20,
    0.15,
    0.5,
    50,
    20,
    100,
    50,
    20,
    50,
  ]; // sectors on the wheel

  int randomSectorIndex = -1; // any index on sectors
  List<double> sectorRadians = []; // sector degrees/radians
  double angle = 0; // angle in radians to spin too

  // other data
  bool spinning = false; // weather currently spinning or not
  double earnedValue = 0; // currently earned value
  double totalEarnings = 0; // all earnings in total
  int spins = 0; // number of times of spinning so far

  //Random Object to help generate any random int
  math.Random random = math.Random();

  // spin animation controller
  late AnimationController controller;

  //Animation
  late Animation<double> animation;

  //Initialize setup
  @override
  void initState() {
    super.initState();
    generateSectorRadians();

    // animation controller
    controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 3600,
      ),
    ); // 3.6 seconds

    // the tween
    Tween<double> tween = Tween<double>(begin: 0, end: 1);
    // the curve behaviour
    CurvedAnimation curve = CurvedAnimation(
      parent: controller,
      curve: Curves.decelerate,
    );

    // animation
    animation = tween.animate(curve);

    // rebuild the screen as the animation continues
    controller.addListener(() {
      // Only when animation completes
      if (controller.isCompleted) {
        // rebuild
        setState(() {
          // record stats
          recordStats();
          // update status bool
          spinning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: _gameContent(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void generateSectorRadians() {
    // radian for one sector
    double sectorRadian =
        2 * math.pi / sectors.length; // ie. 360 degrees = 2xpi
    // make it somehow large
    for (int i = 0; i < sectors.length; i++) {
      // make it greater as much as you can
      sectorRadians.add((i + 1) * sectorRadian);
    }
  }

  void recordStats() {
    earnedValue = sectors[
        sectors.length - (randomSectorIndex + 1)]; // current earned value
    totalEarnings = totalEarnings + earnedValue; // total earnings
    spins = spins + 1;
  }

  Widget _gameContent() {
    return Stack(
      children: [
        _gameTitle(),
        _gameWheel(),
        _gameActions(),
        _gameStats(),
      ],
    );
  }

  Widget _gameActions() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.17,
          left: 20,
          right: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(
                    color: CupertinoColors.systemYellow,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    debugPrint('Ready to withdraw \$ $totalEarnings ?');
                  },
                  icon: const Icon(Icons.arrow_circle_down),
                ),
              ),
            ),
            InkWell(
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(
                      color: CupertinoColors.systemYellow,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: spinning ? 20 : 35,
                      color: const Color(0xFF41006e),
                    ),
                  )),
              onTap: () {
                if (spinning) return;
                setState(() {
                  resetGame(); // reset everything to default
                });
              },
            ),
            InkWell(
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(
                      color: CupertinoColors.systemYellow,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  child: Text(
                    spinning ? 'Spinning' : 'Spin',
                    style: TextStyle(
                      fontSize: spinning ? 20 : 35,
                      color: const Color(0xFF41006e),
                    ),
                  )),
              onTap: () {
                setState(() {
                  if (!spinning) {
                    spin();
                    spinning = true;
                  }
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _gameStats() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          border: Border.all(
            color: CupertinoColors.systemYellow,
            width: 2,
          ),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2d014c),
              Color(
                0xFFf8009e,
              ),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Table(
          border: TableBorder.all(color: CupertinoColors.systemYellow),
          children: [
            TableRow(
              children: [
                _titleColumn('Earned'),
                _titleColumn('Earnings'),
                _titleColumn('Spins'),
              ],
            ),
            TableRow(
              children: [
                _valueColumn(earnedValue),
                _valueColumn(totalEarnings),
                _valueColumn(spins),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gameWheel() {
    // center everything in here
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 20, left: 5),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('assets/images/belt.png'))),

        // use animated builder for scanning
        child: InkWell(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: controller.value * angle,
                // angle and controller value in action
                child: Container(
                  // the wheel container
                  margin:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.07),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/wheel.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
          onTap: () {
            setState(() {
              if (!spinning) {
                spin(); //a method to spin the wheel/ do the animation in it
                spinning = true; // now spinning status
              }
            });
          },
        ),
      ),
    );
  }

  Widget _gameTitle() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 70),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: CupertinoColors.systemYellow,
            width: 2,
          ),
          gradient: const LinearGradient(
            colors: [
              Color(
                0xFF2d014c,
              ),
              Color(
                0xFFf8009e,
              ),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: const Text(
          'Fortune Wheel',
          style: TextStyle(
            fontSize: 40,
            color: CupertinoColors.systemYellow,
          ),
        ),
      ),
    );
  }

  void spin() {
    // spinning here
    // get any random sector index
    randomSectorIndex = random.nextInt(sectors.length); // bound exclusive
    // generate a random radian to spin the wheel
    double randomRadian = generateRandomRadianToSpinTo();
    controller.reset(); // reset any previous, values
    angle = randomRadian;
    controller.forward();
  }

  double generateRandomRadianToSpinTo() {
    // make it higher as much as you can
    return (2 * math.pi * sectors.length) + sectorRadians[randomSectorIndex];
  }

  Column _titleColumn(String title) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5,
          ),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, color: Colors.yellowAccent),
          ),
        ),
      ],
    );
  }

  Column _valueColumn(var val) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5,
          ),
          child: Text(
            '$val',
            style: const TextStyle(fontSize: 25, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void resetGame() {
    spinning = false;
    earnedValue = 0;
    angle = 0;
    totalEarnings = 0;
    spins = 0;
    controller.reset();
  }
}
