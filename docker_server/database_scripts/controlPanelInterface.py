import urllib.request
import json
import functools
import os

allowed_states =   [
    'lbWeb/LHCb|LHCb_fsm_currentState',
    'lbWeb/LHCb|LHCb_DAQ|LHCb_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|ECAL_DAQ|ECAL_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|HCAL_DAQ|HCAL_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|MUONA_DAQ|MUONA_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|MUONC_DAQ|MUONC_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|PLUME_DAQ|PLUME_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|RICH1_DAQ|RICH1_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|RICH2_DAQ|RICH2_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|SFA_DAQ|SFA_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|SFC_DAQ|SFC_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|TDET_DAQ|TDET_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|UTA_DAQ|UTA_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|UTC_DAQ|UTC_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|VELOA_DAQ|VELOA_DAQ_fsm_currentState',
    'lbWeb/LHCb_DAQ|VELOC_DAQ|VELOC_DAQ_fsm_currentState',
    'lbWeb/LHCb|LHCb_DAI|LHCb_DAI_fsm_currentState',
    'lbWeb/LHCb|LHCb_DCS|LHCb_DCS_fsm_currentState',
    'lbWeb/LHCb|LHCb_EB|LHCb_EB_fsm_currentState',
    'lbWeb/LHCb|LHCb_HV|LHCb_HV_fsm_currentState',
    'lbWeb/LHCb|LHCb_TFC|LHCb_TFC_fsm_currentState',
    'lbWeb/LHCb|LHCb_Monitoring|LHCb_Monitoring_fsm_currentState',
    'lbWeb/LHCb_RunInfo_general_runType',
    'lbWeb/LHCb_RunInfo_general_dataType',
    'lbWeb/LHCb_RunInfo_EB_architecture',
    'lbWeb/LHCb_RunInfo_general_runNumber',
    'lbWeb/LHCb_RunInfo_general_partId',
    'lbWeb/LHCb_RunInfo_TFC_odinData',
    'lbWeb/LHCb_RunInfo_TFC_nTriggers',
    'lbWeb/LHCb_RunInfo_TFC_triggerRate',
    'lbWeb/LHCb_RunInfo_HLTFarm_hltNTriggers',
    'lbWeb/LHCb_RunInfo_HLTFarm_hltRate'
  ]
assert ',' not in ''.join(allowed_states), "We use ',' to separate states. Talk to Aristeidis Fkiaras to change."

class ControlPanel:
    def __init__(self) -> None:
        if 'CONTROL_PANEL_SOURCE' in os.environ:
            self.control_panel_source = os.environ['CONTROL_PANEL_SOURCE']
        else:
            self.control_panel_source = 'http://10.128.97.112:8181'

    @functools.lru_cache(maxsize = None)
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

        url = f"{self.control_panel_source}/dims?query={states}"
        contents = urllib.request.urlopen(url)
        contents = json.load(contents)
        return contents

if __name__ == '__main__':
    p = ControlPanel()
    
    for state in allowed_states:
        j=p.get(state)
        print(j)