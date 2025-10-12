# Blaze

This repository contains the NixOS configurations for my homelab servers. The entire setup is managed using Nix Flakes to ensure it is reproducible, declarative, and version-controlled.

This repository currently manages the following machines:

* **`immich-server`**: A dedicated server for running the [Immich](https://immich.app/) photo management service.

* **`arr-stack`**: A server for running a suite of media management tools (e.g., the *arr stack).

## Prerequisites

* A local machine with **Nix** installed and **flakes enabled**.

* [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) for initial installations.

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

### Future Updates (Ongoing Management)

After the initial installation, all subsequent updates should be handled by a dedicated deployment tool like [Colmena](https://github.com/zhaofengli/colmena). This will allow to automatically manage futur updates on existing NixOS machines.

