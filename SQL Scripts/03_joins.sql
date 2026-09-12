USE SchoolDatabase;
GO

-- Students with their Departments
SELECT
    s.StudentId,
    s.FullName AS StudentName,
    s.Email,
    d.DepartmentName
FROM Student s
INNER JOIN Department d
    ON s.DepartmentId = d.DepartmentId
ORDER BY d.DepartmentName, s.LastName;
GO
-- Courses with their Department and Teacher
SELECT
    c.CourseId,
    c.CourseCode,
    c.CourseName,
    d.DepartmentName,
    t.FirstName + ' ' + t.LastName AS TeacherName
FROM Course c
INNER JOIN Department d
    ON c.DepartmentId = d.DepartmentId
INNER JOIN Teacher t
    ON c.TeacherId = t.TeacherId
ORDER BY d.DepartmentName, c.CourseCode;
GO
-- students with their Courses, Enrollment Dates, and Grades
SELECT
    s.StudentId,
    s.FirstName + ' ' + s.LastName AS StudentName,
    c.CourseCode,
    c.CourseName,
    e.EnrollmentDate,
    e.Grade
FROM Enrollment e
INNER JOIN Student s
    ON e.StudentId = s.StudentId
INNER JOIN Course c
    ON e.CourseId = c.CourseId
ORDER BY s.StudentId, e.EnrollmentDate;
GO
-- Teachers with their Supervisors
SELECT
    t.TeacherId,
    t.FirstName + ' ' + t.LastName AS TeacherName,
    d.DepartmentName,
    COALESCE(
        sup.FirstName + ' ' + sup.LastName,
        'No Supervisor'
    ) AS SupervisorName
FROM Teacher t
INNER JOIN Department d
    ON t.DepartmentId = d.DepartmentId
LEFT JOIN Teacher sup
    ON t.SupervisorId = sup.TeacherId
ORDER BY d.DepartmentName, t.LastName;
GO
-- Selecting Students with their Departments, Courses, Teachers, Enrollment Dates, and Grades
SELECT
    s.StudentId,
    s.FirstName + ' ' + s.LastName AS StudentName,
    d.DepartmentName,
    c.CourseCode,
    c.CourseName,
    t.FirstName + ' ' + t.LastName AS TeacherName,
    e.EnrollmentDate,
    e.Grade,
    e.IsPassed
FROM Student s
INNER JOIN Department d
    ON s.DepartmentId = d.DepartmentId
INNER JOIN Enrollment e
    ON s.StudentId = e.StudentId
INNER JOIN Course c
    ON e.CourseId = c.CourseId
INNER JOIN Teacher t
    ON c.TeacherId = t.TeacherId
ORDER BY s.StudentId, c.CourseCode;
GO