import urllib.request
import json

class ControlPanel:
    def __init__(self) -> None:
        pass

    def get(self, state):
        '''
        Connects to a script using DIM to query various values
        and forwards them here.

        Example 
        get('lbWeb/LHCb_RunInfo_general_partId')
        
        '''
        url = f"http://10.128.97.112:8181/dim?query={state}"
        contents = urllib.request.urlopen(url).read()
        return contents

if __name__ == '__main__':
    p = ControlPanel()
    states = ["lbWeb/LHCb|LHCb_fsm_currentState",
    "lbWeb/LHCb|LHCb_DAQ|LHCb_DAQ_fsm_currentState",
    "lbWeb/LHCb|LHCb_DAI|LHCb_DAI_fsm_currentState",
    "lbWeb/LHCb|LHCb_DCS|LHCb_DCS_fsm_currentState",
    "lbWeb/LHCb|LHCb_EB|LHCb_EoB_fsm_currentState",
    "lbWeb/LHCb|LHCb_HV|LHCb_HV_fsm_currentState",
    "lbWeb/LHCb|LHCb_TFC|LHCb_TFC_fsm_currentState",
    "lbWeb/LHCb|LHCb_Monitoring|LHCb_Monitoring_fsm_currentState",
    "lbWeb/LHCb_DAQ|<SD>_DAQ|<SD>_DAQ_fsm_currentState",
    "lbWeb/LHCb_RunInfo_general_runType",
    "lbWeb/LHCb_RunInfo_general_dataType",
    "lbWeb/LHCb_RunInfo_general_runNumber",
    "lbWeb/LHCb_RunInfo_general_partId",
    "lbWeb/LHCb_RunInfo_TFC_odinData",
    "lbWeb/LHCb_RunInfo_TFC_nTriggers",
    "lbWeb/LHCb_RunInfo_TFC_triggerRate",
    "lbWeb/LHCb_RunInfo_HLTFarm_hltNTriggers",
    "lbWeb/LHCb_RunInfo_HLTFarm_hltRate",
    "lbWeb/LHCb_RunInfo_EB_architecture"]
    
    for state in states:
        j=p.get(state)
        print(j)