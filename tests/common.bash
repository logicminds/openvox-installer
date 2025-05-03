load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

 

setup_file() {
  # Creates /usr/local/bin/curl (which is earlier in PATH than /usr/bin/curl)
	# This wrapper script simply forwards all arguments to the real curl, with -k added
	# Works transparently with any script that runs curl

  if [ ! -f /usr/local/bin/curl.real ]; then
    echo "Creating a wrapper script for curl to bypass SSL verification"
    mv /usr/bin/curl /usr/local/bin/curl.real
    echo -e '#!/bin/bash\nexec /usr/local/bin/curl.real -k "$@"' | tee /usr/bin/curl > /dev/null && chmod +x /usr/bin/curl
  fi
  echo "🔧 Installing prerequisites..."
  if command -v apt-get >/dev/null; then
    apt-get update && apt-get install -y curl gnupg lsb-release python3
  elif command -v dnf >/dev/null; then
    dnf install -y curl gnupg2 redhat-lsb-core python3
  elif command -v yum >/dev/null; then
    yum install -y curl gnupg2 redhat-lsb-core python3
  fi

  echo "Creating fake certs for testing..."
  if [ ! -f cert.pem ]; then
    openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
      -keyout cert.key -out cert.pem \
      -subj "/CN=voxpupuli.org" \
      -addext "subjectAltName=DNS:voxpupuli.org,DNS:localhost"
    # cp cert.pem /usr/local/share/ca-certificates/openvox.crt
    #update-ca-certificates
  fi

  # Use test file directory as root for python server
  cd "$BATS_TEST_DIRNAME/.." || exit 1
 
  
  echo '127.0.0.1 voxpupuli.org' >> /etc/hosts
  echo "🧪 Starting local HTTP server and redirecting voxpupuli.org to localhost..."

  if [[ ! -f https_server.py ]]; then
    echo "❌ https_server.py not found. Please run the script from the correct directory."
    exit 1
  fi
  # Start the server and redirect output
  nohup python3 https_server.py >> server.log 2>&1 &
  server_pid=$!

  # Wait for server to start (check for port availability or specific log output)
  for i in {1..30}; do
    if grep -q "Server started" server.log || curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:443/install.sh 2>/dev/null | grep -q "200"; then
      echo "Server started successfully"
      break
    fi
    cat server.log
    echo "Waiting for server to start... ($i)"
    sleep 1
  done

  echo "Installing puppet-agent"
  curl -fsSL https://voxpupuli.org/install.sh | bash -s -- 8 openvox-agent
  if [ ! -f /opt/puppetlabs/bin/puppet ]; then
    echo "❌ install.sh failed in setup"
    exit 1
  fi
}

teardown_file() {
  pkill -f https_server.py || true
  mv /usr/local/bin/curl.real /usr/bin/curl
}