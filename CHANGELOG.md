# Changelog

## 2025-08-03

### Added
- Allow users to pass in install script source URL instead of hardcoding
- Updated beta agents to official versions for Windows and Mac
- Added support for custom source URLs in installation scripts

### Changed
- Updated installation scripts to support configurable source URLs
- Mac and Windows agents now use official versions (still hardcoded to specific versions)

## 2025-06-12

### Changed
- Updated supported distributions in run-local-test.sh:
  - Dropped EOL Ubuntu 20.04
  - Added Ubuntu 24.04
  - Updated Fedora from 40 to 42

## 2025-05-02

### Added
- Added macOS support with `install-openvox-mac.sh`
- Added Windows support with `install-openvox-win.psh`
- Updated README.md with multi-platform installation instructions

### Changed
- Enhanced `install.sh` to support multiple platforms
- Updated `install-openvox-rpm.sh` for better compatibility

