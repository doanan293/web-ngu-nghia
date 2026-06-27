# Spec thiết kế: Tích hợp chặt chẽ RDFS và OWL - chủ đề doanh nghiệp Việt Nam

Tài liệu này đặc tả thiết kế cấu trúc lại mô hình ontology chủ đề doanh nghiệp nhằm tạo sự liên kết chặt chẽ ("xuyên suốt") giữa RDFS và OWL. Các lớp doanh nghiệp cốt lõi được định nghĩa và ràng buộc trực tiếp bởi các thuộc tính OWL ẩn danh (Restriction Classes), tương tự như mô hình mẫu của thế giới động vật.

---

## 1. Kiến trúc Schema mới (RDFS & OWL)

### 1.1. Các Lớp Cốt Lõi (Classes)
- **`Công_ty`**: Lớp cha chung đại diện cho các doanh nghiệp.
- **`Công_ty_cổ_phần`**: Lớp con của `Công_ty`.
- **`Công_ty_TNHH_một_thành_viên`**: Lớp con của `Công_ty`.
- **`Công_ty_hợp_danh`**: Lớp con của `Công_ty`.
- **`Thành_viên`**: Lớp đại diện chung cho các thành viên/chủ sở hữu.
- **`Cổ_đông`**: Lớp con của `Thành_viên`.
- **`Thành_viên_hợp_danh`**: Lớp con của `Thành_viên`.
- **`Tổ_chức_đại_chúng`**: Lớp phụ trợ đại diện cho các tổ chức đại chúng.

### 1.2. Các Thuộc tính (Properties)
- **`có_thành_viên`** (ObjectProperty):
  - Domain: `Công_ty`
  - Range: `Thành_viên`
- **`có_cổ_đông`** (ObjectProperty, subPropertyOf `có_thành_viên`):
  - Domain: `Công_ty`
  - Range: `Cổ_đông`
- **`có_chủ_sở_hữu`** (ObjectProperty, subPropertyOf `có_thành_viên`):
  - Domain: `Công_ty`
- **`có_thành_viên_hợp_danh`** (ObjectProperty, subPropertyOf `có_thành_viên`):
  - Domain: `Công_ty`
  - Range: `Thành_viên_hợp_danh`

### 1.3. Các Ràng buộc OWL gắn kết trực tiếp (Equivalent Classes)
Các lớp RDFS cốt lõi được định nghĩa tương đương (`owl:equivalentClass`) với các lớp ràng buộc ẩn danh:
1. **`Công_ty_cổ_phần`** tương đương với ràng buộc:
   - `owl:onProperty`: `có_cổ_đông`
   - `owl:someValuesFrom`: `Cổ_đông`
2. **`Công_ty_hợp_danh`** tương đương với ràng buộc:
   - `owl:onProperty`: `có_thành_viên_hợp_danh`
   - `owl:someValuesFrom`: `Thành_viên_hợp_danh`
3. **`Công_ty_TNHH_một_thành_viên`** tương đương với ràng buộc:
   - `owl:onProperty`: `có_chủ_sở_hữu`
   - `owl:hasValue`: `UBND_TP_Hà_Nội` (Cá thể)

---

## 2. Thiết kế Dữ liệu mẫu (Data) và Suy luận (Reasoning)

Trong tệp `ca-map-data.ttl`, các doanh nghiệp sẽ không được gán trực tiếp kiểu lớp cụ thể mà kiểu lớp sẽ được tự động suy ra bởi bộ suy luận Jena:

### 2.1. Đối tượng bổ trợ
- `Tổng_công_ty_SCIC` rdf:type `Cổ_đông`
- `Đỗ_Thị_Hồng_Hải` rdf:type `Thành_viên_hợp_danh`
- `UBND_TP_Hà_Nội` (Cá thể đại diện cho chủ sở hữu duy nhất)

### 2.2. Khai báo thuộc tính cho cá thể doanh nghiệp
- `Vinamilk` rdf:type `Công_ty`
  - `có_cổ_đông` `Tổng_công_ty_SCIC`
  - *Kết quả suy luận*: `Vinamilk` rdf:type `Công_ty_cổ_phần`
- `Đấu_giá_Lạc_Việt` rdf:type `Công_ty`
  - `có_thành_viên_hợp_danh` `Đỗ_Thị_Hồng_Hải`
  - *Kết quả suy luận*: `Đấu_giá_Lạc_Việt` rdf:type `Công_ty_hợp_danh`
- `Hanoi_Metro` rdf:type `Công_ty`
  - `có_chủ_sở_hữu` `UBND_TP_Hà_Nội`
  - *Kết quả suy luận*: `Hanoi_Metro` rdf:type `Công_ty_TNHH_một_thành_viên`

---

## 3. Thiết kế Đồ thị trực quan (`rdf.drawio`)

Đồ thị drawio mới sẽ biểu diễn trực quan cấu trúc liên kết chặt chẽ này:

```mermaid
classDiagram
    direction TB
    class Công_ty {
    }
    class Công_ty_cổ_phần {
    }
    class Công_ty_TNHH_một_thành_viên {
    }
    class Công_ty_hợp_danh {
    }
    class Cổ_đông {
    }
    class Thành_viên_hợp_danh {
    }
    
    Công_ty_cổ_phần --|> Công_ty : rdfs:subClassOf
    Công_ty_TNHH_một_thành_viên --|> Công_ty : rdfs:subClassOf
    Công_ty_hợp_danh --|> Công_ty : rdfs:subClassOf
    
    class Restriction_CP["Restriction (có_cổ_đông some Cổ_đông)"] {
    }
    class Restriction_HD["Restriction (có_thành_viên_hợp_danh some Thành_viên_hợp_danh)"] {
    }
    class Restriction_TNHH["Restriction (có_chủ_sở_hữu hasValue UBND_TP_Hà_Nội)"] {
    }
    
    Công_ty_cổ_phần ..> Restriction_CP : owl:equivalentClass
    Công_ty_hợp_danh ..> Restriction_HD : owl:equivalentClass
    Công_ty_TNHH_một_thành_viên ..> Restriction_TNHH : owl:equivalentClass
```

Trong tệp `rdf.drawio` mới:
- Các lớp RDFS thông thường vẽ bằng hình Elip viền đen nền trắng.
- Các lớp ẩn danh (OWL Restriction) vẽ bằng hình Elip đứt nét hoặc ký hiệu đặc thù chứa thông tin restriction.
- Các thuộc tính OWL (`có_thành_viên`, `có_cổ_đông`, `có_chủ_sở_hữu`, `có_thành_viên_hợp_danh`) vẽ dưới dạng các mũi tên kết nối.
- Các cá thể dữ liệu được liên kết tới các lớp suy luận tương ứng bằng các nét đứt.

---

## 4. Kế hoạch Thực hiện
1. Cập nhật `ca-map-schema.ttl`.
2. Cập nhật `ca-map-data.ttl`.
3. Viết lại tài liệu tổng quan `chu-de-doanh-nghiep-vn.md`.
4. Tạo tệp vẽ đồ thị mới `rdf.drawio` chứa đầy đủ sơ đồ tích hợp.
5. Kiểm tra chạy thử bộ suy luận Apache Jena / Fuseki để xác nhận các cá thể được suy luận tự động đúng kiểu lớp.
