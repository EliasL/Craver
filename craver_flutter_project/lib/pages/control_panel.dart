import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../support/data_getter.dart';
import '../support/control_values_and_color.dart';
import '../support/gauge.dart';

void updateStates(context) async {
  // We generate a list of all the states
  // we want to get values for.

  // newValues is a json object
  var newValues = await getControlPanelStates(
      List<String>.generate(ControlValues.allValues.length,
          (i) => ControlValues.allValues[i].fullName),
      context);
  if (newValues == null) {
    return;
  }

  // Then we update the values in the ControlValues class
  for (ControlValue value in ControlValues.allValues) {
    String newValue = newValues[value.fullName];
    if (newValue == 'NOT__READY') {
      value.sValue = null;
    } else {
      value.sValue = newValue;
    }
  }

  // Now we let the control panel updater know that we have updated the values
  // and by doing so, update all the widgets that listen to this variable
  ControlValues.updater.value += 1;
}

class ControlPanel extends StatelessWidget {
  final List<MaterialColor> gaugeColors = const [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange
  ];
  ControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Timer timer = Timer.periodic(
        const Duration(milliseconds: 700), (Timer t) => updateStates(context));

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
                    text: 'LHCb Status',
                  ),
                  Tab(
                    text: 'Details',
                  ),
                  Tab(
                    text: 'Abbreviations',
                  ),
                ],
              )
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: TabBarView(
            children: [
              StatusPage(gaugeColors: gaugeColors),
              DetailsPage(gaugeColors: gaugeColors),
              Abbreviations(),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusText extends StatelessWidget {
  final List<MaterialColor> colors;
  final double widthFactor;
  final double heightPadding;
  const StatusText(
      {Key? key,
      required this.colors,
      this.widthFactor = 1,
      this.heightPadding = 0})
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
              valueListenable: ControlValues.updater,
              builder: (BuildContext context, _, Widget? child) {
                var descriptionColor = Colors.grey[500];
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: 'Run Number:\n    ',
                          style: TextStyle(color: descriptionColor)),
                      TextSpan(text: ControlValues.runNumber.sValue),
                      TextSpan(
                          text: '\nRun Type:\n    ',
                          style: TextStyle(color: descriptionColor)),
                      TextSpan(text: ControlValues.runType.sValue),
                      TextSpan(
                          text: '\nData Type:\n    ',
                          style: TextStyle(color: descriptionColor)),
                      TextSpan(
                          text: ControlValues.dataType.sValue,
                          style: const TextStyle(fontSize: 13)),
                      TextSpan(
                          text: '\nArchitecture:\n    ',
                          style: TextStyle(color: descriptionColor)),
                      TextSpan(text: ControlValues.architecture.sValue),
                      TextSpan(
                          text: '\nNr. events\n    ',
                          style: TextStyle(color: descriptionColor)),
                      TextSpan(text: ControlValues.nrOfEvents.sValue),
                      TextSpan(
                          text: '\nInput rate\n',
                          style:
                              TextStyle(color: Color(colors[0][600]!.value))),
                      TextSpan(
                          text: 'Output rate\n',
                          style:
                              TextStyle(color: Color(colors[1][600]!.value))),
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
  final ControlValue cv;
  const StatusBox({Key? key, required this.name, required this.cv})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ControlValues.updater,
      builder: (BuildContext context, _, Widget? child) {
        Color color = cv.colorStateMap[cv.sValue] ?? defaultColor;
        Color textColor =
            color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
        return Flexible(
          child: Card(
            color: color,
            child: ListTile(
              title: Text(
                '$name: ${cv.colorStateMap[cv.sValue] ?? ''}',
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

class StatusPage extends StatefulWidget {
  final List<MaterialColor> gaugeColors;
  const StatusPage({Key? key, required this.gaugeColors}) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatusText(
                colors: widget.gaugeColors,
                widthFactor: 0.8,
                heightPadding: 25,
              ),
              const SizedBox(
                width: 10,
              ),
              RadialGaugeWithNumbers(
                updateData: ControlValues.updater,
                gaugeValues: [
                  ControlValues.inputRate,
                  ControlValues.outputRate
                ],
                colors: widget.gaugeColors,
                radius: 0.65,
                minValue: 0,
                maxValue: 11,
                useExp: true,
                units: ['Hz', 'Hz'],
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
                    StatusBox(name: 'LHCb', cv: ControlValues.LHCbState),
                    StatusBox(name: 'DAQ', cv: ControlValues.DAQState),
                    StatusBox(name: 'DAI', cv: ControlValues.DAIState),
                    StatusBox(name: 'DCS', cv: ControlValues.DCSState),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatusBox(
                        name: 'Monitoring', cv: ControlValues.MonitoringState),
                    StatusBox(name: 'TFC', cv: ControlValues.TFCState),
                    StatusBox(name: 'EB', cv: ControlValues.EBState),
                    StatusBox(name: 'HV', cv: ControlValues.HVState),
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
  final List<MaterialColor> gaugeColors;
  const DetailsPage({Key? key, required this.gaugeColors}) : super(key: key);

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
      updateData: ControlValues.updater,
      gaugeValues: [ControlValues.inputRate, ControlValues.outputRate],
      colors: widget.gaugeColors,
      radius: 0.55,
      minValue: 0,
      maxValue: 8,
      useExp: true,
      units: ['Hz', 'Hz'],
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
