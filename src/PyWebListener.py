import http.server
import socketserver
import os

PORT = 80
Handler = http.server.SimpleHTTPRequestHandler
httpd = socketserver.TCPServer(("", PORT), Handler)
os.system("echo 'serving at port {}'".format(PORT))
httpd.serve_forever()
