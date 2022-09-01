import logging

import requests
from authlib.jose import jwk, jwt
from authlib.oidc.core import ImplicitIDToken, UserInfo
from flask import current_app, request, Response, jsonify


class ImplicitIDTokenNoNonce(ImplicitIDToken):
    """
    Don't validate the nonce claim as it's not coming with the token
    """

    ESSENTIAL_CLAIMS = ["iss", "sub", "aud", "exp", "iat"]

def parse_id_token(id_token):
    def load_key(header, payload):
        jwk_set = requests.get(current_app.config["OIDC_JWKS_URL"]).json()
        test = jwk.loads(jwk_set, header.get("kid"))
        return jwk.loads(jwk_set, header.get("kid"))

    claims_params = {"client_id": current_app.config["OIDC_CLIENT_ID"]}
    claims_cls = ImplicitIDTokenNoNonce
    claims_options = {
        "iss": {"values": [current_app.config["OIDC_ISSUER"]]},
        "nonce": {"validate": lambda x: True},
    }

    claims = jwt.decode(
        id_token,
        key=load_key,
        claims_cls=claims_cls,
        claims_options=claims_options,
        claims_params=claims_params,
    )
    claims.validate(leeway=120)
    return UserInfo(claims)


def oidc_validate(func):
    """
    Decorator for validation of the auth token
    """

    def function_wrapper(*args, **kwargs):
        try:
            auth_header = request.headers["Authorization"]
            token = auth_header.split("Bearer")[1].strip()
            user_info = parse_id_token(token)
        except Exception as e:
            logging.error(f"Authentication error: {e}")
            return jsonify({"status": "Authorization Denied"}), 401
        return func(*args, **kwargs)
    function_wrapper.__name__ = func.__name__
    return function_wrapper
