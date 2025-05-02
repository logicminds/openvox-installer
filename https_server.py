#!/usr/bin/env python3

import http.server
import ssl

port = 443
server_address = ('', port)

httpd = http.server.HTTPServer(server_address, http.server.SimpleHTTPRequestHandler)

# Create SSL context
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(certfile='cert.pem', keyfile='cert.key')

# Wrap the socket with the context
httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

print(f"🔐 Serving HTTPS on port {port} ...")
httpd.serve_forever()