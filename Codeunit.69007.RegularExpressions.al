codeunit 69007 "Regexp Examples"
{
    procedure SQLToJSBoolExpr(SQlBoolExpr: Text) JSBoolExpr: text;
    var
        DotNet_Regex: Codeunit DotNet_Regex;
        DotNet_RegexOptions: Codeunit DotNet_RegexOptions;
        RegExSplitWrapper: codeunit "RegEx Split Wrapper";
        DotNet_Match: Codeunit DotNet_Match;
        DotNet_MatchCollection: Codeunit DotNet_MatchCollection;
        DotNet_Group: Codeunit DotNet_Group;
        DotNet_GroupCollection: Codeunit DotNet_GroupCollection;

    begin
        DotNet_RegexOptions.IgnoreCase();
        JSBoolExpr := SQlBoolExpr;
        JSBoolExpr := DotNet_Regex.Replace(JSBoolExpr, 'and', '&&', DotNet_RegexOptions);
        JSBoolExpr := DotNet_Regex.Replace(JSBoolExpr, 'or', '||', DotNet_RegexOptions);
        JSBoolExpr := DotNet_Regex.Replace(JSBoolExpr, 'not', '!', DotNet_RegexOptions);
        JSBoolExpr := DotNet_Regex.Replace(JSBoolExpr, '([^=])(=)([^=])', '$1 == $3', DotNet_RegexOptions);
    end;

    procedure RenameALObjectVariable(OriginalStatement: Text) FinalStatement: text;
    var
        DotNet_Regex: Codeunit DotNet_Regex;
        DotNet_RegexOptions: Codeunit DotNet_RegexOptions;
        DotNet_Match: Codeunit DotNet_Match;
        DotNet_GroupVarType: Codeunit DotNet_Group;
        DotNet_GroupVarOldVarName: Codeunit DotNet_Group;
        DotNet_GroupVarSubType: Codeunit DotNet_Group;
        DotNet_GroupCollection: Codeunit DotNet_GroupCollection;
        NewVarName: Text[100];
        NameAlreadyInOldName: Boolean;
    begin
        FinalStatement := OriginalStatement;
        DotNet_RegexOptions.IgnoreCase();
        DotNet_Regex.Match(OriginalStatement, DeclarationPatternlbl, DotNet_RegexOptions, DotNet_Match);
        if not DotNet_Match.Success() then
            exit;
        DotNet_Match.Groups(DotNet_GroupCollection);
        DotNet_GroupCollection.Item(1, DotNet_GroupVarOldVarName);
        DotNet_GroupCollection.Item(2, DotNet_GroupVarType);
        DotNet_GroupCollection.Item(3, DotNet_GroupVarSubType);
        NewVarName := DelChr(DotNet_GroupVarSubType.Value(), '=', '" ');
        NameAlreadyInOldName := StrPos(DotNet_GroupVarOldVarName.Value(), NewVarName) <> 0;
        if NameAlreadyInOldName then
            exit;
        FinalStatement := NewVarName + ': ' + DotNet_GroupVarType.Value() + ' ' + DotNet_GroupVarSubType.Value() + ';';
    end;

    var
        DeclarationPatternlbl: Label '(.*):\s*(Record|Page|Report|Codeunit|XMLPort|Query)(.*);';
}
