# Overdraft Render

A simple overdraft projection system.

This is a command-line tool that parses a org file of specific format,
calculates overdraft projections based on principal and interest payments, and
then prints a formatted table to the console.

## Building and Running

To build the project, run:

```
dune build
```

To run the tool, you need to provide a file in the format that the tool
expects. You can then run the tool like this:

```
dune exec overdraft-render <path/to/your/file>.org
```

## Sample Input

```org
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
```
# Overdraft Render

A simple overdraft projection system.

This is a command-line tool that parses a org file of specific format,
calculates overdraft projections based on principal and interest payments, and
then prints a formatted table to the console.

## Building and Running

To build the project, run:

```
dune build
```

To run the tool, you need to provide a file in the format that the tool
expects. You can then run the tool like this:

```
dune exec overdraft-render <path/to/your/file>.org
```

## Sample Input

```org
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
```
