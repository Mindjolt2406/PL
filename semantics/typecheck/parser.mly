%{
%}

%token          NEWLINE WS COMMA EOF LPAREN RPAREN COLON
%token          IF THEN ELSE LET IN
%token          ADD SUBTRACT EQ
%token          AND OR NOT
%token <int>    INTEGER
%token <string> ID
%token <bool>   BOOLEAN
%start expr
%type <Expression.expr> expr
//%type <Expression.expr> bool_expr

%left ADD SUBTRACT
%left AND OR
%right NOT

%% /* Grammar rules and actions follow */

expr :	  	
  | ID                               { Expression.Id($1)          } 
  | INTEGER                          { Expression.IntConst($1)     }
  | BOOLEAN                          { Expression.BoolConst $1 }
  | expr ADD expr                    { Expression.Add($1, $3)     }
  | expr SUBTRACT expr               { Expression.Sub($1, $3)     }
  | IF expr THEN expr ELSE expr      { Expression.If($2, $4, $6)  }
  | expr AND expr { Expression.And($1, $3) }
  | expr OR expr { Expression.Or($1, $3) }
  | NOT expr { Expression.Not($2) }
  | expr EQ expr {Expression.Equals($1, $3) }
  | LET ID EQ expr IN expr           { Expression.Let($2, $4, $6) }
  | LPAREN expr RPAREN               { $2 }
;

/*
bool_expr:
    BOOLEAN { Expression.BoolConst $1 }
  | bool_expr AND bool_expr { Expression.And($1, $3) }
  | bool_expr OR bool_expr { Expression.Or($1, $3) }
  | NOT bool_expr { Expression.Not($2) }
;
*/
%%
