system: type: path: let
  inherit (builtins) length head elemAt zipAttrsWith isAttrs attrValues concatLists foldl' getFlake;
  pipe = foldl' (x: f: f x);
  attrByPath =
    attrPath: default: set:
    let
      lenAttrPath = length attrPath;
      attrByPath' = n: s: (
        if n == lenAttrPath then s
        else (
          let attr = elemAt attrPath n; in
          if s ? ${attr} then attrByPath' (n + 1) s.${attr} else default
        )
      );
    in
    attrByPath' 0 set;
  recMergePickDeeper =
    lhs: rhs:
    let
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
    in
    f [] [rhs lhs];

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
  targetFlake = getFlake "path:${toString path}";
  getCfgs = atp: attrValues (attrByPath atp {} targetFlake);
in pipe type [
  (type: allTargets.${type})
  (map getCfgs)
  concatLists
  (foldl' recMergePickDeeper {})
  (v: v.options or {})
]
