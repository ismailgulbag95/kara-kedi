import http.server
import socketserver
import os
import sys

PORT = 8060
DIRECTORY = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "build", "web"))

class COOPHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        super().end_headers()

if __name__ == "__main__":
    if not os.path.exists(DIRECTORY):
        print(f"Directory {DIRECTORY} does not exist yet. Creating...")
        os.makedirs(DIRECTORY, exist_ok=True)
    
    # Allow port reuse
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("127.0.0.1", PORT), COOPHandler) as httpd:
        print(f"Serving Godot Web on http://localhost:{PORT}")
        sys.stdout.flush()
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            pass
