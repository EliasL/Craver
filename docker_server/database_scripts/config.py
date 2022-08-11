import os
'''
Use environment variables (eg. CLIENT_USER_PASSWORD) to
configure instead of editing this file.

Default values are provided below as an example of what
was used under development.


client_user = {
        'username': 'client',
        'host'    : 'dbod-cern-dataviewer.cern.ch',
        'port'    : 5502,
        'database': 'dataviewerdata',
        'password': '-REMOVED-'
}

SERVER_SECRET_KEY = '-REMOVED-'
'''

client_user_username = os.getenv('CLIENT_USER_USERNAME', 'client')
client_user_host = os.getenv('CLIENT_USER_HOST', 'dbod-cern-dataviewer.cern.ch')
client_user_port = os.getenv('CLIENT_USER_PORT', '5502')
client_user_database = os.getenv('CLIENT_USER_DATABASE', 'dataviewerdata')

if(os.getenv('CLIENT_USER_PASSWORD')):
        client_user_password = os.getenv('CLIENT_USER_PASSWORD')
else:
        client_user_password = None
        raise ValueError('No password provided. Please set the CLIENT_USER_PASSWORD environment variable.')

client_user = {
        'username': client_user_username,
        'host'    : client_user_host,
        'port'    : client_user_port,
        'database': client_user_database,
        'password': client_user_password
}


if(os.getenv('SERVER_SECRET_KEY')):
        SERVER_SECRET_KEY = os.getenv('SERVER_SECRET_KEY')
else:
        SERVER_SECRET_KEY = None
        raise ValueError('No server key provided. Please set the SERVER_SECRET_KEY environment variable.')

