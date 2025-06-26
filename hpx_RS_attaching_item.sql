USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_attaching_item]    Script Date: 26.06.2025 13:50:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_attaching_item]
@IDDoklad INT,
@ID INT
AS

DECLARE @IDSklad_orig NVARCHAR(30);
SET @IDSklad_orig=(SELECT IDSklad FROM TabDokladyZbozi WHERE ID=@IDDoklad)

UPDATE tpz SET tpz.IDOldPolozka=(
SELECT tpz_orig.ID
FROM TabPohybyZbozi tpz
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabStavSkladu tss_orig ON tss_orig.IDKmenZbozi=tkz.ID AND tss_orig.IDSklad=@IDSklad_orig
LEFT OUTER JOIN TabPohybyZbozi tpz_orig ON tpz_orig.IDZboSklad=tss_orig.ID AND tpz_orig.IDDoklad=@IDDoklad
WHERE tpz.ID=@ID)
FROM TabPohybyZbozi tpz
WHERE tpz.ID=@ID
GO

