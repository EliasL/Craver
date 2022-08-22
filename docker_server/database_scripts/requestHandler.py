from ast import arg
from tables import Tables
from dbInterface import Database
from config import client_user
from lblogbookInterface import LbLogbook
from prometheusInterface import Prometheus
from controlPanelInterface import ControlPanel
import werkzeug.exceptions as ex
from flask import Flask, request, redirect, abort
import json
import datetime

class PaymentRequired(ex.HTTPException):
    code = 400
    description = 'Invalid argument'

abort.mappings[400] = PaymentRequired

# These are all the versions of the app that this server is 
# compatible with. It is a comma separated value. Eg. '0.6,1.2,0.01'
SERVER_VERSIONS = '0.6' 

app = Flask(__name__)
P = Prometheus()
L = LbLogbook()
C = ControlPanel()


def badArgs(*args):
    return None in args


@app.errorhandler(400)
def payme(e):
    return 'Invalid argument'

@app.route("/")
def home_page():
    return redirect("https://home.web.cern.ch/")

# Example: /prometheus_query?command=up&instance=aseb03.lbdaq.cern.ch&time=4
# Example: /prometheus_query?command=up
@app.route("/prometheus_query", methods = ['GET'])
def get_prometheus_data():
    # Convert arguments to dict
    args = request.args.to_dict()

    # We extract command and time and leave the rest as they are
    command = args['command']
    del args['command']
    if 'time' in args:
        time = args['time']
        del args['time']
    else:
        time=None

    if badArgs(command):
        abort(400)

    return P.get(command, args, time)

@app.route("/lblogbook", methods = ['GET'])
def get_lblogbook_data():
    
    args = request.args.to_dict()
    page = args['page']
    if badArgs(page):
        abort(400)
    return L.get(page)

@app.route("/control_panel", methods = ['GET'])
def get_control_panel_data():
    
    args = request.args.to_dict()
    states = args['states']
    if badArgs(states):
        abort(400)
    return C.get(states)

@app.route("/version",)
def get_compatibale_versions():
    return SERVER_VERSIONS


if __name__ == '__main__':
    from waitress import serve
    #app.run(host="0.0.0.0", port=8080)
    serve(app, host="0.0.0.0", port=8080, threads=8, connection_limit=1000, backlog=4000)