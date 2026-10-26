# Changelog

## [Unreleased]

### Added

- Initial ESCloud cluster module with node, storage, network, maintenance,
  billing, deletion-protection, and tag configuration.
- Stable-keyed private and public IP allowlist management.
- Private development and high-availability complete examples.
- Bilingual module and example documentation.

### Changed

- Enforce the API-reported 20 GiB minimum ESCloud disk size.
- Generate the required `terraform-managed` allowlist group when callers omit
  custom groups.
- Ignore service-injected system tag differences to preserve no-change plans.
- Use create-supported 2C4G ES node specifications and available zones in the
  validated examples.
- Document that asynchronous allowlist deletion can make the first instance
  destroy return `TaskIsRunning`; wait for the service task and retry destroy
  instead of removing the instance or state manually.

### Known Limitations

- The Provider exposes no security group attachment, snapshot policy, or
  snapshot repository resource.
- The Provider exposes no ESCloud IAM access policy or log-delivery resource.
- Provider 0.0.71 can expose the administrator password in refreshed state and
  destroy plans.
