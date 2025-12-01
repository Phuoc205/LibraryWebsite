import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import './header.css';

const Header = () => {
    const location = useLocation(); 

    return (
        <header className="header">
            <div className="header-left">
                <Link to="/" className="logo">
                    <img src="/Image/logolib.png" alt="BK Library" />
                    <span>BK Library</span>
                </Link>
            </div>

            <nav className="header-nav">
                <Link to="/" className={location.pathname === '/' ? 'active' : ''}>
                    Trang chủ
                </Link>
                {/* Đã sửa /search thành /catalog cho phù hợp với BookCatalog */}
                <Link to="/search" className={location.pathname === '/search' ? 'active' : ''}>
                    Tra cứu sách
                </Link>
                
                <Link to="/manage-books" className={location.pathname === '/manage-books' ? 'active' : ''}>
                    Quản lý sách (Nhập liệu)
                </Link>
                <Link to="/return" className={location.pathname === '/return' ? 'active' : ''}>
                    Quầy trả sách (Lưu hành)
                </Link>
                {/* ĐƯỜNG DẪN GIỎ HÀNG (MỚI) */}
                <Link to="/cart" className={location.pathname === '/cart' ? 'active' : ''}>
                    Giỏ hàng
                </Link>
            </nav>

            <div className="header-right">
                <button className="btn-login">Admin</button>
            </div>
        </header>
    );
};

export default Header;