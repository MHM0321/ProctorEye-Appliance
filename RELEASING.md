# Release process

Public appliance releases are built from the main ProctorEye repository after its automated tests pass.

Each release should contain:

- one Windows archive;
- one macOS archive;
- one Linux archive;
- a SHA-256 checksum file;
- release notes that identify the source commit and summarize user-visible changes.

Existing releases and tags are kept so operators can audit and roll back versions. Secrets, generated `.env` files, private keys, and real license files must never be included.

