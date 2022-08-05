from ast import arg
from tables import Tables
from dbInterface import Database
from config import client_user, SERVER_SECRET_KEY
from lblogbookInterface import LbLogbook
from prometheusInterface import Prometheus
from flask import Flask, request, session, Response, jsonify
import json
import datetime

from keycloak.keycloak_openid import KeycloakOpenID


app = Flask(__name__)
app.config['SECRET_KEY'] = SERVER_SECRET_KEY
keycloak_openid = KeycloakOpenID(server_url='https://auth.cern.ch/auth',
    client_id='craver',
    realm_name='cern',
    client_secret_key=SERVER_SECRET_KEY,
    )
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

@app.route("/login:/oauth2callback", methods = ['GET'])
def login_callback():
    """ Authentication callback handler """
    redirect_uri = "http://10.128.124.104:8080/login:/oauth2callback"
    
    # make a callback call to get token for our code value
    # the reponse value is a JSON dict with different attributes such as
    # access_token, refresh_token, etc.
    state = request.args.get('session_state', 'unknown')
    code = request.args.get('code', 'unknown')
    print(f'code:{code}')
    access_token = keycloak_openid.token(
        grant_type='authorization_code',
        code=code,
        redirect_uri=redirect_uri)

    # using access token make request to auth server to fetch user parameters
    userinfo = keycloak_openid.userinfo(access_token)
    print(userinfo)
    # put user information dict returned by OAuth server into our session structure
    session["user"] = userinfo

    # return userinfo to upstream caller
    return jsonify(userinfo)


if __name__ == '__main__':
    #Remember to disable debug sooner or later
    app.run(host="0.0.0.0", debug=True, port=8080)