USE SchoolDatabase;
GO

SELECT
    s.StudentId,
    s.FullName AS StudentName,
    s.Email,
    d.DepartmentName
FROM dbo.Student AS s
INNER JOIN dbo.Department AS d
    ON s.DepartmentId = d.DepartmentId
ORDER BY
    d.DepartmentName,
    s.LastName;
GO

SELECT
    c.CourseId,
    c.CourseCode,
    c.CourseName,
    d.DepartmentName,
    t.FullName AS TeacherName
FROM dbo.Course AS c
INNER JOIN dbo.Department AS d
    ON c.DepartmentId = d.DepartmentId
INNER JOIN dbo.Teacher AS t
    ON c.TeacherId = t.TeacherId
ORDER BY
    d.DepartmentName,
    c.CourseCode;
GO

SELECT
    s.StudentId,
    s.FullName AS StudentName,
    c.CourseCode,
    c.CourseName,
    e.EnrollmentDate,
    e.Grade
FROM dbo.Enrollment AS e
INNER JOIN dbo.Student AS s
    ON e.StudentId = s.StudentId
INNER JOIN dbo.Course AS c
    ON e.CourseId = c.CourseId
ORDER BY
    s.StudentId,
    e.EnrollmentDate;
GO

SELECT
    t.TeacherId,
    t.FullName AS TeacherName,
    d.DepartmentName,
    COALESCE(sup.FullName, N'No Supervisor') AS SupervisorName
FROM dbo.Teacher AS t
INNER JOIN dbo.Department AS d
    ON t.DepartmentId = d.DepartmentId
LEFT JOIN dbo.Teacher AS sup
    ON t.SupervisorId = sup.TeacherId
ORDER BY
    d.DepartmentName,
    t.LastName;
GO

SELECT
    s.StudentId,
    s.FullName AS StudentName,
    d.DepartmentName,
    c.CourseCode,
    c.CourseName,
    t.FullName AS TeacherName,
    e.EnrollmentDate,
    e.Grade,
    CASE
        WHEN e.IsPassed IS NULL THEN N'Pending'
        WHEN e.IsPassed = 1 THEN N'Passed'
        ELSE N'Failed'
    END AS Result
FROM dbo.Student AS s
INNER JOIN dbo.Department AS d
    ON s.DepartmentId = d.DepartmentId
INNER JOIN dbo.Enrollment AS e
    ON s.StudentId = e.StudentId
INNER JOIN dbo.Course AS c
    ON e.CourseId = c.CourseId
INNER JOIN dbo.Teacher AS t
    ON c.TeacherId = t.TeacherId
ORDER BY
    d.DepartmentName,
    s.StudentId,
    c.CourseCode;
GO