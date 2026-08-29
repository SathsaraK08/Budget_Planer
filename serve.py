import http.server
import socketserver
import webbrowser
import os

PORT = 8080
DIRECTORY = os.path.join(os.path.dirname(__file__), "web")

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

def run():
    print(f"=======================================================")
    print(f"  Household Budget Planner (25th-to-25th Cycle Tracker)")
    print(f"  Running locally at: http://localhost:{PORT}")
    print(f"=======================================================")
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        try:
            webbrowser.open(f"http://localhost:{PORT}")
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")

if __name__ == "__main__":
    run()
