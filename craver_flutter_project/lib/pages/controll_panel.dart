import 'dart:async';

import 'package:flutter/material.dart';

import 'package:gauges/gauges.dart';
import 'dart:math';


int itteration = 0;
Timer? timer;

void updateValue(){
  ControllPanel.value.value = sin(itteration*2*pi/80)*100;
  itteration +=1;
}

class ControllPanel extends StatelessWidget {


  static var value = ValueNotifier<double>(0);

  const ControllPanel({Key? key}) : super(key: key);

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
        body: TabBarView(
          children: [
            const StatusPage(),
            OutgoingPage(),
            MissedPage(),
          ],
        ),
      ),
    );
  }
}

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
  //In order to put a listener to update the app title
  //CRAVER: Logbook page 1, we need to use this
  static var currentPage = ValueNotifier<int>(1);
}

class _StatusPageState extends State<StatusPage> {
  Future? data;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    //This updates the ages of the posts: 5 minutes ago -> 6 minutes ago
    timer = Timer.periodic(
        const Duration(milliseconds: 100), (Timer t) => updateValue());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: ControllPanel.value, 
              builder:(context, value, widget) {
                return RadialGauge(
                axes: [
                  RadialGaugeAxis(
                    minValue: -100,
                    maxValue: 100,
                    minAngle: -150,
                    maxAngle: 150,
                    radius: 0.6,
                    width: 0.2,
                    color: Colors.transparent,
                    ticks: [
                      RadialTicks(
                          interval: 20,
                          alignment: RadialTickAxisAlignment.inside,
                          color: Colors.blue,
                          length: 0.2,
                          children: [
                            RadialTicks(
                                ticksInBetween: 5,
                                length: 0.1,
                                color: Colors.grey[500]!),
                          ])
                    ],
                    pointers: [
                      RadialNeedlePointer(
                        minValue: -100,
                        maxValue: 100,
                        value: ControllPanel.value.value,
                        thicknessStart: 20,
                        thicknessEnd: 0,
                        color: Colors.blue,
                        length: 0.6,
                        knobRadiusAbsolute: 10,
                        gradient: LinearGradient(
                          colors: [
                            Color(Colors.blue[300]!.value),
                            Color(Colors.blue[300]!.value),
                            Color(Colors.blue[600]!.value),
                            Color(Colors.blue[600]!.value)
                          ],
                          stops: [0, 0.5, 0.5, 1],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ],
                  ),
                ],
            );
            },
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: clear,
      //   child: Icon(Icons.clear_all),
      // ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class OutgoingPage extends StatefulWidget {
  @override
  _OutgoingPageState createState() => _OutgoingPageState();
}

class _OutgoingPageState extends State<OutgoingPage>
    with AutomaticKeepAliveClientMixin<OutgoingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        //child: Icon(Icons.call_made_outlined, size: 350),
        child: Column(
          children: [
            RadialGauge(
                axes: [
                  // Left axis
                  RadialGaugeAxis(
                    minValue: -100,
                    maxValue: 0,
                    minAngle: -150,
                    maxAngle: 0,
                    radius: 0.15,
                    width: 0.05,
                    offset: Offset(-0.2, -0.1),
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
                    offset: Offset(0.2, -0.1),
                    color: Colors.green[300],
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
              ),
          ],
        )
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MissedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.call_missed_outgoing, size: 350);
  }
}
