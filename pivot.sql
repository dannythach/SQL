select convert(date,N'2023-05-01') as ngaycong, convert(nvarchar(100),N'Nguyễn Văn A') as nhanvien, convert(float,N'7.5') as giocong, convert(nvarchar(100),null) as loainghi
into #tam

--insert into #tam values(convert(date,N'2023-05-02'),convert(nvarchar(100),N'Nguyễn Văn A'),convert(float,N'8'),convert(nvarchar(100),null))
insert into #tam values(convert(date,N'2023-05-03'),convert(nvarchar(100),N'Nguyễn Văn A'),convert(float,N''),convert(nvarchar(100),null))
insert into #tam values(convert(date,N'2023-05-04'),convert(nvarchar(100),N'Nguyễn Văn A'),convert(float,N'8'),convert(nvarchar(100),null))
insert into #tam values(convert(date,N'2023-05-05'),convert(nvarchar(100),N'Nguyễn Văn A'),convert(float,N'9'),convert(nvarchar(100),null))
--insert into #tam values(convert(date,N'2023-05-01'),convert(nvarchar(100),N'Nguyễn Văn B'),convert(float,N''),convert(nvarchar(100),N'PN'))
--insert into #tam values(convert(date,N'2023-05-02'),convert(nvarchar(100),N'Nguyễn Văn B'),convert(float,N'8'),convert(nvarchar(100),null))
--insert into #tam values(convert(date,N'2023-05-03'),convert(nvarchar(100),N'Nguyễn Văn B'),convert(float,N'7'),convert(nvarchar(100),null))

select *,sum(giocong) over (order by ngaycong) AS next_day into #tam2 from #tam
select * from #tam2

--select count(*) from #tam group by nhanvien,loainghi having loainghi is not null

;WITH AllDates AS (
  SELECT CONVERT(DATE,'2023-05-01') as ngaycong, convert(nvarchar(100),null) as nhanvien, convert(float,N'7.5') as giocong,convert(nvarchar(100),null) as loainghi, convert(float,0) as next_day
  UNION ALL
  SELECT CONVERT(DATE,'2023-05-02') as ngaycong, convert(nvarchar(100),null) as nhanvien, convert(float,N'7.5') as giocong,convert(nvarchar(100),null) as loainghi, convert(float,0) as next_day 
  UNION ALL
  SELECT CONVERT(DATE,'2023-05-03') as ngaycong, convert(nvarchar(100),null) as nhanvien, convert(float,N'7.5') as giocong,convert(nvarchar(100),null) as loainghi, convert(float,0) as next_day 
  UNION ALL
  SELECT CONVERT(DATE,'2023-05-04') as ngaycong, convert(nvarchar(100),null) as nhanvien, convert(float,N'7.5') as giocong,convert(nvarchar(100),null) as loainghi, convert(float,0) as next_day 
  UNION ALL
  SELECT CONVERT(DATE,'2023-05-05') as ngaycong, convert(nvarchar(100),null) as nhanvien, convert(float,N'7.5') as giocong,convert(nvarchar(100),null) as loainghi, convert(float,0) as next_day
)

SELECT *
	  --COALESCE(t2.next_day, 0) AS next_day,
	  --SUM(COALESCE(t2.next_day, 0)) OVER (ORDER BY al.ngaycong) AS CumulativeSales
	  into #temp3
FROM AllDates union select * from #tam2 
--al
--	left join #tam2 t2 on al.ngaycong = t2.ngaycong
--ORDER BY AllDates.ngaycong

select * from #temp3
drop table #tam,#tam2,#temp3

SELECT *
FROM
(
  SELECT day(ngaycong) as nc,nhanvien
		,CumulativeSales
		--,giocong
		--,LEAD (giocong,1) OVER (ORDER BY ngaycong desc) AS next_day
  FROM #temp3
) AS SourceTable
PIVOT
(
  max(CumulativeSales)
  FOR nc IN ([1], [2],[3],[4],[5])
) AS PivotTable


drop table #tam,#tam2,#temp3


---------------------------------------------hàm lead

select convert(int,N'45') as dept_id, convert(float,N'54000') as salary, convert(nvarchar(100),N'Sutherland') as last_name
into #tam

insert into #tam values(convert(int,N'45'), convert(float,N'80000'), convert(nvarchar(100),N'Yates'))
insert into #tam values(convert(int,N'45'), convert(float,N'42000'), convert(nvarchar(100),N'Erickson'))
insert into #tam values(convert(int,N'30'), convert(float,N'57500'), convert(nvarchar(100),N'Parker'))
insert into #tam values(convert(int,N'30'), convert(float,N'65000'), convert(nvarchar(100),N'Gates'))

select * from #tam

SELECT dept_id, last_name, salary,
		LEAD (salary,1) OVER (ORDER BY salary) AS next_highest_salary
FROM #tam

drop table #tam





