open Overdraft
open Overdraft.Types

let sample = {|
* Alice

#+NAME: principal
|       Date | Amount    | Rate | Comments |
|------------+-----------+------+----------|
| 2026-03-04 | 35,00,000 |   10 |          |
| 2026-03-04 | 32,50,000 |   12 |          |
| 2026-03-05 | 5,00,000  |   12 |          |

#+NAME: interest
|       Date | Amount | Comments |
|------------+--------+----------|
| 2026-03-05 | 7,500  |          |

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
    {
      unique_rates = [ 10; 12 ];
      principal_payments =
        [{ rate = 10; principal = 3500000;
           date = { year = 2026; month = 3 } };
         { rate = 12; principal = 3250000;
           date = { year = 2026; month = 3 } };
         { rate = 12; principal = 500000;
           date = { year = 2026; month = 3 } }
        ];
      interest_payments =
        [{ amount = 7500; date = { year = 2026; month = 3 } }]
    }
   );
   ("Bob",
    {
      unique_rates = [ 10 ];
      principal_payments =
        [{ rate = 10; principal = 500000;
           date = { year = 2026; month = 3 } };
         { rate = 10; principal = -10000;
           date = { year = 2026; month = 3 } }
        ];
      interest_payments =
        [{ amount = 1500; date = { year = 2026; month = 3 } }]
    }
   )
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
