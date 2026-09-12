USE SchoolDatabase;
GO
-- Students by Department
CREATE OR ALTER VIEW vw_StudentsByDepartment
AS
SELECT
    s.StudentId,
   s.FullName AS StudentName,
    s.Email,
    d.DepartmentId,
    d.DepartmentName
FROM Student AS s
INNER JOIN Department AS d
    ON s.DepartmentId = d.DepartmentId;
GO
--  Course Details
CREATE OR ALTER VIEW vw_CourseDetails
AS
SELECT
    c.CourseId,
    c.CourseCode,
    c.CourseName,
    d.DepartmentName,
    t.TeacherId,
    t.FirstName + ' ' + t.LastName AS TeacherName,
    t.Email AS TeacherEmail
FROM Course AS c
INNER JOIN Department AS d
    ON c.DepartmentId = d.DepartmentId
INNER JOIN Teacher AS t
    ON c.TeacherId = t.TeacherId;
GO
-- Student Enrollments
CREATE OR ALTER VIEW vw_StudentEnrollments
AS
SELECT
    s.StudentId,
    s.FullName AS StudentName,
    d.DepartmentName,
    c.CourseCode,
    c.CourseName,
    e.EnrollmentDate,
    e.Grade,
    e.IsPassed
FROM Enrollment AS e
INNER JOIN Student AS s
    ON e.StudentId = s.StudentId
INNER JOIN Department AS d
    ON s.DepartmentId = d.DepartmentId
INNER JOIN Course AS c
    ON e.CourseId = c.CourseId;
GO
-- Teacher Hierarchy
CREATE OR ALTER VIEW dbo.vw_TeacherHierarchy
AS
SELECT
    t.TeacherId,
    t.FullName AS TeacherName,
    d.DepartmentName,
    t.SupervisorId,
    COALESCE(
        sup.FirstName + N' ' + sup.LastName,
        N'No Supervisor'
    ) AS SupervisorName,
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
-- Test All Views
SELECT *
FROM vw_StudentsByDepartment;
GO

SELECT *
FROM vw_CourseDetails;
GO

SELECT *
FROM vw_StudentEnrollments;
GO

SELECT *
FROM vw_TeacherHierarchy;
GO

