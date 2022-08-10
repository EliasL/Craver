#!/usr/bin/env python3
#
# dim2pr: simple-minded DIM to Prometheus bridge
#
from prometheus_client import Enum, Gauge, start_http_server
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

gauges = {}
def create_gauges():
    '''Create prometheus gauges with initial values'''
    logging.info("Creating and initializing gauges")
    for service in DIM_SERVICES_GAUGE:
        clean_name = clean_service_name(service)
        gauges[clean_name] = Gauge(clean_name, 'Value coming from DIM')
        gauges[clean_name].set(-1)
        logging.debug("Will try to fetch: %s" % service)
        dic_info_service(service,  gauges[clean_name].set, timeout=10, default=-1)

enums = {}
def create_enums():
    '''Create prometheus gauges with initial values'''
    logging.info("Creating and initializing gauges")
    for service in DIM_SERVICES_ENUM:
        clean_name = clean_service_name(service[0])
        enums[clean_name] = Enum(clean_name, 'State coming from DIM', states=service[1])
        enums[clean_name].state("UNKNOWN")
        logging.debug("Will try to fetch: %s" % service[0])
        dic_info_service(service[0],  'C:7', enums[clean_name].state, timeout=10, default="UNKNOWN")

def main():
    logging.info('Setting DIM DNS to %s' % DIM_DNS_NODE)
    dis_set_dns_node(DIM_DNS_NODE)
    time.sleep(1)
    create_gauges()
    create_enums()

    time.sleep(11)
    logging.info("Starting Prometheus Server")
    start_http_server(8000)

    while True:
        time.sleep(1000)

if __name__ == '__main__':
    main()
