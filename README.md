# Blaze

This repository contains the NixOS configurations for my homelab servers. The entire setup is managed using Nix Flakes to ensure it is reproducible, declarative, and version-controlled.

This repository currently manages the following machines:

**k3s-control**: A k3s Kubernetes control plane declared with NixOS.

## Prerequisites

* A local machine with **Nix** installed and **flakes enabled**.

* SSH access to the target machine(s) with a root user.

## Usage

### Building a Configuration

To verify that a machine's configuration builds correctly without deploying it, run the following command from the repository root. This is useful as a "dry-run" to catch errors.

For the Immich server:

```
nix build .#nixosConfigurations.images-sack.config.system.build.toplevel
```

For the media stack server:

```
nix build .#nixosConfigurations.arr-stack.config.system.build.toplevel
```

### Updating a machine

This can be done remotely using Colmena. It is only needed to have the host correctly configured with ssh for the target machine. Then, to update a machine, run the following command:

```sh
colmena apply --on <machine-name>
```
