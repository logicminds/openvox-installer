# OpenVox Installer + CI Validation

This project includes:

- A wrapper install script (`install.sh`) that detects OS and installs the correct version of the OpenVox agent.
- Dedicated install scripts for `.deb` and `.rpm` based systems.
- GitHub Actions workflow to test on multiple OSes.
- Bats-based test suite to validate successful installs and binary availability.

## 🛠 Usage

### Install on any supported system:
```bash
curl -fsSL https://voxpupuli.org/install.sh | bash -s -- 8 openvox-agent
```

### GitHub Actions
- Tests are defined in `.github/workflows/bats-install-tests.yml`
- Uses matrix strategy to test on Ubuntu, Debian, CentOS, Rocky, Alma, Fedora, and Amazon Linux

### Tests
Located in `/tests`, run via Bats.
Each test:
- Installs `openvox-agent`
- Validates install success
- Verifies `puppet` binary in PATH
- Checks `puppet version`


