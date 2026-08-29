import http.server
import socketserver
import os
import sys

PORT = 8080
DIRECTORY = os.path.join(os.path.dirname(__file__), "web")

class BudgetAppHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        clean_path = self.path.split('?')[0].rstrip('/')
        if clean_path.lower() in ('/admin', '/admin.html', '/wp-admin'):
            self.path = '/admin.html'
        elif clean_path == '' or clean_path == '/':
            self.path = '/index.html'
        return super().do_GET()

    def end_headers(self):
        # Disable caching for instant CMS development & updates
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

def run():
    print("=" * 65)
    print("  HOUSEHOLD BUDGET PLANNER & FULL WORDPRESS-STYLE ADMIN CMS")
    print(f"  Live Frontend App : http://localhost:{PORT}/")
    print(f"  Full Admin CMS    : http://localhost:{PORT}/admin")
    print("=" * 65)
    
    # Allow socket address reuse immediately upon restart
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), BudgetAppHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
            sys.exit(0)

if __name__ == "__main__":
    run()
