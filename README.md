# Banking-Loan-Analytics
# **Phân Tích Dữ Liệu Vay Ngân Hàng - SQL Server**

## Tổng Quan Dự Án

Dự án này khám phá hành vi vay của khách hàng và xu hướng nhân khẩu học nhằm hiểu rõ các rủi ro, phân khúc khách hàng, và những yếu tố tiềm năng dự đoán khả năng vỡ nợ. Bộ dữ liệu cung cấp thông tin chi tiết về nhân khẩu học và tài chính như thu nhập, độ tuổi, quy mô gia đình và số tiền vay. Phân tích bao gồm xử lý dữ liệu, tạo đặc trưng, và truy vấn SQL cốt lõi để rút ra các hiểu biết phục vụ ra quyết định.

## Mục Lục

- [Giới thiệu](#giới-thiệu)
- [Bước 1: Nhập Dữ Liệu](#bước-1-nhập-dữ-liệu)
- [Bước 2: Khám Phá, Làm Sạch và Chuẩn Bị Dữ Liệu](#bước-2-khám-phá-làm-sạch-và-chuẩn-bị-dữ-liệu)
- [Bước 3: Truy Vấn Phân Tích](#bước-3-truy-vấn-phân-tích)
- [Bước 4: Kết Quả và Đánh Giá](#bước-4-kết-quả-và-đánh-giá)
- [Kết Luận](#kết-luận)
- [Cách Chạy](#cách-chạy)
- [Tài Liệu Tham Khảo](#tài-liệu-tham-khảo)

## Giới Thiệu

Phân tích SQL này đánh giá dữ liệu vay của khách hàng nhằm xác định các yếu tố quan trọng ảnh hưởng đến rủi ro tín dụng và nhân khẩu học. Bằng cách phân tích thông tin khoản vay và đặc điểm khách hàng, dự án cung cấp cái nhìn sâu sắc về hành vi người vay và các yếu tố dự đoán chính của kết quả khoản vay, hỗ trợ ra quyết định trong việc nhắm chọn khách hàng và đánh giá rủi ro.

---

## Bước 1: Nhập Dữ Liệu

**Cài Đặt Cơ Sở Dữ Liệu và Nhập Liệu**  
Để bắt đầu, hãy thiết lập một cơ sở dữ liệu tương thích với SQL (MySQL, SQLServer, v.v.) và tải các bộ dữ liệu có trong bảng `Bank_Personal_Loan_Modelling` và `Submission_Approval_Datetime.csv`.

---

## Bước 2: Khám Phá, Làm Sạch và Chuẩn Bị Dữ Liệu

### Khám Phá Dữ Liệu

Bộ dữ liệu bao gồm các đặc điểm chính sau:
Bộ dữ liệu này chứa thông tin của hơn 5.000 khách hàng. Dựa trên số điểm mà mỗi khách hàng đạt được, một khoản vay được đề xuất cho họ. Các đặc điểm (thuộc tính) trong bộ dữ liệu bao gồm:

- **Age**: Tuổi của khách hàng (tính theo số năm đã hoàn thành)

- **Experience**: Số năm kinh nghiệm làm việc chuyên môn

- **Income**: Thu nhập hàng năm của khách hàng

- **Zip code**: Mã vùng (Zip code) tại địa chỉ nhà của khách hàng

- **Family**: Quy mô gia đình của khách hàng

- **CCAvg**: Mức chi tiêu trung bình hàng tháng bằng thẻ tín dụng

- **Education**: Trình độ học vấn (Đại học = 1, Sau đại học = 2, Trình độ cao cấp = 3)

- **Mortgage**: Giá trị khoản vay thế chấp nhà (nếu có)

- **Personal_loan**: Khách hàng này có chấp nhận khoản vay cá nhân được đề nghị trong chiến dịch gần nhất không?

- **Security_account**: Khách hàng có tài khoản chứng khoán tại ngân hàng không?

- **Cd_account**: Khách hàng có tài khoản chứng chỉ tiền gửi (CD) tại ngân hàng không?

- **Online**: Khách hàng có sử dụng dịch vụ ngân hàng trực tuyến không?

- **Creditcard**: Khách hàng có sử dụng thẻ tín dụng do Universal Bank phát hành không?

Những thuộc tính này giúp làm sáng tỏ hành vi vay của khách hàng và cho phép phân khúc theo nhân khẩu học và đặc điểm khoản vay.

### Kiểm Tra Dữ Liệu Thiếu

Truy vấn ban đầu xác nhận không có giá trị thiếu trong các biến nhân khẩu học quan trọng, đảm bảo tính toàn vẹn dữ liệu.

### Loại Bỏ Bản Ghi Trùng Lặp

Kiểm tra ban đầu phát hiện các bản ghi trùng lặp theo mã khách hàng, và đã được loại bỏ để tránh sai lệch trong phân tích. Dữ liệu sau khi làm sạch đã sẵn sàng để phân tích.

### Phát Hiện Outliers

Các giá trị ngoại lai (ví dụ thu nhập hoặc số tiền vay quá cao) đã được xem xét và xử lý để tránh ảnh hưởng đến kết quả phân tích.

---

## Bước 3: Truy Vấn Phân Tích

1. **Phân Khúc Khách Hàng**: Phân khúc khách hàng theo đặc điểm nhân khẩu học như thu nhập và quy mô gia đình để xác định nhóm mục tiêu.
2. **Phê Duyệt Vay và Rủi Ro**: Truy vấn phân tích tỷ lệ phê duyệt và các khoản vay có rủi ro cao dựa trên đặc điểm khách hàng.
3. **Tỷ Lệ Thu Nhập / Khoản Vay**: Tỷ lệ này được tính toán để đánh giá khả năng chi trả và rủi ro của khách hàng.
4. **Dự Đoán Vỡ Nợ**: Xác định các yếu tố có thể dự đoán nguy cơ vỡ nợ dựa trên đặc điểm khách hàng.

---

## Bước 4: Kết Quả và Đánh Giá

### Các Chỉ Số Hiệu Suất Chính (KPIs)

- **Tỷ Lệ Phê Duyệt Vay**: Phần trăm khoản vay được phê duyệt phản ánh xu hướng chấp thuận chung.
- **Tỷ Lệ Vỡ Nợ**: Phần trăm các khoản vay bị vỡ nợ giúp đánh giá mức độ rủi ro.
- **Tỷ Lệ Thu Nhập / Khoản Vay**: Đánh giá khả năng chi trả của khách hàng.
- **Tỷ Lệ Khách Hàng Có Rủi Ro Cao**: Dựa trên các chỉ số nhân khẩu học.

### Kết Quả Phân Tích

1. **Phân Khúc Khách Hàng**: Các phân khúc chính theo độ tuổi, thu nhập, quy mô gia đình.
2. **Chỉ Báo Rủi Ro Cao**: Mô hình thu nhập và độ tuổi có mối liên hệ với khả năng vỡ nợ.
3. **Chất Lượng Dữ Liệu**: Dữ liệu được xác nhận không thiếu và không trùng lặp, đảm bảo độ chính xác.

---

## Kết Luận

### Những Phát Hiện Chính

- **Phân Khúc Khách Hàng**: Khách hàng chủ yếu được phân theo độ tuổi, thu nhập và quy mô gia đình.
- **Phê Duyệt Vay và Rủi Ro**: Chỉ có 9.6% người nộp đơn hiện đang có khoản vay cá nhân, với thu nhập trung bình của người được phê duyệt là 144.75K USD, so với 66.24K USD cho người không được phê duyệt.
- **Thông Tin Nhân Khẩu Học**: Độ tuổi trung bình của người được phê duyệt là 45.07 tuổi. Những người sử dụng thẻ tín dụng nhiều hơn (trung bình 3.91) có khả năng được phê duyệt cao hơn, cho thấy độ tuổi, thu nhập và thói quen sử dụng thẻ tín dụng là những yếu tố quan trọng trong phê duyệt khoản vay.
- **Xác Định Rủi Ro Cao**: Người sử dụng thẻ tín dụng ít hơn (trung bình 1.73 ở nhóm không được phê duyệt) có nguy cơ vỡ nợ cao hơn, cho thấy thẻ tín dụng là một yếu tố dự đoán hữu ích trong đánh giá rủi ro.
- **Hiệu Quả Hoạt Động**: Thời gian xử lý trung bình là 95.75 giờ, tối đa lên đến 168 giờ cho một khoản vay, cho thấy có thể tối ưu quy trình phê duyệt.

### Tóm Tắt Dành Cho Các Bên Liên Quan

**Chiến Lược Phê Duyệt Vay**  
Phân tích cho thấy chỉ 9.6% người nộp đơn nhận được khoản vay cá nhân, phản ánh một phân khúc thị trường hẹp nhưng có thể nhắm đến hiệu quả hơn. Những người được phê duyệt có thu nhập trung bình là 144.75K USD, cao hơn nhiều so với 66.24K USD của nhóm không được phê duyệt, cho thấy thu nhập là yếu tố then chốt. Thêm vào đó, thời gian xử lý trung bình là 95.75 giờ, có thể cải tiến để đẩy nhanh quy trình phê duyệt.

**Tiếp Thị Có Mục Tiêu và Phân Khúc Khách Hàng**  
90.4% người nộp đơn hiện chưa có khoản vay cá nhân, là một thị trường tiềm năng lớn. Bằng cách nhắm đến những người có tỷ lệ thu nhập/khoản vay cao, ngân hàng có thể tập trung vào những khách hàng có khả năng được phê duyệt cao hơn. Ví dụ, nhóm có thu nhập cao thường có tỷ lệ sử dụng thẻ tín dụng cao hơn (trung bình 3.91), cho thấy khả năng thanh toán tốt hơn.

**Tăng Cường Quản Lý Rủi Ro**  
Dữ liệu cho thấy nhóm có thu nhập cao và sử dụng thẻ tín dụng trung bình 3.91 ít có khả năng vỡ nợ hơn so với nhóm sử dụng thẻ ít hơn (trung bình 1.73). Tập trung vào nhóm khách hàng trong độ tuổi từ 23 đến 67, có hồ sơ phù hợp với đặc điểm này, có thể giúp giảm rủi ro và xây dựng các sản phẩm vay phù hợp hơn.

**Cải Tiến Sản Phẩm Vay Dựa Trên Xu Hướng Nhân Khẩu Học**  

## Cách Chạy

1. **Database Setup**: Import the `Bank_Personal_Loan_Modelling` and `Submission_Approval_Datetime.csv` datasets into your SQL environment.
2. **Run Queries**: Execute the queries in `Banking-Loan-Analytics-Script.sql` to perform the analysis.
3. **Analyze Results**: Use the KPIs and insights to interpret loan and customer patterns.

---

## Tài Liệu Tham Khảo

- [SQL Documentation](https://www.mysql.com/)
- [Bank Personal Loan Modelling Data](https://www.kaggle.com/code/pritech/bank-personal-loan-modelling)
