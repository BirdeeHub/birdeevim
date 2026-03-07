system: type: path: let
  pipe = builtins.foldl' (x: f: f x);
  flip = f: a: b: f b a;
  attrByPath =
    attrPath: default: set:
    let
      lenAttrPath = builtins.length attrPath;
      attrByPath' = n: s: (
        if n == lenAttrPath then s
        else (
          let attr = builtins.elemAt attrPath n; in
          if s ? ${attr} then attrByPath' (n + 1) s.${attr} else default
        )
      );
    in
    attrByPath' 0 set;
  recMergePickDeeper = with builtins; lhs: rhs: let
    pred = path: lh: rh: ! isAttrs lh || ! isAttrs rh;
    pick = path: l: r: if isAttrs l then l else r;
    f = attrPath:
      zipAttrsWith (n: values:
        let here = attrPath ++ [n]; in
        if length values == 1 then
          head values
        else if pred here (elemAt values 1) (head values) then
          pick here (elemAt values 1) (head values)
        else
          f here values
      );
  in f [] [rhs lhs];

  allTargets = {
    nixos = [
      [ "outputs" "nixosConfigurations" ]
      [ "outputs" "legacyPackages" system "nixosConfigurations" ]
    ];
    home-manager = [
      [ "outputs" "homeConfigurations" ]
      [ "outputs" "legacyPackages" system "homeConfigurations" ]
    ];
    darwin = [
      [ "outputs" "darwinConfigurations" ]
      [ "outputs" "legacyPackages" system "darwinConfigurations" ]
    ];
  };
  targetFlake = with builtins; getFlake "path:${toString path}";
  getCfgs = flip pipe [
    (atp: attrByPath atp {} targetFlake)
    builtins.attrValues
  ];
in pipe type [
  (type: allTargets.${type})
  (map getCfgs)
  builtins.concatLists
  (builtins.foldl' recMergePickDeeper {})
  (v: v.options or {})
]
