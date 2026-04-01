# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-02-25

### Changed
- Updated all dependency references to latest versions.
- Migrated from `mo:base` to `mo:core`.
- Updated OVS roll-up documentation in README.

### Breaking
- Probable breaking changes due to `mo:core` migration — callers using `mo:base` collection types will need to update.

## [0.2.0]

### Added
- Metadata as a `DataItemMap` to all List Items.

### Changed
- Updated `mo:base`.
- Updated Timer Tool.

### Breaking
- `get_list_members_admin` return type now includes the metadata.
- `ManageListMembershipRequest` has an `Update` action to change metadata and `Add` includes metadata.