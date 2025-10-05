# Quick Start Guide for Bzlmod

This is a quick reference for building with bzlmod. For complete documentation, see [BZLMOD.md](BZLMOD.md).

## Prerequisites

- Bazel 7.6.1+ (see `.bazelversion`)

## Building

### Default (WORKSPACE mode)
```bash
bazel build //...
```

### With Bzlmod (Hybrid mode - Recommended)
```bash
bazel build --enable_bzlmod --enable_workspace //...
```

## Testing Both Modes

Run the test script to verify both modes work:
```bash
./test_build_modes.sh
```

## Key Files

- `.bazelversion` - Bazel version (7.6.1)
- `WORKSPACE` - Traditional dependency management (default)
- `MODULE.bazel` - Bzlmod dependency declarations
- `.bazelrc` - Build configuration
- `BZLMOD.md` - Complete documentation

## Common Commands

```bash
# WORKSPACE mode (default)
bazel build //...
bazel test //...

# Bzlmod hybrid mode
bazel build --enable_bzlmod --enable_workspace //...
bazel test --enable_bzlmod --enable_workspace //...

# Query dependencies
bazel query --noenable_bzlmod @com_google_absl//:base
bazel query --enable_bzlmod --enable_workspace @bazel_skylib//lib:paths
```

## Troubleshooting

**Build fails**: Try WORKSPACE mode as fallback
```bash
bazel build --noenable_bzlmod //...
```

**Missing dependencies**: Ensure using hybrid mode
```bash
bazel build --enable_bzlmod --enable_workspace //...
```

For more help, see [BZLMOD.md](BZLMOD.md).
