// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../support/settings.dart' as settings;
//import 'dart:developer' as dev;

class ControlValue {
  // AControlValue has a long name like: "lbWeb/LHCb|LHCb_fsm_currentState",
  // a color, and a value that can either be a number or a string such as
  // 3.5 or "NOT_READY"
  final String dimPath;
  final String shortName;
  final String? longName;
  final Type type;
  String? sValue;
  double get numValue => double.tryParse(sValue ?? 'null') ?? 0;

  // Tells what color the different states should have for this controll value
  Map<String, Color> colorStateMap;
  ControlValue(
      {required this.dimPath,
      required this.shortName,
      this.longName,
      this.type = String,
      colorScheme = ECSColorScheme})
      : colorStateMap = defaultColorStateMap(colorScheme),
        assert(type == double || type == String);

  @override
  String toString() {
    return "'$dimPath'";
  }
}

class ControlValues {
  // Use this to know when the values have been updated
  // For simplicity, we assume all values update at the same time
  // at a similar rate. (The numerical value will never be used)
  static final ValueNotifier<int> updater = ValueNotifier<int>(0);

  // These are the values we want to pull from the control panel (Through DIM)
  // They default to string type values like 'RUNNING', but you need to
  // specify them as double if they should be parsed. eg: '41236'

  static final LHCbState = ControlValue(
      dimPath: "lbWeb/LHCb|LHCb_fsm_currentState",
      shortName: 'LHCb',
      longName: 'Large Hadron Collider beauty experiment');

  static final DAQState = ControlValue(
      dimPath: "lbWeb/LHCb|LHCb_DAQ|LHCb_DAQ_fsm_currentState",
      shortName: 'DAQ',
      longName: 'Data Acquisition System');

  static final DAQ_VA_State = ControlValue(
      dimPath: "lbWeb/LHCb_DAQ|VELOA_DAQ|VELOA_DAQ_fsm_currentState",
      shortName: 'VELOA',
      longName: 'VErtex LOcator A');

  static final DAQ_VC_State = ControlValue(
      dimPath: "lbWeb/LHCb_DAQ|VELOC_DAQ|VELOC_DAQ_fsm_currentState",
      shortName: 'VELOC',
      longName: 'VErtex LOcator C');

  static final DAQ_R1_State = ControlValue(
      dimPath: "lbWeb/LHCb_DAQ|RICH1_DAQ|RICH1_DAQ_fsm_currentState",
      shortName: 'RICH1',
      longName: 'Ring Imaging Cherenkov 1');

  static final DAQ_R2_State = ControlValue(
      dimPath: "lbWeb/LHCb_DAQ|RICH2_DAQ|RICH2_DAQ_fsm_currentState",
      shortName: 'RICH2',
      longName: 'Ring Imaging Cherenkov 2');

  static final DAQ_TDET_State = ControlValue(
      //UNUSED
      dimPath: "lbWeb/LHCb_DAQ|TDET_DAQ|TDET_DAQ_fsm_currentState",
      shortName: 'TDET',
      longName: 'Test Detector');

  static final DAQ_UTA_State = ControlValue(
      //UNUSED
      dimPath: "lbWeb/LHCb_DAQ|UTA_DAQ|UTA_DAQ_fsm_currentState",
      shortName: 'UTA',
      longName: 'Upstream Tracker A');

  static final DAQ_UTC_State = ControlValue(
      dimPath: "lbWeb/LHCb_DAQ|UTC_DAQ|UTC_DAQ_fsm_currentState",
      shortName: 'UTC',
      longName: 'Upstream Tracker C');

  static final DAQ_SFA_State = ControlValue(
      dimPath: "lbWeb/LHCb_DAQ|SFA_DAQ|SFA_DAQ_fsm_currentState",
      shortName: 'SFA',
      longName: 'Scintillating-Fibre particle-tracking detector / SciFi A');

  static final DAQ_SFC_State = ControlValue(
      dimPath: "lbWeb/LHCb_DAQ|SFC_DAQ|SFC_DAQ_fsm_currentState",
      shortName: 'SFC',
      longName: 'Scintillating-Fibre particle-tracking detector / SciFi C');

  static final DAQ_MA_State = ControlValue(
      dimPath: "lbWeb/LHCb_DAQ|MUONA_DAQ|MUONA_DAQ_fsm_currentState",
      shortName: 'MUONA',
      longName: 'Muon Detector A');

  static final DAQ_MC_State = ControlValue(
      dimPath: "lbWeb/LHCb_DAQ|MUONC_DAQ|MUONC_DAQ_fsm_currentState",
      shortName: 'MUONC',
      longName: 'Muon Detector C');

  static final DAQ_EC_State = ControlValue(
      dimPath: "lbWeb/LHCb_DAQ|ECAL_DAQ|ECAL_DAQ_fsm_currentState",
      shortName: 'ECAL',
      longName: 'Electromagnetic Calorimeter');

  static final DAQ_HC_State = ControlValue(
      dimPath: "lbWeb/LHCb_DAQ|HCAL_DAQ|HCAL_DAQ_fsm_currentState",
      shortName: 'HCAL',
      longName: 'Hadron Calorimeter');

  static final DAQ_PL_State = ControlValue(
      dimPath: "lbWeb/LHCb_DAQ|PLUME_DAQ|PLUME_DAQ_fsm_currentState",
      shortName: 'PLUME',
      longName: 'Probe for LUminosity MEasurement');

  static final DAIState = ControlValue(
      dimPath: "lbWeb/LHCb|LHCb_DAI|LHCb_DAI_fsm_currentState",
      shortName: 'DAI',
      longName: "Demande d'Achat Interne");

  static final DCSState = ControlValue(
      dimPath: "lbWeb/LHCb|LHCb_DCS|LHCb_DCS_fsm_currentState",
      shortName: 'DCS',
      longName: 'Detector Control System');

  static final EBState = ControlValue(
      dimPath: "lbWeb/LHCb|LHCb_EB|LHCb_EB_fsm_currentState",
      shortName: 'EB',
      longName: 'Event Builder System');

  static final HVState = ControlValue(
      dimPath: "lbWeb/LHCb|LHCb_HV|LHCb_HV_fsm_currentState",
      shortName: 'HV',
      longName: 'High Voltage System');

  static final TFCState = ControlValue(
      dimPath: "lbWeb/LHCb|LHCb_TFC|LHCb_TFC_fsm_currentState",
      shortName: 'TFC',
      longName: 'Timing Fast Control System');

  static final MonitoringState = ControlValue(
      dimPath: "lbWeb/LHCb|LHCb_Monitoring|LHCb_Monitoring_fsm_currentState",
      shortName: 'Monitoring');

  static final runType = ControlValue(
      dimPath: "lbWeb/LHCb_RunInfo_general_runType", shortName: 'runType');

  static final dataType = ControlValue(
      dimPath: "lbWeb/LHCb_RunInfo_general_dataType", shortName: 'dataType');

  static final runNumber = ControlValue(
      dimPath: "lbWeb/LHCb_RunInfo_general_runNumber",
      shortName: 'Run number',
      type: double);

  static final partId = ControlValue(
      dimPath: "lbWeb/LHCb_RunInfo_general_partId",
      shortName: 'Particle ID',
      type: double);

  static final odinData = ControlValue(
      dimPath: "lbWeb/LHCb_RunInfo_TFC_odinData",
      shortName: 'Odin Data',
      longName: 'Readout Supervisor',
      type: double);

  static final nrOfEvents = ControlValue(
      dimPath: "lbWeb/LHCb_RunInfo_TFC_nTriggers",
      shortName: 'Number of events',
      longName: 'nTriggers',
      type: double);

  static final inputRate = ControlValue(
      dimPath: "lbWeb/LHCb_RunInfo_TFC_triggerRate",
      shortName: 'Input rate',
      longName: 'triggerRate',
      type: double);

  static final hltNTriggers = ControlValue(
      dimPath: "lbWeb/LHCb_RunInfo_HLTFarm_hltNTriggers",
      shortName: 'Number of high level triggers',
      longName: 'hltNTriggers',
      type: double);

  static final outputRate = ControlValue(
      dimPath: "lbWeb/LHCb_RunInfo_HLTFarm_hltRate",
      shortName: 'Output rate',
      longName: 'hltRate',
      type: double);

  static final architecture = ControlValue(
      dimPath: "lbWeb/LHCb_RunInfo_EB_architecture",
      shortName: 'Architecture',
      longName: 'Event builder architecture');

  static final List<ControlValue> allValues = [
    LHCbState,
    DAQState,
    DAQ_EC_State,
    DAQ_HC_State,
    DAQ_MA_State,
    DAQ_MC_State,
    DAQ_PL_State,
    DAQ_R1_State,
    DAQ_R2_State,
    DAQ_SFA_State,
    DAQ_SFC_State,
    DAQ_TDET_State,
    DAQ_UTA_State,
    DAQ_UTC_State,
    DAQ_VA_State,
    DAQ_VC_State,
    DAIState,
    DCSState,
    EBState,
    HVState,
    TFCState,
    MonitoringState,
    runType,
    dataType,
    architecture,
    runNumber,
    partId,
    odinData,
    nrOfEvents,
    inputRate,
    hltNTriggers,
    outputRate,
  ];

  // This loads the selected colorscheme from the settings
  static void loadColorScheme({Function colorStateMap = defaultColorStateMap}) {
    ColorScheme colorScheme = getCurrentColorScheme();
    for (var controlValue in allValues) {
      controlValue.colorStateMap = colorStateMap(colorScheme);
    }
    // This is usefull to update the server allowed states
    //dev.log(allValues.toString());
  }

  ControlValues() {
    loadColorScheme();
  }
}

getCurrentColorScheme() {
  return getColorScheme(settings.controlColors);
}

ColorScheme getColorScheme(settings.ColorSchemes option) {
  ColorScheme colorScheme;
  switch (option) {
    case settings.ColorSchemes.ECS:
      colorScheme = ECSColorScheme;
      break;
    case settings.ColorSchemes.Craver:
      colorScheme = craverColorScheme;
      break;
    default:
      colorScheme = ECSColorScheme;
  }
  return colorScheme;
}

class ColorScheme {
  // "GREEN"-ish
  // Color that the system MUST be in when the detector is taking data
  final Color running;
  // "BLUE"-ish
  // Color that the system is in while we are NOT RUNNING, but could start
  final Color ready;
  // "YELLOW"-ish
  // Intermediate points between off/unknown and ready (or running and ready)
  final Color notReady;
  // "RED"-ish
  // Abnomal situation
  final Color abnomal;
  // "BLUE" again?
  // Off
  final Color off;
  // "Orange"-ish
  // Unknown
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

Color defaultColor = Colors.grey;

const ColorScheme ECSColorScheme = ColorScheme(
  running: ui.Color.fromARGB(255, 0, 204, 153),
  ready: ui.Color.fromARGB(255, 51, 153, 255),
  notReady: ui.Color.fromARGB(255, 255, 255, 153),
  abnomal: ui.Color.fromARGB(255, 255, 0, 0),
  off: ui.Color.fromARGB(255, 51, 153, 255),
  unknown: ui.Color.fromARGB(255, 255, 153, 0),
);

ColorScheme craverColorScheme = ColorScheme(
    running: Colors.teal,
    ready: const ui.Color.fromARGB(255, 68, 98, 174),
    notReady: Colors.amber[200]!,
    abnomal: const ui.Color.fromARGB(255, 197, 28, 53),
    off: Colors.blueGrey,
    unknown: Colors.orange);

enum RunStates {
  RUNNING,
  READY,
  ACTIVE,
  RAMPING_READY,
  CONFIGURING,
  ALLOCATING,
  STOPPING,
  NOT_ALLOCATED,
  NOT_READY,
  ERROR,
  EMERGENCY_OFF,
  OFF,
  DEAD,
  UNKNOWN,
}

List<String> allRunstates = List<String>.generate(
    RunStates.values.length, (index) => RunStates.values[index].name);

Map<String, Color> defaultColorStateMap(ColorScheme colorScheme) {
  return {
    RunStates.RUNNING.name: colorScheme.running,
    RunStates.READY.name: colorScheme.ready,
    RunStates.ACTIVE.name: colorScheme.ready,
    RunStates.RAMPING_READY.name: colorScheme.notReady,
    RunStates.CONFIGURING.name: colorScheme.notReady,
    RunStates.ALLOCATING.name: colorScheme.notReady,
    RunStates.STOPPING.name: colorScheme.notReady,
    RunStates.NOT_ALLOCATED.name: colorScheme.notReady,
    RunStates.NOT_READY.name: colorScheme.notReady,
    RunStates.ERROR.name: colorScheme.abnomal,
    RunStates.EMERGENCY_OFF.name: colorScheme.abnomal,
    RunStates.OFF.name: colorScheme.off,
    RunStates.DEAD.name: colorScheme.off,
    RunStates.UNKNOWN.name: colorScheme.unknown,
  };
}

class ColorPreview extends StatelessWidget {
  final ColorScheme cs; // ColorScheme
  const ColorPreview(this.cs, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      cs.running,
      cs.ready,
      cs.notReady,
      cs.abnomal,
      cs.off,
      cs.unknown,
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Container>.generate(colors.length, (index) {
        return Container(
          height: 10,
          width: 10,
          color: colors[index],
        );
      }),
    );
  }
}
