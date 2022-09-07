from ast import arg
from lblogbookInterface import LbLogbook
from prometheusInterface import Prometheus
from controlPanelInterface import ControlPanel
import werkzeug.exceptions as ex
from flask import Flask, request, redirect, abort
import json
import datetime
import threading
from auth import oidc_validate
import config as c

# These are all the versions of the app that this server is 
# compatible with. It is a comma separated value. Eg. '0.6,1.2,0.01'
SERVER_VERSIONS = '1.0' 

app = Flask(__name__)
app.config.update(
    DEBUG = c.DEBUG,

    CSRF_ENABLED = c.CSRF_ENABLED,

    # Use a secure, unique and absolutely secret key for
    # signing the data.
    CSRF_SESSION_KEY = c.CSRF_SESSION_KEY,

    # Secret key for signing cookies
    SECRET_KEY = c.SECRET_KEY,

    # OIDC configuration
    OIDC_CLIENT_ID = c.OIDC_CLIENT_ID,
    OIDC_JWKS_URL = c.OIDC_JWKS_URL,
    OIDC_ISSUER = c.OIDC_ISSUER,
)

P = Prometheus()
L = LbLogbook()
C = ControlPanel()



def cache_clearing(clear_counter):
    # We clear the cache for Prometheus and the logbook
    # only every 20 second, where as the control panel is
    # updated every second.
    if clear_counter % 20 == 0:
        P.get.cache_clear()
        L.get.cache_clear()
    C.get.cache_clear()
    clear_counter +=1
    threading.Timer(1, cache_clearing, args=((clear_counter,))).start()

def badArgs(*args):
    # Honestly, i dont remember why this is here, but
    # maybe it's useful
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
@oidc_validate
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

    return P.get(command, time)

@app.route("/lblogbook", methods = ['GET'])
@oidc_validate
def get_lblogbook_data():
    
    args = request.args.to_dict()
    page = args['page']
    if badArgs(page):
        abort(400)
    return L.get(page)

@app.route("/control_panel", methods = ['GET'])
# To reenable token requirement for the DIM values, uncomment the line below
#@oidc_validate
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
    cache_clearing(0)
    serve(app, host="0.0.0.0", port=8080, threads=8, connection_limit=1000, backlog=4000)