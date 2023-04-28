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

%====================-------------==================------------==========================-------------===================

%search predicate find the respective values from the environment

search(Var_Id, [(_Dtype, Var_Id, Result)|_], Result).
search(Var_Id, [_|Envrnmnt_Tail], Result) :- search(Var_Id, Envrnmnt_Tail, Result).

search_type(Var_Id, [_|Envrnmnt_Tail], Result) :- search_type(Var_Id, Envrnmnt_Tail, Result).
search_type(Var_Id, [(Dtype,Var_Id,_X)|_], Dtype).

%modify predicate updates the value of the idntfr_name

modify(Dtype, Var_Id, New_Value, [], [(Dtype, Var_Id, New_Value)]).
modify(Dtype, Var_Id, New_Value, [(Dtype, Var_Id, _)|Envrnmnt_Tail], [(Dtype, Var_Id, New_Value)|Envrnmnt_Tail]).
modify(Dtype, Var_Id, New_Value, [Curr|Envrnmnt_Tail], [Curr|Rem]) :- modify(Dtype, Var_Id, New_Value, Envrnmnt_Tail, Rem).

%====================-------------==================------------==========================-------------===================

%Evaluating the block of the code
exec_codeblock(parsed_codeblock(C), Envrnmnt, Last_Envrnmnt) :- exec_codeblock_segment(C, Envrnmnt, Last_Envrnmnt).
exec_codeblock_segment(parsed_codeblock(C, G), Envrnmnt, Last_Envrnmnt) :- exec_stmnts(C, Envrnmnt, Envrnmnt1), 
    exec_codeblock_segment(G, Envrnmnt1, Last_Envrnmnt).
exec_codeblock_segment(parsed_codeblock(C), Envrnmnt, Last_Envrnmnt) :- exec_stmnts(C, Envrnmnt, Last_Envrnmnt).

%Evaluating the program
exec_program(parsed_program(C), Last_Envrnmnt) :- exec_codeblock(C, [], Last_Envrnmnt), !.

%Evaluating various kinds of the statements
exec_declare(parsed_declare(C, G), Envrnmnt, NewEnvrnmnt):- 
    exec_chrctr_tree(G, Var_Id),
    modify(C, Var_Id, _, Envrnmnt, NewEnvrnmnt).
exec_declare(parsed_int_declrtn(int, G, Z), Envrnmnt, NewEnvrnmnt):- 
    exec_chrctr_tree(G, Var_Id),
    exec_expr(Z, Envrnmnt, Envrnmnt1, New_Value),
    modify(int, Var_Id, New_Value, Envrnmnt1, NewEnvrnmnt).
exec_declare(parsed_str_declrtn(varchar, G, Z), Envrnmnt, NewEnvrnmnt):- 
    exec_chrctr_tree(G, Var_Id),
    exec_str(Z, Envrnmnt, NewEnvrnmnt1, New_Value),
    modify(varchar, Var_Id, New_Value, NewEnvrnmnt1, NewEnvrnmnt).
exec_declare(parsed_declarebool(bool, G, true), Envrnmnt, NewEnvrnmnt):- 
    exec_chrctr_tree(G, Var_Id),
    modify(bool, Var_Id, true, Envrnmnt, NewEnvrnmnt).
exec_declare(parsed_declarebool(bool, G, false), Envrnmnt, NewEnvrnmnt):- 
    exec_chrctr_tree(G, Var_Id),
    modify(bool, Var_Id, false, Envrnmnt, NewEnvrnmnt).

%Evaluating the various statements
exec_stmnts(parsed_stmnts(C), Envrnmnt, Last_Envrnmnt) :- 
    exec_declare(C, Envrnmnt, Last_Envrnmnt);
    exec_assign(C, Envrnmnt, Last_Envrnmnt);
    exec_boolean(C, Envrnmnt, Last_Envrnmnt, _New_Value);
    exec_print(C, Envrnmnt, Last_Envrnmnt);
    exec_if(C, Envrnmnt, Last_Envrnmnt);
    exec_while(C, Envrnmnt, Last_Envrnmnt);
    exec_forloop(C, Envrnmnt, Last_Envrnmnt);
    exec_foreach(C, Envrnmnt, Last_Envrnmnt);
    exec_ternary_op(C, Envrnmnt, Last_Envrnmnt);
    exec_iter(C, Envrnmnt, Last_Envrnmnt).

%Evaluating the assignment operation
exec_assign(parsed_assign(C, G), Envrnmnt, NewEnvrnmnt) :- 
    exec_expr(G, Envrnmnt, Envrnmnt1, New_Value),
    type_check(New_Value, Ty),
    exec_chrctr_tree(C, Var_Id),
    search_type(Var_Id, Envrnmnt1, Ty1),
    Ty =@= Ty1,
    modify(Ty, Var_Id, New_Value, Envrnmnt1, NewEnvrnmnt).
exec_assign(parsed_assign(C, G), Envrnmnt, NewEnvrnmnt) :- 
    exec_str(G, Envrnmnt, Envrnmnt, New_Value),
    type_check(New_Value, Ty),
    exec_chrctr_tree(C, Var_Id),
    search_type(Var_Id, Envrnmnt, Ty1),
    Ty =@= Ty1,
    modify(Ty, Var_Id, New_Value, Envrnmnt, NewEnvrnmnt).
exec_assign(parsed_assign(C, G), Envrnmnt, NewEnvrnmnt) :- 
   exec_boolean(G, Envrnmnt, Envrnmnt, New_Value),
    type_check(New_Value, Ty),
    exec_chrctr_tree(C, Var_Id),
   search_type(Var_Id, Envrnmnt, Ty1),
    Ty =@= Ty1,
    modify(Ty, Var_Id, New_Value, Envrnmnt, NewEnvrnmnt).

%Evaluating interpreted condition like boolean
exec_boolean(true, _Envrnmnt1, _NewEnvrnmnt, true).
exec_boolean(false, _Envrnmnt1, _NewEnvrnmnt,false).
exec_boolean(parsed_bool_not(G), Envrnmnt, NewEnvrnmnt, New_Value) :- 
    (exec_boolean(G, Envrnmnt, NewEnvrnmnt, New_Value1);exec_interpreted_condtn(G, Envrnmnt, NewEnvrnmnt, New_Value1)), 
    not(New_Value1, New_Value2), 
    New_Value = New_Value2.
exec_boolean(parsed_bool_and(C, G), Envrnmnt, NewEnvrnmnt, New_Value) :- 
    exec_boolean(C, Envrnmnt, NewEnvrnmnt, New_Value1),
    exec_boolean(G, Envrnmnt, NewEnvrnmnt, New_Value2),
    and(New_Value1, New_Value2, New_Value).
exec_boolean(parsed_bool_and(C, G), Envrnmnt, NewEnvrnmnt, New_Value) :- 
    exec_interpreted_condtn(C, Envrnmnt, NewEnvrnmnt, New_Value1),
    exec_interpreted_condtn(G, Envrnmnt, NewEnvrnmnt, New_Value2), 
    and(New_Value1, New_Value2, New_Value).
exec_boolean(parsed_bool_or(C, G), Envrnmnt, NewEnvrnmnt, New_Value) :- 
    exec_boolean(C, Envrnmnt, NewEnvrnmnt, New_Value1),
    exec_boolean(G, Envrnmnt, NewEnvrnmnt, New_Value2),
    or(New_Value1, New_Value2, New_Value).
exec_boolean(parsed_bool_or(C, G), Envrnmnt, NewEnvrnmnt, New_Value) :- 
    exec_interpreted_condtn(C, Envrnmnt, NewEnvrnmnt, New_Value1),
    exec_interpreted_condtn(G, Envrnmnt, NewEnvrnmnt, New_Value2),
    or(New_Value1, New_Value2, New_Value).

%Evaluating the interpreted condtion if
exec_if(parsed_if_cond(C,G), Envrnmnt,Last_Envrnmnt):- 
    ((exec_interpreted_condtn(C, Envrnmnt, NewEnvrnmnt,true);exec_boolean(C, Envrnmnt, NewEnvrnmnt,true)),exec_codeblock(G, NewEnvrnmnt,Last_Envrnmnt)).
exec_if(parsed_if_cond(C,_Y), Envrnmnt, NewEnvrnmnt):- 
    exec_interpreted_condtn(C, Envrnmnt, NewEnvrnmnt,false);exec_boolean(C, Envrnmnt, NewEnvrnmnt,false).
exec_if(parsed_if_cond(C,G,_Z), Envrnmnt,Last_Envrnmnt):- 
    (exec_interpreted_condtn(C, Envrnmnt, NewEnvrnmnt,true);exec_boolean(C, Envrnmnt, NewEnvrnmnt,true)),
    exec_codeblock(G, NewEnvrnmnt,Last_Envrnmnt).
exec_if(parsed_if_cond(C,_Y,Z), Envrnmnt,Last_Envrnmnt):- 
    (exec_interpreted_condtn(C, Envrnmnt, NewEnvrnmnt,false);exec_boolean(C, Envrnmnt, NewEnvrnmnt,false)),
    exec_codeblock(Z, NewEnvrnmnt,Last_Envrnmnt).


%Evaluating the print statements
exec_print(parsed_print(C), Envrnmnt, Envrnmnt) :- 
    exec_chrctr_tree(C,Var_Id),
    search(Var_Id, Envrnmnt, New_Value),
    writeln(New_Value).
exec_print(parsed_print(C), Envrnmnt, Envrnmnt) :- 
    exec_numtree(C, New_Value),
    writeln(New_Value).
exec_print(parsed_print(C), Envrnmnt, Envrnmnt) :- 
    exec_str(C, Envrnmnt, Envrnmnt, New_Value),
    writeln(New_Value).

%Evaluating the data about while loop
exec_while(parsed_whileloop(C,G), Envrnmnt,Last_Envrnmnt):- 
    exec_boolean(C, Envrnmnt, NewEnvrnmnt,true),
    exec_codeblock(G, NewEnvrnmnt, NewEnvrnmnt1),
    exec_while(parsed_whileloop(C,G), NewEnvrnmnt1,Last_Envrnmnt).
exec_while(parsed_whileloop(C,_Y), Envrnmnt, Envrnmnt) :- 
    exec_boolean(C, Envrnmnt, Envrnmnt,false).
exec_while(parsed_whileloop(C,G), Envrnmnt,Last_Envrnmnt):- 
    exec_interpreted_condtn(C, Envrnmnt, NewEnvrnmnt,true),
    exec_codeblock(G, NewEnvrnmnt, NewEnvrnmnt1),
    exec_while(parsed_whileloop(C,G), NewEnvrnmnt1,Last_Envrnmnt).
exec_while(parsed_whileloop(C,_Y), Envrnmnt, Envrnmnt) :- 
    exec_interpreted_condtn(C, Envrnmnt, Envrnmnt,false).

%Executing interpreted_condtnal operation
exec_interpreted_condtn(parsed_interpreted_condtn(C, ==, G), Envrnmnt, NewEnvrnmnt, New_Value) :- 
    exec_expr(C, Envrnmnt, NewEnvrnmnt, New_Value1),
    exec_expr(G, Envrnmnt, NewEnvrnmnt, New_Value2),
    (( New_Value1 =:= New_Value2, New_Value = true); ( \+(New_Value1 =:= New_Value2), New_Value = false)).
exec_interpreted_condtn(parsed_interpreted_condtn(C, '!=', G), Envrnmnt, NewEnvrnmnt, New_Value) :- 
    exec_expr(C, Envrnmnt, NewEnvrnmnt, New_Value1),
    exec_expr(G, Envrnmnt, NewEnvrnmnt, New_Value2),
    (( New_Value1 =\= New_Value2, New_Value = true);( \+(New_Value1 =\= New_Value2), New_Value = false)).
exec_interpreted_condtn(parsed_interpreted_condtn(C, '>', G), Envrnmnt, NewEnvrnmnt, New_Value) :-
    exec_expr(C, Envrnmnt, NewEnvrnmnt, New_Value1),
    exec_expr(G, Envrnmnt, NewEnvrnmnt, New_Value2),
    (( New_Value1 > New_Value2, New_Value = true);( \+(New_Value1 > New_Value2), New_Value = false)).
exec_interpreted_condtn(parsed_interpreted_condtn(C, '<', G), Envrnmnt, NewEnvrnmnt, New_Value) :- 
    exec_expr(C, Envrnmnt, NewEnvrnmnt, New_Value1),
    exec_expr(G, Envrnmnt, NewEnvrnmnt, New_Value2),
    (( New_Value1 < New_Value2, New_Value = true);( \+(New_Value1 < New_Value2), New_Value = false)).
exec_interpreted_condtn(parsed_interpreted_condtn(C, '>=', G), Envrnmnt, NewEnvrnmnt, New_Value) :- 
    exec_expr(C, Envrnmnt, NewEnvrnmnt, New_Value1),
    exec_expr(G, Envrnmnt, NewEnvrnmnt, New_Value2),
    (( New_Value1 >= New_Value2, New_Value = true);( \+(New_Value1 >= New_Value2), New_Value = false)).
exec_interpreted_condtn(parsed_interpreted_condtn(C, '<=', G), Envrnmnt, NewEnvrnmnt, New_Value) :- 
    exec_expr(C, Envrnmnt, NewEnvrnmnt, New_Value1),
    exec_expr(G, Envrnmnt, NewEnvrnmnt, New_Value2),
    (( New_Value1 =< New_Value2, New_Value = true);( \+(New_Value1 =< New_Value2), New_Value = false)).
exec_interpreted_condtn(parsed_interpreted_condtn(C, ==, G), Envrnmnt, NewEnvrnmnt, New_Value) :- 
    exec_str(C, Envrnmnt, NewEnvrnmnt, New_Value1),
    exec_str(G, Envrnmnt, NewEnvrnmnt, New_Value2),
    ((New_Value1 = New_Value2, New_Value = true);(\+(New_Value1 = New_Value2), New_Value = false)).
exec_interpreted_condtn(parsed_interpreted_condtn(C,'!=',G), Envrnmnt, NewEnvrnmnt, New_Value) :-
    exec_str(C, Envrnmnt, NewEnvrnmnt, New_Value1),
    exec_str(G, Envrnmnt, NewEnvrnmnt, New_Value2),
    ((New_Value1 = New_Value2, New_Value = false);(\+(New_Value1 = New_Value2), New_Value = true)).
exec_interpreted_condtn(parsed_interpreted_condtn(C,'>',G), Envrnmnt, NewEnvrnmnt,_New_Value) :- 
    exec_str(C, Envrnmnt, NewEnvrnmnt,_New_Value1),
    exec_str(G, Envrnmnt, NewEnvrnmnt,_New_Value2),
    write("Operation is incorrect!").
exec_interpreted_condtn(parsed_interpreted_condtn(C,'<',G), Envrnmnt, NewEnvrnmnt,_New_Value) :- 
    exec_str(C, Envrnmnt, NewEnvrnmnt,_New_Value1),
    exec_str(G, Envrnmnt, NewEnvrnmnt,_New_Value2),
    write("Operation is incorrect!").
exec_interpreted_condtn(parsed_interpreted_condtn(C,'>=',G), Envrnmnt, NewEnvrnmnt,_New_Value) :- 
    exec_str(C, Envrnmnt, NewEnvrnmnt,_New_Value1),
    exec_str(G, Envrnmnt, NewEnvrnmnt,_New_Value2),
    write("Operation is incorrect!").
exec_interpreted_condtn(parsed_interpreted_condtn(C,'<=',G), Envrnmnt, NewEnvrnmnt,_New_Value) :- 
    exec_str(C, Envrnmnt, NewEnvrnmnt,_New_Value1),
    exec_str(G, Envrnmnt, NewEnvrnmnt,_New_Value2),
    write("Operation is incorrect!").
exec_interpreted_condtn(parsed_interpreted_condtn(C,==,G), Envrnmnt, NewEnvrnmnt, New_Value) :-
    exec_chrctr_tree(C,Var_Id),
    search(Var_Id, Envrnmnt, New_Value1),
    type_check(New_Value1,Ty),
    Ty=varchar,
    exec_str(G, Envrnmnt, NewEnvrnmnt, New_Value2),
    ((New_Value1 =@= New_Value2, New_Value = true);(\+(New_Value1 =@= New_Value2), New_Value = false)).
exec_interpreted_condtn(parsed_interpreted_condtn(C,'!=',G), Envrnmnt, NewEnvrnmnt, New_Value) :- 
    exec_chrctr_tree(C,Var_Id),
    search(Var_Id, Envrnmnt, New_Value1),
    type_check(New_Value1,Ty),
    Ty=varchar,
    exec_str(G, Envrnmnt, NewEnvrnmnt, New_Value2),
    ((New_Value1 = New_Value2, New_Value = false);(\+(New_Value1 = New_Value2), New_Value = true)).
exec_interpreted_condtn(parsed_interpreted_condtn(C,'>',G), Envrnmnt, NewEnvrnmnt,_New_Value) :- 
    exec_chrctr_tree(C,Var_Id),
    search(Var_Id, Envrnmnt, New_Value1),
    type_check(New_Value1,Ty),
    Ty=varchar,
    exec_str(G, Envrnmnt, NewEnvrnmnt,_New_Value2),
    write("Operation is incorrect!").
exec_interpreted_condtn(parsed_interpreted_condtn(C,'<',G), Envrnmnt, NewEnvrnmnt,_New_Value) :- 
    exec_chrctr_tree(C,Var_Id),
    search(Var_Id, Envrnmnt, New_Value1),
    type_check(New_Value1,Ty),
    Ty=varchar,
    exec_str(G, Envrnmnt, NewEnvrnmnt,_New_Value2),
    write("Operation is incorrect!").
exec_interpreted_condtn(parsed_interpreted_condtn(C,'>=',G), Envrnmnt, NewEnvrnmnt,_New_Value) :- 
    exec_chrctr_tree(C,Var_Id),
    search(Var_Id, Envrnmnt, New_Value1),
    type_check(New_Value1,Ty),
    Ty=varchar,
    exec_str(G, Envrnmnt, NewEnvrnmnt,_New_Value2),
    write("Operation is incorrect!").
exec_interpreted_condtn(parsed_interpreted_condtn(C,'<=',G), Envrnmnt, NewEnvrnmnt,_New_Value) :- 
    exec_chrctr_tree(C,Var_Id),
    search(Var_Id, Envrnmnt, New_Value1),
    type_check(New_Value1,Ty),
    Ty=varchar,
    exec_str(G, Envrnmnt, NewEnvrnmnt,_New_Value2),
    write("Operation is incorrect!").
