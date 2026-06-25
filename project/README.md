# Luật Doanh nghiệp Việt Nam - RDF/OWL Fuseki Demo

## Mục tiêu

Dự án mô hình hóa một phần Luật Doanh nghiệp Việt Nam bằng RDF, RDFS và OWL. Apache Jena Fuseki được dùng để nạp mô hình và quan sát kết quả suy diễn bằng SPARQL.

## RDF, RDFS và OWL

- RDF biểu diễn tri thức bằng bộ ba chủ thể - thuộc tính - đối tượng.
- RDFS bổ sung lớp, lớp con, thuộc tính con, domain và range.
- OWL mở rộng khả năng mô hình hóa ontology với restriction, union, intersection và tính chất thuộc tính như bắc cầu, đối xứng, hàm.

OWL không thuộc RDFS. OWL được xây trên nền RDF/RDFS và dùng thêm từ vựng riêng để mô tả ontology mạnh hơn.

## Tệp chính

- `luat-doanh-nghiep-schema.ttl`: định nghĩa lớp, thuộc tính, RDFS và OWL.
- `luat-doanh-nghiep-data.ttl`: dữ kiện cá thể.
- `fuseki-config.ttl`: cấu hình dataset `/dataset` có suy diễn.
- `luat-doanh-nghiep.rules`: luật suy diễn Jena cho phần demo.
- `queries/`: các truy vấn SPARQL kiểm chứng.
- `rdf.drawio`: sơ đồ RDF của bài nộp.

## Chạy Fuseki và tự động nạp dữ liệu

Để khởi chạy Fuseki và tự động nạp cả schema và data trong một bước duy nhất, hãy chạy script tự động hóa:

```bash
./scripts/run-fuseki.sh
```

Hoặc thực hiện thủ công theo các bước dưới đây:

### Khởi chạy Fuseki thủ công

```bash
docker compose up -d
```

Mở giao diện Fuseki:

```text
http://localhost:3030/
```

Dataset:

```text
http://localhost:3030/dataset
```

### Nạp dữ liệu thủ công

Nạp schema:

```bash
curl -u admin:admin -X POST \
  -H "Content-Type: text/turtle; charset=utf-8" \
  --data-binary @luat-doanh-nghiep-schema.ttl \
  "http://localhost:3030/dataset/data"
```

Nạp data:

```bash
curl -u admin:admin -X POST \
  -H "Content-Type: text/turtle; charset=utf-8" \
  --data-binary @luat-doanh-nghiep-data.ttl \
  "http://localhost:3030/dataset/data"
```

Có thể nạp bằng giao diện Fuseki nếu lệnh `curl` không thuận tiện.

## Chạy truy vấn

Ví dụ:

```bash
curl -G "http://localhost:3030/dataset/query" \
  --data-urlencode query@queries/01-rdfs-subclass.rq
```

Thay tên file query để chạy các truy vấn còn lại:

```bash
queries/01-rdfs-subclass.rq
queries/02-rdfs-subproperty.rq
queries/03-owl-restrictions.rq
queries/04-owl-property-characteristics.rq
queries/05-owl-class-constructors.rq
```

## Kết quả mong đợi

### 1. RDFS subClassOf

`queries/01-rdfs-subclass.rq` trả về các cá thể được suy ra hoặc khai báo thuộc lớp `Công_ty`:

- `Vinamilk`
- `Hanoi_Metro`
- `Đấu_giá_Lạc_Việt`

Ví dụ: Mặc dù các lớp cụ thể của công ty được suy luận tự động từ OWL Restriction, các lớp này đều là lớp con của `Công_ty` (`rdfs:subClassOf`), giúp hệ thống tổ chức phân cấp rõ ràng.

### 2. RDFS subPropertyOf

`queries/02-rdfs-subproperty.rq` trả về các thành viên qua thuộc tính cha `có_thành_viên`.

Ví dụ: dữ kiện gốc có `Vinamilk có_cổ_đông Tổng_công_ty_SCIC`. Do `có_cổ_đông rdfs:subPropertyOf có_thành_viên`, hệ suy diễn trả thêm `Vinamilk có_thành_viên Tổng_công_ty_SCIC`.

### 3. OWL restrictions

`queries/03-owl-restrictions.rq` trả về các công ty được suy luận tự động thuộc lớp tương ứng với các ràng buộc `owl:someValuesFrom` và `owl:hasValue` (như `Công_ty_cổ_phần`, `Công_ty_hợp_danh`, `Công_ty_TNHH_một_thành_viên`, và `Công_ty_có_trụ_sở_tại_TP_HCM`).

### 4. OWL property characteristics

`queries/04-owl-property-characteristics.rq` trả về:

- `Vinamilk có_công_ty_mẹ Công_ty_mẹ_toàn_cầu`
- `Đấu_giá_Lạc_Việt hợp_tác_với Vinamilk`

Các kết quả này đến từ `owl:TransitiveProperty` và `owl:SymmetricProperty`.

### 5. OWL class constructors

`queries/05-owl-class-constructors.rq` trả về:

- Các công ty thuộc `Công_ty_có_tư_cách_pháp_nhân` nhờ `owl:unionOf`.
- `Vinamilk rdf:type Công_ty_cổ_phần_đại_chúng` nhờ `owl:intersectionOf`.

## Reset dữ liệu

Xóa dữ liệu Fuseki để chạy lại từ đầu:

```bash
docker compose down -v
```

Sau đó chạy lại `docker compose up -d` và nạp lại hai file Turtle.

## Ghi chú

- Nếu nạp dữ liệu nhiều lần, kết quả query có thể nhìn như bị lặp tùy hình dạng query.
- Nếu không thấy inferred triples, kiểm tra container đã mount đúng `fuseki-config.ttl` và `luat-doanh-nghiep.rules`.
- Sơ đồ dùng file `rdf.drawio`. Phần OWL được giải thích bằng lời trong `luat-doanh-nghiep-vn.md` và kiểm chứng bằng Fuseki/SPARQL.
