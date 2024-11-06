# 1 "lexer.mll"
 
  (* lexer.mll *)

  open Parser        (* Assuming your parser is named 'Parser' *)
  open Ast           (* Access to AST definitions *)
  open Location      (* Access to Location module for tracking positions *)
  open PrintBox

  (* Initialize a keyword table to differentiate between keywords and identifiers *)
  let keyword_table = Hashtbl.create 20

  let () = List.iter (fun (kwd, tok) ->
    Hashtbl.add keyword_table kwd tok
  ) [
    "true", TRUE;
    "false", FALSE;
    "nil", NIL;
    "var", VAR;
    "let", LET;
    "if", IF;
    "else", ELSE;
    "while", WHILE;
    "for", FOR;
    "break", BREAK;
    "continue", CONTINUE;
    "return", RETURN;
    "int", INT;
    "byte", BYTE;
    "bool", BOOL;
    "string", STRING;
    "void", VOID;
    "record", RECORD;
    "new", NEW;
  ]

  (* Helper function to create location information *)
  let make_location lexbuf =
    let startp = Lexing.lexeme_start_p lexbuf in
    let endp = Lexing.lexeme_end_p lexbuf in
    Location.make_location (startp, endp)

# 44 "lexer.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base =
   "\000\000\221\255\222\255\078\000\088\000\001\000\226\255\227\255\
    \228\255\229\255\230\255\231\255\232\255\233\255\234\255\235\255\
    \236\255\241\255\243\255\163\000\245\255\003\000\031\000\033\000\
    \035\000\001\000\022\000\105\000\001\000\254\255\212\000\252\255\
    \002\000\004\000\253\255\251\255\250\255\249\255\248\255\247\255\
    \246\255\225\255\114\000\212\000\251\255\252\255\006\000\253\255\
    \102\000\108\000\255\255\254\255";
  Lexing.lex_backtrk =
   "\255\255\255\255\255\255\032\000\031\000\034\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\011\000\255\255\016\000\015\000\017\000\
    \018\000\034\000\034\000\013\000\034\000\255\255\000\000\255\255\
    \002\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\003\000\255\255\
    \003\000\003\000\255\255\255\255";
  Lexing.lex_default =
   "\001\000\000\000\000\000\255\255\255\255\042\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\255\255\000\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\000\000\255\255\000\000\
    \032\000\255\255\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\042\000\045\000\000\000\000\000\255\255\000\000\
    \255\255\255\255\000\000\000\000";
  Lexing.lex_trans =
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\030\000\029\000\029\000\034\000\028\000\034\000\033\000\
    \047\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \030\000\023\000\005\000\041\000\000\000\017\000\025\000\036\000\
    \007\000\006\000\018\000\020\000\014\000\019\000\012\000\027\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\015\000\013\000\022\000\024\000\021\000\016\000\
    \040\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\011\000\039\000\010\000\038\000\004\000\
    \037\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\009\000\026\000\008\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\035\000\031\000\041\000\051\000\050\000\000\000\
    \032\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\000\000\000\000\000\000\000\000\004\000\
    \000\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\030\000\047\000\000\000\
    \000\000\046\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\030\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\048\000\000\000\
    \002\000\255\255\255\255\049\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\255\255\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\044\000";
  Lexing.lex_check =
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\028\000\032\000\000\000\033\000\032\000\
    \046\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\000\000\000\000\005\000\255\255\000\000\000\000\025\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \021\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\022\000\000\000\023\000\000\000\
    \024\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\026\000\027\000\042\000\048\000\049\000\255\255\
    \027\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\255\255\255\255\255\255\255\255\004\000\
    \255\255\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\019\000\019\000\019\000\019\000\019\000\
    \019\000\019\000\019\000\019\000\019\000\030\000\043\000\255\255\
    \255\255\043\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\030\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\043\000\255\255\
    \000\000\005\000\032\000\043\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\042\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\043\000";
  Lexing.lex_base_code =
   "";
  Lexing.lex_backtrk_code =
   "";
  Lexing.lex_default_code =
   "";
  Lexing.lex_trans_code =
   "";
  Lexing.lex_check_code =
   "";
  Lexing.lex_code =
   "";
}

let rec tokenize lexbuf =
   __ocaml_lex_tokenize_rec lexbuf 0
and __ocaml_lex_tokenize_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 56 "lexer.mll"
               ( tokenize lexbuf )
# 211 "lexer.ml"

  | 1 ->
# 59 "lexer.mll"
            ( Lexing.new_line lexbuf; tokenize lexbuf )
# 216 "lexer.ml"

  | 2 ->
# 62 "lexer.mll"
                                         ( 
      Lexing.new_line lexbuf; 
      tokenize lexbuf 
    )
# 224 "lexer.ml"

  | 3 ->
# 68 "lexer.mll"
         ( comment 1 lexbuf )
# 229 "lexer.ml"

  | 4 ->
# 71 "lexer.mll"
         ( LOR )
# 234 "lexer.ml"

  | 5 ->
# 72 "lexer.mll"
         ( LAND )
# 239 "lexer.ml"

  | 6 ->
# 73 "lexer.mll"
         ( EQ )
# 244 "lexer.ml"

  | 7 ->
# 74 "lexer.mll"
         ( NEQ )
# 249 "lexer.ml"

  | 8 ->
# 75 "lexer.mll"
         ( LE )
# 254 "lexer.ml"

  | 9 ->
# 76 "lexer.mll"
         ( GE )
# 259 "lexer.ml"

  | 10 ->
# 79 "lexer.mll"
        ( PLUS )
# 264 "lexer.ml"

  | 11 ->
# 80 "lexer.mll"
        ( MINUS )
# 269 "lexer.ml"

  | 12 ->
# 81 "lexer.mll"
        ( MUL )
# 274 "lexer.ml"

  | 13 ->
# 82 "lexer.mll"
        ( DIV )
# 279 "lexer.ml"

  | 14 ->
# 83 "lexer.mll"
        ( REM )
# 284 "lexer.ml"

  | 15 ->
# 84 "lexer.mll"
        ( LT )
# 289 "lexer.ml"

  | 16 ->
# 85 "lexer.mll"
        ( GT )
# 294 "lexer.ml"

  | 17 ->
# 86 "lexer.mll"
        ( LNOT )
# 299 "lexer.ml"

  | 18 ->
# 87 "lexer.mll"
        ( ASSIGN )
# 304 "lexer.ml"

  | 19 ->
# 88 "lexer.mll"
        ( QUESTIONMARK )
# 309 "lexer.ml"

  | 20 ->
# 89 "lexer.mll"
        ( COLON )
# 314 "lexer.ml"

  | 21 ->
# 90 "lexer.mll"
        ( COMMA )
# 319 "lexer.ml"

  | 22 ->
# 91 "lexer.mll"
        ( SEMICOLON )
# 324 "lexer.ml"

  | 23 ->
# 92 "lexer.mll"
        ( DOT )
# 329 "lexer.ml"

  | 24 ->
# 93 "lexer.mll"
        ( LBRACKET )
# 334 "lexer.ml"

  | 25 ->
# 94 "lexer.mll"
        ( RBRACKET )
# 339 "lexer.ml"

  | 26 ->
# 95 "lexer.mll"
        ( LBRACE )
# 344 "lexer.ml"

  | 27 ->
# 96 "lexer.mll"
        ( RBRACE )
# 349 "lexer.ml"

  | 28 ->
# 97 "lexer.mll"
        ( LPAREN )
# 354 "lexer.ml"

  | 29 ->
# 98 "lexer.mll"
        ( RPAREN )
# 359 "lexer.ml"

  | 30 ->
let
# 101 "lexer.mll"
                  s
# 365 "lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 101 "lexer.mll"
                    ( 
      STRING_LIT (String.sub s 1 (String.length s - 2))  (* Remove the surrounding quotes *)
    )
# 371 "lexer.ml"

  | 31 ->
let
# 106 "lexer.mll"
             id
# 377 "lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 106 "lexer.mll"
                ( 
      try 
        Hashtbl.find keyword_table id 
      with 
        Not_found -> IDENT id 
    )
# 386 "lexer.ml"

  | 32 ->
let
# 114 "lexer.mll"
               num
# 392 "lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 114 "lexer.mll"
                   (
    try
      INT_LIT (Int64.of_string num)
    with
      Failure _ ->
        let loc = make_location lexbuf in
        (* Print the location tree to stdout *)
        PrintBox_text.output stdout (Location.location_to_tree loc);
        (* Raise the exception with the message *)
        failwith ("Integer literal out of bounds: " ^ num);
  )
# 406 "lexer.ml"

  | 33 ->
# 126 "lexer.mll"
        ( EOF )
# 411 "lexer.ml"

  | 34 ->
let
# 129 "lexer.mll"
               c
# 417 "lexer.ml"
= Lexing.sub_lexeme_char lexbuf lexbuf.Lexing.lex_start_pos in
# 129 "lexer.mll"
                 (
    let loc = make_location lexbuf in
    (* Print the location tree to stdout *)
    PrintBox_text.output stdout (Location.location_to_tree loc);
    (* Raise the exception with the message *)
    failwith ("Unexpected character '" ^ String.escaped (String.make 1 c) ^ "'");
)
# 427 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_tokenize_rec lexbuf __ocaml_lex_state

and comment depth lexbuf =
   __ocaml_lex_comment_rec depth lexbuf 43
and __ocaml_lex_comment_rec depth lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 139 "lexer.mll"
         ( comment (depth + 1) lexbuf )
# 439 "lexer.ml"

  | 1 ->
# 142 "lexer.mll"
         ( 
      if depth = 1 then 
        tokenize lexbuf  (* Exit the comment mode *)
      else 
        comment (depth - 1) lexbuf  (* Handle nested comment *)
    )
# 449 "lexer.ml"

  | 2 ->
# 150 "lexer.mll"
            ( 
      Lexing.new_line lexbuf; 
      comment depth lexbuf 
    )
# 457 "lexer.ml"

  | 3 ->
# 156 "lexer.mll"
            ( 
      comment depth lexbuf 
    )
# 464 "lexer.ml"

  | 4 ->
# 161 "lexer.mll"
        ( 
    let loc = make_location lexbuf in
    (* Print the location tree to stdout *)
    PrintBox_text.output stdout (Location.location_to_tree loc);
    (* Raise the exception with the message *)
    failwith "Unterminated comment";
)
# 475 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_comment_rec depth lexbuf __ocaml_lex_state

;;
