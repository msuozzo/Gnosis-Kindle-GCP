import json

import webapp2

# Add local "lib" directory to import path
from google.appengine.ext import vendor
vendor.add('lib')

import lector


CREDS_PATH = '.credentials.json'


def get_creds():
    """Return the username and password from the credential file.

    Returns:
        2-tuple (username, password)
    """
    with open(CREDS_PATH, 'r') as creds_file:
        creds = json.load(creds_file)
    return creds['uname'], creds['pword']


class Main(webapp2.RequestHandler):
    def get(self):
        with lector.KindleCloudReaderAPI.get_instance(*get_creds()) as kcr:
            self.response.write(str(kcr.get_library_metadata()))


app = webapp2.WSGIApplication([
    ('/', Main)
    ], debug=True)
