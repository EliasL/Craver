import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:gauges/gauges.dart';
import 'dart:math';

import 'package:intl/intl.dart';

void updateValue(Timer t) {
  ControllPanel.value.value = sin(t.tick * 2 * pi / 200) * 4 + 3;
}

class ControllPanel extends StatelessWidget {
  static var value = ValueNotifier<double>(0);

  ControllPanel({Key? key}) : super(key: key);

  final Timer timer = Timer.periodic(
      const Duration(milliseconds: 100), (Timer t) => updateValue(t));

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              TabBar(
                tabs: [
                  Tab(
                    text: 'Status',
                  ),
                  Tab(
                    text: 'Details',
                  ),
                  Tab(
                    text: 'Something',
                  ),
                ],
              )
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StatusPage(),
            DetailsPage(),
            SomethingPage(),
          ],
        ),
      ),
    );
  }
}

class RadialGaugeWithNumbers extends StatefulWidget {
  final double radius;
  final double minValue;
  final double maxValue;
  final bool useExp;
  const RadialGaugeWithNumbers(
      {Key? key,
      required this.radius,
      required this.minValue,
      required this.maxValue,
      required this.useExp})
      : super(key: key);

  @override
  State<RadialGaugeWithNumbers> createState() => _RadialGaugeWithNumbersState();
}

class _RadialGaugeWithNumbersState extends State<RadialGaugeWithNumbers> {
  RadialGaugePointer fancyPointer(color, value) {
    final double radius = widget.radius;
    var colors;
    switch (color) {
      case 'blue':
        colors = [
          Color(Colors.blue[300]!.value),
          Color(Colors.blue[300]!.value),
          Color(Colors.blue[600]!.value),
          Color(Colors.blue[600]!.value)
        ];
        break;
      case 'red':
        colors = [
          Color(Colors.red[400]!.value),
          Color(Colors.red[400]!.value),
          Color(Colors.red[600]!.value),
          Color(Colors.red[600]!.value),
        ];
        break;
      default:
        colors = [
          Color(Colors.blue[300]!.value),
          Color(Colors.blue[300]!.value),
          Color(Colors.blue[600]!.value),
          Color(Colors.blue[600]!.value)
        ];
    }

    return RadialNeedlePointer(
      minValue: -100,
      maxValue: 100,
      value: value,
      thicknessStart: 20,
      thicknessEnd: 0,
      color: Colors.red,
      length: radius,
      knobRadiusAbsolute: 10,
      gradient: LinearGradient(
        colors: colors,
        stops: [0, 0.5, 0.5, 1],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  // get the text size
  Size _textSize(String text) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text),
        maxLines: 1,
        textDirection: ui.TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double radius = widget.radius;
        final bool useExp = widget.useExp;
        List<Widget> children = [];

        double minValue = widget.minValue;
        double maxValue = widget.maxValue;
        double rangeValue = maxValue - minValue;
        double minAngle = -150;
        double maxAngle = 150;
        double rangeAngle = maxAngle - minAngle;
        int displayedNumberOfValues = 10;
        int nrOfValues = displayedNumberOfValues - 1;
        double interval = rangeValue / nrOfValues;
        int ticksInBetween = (8 * radius).round();

        double tickLength = 0.2;
        double tickLengthSmall = 0.1;

        double numberOffsett = 0.02;

        var superScript = '⁰¹²³⁴⁵⁶⁷⁸⁹';
        String toSuper(int i) {
          //Must be -9=<i<=9
          if (i < 0) {
            return '⁻${superScript[i.abs()]}';
          } else {
            return superScript[i];
          }
        }

        var radialGauge = Positioned.fill(
            top: 0,
            left: 0,
            child: ValueListenableBuilder(
                valueListenable: ControllPanel.value,
                builder: (context, value, widget) {
                  return RadialGauge(
                    axes: [
                      // Main axis
                      RadialGaugeAxis(
                        minValue: minValue,
                        maxValue: maxValue,
                        minAngle: minAngle,
                        maxAngle: maxAngle,
                        radius: radius,
                        width: tickLength,
                        color: Colors.transparent,
                        ticks: [
                          RadialTicks(
                              interval: interval,
                              alignment: RadialTickAxisAlignment.inside,
                              color: Colors.blue,
                              length: tickLength,
                              children: [
                                RadialTicks(
                                  ticksInBetween: ticksInBetween,
                                  length: tickLengthSmall,
                                  color: Colors.grey[500]!,
                                ),
                              ])
                        ],
                        pointers: [
                          fancyPointer('blue', ControllPanel.value.value),
                          fancyPointer('red', ControllPanel.value.value + 1)
                        ],
                      ),
                    ],
                  );
                }));

        children.add(radialGauge);

        // Now we add the numbers...
        for (var i = 0; i <= nrOfValues; i++) {
          var width = constraints.maxWidth;
          var height = constraints.maxHeight;
          var widthR = width / 2;
          var heightR = height / 2;

          // We're not going to cover the whole circle, only the parts between
          // min and max angle
          var radiansToCover = 2 * pi * (rangeAngle / 360);
          var offsett = (180 - minAngle) / 360 * 2 * pi;
          var theta = -i * radiansToCover / nrOfValues + offsett;
          var f1 = NumberFormat('##.#');
          var f2 = NumberFormat.compact(); //NumberFormat('####');
          String value;
          if (useExp) {
            value = "10${toSuper(i - 1)}";
          } else {
            double number = minValue + i * rangeValue / nrOfValues;
            if (number.abs() < 100) {
              value = f1.format(number);
            } else {
              value = f2.format(number);
            }
          }
          var textSize = _textSize(value);
          double textx = textSize.width;
          double texty = textSize.height;

          children.add(
            Positioned(
                top: cos(theta) *
                        widthR *
                        (radius + tickLength + numberOffsett) +
                    heightR -
                    texty / 2 -
                    texty / 2 * -cos(theta),
                left: sin(theta) *
                        widthR *
                        (radius + tickLength + numberOffsett) +
                    widthR -
                    textx / 2 -
                    textx / 2 * -sin(theta),
                child: SizedBox(
                  width: textx,
                  height: texty,
                  child: Text(value),
                )),
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: children,
        );
      },
    );
  }
}

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        RadialGaugeWithNumbers(
          radius: 0.2,
          minValue: -1,
          maxValue: 8,
          useExp: true,
        ),
        RadialGaugeWithNumbers(
          radius: 0.6,
          minValue: 0.01,
          maxValue: 8293847997987,
          useExp: false,
        ),
      ],
    );
  }
}

class DetailsPage extends StatefulWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
  //In order to put a listener to update the app title
  //CRAVER: Logbook page 1, we need to use this
  static var currentPage = ValueNotifier<int>(1);
}

class _DetailsPageState extends State<DetailsPage> {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          //child: Icon(Icons.call_made_outlined, size: 350),
          child: Column(
        children: [
          ValueListenableBuilder(
              valueListenable: ControllPanel.value,
              builder: (context, value, widget) {
                return RadialGauge(
                  axes: [
                    // Left axis
                    RadialGaugeAxis(
                      minValue: -100,
                      maxValue: 0,
                      minAngle: -150,
                      maxAngle: 0,
                      radius: 0.15,
                      width: 0.05,
                      offset: const Offset(-0.2, -0.1),
                      color: Colors.red[300],
                      pointers: [
                        RadialNeedlePointer(
                          value: -100 - ControllPanel.value.value,
                          thickness: 4.0,
                          knobColor: Colors.transparent,
                          length: 0.2,
                        ),
                      ],
                      ticks: [
                        RadialTicks(
                            alignment: RadialTickAxisAlignment.below,
                            ticksInBetween: 10,
                            length: 0.05)
                      ],
                    ),
                    // Left axis
                    RadialGaugeAxis(
                      minValue: -100,
                      maxValue: 0,
                      minAngle: 0,
                      maxAngle: 90,
                      radius: 0.15,
                      width: 0.05,
                      offset: const Offset(0.2, -0.1),
                      color: Colors.green[300],
                      pointers: [
                        RadialNeedlePointer(
                          value: -100 + ControllPanel.value.value,
                          thickness: 4.0,
                          knobColor: Colors.transparent,
                          length: 0.2,
                        ),
                      ],
                      ticks: [
                        RadialTicks(
                            alignment: RadialTickAxisAlignment.above,
                            ticksInBetween: 10,
                            length: 0.05)
                      ],
                    ),
                    // Main axis
                    RadialGaugeAxis(
                      minValue: -100,
                      maxValue: 0,
                      minAngle: -150,
                      maxAngle: 150,
                      radius: 0.6,
                      width: 0.2,
                      color: Colors.lightBlue[200],
                      ticks: [
                        RadialTicks(
                            interval: 50,
                            alignment: RadialTickAxisAlignment.inside,
                            color: Colors.black,
                            length: 0.2,
                            children: [
                              RadialTicks(
                                ticksInBetween: 5,
                                length: 0.1,
                                color: Colors.blueGrey,
                              ),
                            ])
                      ],
                      pointers: [
                        RadialNeedlePointer(
                          value: ControllPanel.value.value,
                          thicknessStart: 20,
                          thicknessEnd: 0,
                          color: Colors.lightBlue[200]!,
                          length: 0.6,
                          knobRadiusAbsolute: 10,
                        ),
                      ],
                    ),
                  ],
                );
              }),
        ],
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SomethingPage extends StatefulWidget {
  const SomethingPage({Key? key}) : super(key: key);

  @override
  State<SomethingPage> createState() => _SomethingPageState();
  //In order to put a listener to update the app title
  //CRAVER: Logbook page 1, we need to use this
  static var currentPage = ValueNotifier<int>(1);
}

class _SomethingPageState extends State<SomethingPage> {
  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}
