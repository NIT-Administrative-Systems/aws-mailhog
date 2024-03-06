# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v2.0.0] - 2024-03-06
### Changed
- Switched from Mailhog to Mailpit, as Mailhog is no longer maintained.
- ECS task now uses ARM64 architecture, which should be cheaper.

## [v1.0.2] - 2022-05-17
### Changed
- Newest version removes provider block as recommended by hashicorp

## [v1.0.1] - 20244-03-09
### Changed
- Minor bug fix of variable name from oicd to oidc