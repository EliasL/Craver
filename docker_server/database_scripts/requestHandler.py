from ast import arg
from tables import Tables
from dbInterface import Database
from config import client_user
from lblogbookInterface import LbLogbook
from prometheusInterface import Prometheus
from flask import Flask, request
import json
import datetime



app = Flask(__name__)
P = Prometheus()
L = LbLogbook()

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


if __name__ == '__main__':
    #Remember to disable debug sooner or later
    app.run(host="0.0.0.0", debug=True, port=8080)