open Overdraft_render
open Overdraft_render.Types

let sample = {|
* Alice

#+NAME: principal
|       Date | Amount    | Rate | Comments |
|------------+-----------+------+----------|
| 2025-03-04 | 35,00,000 |   10 |          |
| 2025-06-04 | 35,00,000 |   10 |          |
| 2025-09-04 | 32,50,000 |   12 |          |
| 2026-01-05 | 5,00,000  |   12 |          |

#+NAME: interest
|       Date | Amount   | Comments |
|------------+----------+----------|
| 2025-03-05 | 29,166   |          |
| 2025-04-05 | 29,166   |          |
| 2025-05-05 | 29,166   |          |
| 2025-06-05 | 58,333   |          |
| 2025-07-05 | 18,333   |          |
| 2025-12-05 | 5,77,513 |          |
| 2026-01-05 | 95,833   |          |

* Bob

#+NAME: principal
|       Date | Amount   | Rate | Comments |
|------------+----------+------+----------|
| 2026-03-02 | 5,00,000 |   10 |          |
| 2026-03-04 | -10,000  |   10 |          |

#+NAME: interest
|       Date | Amount | Comments |
|------------+--------+----------|
| 2026-03-04 | 1,500  |          |
|}

let expected =
  [("Alice",
    { unique_rates = [10; 12];
      principal_payments =
        [{ rate = 10; principal = 3500000;
           date = { year = 2025; month = 3 } };
         { rate = 10; principal = 3500000;
           date = { year = 2025; month = 6 } };
         { rate = 12; principal = 3250000;
           date = { year = 2025; month = 9 } };
         { rate = 12; principal = 500000;
           date = { year = 2026; month = 1 } }
        ];
      interest_payments =
        [{ amount = 29166; date = { year = 2025; month = 3 } };
         { amount = 29166; date = { year = 2025; month = 4 } };
         { amount = 29166; date = { year = 2025; month = 5 } };
         { amount = 58333; date = { year = 2025; month = 6 } };
         { amount = 18333; date = { year = 2025; month = 7 } };
         { amount = 577513; date = { year = 2025; month = 12 } };
         { amount = 95833; date = { year = 2026; month = 1 } }]
   });
   ("Bob",
    { unique_rates = [10];
      principal_payments =
        [{ rate = 10; principal = 500000;
           date = { year = 2026; month = 3 } };
         { rate = 10; principal = -10000;
           date = { year = 2026; month = 3 } }
        ];
      interest_payments =
        [{ amount = 1500; date = { year = 2026; month = 3 } }] })
  ]

let () =
  let db = Parser.parse_string sample in
  let actual = StringMap.bindings db in
  if actual = expected then
    Render.render_database db
  else
    begin
      Printf.printf "Failure!\n\nExpectedD:\n%s\n\nActual:\n%s\n"
        (show_database_as_list expected)
        (show_database_as_list actual);
      exit 1
    end
