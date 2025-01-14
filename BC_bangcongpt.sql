
ALTER proc [dbo].[BC_bangcongpt]
@condition varchar(max) = ' ',
@PageIndex int = 1,
@PageSize int = 100,
@Username varchar(50) = 'vnr_admin'
as
BEGIN
	declare @query Nvarchar(max)
	declare @query1 Nvarchar(max)
	declare @query2 Nvarchar(max)
	declare @queryPageSize Nvarchar(max)
	DECLARE @countrow INT
    DECLARE @row INT
    DECLARE @index INT
    DECLARE @ID NVARCHAR(500)
	DECLARE @top0 varchar(max) = ''
	DECLARE @str nvarchar(max) = ''
	declare @tempID varchar(max)
	declare @tempCodition varchar(max)
	--khai báo các biến chứa điều kiện cần tách
	DECLARE @strConditionOrg varchar(max) = ''
	DECLARE @strConditioncode VARCHAR(max)=''
	DECLARE @strConditioncutid VARCHAR(MAX)=''
   



--------------- Nếu có mã hoá thì cấu hình = true-----------------------------	
	--declare @Encrypt varchar(10) = 'true'
	--declare @Decrypt_Value varchar(40) = 'spti.E_Value'
	--if @Encrypt = 'true'
	--begin
	--	set @Decrypt_Value = 'CAST(dbo.VnrDecrypt(E_Value) AS float)'
	--end	

	--declare @strElementsLUONG varchar(max) = 'BTM_PC_HQCN'
	--declare @strElementLUONG varchar(max)
	--SELECT @strElementLUONG= COALESCE(@strElementLUONG + ',','') + QUOTENAME([ID])
	--FROM (select ID from SPLIT_To_NVARCHAR(@strElementsLUONG)) as #tableLUONG

----------------------------------------------------
	



	SET NOCOUNT ON;
	-- Cấu hình các mã phần tử ở đây
	--SELECT @condition
      --SET @condition = 'and (spti.MonthYear between ''2020/10/01'' and ''2020/11/30'') and (hp.PayrollCategoryID in (''E8B96677-C030-4AE4-8527-43F2B4867586'')) and (hp.CostCentreID in (''60274f82-ab8f-4e7e-ae82-069f58f82924'')) '
      --set @condition=' and (spt.CutOffDurationID like N''%E63AAFD7-EB01-4B77-BCF6-5DE6C576D292%'') and (hp.PayrollCategoryID in (''e8b96677-c030-4ae4-8527-43f2b4867586'')) '
	 ----------------if điều kiện để chạy store---------------------------------------
	 IF (@condition = '' or @condition=' ')
		begin
		  SET @condition='and (act.ID in (''93A68692-67D3-48B6-BAB8-A8040AB9C2F0'')) '
		end
	------------------------cấu hình cắt điều kiện-----------------------------------
		set @str = REPLACE(@condition,',','@')
		set @str = REPLACE(@str,'and (',',')

		SELECT ID into #tableTempCondition FROM SPLIT_To_VARCHAR (@str)
	
		set @row = (SELECT count(ID) FROM SPLIT_To_VARCHAR (@str))
		set @countrow = 0
		set @index = 0

	while @row > 0
	begin
		set @index = 0
		set @ID = (select top 1 ID from #tableTempCondition)
		set @tempID = replace(@ID,'@',',')
-----------------------------cắt điều kiện theo năm ---------------------------
		set @index = charindex('(act.ID ','('+@tempID,0) 
		if(@index > 0)
		begin
			--bỏ điều kiện muốn tách trong chuỗi điều kiện tổng
			set @tempCodition = 'and ('+@tempID
			set @condition = REPLACE(@condition,@tempCodition,' ')
			set @strConditioncutid = @tempCodition
			
		
		END
		
------------------------------------------------------------------------	    
	
		------------------nhanvien---------------------------
		set @index = charindex('(hp.CodeEmp ','('+@tempID,0) 
		if(@index > 0)
		begin
			--bỏ điều kiện muốn tách trong chuỗi điều kiện tổng
			set @tempCodition = 'and ('+@tempID
			set @condition = REPLACE(@condition,@tempCodition,' ')
			set @strConditioncode = @tempCodition
			
		
		END
	
		
		DELETE #tableTempCondition WHERE ID = @ID
		set @row = @row - 1

		
	   END
	   
	 

--SELECT @strConditioncutid
	----------------------thongtinnhanvien-----------------------------------------
SET @query =N'
WITH rawdata
AS (
				SELECT 
				hp.CodeEmp,
				hp.ProfileName,
				hp.DateHire,
				SAL.DateOfEffect AS DateOfEffect,
				dbo.VnrDecrypt(sal.E_GrossAmount) AS GrossAmount,
				ccp.CompanyName,
				ccp.CompanyCode,
				aat.ProfileID,
				cs.ShiftName,
				aati.WorkPaidHours,
				aati.NightShiftHours,
				aati.WorkDate,
				ROW_NUMBER() OVER (PARTITION BY aat.ProfileID ORDER BY aati.WorkDate ASC) AS pv
				FROM dbo.Att_AttendanceTable aat
				LEFT JOIN  (SELECT ID,WorkDate,WorkPaidHours,ShiftID,NightShiftHours,AttendanceTableID FROM dbo.Att_AttendanceTableItem  where isdelete is null) aati ON aati.AttendanceTableID = aat.ID 
				LEFT JOIN  (SELECT ID,EmpTypeID,CodeEmp,ProfileName,DateHire FROM dbo.Hre_Profile where isdelete is null ) hp ON hp.id=aat.ProfileID 
				LEFT JOIN  dbo.Cat_Shift cs ON cs.ID=aati.ShiftID AND cs.IsDelete IS NULL
				LEFT JOIN (SELECT ID,OrgStructureName,OrderNumber FROM dbo.Cat_OrgStructure where isdelete is null) cos ON cos.ID=aat.OrgStructureID
				LEFT JOIN  (SELECT ID,Code AS CompanyCode,CompanyName FROM dbo.Cat_Company where isdelete is null) ccp ON ccp.ID = aat.CompanyID
				LEFT JOIN  (SELECT ID,DateEnd  FROM  dbo.Att_CutOffDuration where isdelete is null) act ON act.ID = aat.CutOffDurationID
				OUTER APPLY (SELECT TOP 1 * FROM dbo.Sal_BasicSalary where isdelete is NULL AND ProfileID=hp.ID AND DateOfEffect <= act.DateEnd ORDER BY DateOfEffect DESC) SAL
				where aat.isdelete is NULL
				'+@strConditioncutid+'
				'+@strConditioncode+'
				'+@condition+'
				AND hp.EmpTypeID=''7901D683-09B0-42ED-A7A2-C6BE1F8DE097''
           
),

-----ca làm việc---------------
shiftname
AS
 (
                    SELECT              
					pv.ProfileID ,
                    PV.[1] AS R1,
					PV.[2] AS R2,
					PV.[3] AS R3,
					PV.[4] AS R4,
					PV.[5] AS R5,
					PV.[6] AS R6,
					PV.[7] AS R7,
					PV.[8] AS R8,
					PV.[9] AS R9,
					PV.[10]AS R10,
					PV.[11]AS R11,
					PV.[12]AS R12,
					PV.[13]AS R13,
					PV.[14]AS R14,
					PV.[15]AS R15,
					PV.[16]AS R16,
					PV.[17]AS R17,
					PV.[18]AS R18,
					PV.[19]AS R19,
					PV.[20]AS R20,
					PV.[21]AS R21,
					PV.[22]AS R22,
					PV.[23]AS R23,
					PV.[24]AS R24,
					PV.[25]AS R25,
					PV.[26]AS R26,
					PV.[27]AS R27,
					PV.[28]AS R28,
					PV.[29]AS R29,
					PV.[30]AS R30,
					PV.[31]AS R31
					FROM (SELECT ProfileID,pv,ShiftName FROM rawdata) rawdata
                    PIVOT ( MAX(ShiftName) 
					FOR pv IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31]) ) pv
),

--------giờ ca ngày------------------
WorkPaidHours
AS(
      SELECT
	        PV.ProfileID ,
            PV.[1] AS D1,
			PV.[2] AS D2,
			PV.[3] AS D3,
			PV.[4] AS D4,
			PV.[5] AS D5,
			PV.[6] AS D6,
			PV.[7] AS D7,
			PV.[8] AS D8,
			PV.[9] AS D9,
			PV.[10]AS D10,
			PV.[11]AS D11,
			PV.[12]AS D12,
			PV.[13]AS D13,
			PV.[14]AS D14,
			PV.[15]AS D15,
			PV.[16]AS D16,
			PV.[17]AS D17,
			PV.[18]AS D18,
			PV.[19]AS D19,
			PV.[20]AS D20,
			PV.[21]AS D21,
			PV.[22]AS D22,
			PV.[23]AS D23,
			PV.[24]AS D24,
			PV.[25]AS D25,
			PV.[26]AS D26,
			PV.[27]AS D27,
			PV.[28]AS D28,
			PV.[29]AS D29,
			PV.[30]AS D30,
			PV.[31]AS D31
	  FROM (SELECT ProfileID,pv,WorkPaidHours FROM rawdata) rawdata 
	  PIVOT 
	  (
	  MAX(WorkPaidHours)
	  FOR PV IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
	  )PV


),
'
SET @query1=N'
----giờ ca tối----------------------------
NightShiftHours
AS
(
        SELECT 
		PV.ProfileID ,
        PV.[1] AS N1,
		PV.[2] AS N2,
		PV.[3] AS N3,
		PV.[4] AS N4,
		PV.[5] AS N5,
		PV.[6] AS N6,
		PV.[7] AS N7,
		PV.[8] AS N8,
		PV.[9] AS N9,
		PV.[10]AS N10,
		PV.[11]AS N11,
		PV.[12]AS N12,
		PV.[13]AS N13,
		PV.[14]AS N14,
		PV.[15]AS N15,
		PV.[16]AS N16,
		PV.[17]AS N17,
		PV.[18]AS N18,
		PV.[19]AS N19,
		PV.[20]AS N20,
		PV.[21]AS N21,
		PV.[22]AS N22,
		PV.[23]AS N23,
		PV.[24]AS N24,
		PV.[25]AS N25,
		PV.[26]AS N26,
		PV.[27]AS N27,
		PV.[28]AS N28,
		PV.[29]AS N29,
		PV.[30]AS N30,
		PV.[31]AS N31
	  FROM (SELECT ProfileID,pv,NightShiftHours FROM rawdata) rawdata
	  PIVOT 
	  (
	  MAX(NightShiftHours)
	  FOR PV IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
	  )PV


)
--------------giờ ca ngày lễ---------------------
,
sall
AS
(
SELECT pv.ProfileID ,
       pv.SG_DNL,
	   pv.SG_DNT,
       pv.SG_NL ,
       pv.SG_NT 
	   FROM (
		SELECT spt.ProfileID,spti.Code,CAST(dbo.VnrDecrypt(spti.E_Value) AS FLOAT) AS value FROM dbo.Sal_PayrollTable spt
		LEFT JOIN  dbo.Sal_PayrollTableItem spti ON spti.PayrollTableID = spt.ID AND spti.IsDelete IS NULL
		LEFT JOIN  (SELECT ID,DateEnd  FROM  dbo.Att_CutOffDuration where isdelete is null) act ON act.ID = spt.CutOffDurationID
		where spt.isdelete is NULL 
		'+@strConditioncutid+'
		AND spti.Code IN (''SG_NT'',''SG_DNT'',''SG_NL'',''SG_DNL'')
		AND spt.ProfileID IN ( SELECT ProfileID FROM rawdata )
            ) pvv
      PIVOT 
		 (
		   SUM(value)
		   FOR Code IN ([SG_NT],[SG_DNT],[SG_NL],[SG_DNL])
		 )pv

)
'
SET @query2=N'

SELECT  

       hp.CodeEmp ,
       hp.ProfileName ,
       hp.DateHire ,
       hp.DateOfEffect ,
       hp.GrossAmount as LCB,
       hp.CompanyName,
	   hp.CompanyCode,
       hp.WorkDate AS StartingDate,
       WorkPaidHours.D1 ,
       WorkPaidHours.D2 ,
       WorkPaidHours.D3 ,
       WorkPaidHours.D4 ,
       WorkPaidHours.D5 ,
       WorkPaidHours.D6 ,
       WorkPaidHours.D7 ,
       WorkPaidHours.D8 ,
       WorkPaidHours.D9 ,
       WorkPaidHours.D10 ,
       WorkPaidHours.D11 ,
       WorkPaidHours.D12 ,
       WorkPaidHours.D13 ,
       WorkPaidHours.D14 ,
       WorkPaidHours.D15 ,
       WorkPaidHours.D16 ,
       WorkPaidHours.D17 ,
       WorkPaidHours.D18 ,
       WorkPaidHours.D19 ,
       WorkPaidHours.D20 ,
       WorkPaidHours.D21 ,
       WorkPaidHours.D22 ,
       WorkPaidHours.D23 ,
       WorkPaidHours.D24 ,
       WorkPaidHours.D25 ,
       WorkPaidHours.D26 ,
       WorkPaidHours.D27 ,
       WorkPaidHours.D28 ,
       WorkPaidHours.D29 ,
       WorkPaidHours.D30 ,
       WorkPaidHours.D31 ,

       NightShiftHours.N1 ,
       NightShiftHours.N2 ,
       NightShiftHours.N3 ,
       NightShiftHours.N4 ,
       NightShiftHours.N5 ,
       NightShiftHours.N6 ,
       NightShiftHours.N7 ,
       NightShiftHours.N8 ,
       NightShiftHours.N9 ,
       NightShiftHours.N10 ,
       NightShiftHours.N11 ,
       NightShiftHours.N12 ,
       NightShiftHours.N13 ,
       NightShiftHours.N14 ,
       NightShiftHours.N15 ,
       NightShiftHours.N16 ,
       NightShiftHours.N17 ,
       NightShiftHours.N18 ,
       NightShiftHours.N19 ,
       NightShiftHours.N20 ,
       NightShiftHours.N21 ,
       NightShiftHours.N22 ,
       NightShiftHours.N23 ,
       NightShiftHours.N24 ,
       NightShiftHours.N25 ,
       NightShiftHours.N26 ,
       NightShiftHours.N27 ,
       NightShiftHours.N28 ,
       NightShiftHours.N29 ,
       NightShiftHours.N30 ,
       NightShiftHours.N31 ,

       shiftname.R1 ,
       shiftname.R2 ,
       shiftname.R3 ,
       shiftname.R4 ,
       shiftname.R5 ,
       shiftname.R6 ,
       shiftname.R7 ,
       shiftname.R8 ,
       shiftname.R9 ,
       shiftname.R10 ,
       shiftname.R11 ,
       shiftname.R12 ,
       shiftname.R13 ,
       shiftname.R14 ,
       shiftname.R15 ,
       shiftname.R16 ,
       shiftname.R17 ,
       shiftname.R18 ,
       shiftname.R19 ,
       shiftname.R20 ,
       shiftname.R21 ,
       shiftname.R22 ,
       shiftname.R23 ,
       shiftname.R24 ,
       shiftname.R25 ,
       shiftname.R26 ,
       shiftname.R27 ,
       shiftname.R28 ,
       shiftname.R29 ,
       shiftname.R30 ,
       shiftname.R31 ,

       sal.SG_DNL ,
       sal.SG_DNT ,
       sal.SG_NL ,
       sal.SG_NT ,
	   ROW_NUMBER() OVER ( ORDER BY hp.CodeEmp asc) as RowNumber
       
			

      into #Result1

      FROM WorkPaidHours 
	  LEFT  JOIN NightShiftHours ON NightShiftHours.ProfileID = WorkPaidHours.ProfileID
	  LEFT	JOIN shiftname ON shiftname.ProfileID = WorkPaidHours.ProfileID
	  OUTER APPLY (SELECT * FROM sall where sall.ProfileID=WorkPaidHours.ProfileID) sal
	  OUTER APPLY (SELECT TOP 1 * FROM rawdata WHERE rawdata.ProfileID=WorkPaidHours.ProfileID ORDER BY rawdata.WorkDate ASC) hp
;
  
       
'

set @queryPageSize = N' 

    ALTER TABLE #Result1 ADD TotalRow INT
    DECLARE @totalRow INT
	SELECT @totalRow = COUNT(*) FROM #Result1
	UPDATE #Result1 set TotalRow = @totalRow
	
	SELECT * , null as "act.ID",null as "hp.CodeEmp" ,null as "cos.OrderNumber"
    FROM #Result1
	WHERE RowNumber BETWEEN('+CAST(@PageIndex AS VARCHAR)+' -1) * '+CAST(@PageSize AS VARCHAR)+' + 1 AND((('+CAST(@PageIndex AS VARCHAR)+' -1) * '+CAST(@PageSize AS VARCHAR)+' + 1) + '+CAST(@PageSize AS VARCHAR)+') - 1


    drop table #Result1
'

print(  @query + ' ' +@query1 + ' ' + @query2 + ' ' + @queryPageSize)
EXEC (@query + ' ' + @query1 + ' ' + @query2 + ' ' + @queryPageSize)



END
--@query + ' ' +@query1 + ' ' +

