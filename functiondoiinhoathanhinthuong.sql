CREATE FUNCTION dbo.fn_capitalize_pos
(
@str AS nvarchar(100)
)
RETURNS nvarchar(100)
AS
BEGIN

DECLARE
@ret_str AS NVARCHAR(100),
@pos AS int,
@len AS int

SELECT
@ret_str = N' ' + LOWER(@str),
@pos = 1,
@len = LEN(@str) + 1

WHILE @pos > 0 AND @pos < @len
BEGIN
SET @ret_str = STUFF(@ret_str,
@pos + 1,
1,
UPPER(SUBSTRING(@ret_str,@pos + 1, 1)))
SET @pos = CHARINDEX(N' ', @ret_str, @pos + 1)
END

RETURN RIGHT(@ret_str, @len - 1)

END