const express = require("express");
const sql = require("mssql");
const cors = require("cors");

const app = express();
const PORT = 5000;

// 1. Cấu hình kết nối SQL Server
const dbConfig = {
  user: "sa",
  password: "12345",
  server: "localhost", // SỬA: Phải là localhost hoặc 127.0.0.1
  database: "LibraryDB",
  options: {
    encrypt: true,
    trustServerCertificate: true,
  },
};

// Middleware
app.use(cors());
app.use(express.json());

// 2. Kết nối Database
sql
  .connect(dbConfig)
  .then((pool) => {
    if (pool.connected) {
      console.log("✅ Đã kết nối thành công tới SQL Server!");
    }
  })
  .catch((err) => {
    console.error("❌ Lỗi kết nối Database:", err);
  });

// ================= API ENDPOINTS =================

// API: Lấy thông tin phiếu mượn (Loan) theo LoanID
app.get("/api/loan/:loanID", async (req, res) => {
  try {
    const { loanID } = req.params;
    const pool = await sql.connect(dbConfig);
    const result = await pool
      .request()
      .input("LoanID", sql.VarChar, loanID)
      .query("SELECT LoanID, BorrowerID FROM Loan WHERE LoanID = @LoanID");
    if (result.recordset.length === 0) {
      res.status(404).send("Không tìm thấy phiếu mượn");
    } else {
      res.json(result.recordset[0]);
    }
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// API: Lấy danh sách sách quá hạn của một user
app.get("/api/user/overdue-books/:userID", async (req, res) => {
  try {
    const { userID } = req.params;
    const pool = await sql.connect(dbConfig);
    const result = await pool
      .request()
      .input("UserID", sql.Char(8), userID)
      .query("SELECT dbo.fn_ListOverdueBooksByUser(@UserID) AS OverdueBooks");
    res.json(result.recordset[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// API 1: Tìm kiếm sách
app.get("/api/books/search", async (req, res) => {
  try {
    const { keyword } = req.query;
    const pool = await sql.connect(dbConfig);

    const result = await pool
      .request()
      .input("Keyword", sql.NVarChar(100), keyword)
      .execute("sp_SearchBookByTitle");

    res.json(result.recordset);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// API 2: Thêm sách mới
app.post("/api/books", async (req, res) => {
  try {
    const { recordID, title, publisher, year } = req.body;
    const pool = await sql.connect(dbConfig);

    await pool
      .request()
      .input("RecordID", sql.VarChar, recordID)
      .input("Title", sql.NVarChar, title)
      .input("Publisher", sql.NVarChar, publisher)
      .input("Year", sql.Int, year).query(`
                INSERT INTO BibliographicRecord (RecordID, Title, Publisher, Year)
                VALUES (@RecordID, @Title, @Publisher, @Year)
            `);

    res.json({ message: "Thêm sách thành công" });
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// API 3: Kiểm tra tiền phạt (Gọi Function SQL)
app.get("/api/loans/fine/:loanID", async (req, res) => {
  try {
    const { loanID } = req.params;
    const pool = await sql.connect(dbConfig);

    // Gọi hàm SQL fn_CalculateFine để lấy số tiền chính xác
    // Hàm này sẽ trả về 0 nếu tiền phạt đã được đóng (Paid)
    const result = await pool.request().input("LoanID", sql.VarChar, loanID)
      .query(`
                SELECT dbo.fn_CalculateFine(@LoanID) AS FineAmount,
                DATEDIFF(DAY, (SELECT [Due Date] FROM Loan WHERE LoanID = @LoanID), GETDATE()) AS DaysLate
            `);

    res.json(result.recordset[0]);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// ==========================================================
// API 4 [QUAN TRỌNG]: Trả sách & Thu tiền (ĐÃ SỬA)
// Thay vì UPDATE thủ công, ta gọi Stored Procedure để đảm bảo Transaction
// ==========================================================
app.post("/api/loans/return", async (req, res) => {
  try {
    const { loanID } = req.body;
    const pool = await sql.connect(dbConfig);

    // Gọi thủ tục sp_ReturnBookAndPayFine
    // Thủ tục này sẽ: 
    // 1. Update Loan -> Returned
    // 2. Update Fine -> Paid (nếu đang Unpaid)
    await pool.request()
      .input("LoanID", sql.VarChar, loanID)
      .execute("sp_ReturnBookAndPayFine");

    res.json({ message: "Đã trả sách và thanh toán phạt thành công!" });
  } catch (err) {
    console.error("Lỗi trả sách:", err.message);
    res.status(500).send(err.message);
  }
});
// ==========================================================


// API: Sửa thông tin sách
app.put("/api/books/:id", async (req, res) => {
  try {
    const { id } = req.params; 
    const { title, publisher, year, refBookID } = req.body; 

    const pool = await sql.connect(dbConfig);

    await pool
      .request()
      .input("RecordID", sql.VarChar, id)
      .input("Title", sql.NVarChar, title)
      .input("Publisher", sql.NVarChar, publisher)
      .input("Year", sql.Int, year)
      .input("RefBookID", sql.VarChar, refBookID ? refBookID : null)
      .execute("sp_UpdateBibliographicRecord");

    res.json({ message: "Cập nhật sách thành công!" });
  } catch (err) {
    console.error("Lỗi khi cập nhật:", err.message);
    res.status(500).send(err.message);
  }
});

// API: XÓA thông tin sách
app.delete("/api/books/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const pool = await sql.connect(dbConfig);

    await pool
      .request()
      .input("RecordID", sql.VarChar, id)
      .execute("sp_DeleteBibliographicRecord");

    res.json({ message: "Xóa sách thành công" });
  } catch (err) {
    console.error("Lỗi khi xóa:", err.message);
    res.status(500).send(err.message);
  }
});

// API 6: Lọc sách theo thể loại
app.get("/api/books/filter-by-category", async (req, res) => {
  try {
    const { category } = req.query;
    const pool = await sql.connect(dbConfig);

    const result = await pool
      .request()
      .input("CategoryName", sql.NVarChar(100), category)
      .execute("sp_FilterBooksByCategory");

    res.json(result.recordset);
  } catch (err) {
    console.error("Lỗi lọc sách:", err);
    res.status(500).send(err.message);
  }
});

app.get("/api/categories", async (req, res) => {
  try {
    const pool = await sql.connect(dbConfig);
    const result = await pool.request().query("SELECT Name FROM Category");
    res.json(result.recordset);
  } catch (err) {
    console.error("Lỗi lấy danh mục:", err);
    res.status(500).send(err.message);
  }
});

// Khởi chạy server
app.listen(PORT, () => {
  console.log(`🚀 Server đang chạy tại http://localhost:${PORT}`);
});