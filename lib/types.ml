
(******************************************************************************)
(* Date *)
(******************************************************************************)

type date = {
  year : int;
  month : int;
} [@@deriving show, eq]

(* NOTE: Is there a way to define type signatures in the .ml file? *)
let next_date (x : date) : date =
  if x.month = 12 then
    { year = x.year + 1; month = 1 }
  else
    { year = x.year; month = x.month + 1 }

let current_date () : date =
  let tm = Unix.localtime (Unix.time ()) in {
    year = tm.tm_year + 1900;
    month = tm.tm_mon + 1;
  }

(******************************************************************************)
(* Database *)
(******************************************************************************)

module StringMap = Map.Make(String)

type principal_payment = {
  rate : int;
  principal : int;
  date: date;
} [@@deriving show, eq]

type interest_payment = {
  amount : int;
  date: date;
} [@@deriving show, eq]

type borrower = string [@@deriving show, eq]

type borrower_details = {
  principal_payments : principal_payment list;
  interest_payments : interest_payment list;
} [@@deriving show, eq]

type database = borrower_details StringMap.t

type database_as_list = (borrower * borrower_details) list [@@deriving show, eq]
