# Báo cáo bài tập: Xây dựng mô hình ngữ nghĩa cho chủ đề doanh nghiệp Việt Nam

## 1. Yêu cầu bài tập

Báo cáo thực hiện các yêu cầu mô hình hóa một phần chủ đề doanh nghiệp Việt Nam sử dụng các công nghệ web ngữ nghĩa (RDF, RDFS, OWL). Cụ thể bao gồm:
- Xác định ít nhất 3 quan hệ "subClassOf" và 3 quan hệ "subPropertyOf".
- Chọn một đối tượng đặc trưng đại diện cho mỗi lớp.
- Chọn một bộ ba dữ kiện minh họa cho mỗi thuộc tính.
- Biểu diễn bằng lời và vẽ đồ thị RDF trên một trang sơ đồ thống nhất.
- Viết mã nguồn bằng Turtle chia làm hai tệp: tệp định nghĩa khái niệm (schema) và tệp chứa dữ kiện (data), sử dụng không gian tên riêng.
- Tích hợp các ví dụ minh họa cấu trúc OWL bao gồm: "owl:intersectionOf", "owl:unionOf", "owl:Restriction" ("owl:onProperty", "owl:someValuesFrom", "owl:hasValue"), "owl:TransitiveProperty", "owl:FunctionalProperty", và "owl:SymmetricProperty".

---

## 2. Nội dung báo cáo

### 2.1. Mô tả mô hình bằng lời

Mô hình sử dụng không gian tên riêng của nhóm Cá Mập: "http://example.org/ca-map/". Không gian tên này được dùng để định danh các lớp, thuộc tính và đối tượng trong mô hình.

Lớp doanh nghiệp tổng quát là công ty. Ba lớp con cốt lõi kế thừa từ công ty là công ty cổ phần, công ty TNHH một thành viên, và công ty hợp danh.

Lớp con người hoặc tổ chức liên quan là thành viên. Hai lớp con kế thừa từ thành viên là cổ đông và thành viên hợp danh.

Thuộc tính tổng quát là "có thành viên" (miền xác định: "công ty", miền giá trị: "thành viên"), biểu diễn liên kết sở hữu doanh nghiệp. Ba thuộc tính con ("rdfs:subPropertyOf") kế thừa từ thuộc tính này là:
- "có cổ đông" (miền xác định: "công ty", miền giá trị: "cổ đông")
- "có chủ sở hữu" (miền xác định: "công ty", miền giá trị: "thành viên")
- "có thành viên hợp danh" (miền xác định: "công ty", miền giá trị: "thành viên hợp danh")

Để tạo sự liên kết và tính nhất quán cao, các lớp doanh nghiệp và lớp thành viên được định nghĩa thông qua các cấu trúc logic OWL:
- Lớp công ty cổ phần được định nghĩa là giao của lớp "công ty" và một ràng buộc thuộc tính: có ít nhất một thành viên thuộc lớp "cổ đông" (sử dụng "owl:intersectionOf" kết hợp "owl:someValuesFrom" trên thuộc tính "có cổ đông").
- Lớp công ty hợp danh tương đương với ràng buộc thuộc tính: có ít nhất một thành viên thuộc lớp "thành viên hợp danh" (sử dụng "owl:someValuesFrom" trên thuộc tính "có thành viên hợp danh").
- Lớp công ty TNHH một thành viên tương đương với ràng buộc thuộc tính: có chủ sở hữu là cá thể cố định "UBND TP. Hà Nội" (sử dụng "owl:hasValue" trên thuộc tính "có chủ sở hữu").
- Lớp thành viên được định nghĩa là hợp của hai lớp con "cổ đông" và "thành viên hợp danh" (sử dụng "owl:unionOf").

Dựa trên các ràng buộc này, bộ suy luận Jena sẽ tự động phân loại chính xác các đối tượng dựa trên các thuộc tính khai báo của chúng:
- Thực thể Vinamilk khai báo có cổ đông là "Tổng công ty SCIC" (thuộc lớp "cổ đông") sẽ tự động được suy luận thuộc lớp công ty cổ phần.
- Thực thể Đấu giá Lạc Việt khai báo có thành viên hợp danh là "Đỗ Thị Hồng Hải" sẽ tự động được suy luận thuộc lớp công ty hợp danh.
- Thực thể Hanoi Metro khai báo có chủ sở hữu là "UBND TP. Hà Nội" sẽ tự động được suy luận thuộc lớp công ty TNHH một thành viên.
- Các cá thể thành viên như "Tổng công ty SCIC" (cổ đông) và "Đỗ Thị Hồng Hải" (thành viên hợp danh) tự động được phân loại thuộc lớp cha thành viên nhờ quan hệ hợp "owl:unionOf".

Đồng thời, khi truy vấn qua thuộc tính cha "có thành viên", hệ thống cũng tự động suy luận ra toàn bộ danh sách thành viên của các công ty nhờ vào quan hệ phân cấp thuộc tính con "subPropertyOf".

### 2.2. Quan hệ lớp con (RDFS "subClassOf")

Các quan hệ phân cấp lớp được định nghĩa trong mô hình bao gồm:
- Lớp công ty cổ phần là subClassOf của lớp công ty.
- Lớp công ty TNHH một thành viên là subClassOf của lớp công ty.
- Lớp công ty hợp danh là subClassOf của lớp công ty.
- Lớp cổ đông là subClassOf của lớp thành viên.
- Lớp thành viên hợp danh là subClassOf của lớp thành viên.

### 2.3. Quan hệ thuộc tính con (RDFS "subPropertyOf")

Các quan hệ phân cấp thuộc tính được định nghĩa trong mô hình bao gồm:
- Thuộc tính "có cổ đông" là thuộc tính con của thuộc tính "có thành viên".
- Thuộc tính "có chủ sở hữu" là thuộc tính con của thuộc tính "có thành viên".
- Thuộc tính "có thành viên hợp danh" là thuộc tính con của thuộc tính "có thành viên".

### 2.4. Bộ ba minh họa cho từng thuộc tính

Các bộ ba dữ kiện minh họa trực tiếp cho từng thuộc tính gồm:
- Vinamilk - có cổ đông - Tổng công ty SCIC.
- Hanoi Metro - có chủ sở hữu - UBND TP. Hà Nội.
- Đấu giá Lạc Việt - có thành viên hợp danh - Đỗ Thị Hồng Hải.

### 2.5. Các cấu trúc OWL tích hợp

Báo cáo tích hợp các ví dụ minh họa cho các cấu trúc OWL cụ thể:

#### "owl:intersectionOf" và "owl:someValuesFrom"
Lớp công ty cổ phần được định nghĩa bằng giao của hai lớp: lớp công ty và một restriction chỉ định thuộc tính "có cổ đông" nhận giá trị từ lớp cổ đông. Nhờ vậy, thực thể Vinamilk tự động được phân loại thuộc lớp công ty cổ phần.

#### "owl:unionOf"
Lớp thành viên được định nghĩa là tập hợp của lớp cổ đông và lớp thành viên hợp danh. Các cá thể SCIC (cổ đông) và Đỗ Thị Hồng Hải (thành viên hợp danh) sẽ tự động được suy luận thuộc lớp thành viên.

#### "owl:hasValue"
Lớp công ty TNHH một thành viên tương đương với ràng buộc thuộc tính "có chủ sở hữu" nhận giá trị cố định là cá thể "UBND TP. Hà Nội". Nhờ vậy, thực thể Hanoi Metro tự động được phân loại thuộc lớp này.

#### "owl:TransitiveProperty"
Thuộc tính "có công ty mẹ" được khai báo là thuộc tính bắc cầu. Do "Mộc Châu Milk" có công ty mẹ là "VLC", và "VLC" có công ty mẹ là "Vinamilk", hệ suy diễn tự động suy luận ra "Mộc Châu Milk" có công ty mẹ là "Vinamilk".

#### "owl:FunctionalProperty"
Thuộc tính "mã số doanh nghiệp" được khai báo là thuộc tính hàm (đơn trị), đảm bảo mỗi doanh nghiệp chỉ liên kết với tối đa một mã số doanh nghiệp dạng chuỗi ký tự.

#### "owl:SymmetricProperty"
Thuộc tính "hợp tác với" được khai báo là thuộc tính đối xứng. Do thực thể "Vinamilk" hợp tác với "Đấu giá Lạc Việt", hệ suy luận tự động suy sau chiều ngược lại là "Đấu giá Lạc Việt" cũng hợp tác với "Vinamilk".

### 2.6. Các tệp dữ liệu nguồn

Mô hình ngữ nghĩa được tổ chức thành hai tệp văn bản định dạng Turtle:
- Tệp định nghĩa khái niệm (schema): "ca-map-schema.ttl" chứa khai báo các lớp, thuộc tính và ràng buộc logic OWL.
- Tệp dữ kiện cá thể (data): "ca-map-data.ttl" chứa thông tin về các cá thể và các bộ ba dữ kiện ban đầu.

### 2.7. Đồ thị RDF

Đồ thị RDF được vẽ và lưu trữ trong tệp "rdf.drawio", biểu diễn toàn bộ các lớp, thuộc tính, cá thể dữ liệu và các bộ ba minh họa trên một trang sơ đồ thống nhất. Sơ đồ tuân thủ quy tắc sử dụng hình elip cho tài nguyên (lớp, cá thể) và hình chữ nhật cho các hằng giá trị (literal). Các nút Restriction, nút Union (∪), và nút Intersection (∩) được vẽ dưới dạng các vòng tròn nét đứt để thể hiện cấu trúc logic OWL.

Để sơ đồ mạch lạc, dễ theo dõi và phản ánh đúng kết quả thực thi của hệ thống, các đường nối trực tiếp "rdf:type" đã được thêm vào để kết nối 3 thực thể công ty cụ thể (Vinamilk, Hanoi Metro, Đấu giá Lạc Việt) trực tiếp tới các lớp tương ứng của chúng (công ty cổ phần, công ty TNHH một thành viên, công ty hợp danh).
