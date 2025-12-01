import React, { useState } from "react";

const BookManagement = () => {
    const currentYear = new Date().getFullYear();

    const [formData, setFormData] = useState({
        title: "",
        refBookID: "",
        publisher: "",
        year: currentYear,
        authorID: "",
        addNewAuthor: false,
        authorName: "",
        authorBio: ""
    });

    const handleChange = (e) => {
        const { name, value, type, checked } = e.target;
        setFormData({
            ...formData,
            [name]: type === "checkbox" ? checked : value
        });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        try {
            console.log("Sending:", formData);

            const response = await fetch("http://localhost:5000/api/insert/books", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(formData)
            });

            console.log("Status:", response.status);
            console.log("Headers:", response.headers.get("content-type"));

            if (response.headers.get("content-type")?.includes("application/json")) {
                const result = await response.json();
                console.log("JSON result:", result);

                if (!response.ok || result.error) {
                    alert("Lỗi khi thêm sách: " + (result.detail || result.error));
                    return;
                }

                alert(`Đã thêm sách thành công! Mã RecordID mới: ${result.id}`);
                setFormData({
                    title: "",
                    refBookID: "",
                    publisher: "",
                    year: currentYear,
                    authorID: "",
                    addNewAuthor: false,
                    authorName: "",
                    authorBio: ""
                });
            } 
            else {
                const text = await response.text();
                console.log("Raw text:", text);
                alert("Lỗi server: " + text);
            }

        } catch (err) {
            console.error(err);
            alert("Lỗi kết nối tới server!");
        }
    };


    return (
        <div style={{ padding: "20px", maxWidth: "600px", margin: "0 auto" }}>
            <h2>Quản lý Hồ sơ Sách</h2>

            <form onSubmit={handleSubmit} style={{ display: "flex", flexDirection: "column", gap: "15px" }}>
                
                {/* BOOK INFO */}
                <div>
                    <label>Tựa đề:</label>
                    <input
                        name="title"
                        value={formData.title}
                        onChange={handleChange}
                        required
                        style={{ width: "100%", padding: "8px" }}
                    />
                </div>

                <div>
                    <label>RefBookID (nếu có):</label>
                    <input
                        name="refBookID"
                        value={formData.refBookID}
                        onChange={handleChange}
                        style={{ width: "100%", padding: "8px" }}
                    />
                </div>

                <div>
                    <label>Nhà Xuất Bản:</label>
                    <input
                        name="publisher"
                        value={formData.publisher}
                        onChange={handleChange}
                        style={{ width: "100%", padding: "8px" }}
                    />
                </div>

                <div>
                    <label>Năm Xuất Bản:</label>
                    <input
                        type="number"
                        name="year"
                        value={formData.year}
                        onChange={handleChange}
                        style={{ width: "100%", padding: "8px" }}
                    />
                </div>

                {/* AUTHOR INFO */}
                <div style={{ marginTop: "15px" }}>
                    <label>Mã tác giả (AuthorID) (*):</label>
                    <input
                        name="authorID"
                        value={formData.authorID}
                        onChange={handleChange}
                        required
                        style={{ width: "100%", padding: "8px" }}
                    />
                </div>

                <label style={{ display: "flex", alignItems: "center", gap: "10px", cursor: "pointer" }}>
                    <input
                        type="checkbox"
                        name="addNewAuthor"
                        checked={formData.addNewAuthor}
                        onChange={handleChange}
                    />
                    Thêm tác giả mới?
                </label>

                {/* SHOW THIS ONLY IF addNewAuthor = true */}
                {formData.addNewAuthor && (
                    <div style={{ padding: "15px", border: "1px solid #ccc", borderRadius: "5px" }}>
                        <h3>Thông tin Tác giả mới</h3>

                        <div>
                            <label>Tên tác giả (*):</label>
                            <input
                                name="authorName"
                                value={formData.authorName}
                                onChange={handleChange}
                                required={formData.addNewAuthor}
                                style={{ width: "100%", padding: "8px" }}
                            />
                        </div>

                        <div>
                            <label>Tiểu sử (Bio):</label>
                            <textarea
                                name="authorBio"
                                value={formData.authorBio}
                                onChange={handleChange}
                                required={formData.addNewAuthor}
                                style={{ width: "100%", padding: "8px", height: "100px" }}
                            />
                        </div>
                    </div>
                )}

                <button
                    type="submit"
                    style={{ padding: "10px", backgroundColor: "#28a745", color: "white", border: "none", cursor: "pointer" }}
                >
                    Thêm Sách Mới
                </button>
            </form>
        </div>
    );
};

export default BookManagement;