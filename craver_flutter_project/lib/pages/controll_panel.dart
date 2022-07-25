import 'dart:async';

import 'package:flutter/material.dart';

import 'package:gauges/gauges.dart';
import 'dart:math';

void updateValue(Timer t) {
  ControllPanel.value.value = sin(t.tick * 2 * pi / 200) * 100;
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
  const RadialGaugeWithNumbers({Key? key, required this.radius})
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double radius = widget.radius;
        List<Widget> children = [];

        double minValue = -100;
        double maxValue = 100;
        double interval = 20;
        int ticksInBetween = 5;

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
                        minAngle: -150,
                        maxAngle: 150,
                        radius: radius,
                        width: 0.2,
                        color: Colors.transparent,
                        ticks: [
                          RadialTicks(
                              interval: interval,
                              alignment: RadialTickAxisAlignment.inside,
                              color: Colors.blue,
                              length: 0.2,
                              children: [
                                RadialTicks(
                                  ticksInBetween: ticksInBetween,
                                  length: 0.1,
                                  color: Colors.grey[500]!,
                                ),
                              ])
                        ],
                        pointers: [
                          fancyPointer('blue', ControllPanel.value.value),
                          fancyPointer('red', ControllPanel.value.value + 20)
                        ],
                      ),
                    ],
                  );
                }));

        children.add(radialGauge);

        // Now we add the numbers...
        int nrOfValues = ((maxValue - minValue) / interval).round();
        for (var i = 0; i < nrOfValues; i++) {
          var width = constraints.maxWidth;
          var height = constraints.maxHeight;
          var widthR = width / 2;
          var heightR = height / 2;
          children.add(Positioned(
            top: cos(i * 2 * pi / nrOfValues) * heightR * radius + heightR,
            left: sin(i * 2 * pi / nrOfValues) * widthR * radius + widthR,
            child: Text("test"),
          ));
        }

        return Stack(
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
    return const RadialGaugeWithNumbers(
      radius: 0.55,
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
