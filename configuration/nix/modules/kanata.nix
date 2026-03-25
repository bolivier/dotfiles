{ pkgs, ... }:

{
  services.kanata = {
    enable = true;
    keyboards.default = {
      devices = [ ];
      extraDefCfg = "process-unmapped-keys yes";
      config = ''
        (defsrc
          caps ret prnt
        )

        (defvar
          tap-time 200
          hold-time 150
        )

        (deflayer base
          lctl @ret lmet
        )

        (defalias
          ret (tap-hold $tap-time $hold-time ret lctl)
        )
      '';
    };
  };
}
