open Types
open PrintBox

module IntMap = Map.Make(Int)

(******************************************************************************)
(* Event streams *)
(******************************************************************************)

type event =
  | Principal of principal_payment
  | Interest of interest_payment
  | Tick of date [@@deriving show, eq]

let build_event_stream (details : borrower_details) : event Seq.t =
  let initial_date =
    match details.principal_payments, details.interest_payments with
    | [], [] -> None
    | p :: _, [] -> Some p.date
    | [], i :: _ -> Some i.date
    | p :: _, i :: _ -> Some (if p.date < i.date then p.date else i.date)
  in
  let rec loop running_date (ps : principal_payment list) (is : interest_payment list) () =
    if running_date > (current_date ()) then
      Seq.Nil
    else
      match ps, is with
      | p :: p_tl, _ when p.date = running_date ->
         Seq.Cons (Principal p, loop running_date p_tl is)
      | _, i :: i_tl when i.date = running_date ->
         Seq.Cons (Interest i, loop running_date ps i_tl)
      | _, _ ->
         Seq.Cons (Tick running_date, loop (next_date running_date) ps is)
  in
  match initial_date with
  | None -> Seq.empty
  | Some d -> loop d details.principal_payments details.interest_payments

type timeline_state = {
    principal_accured : int IntMap.t;
    interest_paid : int;
    interest_due : int;
}

type timeline_elem = {
    date : date;
    prin_map : int IntMap.t;
    int_map : int IntMap.t;
    int_paid : int;
    int_due : int;
}

let build_timeline_stream all_rates event_stream =
  let initial_state = {
      principal_accured = IntMap.empty;
      interest_paid = 0;
      interest_due = 0;
    } in
  let rec loop ev_step state () =
    match ev_step () with
    | Seq.Nil -> Seq.Nil
    | Seq.Cons (event, ev_step_next) ->
       match event with
       | Principal p ->
          let new_state = {
              state with
              principal_accured =
                IntMap.update p.rate (fun mres ->
                    match mres with
                    | Some res -> Some (res + p.principal)
                    | None -> Some p.principal
                  ) state.principal_accured
            } in
          loop ev_step_next new_state ()
       | Interest i ->
          let new_state = {
              state with
              interest_paid = state.interest_paid + i.amount
            } in
          loop ev_step_next new_state ()
       | Tick d ->
          let standard_int_due_map =
            IntMap.mapi (fun r p -> p * r / 100 / 12) state.principal_accured in
          let standard_int_due =
            IntMap.fold (fun _ amt acc -> acc + amt) standard_int_due_map 0 in
          let interest_offset =
            if state.interest_due > 0 then
              state.interest_due + (state.interest_due * 24) / 100 / 12
            else
              state.interest_due in
          let total_interest_due =
            standard_int_due + interest_offset - state.interest_paid in
          let new_state =
            { state with
              interest_due = total_interest_due;
              interest_paid = 0
            } in
          let loop_next = loop ev_step_next new_state in
          Seq.Cons ({
                date = d;
                prin_map = state.principal_accured;
                int_map = standard_int_due_map;
                int_due = total_interest_due;
                int_paid = state.interest_paid
              }, loop_next) in
  loop event_stream initial_state

(******************************************************************************)
(* Rendering *)
(******************************************************************************)

let format_indian n =
  let s = string_of_int (abs n) in
  let len = String.length s in
  let sign = if n < 0 then "-" else "" in
  if len <= 3 then
    sign ^ s
  else
    let last_three = String.sub s (len - 3) 3 in
    let remaining = String.sub s 0 (len - 3) in
    let rec add_commas_two str =
      let l = String.length str in
      if l <= 2 then str
      else
        let part = String.sub str (l - 2) 2 in
        let rest = String.sub str 0 (l - 2) in
        add_commas_two rest ^ "," ^ part
    in
    sign ^ add_commas_two remaining ^ "," ^ last_three

let make_table_row all_rates e =
  let box x = text x |> hpad 2 in
  let box_num x = format_indian x |> box in
  let date_cell = box (Printf.sprintf "%d-%02d" e.date.year e.date.month) in
  let prin_cells =
    List.map (fun r ->
        IntMap.find_opt r e.prin_map
        |> Option.value ~default:0 |> box_num
      ) all_rates in
  let total_prin =
    IntMap.fold (fun _ bal acc -> acc + bal) e.prin_map 0 |> box_num
  in
  let int_cells =
    List.map (fun r ->
        IntMap.find_opt r e.int_map
        |> Option.value ~default:0 |> box_num
      ) all_rates in
  let total_int_month =
    IntMap.fold (fun _ i acc -> acc + i) e.int_map 0 |> box_num
  in
  [date_cell]
  @ prin_cells
  @ [total_prin]
  @ int_cells
  @ [total_int_month]
  @ [box_num e.int_paid; box_num e.int_due]

let render_borrower_details details =
  let rows =
    build_event_stream details
    |> build_timeline_stream details.unique_rates
    |> Seq.map (make_table_row details.unique_rates)
    |> List.of_seq in

  let h_date = [text "Date"] in
  let h_prin =
    List.map (fun r -> text (Printf.sprintf "Bal @ %d%%" r)) details.unique_rates
    @ [text "Bal"] in
  let h_int =
    List.map (fun r -> text (Printf.sprintf "Int @ %d%%" r)) details.unique_rates
    @ [text "Int"] in
  let h_end = [text "Paid"; text "Due"] in

  let header = List.map (hpad 2) (h_date @ h_prin @ h_int @ h_end) in
  let table = grid_l (header :: rows) in

  PrintBox_text.output stdout table;
  print_newline ()

let render_database =
  StringMap.iter (fun borrower details ->
      Printf.printf "\n# %s\n\n" borrower;
      render_borrower_details details;
      print_endline ""
    )
