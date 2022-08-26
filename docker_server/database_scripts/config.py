import os
'''
Use environment variables (eg. CLIENT_USER_PASSWORD) to
configure instead of editing this file.

Default values are provided below as an example of what
was used under development.
'''


if(os.getenv('SERVER_SECRET_KEY')):
        SERVER_SECRET_KEY = os.getenv('SERVER_SECRET_KEY')
else:
        SERVER_SECRET_KEY = None
        raise ValueError('No server key provided. Please set the SERVER_SECRET_KEY environment variable.')

