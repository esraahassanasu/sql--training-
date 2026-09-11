-- Create Database

IF DB_ID('SchoolDatabase') IS NULL
BEGIN
    CREATE DATABASE SchoolDatabase;
END
GO

USE SchoolDatabase;
GO

-- Clean Existing Tables

IF OBJECT_ID('dbo.EnrollmentAudit', 'U') IS NOT NULL
    DROP TABLE dbo.EnrollmentAudit;
GO

IF OBJECT_ID('dbo.Enrollment', 'U') IS NOT NULL
    DROP TABLE dbo.Enrollment;
GO

IF OBJECT_ID('dbo.Course', 'U') IS NOT NULL
    DROP TABLE dbo.Course;
GO

IF OBJECT_ID('dbo.Student', 'U') IS NOT NULL
    DROP TABLE dbo.Student;
GO

IF OBJECT_ID('dbo.Teacher', 'U') IS NOT NULL
    DROP TABLE dbo.Teacher;
GO

IF OBJECT_ID('dbo.Department', 'U') IS NOT NULL
    DROP TABLE dbo.Department;
GO

-- Department Table

CREATE TABLE dbo.Department
(
    DepartmentId INT IDENTITY(1,1) NOT NULL,
    DepartmentName NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_Department
        PRIMARY KEY (DepartmentId),

    CONSTRAINT UQ_Department_DepartmentName
        UNIQUE (DepartmentName)
);
GO

--Teacher Table

CREATE TABLE dbo.Teacher
(
    TeacherId INT IDENTITY(1,1) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(150) NOT NULL,
    DepartmentId INT NOT NULL,
    SupervisorId INT NULL,

    CONSTRAINT PK_Teacher
        PRIMARY KEY (TeacherId),

    CONSTRAINT UQ_Teacher_Email
        UNIQUE (Email),

    CONSTRAINT FK_Teacher_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES dbo.Department(DepartmentId)
        ON DELETE NO ACTION,

    CONSTRAINT FK_Teacher_Supervisor
        FOREIGN KEY (SupervisorId)
        REFERENCES dbo.Teacher(TeacherId)
        ON DELETE NO ACTION
);
GO

-- Student Table

CREATE TABLE dbo.Student
(
    StudentId INT IDENTITY(1,1) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(150) NOT NULL,
    DepartmentId INT NOT NULL,

    CONSTRAINT PK_Student
        PRIMARY KEY (StudentId),

    CONSTRAINT UQ_Student_Email
        UNIQUE (Email),

    CONSTRAINT FK_Student_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES dbo.Department(DepartmentId)
        ON DELETE NO ACTION
);
GO

-- Course Table

CREATE TABLE dbo.Course
(
    CourseId INT IDENTITY(1,1) NOT NULL,
    CourseName NVARCHAR(100) NOT NULL,
    CourseCode NVARCHAR(20) NOT NULL,
    DepartmentId INT NOT NULL,
    TeacherId INT NOT NULL,

    CONSTRAINT PK_Course
        PRIMARY KEY (CourseId),

    CONSTRAINT UQ_Course_CourseCode
        UNIQUE (CourseCode),

    CONSTRAINT FK_Course_Department
        FOREIGN KEY (DepartmentId)
        REFERENCES dbo.Department(DepartmentId)
        ON DELETE NO ACTION,

    CONSTRAINT FK_Course_Teacher
        FOREIGN KEY (TeacherId)
        REFERENCES dbo.Teacher(TeacherId)
        ON DELETE NO ACTION
);
GO
-- Enrollment Table

CREATE TABLE dbo.Enrollment
(
    StudentId INT NOT NULL,
    CourseId INT NOT NULL,
    EnrollmentDate DATE NOT NULL,
    Grade DECIMAL(5,2) NULL,

    CONSTRAINT PK_Enrollment
        PRIMARY KEY (StudentId, CourseId),

    CONSTRAINT FK_Enrollment_Student
        FOREIGN KEY (StudentId)
        REFERENCES dbo.Student(StudentId)
        ON DELETE NO ACTION,

    CONSTRAINT FK_Enrollment_Course
        FOREIGN KEY (CourseId)
        REFERENCES dbo.Course(CourseId)
        ON DELETE NO ACTION,

    CONSTRAINT CK_Enrollment_Grade
        CHECK
        (
            Grade IS NULL
            OR
            (Grade >= 0 AND Grade <= 100)
        )
);
GO
-- Computed FullName

ALTER TABLE dbo.Student
ADD FullName AS
(
    FirstName + N' ' + LastName
);
GO
-- Computed IsPassed

ALTER TABLE dbo.Enrollment
ADD IsPassed AS
(
    CASE
        WHEN Grade IS NULL THEN NULL
        WHEN Grade >= 50 THEN 1
        ELSE 0
    END
);
GO

-- Create Indexes

CREATE NONCLUSTERED INDEX IX_Student_DepartmentId
ON dbo.Student(DepartmentId);
GO

CREATE NONCLUSTERED INDEX IX_Teacher_DepartmentId
ON dbo.Teacher(DepartmentId);
GO

CREATE NONCLUSTERED INDEX IX_Course_DepartmentId
ON dbo.Course(DepartmentId);
GO

CREATE NONCLUSTERED INDEX IX_Course_TeacherId
ON dbo.Course(TeacherId);
GO

CREATE NONCLUSTERED INDEX IX_Enrollment_CourseId
ON dbo.Enrollment(CourseId);
GO


-- Verify Tables

SELECT
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO
-- Verify Indexes
SELECT
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType
FROM sys.indexes AS i
INNER JOIN sys.tables AS t
    ON i.object_id = t.object_id
WHERE t.name IN
(
    'Department',
    'Teacher',
    'Student',
    'Course',
    'Enrollment'
)
AND i.name IS NOT NULL
ORDER BY
    t.name,
    i.index_id;
GO