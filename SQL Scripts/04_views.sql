USE SchoolDatabase;
GO

CREATE OR ALTER VIEW dbo.vw_StudentsByDepartment
AS
SELECT
    s.StudentId,
    s.FullName AS StudentName,
    s.Email,
    d.DepartmentId,
    d.DepartmentName
FROM dbo.Student AS s
INNER JOIN dbo.Department AS d
    ON s.DepartmentId = d.DepartmentId;
GO

CREATE OR ALTER VIEW dbo.vw_CourseDetails
AS
SELECT
    c.CourseId,
    c.CourseCode,
    c.CourseName,
    d.DepartmentId,
    d.DepartmentName,
    t.TeacherId,
    t.FullName AS TeacherName
FROM dbo.Course AS c
INNER JOIN dbo.Department AS d
    ON c.DepartmentId = d.DepartmentId
INNER JOIN dbo.Teacher AS t
    ON c.TeacherId = t.TeacherId;
GO

CREATE OR ALTER VIEW dbo.vw_StudentEnrollments
AS
SELECT
    s.StudentId,
    s.FullName AS StudentName,
    c.CourseId,
    c.CourseCode,
    c.CourseName,
    e.EnrollmentDate,
    e.Grade,
    CASE
        WHEN e.IsPassed IS NULL THEN N'Pending'
        WHEN e.IsPassed = 1 THEN N'Passed'
        ELSE N'Failed'
    END AS Result
FROM dbo.Enrollment AS e
INNER JOIN dbo.Student AS s
    ON e.StudentId = s.StudentId
INNER JOIN dbo.Course AS c
    ON e.CourseId = c.CourseId;
GO

CREATE OR ALTER VIEW dbo.vw_TeacherHierarchy
AS
SELECT
    t.TeacherId,
    t.FullName AS TeacherName,
    d.DepartmentName,
    COALESCE(sup.FullName, N'No Supervisor') AS SupervisorName,
    CASE
        WHEN d.LeadTeacherId = t.TeacherId THEN 1
        ELSE 0
    END AS IsLeadTeacher
FROM dbo.Teacher AS t
INNER JOIN dbo.Department AS d
    ON t.DepartmentId = d.DepartmentId
LEFT JOIN dbo.Teacher AS sup
    ON t.SupervisorId = sup.TeacherId;
GO

SELECT *
FROM dbo.vw_StudentsByDepartment;
GO

SELECT *
FROM dbo.vw_CourseDetails;
GO

SELECT *
FROM dbo.vw_StudentEnrollments;
GO

SELECT *
FROM dbo.vw_TeacherHierarchy;
GO