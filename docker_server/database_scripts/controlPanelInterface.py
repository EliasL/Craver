import urllib.request
import json

allowed_states = [
    'lbWeb/LHCb|LHCb_fsm_currentState',
    'lbWeb/LHCb|LHCb_DAQ|LHCb_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|EC_DAQ|EC_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|HC_DAQ|HC_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|MA_DAQ|MA_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|MC_DAQ|MC_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|PL_DAQ|PL_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|R1_DAQ|R1_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|R2_DAQ|R2_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|SFA_DAQ|SFA_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|SFC_DAQ|SFC_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|UTA_DAQ|UTA_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|UTC_DAQ|UTC_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|VA_DAQ|VA_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|VC_DAQ|VC_DAQ_fsm_currentState',
    'lbWeb/LHCb|LHCb_DAI|LHCb_DAI_fsm_currentState',
    'lbWeb/LHCb|LHCb_DCS|LHCb_DCS_fsm_currentState',
    'lbWeb/LHCb|LHCb_EB|LHCb_EB_fsm_currentState',
    'lbWeb/LHCb|LHCb_HV|LHCb_HV_fsm_currentState',
    'lbWeb/LHCb|LHCb_TFC|LHCb_TFC_fsm_currentState',
    'lbWeb/LHCb|LHCb_Monitoring|LHCb_Monitoring_fsm_currentState',
    'lbWeb/LHCb_RunInfo_general_runType',
    'lbWeb/LHCb_RunInfo_general_dataType',
    'lbWeb/LHCb_RunInfo_general_runNumber',
    'lbWeb/LHCb_RunInfo_general_partId',
    'lbWeb/LHCb_RunInfo_TFC_odinData',
    'lbWeb/LHCb_RunInfo_TFC_nTriggers',
    'lbWeb/LHCb_RunInfo_TFC_triggerRate',
    'lbWeb/LHCb_RunInfo_HLTFarm_hltNTriggers',
    'lbWeb/LHCb_RunInfo_HLTFarm_hltRate',
    'lbWeb/LHCb_RunInfo_EB_architecture'
  ]

assert ',' not in ''.join(allowed_states), "We use ',' to separate states. Talk to Aristeidis Fkiaras to change."

class ControlPanel:
    def __init__(self) -> None:
        pass

    def get(self, states):
        '''
        Connects to a script using DIM to query various values
        and forwards them here.

        Example 
        get('lbWeb/LHCb_RunInfo_general_partId,lbWeb/LHCb|LHCb_DAQ|LHCb_DAQ_fsm_currentState')
        '''

        #TODO If the server is slow, perhaps this can be optimized
        for state in states.split(','):
            if state not in allowed_states:
                return f'Not allowed state: {state}'

        url = f"http://10.128.97.112:8181/dims?query={states}"
        contents = urllib.request.urlopen(url)
        contents = json.load(contents)
        return contents

if __name__ == '__main__':
    p = ControlPanel()
    
    for state in allowed_states:
        j=p.get(state)
        print(j)