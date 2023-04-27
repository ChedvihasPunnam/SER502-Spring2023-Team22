rev(LexFile, CodeFile) :-
    process_create(path('python'), [LexFile, CodeFile], [stdout(pipe(InputStream))]),
    read_string(InputStream, _, A),
    term_to_atom(B, A),
    write('SER502-Spring2023-Team22'), nl,
    write('--Rev Programming Language--'), nl,
    write('@Authors-- Chedvihas Punnam, Gnanadeep Settykara, Teja Lam, Naga Vamsi Bhargava Reddy Seelam, Vikranth Reddy Tripuram'), nl, nl,
    program(ParsedTree, B, []),
    write('Starting program execution.....'), write(CodeFile), nl, nl,
    write('Tokens List:'), nl, 
    write(B),nl, nl,
    write('Parsed Tree:'), nl, write(ParsedTree),nl, nl, 
    write('Prgram-Output:'), nl,
    eval_program(ParsedTree, ProgramOutput).