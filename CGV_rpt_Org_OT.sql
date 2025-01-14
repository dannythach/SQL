USE [HRMPro8_Migrate_CGV]
GO
/****** Object:  StoredProcedure [dbo].[CGV_rpt_Org_OT]    Script Date: 10/26/2021 9:52:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[CGV_rpt_Org_OT]
@condition varchar(max) =  " ",
@PageIndex int = 1,
@PageSize int = 20,
@Username varchar(100) = null
as
begin

	 SET NOCOUNT ON

	 declare @str varchar(max)
	 declare @strMonth varchar(max)

	 DECLARE @kycongid nvarchar(max)
	 declare @countrow int
	 declare @row int
	 
	 declare @query varchar(max)
	 declare @queryPageSize varchar(max)

	--SELECT @condition

	--SET @condition = ' and (DateEffective = ''2020/02/01'')'
	--SET @condition = ' and (DateEffective = ''2020/02/01'') and (OrderNumber in (select Id from split_to_int(ISNULL(''109,110,111,112'', NULL))))'

	declare @index int
	declare @ID varchar(500)

	set @str = REPLACE(@condition,',','@')
	SET @str = REPLACE(@str,'and (',',')

	SELECT ID into #tableTempCondition FROM SPLIT_To_VARCHAR (@str)
	SET @row = (SELECT count(ID) FROM SPLIT_To_VARCHAR (@str))
	SET @countrow = 0
	SET @index = 0

	DECLARE @tempID varchar(500)
	DECLARE @tempCodition varchar(100)

	while @row > 0
	BEGIN
		set @index = 0
		set @ID = (select top 1 ID from #tableTempCondition)
		set @tempID = replace(@ID,'@',',')

		set @index = 0
		set @index = charindex('(DateEffective ','('+@tempID,0) 
		if(@index > 0)
		begin
			set @tempCodition = 'and ('+@tempID
			set @condition = REPLACE(@condition,@tempCodition,' ')
			set @strMonth = REPLACE(@tempID,'DateEffective =','')
			set @strMonth = REPLACE(@strMonth,')','')
		end

		DELETE #tableTempCondition WHERE ID = @ID
		set @row = @row - 1
	END

	DROP table #tableTempCondition

	-- Cắt lấy tháng năm
	SET @strMonth = REPLACE(@strMonth,'and (DateEffective = ','')
	SET @strMonth = REPLACE(@strMonth,')','')
	SET @strMonth = REPLACE(@strMonth,' ','')
 
	DECLARE @datetimeMonth datetime = CONVERT(VARCHAR(10),substring(@strMonth, 2, len(@strMonth)-2),103)
	--select @datetimeMonth

	--select dbo.Get_month(@datetimeMonth,21)

	DECLARE @datetimeEndOfMonth date = DATEFROMPARTS(year(@datetimeMonth),dbo.Get_month(@datetimeMonth,21),20)
	DECLARE @strEndOfMonth varchar(max) = CAST(@datetimeEndOfMonth as varchar(max))

	--select @strEndOfMonth
	SET @kycongid=(SELECT CutOffDurationName FROM dbo.Att_CutOffDuration WHERE IsDelete IS NULL AND MonthYear= DATEFROMPARTS(year(@datetimeMonth),dbo.Get_month(@datetimeMonth,21),1))
	--SELECT @kycongid

	--SELECT @condition
	
 	SET @query = '
	
	SELECT a.ProfileID,a.OrgStructureID,b.code
	,
	CASE
		WHEN CHARINDEX('','',REVERSE(dbo.VnrDecrypt(E_Value)),1)<=3 THEN convert(FLOAT,REPLACE(dbo.VnrDecrypt(E_Value),'','',''.''))
		ELSE convert(FLOAT,dbo.VnrDecrypt(E_Value))
	END AS value_Total
		into #Temp1		
	FROM dbo.Sal_PayrollTable a,
		dbo.Sal_PayrollTableItem b,
		dbo.Hre_Profile c,
		dbo.Hre_WorkHistory d,
		dbo.Cat_OrgStructure e,
		dbo.Cat_OrgStructureType f,
		dbo.Att_CutOffDuration g,
		dbo.cat_Company h
	WHERE a.isdelete IS NULL
		AND a.id=b.PayrollTableID AND b.IsDelete IS NULL
		AND a.ProfileID=c.ID AND c.IsDelete IS NULL
		And c.CompanyID=h.ID
		AND a.CutOffDurationID=g.ID AND g.IsDelete IS null
		AND g.CutOffDurationName= '''+@kycongid+'''
		AND d.OrganizationStructureID=e.ID AND e.IsDelete IS NULL
		AND e.OrgStructureTypeID=f.ID AND f.IsDelete IS NULL
		AND (b.code=N''OT15'' 
			OR b.code=N''OT21'' 
			OR b.code=N''OT20'' 
			OR b.code=N''OT27'' 
			OR b.code=N''OT30'' 
			OR b.code=N''OT39''
			OR b.code=N''CLL''
			OR b.code=N''T_CLL''
			OR b.code=N''CDEM''
			OR b.code=N''T_CDEM''
			OR b.code=N''OT_TT''
			)
		AND a.ProfileID=d.ProfileID
		AND d.ID = (
								select top 1 ID from Hre_WorkHistory hwh
								where hwh.IsDelete is null
								and hwh."Status" = ''E_APPROVED''
								and hwh.ProfileID = a.ProfileID
								and hwh.DateEffective <= '''+@strEndOfMonth+'''
								order by hwh.DateEffective desc
							) 
	
	SELECT OrgStructureID,code,SUM(CONVERT(FLOAT,value_Total)) AS value_Total,COUNT(ProfileID) AS headcount 
		into #Temp
	FROM #Temp1 
	GROUP BY OrgStructureID,Code
	
	SELECT OrgStructureID,OrderNumber,CompanyID,CompanyCode,CompanyName,headcount
		,[OT15], [OT21],[OT20],[OT27],[OT30],[OT39],[CLL],[T_CLL],[CDEM],[T_CDEM],[OT_TT]
		into #OrgtypeTemp
	FROM 
		(
		select tam.OrgStructureID,a.OrderNumber,b.ID AS CompanyID,b.Code AS CompanyCode,b.CompanyName,tam.headcount
			,tam.Code,tam.value_Total
		from #Temp tam,
			dbo.Cat_OrgStructure a	
			LEFT join Cat_Company b on a.CompanyID = b.ID and b.IsDelete IS NULL	
		WHERE tam.OrgStructureID=a.ID AND a.IsDelete IS null
		) as bangtam
	PIVOT 
		(
		 SUM(bangtam.value_Total)
		 FOR bangtam.code IN ([OT15], [OT21],[OT20],[OT27],[OT30],[OT39],[CLL],[T_CLL],[CDEM],[T_CDEM],[OT_TT])
		) as bangchuyen

	select a.OrgStructureID,OrderNumber,CompanyID,CompanyCode,CompanyName
		,b.E_COMPANY as CEO,b.E_BRANCH as Division,b.E_UNIT as Department,b.E_DIVISION as Team,b.E_DEPARTMENT as Sub_team
		,[OT15], [OT21],[OT20],[OT27],[OT30],[OT39],[CLL],[T_CLL],[CDEM],[T_CDEM],[OT_TT]
		,null as DateEffective
	from #OrgtypeTemp a,
		Cat_OrgUnit b
	where a.OrgstructureID=b.OrgstructureID and b.IsDelete is null '+@condition+'
		
	Drop table #Temp,#OrgtypeTemp

	'	
	print(@query)
	exec(@query)
	
end
