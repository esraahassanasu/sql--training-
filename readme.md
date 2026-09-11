# School Database Management System

A SQL Server database project designed for managing the academic structure of a mid-sized school. The system replaces paper-based records with a relational database that manages departments, teachers, students, courses, and student enrollments.

The project demonstrates core SQL Server concepts including database design, relationships, constraints, joins, views, stored procedures, user-defined functions, indexes, transactions, and execution plan analysis.

---

## Project Objectives

The main objectives of the project are to:

* Design a normalized relational database for a school.
* Manage Departments, Teachers, Students, Courses, and Enrollments.
* Represent Teacher–Supervisor relationships using a self-referencing foreign key.
* Represent the many-to-many relationship between Students and Courses.
* Enforce important business rules using Primary Keys, Foreign Keys, Unique Constraints, and Check Constraints.
* Implement reusable Views, Stored Procedures, and Functions.
* Demonstrate Transactions and Rollback.
* Improve query performance using appropriate indexes.
* Analyze index usage and SQL Server Execution Plans.

---

## Database Structure

The database is named:

```text
SchoolDatabase
```

### Main Entities

The database contains five main entities:

```text
Department
    |
    |--- Teacher
    |       |
    |       └── Supervisor (Teacher)
    |
    |--- Student
    |
    └--- Course
             |
             └── Teacher

Student
    |
    └── Enrollment ─── Course
```

### Tables

| Table      | Description                                                                  |
| ---------- | ---------------------------------------------------------------------------- |
| Department | Stores school departments.                                                   |
| Teacher    | Stores teachers and their department/supervisor relationships.               |
| Student    | Stores students and their departments.                                       |
| Course     | Stores courses, their departments, and assigned teachers.                    |
| Enrollment | Connects students with courses and stores enrollment information and grades. |

---

## Relationships

### Department → Teacher

One Department can have multiple Teachers.

Each Teacher belongs to exactly one Department.

```text
Department 1 ──────── * Teacher
```

---

### Department → Student

One Department can contain multiple Students.

Each Student belongs to exactly one Department.

```text
Department 1 ──────── * Student
```

---

### Department → Course

One Department can offer multiple Courses.

Each Course belongs to exactly one Department.

```text
Department 1 ──────── * Course
```

---

### Teacher → Course

A Teacher can teach multiple Courses.

Each Course is taught by exactly one Teacher.

```text
Teacher 1 ──────── * Course
```

---

### Teacher → Teacher (Supervisor Relationship)

The Teacher table contains a self-referencing relationship.

A Teacher can have another Teacher as a Supervisor.

`SupervisorId` is nullable because a Teacher may have no Supervisor, for example a department lead.

```text
Teacher
   |
   └── SupervisorId → TeacherId
```

Example:

```text
Ahmed Hassan
├── Khaled Mostafa
└── Nour Samir
```

---

### Student ↔ Course

Students can enroll in multiple Courses, and each Course can contain multiple Students.

This is a many-to-many relationship.

The relationship is implemented using the `Enrollment` table.

```text
Student 1 ──── * Enrollment * ──── 1 Course
```

---

## Why is Enrollment Required?

A direct many-to-many relationship between `Student` and `Course` cannot be represented efficiently using only the two tables.

The `Enrollment` table acts as an associative entity and stores the relationship between a Student and a Course.

It also stores attributes that belong to the relationship itself:

* `EnrollmentDate`
* `Grade`

The primary key is:

```sql
PRIMARY KEY (StudentId, CourseId)
```

This prevents the same student from being enrolled in the same course more than once.

---

# Database Constraints

The database uses several constraints to maintain data integrity.

## Primary Keys

Each main table has a Primary Key:

```text
Department.DepartmentId
Teacher.TeacherId
Student.StudentId
Course.CourseId
```

`Enrollment` uses a composite Primary Key:

```text
(StudentId, CourseId)
```

---

## Foreign Keys

Foreign Keys maintain relationships between tables.

Examples:

```text
Teacher.DepartmentId → Department.DepartmentId

Student.DepartmentId → Department.DepartmentId

Course.DepartmentId → Department.DepartmentId

Course.TeacherId → Teacher.TeacherId

Enrollment.StudentId → Student.StudentId

Enrollment.CourseId → Course.CourseId

Teacher.SupervisorId → Teacher.TeacherId
```

---

## Unique Constraints

Unique constraints are used for values that must not be duplicated.

Examples:

```text
DepartmentName
Teacher.Email
Student.Email
CourseCode
```

---

## Grade Validation

Grades are restricted to values between 0 and 100.

A grade can also be `NULL` because a student may be enrolled in a course before taking the exam.

```sql
CHECK
(
    Grade IS NULL
    OR
    (Grade >= 0 AND Grade <= 100)
)
```

---

## ON DELETE Behavior

The project uses:

```sql
ON DELETE NO ACTION
```

for the foreign key relationships.

This prevents accidental cascading deletion of related academic records.

For example, deleting a Department should not automatically delete all its Students, Teachers, or Courses.

---

# Computed Columns

The project includes two computed columns as additional functionality.

### Student Full Name

```text
FullName
```

It is generated from:

```text
FirstName + LastName
```

### Enrollment Result

```text
IsPassed
```

The value is calculated from the Grade:

```text
NULL → NULL
Grade >= 50 → 1
Grade < 50 → 0
```

The `NULL` behavior preserves the distinction between a course that has not been graded yet and a failed course.

---

# SQL Queries

## JOIN Queries

The project includes five JOIN queries demonstrating:

1. Students with their Departments.
2. Courses with their Departments and Teachers.
3. Students with their Courses, Enrollment Dates, and Grades.
4. Teachers with their Supervisors.
5. Students with their Departments, Courses, Teachers, Enrollment Dates, and Grades.

Different JOIN types are used according to the relationship requirements.

For example, a `LEFT JOIN` is used for the Supervisor relationship because `SupervisorId` can be `NULL`.

---

# Views

Four database Views are implemented.

### `vw_StudentsByDepartment`

Displays students together with their department information.

### `vw_CourseDetails`

Displays course information with the corresponding Department and Teacher.

### `vw_StudentEnrollments`

Displays student enrollment details including:

* Student
* Department
* Course
* Enrollment Date
* Grade
* Pass status

### `vw_TeacherHierarchy`

Displays teachers together with their supervisors and departments.

---

# Stored Procedures

## `sp_GetStudentsByDepartment`

Returns all students belonging to a specified Department.

It validates that the requested Department exists before executing the query.

Example:

```sql
EXEC dbo.sp_GetStudentsByDepartment
    @DepartmentId = 1;
```

---

## `sp_EnrollStudent`

Enrolls a Student in a Course after validating:

* Student existence.
* Course existence.
* Student and Course Department compatibility.
* Duplicate enrollment.

If no enrollment date is provided, the current date is used.

Example:

```sql
EXEC dbo.sp_EnrollStudent
    @StudentId = 1,
    @CourseId = 1;
```

---

## `sp_TransferStudent`

Transfers a Student to another Department.

The operation uses a SQL Server Transaction to ensure that the update is completed safely.

The procedure uses:

```sql
BEGIN TRANSACTION
```

and either:

```sql
COMMIT TRANSACTION
```

or:

```sql
ROLLBACK TRANSACTION
```

when an error or validation failure occurs.

Example:

```sql
EXEC dbo.sp_TransferStudent
    @StudentId = 14,
    @NewDepartmentId = 1;
```

---

## Additional Stored Procedures

The project also contains additional procedures for:

* Retrieving a student's enrollment details.
* Retrieving teachers by Department.

These provide reusable database operations beyond the minimum required procedures.

---

# User-Defined Functions

Four scalar functions are implemented.

## `fn_IsPassed`

Determines the student's result based on the grade.

```text
Grade >= 50 → Passed
Grade < 50  → Failed
Grade NULL  → Pending
```

Example:

```sql
SELECT dbo.fn_IsPassed(75);
```

Result:

```text
Passed
```

---

## `fn_GetStudentFullName`

Returns the full name of a student using the Student ID.

Example:

```sql
SELECT dbo.fn_GetStudentFullName(1);
```

---

## `fn_GetStudentAverageGrade`

Returns the average grade for a student.

`NULL` grades are ignored.

If the student has no graded courses, the result is `NULL`.

Example:

```sql
SELECT dbo.fn_GetStudentAverageGrade(1);
```

---

## `fn_GetStudentEnrollmentCount`

Returns the number of courses in which a student is enrolled.

Example:

```sql
SELECT dbo.fn_GetStudentEnrollmentCount(1);
```

---

# Indexing and Performance

The project includes indexes designed to support common filtering and JOIN operations.

Implemented indexes include:

```text
IX_Student_DepartmentId
IX_Teacher_DepartmentId
IX_Course_DepartmentId
IX_Course_TeacherId
IX_Enrollment_CourseId
```

## Composite Primary Key

The `Enrollment` table uses:

```text
(StudentId, CourseId)
```

as its composite Primary Key.

This creates an index whose leading column is `StudentId`.

Therefore, it efficiently supports queries such as:

```sql
WHERE StudentId = 1
```

and:

```sql
WHERE StudentId = 1
AND CourseId = 1
```

However, it is not equivalent to an index beginning with `CourseId`.

For queries such as:

```sql
WHERE CourseId = 1
```

a separate index on `CourseId` is useful:

```text
IX_Enrollment_CourseId
```

### Why Column Order Matters

These two indexes are different:

```text
(StudentId, CourseId)
```

and:

```text
(CourseId, StudentId)
```

The first column is the leading column of a composite index and strongly affects which queries can use the index efficiently.

---

## Low Selectivity

Columns such as `DepartmentId` can have relatively low selectivity because many students, teachers, or courses may belong to the same department.

Therefore, having an index does not guarantee that SQL Server will choose an Index Seek.

The SQL Server Query Optimizer may choose an Index Scan or Table Scan when it estimates that scanning is cheaper.

The actual choice depends on factors such as:

* Table size.
* Number of matching rows.
* Statistics.
* Query cost.
* Available indexes.

---

# Execution Plan Analysis

SQL Server execution plans are used to analyze query performance.

The project tests queries involving:

```text
Enrollment by StudentId
Enrollment by StudentId + CourseId
Enrollment by CourseId
Student by DepartmentId
```

Performance can be evaluated using:

* Index Seek vs. Index Scan.
* Actual Number of Rows.
* Estimated Number of Rows.
* Logical Reads.
* CPU Time.
* Elapsed Time.

In SQL Server Management Studio, the Actual Execution Plan can be enabled using:

```text
Ctrl + M
```

The execution plan should be evaluated based on the actual SQL Server output rather than assuming that an index will always produce a faster query.

---

# Project Files

The project follows the required structure:

```text
SchoolDatabase/
│
├──erd.png
│
├── SQL Scripts/
│   ├── 01_schema.sql
│   ├── 02_seed.sql
│   ├── 03_joins.sql
│   ├── 04_views.sql
│   ├── 05_procedures.sql
│   └── 06_functions.sql
│
└── readme.md
```

### File Description

| File                | Purpose                                                                   |
| ------------------- | ------------------------------------------------------------------------- |
| `01_schema.sql`     | Creates the database, tables, constraints, computed columns, and indexes. |
| `02_seed.sql`       | Inserts realistic sample data.                                            |
| `03_joins.sql`      | Contains the required JOIN queries.                                       |
| `04_views.sql`      | Creates and tests the four required Views.                                |
| `05_procedures.sql` | Creates and tests Stored Procedures.                                      |
| `06_functions.sql`  | Creates and tests Functions and contains performance analysis queries.    |
| `erd.png`           | Entity Relationship Diagram of the database.                              |
| `README.md`         | Project documentation.                                                    |

---

# How to Run

## Prerequisites

* Microsoft SQL Server
* SQL Server Management Studio (SSMS)

## Steps

Run the scripts in the following order:

```text
1. 01_schema.sql
2. 02_seed.sql
3. 03_joins.sql
4. 04_views.sql
5. 05_procedures.sql
6. 06_functions.sql
```

### Important

For a clean test, start by running:

```text
01_schema.sql
```

This recreates the database objects.

Then run:

```text
02_seed.sql
```

to insert the sample data.

After that, execute the remaining scripts in order.

---

# Testing

The project includes test queries for:

* JOIN operations.
* Views.
* Stored Procedures.
* Valid and invalid Department IDs.
* Valid enrollment.
* Duplicate enrollment.
* Department mismatch during enrollment.
* Student transfer.
* Invalid student/department transfer.
* Passed grades.
* Failed grades.
* Pending grades.
* Student average grades.
* Student enrollment counts.

The `fn_IsPassed` function is specifically tested with boundary values:

```text
100 → Passed
75  → Passed
50  → Passed
49  → Failed
0   → Failed
NULL → Pending
```

---

# Key SQL Server Concepts Demonstrated

This project demonstrates practical understanding of:

* Relational Database Design
* ERD
* Primary Keys
* Composite Primary Keys
* Foreign Keys
* Self-Referencing Foreign Keys
* Unique Constraints
* Check Constraints
* Nullable Columns
* Many-to-Many Relationships
* JOINs
* Views
* Stored Procedures
* Scalar Functions
* Transactions
* COMMIT
* ROLLBACK
* TRY/CATCH
* Error Handling
* Computed Columns
* Nonclustered Indexes
* Composite Indexes
* Index Column Order
* Low Selectivity
* Execution Plans
* Query Performance Analysis

---

# Conclusion

The School Database Management System provides a relational solution for managing the main academic records of a mid-sized school.

The project focuses on maintaining data integrity, representing real-world relationships correctly, providing reusable database operations, and applying SQL Server performance concepts such as indexing and execution plan analysis.
