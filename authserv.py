#/usr/bin/python3

from http.server import *
import os
import re

class S(BaseHTTPRequestHandler):
    def do_POST(self):
        l = int(self.headers['content-length'])
        req = str(self.rfile.read(l))
        try:
            print(re.search("psk=(.+)",req).group(1)[:-1])
            print('found psk')
            if os.environ['SECRET'] == re.search("psk=(.+)",req).group(1)[:-1]:
                print('match..')
                self.send_response(201)
                self.end_headers()
            else:
                raise
        except:
                self.send_response(404)
                self.end_headers()

def run(server_class=HTTPServer, handler_class=S, port=8888):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print('Starting httpd... on port {}'.format(port))
    print('secret is : {}'.format(os.environ['SECRET']))
    httpd.serve_forever()

if __name__ == "__main__":
   run() 
