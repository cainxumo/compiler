%{
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
class AbstractASTNode;
extern char *yytext;
extern int yylex();
extern int column;
AbstractASTNode* root;
StructTable *structTable;
void yyerror(const char *str);
%}

%union {
    AbstractASTNode* node;
    char* str;
}

%right '='
%left <node> '||'
%left <node> '&&'
%left <node> '&'
%left <node> '-' '+'
%left <node> '*' '/' '%'
%left <node> '^'
%right <node> '!'
%left '(' ')' '[' ']'

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
            :Main_Declaration '(' ')' compoundk_statement {
            root = new ASTNode();//程序根结点
            root->addChildNode($1);//语法树开始
            }
            ;
Main_Declaration
            :type_specifier
            ;
type_specifier
            :VOID {
            $$ = $1;
            }
            |INT {
            $$ = $1;
            }
            |CHAR {
            $$ = $1;
            }
            |SHORT {
            $$ = $1;
            }
            |LONG {
            $$ = $1;
            }
            ;
compoundk_statement
            :'{' '}'
            | '{' statement_list '}'
            | '{' declaration_list '}'
            | '{' declaration_list statement_list '}'
            ;
statement_list
            :statement {
            $$ = $1;
            }
            | statement_list statement {
            if ($1 == NULL) {
                $$ = $2;
            } else {
                if ($2 != NULL) {
                    $1->getLastPeerNode()->addPeerNode($2);//在最后一个声明节点上创建一个新的兄弟节点                }
                }
                $$ = $1;
            }
            }
            ;
declaration_list
            : declaration {
            $$ = $1;
            }
            | declaration_list declaration{
            if ($1 == NULL) {
                $$ = $2;
            } else {
                if ($2 != NULL) {
                    $1->getLastPeerNode()->addPeerNode($2);//在最后一个函数定义语法节点上创建一个新的兄弟节点                }
                }
                $$ = $1;
            }
            }
            ;
statement
            : compoundk_statement
            | expression_statement {
            AbstractASTNode* temp = new StmtASTNode(StmtType::expStmt);//新的exp树
            temp->addChildNode($1);
            $$ = temp;
            }
            | selection_statement {
            //同上
            }
            | iteration_statement
            | jump_statement
            ;
jump_statement
            : CONTINUE ';' {
            //同 return
            }
            | BREAK ';' {
            //同 return
            }
            | RETURN ';'{
            $$ = new StmtASTNode(StmtType::returnStmt);//新的声明树节点
            }
            | RETURN expression ';'{
            AbstractASTNode* temp = new StmtASTNode(StmtType::returnStmt);
            temp->addChildNode($2);//添加子树存储exp
            $$ = temp;
            }
            ;
iteration_statement
            : WHILE '(' expression ')' statement{
            $$ = new LoopASTNode((char*)"", LoopType::_while, $5, $3);//关联为循环父子树
            }
            | DO statement WHILE '(' expression ')' ';'
            | FOR '(' expression_statement expression_statement ')' statement{
            $$ = new LoopASTNode((char*)"", LoopType::_for, $8, $3, $5, NULL);//循环树,$n代表右边第几个,由于规约位置不确定，此处需要修改产生式或寻找其他方法找到确定位置的点
            }//此处代表：for(dec;exp;)stmt,位置包含了;
            | FOR '(' expression_statement expression_statement expression ')' statement{
            $$ = new LoopASTNode((char*)"", LoopType::_for, $9, $3, $5, $7);
            }
            ;
selection_statement
            : IF '(' expression ')' statement %prec NES{
            $$ = new SelectASTNode((char*)"", SelectType::_if, $5, $3);//关联为父子树
            }
            | IF '(' expression ')' statement ELSE statement{
            $$ = new SelectASTNode((char*)"", SelectType::_if, $5, $3, $7);
            }
            ;
expression_statement
            : ';'
            | expression ';'
            ;
declaration
            : declaration_specifiers ';' {
            AbstractASTNode* temp = new StmtASTNode(StmtType::defStmt);
            temp->addChildNode($1);
            $$ = temp;
            }
            | declaration_specifiers init_declarator_list ';'{
            DefVarASTNode* temp = (DefVarASTNode*)$2;
            temp->setAllType($1);//由于specifiers下一步进行规约，需要修改产生式或者树的创建方式
            $$ = temp;
            }
            ;
declaration_specifiers
            : type_specifier
            | type_specifier declaration_specifiers
            | type_qualifier
            | type_qualifier declaration_specifiers
            ;
type_qualifier
            : CONST{
            $$ = $1;
            }
            ;
init_declarator_list
            : init_declarator
            | init_declarator_list ',' init_declarator {
            $1->getLastPeerNode()->addPeerNode($3);
            $$ = $1;
            }
            ;
init_declarator
            : declarator {
            $$ = $1;
            }
            | declarator '=' initializer {
             $1->addChildNode($3);
             $$ = $1;
            }
            ;
declarator
            : IDENTIFIER {
            $$ = $1;
            }
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
            | unary_operator unary_expression {
            AbstractASTNode* temp = new OperatorASTNode((char*)"-", opType::Negative);
            temp->addChildNode($2);//由于符号在下一步才被规约，需要调整产生式或者修改建树方式
            $$ = temp;
            }
            ;
unary_operator
            : '+'
            | '-'
            | '!'
            ;
postfix_expression
            : primary_expression
            | postfix_expression '[' expression ']' {
            $$ = NULL;
            }
            ;
primary_expression
            : IDENTIFIER{
            $$ = new VarASTNode($1);
            }
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
            | and_expression '&' equality_expression {
            AbstractASTNode* op = new OperatorASTNode((char*)"&", opType::SingalAnd);
            AbstractASTNode* var = new VarASTNode((char*)$2);
            op->addChildNode(var);
            $$ = op;
            }
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
            | additive_expression '+' multiplicative_expression {
            AbstractASTNode* temp = new OperatorASTNode((char*)"%", opType::Plus);
            temp->addChildNode($1);//加树
            $1->addPeerNode($3);
            $ = temp;
            }
            | additive_expression '-' multiplicative_expression {
            AbstractASTNode* temp = new OperatorASTNode((char*)"-", opType::Minus);
            temp->addChildNode($1);
            $1->addPeerNode($3);
            $$ = temp;
            }
            ;
multiplicative_expression
            : unary_expression
            | multiplicative_expression '*' unary_expression {
            AbstractASTNode* temp = new OperatorASTNode((char*)"*", opType::Times);
            temp->addChildNode($1);
            $1->addPeerNode($3);
            $$ = temp;
            }
            | multiplicative_expression '/' unary_expression {
            AbstractASTNode* temp = new OperatorASTNode((char*)"/", opType::Div);
            temp->addChildNode($1);
            $1->addPeerNode($3);
            $$ = temp;
            }
            | multiplicative_expression '%' unary_expression {
            AbstractASTNode* temp = new OperatorASTNode((char*)"%", opType::Mod);
            temp->addChildNode($1);
            $1->addPeerNode($3);
            $$ = temp;
            }
            | multiplicative_expression '^' unary_expression {
            AbstractASTNode* temp = new OperatorASTNode((char*)"^", opType::Power);
            temp->addChildNode($1);
            $1->addPeerNode($3);
            $ = temp;
            }
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

