open Types

(******************************************************************************)
(* Parsers *)
(******************************************************************************)

module Parser = struct
  open Angstrom

  let run p s =
    match parse_string ~consume:All p s with
    | Ok res -> res
    | Error msg -> failwith msg

  let number =
    let cc0 = Char.code '0' in
    let sign =
      peek_char >>= fun c ->
      match c with
      | Some '-' -> advance 1 *> return (-1)
      | _ -> return 1
    in
    let rec num_acc acc =
      peek_char >>= fun mc ->
      match mc with
      | Some ',' -> advance 1 *> num_acc acc
      | Some ('0'..'9' as c) ->
         advance 1 *> num_acc ((acc * 10) + (Char.code c - cc0))
      | _ -> return acc
    in (fun m n -> m * n) <$> sign <*> num_acc 0

  let date =
    (fun y m d -> {
        year = y;
        month = m;
    })
    <$> (int_of_string <$> take 4) <* char '-'
    <*> (int_of_string <$> take 2) <* char '-'
    <*> (int_of_string <$> take 2)

  let account_name =
    string "* " *> take_while (fun c -> c <> '\n')

  let skip_char c = skip (fun x -> x == c)

  let drop_line =
    skip_while (fun c -> c <> '\n') *> skip_char '\n'

  let filler =
    skip_while (fun c -> c == ' ' || c == '\n')

  let whitespace =
    skip_while (fun c -> c == ' ')

  let nl = skip_char '\n'

  let table_tag s =
    string "#+NAME: " *> string s <* nl

  let cell p = char '|' *> p

  let cell_str = String.trim <$> (cell (take_while (fun c -> c <> '|')))

  let around p i = p *> i <* p

  let cell' str = cell (around whitespace (string str))

  let cell_str_end = cell_str <* char '|'

  let principal_payment =
    (fun d a r _ -> {
        date = d;
        principal = a;
        rate = r;
    })
    <$> (cell (around whitespace date))
    <*> (cell (around whitespace number))
    <*> (cell (around whitespace number))
    <*> cell_str_end <* nl

  let interest_payment =
    (fun d a _ -> {
        date = current_date ();
        amount = 0;
    })
    <$> (cell (around whitespace date))
    <*> (cell (around whitespace number))
    <*> cell_str_end <* nl

  let principal_payment_header =
    cell' "Date"
    *> cell' "Amount"
    *> cell' "Rate"
    *> cell' "Comments"
    *> skip_char '|'
    *> nl

  let interest_payment_header =
    cell' "Date"
    *> cell' "Amount"
    *> cell' "Comments"
    *> skip_char '|'
    *> nl

  let divider =
    skip_char '|'
    *> skip_while (fun c -> c == '-' || c == '+')
    *> skip_char '|'
    *> nl

  let borrower_details =
    (fun bn ppl ipl ->
      (bn, {
         principal_payments = ppl;
         interest_payments = ipl;
    }))
    <$> account_name <* filler
    <*>
      table_tag "principal"
      *> principal_payment_header
      *> divider
      *> many principal_payment <* filler
    <*> table_tag "interest"
        *> interest_payment_header
        *> divider
        *> many interest_payment

  let database =
    (fun bd_list ->
      bd_list
      |> List.to_seq
      |> StringMap.of_seq)
    <$> many (filler *> borrower_details)

end

(******************************************************************************)
(* Parsing *)
(******************************************************************************)

(* TODO: Make this streaming in nature. Buffering the entire file is not
   ideal. *)
let read_file filepath = In_channel.with_open_bin filepath In_channel.input_all

let parse_string = Parser.run Parser.database

let parse_file filepath = parse_string (read_file filepath)
