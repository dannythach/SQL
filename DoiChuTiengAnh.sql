USE [HRMPro8_Migrate_CGV]
GO
/****** Object:  UserDefinedFunction [dbo].[DoiChuTiengAnh]    Script Date: 10/26/2021 10:03:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[DoiChuTiengAnh](@so int)
RETURNS nvarchar(10)
AS
BEGIN
 DECLARE @chuso nvarchar(10)
 IF(@so=0) SET @chuso=N'Zero'
 IF(@so=1) SET @chuso=N'One'
 IF(@so=2) SET @chuso=N'Two'
 IF(@so=3) SET @chuso=N'Three'
 IF(@so=4) SET @chuso=N'Four'
 IF(@so=5) SET @chuso=N'Five'
 IF(@so=6) SET @chuso=N'Six'
 IF(@so=7) SET @chuso=N'Seven'
 IF(@so=8) SET @chuso=N'Eight'
 IF(@so=9) SET @chuso=N'Nine'
 IF(@so=10) SET @chuso=N'Ten'
 IF(@so=11) SET @chuso=N'One'
 IF(@so=12) SET @chuso=N'Pear'
 IF(@so=13) SET @chuso=N'Five'
 IF(@so=14) SET @chuso=N'ty'
 IF(@so=15) SET @chuso=N'Hundred'
 IF(@so=16) SET @chuso=N'Thousand'
 IF(@so=17) SET @chuso=N'Milion'
 IF(@so=18) SET @chuso=N'Bilion'
 IF(@so=19) SET @chuso=N'Thousand Billion'
 IF(@so=20) SET @chuso=N'Dong'

RETURN @chuso
END