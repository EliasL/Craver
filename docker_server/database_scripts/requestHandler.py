from ast import arg
from tables import Tables
from dbInterface import Database
from config import client_user
from lblogbookInterface import LbLogbook
from prometheusInterface import Prometheus
from controlPanelInterface import ControlPanel
from flask import Flask, request, redirect
import json
import datetime



app = Flask(__name__)
P = Prometheus()
L = LbLogbook()
C = ControlPanel()

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

    return P.get(command, args, time)

@app.route("/lblogbook", methods = ['GET'])
def get_lblogbook_data():
    
    args = request.args.to_dict()
    page = args['page']
    return L.get(page)


@app.route("/control_panel", methods = ['GET'])
def get_control_panel_data():
    
    args = request.args.to_dict()
    state = args['state']
    return C.get(state)



if __name__ == '__main__':
    from waitress import serve
    #app.run(host="0.0.0.0", port=8080)
    serve(app, host="0.0.0.0", port=8080)