:- style_check(-singleton).
rev(LexFile, CodeFile) :-
    process_create(path('python'), [LexFile, CodeFile], [stdout(pipe(In))]),
    read_string(In, _, A),
    term_to_atom(B, A),
    write('SER502-Spring2023-Team22'), nl,
    write('--Rev Programming Language--'), nl,
    write('@Authors-- Chedvihas Punnam, Gnanadeep Settykara, Teja Lam, Naga Vamsi Bhargava Reddy Seelam, Vikranth Reddy Tripuram'), nl, nl,
    program(ParsedTree, B, []),
    write('Starting program execution.....'), write(CodeFile), nl, nl,
    write('Tokens List:'), nl, 
    write(B),nl, nl,
    write('Parsed Tree:'), nl, write(ParsedTree),nl, nl, 
    write('Program-Output:'), nl,
    exec_program(ParsedTree, ProgramOutput).

%====================-------------==================------------==========================-------------===================

:- table boolean/3, exprssn/3, term/3.

%Parsing the program segment  
program(parsed_program(R)) -->['init'], codeblock(R), ['exit'].

%Parsing the block of code section
codeblock(parsed_codeblock(R)) --> ['{'], codeblock_segment(R), ['}']. 
codeblock_segment(parsed_codeblock(R, L)) --> stmnts(R), codeblock_segment(L).
codeblock_segment(parsed_codeblock(R)) --> stmnts(R).

%Parsing the various kinds of statements
stmnts(parsed_stmnts(R)) --> for_loop_info(R).
stmnts(parsed_stmnts(R)) --> while_loop_info(R).
stmnts(parsed_stmnts(R)) --> foreach(R).
stmnts(parsed_stmnts(R)) --> iterable_loop(R), [;].
stmnts(parsed_stmnts(R)) --> dclrtn(R), [;].
stmnts(parsed_stmnts(R)) --> assgnmnt(R), [;].
stmnts(parsed_stmnts(R)) --> if_cndtn(R).
stmnts(parsed_stmnts(R)) --> ternary_cndtn(R), [;].
stmnts(parsed_stmnts(R)) --> exprssn(R), [;].
stmnts(parsed_stmnts(R)) --> boolean(R), [;].
stmnts(parsed_stmnts(R)) --> printstmnts(R), [;].

%Parsing the declaration of the variable
dclrtn(parsed_declare(R, L)) --> type(R), idntfr_name(L).
dclrtn(parsed_str_declrtn(varchar, R, L)) --> ['varchar'], idntfr_name(R), ['='], string(L).
dclrtn(parsed_declarebool(bool, R, true)) --> ['bool'], idntfr_name(R), [=], ['true'].
dclrtn(parsed_int_declrtn(int, R, L)) --> ['int'], idntfr_name(R), ['='], exprssn(L).
dclrtn(parsed_declarebool(bool, R, false)) --> ['bool'], idntfr_name(R), [=], ['false'].

%Parsing the operator related to the assignment
assgnmnt(parsed_assign(R, L)) --> idntfr_name(R), ['='], boolean(L).
assgnmnt(parsed_assign(R, L)) --> idntfr_name(R), ['='], exprssn(L).

%Parsing datatype
type(varchar) --> ['varchar'].
type(bool) --> ['bool'].
type(int) --> ['int'].

%Parsing information about the while loop
while_loop_info(parsed_whileloop(A, B)) --> ['while'], ['('], (interpreted_condtn(A);boolean(A)), [')'], codeblock(B).

%Parsing data about the for loop
for_loop_info(parsed_for_loop_info(C, G, T, V)) --> ['for'], ['('], assgnmnt(C), [';'], (interpreted_condtn(G);boolean(G)), [';'], iterable_loop(T), [')'], codeblock(V).
for_loop_info(parsed_for_loop_info(C, G, T, V)) --> ['for'], ['('], dclrtn(C), [';'], (interpreted_condtn(G);boolean(G)), [';'], iterable_loop(T), [')'], codeblock(V).
for_loop_info(parsed_for_loop_info(C, G, T, V)) --> ['for'], ['('], dclrtn(C), [';'], (interpreted_condtn(G);boolean(G)), [';'], assgnmnt(T), [')'], codeblock(V).
for_loop_info(parsed_for_loop_info(C, G, T, V)) --> ['for'], ['('], assgnmnt(C), [';'], (interpreted_condtn(G);boolean(G)), [';'], exprssn(T), [')'], codeblock(V).

%Parsing the for each loop
foreach(parsed_foreach(C, G, T, V)) --> ['for'], idntfr_name(C), ['in'], ['each'], ['('], num(G), [':'], num(T), [')'], codeblock(V).
foreach(parsed_foreach(C, G, T, V)) --> ['for'], idntfr_name(C), ['in'], ['each'], ['('], num(G), [':'], idntfr_name(T), [')'], codeblock(V).
foreach(parsed_foreach(C, G, T, V)) --> ['for'], idntfr_name(C), ['in'], ['each'], ['('], idntfr_name(G), [':'], num(T), [')'], codeblock(V).
foreach(parsed_foreach(C, G, T, V)) --> ['for'], idntfr_name(C), ['in'], ['each'], ['('], idntfr_name(G), [':'], idntfr_name(T), [')'], codeblock(V).

%Parsing the if condition
if_cndtn(parsed_if_cond(C, G, T)) --> ['if'], ['('], (interpreted_condtn(C);boolean(C)), [')'], codeblock(G), ['else'], codeblock(T).
if_cndtn(parsed_if_cond(C, G)) --> ['if'], ['('], (interpreted_condtn(C);boolean(C)), [')'], codeblock(G).

%Parsing ternary operator condition
ternary_cndtn(parsed_tern_cond(C, G, T)) --> (interpreted_condtn(C);boolean(C)), ['?'], stmnts(G), [':'], stmnts(T).

%Parsing the expression related to boolean variables
boolean(true) --> ['true'].
boolean(false) --> ['false'].
boolean(parsed_bool_not(R)) --> ['not'],['('], boolean(R), [')'].
boolean(parsed_bool_not(R)) --> ['not'],['('], interpreted_condtn(R), [')'].
boolean(parsed_bool_and(R, L)) --> boolean(R), ['and'], boolean(L).
boolean(parsed_bool_and(R, L)) --> interpreted_condtn(R), ['and'], interpreted_condtn(L).
boolean(parsed_bool_or(R, L)) --> boolean(R), ['or'], boolean(L).
boolean(parsed_bool_or(R, L)) --> interpreted_condtn(R), ['or'], interpreted_condtn(L).

%Parsing print related statements 
printstmnts(parsed_print(R)) --> ['print'], idntfr_name(R).
printstmnts(parsed_print(R)) --> ['print'], num(R).
printstmnts(parsed_print(R)) --> ['print'], string(R).

%Parsing the interpreted condition
interpreted_condtn(parsed_interpreted_condtn(R, L, Z)) --> exprssn(R), opratr_token(L), exprssn(Z).
interpreted_condtn(parsed_interpreted_condtn(R, L, Z)) --> string(R), opratr_token(L), string(Z).
interpreted_condtn(parsed_interpreted_condtn(R, L, Z)) --> idntfr_name(R), opratr_token(L), string(Z).

%Parsing the interpreted condition for operator token
opratr_token('!=') --> ['!='].
opratr_token(==) --> ['=='].
opratr_token(<) --> ['<'].
opratr_token(>) --> ['>'].
opratr_token(<=) --> ['<='].
opratr_token(>=) --> ['>='].

%Parsing operations like multiplication--addition--division--subtraction
exprssn(parsed_addtn(C, G)) --> exprssn(C), ['+'], term(G).
exprssn(parsed_subtrn(C, G)) --> exprssn(C), ['-'], term(G).
exprssn(C) --> term(C).
term(parsed_multpcn(C, G)) --> term(C), ['*'], term(G).
term(parsed_divsn(C, G)) --> term(C), ['/'], term(G).
term(C) --> ['('], exprssn(C), [')'].
term(C) --> num(C).
term(C) --> idntfr_name(C).

%Parsing operations of unary decrement---increment
iterable_loop(parsed_decrmnt(C)) --> idntfr_name(C), ['-'], ['-'].
iterable_loop(parsed_incrmnt(C)) --> idntfr_name(C), ['+'], ['+'] .

%Parsing string, number and identifier name
idntfr_name(idntfr_name(G)) --> [G], {atom(G)}.
num(parsed_num(G)) --> [G], {number(G)}.
onlystring(parsed_str(G)) --> [G], {atom(G)}.
string(G) --> onlystring(G).

type_check(New_Value, Result) :- (New_Value = true ; New_Value = false), Result = bool.
type_check(New_Value, Result) :- string(New_Value), Result = varchar.
type_check(New_Value, Result) :- integer(New_Value), Result = int.

not(false, true).
not(true, false).

and(true, true, true).
and(false, _, false).
and(_, false, false).

or(false, false, false).
or(true, _, true).
or(_, true, true).