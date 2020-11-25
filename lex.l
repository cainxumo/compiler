%{
#include "y.tab.h"
#include <stdio.h>
#define ERRORCHAR -1
#define VOID 1
#define MAIN 2
#define RETURN 3
#define CONST 4
#define STATIC 5
#define AUTO 6
#define TYPE_NAME 7
#define IF 8
#define ELSE 9
#define WHILE 10
#define DO 11
#define BREAK 12
#define CONTINUE 13
#define SWITCH 14
#define CASE 15
#define DEFAULT 16
#define SIZEOF 17
#define TYPEDEF 18
#define VOLATILE 19
#define GOTO 20
#define INT 21
#define ID 22
#define LE_OP 23
#define GE_OP 24
#define INC_OP 34
#define DEC_OP 35
#define AND_OP 25
#define OR_OP 26
#define NE_OP 39
#define PTR_OP 46
#define ADD_ASSIGN 27
#define SUB_ASSIGN 28
#define MUL_ASSIGN 29
#define DIV_ASSIGN 30
#define MOD_ASSIGN 31
#define EQUAL 36
#define FOR 48
#define STRING 49
#define INPUT 50
#define OUTPUT 51

struct word
{
    char* word_name;
    struct word* next;
};
struct word* word_list;
extern void *malloc();
struct word* add_word(char*);
struct word* lookup_word(char*);
void notes();
void out_list(int);

%}

delim       [ \t\n]
whitespace  {delim}+
letter      [A-Za-z_]
string      ["](\"|.)*?["]
digit       [0-9]
int         ([1-9]|[1-9]([0-9])+|0)
id          {letter}({digit}|{letter})*
type        "int"

%%

void        {return VOID;}
main        {return MAIN;}
return      {return RETURN;}
const       {return CONST;}
static      {return STATIC;}
auto        {return AUTO;}
if          {return IF;}
else        {return ELSE;}
for         {return FOR;}
while       {return WHILE;}
do          {return DO;}
break       {return BREAK;}
continue    {return CONTINUE;}
switch      {return SWITCH;}
case        {return CASE;}
default     {return DEFAULT;}
sizeof      {return SIZEOF;}
typedef     {return TYPEDEF;}
volatile    {return VOLATILE;}
goto        {return GOTO;}
input_int   {return INPUT;}
output_int  {return OUTPUT;}

{whitespace} {}
{type}      {return TYPE_NAME;}
{int}       {return INT;}
{id}        {return ID;}
{string}    {return STRING;}

"("     {return '(';}
")"     {return ')';}
"["     {return '[';}
"]"     {return ']';}
"{"     {return '{';}
"}"     {return '}';}
"<"     {return '<';}
">"     {return '>';}
"<="    {return LE_OP;}
">="    {return GE_OP;}
"&"     {return '&';}
"|"     {return '|';}
"&&"    {return AND_OP;}
"||"    {return OR_OP;}
"+"     {return '+';}
"-"     {return '-';}
"*"     {return '*';}
"/"     {return '/';}
"%"     {return '%';}
"^"     {return '^';}
"!"     {return '!';}
"="     {return '=';}
"+="    {return ADD_ASSIGN;}
"-="    {return SUB_ASSIGN;}
"*="    {return MUL_ASSIGN;}
"/="    {return DIV_ASSIGN;}
"%="    {return MOD_ASSIGN;}
"++"    {return INC_OP;}
"--"    {return DEC_OP;}
"=="    {return EQUAL;}
"!="    {return NE_OP;}
","     {return ',';}
";"     {return ';';}
"->"    {return PTR_OP;}
"//"[^\n]* {}
"/*"    {notes();}
.       {return ERRORCHAR;}

%%

void main(int argc, char* argv[])
{
    int c = 0;
    if(argc >= 2)
    {
        if((yyin = fopen(argv[1], "r")) == NULL)
        {
            printf("无法创建");
            return;
        }
        if(argc >= 3)
        {
            yyout = fopen(argv[2], "w");
        }
    }
    fprintf(yyout, "%-10s\t%-10s\t%-10s\t\n", "单词", "词素", "属性");
    while(c = yylex())
    {
        out_list(c);
    }
    if(argc >= 2)
    {
        fclose(yyin);
        if(argc >= 3)
        {
            fclose(yyout);
        }
    }
}

int yywrap(void)
{
    return 1;
}

void notes()
{
    char c, prev = 0;
    while((c = input()) != 0)
    {
        if(c == '/' && prev == '*')
        {
            return;
        }
        prev = c;
    }
    fprintf(yyout, "error");
}

struct word* add_word(char* word)
{
    struct word* wp;
    wp = lookup_word(word);
    if(wp != NULL) 
    {
        return wp;
    }
    wp = (struct word*)malloc(sizeof(struct word));
    wp->next = word_list;
    wp->word_name = (char*)malloc(strlen(word)+1);
    strcpy(wp->word_name, word);
    word_list = wp;
    return wp;
}

struct word* lookup_word(char* word)
{
    struct word* wp =word_list;
    for(; wp; wp = wp->next)
    {
        if(strcmp(wp->word_name, word) == 0)
        {
            return wp;
        }
    }
    return NULL;
}

void out_list(int c)
{
    switch(c)
    {
        case ERRORCHAR:
            fprintf(yyout, "%-10s\t%-10s", "ERRORCHAR", yytext);
            break;
        case VOID:
            fprintf(yyout, "%-10s\t%-10s", "VOID", yytext);
            break;
        case MAIN:
            fprintf(yyout, "%-10s\t%-10s", "MAIN", yytext);
            break;
        case RETURN:
            fprintf(yyout, "%-10s\t%-10s", "RETURN", yytext);
            break;
        case CONST:
            fprintf(yyout, "%-10s\t%-10s", "CONST", yytext);
            break;
        case STATIC:
            fprintf(yyout, "%-10s\t%-10s", "STATIC", yytext);
            break;
        case TYPE_NAME:
            fprintf(yyout, "%-10s\t%-10s", "TYPE", yytext);
            break;
        case IF:
            fprintf(yyout, "%-10s\t%-10s", "IF", yytext);
            break;
        case ELSE:
            fprintf(yyout, "%-10s\t%-10s", "ELSE", yytext);
            break;
        case FOR:
            fprintf(yyout, "%-10s\t%-10s", "FOR", yytext);
            break;
        case WHILE:
            fprintf(yyout, "%-10s\t%-10s", "WHILE", yytext);
            break;
        case DO:
            fprintf(yyout, "%-10s\t%-10s", "DO", yytext);
            break;
        case BREAK:
            fprintf(yyout, "%-10s\t%-10s", "BREAK", yytext);
            break;
        case CONTINUE:
            fprintf(yyout, "%-10s\t%-10s", "CONTINUE", yytext);
            break;
        case DEFAULT:
            fprintf(yyout, "%-10s\t%-10s", "DEFAULT", yytext);
            break;
        case TYPEDEF:
            fprintf(yyout, "%-10s\t%-10s", "TYPEDEF", yytext);
            break;
        case INT:
            fprintf(yyout, "%-10s\t%-10s\t%-10s", "NUMBER", yytext, yytext);
            break;
        case ID:
            fprintf(yyout, "%-10s\t%-10s\t%p", "ID", yytext, add_word(yytext));
            break;
        case '(':
            fprintf(yyout, "%-10s\t%-10s", "LP", yytext);
            break;
        case ')':
            fprintf(yyout, "%-10s\t%-10s", "RP", yytext);
            break;
        case '[':
            fprintf(yyout, "%-10s\t%-10s", "LSB", yytext);
            break;
        case ']':
            fprintf(yyout, "%-10s\t%-10s", "RSB", yytext);
            break;
        case '{':
            fprintf(yyout, "%-10s\t%-10s", "LBRACE", yytext);
            break;
        case '}':
            fprintf(yyout, "%-10s\t%-10s", "RBRACE", yytext);
            break;
        case '<':
            fprintf(yyout, "%-10s\t%-10s", "LT", yytext);
            break;
        case LE_OP:
            fprintf(yyout, "%-10s\t%-10s", "LE", yytext);
            break;
        case '>':
            fprintf(yyout, "%-10s\t%-10s", "GT", yytext);
            break;
        case GE_OP:
            fprintf(yyout, "%-10s\t%-10s", "GE", yytext);
            break;
        case INC_OP:
            fprintf(yyout, "%-10s\t%-10s", "INC", yytext);
            break;
        case DEC_OP:
            fprintf(yyout, "%-10s\t%-10s", "DEC", yytext);
            break;
        case PTR_OP:
            fprintf(yyout, "%-10s\t%-10s", "PTR", yytext);
            break;
        case NE_OP:
            fprintf(yyout, "%-10s\t%-10s", "NE", yytext);
            break;
        case AND_OP:
            fprintf(yyout, "%-10s\t%-10s", "AND", yytext);
            break;
        case OR_OP:
            fprintf(yyout, "%-10s\t%-10s", "OR", yytext);
            break;
        case '+':
            fprintf(yyout, "%-10s\t%-10s", "ADD", yytext);
            break;
        case '-':
            fprintf(yyout, "%-10s\t%-10s", "SUB", yytext);
            break;
        case '*':
            fprintf(yyout, "%-10s\t%-10s", "MUL", yytext);
            break;
        case '/':
            fprintf(yyout, "%-10s\t%-10s", "DIV", yytext);
            break;
        case '%':
            fprintf(yyout, "%-10s\t%-10s", "MOD", yytext);
            break;
        case '^':
            fprintf(yyout, "%-10s\t%-10s", "POW", yytext);
            break;
        case '=':
            fprintf(yyout, "%-10s\t%-10s", "ASSIGN", yytext);
            break;
        case ADD_ASSIGN:
            fprintf(yyout, "%-10s\t%-10s", "ADD_ASSIGN", yytext);
            break;
        case SUB_ASSIGN:
            fprintf(yyout, "%-10s\t%-10s", "SUB_ASSIGN", yytext);
            break;
        case MUL_ASSIGN:
            fprintf(yyout, "%-10s\t%-10s", "MUL_ASSIGN", yytext);
            break;
        case DIV_ASSIGN:
            fprintf(yyout, "%-10s\t%-10s", "DIV_ASSIGN", yytext);
            break;
        case MOD_ASSIGN:
            fprintf(yyout, "%-10s\t%-10s", "MOD_ASSIGN", yytext);
            break;
        case EQUAL:
            fprintf(yyout, "%-10s\t%-10s", "EQUAL", yytext);
            break;
        case ';':
            fprintf(yyout, "%-10s\t%-10s", "SEMICOLON", yytext);
            break;
        case '&':
            fprintf(yyout, "%-10s\t%-10s", "&", yytext);
            break;
        case '|':
            fprintf(yyout, "%-10s\t%-10s", "|", yytext);
            break;
        case ',':
            fprintf(yyout, "%-10s\t%-10s", "COMMA", yytext);
            break;
        case '!':
            fprintf(yyout, "%-10s\t%-10s", "NOT", yytext);
            break;
        case STRING:
            fprintf(yyout, "%-10s\t%-10s", "STRING", yytext);
            break;
        case INPUT:
            fprintf(yyout, "%-10s\t%-10s", "INPUT", yytext);
            break;
        case OUTPUT:
            fprintf(yyout, "%-10s\t%-10s", "OUTPUT", yytext);
            break;
        default:
            fprintf(yyout, "无%s", yytext);
    }
    fprintf(yyout, "\n");
}
