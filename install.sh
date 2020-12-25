#! /usr/bin/env bash

set -e

sgdisk -d 1 /dev/sda
sgdisk -N 1 /dev/sda
partprobe /dev/sda

mkfs.ext4 -F /dev/sda1

mount /dev/sda1 /mnt

nixos-generate-config --root /mnt

sed -i -E 's:^\}\s*$::g' /mnt/etc/nixos/configuration.nix

echo '
  boot.loader.grub.devices = [ "/dev/sda" ];
  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.permitRootLogin = "prohibit-password";
  services.openssh.enable = true;
  # Replace this by your SSH pubkey
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJoBLpVtzGN5n6yyzF5Xm+cIutcrKACNlDryPldkD+b8mga2Us9iM+Mwylr1JD4+27VMWeqORR+3FFlBUYsrDjWxVSezRapN/KIA2h4VHrzKBker/yJlJW5WRAgVh9+BA+xkFUDf7bYcGQmRR0iOd80SuLNowDyhKFJxQE77UpStrWkwLd/xOe3XnC3noVgsk9q2vWzYB0m9xZKKXFU0WJ66GybN+mzm05cjdbB+Zzsv+f2wx1pqbCjPLcUFfIPJ/fPKy9gR0Qh9RQbFr2mtwPQPzcASaIgDp97DloEV4ZnwJdhHJEBRCqe9BpfvxcbugfjpPNH56k5aKwQi8om2Rp user@host"
  ];
}
' >> /mnt/etc/nixos/configuration.nix

nixos-install --no-root-passwd

reboot
