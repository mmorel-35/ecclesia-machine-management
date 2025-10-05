# Ecclesia

Ecclesia is a set of tools and libraries for interfacing with machine hardware
management and monitoring agents. This project contains a set of tools to
simplify accessing the lower-level system interfaces needed to interact with
hardware.

## Building

This project uses [Bazel](https://bazel.build/) for building. 

### Requirements

- Bazel 7.6.1 or later (see `.bazelversion`)

### Build Modes

The project supports both traditional WORKSPACE and modern bzlmod dependency management:

```bash
# Build using WORKSPACE mode (default)
bazel build //...

# Build using bzlmod hybrid mode
bazel build --enable_bzlmod --enable_workspace //...
```

For detailed information about bzlmod support and build modes, see [BZLMOD.md](BZLMOD.md).

