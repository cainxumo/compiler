%{
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include "../common/trees.h"
#include "../common/util/InterMediate.h"
#include "../common/util/AsmGenerator.h"
class AbstractASTNode;
extern char *yytext;
extern int yylex();
extern int column;
extern FILE * yyin;
extern int yylineno;
AbstractASTNode* root;
StructTable *structTable;
void yyerror(const char *str);
%}

%union {
    AbstractASTNode* node;
    char* str;
}

%token IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN POWER_ASSIOGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELLIPSIS

%token DEFAULT IF ELSE WHILE DO FOR CONTINUE BREAK RETURN

%nonassoc NES
%nonassoc ELSE
%start Function_Definition
%%

Function_Definition
            :Main_Declaration '(' ')' compoundk_statement
            ;
Main_Declaration
            :type_specifier
            ;
type_specifier
            :VOID
            |INT
            |CHAR
            |SHORT
            |LONG
            ;
compoundk_statement
            :'{' '}'
            | '{' statement_list '}'
            | '{' declaration_list '}'
            | '{' declaration_list statement_list '}'
            ;
statement_list
            :statement
            | statement_list statement
            ;
declaration_list
            : declaration
            | declaration_list declaration
            ;
statement
            : compoundk_statement
            | expression_statement
            | selection_statement
            | iteration_statement
            | jump_statement
            ;
jump_statement
            : CONTINUE ';'
            | BREAK ';'
            | RETURN ';'
            | RETURN expression ';'
            ;
iteration_statement
            : WHILE '(' expression ')' statement
            | DO statement WHILE '(' expression ')' ';'
            | FOR '(' expression_statement expression_statement ')' statement
            | FOR '(' expression_statement expression_statement expression ')' statement
            ;
selection_statement
            : IF '(' expression ')' statement %prec NES
            | IF '(' expression ')' statement ELSE statement
            ;
expression_statement
            : ';'
            | expression ';'
            ;
declaration
            : declaration_specifiers ';'
            | declaration_specifiers init_declarator_list ';'
            ;
declaration_specifiers
            : type_specifier
            | type_specifier declaration_specifiers
            | type_qualifier
            | type_qualifier declaration_specifiers
            ;
type_qualifier
            : CONST
            ;
init_declarator_list
            : init_declarator
            | init_declarator_list ',' init_declarator
            ;
init_declarator
            : declarator
            | declarator '=' initializer
            ;
declarator
            : IDENTIFIER
            | '(' declarator ')'
            ;
initializer
            : assignment_expression
            | '{' initializer_list '}'
            | '{' initializer_list ',' '}'
            ;
initializer_list
            : initializer
            | initializer_list ',' initializer
            ;
expression
            : assignment_expression
            | expression ',' assignment_expression
            ;
assignment_expression
            : conditional_expression
            | unary_expression assignment_operator assignment_expression
            ;
assignment_operator
            : '='
            | MUL_ASSIGN
            | DIV_ASSIGN
            | MOD_ASSIGN
            | ADD_ASSIGN
            | SUB_ASSIGN
            | LEFT_ASSIGN
            | RIGHT_ASSIGN
            | AND_ASSIGN
            | OR_ASSIGN
            | POWER_ASSIOGN 
            ;
unary_expression
            : postfix_expression
            | INC_OP unary_expression
            | DEC_OP unary_expression
            | unary_operator unary_expression
            ;
unary_operator
            : '+'
            | '-'
            | '!'
            ;
postfix_expression
            : primary_expression
            | postfix_expression '[' expression ']'
            ;
primary_expression
            : IDENTIFIER
            | CONSTANT
            | '(' expression ')'
            ;
conditional_expression
            : logical_or_expression
            | logical_or_expression '?' expression ':' conditional_expression
            ;
logical_or_expression
            : logical_and_expression
            | logical_or_expression OR_OP logical_and_expression
            ;
logical_and_expression
            : inclusive_or_expression
            | logical_and_expression AND_OP inclusive_or_expression
            ;
inclusive_or_expression
            : exclusive_or_expression
            | inclusive_or_expression '|' exclusive_or_expression
            ;
exclusive_or_expression
            : and_expression
            ;
and_expression
            : equality_expression
            | and_expression '&' equality_expression
            ;
equality_expression
            : relational_expression
            | equality_expression EQ_OP relational_expression
            | equality_expression NE_OP relational_expression
            ;
relational_expression
            : shift_expression
            | relational_expression '<' shift_expression
            | relational_expression '>' shift_expression
            | relational_expression LE_OP shift_expression
            | relational_expression GE_OP shift_expression
            ;
shift_expression
            : additive_expression
            | shift_expression LEFT_OP additive_expression
            | shift_expression RIGHT_OP additive_expression
            ;
additive_expression
            : multiplicative_expression
            | additive_expression '+' multiplicative_expression
            | additive_expression '-' multiplicative_expression
            ;
multiplicative_expression
            : unary_expression
            | multiplicative_expression '*' unary_expression
            | multiplicative_expression '/' unary_expression
            | multiplicative_expression '%' unary_expression
            | multiplicative_expression '^' unary_expression
            ;
%%
#include <stdio.h>

extern char yytext[];
extern int column;

yyerror(s)
char *s;
{
    fflush(stdout);
    printf("\n%*s\n%*s\n", column, "^", column, s);
}

