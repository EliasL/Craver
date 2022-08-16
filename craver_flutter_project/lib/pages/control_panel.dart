import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gauges/gauges.dart';
import 'package:html/parser.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart' as math;
import 'package:intl/intl.dart';
import 'dart:isolate';

import '../support/data_getter.dart';
import '../support/alert.dart';
import '../support/settings.dart' as settings;

///
///
/// NOTE - A major concern with this control panel is to controll the color.
/// The color of the pointer is not connected to the color of the number under
/// the pointers, or the color of the text to the left. <- TODO
///
///

//https://stackoverflow.com/questions/58030337/valuelistenablebuilder-listen-to-more-than-one-value
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  const ValueListenableBuilder2({
    required this.first,
    required this.second,
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  final ValueNotifier<A> first;
  final ValueNotifier<B> second;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<A>(
        valueListenable: first,
        builder: (_, a, __) {
          return ValueListenableBuilder<B>(
            valueListenable: second,
            builder: (context, b, __) {
              return builder(context, a, b, child);
            },
          );
        },
      );
}

// This is to make the text more readable when used in the
// getControlPanelState function eg.:
// getControlPanelState(fullStates[STATES.runType]);
// NB THIS MEANS THAT THE ORDER OF fullStates and STATES
// MUST MATCH!

const fullStates = [
  "lbWeb/LHCb|LHCb_fsm_currentState",
  "lbWeb/LHCb|LHCb_DAQ|LHCb_DAQ_fsm_currentState",
  "lbWeb/LHCb|LHCb_DAI|LHCb_DAI_fsm_currentState",
  "lbWeb/LHCb|LHCb_DCS|LHCb_DCS_fsm_currentState",
  "lbWeb/LHCb|LHCb_EB|LHCb_EB_fsm_currentState",
  "lbWeb/LHCb|LHCb_HV|LHCb_HV_fsm_currentState",
  "lbWeb/LHCb|LHCb_TFC|LHCb_TFC_fsm_currentState",
  "lbWeb/LHCb|LHCb_Monitoring|LHCb_Monitoring_fsm_currentState",
  "lbWeb/LHCb_DAQ|<SD>_DAQ|<SD>_DAQ_fsm_currentState",
  "lbWeb/LHCb_RunInfo_general_runType",
  "lbWeb/LHCb_RunInfo_general_dataType", //10
  "lbWeb/LHCb_RunInfo_general_runNumber", //11
  "lbWeb/LHCb_RunInfo_general_partId", //12
  "lbWeb/LHCb_RunInfo_TFC_odinData", //13
  "lbWeb/LHCb_RunInfo_TFC_nTriggers", //14
  "lbWeb/LHCb_RunInfo_TFC_triggerRate",
  "lbWeb/LHCb_RunInfo_HLTFarm_hltNTriggers",
  "lbWeb/LHCb_RunInfo_HLTFarm_hltRate",
  "lbWeb/LHCb_RunInfo_EB_architecture"
];

enum STATES {
  LHCbState,
  DAQState,
  DAIState,
  DCSState,
  EBState,
  HVState,
  TFCState,
  MonitoringState,
  SDDAQState,
  runType,
  dataType, //10 (value)
  runNumber, //11
  partId, //12
  odinData, //13
  nrOfEvents, //14 - nTriggers
  inputRate, // 15 - triggerRate
  hltNTriggers, // 16 - hltNTriggers
  outputRate, // 17 - hltRate
  architecture, // 18
}

class RunStates {
  static const String RUNNING = "RUNNING";
  static const String READY = "READY";
  static const String RAMPING_READY = "RAMPING_READY";
  static const String ACTIVE = "ACTIVE";
  static const String CONFIGURING = "CONFIGURING";
  static const String ALLOCATING = "ALLOCATING";
  static const String NOT_ALLOCATED = "NOT_ALLOCATED";
  static const String NOT_READY = "NOT_READY";
  static const String STOPPING = "STOPPING";
  static const String UNKOWN = "UNKOWN";
  static const String ERROR = "ERROR";
  static const String EMERGENCY_OFF = "EMERGENCY_OFF";
  static const String OFF = "OFF";
}

void update(STATES s) async {
  var value = await getControlPanelState(fullStates[s.index]);
  if (value == null) {
    ControlPanel.controlValues[s.index].value = 'null';
  } else {
    ControlPanel.controlValues[s.index].value = value;
    try {
      ControlPanel.controlValues[s.index].value = value;
    } catch (e) {
      ControlPanel.controlValues[s.index].value = value;
    }
  }
}

void slowUpdateValue(Timer t) {
  // Isolate.spawn(update, STATES.state);
  // Isolate.spawn(update, STATES.DAQState);
  // Isolate.spawn(update, STATES.DAIState);
  // Isolate.spawn(update, STATES.EBState);
  // Isolate.spawn(update, STATES.HVState);
  // Isolate.spawn(update, STATES.TFCState);
  // Isolate.spawn(update, STATES.MonitoringState);
  // Isolate.spawn(update, STATES.SDDAQState);
  // Isolate.spawn(update, STATES.runType);
  // Isolate.spawn(update, STATES.dataType);
  // Isolate.spawn(update, STATES.runNumber);
  // Isolate.spawn(update, STATES.partId);
  // Isolate.spawn(update, STATES.odinData);
  // Isolate.spawn(update, STATES.triggerRate);
  // Isolate.spawn(update, STATES.hltNTriggers);
  // Isolate.spawn(update, STATES.hltRate);
  // Isolate.spawn(update, STATES.architecture);
  for (var i = 0; i < STATES.values.length; i++) {
    update(STATES.values[i]);
    //print('$i: ' + ControlPanel.controlValues[i].value);
  }
}

void fastUpdateValue(Timer t) {
  Isolate.spawn(update, STATES.inputRate);
}

class ControlPanel extends StatelessWidget {
  static var controlValues = List<ValueNotifier<String>>.generate(
      STATES.values.length, (index) => ValueNotifier<String>('0.0'));

  ControlPanel({Key? key}) : super(key: key);

  final Timer slowTimer = Timer.periodic(
      const Duration(milliseconds: 700), (Timer t) => slowUpdateValue(t));
  //final Timer fastTimer = Timer.periodic(
  //    const Duration(milliseconds: 1000), (Timer t) => fastUpdateValue(t));

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              TabBar(
                tabs: [
                  Tab(
                    text: 'LHCb Status',
                  ),
                  //Tab(
                  //  text: 'Details',
                  //),
                  //Tab(
                  //  text: 'Abbreviations',
                  //),
                ],
              )
            ],
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: TabBarView(
            children: [
              StatusPage(),
              //DetailsPage(),
              //Abbreviations(),
            ],
          ),
        ),
      ),
    );
  }
}

class RadialGaugeWithNumbers extends StatefulWidget {
  /// A guage with numbers on the side, and a centeral
  /// value in the middle.
  ///
  /// Sorry about the mess...
  /// I hope you don't have to try to understand the angles
  /// It's a bit of a pile of junk
  ///
  final ValueNotifier gaugeValue1;
  final ValueNotifier? gaugeValue2;
  final ValueNotifier? gaugeValue3;
  final ValueNotifier? gaugeValue4;
  final double radius;
  final double minValue;
  final double maxValue;
  final bool useExp;
  final String descreption;
  final String units;
  const RadialGaugeWithNumbers({
    Key? key,
    required this.gaugeValue1,
    this.gaugeValue2,
    this.gaugeValue3,
    this.gaugeValue4,
    required this.radius,
    required this.minValue,
    required this.maxValue,
    required this.useExp,
    this.descreption = '',
    this.units = '',
  }) : super(key: key);

  @override
  State<RadialGaugeWithNumbers> createState() => _RadialGaugeWithNumbersState();
}

class _RadialGaugeWithNumbersState extends State<RadialGaugeWithNumbers> {
  RadialGaugePointer fancyPointer(color, value, minValue, maxValue) {
    final double radius = widget.radius;
    var colors;
    switch (color) {
      case 'orange':
        colors = [
          Color(Colors.orange[300]!.value),
          Color(Colors.orange[300]!.value),
          Color(Colors.orange[600]!.value),
          Color(Colors.orange[600]!.value)
        ];
        break;
      case 'green':
        colors = [
          Color(Colors.green[300]!.value),
          Color(Colors.green[300]!.value),
          Color(Colors.green[600]!.value),
          Color(Colors.green[600]!.value)
        ];
        break;
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
          Color(Colors.red[300]!.value),
          Color(Colors.red[300]!.value),
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
      minValue: minValue,
      maxValue: maxValue,
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

  static double log10(num x) => log(x) / ln10;

  static String toSuper(int i) {
    const String superScript = '⁰¹²³⁴⁵⁶⁷⁸⁹';
    if (i < 0) {
      return '⁻${toSuper(i.abs())}';
    } else if (i > 9) {
      var s = i.toString();
      return toSuper(int.parse(s[0])) + toSuper(int.parse(s.substring(1)));
    } else {
      return superScript[i];
    }
  }

  // get the text size
  static Size _textSize(String text) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text),
        maxLines: 1,
        textDirection: ui.TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool useExp = widget.useExp;

          double logify(double value) => useExp ? log10(value) : value;
          final ValueNotifier gaugeValue1 = widget.gaugeValue1;
          final ValueNotifier gaugeValue2;
          final ValueNotifier gaugeValue3;
          final ValueNotifier gaugeValue4;
          //TODO fix this copy paste ->
          if (widget.gaugeValue2 == null) {
            gaugeValue2 = gaugeValue1;
          } else {
            gaugeValue2 = widget.gaugeValue2!;
          }
          if (widget.gaugeValue3 == null) {
            gaugeValue3 = gaugeValue1;
          } else {
            gaugeValue3 = widget.gaugeValue3!;
          }
          if (widget.gaugeValue4 == null) {
            gaugeValue4 = gaugeValue1;
          } else {
            gaugeValue4 = widget.gaugeValue4!;
          }
          final double radius = widget.radius;
          String description = widget.descreption;
          if (description != '') description += ": ";
          final String units = widget.units;
          List<Widget> children = [];

          double minValue = widget.minValue;
          double maxValue = widget.maxValue;
          double rangeValue = maxValue - minValue;
          double minAngle = -150;
          double maxAngle = 150;
          double offsett = math.radians(180 - minAngle); // We need a offsett :/
          double rangeAngle = maxAngle - minAngle;
          int displayedNumberOfValues =
              max(10, (maxValue.round() + 2) * (useExp ? 1 : 0));
          int nrOfValues = displayedNumberOfValues - 1;
          double interval = rangeValue / nrOfValues;
          // Pick numbers that look nice
          int ticksInBetween =
              (8 * radius * 8 / displayedNumberOfValues).round();

          double tickLength = 0.2;
          double tickLengthSmall = 0.1;

          double numberOffsett = 0.02;

          var radialGauge = Positioned.fill(
              top: 0,
              left: 0,
              child: ValueListenableBuilder2(
                  first: gaugeValue1,
                  second: gaugeValue3,
                  builder: (context, value1, value2, widget) {
                    double value1 = logify(double.parse(gaugeValue1.value));
                    double value2 = logify(double.parse(gaugeValue2.value));
                    double value3 = logify(double.parse(gaugeValue3.value));
                    double value4 = logify(double.parse(gaugeValue4.value));
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
                            fancyPointer('orange', value4, minValue, maxValue),
                            fancyPointer('green', value3, minValue, maxValue),
                            fancyPointer('red', value2, minValue, maxValue),
                            fancyPointer('blue', value1, minValue,
                                maxValue) // This one is on top
                          ],
                        ),
                      ],
                    );
                  }));

          children.add(radialGauge);

          // Now we add the numbers...

          var width = constraints.maxWidth;
          var height = constraints.maxHeight;
          var widthR = width / 2;
          var heightR = height / 2;

          // We're not going to cover the whole circle, only the parts between
          // min and max angle
          var radiansToCover = math.radians(rangeAngle);
          var smallFormat = NumberFormat('##.#');
          var compactFormat = NumberFormat.compact(); //NumberFormat('####');

          //Create text values
          var textSize = _textSize('value');
          double textx = textSize.width;
          double texty = textSize.height;

          for (var i = 0; i <= nrOfValues; i++) {
            String value;
            if (useExp) {
              value = "10${toSuper(i - 1)}";
            } else {
              double number = minValue + i * rangeValue / nrOfValues;
              if (number.abs() < 100) {
                value = smallFormat.format(number);
              } else {
                value = compactFormat.format(number);
              }
            }

            //Update text values
            textSize = _textSize(value);
            textx = textSize.width;
            texty = textSize.height;

            var theta = -i * radiansToCover / nrOfValues + offsett;
            children.add(
              Positioned(
                top: heightR + //Center of guage
                    cos(theta) *
                        widthR *
                        (radius +
                            tickLength +
                            numberOffsett) + //outside of ticks
                    texty / 2 * (-1 + cos(theta)), //Center text
                left: widthR + //Center of guage
                    sin(theta) *
                        widthR *
                        (radius +
                            tickLength +
                            numberOffsett) + //outside of ticks
                    textx / 2 * (-1 + sin(theta)), //Center text
                child: Text(
                  value,
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            );
          }

          var minTheta = math.radians(-minAngle) + pi;
          var maxTheta = math.radians(-maxAngle) + pi;
          var R = radius + tickLengthSmall / 2;
          // Find the size of the box we can fit between the gaues
          // Assume that it is symetric around the 0 degree axis.
          // The length of the box is then

          var A = widthR + //Center of guage
              sin(minTheta) * widthR * R;
          var B = widthR + //Center of guage
              sin(maxTheta) * widthR * R;
          var lengthOfBox = B - A;

          // Finally we'll add the number at the bottom to show the real value numerically
          children.add(Positioned(
              top: heightR + //Center of guage
                  cos(minTheta) * widthR * R,
              left: widthR + //Center of guage
                  sin(minTheta) * widthR * R,
              child: SizedBox(
                  width: lengthOfBox,
                  child: ValueListenableBuilder2(
                      first: gaugeValue1,
                      second: gaugeValue3,
                      builder: (context, value1, value2, widget) {
                        String value1 = gaugeValue1.value;
                        String value2 = gaugeValue2.value;
                        String value3 = gaugeValue3.value;
                        String value4 = gaugeValue4.value;
                        return SizedBox(
                            width: lengthOfBox,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text:
                                          '\n$description${compactFormat.format(double.parse(value1 as String))}$units\n',
                                      style: TextStyle(
                                          color:
                                              Color(Colors.blue[600]!.value))),
                                  TextSpan(
                                      text:
                                          '$description${compactFormat.format(double.parse(value2 as String))}$units\n',
                                      style: TextStyle(
                                          color:
                                              Color(Colors.red[600]!.value))),
                                  // TextSpan(
                                  //     text:
                                  //         '$description${compactFormat.format(double.parse(value3))}$units\n',
                                  //     style: TextStyle(
                                  //         color:
                                  //             Color(Colors.green[600]!.value))),
                                  // TextSpan(
                                  //     text:
                                  //         '$description${compactFormat.format(double.parse(value4))}$units\n',
                                  //     style: TextStyle(
                                  //         color: Color(
                                  //             Colors.orange[600]!.value))),
                                ],
                              ),
                              textAlign: ui.TextAlign.center,
                            ));
                      }))));

          return Stack(
            clipBehavior: ui.Clip.none,
            alignment: Alignment.center,
            children: children,
          );
        },
      ),
    );
  }
}

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class StatusText extends StatelessWidget {
  final double widthFactor;
  final double heightPadding;
  const StatusText({Key? key, this.widthFactor = 1, this.heightPadding = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Wrap(
          //direction: Axis.horizontal,
          //mainAxisAlignment: MainAxisAlignment.center,
          direction: Axis.horizontal,
          clipBehavior: ui.Clip.hardEdge,
          children: [
            SizedBox(
              height: heightPadding,
              width: 100, //Random number
            ),
            ValueListenableBuilder(
              valueListenable:
                  ControlPanel.controlValues[STATES.nrOfEvents.index],
              builder: (BuildContext context, dynamic value, Widget? child) {
                var c = ControlPanel.controlValues;
                String runNumber = c[STATES.runNumber.index].value;
                String runType = c[STATES.runType.index].value;
                String dataType = c[STATES.dataType.index].value;
                String architecture = c[STATES.architecture.index].value;
                String nrOfEvents = c[STATES.nrOfEvents.index].value;
                var descriptionColor = Colors.grey[500];
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: 'Run Number:\n    ',
                          style: TextStyle(color: descriptionColor)),
                      TextSpan(text: runNumber),
                      TextSpan(
                          text: '\nRun Type:\n    ',
                          style: TextStyle(color: descriptionColor)),
                      TextSpan(text: runType),
                      TextSpan(
                          text: '\nData Type:\n    ',
                          style: TextStyle(color: descriptionColor)),
                      TextSpan(text: dataType, style: TextStyle(fontSize: 13)),
                      TextSpan(
                          text: '\nArchitecture:\n    ',
                          style: TextStyle(color: descriptionColor)),
                      TextSpan(text: architecture),

                      TextSpan(
                          text: '\nNr. events\n    ',
                          style: TextStyle(color: descriptionColor)),
                      TextSpan(text: nrOfEvents),
                      TextSpan(
                          text: '\nInput rate\n',
                          style:
                              TextStyle(color: Color(Colors.blue[600]!.value))),
                      TextSpan(
                          text: 'Output rate\n',
                          style:
                              TextStyle(color: Color(Colors.red[600]!.value))),
                      // TextSpan(
                      //     text: 'HLT N. rate\n',
                      //     style: TextStyle(
                      //         color: Color(Colors.orange[600]!.value))),
                    ],
                  ),
                  textAlign: ui.TextAlign.left,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBox extends StatelessWidget {
  final String name;
  final ValueNotifier status;
  const StatusBox({Key? key, required this.name, required this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: status,
      builder: (BuildContext context, dynamic strangeValue, Widget? child) {
        ui.Color? color;

        // The last char of the value is NOT ' ',
        // so we remove the last char
        String value =
            (strangeValue as String).substring(0, strangeValue.length - 1);

        switch (value) {
          case RunStates.RUNNING:
            color = ui.Color.fromARGB(255, 0, 204, 153);
            break;
          case RunStates.READY:
            color = ui.Color.fromARGB(255, 0, 204, 153);
            break;
          case RunStates.RAMPING_READY:
            color = ui.Color.fromARGB(255, 0, 144, 108);
            break;
          case RunStates.ACTIVE:
            color = Colors.teal[400];
            break;
          case RunStates.CONFIGURING:
            color = ui.Color.fromARGB(255, 255, 255, 153);
            break;
          case RunStates.ALLOCATING:
            color = Colors.cyan[400];
            break;
          case RunStates.NOT_ALLOCATED:
            color = Colors.cyan[700];
            break;
          case RunStates.NOT_READY:
            color = ui.Color.fromARGB(255, 255, 255, 153);
            break;

          case RunStates.STOPPING:
            color = ui.Color.fromARGB(255, 133, 178, 255);
            break;
          case RunStates.ERROR:
            color = ui.Color.fromARGB(255, 169, 54, 54);
            break;
          case RunStates.EMERGENCY_OFF:
            color = ui.Color.fromARGB(255, 199, 10, 10);
            break;
          case RunStates.OFF:
            color = ui.Color.fromARGB(255, 51, 153, 255);
            break;
          case RunStates.UNKOWN:
            color = ui.Color.fromARGB(255, 255, 153, 0);
            break;
          default:
            color = Colors.grey[700];
        }
        Color textColor =
            color!.computeLuminance() > 0.5 ? Colors.black : Colors.white;
        return Flexible(
          child: Card(
            color: color,
            child: ListTile(
              title: Text(
                '$name: $value',
                textAlign: ui.TextAlign.center,
                style: TextStyle(color: textColor),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusPageState extends State<StatusPage> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var s = ControlPanel.controlValues;
    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const StatusText(
                widthFactor: 0.8,
                heightPadding: 25,
              ),
              const SizedBox(
                width: 10,
              ),
              RadialGaugeWithNumbers(
                gaugeValue1: ControlPanel.controlValues[STATES.inputRate.index],
                gaugeValue2:
                    ControlPanel.controlValues[STATES.outputRate.index],
                //gaugeValue3:
                //    ControlPanel.controlValues[STATES.nrOfEvents.index],
                //gaugeValue4: ,
                radius: 0.65,
                minValue: 0,
                maxValue: 11,
                useExp: true,
                units: 'Hz', // TODO Should be a list of 4 values
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatusBox(name: 'LHCb', status: s[STATES.LHCbState.index]),
                    StatusBox(name: 'DAQ', status: s[STATES.DAQState.index]),
                    StatusBox(name: 'DAI', status: s[STATES.DAIState.index]),
                    StatusBox(name: 'DCS', status: s[STATES.DCSState.index]),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatusBox(
                        name: 'Monitoring',
                        status: s[STATES.MonitoringState.index]),
                    StatusBox(name: 'TFC', status: s[STATES.TFCState.index]),
                    StatusBox(name: 'EB', status: s[STATES.EBState.index]),
                    StatusBox(name: 'HV', status: s[STATES.HVState.index]),
                  ],
                ),
              ),
            ],
          ),
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
    return RadialGaugeWithNumbers(
      gaugeValue1: ControlPanel.controlValues[STATES.inputRate.index],
      gaugeValue2: ControlPanel.controlValues[STATES.outputRate.index],
      radius: 0.55,
      minValue: 0,
      maxValue: 8,
      useExp: true,
      units: 'Hz',
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Abbreviations extends StatefulWidget {
  const Abbreviations({Key? key}) : super(key: key);

  @override
  State<Abbreviations> createState() => _AbbreviationsState();
  //In order to put a listener to update the app title
  //CRAVER: Logbook page 1, we need to use this
  static var currentPage = ValueNotifier<int>(1);
}

class _AbbreviationsState extends State<Abbreviations> {
  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}
