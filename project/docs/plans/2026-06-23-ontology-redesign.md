# Tích hợp RDFS và OWL Luật Doanh nghiệp Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cấu trúc lại mô hình ontology Luật Doanh nghiệp Việt Nam để RDFS và OWL tích hợp chặt chẽ ("xuyên suốt"), đồng thời vẽ lại đồ thị draw.io và cập nhật dữ liệu để kiểm chứng bằng bộ suy luận Jena Fuseki.

**Architecture:** Sử dụng các lớp ràng buộc OWL ẩn danh (Restriction Classes) làm định nghĩa tương đương (`owl:equivalentClass`) cho các lớp cốt lõi (`Công_ty_cổ_phần`, `Công_ty_hợp_danh`, `Công_ty_TNHH_một_thành_viên`). Các cá thể trong dữ liệu sẽ không khai báo kiểu lớp cụ thể mà để bộ suy luận tự động phân loại.

**Tech Stack:** RDF/RDFS, OWL, SPARQL, Apache Jena Fuseki, Draw.io XML.

---

### Task 1: Cập nhật Schema OWL & RDFS

**Files:**
- Modify: `luat-doanh-nghiep-schema.ttl`

- [ ] **Step 1: Cập nhật định nghĩa thuộc tính và lớp mới trong schema**
  Thay thế nội dung tệp `luat-doanh-nghiep-schema.ttl` để bao gồm các thuộc tính mới (`phát_hành`, `có_thành_viên`, `có_chủ_sở_hữu`), các lớp đối tượng bổ trợ (`Cổ_phiếu`, `Thành_viên_hợp_danh`) và liên kết các lớp cốt lõi qua `owl:equivalentClass` với các restriction tương ứng.
  
  Nội dung mới của `luat-doanh-nghiep-schema.ttl`:
  ```turtle
  @base <http://example.org/luat-doanh-nghiep/> .
  @prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
  @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
  @prefix owl:  <http://www.w3.org/2002/07/owl#> .

  # --- Các Lớp Cốt Lõi ---
  <Công_ty> rdf:type rdfs:Class, owl:Class ;
      rdfs:label "Công ty"@vi ;
      rdfs:comment "Lớp gốc đại diện cho doanh nghiệp theo Luật Doanh nghiệp Việt Nam 2020."@vi .

  <Công_ty_cổ_phần> rdf:type rdfs:Class, owl:Class ;
      rdfs:subClassOf <Công_ty> ;
      rdfs:label "Công ty cổ phần"@vi ;
      rdfs:comment "Doanh nghiệp có vốn điều lệ chia thành cổ phần."@vi ;
      owl:equivalentClass [
          rdf:type owl:Restriction ;
          owl:onProperty <phát_hành> ;
          owl:someValuesFrom <Cổ_phiếu>
      ] .

  <Công_ty_TNHH_một_thành_viên> rdf:type rdfs:Class, owl:Class ;
      rdfs:subClassOf <Công_ty> ;
      rdfs:label "Công ty TNHH một thành viên"@vi ;
      rdfs:comment "Doanh nghiệp do một cá nhân hoặc một tổ chức làm chủ sở hữu."@vi ;
      owl:equivalentClass [
          rdf:type owl:Restriction ;
          owl:onProperty <có_chủ_sở_hữu> ;
          owl:hasValue <Chủ_sở_hữu_duy_nhất>
      ] .

  <Công_ty_hợp_danh> rdf:type rdfs:Class, owl:Class ;
      rdfs:subClassOf <Công_ty> ;
      rdfs:label "Công ty hợp danh"@vi ;
      rdfs:comment "Doanh nghiệp có ít nhất hai thành viên hợp danh."@vi ;
      owl:equivalentClass [
          rdf:type owl:Restriction ;
          owl:onProperty <có_thành_viên> ;
          owl:someValuesFrom <Thành_viên_hợp_danh>
      ] .

  # --- Các Lớp Hỗ trợ ---
  <Cổ_phiếu> rdf:type rdfs:Class, owl:Class ;
      rdfs:label "Cổ phiếu"@vi ;
      rdfs:comment "Cổ phần của Công ty cổ phần dưới dạng chứng chỉ."@vi .

  <Thành_viên_hợp_danh> rdf:type rdfs:Class, owl:Class ;
      rdfs:label "Thành viên hợp danh"@vi ;
      rdfs:comment "Thành viên chịu trách nhiệm vô hạn trong công ty hợp danh."@vi .

  <Tổ_chức_đại_chúng> rdf:type rdfs:Class, owl:Class ;
      rdfs:subClassOf <Công_ty> ;
      rdfs:label "Tổ chức đại chúng"@vi .

  <Tỉnh_thành> rdf:type rdfs:Class, owl:Class ;
      rdfs:label "Tỉnh thành"@vi .

  # --- Các Lớp Phức hợp (Union & Intersection) ---
  <Công_ty_cổ_phần_đại_chúng> rdf:type rdfs:Class, owl:Class ;
      rdfs:label "Công ty cổ phần đại chúng"@vi ;
      owl:equivalentClass [
          rdf:type owl:Class ;
          owl:intersectionOf ( <Công_ty_cổ_phần> <Tổ_chức_đại_chúng> )
      ] .

  <Công_ty_có_tư_cách_pháp_nhân> rdf:type rdfs:Class, owl:Class ;
      rdfs:label "Công ty có tư cách pháp nhân"@vi ;
      owl:equivalentClass [
          rdf:type owl:Class ;
          owl:unionOf (
              <Công_ty_cổ_phần>
              <Công_ty_TNHH_một_thành_viên>
              <Công_ty_hợp_danh>
          )
      ] .

  <Công_ty_có_trụ_sở_tại_TP_HCM> rdf:type rdfs:Class, owl:Class ;
      rdfs:label "Công ty có trụ sở tại TP. Hồ Chí Minh"@vi ;
      owl:equivalentClass [
          rdf:type owl:Restriction ;
          owl:onProperty <có_tỉnh_thành> ;
          owl:hasValue <TP_Hồ_Chí_Minh>
      ] .

  # --- Các Thuộc tính (Properties) ---
  <Giấy_chứng_nhận_đăng_ký_doanh_nghiệp> rdf:type rdf:Property ;
      rdfs:domain <Công_ty> ;
      rdfs:range rdfs:Literal ;
      rdfs:label "giấy chứng nhận đăng ký doanh nghiệp"@vi .

  <Tên_doanh_nghiệp> rdf:type rdf:Property ;
      rdfs:subPropertyOf <Giấy_chứng_nhận_đăng_ký_doanh_nghiệp> ;
      rdfs:domain <Công_ty> ;
      rdfs:range rdfs:Literal ;
      rdfs:label "tên doanh nghiệp"@vi .

  <Mã_số_doanh_nghiệp> rdf:type rdf:Property, owl:DatatypeProperty, owl:FunctionalProperty ;
      rdfs:subPropertyOf <Giấy_chứng_nhận_đăng_ký_doanh_nghiệp> ;
      rdfs:domain <Công_ty> ;
      rdfs:range rdfs:Literal ;
      rdfs:label "mã số doanh nghiệp"@vi .

  <Địa_chỉ_trụ_sở_chính> rdf:type rdf:Property ;
      rdfs:subPropertyOf <Giấy_chứng_nhận_đăng_ký_doanh_nghiệp> ;
      rdfs:domain <Công_ty> ;
      rdfs:range rdfs:Literal ;
      rdfs:label "địa chỉ trụ sở chính"@vi .

  # --- OWL Object Properties ---
  <phát_hành> rdf:type rdf:Property, owl:ObjectProperty ;
      rdfs:domain <Công_ty> ;
      rdfs:range <Cổ_phiếu> ;
      rdfs:label "phát hành"@vi .

  <có_thành_viên> rdf:type rdf:Property, owl:ObjectProperty ;
      rdfs:domain <Công_ty> ;
      rdfs:range <Thành_viên_hợp_danh> ;
      rdfs:label "có thành viên hợp danh"@vi .

  <có_chủ_sở_hữu> rdf:type rdf:Property, owl:ObjectProperty ;
      rdfs:domain <Công_ty> ;
      rdfs:label "có chủ sở hữu"@vi .

  <có_tỉnh_thành> rdf:type rdf:Property, owl:ObjectProperty ;
      rdfs:domain <Công_ty> ;
      rdfs:range <Tỉnh_thành> ;
      rdfs:label "có tỉnh thành"@vi .

  <có_công_ty_mẹ> rdf:type rdf:Property, owl:ObjectProperty, owl:TransitiveProperty ;
      rdfs:domain <Công_ty> ;
      rdfs:range <Công_ty> ;
      rdfs:label "có công ty mẹ"@vi .

  <hợp_tác_với> rdf:type rdf:Property, owl:ObjectProperty, owl:SymmetricProperty ;
      rdfs:domain <Công_ty> ;
      rdfs:range <Công_ty> ;
      rdfs:label "hợp tác với"@vi .
  ```

- [ ] **Step 2: Commit file Schema**
  ```bash
  git add luat-doanh-nghiep-schema.ttl
  git commit -m "schema: update RDFS and OWL definitions to strongly tie classes to restrictions"
  ```

---

### Task 2: Cập nhật Dữ liệu RDF (Data)

**Files:**
- Modify: `luat-doanh-nghiep-data.ttl`

- [ ] **Step 1: Cập nhật dữ liệu cá thể loại bỏ định nghĩa lớp thủ công**
  Thay đổi tệp `luat-doanh-nghiep-data.ttl` để chỉ khai báo các cá thể có lớp là `Công_ty`, kết hợp các thuộc tính tương ứng để kích hoạt suy luận.

  Nội dung mới của `luat-doanh-nghiep-data.ttl`:
  ```turtle
  @base <http://example.org/luat-doanh-nghiep/> .
  @prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .

  # Các cá thể hỗ trợ
  <Cổ_phiếu_Vinamilk> rdf:type <Cổ_phiếu> .
  <Nguyễn_Văn_A> rdf:type <Thành_viên_hợp_danh> .
  <TP_Hồ_Chí_Minh> rdf:type <Tỉnh_thành> .
  <Chủ_sở_hữu_duy_nhất> . # Cá thể đặc trưng

  # Vinamilk (Sẽ được suy luận là Công_ty_cổ_phần)
  <Vinamilk> rdf:type <Công_ty>, <Tổ_chức_đại_chúng> ;
      <Tên_doanh_nghiệp> "Công ty Cổ phần Sữa Việt Nam"@vi ;
      <phát_hành> <Cổ_phiếu_Vinamilk> ;
      <có_tỉnh_thành> <TP_Hồ_Chí_Minh> ;
      <có_công_ty_mẹ> <Tập_đoàn_Vingroup> ;
      <hợp_tác_với> <Deloitte_Việt_Nam> .

  # Samsung Việt Nam (Sẽ được suy luận là Công_ty_TNHH_một_thành_viên)
  <Samsung_Việt_Nam> rdf:type <Công_ty> ;
      <Mã_số_doanh_nghiệp> "2300325764" ;
      <có_chủ_sở_hữu> <Chủ_sở_hữu_duy_nhất> .

  # Deloitte Việt Nam (Sẽ được suy luận là Công_ty_hợp_danh)
  <Deloitte_Việt_Nam> rdf:type <Công_ty> ;
      <Địa_chỉ_trụ_sở_chính> "15 Đoàn Văn Bơ, Quận 4, TP. Hồ Chí Minh"@vi ;
      <có_thành_viên> <Nguyễn_Văn_A> .

  # Quan hệ công ty mẹ để test TransitiveProperty
  <Tập_đoàn_Vingroup> rdf:type <Công_ty> ;
      <Tên_doanh_nghiệp> "Tập đoàn Vingroup"@vi ;
      <có_công_ty_mẹ> <Công_ty_mẹ_toàn_cầu> .

  <Công_ty_mẹ_toàn_cầu> rdf:type <Công_ty> ;
      <Tên_doanh_nghiệp> "Công ty mẹ toàn cầu"@vi .
  ```

- [ ] **Step 2: Commit file Data**
  ```bash
  git add luat-doanh-nghiep-data.ttl
  git commit -m "data: update individual definitions to rely on OWL properties for class inference"
  ```

---

### Task 3: Cập nhật các câu truy vấn SPARQL

**Files:**
- Modify: `queries/03-owl-restrictions.rq`

- [ ] **Step 1: Cập nhật câu truy vấn kiểm tra Restriction**
  Chỉnh sửa `queries/03-owl-restrictions.rq` để truy vấn trực tiếp các lớp cốt lõi được suy luận từ Restriction (`Công_ty_cổ_phần`, `Công_ty_hợp_danh`, `Công_ty_TNHH_một_thành_viên`).

  Nội dung mới của `queries/03-owl-restrictions.rq`:
  ```sparql
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
  PREFIX : <http://example.org/luat-doanh-nghiep/>

  SELECT ?company ?inferredClass
  WHERE {
    VALUES ?inferredClass {
      :Công_ty_cổ_phần
      :Công_ty_hợp_danh
      :Công_ty_TNHH_một_thành_viên
      :Công_ty_có_trụ_sở_tại_TP_HCM
    }
    ?company rdf:type ?inferredClass .
  }
  ORDER BY ?company ?inferredClass
  ```

- [ ] **Step 2: Commit file Query**
  ```bash
  git add queries/03-owl-restrictions.rq
  git commit -m "queries: update restriction query to check core inferred classes"
  ```

---

### Task 4: Khởi chạy Fuseki và Kiểm tra Suy luận

- [ ] **Step 1: Reset và khởi động Fuseki**
  Khởi động môi trường bằng Docker Compose:
  ```bash
  docker compose down -v && docker compose up -d
  ```

- [ ] **Step 2: Nạp schema và data mới**
  Nạp schema mới:
  ```bash
  curl -u admin:admin -X POST -H "Content-Type: text/turtle; charset=utf-8" --data-binary @luat-doanh-nghiep-schema.ttl "http://localhost:3030/dataset/data"
  ```
  Nạp data mới:
  ```bash
  curl -u admin:admin -X POST -H "Content-Type: text/turtle; charset=utf-8" --data-binary @luat-doanh-nghiep-data.ttl "http://localhost:3030/dataset/data"
  ```

- [ ] **Step 3: Chạy thử các truy vấn kiểm tra suy luận**
  - Chạy `queries/01-rdfs-subclass.rq` -> Trả về cả 3 công ty.
  - Chạy `queries/03-owl-restrictions.rq` -> Trả về:
    * `Vinamilk` có kiểu `Công_ty_cổ_phần` và `Công_ty_có_trụ_sở_tại_TP_HCM`
    * `Deloitte_Việt_Nam` có kiểu `Công_ty_hợp_danh`
    * `Samsung_Việt_Nam` có kiểu `Công_ty_TNHH_một_thành_viên`
  - Chạy `queries/05-owl-class-constructors.rq` -> Trả về cả 3 công ty thuộc `Công_ty_có_tư_cách_pháp_nhân`, và `Vinamilk` thuộc `Công_ty_cổ_phần_đại_chúng`.
  
  Lệnh chạy thử:
  ```bash
  curl -G "http://localhost:3030/dataset/query" --data-urlencode query@queries/03-owl-restrictions.rq
  ```

---

### Task 5: Cập nhật tài liệu thuyết minh và Đồ thị Draw.io

**Files:**
- Modify: `luat-doanh-nghiep-vn.md`
- Create/Modify: `rdf.drawio`

- [ ] **Step 1: Viết lại thuyết minh trong luat-doanh-nghiep-vn.md**
  Cập nhật mục mô tả OWL để phản ánh đúng cấu trúc liên kết mới và cơ chế suy luận.
  
  Đoạn thay đổi chính ở Mục 5:
  ```markdown
  #### owl:Restriction với owl:onProperty và owl:someValuesFrom
  - `Công_ty_cổ_phần` tương đương với ràng buộc trên thuộc tính `phát_hành` trỏ tới một số cá thể lớp `Cổ_phiếu`.
  - `Công_ty_hợp_danh` tương đương với ràng buộc trên thuộc tính `có_thành_viên` trỏ tới một số cá thể lớp `Thành_viên_hợp_danh`.

  #### owl:Restriction với owl:onProperty và owl:hasValue
  - `Công_ty_TNHH_một_thành_viên` tương đương với ràng buộc trên thuộc tính `có_chủ_sở_hữu` trỏ tới cá thể `Chủ_sở_hữu_duy_nhất`.
  - `Công_ty_có_trụ_sở_tại_TP_HCM` tương đương với ràng buộc trên thuộc tính `có_tỉnh_thành` trỏ tới cá thể `TP_Hồ_Chí_Minh`.
  ```

- [ ] **Step 2: Cập nhật đồ thị vẽ rdf.drawio**
  Vẽ lại sơ đồ hoàn chỉnh thể hiện RDFS và các OWL Restriction classes ẩn danh kết nối trực tiếp với 3 lớp cốt lõi, cùng các cá thể dữ liệu được suy luận. Dùng draw.io XML để xuất đè lên `rdf.drawio`.

- [ ] **Step 3: Commit tài liệu và đồ thị**
  ```bash
  git add luat-doanh-nghiep-vn.md rdf.drawio
  git commit -m "docs: rewrite enterprise law explanation and update draw.io diagram"
  ```
