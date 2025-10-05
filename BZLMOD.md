# Bzlmod Support for Ecclesia

This document describes the bzlmod setup for the Ecclesia Machine Management project.

## Overview

As of Bazel 7.6.1, this project supports both traditional WORKSPACE mode and the new bzlmod (Bazel Module) system. Both modes are fully functional for building the project.

## Requirements

- Bazel 7.6.1 or later (specified in `.bazelversion`)
- Both `WORKSPACE` and `MODULE.bazel` files are present in the repository

## Build Modes

### 1. WORKSPACE Mode (Default)

This is the traditional Bazel dependency management approach and is the **default** mode.

```bash
# Build using WORKSPACE mode
bazel build //...

# Or explicitly disable bzlmod
bazel build --noenable_bzlmod //...
```

**Characteristics:**
- Uses `WORKSPACE` file for all dependency declarations
- Full support for all 40+ project dependencies
- Custom patches and BUILD files work correctly
- This is the recommended mode for production use

### 2. Bzlmod Hybrid Mode (Recommended for Bzlmod)

This mode uses `MODULE.bazel` for dependencies available in the Bazel Central Registry (BCR) and falls back to `WORKSPACE` for others.

```bash
# Build using bzlmod hybrid mode
bazel build --enable_bzlmod --enable_workspace //...
```

**Characteristics:**
- Uses `MODULE.bazel` for core Bazel rules (rules_cc, rules_python, etc.)
- Falls back to `WORKSPACE` for project-specific dependencies
- Allows gradual migration to bzlmod
- Both dependency systems coexist

### 3. Pure Bzlmod Mode (Limited Support)

This mode uses only `MODULE.bazel` without any WORKSPACE dependencies.

```bash
# Build using pure bzlmod mode
bazel build --enable_bzlmod --noenable_workspace //...
```

**Characteristics:**
- Only uses `MODULE.bazel` declarations
- **Currently not fully supported** due to missing dependencies
- Many project dependencies are not yet available without WORKSPACE
- For testing future full bzlmod migration

## Configuration

### .bazelrc

The `.bazelrc` file documents the different modes and can be configured to change the default:

```starlark
# To enable bzlmod hybrid mode by default, uncomment:
# common --enable_bzlmod
# common --enable_workspace
```

### .bazelversion

Pins the Bazel version to 7.6.1, which supports bzlmod.

## Dependencies

### MODULE.bazel

The `MODULE.bazel` file declares the following dependencies from Bazel Central Registry (BCR):

**Core Bazel Rules (7 dependencies):**
- bazel_skylib (1.4.2)
- platforms (0.0.8)
- rules_cc (0.0.9)
- rules_proto (5.3.0-21.7)
- rules_python (0.26.0)
- rules_pkg (0.9.1)

**C++ Libraries (6 dependencies):**
- protobuf (29.1) - Protocol Buffers
- abseil-cpp (20230802.2) - C++ common libraries
- googletest (1.14.0) - C++ testing framework
- google_benchmark (1.8.3) - C++ microbenchmarking
- re2 (2023-09-01) - Regular expression library
- zlib (1.3.1) - Compression library

**Total in MODULE.bazel: 13 dependencies migrated to bzlmod**

### WORKSPACE

The `WORKSPACE` file (via `deps_first.bzl` and `deps_second.bzl`) provides the remaining 26+ dependencies:

**C++ Core Libraries (3 remaining):**
- com_google_emboss - Binary format compiler (not in BCR)
- com_json - nlohmann/json (needs custom BUILD)
- com_google_riegeli - Record I/O library (complex transitive deps)

**Networking (3 dependencies):**
- boringssl - SSL/TLS library (with no_array_parameter patch)
- com_github_grpc_grpc - gRPC (1.51.1 with 3 patches)
- com_google_googleapis - Google APIs (complex proto setup)

**Build Rules (3 dependencies):**
- com_github_nelhage_rules_boost - Boost libraries (not in BCR)
- build_bazel_rules_swift - Swift rules (old version)
- io_bazel_rules_closure - Closure rules (old version)

**System Libraries (5 dependencies):**
- com_github_libevent_libevent - Event notification (needs custom BUILD)
- ncurses - Terminal UI library (needs custom BUILD)
- libedit - Command line editing (needs custom BUILD)
- curl - URL transfer library (needs custom BUILD)
- jansson - JSON C library (needs custom BUILD)

**Messaging (3 dependencies):**
- libsodium - Crypto library (with version_h patch)
- zeromq - Message queue (with platform_hpp patch)
- cppzmq - C++ ZeroMQ bindings (needs custom BUILD)

**Python (4 dependencies):**
- com_google_absl_py - Abseil Python
- six_archive - Python 2/3 compatibility
- jinja2 - Template engine (needs custom BUILD)
- markupsafe - String escaping (needs custom BUILD)

**Redfish (2 dependencies):**
- redfishMockupServer - Mock Redfish server (with 12 patches)
- public_redfish_schema - Redfish schemas (custom download/extraction)

**TensorFlow (2 dependencies):**
- org_tensorflow - TensorFlow 2.0.0-rc0 (complex deps)
- com_google_tensorflow_serving - TF Serving (with visibility patch)

**Compression (4 dependencies):**
- org_brotli - Brotli compression (with patch, riegeli dependency)
- snappy - Snappy compression (custom BUILD from riegeli)
- highwayhash - Fast hashing (custom BUILD from riegeli)
- net_zstd - Zstd compression (custom BUILD from riegeli)

Many of these dependencies include:
- Custom patches applied during download
- Custom BUILD files for projects without Bazel support
- Specific version pinning for compatibility

## Bzlmod Migration Coverage

### Migrated to MODULE.bazel (13/39 = 33%)

✅ **Core Bazel rules and infrastructure** - All migrated
✅ **Protobuf** - Upgraded to 29.1
✅ **Abseil-cpp** - Native Bazel project, widely used
✅ **GoogleTest** - Native Bazel project, testing framework
✅ **Google Benchmark** - Native Bazel project, performance testing
✅ **RE2** - Native Bazel project, regex engine
✅ **zlib** - Widely available in BCR

### Candidates for Future Migration

The following dependencies are **native Bazel projects** that could benefit from bzlmod migration but remain in WORKSPACE due to patches or version constraints:

🟡 **boringssl** - Native Bazel, but requires 1 custom patch
🟡 **grpc** - Native Bazel, but requires 3 custom patches for compatibility
🟡 **googleapis** - Native Bazel, but has complex proto generation setup
🟡 **brotli** - Available in BCR, but requires 1 patch
🟡 **riegeli** - Google project, but has complex transitive deps (brotli, snappy, zstd, highwayhash)

### Remaining in WORKSPACE (26 dependencies)

These dependencies are best kept in WORKSPACE due to:
- **No native Bazel support** - Need custom BUILD files
- **Heavy customization** - Multiple patches required
- **Legacy versions** - Specific old versions needed for compatibility
- **Complex setup** - TensorFlow ecosystem, Redfish tooling

## Migration Status

### What Works in Bzlmod

✅ Core Bazel rules (rules_cc, rules_python, rules_pkg, etc.)
✅ Python toolchain configuration
✅ C++ core libraries (Abseil, GoogleTest, Benchmark, RE2, zlib)
✅ Protocol Buffers 29.1
✅ Basic build infrastructure
✅ 33% of total dependencies migrated (13/39)

### What Requires WORKSPACE

❌ Dependencies with custom patches (boringssl, grpc, libsodium, zeromq, etc.)
❌ Dependencies with custom BUILD files (json, ncurses, jinja2, etc.)
❌ Specific version requirements not in BCR (TensorFlow 2.0.0-rc0)
❌ Complex transitive dependencies (TensorFlow ecosystem, Riegeli compression stack)
❌ Legacy build rules (old versions of rules_swift, rules_closure)

### Future Work

To achieve full bzlmod support without WORKSPACE:
1. Convert all patches to standalone `.patch` files compatible with archive_override
2. Create in-repo BUILD files for external dependencies without Bazel support
3. Resolve version conflicts with BCR (e.g., upgrade TensorFlow)
4. Migrate compression stack (brotli, snappy, zstd, highwayhash) with patches
5. Test the complete dependency graph
6. Create module extensions for complex setups (grpc, googleapis)

### Recommended Migration Order

1. ✅ **Phase 1 (Complete)** - Core rules + common C++ libraries (13 deps)
2. 🔄 **Phase 2 (Next)** - Compression libraries with patches (4 deps)
3. 🔄 **Phase 3** - Networking stack (grpc, boringssl, googleapis) (3 deps)
4. 🔄 **Phase 4** - System libraries with custom BUILD files (8 deps)
5. 🔄 **Phase 5** - Python dependencies (4 deps)
6. 🔄 **Phase 6** - TensorFlow ecosystem (2 deps)
7. 🔄 **Phase 7** - Specialized tools (Redfish, Boost, etc.) (6 deps)

## Troubleshooting

### Build fails with bzlmod

If you encounter issues with bzlmod mode:
1. Try hybrid mode: `bazel build --enable_bzlmod --enable_workspace //...`
2. Fall back to WORKSPACE mode: `bazel build --noenable_bzlmod //...`
3. Check that `.bazelversion` is set to 7.6.1 or later

### Missing dependencies

If you see "no such package" errors:
- Ensure you're using hybrid mode (`--enable_workspace`)
- Verify `WORKSPACE` file is present and unmodified
- Check that all transitive dependency loaders are working

## Best Practices

1. **For production builds**: Use WORKSPACE mode (default)
2. **For bzlmod testing**: Use hybrid mode with `--enable_bzlmod --enable_workspace`
3. **For development**: Use the mode you're most comfortable with
4. **For CI/CD**: Test both modes to ensure compatibility

## References

- [Bazel Modules (bzlmod)](https://bazel.build/external/module)
- [Bazel Central Registry](https://registry.bazel.build/)
- [Migration Guide](https://bazel.build/external/migration)
