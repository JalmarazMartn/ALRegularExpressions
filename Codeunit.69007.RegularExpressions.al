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

    procedure IstrueBoolExpr(BoolExpr: Text): text[5]
    var
        DotNet_Regex: codeunit DotNet_Regex;
        DotNet_MatchCollection: Codeunit DotNet_MatchCollection;
        DotNet_Match: Codeunit DotNet_Match;
        DotNet_Group: Codeunit DotNet_Group;
        DotNet_GroupCollection: Codeunit DotNet_GroupCollection;
        i: Integer;
    begin
        DotNet_Regex.Matches(BoolExpr, SimpleExprlbl, DotNet_MatchCollection);
        if DotNet_MatchCollection.Count() = 0 then begin
            Message(BoolExpr);
            exit;
        end;

        for i := 1 to DotNet_MatchCollection.Count() do begin
            DotNet_MatchCollection.Item(i - 1, DotNet_Match);
            DotNet_Match.Groups(DotNet_GroupCollection);
            DotNet_GroupCollection.Item(2, DotNet_Group);
            BoolExpr := BoolExpr.Replace(DotNet_Match.Value(), SolvedBoolExpr(DotNet_Group.Value()));
        end;
        IstrueBoolExpr(BoolExpr);
    end;

    local procedure SolvedBoolExpr(BoolExpr: Text): text;
    var
        DotNet_Regex: codeunit DotNet_Regex;
        DotNet_MatchCollection: Codeunit DotNet_MatchCollection;
        i: Integer;
        DotNet_Match: Codeunit DotNet_Match;
        OrignalExpr: Text;
    begin
        OrignalExpr := BoolExpr;
        DotNet_Regex.Matches(BoolExpr, DecNumberLbl + ComparisionLbl + DecNumberLbl, DotNet_MatchCollection);
        if DotNet_MatchCollection.Count() <> 0 then
            for i := 1 to DotNet_MatchCollection.Count() do begin
                DotNet_MatchCollection.Item(i - 1, DotNet_Match);
                BoolExpr := BoolExpr.Replace(DotNet_Match.Value(), SolverComparision(DotNet_Match));
            end;
        Clear(DotNet_MatchCollection);
        DotNet_Regex.RegexIgnoreCase('i');
        DotNet_Regex.Matches(BoolExpr, StrSubstNo(BoolExprLbl, true, false), DotNet_MatchCollection);
        if DotNet_MatchCollection.Count() <> 0 then
            for i := 1 to DotNet_MatchCollection.Count() do begin
                DotNet_MatchCollection.Item(i - 1, DotNet_Match);
                BoolExpr := BoolExpr.Replace(DotNet_Match.Value(), SolverSingleBoolExpr(DotNet_Match));
            end;
        if OrignalExpr = BoolExpr then
            Error(OrignalExpr);
        exit(BoolExpr);
    end;

    local procedure SolverComparision(var DotNet_Match: Codeunit DotNet_Match): Text;
    var
        Number1Group: Codeunit DotNet_Group;
        CompOperator: Codeunit DotNet_Group;
        Number2Group: Codeunit DotNet_Group;
        Number1: Decimal;
        Number2: Decimal;
        Groups: Codeunit DotNet_GroupCollection;
    begin
        DotNet_Match.Groups(Groups);
        Groups.Item(1, Number1Group);
        Groups.Item(2, CompOperator);
        Groups.Item(3, Number2Group);
        Evaluate(Number1, Number1Group.Value());
        Evaluate(Number2, Number2Group.Value());
        case CompOperator.Value() of
            '<':
                exit(Format(Number1 < number2));
            '>':
                exit(Format(Number1 > number2));
            '<=':
                exit(Format(Number1 <= number2));
            '>=':
                exit(Format(Number1 >= number2));
            '=':
                exit(Format(Number1 = number2));
            else
                Error(DotNet_Match.Value());
        end;
    end;

    local procedure SolverSingleBoolExpr(var DotNet_Match: Codeunit DotNet_Match): Text
    var
        Bool1Group: Codeunit DotNet_Group;
        BoolOperator: Codeunit DotNet_Group;
        Bool2Group: Codeunit DotNet_Group;
        Bool1: Boolean;
        Bool2: Boolean;
        Groups: Codeunit DotNet_GroupCollection;

    begin
        DotNet_Match.Groups(Groups);
        Groups.Item(1, Bool1Group);
        Groups.Item(2, BoolOperator);
        Groups.Item(3, Bool2Group);
        Evaluate(bool1, Bool1Group.Value());
        Evaluate(bool2, Bool2Group.Value());
        case BoolOperator.Value() of
            'or':
                exit(Format(Bool1 or Bool2));
            'and':
                exit(Format(bool1 and Bool2));
            else
                Error(DotNet_Match.Value());
        end;

    end;

    var
        SimpleExprlbl: Label '\s*(\()([^\(&^\)]*)(\))\s*', locked = true;
        BoolExprLbl: Label '\s*(%1|%2)\s*(and|or)\s*(%1|%2)\s*', locked = true;
        ComparisionLbl: Label '(\s*[>=<]{1,2}\s*)', locked = true;
        DecNumberLbl: Label '\s*(\-?[0-9]+\.?[0-9]*)\s*', locked = true;
        DeclarationPatternlbl: Label '(.*):\s*(Record|Page|Report|Codeunit|XMLPort|Query)(.*);';
}
