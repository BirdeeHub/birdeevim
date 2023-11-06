rec {
  luaTablePrinter = attrSet: let
    luatableformatter = attrSet: let
      nameandstringmap = builtins.mapAttrs (name: value:
        if value == true then "${name} = true"
        else if value == false then "${name} = false"
        else if value == null then "${name} = nil"
        else if builtins.isList value then "${name} = ${luaListPrinter value}"
        else if builtins.isAttrs value then "${name} = ${luaTablePrinter value}"
        else "${name} = [[${builtins.toString value}]]"
      ) attrSet;
      resultList = builtins.attrValues nameandstringmap;
      resultString = builtins.concatStringsSep ", " resultList;
    in
    resultString;
    catset = luatableformatter attrSet;
    LuaTable = "{ " + catset + " }";
  in
  LuaTable;

  luaListPrinter = theList: let
    lualistformatter = theList: let
      stringlist = builtins.map (value:
        if value == true then "true"
        else if value == false then "false"
        else if value == null then "nil"
        else if builtins.isList value then "${luaListPrinter value}"
        else if builtins.isAttrs value then "${luaTablePrinter value}"
        else "[[${builtins.toString value}]]"
      ) theList;
      resultString = builtins.concatStringsSep ", " stringlist;
    in
    resultString;
    catlist = lualistformatter theList;
    LuaList = "{ " + catlist + " }";
  in
  LuaList;

  filterAndFlattenAttrsOfLists = SetOfCategoryLists: categories: let
    inputsToCheck = builtins.intersectAttrs SetOfCategoryLists categories;
    thingsIncluded = builtins.mapAttrs (name: value:
        if value == true then builtins.getAttr name SetOfCategoryLists else []
      ) inputsToCheck;
    listOfLists = builtins.attrValues thingsIncluded;
    flattenedList = builtins.concatLists listOfLists;
  in
  flattenedList;
}
