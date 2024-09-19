--hàm lead dùng để trả về giá trị của dòng tiếp theo
--LEAD(column_name, offset, default_value) OVER (PARTITION BY partition_column ORDER BY order_column)
--column_name: Là tên cột mà bạn muốn truy xuất giá trị của hàng kế tiếp.
--offset: Là số nguyên xác định số hàng bạn muốn bỏ qua để truy xuất giá trị. Mặc định là 1, nếu bạn không xác định.
--default_value: Là giá trị mặc định sẽ được trả về nếu không có hàng kế tiếp. Điều này là tùy chọn.
--PARTITION BY partition_column: Là mệnh đề tùy chọn cho phép bạn chia dữ liệu thành các phần nhỏ (partitions) dựa trên giá trị của một cột. LEAD sẽ tính toán hàng kế tiếp riêng lẻ cho mỗi partition.
--ORDER BY order_column: Xác định thứ tự sắp xếp cho việc lấy hàng kế tiếp.

select LEAD(LoaiPhieu, 1, 0) OVER (ORDER BY ngaylp desc) AS loaiphieuketiep,*	
from [DM_LOTDATE]
where month(ngaylp)=8
order by ngaylp desc
















