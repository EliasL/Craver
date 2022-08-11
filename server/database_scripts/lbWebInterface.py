#!/usr/bin/env python3
#
# dim2pr: simple-minded DIM to Prometheus bridge
#
from pydim import dis_set_dns_node, dic_info_service
import os
import time
import logging
logging.basicConfig(level=logging.DEBUG)

DIM_DNS_NODE = os.environ.get("DIM_DNS_NODE", "ecs04.lbdaq.cern.ch")

DIM_SERVICES_GAUGE = [
    "lbWeb/LHCb_RunInfo_HLTFarm_hltNTriggers",
    "lbWeb/LHCb_RunInfo_HLTFarm_hltRates"
]

DIM_SERVICES_ENUM = [
    ("lbWeb/LHCb|LHCb_DAQ|LHCb_DAQ_fsm_currentState", ["RUNNING", "UNKNOWN"]),
    ("lbWeb/LHCb|LHCb_DAQ|LHCb_DAI_fsm_currentState", ["RUNNING", "UNKNOWN"])
]

# dim_services_clean = ['dim_' + service.replace("/", "_").replace("|", "_").lower() for service in DIM_SERVICES]
def clean_service_name(service_name):
    '''
    Preparing the service name for prometheus.
    For a prometheus metric name to be valid it needs to match the [a-zA-Z_:][a-zA-Z0-9_:]* regex.
    To protect against future facepalms, will also convert to lowercase and prepend  dim_
    '''
    return 'dim_' + service_name.replace("/", "_").replace("|", "_").lower()




def main():
    logging.info('Setting DIM DNS to %s' % DIM_DNS_NODE)
    dis_set_dns_node(DIM_DNS_NODE)
    
    for service in DIM_SERVICES_GAUGE:
        clean_name = clean_service_name(service)
        dic_info_service(service,  'test', timeout=10, default=-1)

if __name__ == '__main__':
    main()
