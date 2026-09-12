USE SchoolDatabase;
GO

CREATE OR ALTER FUNCTION dbo.fn_IsPassed
(
    @Grade DECIMAL(5,2)
)
RETURNS VARCHAR(10)
AS
BEGIN

    DECLARE @Result VARCHAR(10);

    IF @Grade IS NULL
    BEGIN
        SET @Result = 'Pending';
    END
    ELSE IF @Grade >= 50
    BEGIN
        SET @Result = 'Passed';
    END
    ELSE
    BEGIN
        SET @Result = 'Failed';
    END;

    RETURN @Result;

END;
GO

CREATE OR ALTER FUNCTION dbo.fn_GetStudentFullName
(
    @StudentId INT
)
RETURNS NVARCHAR(101)
AS
BEGIN

    DECLARE @FullName NVARCHAR(101);

    SELECT
        @FullName = FirstName + N' ' + LastName
    FROM dbo.Student
    WHERE StudentId = @StudentId;

    RETURN @FullName;

END;
GO

CREATE OR ALTER FUNCTION dbo.fn_GetStudentAverageGrade
(
    @StudentId INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN

    DECLARE @AverageGrade DECIMAL(5,2);

    SELECT
        @AverageGrade = CAST(AVG(Grade) AS DECIMAL(5,2))
    FROM dbo.Enrollment
    WHERE StudentId = @StudentId
      AND Grade IS NOT NULL;

    RETURN @AverageGrade;

END;
GO

CREATE OR ALTER FUNCTION dbo.fn_GetStudentEnrollmentCount
(
    @StudentId INT
)
RETURNS INT
AS
BEGIN

    DECLARE @EnrollmentCount INT;

    SELECT
        @EnrollmentCount = COUNT(*)
    FROM dbo.Enrollment
    WHERE StudentId = @StudentId;

    RETURN @EnrollmentCount;

END;
GO

SELECT
    dbo.fn_IsPassed(100) AS Grade_100,
    dbo.fn_IsPassed(75) AS Grade_75,
    dbo.fn_IsPassed(50) AS Grade_50,
    dbo.fn_IsPassed(49) AS Grade_49,
    dbo.fn_IsPassed(0) AS Grade_0,
    dbo.fn_IsPassed(NULL) AS Grade_NULL;
GO

SELECT
    StudentId,
    CourseId,
    Grade,
    dbo.fn_IsPassed(Grade) AS Result
FROM dbo.Enrollment
ORDER BY
    StudentId,
    CourseId;
GO

SELECT
    s.StudentId,
    dbo.fn_GetStudentFullName(s.StudentId) AS StudentFullName,
    dbo.fn_GetStudentEnrollmentCount(s.StudentId) AS EnrollmentCount,
    dbo.fn_GetStudentAverageGrade(s.StudentId) AS AverageGrade
FROM dbo.Student AS s
ORDER BY
    s.StudentId;
GO

SELECT
    dbo.fn_GetStudentFullName(999) AS FullName,
    dbo.fn_GetStudentAverageGrade(999) AS AverageGrade,
    dbo.fn_GetStudentEnrollmentCount(999) AS EnrollmentCount;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    StudentId,
    CourseId,
    EnrollmentDate,
    Grade
FROM dbo.Enrollment
WHERE StudentId = 1;
GO

SELECT
    StudentId,
    CourseId,
    EnrollmentDate,
    Grade
FROM dbo.Enrollment
WHERE StudentId = 1
  AND CourseId = 1;
GO

SELECT
    StudentId,
    CourseId,
    EnrollmentDate,
    Grade
FROM dbo.Enrollment
WHERE CourseId = 1;
GO

SELECT
    StudentId,
    FirstName,
    LastName,
    Email,
    DepartmentId
FROM dbo.Student
WHERE DepartmentId = 1;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO