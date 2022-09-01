import os
# ---- Authentication settings
# https://gitlab.cern.ch/authzsvc/docs/flask-oidc-api-example/-/blob/master/oidc_example/config.py
DEBUG = False

CSRF_ENABLED = True

# Use a secure, unique and absolutely secret key for
# signing the data.
CSRF_SESSION_KEY = os.getenv('CSRF_SESSION_KEY')

# Secret key for signing cookies
SECRET_KEY = os.getenv('SECRET_KEY')


# OIDC configuration
OIDC_CLIENT_ID = "craver"
OIDC_JWKS_URL = "https://auth.cern.ch/auth/realms/cern/protocol/openid-connect/certs"
OIDC_ISSUER = "https://auth.cern.ch/auth/realms/cern"


