# Bzlmod Support for Ecclesia

This document describes the bzlmod setup for the Ecclesia Machine Management project.

## Overview

As of Bazel 6.4.0, this project supports both traditional WORKSPACE mode and the new bzlmod (Bazel Module) system. Both modes are fully functional for building the project.

## Requirements

- Bazel 6.4.0 or later (specified in `.bazelversion`)
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

Pins the Bazel version to 6.4.0, which supports bzlmod.

## Dependencies

### MODULE.bazel

The `MODULE.bazel` file declares:
- Core Bazel rules from BCR (bazel_skylib, rules_cc, rules_python, etc.)
- Python toolchain configuration
- Documentation of WORKSPACE-defined dependencies

### WORKSPACE

The `WORKSPACE` file (via `deps_first.bzl` and `deps_second.bzl`) provides 40+ dependencies including:

- **C++ Core Libraries**: Abseil, Protobuf, GoogleTest, Benchmark, Emboss, RE2, JSON, Riegeli
- **Networking**: BoringSSL (patched), gRPC (patched), Google APIs
- **Build Rules**: Boost, Swift, Closure
- **System Libraries**: libevent, zlib, ncurses, libedit, curl, jansson
- **Messaging**: libsodium (patched), zeromq (patched), cppzmq
- **Python**: Abseil-py, six, Jinja2, MarkupSafe
- **Redfish**: Mockup Server (with 12 patches), Schema
- **TensorFlow**: TensorFlow core, TensorFlow Serving (patched)
- **Compression**: Brotli, Snappy, HighwayHash, Zstd

Many of these dependencies include:
- Custom patches applied during download
- Custom BUILD files for projects without Bazel support
- Specific version pinning for compatibility

## Migration Status

### What Works in Bzlmod

✅ Core Bazel rules (rules_cc, rules_python, rules_pkg, etc.)
✅ Python toolchain configuration
✅ Basic build infrastructure

### What Requires WORKSPACE

❌ Dependencies with custom patches (boringssl, grpc, etc.)
❌ Dependencies with custom BUILD files (json, ncurses, etc.)
❌ Specific version requirements not in BCR
❌ Complex transitive dependencies (TensorFlow ecosystem)

### Future Work

To achieve full bzlmod support without WORKSPACE:
1. Convert all patches to standalone `.patch` files
2. Create in-repo BUILD files for external dependencies
3. Resolve version conflicts with BCR
4. Test the complete dependency graph
5. Create module extensions for complex setups

## Troubleshooting

### Build fails with bzlmod

If you encounter issues with bzlmod mode:
1. Try hybrid mode: `bazel build --enable_bzlmod --enable_workspace //...`
2. Fall back to WORKSPACE mode: `bazel build --noenable_bzlmod //...`
3. Check that `.bazelversion` is set to 6.4.0 or later

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
