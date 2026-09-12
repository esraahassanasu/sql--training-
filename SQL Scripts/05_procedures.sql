USE SchoolDatabase;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetStudentsByDepartment
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Department
            WHERE DepartmentId = @DepartmentId
        )
        BEGIN
            RAISERROR('Department does not exist.', 16, 1);
            RETURN;
        END;

        SELECT
            s.StudentId,
            s.FullName AS StudentName,
            s.Email,
            d.DepartmentName
        FROM dbo.Student AS s
        INNER JOIN dbo.Department AS d
            ON s.DepartmentId = d.DepartmentId
        WHERE s.DepartmentId = @DepartmentId
        ORDER BY
            s.LastName,
            s.FirstName;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_EnrollStudent
    @StudentId INT,
    @CourseId INT,
    @EnrollmentDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Student
            WHERE StudentId = @StudentId
        )
        BEGIN
            RAISERROR('Student does not exist.', 16, 1);
            RETURN;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Course
            WHERE CourseId = @CourseId
        )
        BEGIN
            RAISERROR('Course does not exist.', 16, 1);
            RETURN;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Student AS s
            INNER JOIN dbo.Course AS c
                ON s.DepartmentId = c.DepartmentId
            WHERE s.StudentId = @StudentId
              AND c.CourseId = @CourseId
        )
        BEGIN
            RAISERROR(
                'Student and Course must belong to the same Department.',
                16,
                1
            );
            RETURN;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.Enrollment
            WHERE StudentId = @StudentId
              AND CourseId = @CourseId
        )
        BEGIN
            RAISERROR(
                'Student is already enrolled in this Course.',
                16,
                1
            );
            RETURN;
        END;

        IF @EnrollmentDate IS NULL
        BEGIN
            SET @EnrollmentDate = CAST(GETDATE() AS DATE);
        END;

        INSERT INTO dbo.Enrollment
        (
            StudentId,
            CourseId,
            EnrollmentDate,
            Grade
        )
        VALUES
        (
            @StudentId,
            @CourseId,
            @EnrollmentDate,
            NULL
        );

        PRINT 'Student enrolled successfully.';

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_TransferStudent
    @StudentId INT,
    @NewDepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Student
            WHERE StudentId = @StudentId
        )
        BEGIN
            RAISERROR('Student does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Department
            WHERE DepartmentId = @NewDepartmentId
        )
        BEGIN
            RAISERROR('New Department does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.Student
            WHERE StudentId = @StudentId
              AND DepartmentId = @NewDepartmentId
        )
        BEGIN
            RAISERROR(
                'Student is already in this Department.',
                16,
                1
            );
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        UPDATE dbo.Student
        SET DepartmentId = @NewDepartmentId
        WHERE StudentId = @StudentId;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR(
                'Student transfer failed.',
                16,
                1
            );
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        COMMIT TRANSACTION;

        PRINT 'Student transferred successfully.';

    END TRY
    BEGIN CATCH

        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;

    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetStudentEnrollments
    @StudentId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Student
            WHERE StudentId = @StudentId
        )
        BEGIN
            RAISERROR('Student does not exist.', 16, 1);
            RETURN;
        END;

        SELECT
            s.StudentId,
            s.FullName AS StudentName,
            d.DepartmentName,
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
        FROM dbo.Student AS s
        INNER JOIN dbo.Department AS d
            ON s.DepartmentId = d.DepartmentId
        INNER JOIN dbo.Enrollment AS e
            ON s.StudentId = e.StudentId
        INNER JOIN dbo.Course AS c
            ON e.CourseId = c.CourseId
        WHERE s.StudentId = @StudentId
        ORDER BY
            e.EnrollmentDate,
            c.CourseCode;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetTeachersByDepartment
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Department
            WHERE DepartmentId = @DepartmentId
        )
        BEGIN
            RAISERROR('Department does not exist.', 16, 1);
            RETURN;
        END;

        SELECT
            t.TeacherId,
            t.FullName AS TeacherName,
            t.Email,
            d.DepartmentName,
            COALESCE(
                sup.FullName,
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
            ON t.SupervisorId = sup.TeacherId
        WHERE t.DepartmentId = @DepartmentId
        ORDER BY
            t.LastName,
            t.FirstName;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

EXEC dbo.sp_GetStudentsByDepartment
    @DepartmentId = 1;
GO

EXEC dbo.sp_GetStudentsByDepartment
    @DepartmentId = 999;
GO

EXEC dbo.sp_EnrollStudent
    @StudentId = 4,
    @CourseId = 1,
    @EnrollmentDate = '2026-09-01';
GO

EXEC dbo.sp_EnrollStudent
    @StudentId = 4,
    @CourseId = 1;
GO

EXEC dbo.sp_EnrollStudent
    @StudentId = 4,
    @CourseId = 4;
GO

EXEC dbo.sp_TransferStudent
    @StudentId = 14,
    @NewDepartmentId = 1;
GO

SELECT
    StudentId,
    FirstName,
    LastName,
    DepartmentId
FROM dbo.Student
WHERE StudentId = 14;
GO

EXEC dbo.sp_TransferStudent
    @StudentId = 999,
    @NewDepartmentId = 1;
GO

EXEC dbo.sp_TransferStudent
    @StudentId = 14,
    @NewDepartmentId = 999;
GO

EXEC dbo.sp_GetStudentEnrollments
    @StudentId = 1;
GO

EXEC dbo.sp_GetStudentEnrollments
    @StudentId = 999;
GO

EXEC dbo.sp_GetTeachersByDepartment
    @DepartmentId = 1;
GO

EXEC dbo.sp_GetTeachersByDepartment
    @DepartmentId = 999;
GO