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

