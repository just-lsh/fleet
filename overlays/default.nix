{ ... }:
{
  additions = final: _prev: import ../pkgs final;
  modifications = final: prev: {
    # Python apps now get a compiled wrapper, which takes each argument as its
    # own element; gearlever passes its flags as single strings and fails to build.
    gearlever = prev.gearlever.overridePythonAttrs (old: {
      makeWrapperArgs = prev.lib.splitString " " (builtins.elemAt old.makeWrapperArgs 1);
      preFixup = ''
        makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
      '';
    });
  };
}
