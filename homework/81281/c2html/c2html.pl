:- use_module(library(dcg/basics)).
:- use_module(library(readutil)).

:- set_prolog_flag(verbose, silent).

:- initialization(main, main).

main :-
    current_prolog_flag(argv, Argv),
    Argv = [H|_],
    atom_string(H, File),
    mainy(File),
    format('You can see the result in the html file.~n'),
    halt.
main :-
    halt(1).

mainy(File):-
    open(File, read, RFile),
    read_stream_to_codes(RFile, CSource),
    close(RFile),
    phrase(tokens(Tokens), CSource),
%%    write(Tokens),
    open('page.html', write, WFile),
    write(WFile,"<!doctype>
    <html>
    <head>
        <title>hello.c</title>
        <style>
           .keyword {
               color: blue;
           }
           .number {
               color: violet;
           }
           .identifier {
               color: green;
           }
           .operator {
               font-style: bold;
               color: blue;
           }
           .comment {
               color: lime;
           }
           .string {
               color: orange;
           }
           .parenthese {
               font-style: bold;
               color: brown;
           }
           .quotation {
               font-style: bold;
               color: black;
           }
           .function {
               color: purple;
           }
       </style>
    </head>
    <body>
        <pre class=\"code\">"),
    tohtmlfile(WFile,Tokens),
    close(WFile).

%% Definitions of tokens
token([tauto, "auto" ]) --> "auto", !.
token([tbreak, "break" ]) --> "break", !.
token([tcase, "case" ]) --> "case", !.
token([tchar, "char" ]) --> "char", !.
token([tconst, "const" ]) --> "const", !.
token([tcontinue, "continue" ]) --> "continue", !.
token([tdefault, "default" ]) --> "default", !.
token([tdo, "do" ]) --> "do", !.
token([tdouble, "double" ]) --> "double", !.
token([telse, "else" ]) --> "else", !.
token([tenum, "enum" ]) --> "enum", !.
token([textern, "extern" ]) --> "extern", !.
token([tfloat, "float" ]) --> "float", !.
token([tfor, "for" ]) --> "for", !.
token([tgoto, "goto" ]) --> "goto", !.
token([tif, "if" ]) --> "if", !.
token([tint, "int" ]) --> "int", !.
token([tlong, "long" ]) --> "long", !.
token([tregister, "register" ]) --> "register", !.
token([treturn, "return" ]) --> "return", !.
token([tshort, "short" ]) --> "short", !.
token([tsigned, "signed" ]) --> "signed", !.
token([tsizeof, "sizeof" ]) --> "sizeof", !.
token([tstatic, "static" ]) --> "static", !.
token([tstruct, "struct" ]) --> "struct", !.
token([tswitch,  "switch"]) --> "switch", !.
token([ttypedef, "switch" ]) --> "typedef", !.
token([tunion, "union" ]) --> "union", !.
token([tunsigned, "unsigned" ]) --> "unsigned", !.
token([tvoid, "void" ]) --> "void", !.
token([tvolatile, "volatile" ]) --> "volatile", !.
token([twhile, "while" ]) --> "while", !.
token([tinclude, "#include" ]) --> "#include", !.

token([tcomment1, IA]) --> comment1(I), !,
    {atom_chars(IA,I)}.

%% Handling windows written files with "\r\n"
token([[tcomment2, IA], [execNL, '\n']]) --> comment2(I), !,
    {append(I1, [C1, C2], I),
    ((char_code('\r', C1), char_code('\n', C2), atom_chars(IA,I1));
    (\+ char_code('\r', C1), char_code('\n', C2),
    append(I1, [C1], I2), atom_chars(IA,I2)))}.

token([ttypesPrintF, IA]) --> prFT(I), !,
    {atom_chars(IA,I)}.
token([tstring, IA]) --> stringy(I), !,
    {atom_chars(IA,I)}.
token([theader, IA]) --> header(I), !,
    {append(IO, [_], I), append([_], II, IO), atom_chars(IA,II)}.
token([[tfunction, IA], [tleftParen, "("]]) --> func(I), !,
    {append(IO, [_], I), IO \= [], atom_chars(IA, IO)}.

token([tmultiply, "*"]) --> "*", !.
token([tdivide, "/"]) --> "/", !.
token([tmod, "%"]) --> "%", !.
token([tadd, "+"]) --> "+", !.
token([tsubtract, "-"]) --> "-", !.
token([tless, "<"]) --> "<", !.
token([tlessEqual, "<="]) --> "<=", !.
token([tgreater, ">"]) --> ">", !.
token([tgreaterEqual,">=" ]) --> ">=", !.
token([tequal, "=="]) --> "==", !.
token([tnotequal,"!=" ]) --> "!=", !.
token([tnot, "!"]) --> "!", !.
token([tassign,"="]) --> "=", !.
token([tlogicalAnd, "&&"]) --> "&&", !.
token([tlogicalOr, "||"]) --> "||", !.
token([tbitwiseAnd, "&"]) --> "&", !.
token([tbitwiseOr, "|"]) --> "|", !.

token([tspace , " "]) --> "\s", !.
token([ttab , "\t"]) --> "\t", !.
token([execTAB , "\\t"]) --> "\\t", !.
token([execNL, "\n"]) --> ( "\n"; "\r\n"), !.
token([tnl, "\\n"]) --> "\\n", !.

token([tleftParen,"("]) --> "(", !.
token([trightParen, ")"]) --> ")", !.
token([tleftBrace, "{"]) --> "{", !.
token([trightBrace, "}"]) --> "}", !.
token([tleftSqParen, "["]) --> "[", !.
token([trightSqParen, "]" ]) --> "]", !.
token([tsemicolon, ";"]) --> ";", !.
token([ttwodots, ":"]) --> ":", !.
token([tquestion, "?"]) --> "?", !.

token([tcomma, "," ]) --> ",", !.
token([tquot, "\'"]) --> "\'", !.
token([tdoubleQuot, "\""]) --> "\"", !.
token([tdot, "."]) --> ".", !.

token([tidentifier, IA]) -->  identifier(I), !,
    {atom_chars(IA,I)}.
token([tnumber, I]) --> number(I), !.

token([tunknown, IA]) --> allThatIsNotAToken(I), !,
    {I \= [], atom_chars(IA, I)}.


%% Main predicate
tokens([Token | Tail]) --> token(Token), !, tokens(Tail).
tokens([]) --> !, [], !.


%% Helper predicates
identifier([C|Cs]) --> [C], {char_type(C, csymf)}, !,
    identifierHelper(Cs).

identifierHelper([C|Cs]) --> [C], {char_type(C, csym)}, !,
    identifierHelper(Cs).
identifierHelper([C]) --> [C], {char_type(C, csym), \+ char_code('_', C)}, !.
identifierHelper([]) --> [], !.

func([C|Cs]) --> [C], {char_type(C, csymf)}, !,
    funkHelper(Cs).

funkHelper([C|Cs]) --> [C], {char_type(C, csym)}, !,
    funkHelper(Cs).
funkHelper([C]) --> [C], {char_code("(", C)}, !.

stringy([C|Cs]) --> [C], {char_code('\"', C)}, !,
    stringyHelper(Cs).

stringyHelper([C|Cs]) --> [C], {char_type(C, csymf); char_code('.', C)},
    stringyHelper(Cs).
stringyHelper([C]) --> [C], {char_code('\"', C)}.

header([C|Cs]) --> [C], {char_code('<', C)}, !,
    hederHelper(Cs).

hederHelper([C|Cs]) --> [C],
    {char_type(C, csymf); char_code('.', C); char_code('/', C); char_code('+', C)},
    hederHelper(Cs).
hederHelper([C]) --> [C], {char_code('>', C)}.

prFT([C|Cs]) --> [C], {char_code('%', C)}, !,
    pr(Cs).

pr([C]) --> [C], {char_type(C, csym)}.

comment1([C1,C2|Cs]) --> [C1,C2], {char_code('/', C1), char_code('*', C2)}, !,
    anything(Cs),
    {append(_,[C3,C4],Cs), char_code('*', C3), char_code('/', C4)}.

comment2([C1,C2|Cs]) --> [C1,C2], {char_code('/', C1), char_code('/', C2)}, !,
    anytingButNL(Cs).

anything([C|Cs]) --> [C], anything(Cs).
anything([]) --> [].

allThatIsNotAToken([C|Cs]) --> [C|Cs], \+ tokens(C), \+ tokens([C|Cs]),
    allThatIsNotAToken(Cs).
allThatIsNotAToken([]) --> [].

anytingButNL([C|Cs]) --> [C],
    {\+ char_code('\r', C), \+ char_code('\n', C)}, anytingButNL(Cs).
anytingButNL([C1,C2|_]) --> [C1,C2],
    {(char_code('\r', C1),  char_code('\n', C2));
    (\+ char_code('\r', C1),  char_code('\n', C2))}.


%% Definitions of lists of different types of tokens
is_keyWord([H,_]):- member(H, [tauto, tbreak, tcase, tchar, tconst, tcontinue,
    tdefault, tdo, tdouble, telse, tenum, textern, tfloat, tfor, tgoto, tif,
    tint, tlong, tregister, treturn, tshort, tsigned, tsizeof, tstatic, tstruct,
    tswitch, ttypedef, tunion, tunsigned, twhile, tvoid, tvolatile, tinclude]).

is_operator([H,_]):- member(H, [tmultiply, tdivide, tmod, tadd, tsubtract, tless,
    tlessEqual, tgreater, tgreaterEqual, tequal, tnotequal, tnot, tassign, tlogicalOr,
    tlogicalAnd, tbitwiseOr, tbitwiseAnd]).

is_parenth([H,_]):- member(H, [tleftParen, trightParen, tleftBrace, trightBrace,
    tleftSqParen, trightSqParen, tsemicolon, ttwodots]).

is_quotation([H,_]):- member(H, [tquot, tdoubleQuot, tcomma, tdot, tquestion]).

is_unknown([H,_]):- member(H, [tunknown]).

is_number([H,_]):- member(H, [tnumber, ttypesPrintF]).

is_function([[H,_],_]):- member(H, [tfunction]).

is_identifier([H,_]):- member(H, [tidentifier, tnl, ttab]).

is_blank([H,_]):- member(H, [execTAB, tspace, execNL]).

is_comment1([H,_]):-member(H, [tcomment1]).

is_comment2([[H,_],_]):-member(H, [tcomment2]).

is_string([H,_]):-  member(H, [tstring]).

is_header([H,_]):- member(H, [theader]).


%% Writing to html file the stream of tokens
tohtmlfile(Stream, []):- !, write(Stream, '</pre></body></html>'), !.

tohtmlfile(Stream, [H|T]) :- is_identifier(H), H = [_,Lexem],
    write(Stream, '<span class=\"identifier\">'),
    write(Stream, Lexem),
    write(Stream,'</span>'),
    !,
    tohtmlfile(Stream, T).

tohtmlfile(Stream, [H|T]) :- is_string(H), H = [_,Lexem],
    write(Stream, '<span class=\"string\">'),
    write(Stream, Lexem),
    write(Stream,'</span>'),
    !,
    tohtmlfile(Stream, T).

tohtmlfile(Stream, [H|T]) :- is_function(H), H = [[_, Lexem1],[_,Lexem2]],
    write(Stream, '<span class=\"function\">'),
    write(Stream, Lexem1),
    write(Stream,'</span>'),
    write(Stream, '<span class=\"parenthese\">'),
    write(Stream, Lexem2),
    write(Stream,'</span>'),
    !,
    tohtmlfile(Stream, T).

tohtmlfile(Stream, [H|T]) :- is_header(H), H = [_,Lexem],
    write(Stream, '<span class=\"string\">&lt;'),
    write(Stream, Lexem),
    write(Stream,'&gt;</span>'),
    !,
    tohtmlfile(Stream, T).

tohtmlfile(Stream, [H|T]) :- is_keyWord(H), H = [_,Lexem],
    write(Stream, '<span class=\"keyword\">'),
    write(Stream, Lexem),
    write(Stream,'</span>'),
    !,
    tohtmlfile(Stream, T).

tohtmlfile(Stream, [H|T]) :- is_number(H), H = [_,Lexem],
    write(Stream, '<span class=\"number\">'),
    write(Stream, Lexem),
    write(Stream,'</span>'),
    !,
    tohtmlfile(Stream, T).

tohtmlfile(Stream, [H|T]) :- is_operator(H), H = [_,Lexem],
    write(Stream, '<span class=\"operator\">'),
    write(Stream, Lexem),
    write(Stream,'</span>'),
    !,
    tohtmlfile(Stream, T).

tohtmlfile(Stream, [H|T]) :- is_parenth(H), H = [_,Lexem],
    write(Stream, '<span class=\"parenthese\">'),
    write(Stream, Lexem),
    write(Stream,'</span>'),
    !,
    tohtmlfile(Stream, T).

tohtmlfile(Stream, [H|T]) :- (is_quotation(H); is_unknown(H)), H = [_,Lexem],
    write(Stream, '<span class=\"quotation\">'),
    write(Stream, Lexem),
    write(Stream,'</span>'),
    !,
    tohtmlfile(Stream, T).

tohtmlfile(Stream, [H|T]) :- is_comment1(H), H = [_,Lexem],
    write(Stream, '<span class=\"comment\">'),
    write(Stream, Lexem),
    write(Stream,'</span>'),
    !,
    tohtmlfile(Stream, T).

tohtmlfile(Stream, [H|T]) :- is_comment2(H), H = [[_, Lexem1],[_,Lexem2]],
    write(Stream, '<span class=\"comment\">'),
    write(Stream, Lexem1),
    write(Stream,'</span>'),
    write(Stream, Lexem2),
    !,
    tohtmlfile(Stream, T).

tohtmlfile(Stream, [H|T]) :- is_blank(H), H = [_,Lexem],
    write(Stream, Lexem),
    !,
    tohtmlfile(Stream, T).
