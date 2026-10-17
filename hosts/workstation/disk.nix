{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF1R802590T";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          label = "EFI";
          uuid = "a8e19e56-e902-4a11-af13-c140494f5691";
          type = "EF00";
          start = "4096s";
          end = "2101247s";
          content = {
            type = "filesystem";
            format = "vfat";
            extraArgs = [
              "-F"
              "32"
              "-i"
              "2031AAD1"
            ];
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
          uuid = "85c21ff7-c944-4de9-b932-dcb0fe1b8dda";
          type = "8300";
          start = "2101248s";
          end = "1953525101s";
          content = {
            type = "filesystem";
            format = "ext4";
            extraArgs = [
              "-L"
              "root"
              "-U"
              "ac01f1e2-830b-493a-871f-28a7239ed209"
            ];
            mountpoint = "/";
          };
        };
      };
    };
  };
}
