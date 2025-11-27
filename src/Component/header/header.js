import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import './header.css';

const Header = () => {
    const location = useLocation(); // Dùng để highlight menu đang chọn

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
                <Link to="/search" className={location.pathname === '/search' ? 'active' : ''}>
                    Tra cứu sách
                </Link>
                <div className="dropdown">
                    <span className="dropdown-title">Thủ thư ▼</span>
                    <div className="dropdown-menu">
                        <Link to="/manage">Quản lý sách (Nhập liệu)</Link>
                        <Link to="/return">Quầy trả sách (Lưu hành)</Link>
                    </div>
                </div>
            </nav>

            <div className="header-right">
                <button className="btn-login">Đăng nhập</button>
            </div>
        </header>
    );
};

export default Header;