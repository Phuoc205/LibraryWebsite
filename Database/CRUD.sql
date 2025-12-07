USE master;
GO

-- Kiem tra neu DB LibraryDB ton tai thi xoa va tao lai
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'LibraryDB')
BEGIN
    ALTER DATABASE [LibraryDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [LibraryDB];
END
GO

CREATE DATABASE LibraryDB;
GO
USE LibraryDB;
GO

-- =============================================
-- 1. TAO SCHEMA (CAC BANG)
-- =============================================

-- 1.1 CATALOGS
CREATE TABLE Branch (
    [Branch ID] VARCHAR(10) PRIMARY KEY,
    [Branch Name] NVARCHAR(100) NOT NULL,
    [Address] NVARCHAR(200)
);

CREATE TABLE Manufacture (
    ManufactureID VARCHAR(10) PRIMARY KEY,
    ManuName NVARCHAR(100),
    Contact NVARCHAR(100)
);

CREATE TABLE Author (
    SSN VARCHAR(10) PRIMARY KEY,      
    Biography NVARCHAR(MAX),         
    Fullname NVARCHAR(100)            
);

CREATE TABLE Category (
    Name NVARCHAR(100) PRIMARY KEY, 
    [Description] NVARCHAR(100)   
);

CREATE TABLE BibliographicRecord (
    RecordID VARCHAR(10) PRIMARY KEY,
    Title NVARCHAR(200),
    RefBookID VARCHAR(10),
    Publisher NVARCHAR(100),
    [Year] INT,
    FOREIGN KEY (RefBookID) REFERENCES BibliographicRecord(RecordID)
);

-- 1.2 USER & SUBTYPES
CREATE TABLE [User] (
    UserID CHAR(8) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    [Password] VARCHAR(50) NOT NULL,
    [First Name] NVARCHAR(50), 
    [Last Name] NVARCHAR(50),
    Email VARCHAR(50),
    SSN CHAR(8),
    Birthday DATE,
    [Address] NVARCHAR(50),
    UserType VARCHAR(50) NOT NULL,
    [Phone Number] VARCHAR(15),
    CONSTRAINT CHK_Email CHECK (Email LIKE '%_@__%.__%'),
    CONSTRAINT CHK_Password CHECK (LEN([Password]) BETWEEN 8 AND 16)
);

CREATE TABLE [Admin] (
    UserID CHAR(8) PRIMARY KEY,
    AdminCode VARCHAR(20),
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

CREATE TABLE Student (
    UserID CHAR(8) PRIMARY KEY,
    [Student ID] VARCHAR(20) NOT NULL,
    [Year] INT,
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

CREATE TABLE Librarian (
    UserID CHAR(8) PRIMARY KEY,
    [Branch ID] VARCHAR(10) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES [User](UserID),
    FOREIGN KEY ([Branch ID]) REFERENCES Branch([Branch ID])
);

-- 1.3 BOOKS, COPIES & M-N RELATIONS
CREATE TABLE [Book Copy] (
    BookID VARCHAR(10) PRIMARY KEY,
    RecordID VARCHAR(10) NOT NULL,
    [Entry Date] DATE,
    [Branch ID] VARCHAR(10),
    ManufactureID VARCHAR(10),
    [Status] NVARCHAR(20),
    FOREIGN KEY (RecordID) REFERENCES BibliographicRecord(RecordID),
    FOREIGN KEY ([Branch ID]) REFERENCES Branch([Branch ID]),
    FOREIGN KEY (ManufactureID) REFERENCES Manufacture(ManufactureID)
);

CREATE TABLE Keywords (
    RecordID VARCHAR(10) NOT NULL,
    Keyword NVARCHAR(50) NOT NULL,
    PRIMARY KEY (RecordID, Keyword),
    FOREIGN KEY (RecordID) REFERENCES BibliographicRecord(RecordID)
);

CREATE TABLE Viet (
    AuthorID VARCHAR(10) NOT NULL,
    RecordID VARCHAR(10) NOT NULL,
    PRIMARY KEY (AuthorID, RecordID),
    FOREIGN KEY (AuthorID) REFERENCES Author(SSN),
    FOREIGN KEY (RecordID) REFERENCES BibliographicRecord(RecordID)
);

CREATE TABLE Thuoc (
    CategoryName NVARCHAR(100) NOT NULL,
    RecordID VARCHAR(10) NOT NULL,
    PRIMARY KEY (CategoryName, RecordID),
    FOREIGN KEY (CategoryName) REFERENCES Category(Name),
    FOREIGN KEY (RecordID) REFERENCES BibliographicRecord(RecordID)
);

-- 1.4 CIRCULATION
CREATE TABLE Cart (
    CartID VARCHAR(8) PRIMARY KEY,
    InitialDate DATE,
    [Status] VARCHAR(20) NOT NULL,
    UserID CHAR(8) NOT NULL,
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

CREATE TABLE [Cart Contain] (
    CartID VARCHAR(8) NOT NULL,
    BookID VARCHAR(10) NOT NULL,
    PRIMARY KEY (CartID, BookID),
    FOREIGN KEY (CartID) REFERENCES Cart(CartID),
    FOREIGN KEY (BookID) REFERENCES [Book Copy](BookID)
);

CREATE TABLE Loan (
    LoanID VARCHAR(8) PRIMARY KEY,
    LoanDate DATE NOT NULL,
    [Due Date] DATE NOT NULL,
    ReturnDate DATE,
    [Status] VARCHAR(20) NOT NULL,
    [Handler ID] CHAR(8) NOT NULL,
    BorrowerID CHAR(8) NOT NULL,
    BookID VARCHAR(10) NOT NULL,
    FOREIGN KEY ([Handler ID]) REFERENCES [User](UserID),
    FOREIGN KEY (BorrowerID) REFERENCES [User](UserID),
    FOREIGN KEY (BookID) REFERENCES [Book Copy](BookID)
);

CREATE TABLE Fine (
    FineID CHAR(8) PRIMARY KEY,
    Amount DECIMAL(10,2) NOT NULL,
    Reason NVARCHAR(100),
    [Status] VARCHAR(20) NOT NULL,
    [Closing Date] DATE,
    ActionDate DATE,
    HandlerID CHAR(8) NOT NULL,
    LoanID VARCHAR(8) NOT NULL,
    FOREIGN KEY (HandlerID) REFERENCES [User](UserID),
    FOREIGN KEY (LoanID) REFERENCES Loan(LoanID),
    CONSTRAINT CHK_FineAmount CHECK (Amount > 0),
    CONSTRAINT CHK_FineStatus CHECK ([Status] IN ('Paid', 'Unpaid'))
);
GO

-- =============================================
-- 2. NHAP LIEU MAU (DA GOP VA SUA LOI)
-- =============================================

-- 2.1 Branch & Manufacture
INSERT INTO Branch ([Branch ID], [Branch Name], [Address]) VALUES
('B001', N'Chi nhánh Trung Tâm', N'123 Đường Nguyễn Huệ, Quận 1, TP.HCM'),
('B002', N'Chi nhánh Thủ Đức', N'456 Đường Võ Văn Ngân, TP. Thủ Đức'),
('B003', N'Chi nhánh Quận 5', N'789 Đường An Dương Vương, Quận 5'),
('B004', N'Chi nhánh Quận 7', N'101 Đường Nguyễn Văn Linh, Quận 7'),
('B005', N'Chi nhánh Gò Vấp', N'202 Đường Quang Trung, Quận Gò Vấp');

INSERT INTO Manufacture (ManufactureID, ManuName, Contact) VALUES
('M001', N'Công ty In ấn Sao Mai', N'saomai@print.com'),
('M002', N'Nhà xuất bản Trẻ', N'tre@nxb.vn'),
('M003', N'Nhà xuất bản Kim Đồng', N'kimdong@nxb.vn'),
('M004', N'In ấn Phương Đông', N'phuongdong@in.com'),
('M005', N'Nhà xuất bản Tổng hợp HCM', N'tonghop@nxb.vn');

-- 2.2 Author (Đã gộp A001-A005 và A006-A010)
INSERT INTO Author (SSN, Biography, Fullname) VALUES
('A001', N'Tac gia noi tieng ve linh vuc kinh te', N'Nguyen Van A'),
('A002', N'Nha van chuyen viet truyen trinh tham', N'Tran Thi B'),
('A003', N'Chuyen gia lap trinh va Co so du lieu', N'Le Van C'),
('A004', N'Tac gia sach khoa hoc vien tuong', N'Pham Minh D'),
('A005', N'Tac gia sach thieu nhi', N'Hoang Thuy E'),
('A006', N'Tác giả bộ truyện Harry Potter nổi tiếng toàn cầu.', N'J.K. Rowling'),
('A007', N'Chuyên gia về Clean Code và kiến trúc phần mềm (Uncle Bob).', N'Robert C. Martin'),
('A008', N'Nhà văn Nhật Bản đương đại nổi tiếng với Rừng Na Uy.', N'Haruki Murakami'),
('A009', N'Giáo sư ngôn ngữ học, đồng tác giả sách học thuật.', N'Nguyễn Phương F'),
('A010', N'Chuyên gia AI và Machine Learning.', N'Phạm Trí Tuệ');

-- 2.3 Category
INSERT INTO Category (Name, [Description]) VALUES
(N'Lập trình', N'Sách liên quan đến phát triển phần mềm và code'),
(N'Kinh tế', N'Sách về tài chính, quản trị, đầu tư'),
(N'Truyện Trinh Thám', N'Sách về điều tra, phá án'),
(N'Khoa Học Viễn Tưởng', N'Sách về tương lai, vũ trụ'),
(N'Văn Học', N'Sách về thơ ca, tiểu thuyết'),
(N'Ngoại ngữ', N'Sách học tiếng Anh, Nhật, Trung');

-- 2.4 BibliographicRecord (Đã gộp R001-R005 và R006-R013)
INSERT INTO BibliographicRecord (RecordID, Title, RefBookID, Publisher, [Year]) VALUES
('R001', N'Lập trình C# cơ bản', NULL, N'Nhà xuất bản Trẻ', 2022),
('R002', N'Bí mật tư duy triệu phú', NULL, N'Nhà xuất bản Tổng hợp HCM', 2018),
('R003', N'Sherlock Holmes: Cuộc điều tra cuối cùng', NULL, N'Nhà xuất bản Kim Đồng', 2015),
('R004', N'Lập trình Web với ASP.NET', 'R001', N'Nhà xuất bản Trẻ', 2023),
('R005', N'Dế Mèn Phiêu Lưu Ký', NULL, N'Nhà xuất bản Kim Đồng', 2010),
('R006', N'Harry Potter và Hòn đá Phù thủy', NULL, N'Nhà xuất bản Trẻ', 2018),
('R007', N'Harry Potter và Phòng chứa Bí mật', 'R006', N'Nhà xuất bản Trẻ', 2019),
('R008', N'Harry Potter và Tên tù nhân ngục Azkaban', 'R007', N'Nhà xuất bản Trẻ', 2020),
('R009', N'Clean Code: Mã sạch', NULL, N'Nhà xuất bản Khoa học Kỹ thuật', 2017),
('R010', N'Clean Architecture: Kiến trúc sạch', NULL, N'Nhà xuất bản Khoa học Kỹ thuật', 2021),
('R011', N'Rừng Na Uy', NULL, N'Nhà xuất bản Hội Nhà Văn', 2015),
('R012', N'Lập trình C# cơ bản(tái bản lần 2)', 'R001', N'Nhà xuất bản Giáo dục Việt Nam', 2024),
('R013', N'Tiếng Anh giao tiếp cơ bản', NULL, N'Nhà xuất bản Giáo dục Việt Nam', 2020);


-- 2.5 User Data
INSERT INTO [User] (UserID, Username, [Password], [First Name], [Last Name], Email, SSN, Birthday, [Address], UserType, [Phone Number]) VALUES
('U0000001', 'admin_lib', 'Admin@123', N'Nguyễn', N'Quản Trị', 'admin@lib.edu', '11111111', '1985-01-01', N'Hà Nội', 'Admin', '0901111111'),
('U0000002', 'lib_td', 'Librarian@1', N'Phạm', N'Thủ Thư 1', 'lib1@lib.edu', '22222222', '1990-05-15', N'TP. Thủ Đức', 'Librarian', '0902222222'),
('U0000003', 'lib_q1', 'Librarian@2', N'Lê', N'Thủ Thư 2', 'lib2@lib.edu', '33333333', '1992-10-20', N'Quận 1', 'Librarian', '0903333333'),
('U0000004', 'stu_loan', 'Student@123', N'Trần', N'Sinh Viên 1', 'stu1@hcmut.edu', '44444444', '2000-03-08', N'Bình Thạnh', 'Student', '0904444444'),
('U0000005', 'stu_cart', 'Student@345', N'Hoàng', N'Sinh Viên 2', 'stu2@hcmut.edu', '55555555', '2001-07-25', N'Quận 5', 'Student', '0905555555'),
('U0000006', 'stu_fine', 'Student@567', N'Võ', N'Sinh Viên 3', 'stu3@hcmut.edu', '66666666', '2002-12-10', N'Quận 7', 'Student', '0906666666'),
('U0000007', 'lib_b1_new', 'Librarian@3', N'Ngô', N'Thủ Thư 3', 'lib3@lib.edu', '77777777', '1988-03-01', N'Quận 1', 'Librarian', '0907777777'),
('U0000008', 'lib_b3_new', 'Librarian@4', N'Trịnh', N'Thủ Thư 4', 'lib4@lib.edu', '88888888', '1995-11-25', N'Quận 5', 'Librarian', '0908888888'),
('U0000009', 'lib_b4_new', 'Librarian@5', N'Đinh', N'Thủ Thư 5', 'lib5@lib.edu', '99999999', '1991-04-12', N'Quận 7', 'Librarian', '0909999999'),
('U0000010', 'lib_b5_new', 'Librarian@6', N'Bùi', N'Thủ Thư 6', 'lib6@lib.edu', '10101010', '1993-09-09', N'Gò Vấp', 'Librarian', '0910101010'),
('U0000011', 'stu_2010', 'Student@2010', N'Cao', N'Sinh Viên 4', 'stu4@hcmut.edu', '11111112', '2000-01-20', N'Bình Thạnh', 'Student', '0911111111'),
('U0000012', 'stu_2110', 'Student@2110', N'Đỗ', N'Sinh Viên 5', 'stu5@hcmut.edu', '12121212', '2001-08-01', N'Quận 5', 'Student', '0912121212'),
('U0000013', 'stu_2210', 'Student@2210', N'Đinh', N'Sinh Viên 6', 'stu6@hcmut.edu', '13131313', '2002-04-04', N'Thủ Đức', 'Student', '0913131313'),
('U0000014', 'stu_2211', 'Student@2211', N'Chu', N'Sinh Viên 7', 'stu7@hcmut.edu', '14141414', '2002-11-11', N'Quận 7', 'Student', '0914141414'),
('U0000015', 'stu_2310', 'Student@2310', N'Dương', N'Sinh Viên 8', 'stu8@hcmut.edu', '15151515', '2003-05-30', N'Gò Vấp', 'Student', '0915151515');

INSERT INTO [Admin] (UserID, AdminCode) VALUES 
('U0000001', 'AD001');


INSERT INTO Librarian (UserID, [Branch ID]) VALUES 
('U0000002', 'B002'), 
('U0000003', 'B001'),
('U0000007', 'B001'), 
('U0000008', 'B003'),
('U0000009', 'B004'),
('U0000010', 'B005');

INSERT INTO Student (UserID, [Student ID], [Year]) VALUES
('U0000004', '20100000', 2020),
('U0000005', '21100000', 2021),
('U0000006', '22100000', 2022),
('U0000011', '20100001', 2020),
('U0000012', '21100002', 2021),
('U0000013', '22100003', 2022),
('U0000014', '22100004', 2022),
('U0000015', '23100005', 2023);

-- 2.6 Book Copy (Đã gộp tất cả và sửa lỗi cú pháp)
INSERT INTO [Book Copy] (BookID, RecordID, [Entry Date], [Branch ID], ManufactureID, [Status]) VALUES
('C001', 'R001', '2023-01-10', 'B002', 'M001', 'CheckedOut'),
('C002', 'R001', '2023-01-10', 'B002', 'M001', 'Available'),
('C003', 'R002', '2023-03-01', 'B001', 'M002', 'OnLoan'),
('C004', 'R002', '2023-03-01', 'B001', 'M002', 'Available'),
('C005', 'R003', '2022-11-15', 'B003', 'M003', 'Available'),
('C006', 'R003', '2022-11-15', 'B003', 'M003', 'Maintenance'),
('C007', 'R004', '2025-02-20', 'B004', 'M004', 'OnLoan'),
('C008', 'R004', '2025-02-20', 'B004', 'M004', 'Available'),
('C009', 'R005', '2021-05-05', 'B005', 'M005', 'Available'),
('C010', 'R005', '2021-05-05', 'B005', 'M005', 'Maintenance'),
('C011', 'R006', '2023-06-01', 'B001', 'M002', 'Available'),
('C012', 'R006', '2023-06-01', 'B001', 'M002', 'OnLoan'),
('C013', 'R006', '2023-06-05', 'B002', 'M002', 'Available'),
('C014', 'R006', '2023-06-05', 'B002', 'M002', 'Available'),
('C015', 'R006', '2023-07-01', 'B003', 'M002', 'Maintenance'),
('C016', 'R006', '2023-07-01', 'B005', 'M002', 'Available'),
('C017', 'R009', '2022-01-15', 'B002', 'M004', 'Available'),
('C018', 'R009', '2022-01-15', 'B002', 'M004', 'OnLoan'),
('C019', 'R009', '2022-02-20', 'B003', 'M004', 'CheckedOut'),
('C020', 'R009', '2022-02-20', 'B003', 'M004', 'Available'),
('C021', 'R011', '2021-12-12', 'B004', 'M005', 'Available'),
('C022', 'R011', '2021-12-12', 'B004', 'M005', 'Available'),
('C023', 'R011', '2022-03-10', 'B001', 'M005', 'Lost'),
('C024', 'R012', '2025-10-01', 'B002', 'M001', 'Available'),
('C025', 'R012', '2025-10-01', 'B002', 'M001', 'Available'),
('C026', 'R012', '2025-10-05', 'B001', 'M001', 'OnLoan'),
('C027', 'R007', '2023-08-15', 'B001', 'M002', 'Available'),
('C028', 'R007', '2023-08-15', 'B002', 'M002', 'Available'),
('C029', 'R008', '2023-09-20', 'B001', 'M002', 'Available'),
('C030', 'R008', '2023-09-20', 'B005', 'M002', 'Available');

-- 2.7 Keywords (Đã gộp và sửa cú pháp)
INSERT INTO Keywords (RecordID, Keyword) VALUES
('R001', N'Lập trình'), ('R001', 'C#'),
('R002', N'Kinh tế'),
('R003', N'Trinh thám'),
('R004', 'ASP.NET'),
('R006', 'Harry Potter'), ('R006', 'Magic'), ('R006', 'Hogwarts'),
('R007', 'Harry Potter'), ('R007', 'Chamber of Secrets'),
('R009', 'Clean Code'), ('R009', 'Java'), ('R009', 'Refactoring'),
('R010', 'Architecture'), ('R010', 'Design Patterns'),
('R012', 'AI'), ('R012', 'Machine Learning'), ('R012', 'C#'),
('R011', 'Novel'), ('R011', 'Japan');

-- 2.8 Relation VIET (Đã gộp)
INSERT INTO Viet (AuthorID, RecordID) VALUES
('A003', 'R001'), ('A001', 'R002'), ('A002', 'R003'), ('A003', 'R004'), ('A005', 'R005'),
('A006', 'R006'), ('A006', 'R007'), ('A006', 'R008'),
('A007', 'R009'), ('A007', 'R010'),
('A008', 'R011'),
('A003', 'R012'), ('A010', 'R012'),
('A003', 'R013');

-- 2.9 Relation THUOC (Đã gộp và sửa cú pháp)
INSERT INTO Thuoc (CategoryName, RecordID) VALUES
(N'Lập trình', 'R001'),
(N'Kinh tế', 'R002'),
(N'Truyện Trinh Thám', 'R003'),
(N'Lập trình', 'R004'),
(N'Văn Học', 'R005'),
(N'Văn học', 'R006'),
(N'Văn học', 'R007'),
(N'Văn học', 'R008'),
(N'Ngoại ngữ', 'R006'),
(N'Lập trình', 'R009'),
(N'Lập trình', 'R010'),
(N'Văn học', 'R011'),
(N'Lập trình', 'R012'),
(N'Khoa Học Viễn Tưởng', 'R012'),
(N'Lập trình', 'R013');

-- 2.10 Circulation Data
INSERT INTO Loan (LoanID, LoanDate, [Due Date], ReturnDate, [Status], [Handler ID], BorrowerID, BookID) VALUES
('L001', '2025-10-01', '2025-10-15', '2025-10-14', 'Returned', 'U0000003', 'U0000004', 'C002'),
('L002', '2025-10-20', '2025-11-03', NULL, 'Overdue', 'U0000003', 'U0000004', 'C003'),
('L003', '2025-10-10', '2025-10-24', '2025-11-05', 'Returned', 'U0000002', 'U0000006', 'C004'),
('L004', '2025-09-01', '2025-09-15', NULL, 'Overdue', 'U0000002', 'U0000006', 'C001'),
('L005', '2025-11-30', '2025-12-14', NULL, 'OnLoan', 'U0000003', 'U0000004', 'C007');

INSERT INTO Cart (CartID, InitialDate, [Status], UserID) VALUES
('CT001', '2025-11-19', 'Active', 'U0000005'),
('CT002', '2025-11-19', 'Active', 'U0000004'),
('CT003', '2025-11-18', 'Completed', 'U0000006'),
('CT004', '2025-11-17', 'Cancelled', 'U0000005'),
('CT005', '2025-11-19', 'Active', 'U0000004');

INSERT INTO [Cart Contain] (CartID, BookID) VALUES
('CT001', 'C002'), ('CT001', 'C004'), ('CT002', 'C005'), ('CT003', 'C008'), ('CT005', 'C009');

INSERT INTO Fine (FineID, Amount, Reason, [Status], HandlerID, LoanID, [Closing Date], ActionDate) VALUES
('F001', 100000.00, N'Hư hỏng nhẹ bìa sách', 'Paid', 'U0000002', 'L001', '2025-10-14', '2025-10-14'),
('F002', 50000.00, N'Trả sách quá hạn 1 ngày', 'Paid', 'U0000002', 'L003', '2025-11-05', '2025-11-05'),
('F003', 20000.00, N'Mất thẻ thư viện', 'Paid', 'U0000001', 'L001', '2025-10-14', '2025-10-14'),
('F004', 50000.00, N'Trả sách quá hạn', 'Unpaid', 'U0000002', 'L004', NULL, NULL),
('F005', 200000.00, N'Mất sách', 'Unpaid', 'U0000003', 'L002', NULL, NULL);
GO

-- =============================================
-- 3. TAO CAC TRIGGER
-- =============================================

-- trigger_autocreatefineonoverdue
CREATE TRIGGER trg_AutoCreateFineOnOverdue
ON Loan
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE [Status] = 'Overdue')
    BEGIN
        INSERT INTO Fine (FineID, Amount, Reason, [Status], HandlerID, LoanID)
        SELECT 
            'F' + i.LoanID, 
            50000, 
            N'Trả sách quá hạn',
            'Unpaid',
            i.[Handler ID],
            i.LoanID
        FROM inserted i
        WHERE i.[Status] = 'Overdue'
          AND NOT EXISTS (SELECT 1 FROM Fine f WHERE f.LoanID = i.LoanID);
    END
END;
GO

-- trigger_checkcartitemavailable
CREATE TRIGGER trg_CheckCartItemAvailable
ON [Cart Contain]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN [Book Copy] AS bc ON i.BookID = bc.BookID
        WHERE bc.[Status] <> 'Available'
    )
    BEGIN
        RAISERROR (N'Sách này hiện không có sẵn để thêm vào giỏ. (Đã có người mượn hoặc đang bảo trì)', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- trigger_preventmanualstatuschange
CREATE TRIGGER trg_PreventManualStatusChange
ON [Book Copy]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE([Status])
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN Loan l ON i.BookID = l.BookID
            WHERE i.[Status] = 'Available' AND l.[Status] = 'OnLoan'
        )
        BEGIN
            RAISERROR (N'Không thể set "Available" thủ công. Sách này vẫn đang được mượn (OnLoan). Phải trả sách ở bảng Loan trước.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM inserted i
            WHERE i.[Status] = 'CheckedOut'
              AND NOT EXISTS (SELECT 1 FROM Loan l WHERE l.BookID = i.BookID AND l.[Status] = 'OnLoan')
        )
        BEGIN
            RAISERROR (N'Không thể set "CheckedOut" thủ công. Phải tạo một Loan mới để mượn sách.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
END;
GO

-- trigger_updatebookcopystatus
CREATE TRIGGER trg_UpdateBookCopyStatus
ON Loan
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- TH1: Khi MUON SACH (INSERT mot Loan moi)
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        UPDATE bc
        SET bc.[Status] = 'CheckedOut'
        FROM [Book Copy] AS bc
        JOIN inserted AS i ON bc.BookID = i.BookID;
    END

    -- TH2: Khi TRA SACH (UPDATE Loan status = 'Returned')
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        UPDATE bc
        SET bc.[Status] = 'Available'
        FROM [Book Copy] AS bc
        JOIN inserted AS i ON bc.BookID = i.BookID
        JOIN deleted AS d ON i.LoanID = d.LoanID
        WHERE i.[Status] = 'Returned' AND d.[Status] <> 'Returned';
    END

    -- TH3: Khi HUY MUON (DELETE mot Loan)
    IF NOT EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        UPDATE bc
        SET bc.[Status] = 'Available'
        FROM [Book Copy] AS bc
        JOIN deleted AS d ON bc.BookID = d.BookID;
    END
END;
GO

-- =============================================
-- 4. TAO STORED PROCEDURES
-- =============================================

-- sp_SearchBookByTitle
CREATE OR ALTER PROCEDURE sp_SearchBookByTitle
    @Keyword NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        br.RecordID,
        br.Title,
        br.Publisher,
        br.[Year],
        
        -- 1. Liệt kê tên Tác giả
        (
            SELECT STRING_AGG(a.Fullname, N', ')
            FROM Viet v 
            JOIN Author a ON v.AuthorID = a.SSN
            WHERE v.RecordID = br.RecordID
        ) AS AuthorName,
        
        -- 2. Tính số lượng bản sao khả dụng
        COUNT(CASE WHEN bc.[Status] = 'Available' THEN 1 END) AS AvailableCopies,
        
        -- 3. LIỆT KÊ TẤT CẢ CÁC BOOKID ĐANG CÓ (Status = 'Available')
        (
            SELECT STRING_AGG(bc_avail.BookID, ', ')
            FROM [Book Copy] bc_avail
            WHERE bc_avail.RecordID = br.RecordID
              AND bc_avail.[Status] = 'Available'
        ) AS AvailableBookIDs
        
    FROM BibliographicRecord br
    LEFT JOIN [Book Copy] bc ON br.RecordID = bc.RecordID
    WHERE br.Title LIKE N'%' + @Keyword + N'%'
    
    GROUP BY 
        br.RecordID, br.Title, br.Publisher, br.[Year]
    ORDER BY br.Title ASC;
END;
GO

-- sp_GetTopBorrowedBooks
CREATE PROCEDURE sp_GetTopBorrowedBooks
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 10
        br.RecordID,
        br.Title,
        COUNT(l.LoanID) AS BorrowCount
    FROM Loan l
    JOIN [Book Copy] bc ON l.BookID = bc.BookID
    JOIN BibliographicRecord br ON bc.RecordID = br.RecordID
    WHERE l.LoanDate BETWEEN @StartDate AND @EndDate
    GROUP BY br.RecordID, br.Title
    HAVING COUNT(l.LoanID) > 0
    ORDER BY BorrowCount DESC, br.Title ASC;
END;
GO

-- sp_UpdateBibliographicRecord
CREATE PROCEDURE sp_UpdateBibliographicRecord
    @RecordID VARCHAR(10),
    @Title NVARCHAR(200),
    @RefBookID VARCHAR(10) = NULL,
    @Publisher NVARCHAR(100),
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM BibliographicRecord WHERE RecordID = @RecordID)
    BEGIN
        RAISERROR(N'Lỗi: Không tìm thấy tài liệu có mã "%s" để cập nhật.', 16, 1, @RecordID);
        RETURN;
    END
    IF @Title IS NULL OR LTRIM(RTRIM(@Title)) = ''
    BEGIN
        RAISERROR(N'Lỗi: Tựa đề sách không được để trống khi cập nhật.', 16, 1);
        RETURN;
    END
    IF ( @Year < 0 OR @Year > YEAR ( GETDATE () ) )
    BEGIN
        RAISERROR(N'Lỗi: Năm xuất bản (%d) không hợp lệ.', 16, 1, @Year);
        RETURN;
    END
    IF @RefBookID = @RecordID
    BEGIN
        RAISERROR(N'Lỗi: Sách không thể tự tham chiếu chính nó (RefBookID trùng RecordID).', 16, 1);
        RETURN;
    END
    IF @RefBookID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM BibliographicRecord WHERE RecordID = @RefBookID)
    BEGIN
        RAISERROR(N'Lỗi: Mã sách tham khảo mới "%s" không tồn tại.', 16, 1, @RefBookID);
        RETURN;
    END

    UPDATE BibliographicRecord
    SET Title = @Title,
        RefBookID = @RefBookID,
        Publisher = @Publisher,
        [Year] = @Year
    WHERE RecordID = @RecordID;
    PRINT N'Cập nhật thông tin tài liệu thành công!';
END;
GO

-- sp_DeleteBibliographicRecord
CREATE PROCEDURE sp_DeleteBibliographicRecord
    @RecordID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM BibliographicRecord WHERE RecordID = @RecordID)
    BEGIN
        RAISERROR(N'Lỗi: Không tìm thấy tài liệu có mã "%s" để xóa.', 16, 1, @RecordID);
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM [Book Copy] WHERE RecordID = @RecordID)
    BEGIN
        DECLARE @NumCopies INT;
        SELECT @NumCopies = COUNT(*) FROM [Book Copy] WHERE RecordID = @RecordID;
        RAISERROR(N'Lỗi: Không thể xóa tài liệu này vì đang tồn tại %d bản sao (Book Copy) trong kho. Cần thanh lý sách trước.', 16, 1, @NumCopies);
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM BibliographicRecord WHERE RefBookID = @RecordID)
    BEGIN
        RAISERROR(N'Lỗi: Không thể xóa tài liệu này vì nó đang được dùng làm tài liệu tham khảo cho sách khác.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        DELETE FROM Viet WHERE RecordID = @RecordID;
        DELETE FROM Thuoc WHERE RecordID = @RecordID;
        DELETE FROM Keywords WHERE RecordID = @RecordID;
        DELETE FROM BibliographicRecord WHERE RecordID = @RecordID;
        COMMIT TRANSACTION;
        PRINT N'Xóa tài liệu và các thông tin liên quan thành công!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(N'Lỗi hệ thống khi xóa: %s', 16, 1, @ErrorMessage);
    END CATCH
END;
GO

-- sp_FilterBooksByCategory
CREATE OR ALTER PROCEDURE sp_FilterBooksByCategory
    @CategoryName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        br.RecordID,
        br.Title,
        br.Publisher,
        br.[Year],
        -- Sử dụng STRING_AGG để gom tất cả tên tác giả thành một chuỗi duy nhất
        (
            SELECT STRING_AGG(a.Fullname, N', ')
            FROM Viet v 
            JOIN Author a ON v.AuthorID = a.SSN
            WHERE v.RecordID = br.RecordID
        ) AS AuthorName,
        -- Tính số lượng bản sao khả dụng
        COUNT(CASE WHEN bc.[Status] = 'Available' THEN 1 END) AS AvailableCopies
    FROM BibliographicRecord br
    JOIN Thuoc t ON br.RecordID = t.RecordID -- Chỉ lấy sách thuộc Category
    -- Bỏ LEFT JOIN Viet/Author ở cấp ngoài
    LEFT JOIN [Book Copy] bc ON br.RecordID = bc.RecordID
    WHERE 
        t.CategoryName = @CategoryName
    -- Chỉ GROUP BY các thông tin của BibliographicRecord
    GROUP BY 
        br.RecordID,
        br.Title,
        br.Publisher,
        br.[Year]
    ORDER BY br.Title ASC;
END;
GO
-- 2.4.1 Ham 1: Tinh toan tien phat (Su dung IF/tinh toan)
-- Muc dich: Tinh tien phat du kien dua tren so ngay qua han trong bang Loan
IF OBJECT_ID('fn_CalculateFine') IS NOT NULL
    DROP FUNCTION fn_CalculateFine;
GO

CREATE FUNCTION fn_CalculateFine (@LoanID VARCHAR(8))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @FineAmount DECIMAL(10,2) = 0;
    DECLARE @DueDate DATE;
    DECLARE @ReturnDate DATE;
    DECLARE @DaysOverdue INT;
    DECLARE @DailyFineRate DECIMAL(10,2) = 5000; -- Muc phat: 5000 dong/ngay

    -- Kiem tra xem LoanID co ton tai khong
    IF NOT EXISTS (SELECT 1 FROM Loan WHERE LoanID = @LoanID)
        RETURN 0;

    -- Nếu tất cả phiếu phạt liên quan đã Paid thì không còn phạt
    IF NOT EXISTS (SELECT 1 FROM Fine WHERE LoanID = @LoanID AND [Status] = 'Unpaid')
        RETURN 0;

    -- Lay thong tin Han Tra va Ngay Tra tu bang Loan
    SELECT @DueDate = [Due Date], @ReturnDate = ReturnDate
    FROM Loan
    WHERE LoanID = @LoanID;

    -- Neu chua tra sach (ReturnDate la NULL), tinh den hom nay
    IF @ReturnDate IS NULL
        SET @ReturnDate = CAST(GETDATE() AS DATE);

    -- Logic IF: Chi phat neu Ngay tra thuc te > Han tra
    IF @ReturnDate > @DueDate
    BEGIN
        SET @DaysOverdue = DATEDIFF(DAY, @DueDate, @ReturnDate);
        SET @FineAmount = @DaysOverdue * @DailyFineRate;
    END

    RETURN @FineAmount;
END;
GO

-- 2.4.2 Ham 2: Liet ke sach qua han (Su dung CURSOR)
-- Muc dich: Tra ve chuoi ten cac cuon sach dang bi qua han cua 1 User
IF OBJECT_ID('fn_ListOverdueBooksByUser') IS NOT NULL
    DROP FUNCTION fn_ListOverdueBooksByUser;
GO

CREATE FUNCTION fn_ListOverdueBooksByUser (@UserID CHAR(8))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @BookList NVARCHAR(MAX) = '';
    DECLARE @Title NVARCHAR(200);

    -- Kiem tra User ton tai
    IF NOT EXISTS (SELECT 1 FROM [User] WHERE UserID = @UserID)
        RETURN N'User không tồn tại';

    -- Khai bao CURSOR de duyet danh sach sach qua han
    -- Join cac bang: Loan -> Book Copy -> BibliographicRecord de lay Title
    DECLARE cur_Overdue CURSOR FOR
    SELECT br.Title
    FROM Loan l
    JOIN [Book Copy] bc ON l.BookID = bc.BookID
    JOIN BibliographicRecord br ON bc.RecordID = br.RecordID
    WHERE l.BorrowerID = @UserID 
      AND l.[Status] = 'Overdue'; -- Chi lay sach co trang thai Overdue

    OPEN cur_Overdue;
    FETCH NEXT FROM cur_Overdue INTO @Title;

    -- Vong lap duyet tung dong
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Noi chuoi: Neu da co sach truoc do thi them dau phay
        IF @BookList = ''
            SET @BookList = @Title;
        ELSE
            SET @BookList = @BookList + ', ' + @Title;

        FETCH NEXT FROM cur_Overdue INTO @Title;
    END;

    CLOSE cur_Overdue;
    DEALLOCATE cur_Overdue;

    IF @BookList = ''
        SET @BookList = N'Không có sách quá hạn.';

    RETURN @BookList;
END;
GO
-- =============================================
-- Muc dich: Xu ly giao dich Tra sach va Thu tien phat cung luc (Transaction)
-- =============================================
GO

CREATE OR ALTER PROCEDURE sp_ReturnBookAndPayFine
    @LoanID VARCHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CalculatedFine DECIMAL(10,2) = dbo.fn_CalculateFine(@LoanID);
    BEGIN TRANSACTION;
    BEGIN TRY
        -- A. Cập nhật trạng thái Phiếu mượn thành Returned
        UPDATE Loan 
        SET ReturnDate = GETDATE(), [Status] = 'Returned'
        WHERE LoanID = @LoanID;

        -- B. Cập nhật Phiếu phạt thành Paid (Nếu có nợ)
        -- Điều này đảm bảo khi tính lại tiền phạt sẽ ra 0
        IF EXISTS (SELECT 1 FROM Fine WHERE LoanID = @LoanID AND [Status] = 'Unpaid')
        BEGIN
            UPDATE Fine
            SET [Status] = 'Paid', 
                [Closing Date] = GETDATE(),
                Amount = @CalculatedFine,
                ActionDate = GETDATE()
            WHERE LoanID = @LoanID AND [Status] = 'Unpaid';
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
-- sp_InsertBibliographicRecord: Thêm tài liệu thư mục và Tác giả
CREATE PROCEDURE sp_InsertBibliographicRecord
    @Title        NVARCHAR(200),
    @RefBookID    VARCHAR(10) = NULL,
    @Publisher    NVARCHAR(100),
    @Year         INT,
    @AuthorName   NVARCHAR(100),
    @AuthorID     VARCHAR(10),
    @AuthorBio    NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NextID VARCHAR(10);
    DECLARE @MaxNum INT;

    IF (@Year < 0 OR @Year > YEAR(GETDATE()))
    BEGIN
        SELECT 'Invalid year' AS Error;
        RETURN;
    END

    IF LEN(LTRIM(RTRIM(@Title))) = 0
    BEGIN
        SELECT 'Title cannot be empty' AS Error;
        RETURN;
    END

    IF (@RefBookID IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM BibliographicRecord WHERE RecordID = @RefBookID
    ))
    BEGIN
        SELECT 'RefBookID does not exist' AS Error;
        RETURN;
    END

    SELECT @MaxNum = MAX(
        TRY_CAST(SUBSTRING(RecordID, 2, LEN(RecordID)) AS INT)
    )
    FROM BibliographicRecord;

    SET @MaxNum = ISNULL(@MaxNum, 0);
    -- Logic tạo ID mới (R001, R002, ...)
    IF @MaxNum < 999
        SET @NextID = 'R' + RIGHT('00' + CAST(@MaxNum + 1 AS VARCHAR(3)), 3);
    ELSE
        SET @NextID = 'R' + RIGHT('000' + CAST(@MaxNum + 1 AS VARCHAR(4)), 4);


    BEGIN TRY
        INSERT INTO BibliographicRecord(RecordID, Title, RefBookID, Publisher, [Year])
        VALUES (@NextID, @Title, @RefBookID, @Publisher, @Year);

        IF NOT EXISTS (SELECT 1 FROM Author WHERE SSN = @AuthorID)
        BEGIN
            INSERT INTO Author(SSN, Fullname, Biography)
            VALUES (@AuthorID, @AuthorName, @AuthorBio);
        END

        INSERT INTO Viet (AuthorID, RecordID)
        VALUES (@AuthorID, @NextID);

        SELECT @NextID AS NewRecordID, 'success' AS Status;

    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Error;
    END CATCH
END
GO

--- sp_GetActiveCartDetails: Lấy chi tiết sách trong giỏ hàng đang Active
CREATE OR ALTER PROCEDURE sp_GetActiveCartDetails
    @UserID CHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ActiveCartID VARCHAR(8);
    SELECT @ActiveCartID = CartID 
    FROM Cart 
    WHERE UserID = @UserID AND [Status] = 'Active';

    IF @ActiveCartID IS NULL
    BEGIN
        SELECT N'Không tìm thấy giỏ hàng hoạt động.' AS Message, NULL AS CartID, 0 AS BookCount;
        RETURN;
    END

    SELECT
        cc.CartID,
        bc.BookID,
        br.Title,
        b.[Branch Name] AS BranchName,
        bc.[Status] AS BookStatus,
        (
            SELECT STRING_AGG(a.Fullname, N', ')
            FROM Viet v 
            JOIN Author a ON v.AuthorID = a.SSN
            WHERE v.RecordID = bc.RecordID
        ) AS AuthorName
    FROM [Cart Contain] cc
    JOIN [Book Copy] bc ON cc.BookID = bc.BookID
    JOIN BibliographicRecord br ON bc.RecordID = br.RecordID
    JOIN Branch b ON bc.[Branch ID] = b.[Branch ID]
    WHERE cc.CartID = @ActiveCartID;
END;
GO

-- sp_AddToCart: Thêm sách vào giỏ hàng
CREATE OR ALTER PROCEDURE sp_AddToCart
    @UserID CHAR(8),
    @BookID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ActiveCartID VARCHAR(8);

    SELECT @ActiveCartID = CartID 
    FROM Cart 
    WHERE UserID = @UserID AND [Status] = 'Active';

    IF @ActiveCartID IS NULL
    BEGIN
        DECLARE @MaxNum INT;
        SELECT @MaxNum = ISNULL(MAX(TRY_CAST(SUBSTRING(CartID, 3, LEN(CartID) - 2) AS INT)), 0)
        FROM Cart;
        SET @ActiveCartID = 'CT' + RIGHT('00' + CAST(@MaxNum + 1 AS VARCHAR(3)), 3);

        INSERT INTO Cart (CartID, InitialDate, [Status], UserID)
        VALUES (@ActiveCartID, GETDATE(), 'Active', @UserID);
    END
    
    IF EXISTS (SELECT 1 FROM [Cart Contain] WHERE CartID = @ActiveCartID AND BookID = @BookID)
    BEGIN
        RAISERROR(N'Sách này đã có trong giỏ hàng.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        -- Trigger trg_CheckCartItemAvailable sẽ kiểm tra sách có Available không
        INSERT INTO [Cart Contain] (CartID, BookID)
        VALUES (@ActiveCartID, @BookID);

        PRINT N'Thêm sách vào giỏ hàng thành công.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;
    END CATCH
END;
GO

-- sp_RemoveFromCart: Xóa sách khỏi giỏ hàng
CREATE OR ALTER PROCEDURE sp_RemoveFromCart
     @UserID CHAR(8),
    @BookID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ActiveCartID VARCHAR(8);

    SELECT @ActiveCartID = CartID 
    FROM Cart 
    WHERE UserID = @UserID AND [Status] = 'Active';

    IF @ActiveCartID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy giỏ hàng hoạt động.', 16, 1);
        RETURN;
    END

    DELETE FROM [Cart Contain]
    WHERE CartID = @ActiveCartID AND BookID = @BookID;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR(N'Không tìm thấy sách trong giỏ hàng.', 16, 1);
    END
    ELSE
    BEGIN
        PRINT N'Xóa sách khỏi giỏ hàng thành công.';
    END
END;
GO

-- sp_CheckoutCart: Chuyển giỏ hàng thành Phiếu Mượn (Loan)
CREATE OR ALTER PROCEDURE sp_CheckoutCart
    @BorrowerID CHAR(8),
    @HandlerID CHAR(8)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ActiveCartID VARCHAR(8);
    DECLARE @MaxLoanNum INT;
    DECLARE @NextLoanID VARCHAR(8);
    DECLARE @MaxBooks INT = 3; 
    
    -- 1. Xác định Giỏ hàng Active
    SELECT @ActiveCartID = CartID 
    FROM Cart 
    WHERE UserID = @BorrowerID AND [Status] = 'Active';

    IF @ActiveCartID IS NULL
    BEGIN
        RAISERROR(N'Lỗi: Người dùng không có giỏ hàng hoạt động.', 16, 1);
        RETURN;
    END
    
    -- 2. Kiểm tra giới hạn mượn sách
    IF (SELECT COUNT(*) FROM [Cart Contain] WHERE CartID = @ActiveCartID) > @MaxBooks
    BEGIN
        RAISERROR(N'Lỗi: Giỏ hàng có quá nhiều sách. Giới hạn là %d cuốn.', 16, 1, @MaxBooks);
        RETURN;
    END

    -- 3. Kiểm tra UserID Handler
    IF NOT EXISTS (SELECT 1 FROM [User] WHERE UserID = @HandlerID AND UserType IN ('Librarian', 'Admin'))
    BEGIN
        RAISERROR(N'Lỗi: Handler ID không hợp lệ hoặc không có quyền.', 16, 1);
        RETURN;
    END

    -- 4. Bắt đầu Giao dịch
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Lấy số ID lớn nhất hiện tại trong bảng Loan
        SELECT @MaxLoanNum = ISNULL(MAX(TRY_CAST(SUBSTRING(LoanID, 2, LEN(LoanID) - 1) AS INT)), 0)
        FROM Loan;

        -- Khai báo CURSOR để duyệt qua từng sách trong giỏ
        DECLARE cur_CartItems CURSOR FOR
        SELECT BookID
        FROM [Cart Contain] 
        WHERE CartID = @ActiveCartID;

        OPEN cur_CartItems;
        DECLARE @CurrentBookID VARCHAR(10);
        
        FETCH NEXT FROM cur_CartItems INTO @CurrentBookID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Tạo LoanID mới cho từng sách
            SET @MaxLoanNum = @MaxLoanNum + 1;
            SET @NextLoanID = 'L' + RIGHT('00' + CAST(@MaxLoanNum AS VARCHAR(5)), 3);

            -- INSERT vào bảng Loan (Mặc định mượn 14 ngày)
            INSERT INTO Loan (LoanID, LoanDate, [Due Date], [Status], [Handler ID], BorrowerID, BookID)
            VALUES (@NextLoanID, GETDATE(), DATEADD(DAY, 14, GETDATE()), 'OnLoan', @HandlerID, @BorrowerID, @CurrentBookID);
            
            FETCH NEXT FROM cur_CartItems INTO @CurrentBookID;
        END

        CLOSE cur_CartItems;
        DEALLOCATE cur_CartItems;
        
        -- 5. Cập nhật trạng thái Giỏ hàng thành Completed
        UPDATE Cart
        SET [Status] = 'Completed'
        WHERE CartID = @ActiveCartID;
        
        -- 6. Dọn dẹp Cart Contain 
        DELETE FROM [Cart Contain] WHERE CartID = @ActiveCartID;

        COMMIT TRANSACTION;
        SELECT N'Thanh toán giỏ hàng thành công! Đã tạo phiếu mượn.' AS Message, 'success' AS Status;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'Lỗi trong quá trình thanh toán: %s', 16, 1, @ErrorMessage);
        RETURN;
    END CATCH
END;
GO