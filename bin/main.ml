open Overdraft_render

let filepath = ref ""

let usage_msg = "overdraft-render <path/to/your/file>.org"

let speclist = []

let () =
  Arg.parse speclist (fun s -> filepath := s) usage_msg;
  if !filepath = "" then (
    prerr_endline "Error: No input file provided.";
    Arg.usage speclist usage_msg;
    exit 1
  ) else (
    !filepath
    |> Parser.parse_file
    |> Render.render_database
  )
