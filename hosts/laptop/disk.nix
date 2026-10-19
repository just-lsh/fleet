{
  disko.devices.disk.main = {
    type = "disk";
    # Check with `lsblk` on the target, or override with `--disk main <device>`.
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          label = "EFI";
          type = "EF00";
          size = "1G";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "fmask=0077"
              "dmask=0077"
            ];
          };
        };
        root = {
          priority = 2;
          label = "root";
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            extraArgs = [
              "-L"
              "root"
            ];
            mountpoint = "/";
          };
        };
      };
    };
  };
}
