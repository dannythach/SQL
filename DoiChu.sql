USE [HRMPro8_Migrate_CGV]
GO
/****** Object:  UserDefinedFunction [dbo].[DoiChu]    Script Date: 10/26/2021 10:03:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[DoiChu](@so int)
RETURNS nvarchar(10)
AS
BEGIN
 DECLARE @chuso nvarchar(10)
 IF(@so=0) SET @chuso=N'Không'
 IF(@so=1) SET @chuso=N'Một'
 IF(@so=2) SET @chuso=N'Hai'
 IF(@so=3) SET @chuso=N'Ba'
 IF(@so=4) SET @chuso=N'Bốn'
 IF(@so=5) SET @chuso=N'Năm'
 IF(@so=6) SET @chuso=N'Sáu'
 IF(@so=7) SET @chuso=N'Bảy'
 IF(@so=8) SET @chuso=N'Tám'
 IF(@so=9) SET @chuso=N'Chín'
 IF(@so=10) SET @chuso=N'Mười'
 IF(@so=11) SET @chuso=N'Mốt'
 IF(@so=12) SET @chuso=N'Lẻ'
 IF(@so=13) SET @chuso=N'Lăm'
 IF(@so=14) SET @chuso=N'Mươi'
 IF(@so=15) SET @chuso=N'Trăm'
 IF(@so=16) SET @chuso=N'Ngàn'
 IF(@so=17) SET @chuso=N'Triệu'
 IF(@so=18) SET @chuso=N'Tỷ'
 IF(@so=19) SET @chuso=N'Ngàn Tỷ'
 IF(@so=20) SET @chuso=N''

RETURN @chuso
END