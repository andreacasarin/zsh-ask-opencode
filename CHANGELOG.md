# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-01-29

### Added

- Initial release of zsh-ask-opencode plugin
- Integration with OpenCode API for AI-powered command generation
- Interactive selection of commands via fzf
- Spinner animation during API calls
- Debug mode for troubleshooting
- Support for both Oh My Zsh and Antidote package managers
- Configurable model selection via `ASK_OPENCODE_MODEL`
- Keybinding on `Ctrl+O` for quick access
- Comprehensive documentation and examples

### Features

- Generate 3 ranked shell command options from natural language descriptions
- Commands ranked by speed, safety, and reliability
- Fallback to first option when fzf is not available
- Non-destructive: commands are inserted but not automatically executed
- Debug output for troubleshooting OpenCode API issues

[Unreleased]: https://github.com/yourusername/zsh-ask-opencode/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/zsh-ask-opencode/releases/tag/v1.0.0
