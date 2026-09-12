USE SchoolDatabase;
GO

INSERT INTO dbo.Department
    (DepartmentName)
VALUES
    ('Computer Science'),
    ('Mathematics'),
    ('Physics'),
    ('Information Technology');
GO

INSERT INTO dbo.Teacher
    (FirstName, LastName, Email, DepartmentId, SupervisorId)
VALUES
    ('Ahmed', 'Hassan', 'ahmed.hassan@school.com', 1, NULL),
    ('Mona', 'Ali', 'mona.ali@school.com', 2, NULL),
    ('Omar', 'Ibrahim', 'omar.ibrahim@school.com', 3, NULL),
    ('Sara', 'Mahmoud', 'sara.mahmoud@school.com', 4, NULL),
    ('Khaled', 'Mostafa', 'khaled.mostafa@school.com', 1, 1),
    ('Nour', 'Samir', 'nour.samir@school.com', 1, 1),
    ('Youssef', 'Adel', 'youssef.adel@school.com', 2, 2),
    ('Hana', 'Tarek', 'hana.tarek@school.com', 2, 2),
    ('Karim', 'Wael', 'karim.wael@school.com', 3, 3),
    ('Menna', 'Ashraf', 'menna.ashraf@school.com', 4, 4);
GO

UPDATE dbo.Department
SET LeadTeacherId = 1
WHERE DepartmentId = 1;

UPDATE dbo.Department
SET LeadTeacherId = 2
WHERE DepartmentId = 2;

UPDATE dbo.Department
SET LeadTeacherId = 3
WHERE DepartmentId = 3;

UPDATE dbo.Department
SET LeadTeacherId = 4
WHERE DepartmentId = 4;
GO

INSERT INTO dbo.Course
    (CourseName, CourseCode, DepartmentId, TeacherId)
VALUES
    ('Database Systems', 'CS101', 1, 1),
    ('Object Oriented Programming', 'CS102', 1, 5),
    ('Data Structures', 'CS103', 1, 6),
    ('Calculus I', 'MATH101', 2, 2),
    ('Linear Algebra', 'MATH102', 2, 7),
    ('Statistics', 'MATH103', 2, 8),
    ('Classical Mechanics', 'PHY101', 3, 3),
    ('Electromagnetism', 'PHY102', 3, 9),
    ('Computer Networks', 'IT101', 4, 4),
    ('Web Technologies', 'IT102', 4, 10);
GO

INSERT INTO dbo.Student
    (FirstName, LastName, Email, DepartmentId)
VALUES
    ('Ali', 'Mohamed', 'ali.mohamed@student.com', 1),
    ('Yara', 'Ahmed', 'yara.ahmed@student.com', 1),
    ('Omar', 'Khaled', 'omar.khaled@student.com', 1),
    ('Salma', 'Hany', 'salma.hany@student.com', 1),
    ('Mai', 'Tamer', 'mai.tamer@student.com', 2),
    ('Adam', 'Sherif', 'adam.sherif@student.com', 2),
    ('Laila', 'Mostafa', 'laila.mostafa@student.com', 2),
    ('Hossam', 'Nabil', 'hossam.nabil@student.com', 2),
    ('Nada', 'Samy', 'nada.samy@student.com', 3),
    ('Ziad', 'Ayman', 'ziad.ayman@student.com', 3),
    ('Reem', 'Wael', 'reem.wael@student.com', 3),
    ('Mariam', 'Fathy', 'mariam.fathy@student.com', 4),
    ('Tarek', 'Amr', 'tarek.amr@student.com', 4),
    ('Jana', 'Essam', 'jana.essam@student.com', 4);
GO

INSERT INTO dbo.Enrollment
    (StudentId, CourseId, EnrollmentDate, Grade)
VALUES
    (1, 1, '2026-01-10', 88),
    (1, 2, '2026-01-11', 92),
    (1, 3, '2026-01-12', NULL),
    (2, 1, '2026-01-10', 75),
    (2, 3, '2026-01-12', 81),
    (3, 1, '2026-01-13', NULL),
    (3, 2, '2026-01-14', 67),
    (4, 2, '2026-01-15', 95),
    (4, 3, '2026-01-16', NULL),
    (5, 4, '2026-01-10', 90),
    (5, 5, '2026-01-11', 84),
    (6, 4, '2026-01-10', 72),
    (6, 6, '2026-01-12', NULL),
    (7, 5, '2026-01-13', 91),
    (7, 6, '2026-01-14', 78),
    (8, 4, '2026-01-15', NULL),
    (8, 5, '2026-01-16', 69),
    (9, 7, '2026-01-10', 87),
    (9, 8, '2026-01-11', NULL),
    (10, 7, '2026-01-12', 76),
    (10, 8, '2026-01-13', 82),
    (11, 7, '2026-01-14', NULL),
    (12, 9, '2026-01-10', 94),
    (12, 10, '2026-01-11', 89),
    (13, 9, '2026-01-12', 73),
    (13, 10, '2026-01-13', NULL),
    (14, 9, '2026-01-14', NULL),
    (14, 10, '2026-01-15', 45);
GO