# Flow Shop Scheduling in MATLAB

This project implements and compares two approaches for solving the **2-Machine Flow Shop Scheduling Problem**:

- **Johnson's Rule** (Optimal algorithm for two machines)
- **MILP (Mixed Integer Linear Programming)** using MATLAB Optimization Toolbox

The project is integrated with **SQL Server** to store job data and scheduling results, and generates a **Gantt Chart** for schedule visualization.

---

## Project Objectives

The main objectives of this project are:

- Read production jobs from a SQL Server database.
- Compute the optimal job sequence using Johnson's Rule.
- Solve the same scheduling problem using a MILP optimization model.
- Compare both approaches in terms of makespan and execution time.
- Store scheduling results back into the database.
- Visualize the schedule using a Gantt Chart.

---

## Technologies Used

- MATLAB R2025b
- Optimization Toolbox (`intlinprog`)
- SQL Server
- Database Toolbox
- Johnson's Rule
- Mixed Integer Linear Programming (MILP)

---

## Project Structure

| File | Description |
|------|-------------|
| `1_connect_and_seed.m` | Connects to SQL Server and inserts sample jobs into the database. |
| `2_run_johnson.m` | Reads jobs from SQL, runs Johnson's algorithm, saves the schedule, and generates the Gantt chart. |
| `3_run_milp_check.m` | Compares Johnson's Rule and MILP on the same scheduling instance. |
| `4_generate_instances.m` | Generates random test instances and compares execution time and makespan. |
| `5_save_milp_to_sql.m` | Solves the scheduling problem using MILP and stores the results in SQL Server. |
| `johnson2machine.m` | Implementation of Johnson's Rule. |
| `milp_flowshop2.m` | MILP optimization model for the two-machine flow shop problem. |
| `SQLQuery1.sql` | SQL script for database operations. |
| `SQLQuery2.sql` | Additional SQL queries used in the project. |

---

## Johnson's Rule

Johnson's Rule is an optimal scheduling algorithm for a two-machine flow shop.

The algorithm works as follows:

1. Find the smallest processing time among all unscheduled jobs.
2. If the smallest value belongs to Machine 1, place that job at the beginning of the sequence.
3. If it belongs to Machine 2, place that job at the end of the sequence.
4. Remove the selected job.
5. Repeat until all jobs are scheduled.

Johnson's Rule guarantees the minimum makespan for two-machine flow shop scheduling problems.

---

## MILP Model

The project also models the scheduling problem as a **Mixed Integer Linear Programming (MILP)** optimization problem.

Decision variables:

- Binary assignment variables (`x`)
- Completion times on Machine 1 (`C1`)
- Completion times on Machine 2 (`C2`)
- Overall makespan (`Cmax`)

Objective:

- Minimize the total makespan (`Cmax`).

The optimization model is solved using MATLAB's `intlinprog` solver.

---

## SQL Integration

The workflow is fully integrated with SQL Server.

The project:

- Reads job processing times from the `CutTube` table.
- Stores scheduling information in:
  - `ScheduleRun`
  - `ScheduleStep`

This allows scheduling results to be stored and analyzed directly in the database.

---

## Gantt Chart

After Johnson's algorithm computes the optimal sequence, a Gantt chart is generated showing:

- Welding machine schedule
- Oven machine schedule
- Start and finish time of each job
- Overall makespan

---

## Performance Comparison

Random scheduling instances are generated to compare:

- Johnson's Rule
- MILP

The comparison includes:

- Makespan
- Execution time

Results are exported to:

```
results/comparison_results.csv
```

---

## Sample Output

- Optimal job sequence
- Makespan
- SQL database records
- Gantt chart
- Performance comparison CSV

---

## Author

**Pardis Eshghinejad**

Master's Student in Computer Engineering (Artificial Intelligence)

University of Genoa, Italy
