import React, { useState, useEffect } from "react";

// Tạm thời định nghĩa Icons cần thiết cho CartContain
const Icons = {
    Trash: () => (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
    ),
    Cart: () => (
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path></svg>
    ),
    Check: () => (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
    )
};

const CartContain = () => {
    // Tạm thời hardcode UserID (Sinh viên 2: Hoàng) và HandlerID (Thủ thư 2: Lê)
    const USER_ID = 'U0000005'; 
    const HANDLER_ID = 'U0000003';

    const [cartItems, setCartItems] = useState([]);
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState("");

    const fetchCart = async () => {
        setLoading(true);
        setMessage("");
        try {
            const response = await fetch(`http://localhost:5000/api/cart/${USER_ID}`);
            const data = await response.json();
            
            if (data.message) {
                setMessage(data.message);
                setCartItems([]);
            } else {
                setCartItems(data.books || []);
            }
        } catch (err) {
            setMessage("Lỗi kết nối hoặc server.");
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchCart();
    }, []);

    const handleRemove = async (bookID) => {
        if (!window.confirm(`Xóa sách có mã ${bookID} khỏi giỏ hàng?`)) return;

        try {
            const response = await fetch("http://localhost:5000/api/cart/remove", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ userID: USER_ID, bookID })
            });

            if (!response.ok) throw new Error("Lỗi xóa sách.");
            
            alert(`Đã xóa sách ${bookID} khỏi giỏ hàng.`);
            fetchCart(); 
        } catch (err) {
            alert(err.message);
            console.error(err);
        }
    };

    const handleCheckout = async () => {
        if (cartItems.length === 0) {
            alert("Giỏ hàng rỗng, không thể thanh toán.");
            return;
        }

        if (!window.confirm(`Xác nhận thanh toán ${cartItems.length} cuốn sách?`)) return;

        try {
            const response = await fetch("http://localhost:5000/api/cart/checkout", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ borrowerID: USER_ID, handlerID: HANDLER_ID })
            });

            const result = await response.json();
            
            if (!response.ok || result.error) {
                alert("Lỗi Thanh toán: " + (result.detail || result.error));
                return;
            }
            
            alert("Thanh toán thành công! Đã tạo phiếu mượn.");
            fetchCart(); 

        } catch (err) {
            console.error(err);
            alert("Lỗi kết nối tới server khi thanh toán.");
        }
    };

    return (
        <div className="cart-container" style={cartStyles.container}>
            <h2 style={cartStyles.header}>
                <Icons.Cart /> Giỏ Hàng Mượn Sách (User: {USER_ID})
            </h2>

            <div style={cartStyles.content}>
                {loading ? (
                    <p style={{ textAlign: 'center' }}>Đang tải...</p>
                ) : cartItems.length === 0 ? (
                    <p style={cartStyles.emptyMessage}>{message || "Giỏ hàng hiện đang trống."}</p>
                ) : (
                    <>
                        <div style={cartStyles.list}>
                            {cartItems.map((item, index) => (
                                <div key={index} style={cartStyles.item}>
                                    <div style={cartStyles.itemDetails}>
                                        <div style={cartStyles.itemTitle}>
                                            {item.Title} 
                                            <span style={cartStyles.bookID}> - Mã bản sao: {item.BookID}</span>
                                        </div>
                                        <div style={cartStyles.itemMeta}>
                                            Tác giả: {item.AuthorName || '---'} | CN: {item.BranchName}
                                        </div>
                                        <div style={cartStyles.itemMeta}>
                                            <span style={cartStyles.statusBadge}>
                                                Trạng thái: {item.BookStatus}
                                            </span>
                                        </div>
                                    </div>
                                    <button 
                                        onClick={() => handleRemove(item.BookID)} 
                                        style={cartStyles.removeButton}
                                        title="Xóa khỏi giỏ"
                                    >
                                        <Icons.Trash />
                                    </button>
                                </div>
                            ))}
                        </div>

                        <div style={cartStyles.summary}>
                            <p style={{ fontWeight: '600', fontSize: '1.1em' }}>Tổng cộng: {cartItems.length} cuốn sách</p>
                            <p style={{ fontSize: '0.9em', color: '#6c757d' }}>Giới hạn mượn: 3 cuốn/lần</p>
                            <button 
                                onClick={handleCheckout} 
                                style={cartStyles.checkoutButton}
                                disabled={cartItems.length === 0}
                            >
                                <Icons.Check /> Xác nhận Mượn ({cartItems.length})
                            </button>
                        </div>
                    </>
                )}
            </div>
        </div>
    );
};

// CSS inline đơn giản cho Component Giỏ hàng
const cartStyles = {
    container: {
        maxWidth: '800px',
        margin: '30px auto',
        padding: '30px',
        backgroundColor: '#ffffff',
        borderRadius: '12px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
        fontFamily: 'Segoe UI, sans-serif'
    },
    header: {
        display: 'flex',
        alignItems: 'center',
        gap: '10px',
        color: '#0056b3',
        borderBottom: '2px solid #e9ecef',
        paddingBottom: '15px',
        marginBottom: '20px'
    },
    list: {
        display: 'flex',
        flexDirection: 'column',
        gap: '15px',
    },
    item: {
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: '15px',
        border: '1px solid #dee2e6',
        borderRadius: '8px',
        backgroundColor: '#f8f9fa',
    },
    itemDetails: {
        flex: 1,
    },
    itemTitle: {
        fontWeight: 'bold',
        fontSize: '1.1em',
        color: '#212529',
    },
    bookID: {
        fontWeight: 'normal',
        fontSize: '0.85em',
        color: '#6c757d',
        marginLeft: '10px'
    },
    itemMeta: {
        fontSize: '0.9em',
        color: '#495057',
        marginTop: '5px'
    },
    statusBadge: {
        backgroundColor: 'rgba(0, 123, 255, 0.1)',
        color: '#007bff',
        padding: '3px 8px',
        borderRadius: '4px',
        fontSize: '0.8em',
        fontWeight: '600'
    },
    removeButton: {
        backgroundColor: '#dc3545',
        color: 'white',
        border: 'none',
        padding: '8px 12px',
        borderRadius: '6px',
        cursor: 'pointer',
        transition: 'background-color 0.2s',
        display: 'flex',
        alignItems: 'center'
    },
    summary: {
        marginTop: '30px',
        paddingTop: '20px',
        borderTop: '1px dashed #ced4da',
        textAlign: 'right'
    },
    checkoutButton: {
        marginTop: '15px',
        padding: '12px 25px',
        backgroundColor: '#28a745',
        color: 'white',
        border: 'none',
        borderRadius: '8px',
        cursor: 'pointer',
        fontWeight: '600',
        fontSize: '1.1em',
        display: 'inline-flex',
        alignItems: 'center',
        gap: '8px',
        transition: 'background-color 0.2s'
    },
    emptyMessage: {
        textAlign: 'center',
        padding: '40px',
        color: '#6c757d',
        fontSize: '1.1em'
    }
};

export default CartContain;