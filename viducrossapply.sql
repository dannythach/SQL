 
SELECT convert(nvarchar(500),N'Nguyễn Thảo') as ten into #sinhvien

INSERT INTO #sinhvien(ten)
VALUES(N'Hoàng Thị Thảo')

select convert(nvarchar(500),N'VB.NET') as mh into #monhoc

INSERT INTO #monhoc(mh)
VALUES(N'Word')
INSERT INTO #monhoc(mh)
VALUES(N'Excel')
INSERT INTO #monhoc(mh)
VALUES(N'C++')

select * from #sinhvien
select * from #monhoc

select * 
from #sinhvien as sv
	cross apply (select * from #monhoc) as monhoc

drop table #sinhvien,#monhoc














