import React, { useState } from 'react';
import './CirculationDesk.css';

const CirculationDesk = () => {
    const [loanID, setLoanID] = useState('');
    const [fineInfo, setFineInfo] = useState(null); 
    const [overdueBooks, setOverdueBooks] = useState('');
    const [isLoading, setIsLoading] = useState(false); // Thêm trạng thái loading

    // B1: Kiểm tra phạt
    const checkFine = async () => {
        if (!loanID) {
            alert("Vui lòng nhập mã phiếu mượn!");
            return;
        }
        setIsLoading(true); // Bắt đầu loading
        try {
            const res = await fetch(`http://localhost:5000/api/loans/fine/${loanID}`);
            if (!res.ok) throw new Error(await res.text());
            const data = await res.json();

            if (data && data.FineAmount !== undefined) {
                setFineInfo({ amount: data.FineAmount, daysLate: data.DaysLate });
            }

            // Check thông tin User & Sách quá hạn
            const resLoan = await fetch(`http://localhost:5000/api/loan/${loanID}`);
            if (resLoan.ok) {
                const loanData = await resLoan.json();
                if (loanData.BorrowerID) {
                    const resOverdue = await fetch(`http://localhost:5000/api/user/overdue-books/${loanData.BorrowerID}`);
                    if (resOverdue.ok) {
                        const overdueData = await resOverdue.json();
                        setOverdueBooks(overdueData.OverdueBooks);
                    }
                }
            }
        } catch (err) {
            alert("Lỗi kiểm tra: " + err.message);
            setFineInfo(null);
        } finally {
            setIsLoading(false); // Kết thúc loading
        }
    };

    // B2: Thu tiền & Trả sách
    const handleReturn = async () => {
        if (!loanID) return;
        
        const amount = fineInfo ? fineInfo.amount : 0;
        if (!window.confirm(`Xác nhận thu ${amount.toLocaleString()} VND và hoàn tất trả sách?`)) {
            return;
        }

        setIsLoading(true);
        try {
            const res = await fetch(`http://localhost:5000/api/loans/return`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ loanID })
            });
            
            if (!res.ok) throw new Error(await res.text());

            alert(`✅ Giao dịch thành công!\n- Sách đã trả về kho.\n- Đã thu ${amount.toLocaleString()} VND.`);
            
            // Reset UI
            setFineInfo(null);
            setOverdueBooks('');
            setLoanID(''); 
            
        } catch (err) {
            alert("❌ Lỗi giao dịch: " + err.message);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="desk-container">
            <h2>📚 Quầy Lưu Hành</h2>
            
            <div className="input-group">
                <label>Mã Phiếu Mượn (Loan ID)</label>
                <input 
                    type="text" 
                    value={loanID} 
                    onChange={(e) => setLoanID(e.target.value)} 
                    placeholder="Ví dụ: L004"
                    onKeyPress={(e) => e.key === 'Enter' && checkFine()} // Cho phép nhấn Enter
                />
            </div>

            <button className="btn-check" onClick={checkFine} disabled={isLoading}>
                {isLoading ? "Đang xử lý..." : "🔍 Kiểm tra Thông Tin"}
            </button>

            {fineInfo !== null && (
                <div className="fine-box">
                    <div className="fine-header">
                        <h3>Hóa Đơn Thanh Toán</h3>
                        <span className={fineInfo.amount > 0 ? "amount-highlight" : "status-clean"}>
                            {fineInfo.amount > 0 ? "Chưa Thanh Toán" : "Hợp Lệ"}
                        </span>
                    </div>

                    <div className="fine-details">
                        <p>Số ngày quá hạn: <span>{fineInfo.daysLate > 0 ? fineInfo.daysLate : 0} ngày</span></p>
                        <p>Tổng tiền phạt: <span className="amount-highlight">{fineInfo.amount.toLocaleString()} VND</span></p>
                    </div>

                    {overdueBooks && overdueBooks !== 'Không có sách quá hạn.' && (
                        <div className="overdue-alert">
                            <strong>⚠️ Cảnh báo độc giả:</strong>
                            {overdueBooks}
                        </div>
                    )}
                    
                    <button className="btn-return" onClick={handleReturn} disabled={isLoading}>
                        {fineInfo.amount > 0 ? "💸 Thu Tiền & Trả Sách" : "✅ Xác Nhận Trả Sách"}
                    </button>
                </div>
            )}
        </div>
    );
};

export default CirculationDesk;