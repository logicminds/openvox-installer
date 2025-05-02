load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
  echo "🔧 Installing prerequisites..."
  if command -v apt-get >/dev/null; then
    apt-get update && apt-get install -y curl gnupg lsb-release python3
  elif command -v dnf >/dev/null; then
    dnf install -y curl gnupg2 redhat-lsb-core python3
  elif command -v yum >/dev/null; then
    yum install -y curl gnupg2 redhat-lsb-core python3
  fi

  echo "🧪 Starting local HTTP server and redirecting voxpupuli.org to localhost..."

  # Use test file directory as root for python server
  cd "$BATS_TEST_DIRNAME/.." || exit 1

  python3 -m http.server 8080 &
  echo '127.0.0.1 voxpupuli.org' >> /etc/hosts
}

teardown() {
  pkill -f "python3 -m http.server" || true
}