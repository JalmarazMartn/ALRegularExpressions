page 69016 "Regex examples"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(InputExpr; InputExpr)
                {
                    Caption = 'Input expression';
                    ApplicationArea = All;
                }
                field(OutputExpr; OutputExpr)
                {
                    Caption = 'Result';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SqlToJS)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    RegexpExamples: Codeunit "Regexp Examples";
                begin
                    OutputExpr := RegexpExamples.SQLToJSBoolExpr(InputExpr);
                end;
            }
            action(AlVariableNaming)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    RegexpExamples: Codeunit "Regexp Examples";
                begin
                    OutputExpr := RegexpExamples.RenameALObjectVariable(InputExpr);
                end;
            }
            action(EvalBoolean)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    RegexpExamples: Codeunit "Regexp Examples";
                begin
                    OutputExpr := RegexpExamples.IstrueBoolExpr(InputExpr);
                end;
            }

        }
    }

    var
        InputExpr: Text;
        OutputExpr: Text;
}