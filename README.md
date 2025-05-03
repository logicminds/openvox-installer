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


### Testing locally
You can use the local script to run tests locally with docker

```bash
chmod +x run-local-test.sh

# Run test in Ubuntu 22.04
./run-local-test.sh ubuntu:22.04

# Run test in CentOS 7
./run-local-test.sh centos:7

# Run test in Fedora 40
./run-local-test.sh fedora:40
```

## How it works
These installer scripts work by running the main script `install.sh` which then retrieves the dedicated OS script like `install-openvox-deb.sh`.

At this time only Ubuntu/Debian and Redhat families are supported.

<details>
<summary>🔍 Click to expand the Mermaid diagram</summary></details>

```mermaid
flowchart TD
  A["User runs curl https\://voxpupuli.org/install.sh \| bash"] --> B["install.sh from voxpupuli.org"]
  B --> C{Detect OS}

  C -->|Debian/Ubuntu| D[Download<br>install-openvox.sh<br>from voxpupuli.org]
  C -->|RHEL-based| E[Download<br>install-openvox-rpm.sh<br>from voxpupuli.org]

  D --> F[Install OpenVox .deb release package]
  E --> F2[Install OpenVox .rpm release package]

  F & F2 --> G[Import GPG key]
  G --> H[Configure apt/yum repo]
  H --> I[Install openvox-agent]

  I --> J{Symlink binaries?}
  J -->|Yes| K[Link to /usr/local/bin]
  J -->|No| L[Skip symlink step]

  
```


