USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_ZmenaRadyVPzLPP]    Script Date: 30.06.2025 8:22:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_ZmenaRadyVPzLPP] @Kontrola BIT, @Prop_RadaVP NVARCHAR(5), @ID INT
AS

IF @Kontrola=1
BEGIN
DECLARE @MFG_ORDER_ID NVARCHAR(100)
SET @MFG_ORDER_ID=(SELECT MFG_ORDER_ID FROM GTabAPSLogis_OUT_MANUFACTURINGORDER WHERE ID=@ID)
UPDATE GTabAPSLogis_OUT_MANUFACTURINGORDERPROPERTY SET STRING_VALUE=@Prop_RadaVP WHERE MFG_ORDER_ID=@MFG_ORDER_ID AND ATTRIBUTE_NAME=N'RAY_RadaVP'
END
ELSE
BEGIN
RAISERROR ('Nic neproběhne, není zatrženo Provést.',16,1)
RETURN
END;




--SELECT P.STRING_VALUE_255 FROM GTabAPSLogis_OUT_MANUFACTURINGORDERPROPERTY P WHERE P.MFG_ORDER_ID=X.MFG_ORDER_ID AND P.ATTRIBUTE_NAME=N'RAY_RadaVP'


GO

