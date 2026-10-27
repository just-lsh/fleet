{ config, ... }:
let
  # The devbox runs the proxy; every host reaches it over the tailnet.
  url = "http://devbox:8317";
  apiKey = config.sops.secrets.cliproxyapi-api-key.path;
in
{
  # Client key for the proxy, also the key the devbox accepts.
  sops.secrets.cliproxyapi-api-key.owner = "len";

  home-manager.users.len = {
    programs.claude-code.settings = {
      apiKeyHelper = "cat ${apiKey}";
      env.ANTHROPIC_BASE_URL = url;
    };

    programs.codex.settings = {
      model_provider = "cliproxyapi";
      model_providers.cliproxyapi = {
        name = "CLIProxyAPI";
        base_url = "${url}/v1";
        wire_api = "responses";
        auth = {
          command = "cat";
          args = [ apiKey ];
        };
      };
    };
  };
}
