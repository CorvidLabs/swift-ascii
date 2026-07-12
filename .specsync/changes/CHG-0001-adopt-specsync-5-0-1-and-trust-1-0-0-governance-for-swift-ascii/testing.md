---
change: CHG-0001-adopt-specsync-5-0-1-and-trust-1-0-0-governance-for-swift-ascii
artifact: testing
---

# Testing

- Run swift build and swift test.
- Require all 63 tests across 12 suites to pass.
- Preserve existing hosted macOS and Swift 6.0 Ubuntu builds and tests.
- Run SpecSync strict validation, agent status, Trust doctor, and Trust verify.
- Keep DocC publication independently triggered from main.

