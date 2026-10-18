{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets.flow-icons-license.owner = "len";

  systemd.user.services.flow-icons = {
    description = "Install Flow Icons for Zed";
    wantedBy = [ "default.target" ];
    unitConfig.ConditionUser = "len";
    startLimitIntervalSec = 60 * 60;
    startLimitBurst = 5;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.flow-icons-zed} ${config.sops.secrets.flow-icons-license.path}";
      Restart = "on-failure";
      RestartSec = "1min";
    };
  };
}
