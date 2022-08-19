import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../support/settings.dart' as settings;

class ControlValue {
  // AControlValue has a long name like: "lbWeb/LHCb|LHCb_fsm_currentState",
  // a color, and a value that can either be a number or a string such as
  // 3.5 or "NOT_READY"
  final String fullName;
  final Type type;
  String? sValue;
  double get numValue => double.tryParse(sValue ?? 'null') ?? 0;

  // Tells what color the different states should have for this controll value
  Map<String, Color> colorStateMap;
  ControlValue(this.fullName,
      {this.type = String, colorScheme = ECSColorScheme})
      : colorStateMap = defaultColorStateMap(colorScheme),
        assert(type == double || type == String);
}

class ControlValues {
  // Use this to know when the values have been updated
  // For simplicity, we assume all values update at the same time
  // at a similar rate. (The numerical value will never be used)
  static final ValueNotifier<int> updater = ValueNotifier<int>(0);

  // These are the values we want to pull from the control panel (Through DIM)
  // They default to string type values like 'RUNNING', but you need to
  // specify them as double if they should be parsed. eg: '41236'
  static final LHCbState = ControlValue("lbWeb/LHCb|LHCb_fsm_currentState");
  static final DAQState =
      ControlValue("lbWeb/LHCb|LHCb_DAQ|LHCb_DAQ_fsm_currentState");
  static final DAIState =
      ControlValue("lbWeb/LHCb|LHCb_DAI|LHCb_DAI_fsm_currentState");
  static final DCSState =
      ControlValue("lbWeb/LHCb|LHCb_DCS|LHCb_DCS_fsm_currentState");
  static final EBState =
      ControlValue("lbWeb/LHCb|LHCb_EB|LHCb_EB_fsm_currentState");
  static final HVState =
      ControlValue("lbWeb/LHCb|LHCb_HV|LHCb_HV_fsm_currentState");
  static final TFCState =
      ControlValue("lbWeb/LHCb|LHCb_TFC|LHCb_TFC_fsm_currentState");
  static final MonitoringState = ControlValue(
      "lbWeb/LHCb|LHCb_Monitoring|LHCb_Monitoring_fsm_currentState");
  static final SDDAQState =
      ControlValue("lbWeb/LHCb_DAQ|<SD>_DAQ|<SD>_DAQ_fsm_currentState");
  static final runType = ControlValue("lbWeb/LHCb_RunInfo_general_runType");
  static final dataType = ControlValue("lbWeb/LHCb_RunInfo_general_dataType");
  static final runNumber =
      ControlValue("lbWeb/LHCb_RunInfo_general_runNumber", type: double);
  static final partId =
      ControlValue("lbWeb/LHCb_RunInfo_general_partId", type: double);
  static final odinData =
      ControlValue("lbWeb/LHCb_RunInfo_TFC_odinData", type: double);
  static final nrOfEvents =
      ControlValue("lbWeb/LHCb_RunInfo_TFC_nTriggers", type: double);
  static final inputRate =
      ControlValue("lbWeb/LHCb_RunInfo_TFC_triggerRate", type: double);
  static final hltNTriggers =
      ControlValue("lbWeb/LHCb_RunInfo_HLTFarm_hltNTriggers", type: double);
  static final outputRate =
      ControlValue("lbWeb/LHCb_RunInfo_HLTFarm_hltRate", type: double);
  static final architecture =
      ControlValue("lbWeb/LHCb_RunInfo_EB_architecture");

  static final List<ControlValue> allValues = [
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
    dataType,
    runNumber,
    partId,
    odinData,
    nrOfEvents,
    inputRate,
    hltNTriggers,
    outputRate,
    architecture
  ];

  // This loads the selected colorscheme from the settings
  static void loadColorScheme({Function colorStateMap = defaultColorStateMap}) {
    ColorScheme colorScheme;
    switch (settings.COLORSETTING) {
      case settings.ColorSchemes.ECSColors:
        colorScheme = ECSColorScheme;
        break;
      case settings.ColorSchemes.craverColors:
        colorScheme = craverColorScheme;
        break;
      default:
        colorScheme = ECSColorScheme;
    }
    for (var controlValue in allValues) {
      controlValue.colorStateMap = colorStateMap(colorScheme);
    }
  }

  ControlValues() {
    loadColorScheme();
  }
}

class ColorScheme {
  // "GREEN"-ish
  // Color that the system MUST be in when the detector is taking data
  final Color running;
  // "BLUE"-ish
  // Color that the system is in while we are NOT RUNNING, but could start
  final Color ready;
  // "YELLOW"-ish
  // Intermediate points between off/unkown and ready (or running and ready)
  final Color notReady;
  // "RED"-ish
  // Abnomal situation
  final Color abnomal;
  // "BLUE" again?
  // Off
  final Color off;
  // "Orange"-ish
  // Unkown
  final Color unknown;

  const ColorScheme({
    required this.running,
    required this.ready,
    required this.notReady,
    required this.abnomal,
    required this.off,
    required this.unknown,
  });
}

const Color defaultColor = ui.Color.fromARGB(255, 97, 97, 97);

const ColorScheme ECSColorScheme = ColorScheme(
  running: ui.Color.fromARGB(255, 0, 204, 153),
  ready: ui.Color.fromARGB(255, 51, 153, 255),
  notReady: ui.Color.fromARGB(255, 255, 153, 0),
  abnomal: ui.Color.fromARGB(255, 255, 0, 0),
  off: ui.Color.fromARGB(255, 51, 153, 255),
  unknown: ui.Color.fromARGB(255, 255, 153, 0),
);

const ColorScheme craverColorScheme = ColorScheme(
    running: Colors.teal,
    ready: Colors.indigo,
    notReady: Colors.orange,
    abnomal: ui.Color.fromARGB(255, 197, 28, 53),
    off: Colors.blueGrey,
    unknown: Colors.purple);

class RunStates {
  static const String RUNNING = "RUNNING";
  static const String READY = "READY";
  static const String ACTIVE = "ACTIVE";
  static const String RAMPING_READY = "RAMPING_READY";
  static const String CONFIGURING = "CONFIGURING";
  static const String ALLOCATING = "ALLOCATING";
  static const String STOPPING = "STOPPING";
  static const String NOT_ALLOCATED = "NOT_ALLOCATED";
  static const String NOT_READY = "NOT_READY";
  static const String ERROR = "ERROR";
  static const String EMERGENCY_OFF = "EMERGENCY_OFF";
  static const String OFF = "OFF";
  static const String UNKOWN = "UNKOWN";
}

Map<String, Color> defaultColorStateMap(ColorScheme colorScheme) {
  return {
    RunStates.RUNNING: colorScheme.running,
    RunStates.READY: colorScheme.ready,
    RunStates.ACTIVE: colorScheme.ready,
    RunStates.RAMPING_READY: colorScheme.notReady,
    RunStates.CONFIGURING: colorScheme.notReady,
    RunStates.ALLOCATING: colorScheme.notReady,
    RunStates.STOPPING: colorScheme.notReady,
    RunStates.NOT_ALLOCATED: colorScheme.notReady,
    RunStates.NOT_READY: colorScheme.notReady,
    RunStates.ERROR: colorScheme.abnomal,
    RunStates.EMERGENCY_OFF: colorScheme.abnomal,
    RunStates.OFF: colorScheme.off,
    RunStates.UNKOWN: colorScheme.unknown,
  };
}
