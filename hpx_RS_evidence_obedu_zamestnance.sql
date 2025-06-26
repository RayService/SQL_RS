USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_evidence_obedu_zamestnance]    Script Date: 26.06.2025 11:23:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_evidence_obedu_zamestnance]
@IDZam INT,
@Datum DATE,
@IDObedu INT
AS
BEGIN
UPDATE Tab_SDMater_EvidObed_Vyber SET IDObedu=@IDObedu, DatZmeny=GETDATE(), Zmenil=SUSER_SNAME() WHERE IDZam=@IDZam AND Datum=@Datum 
IF @@rowcount=0
INSERT INTO Tab_SDMater_EvidObed_Vyber(IDZam, Datum, IDObedu,Autor) VALUES(@IDZam, @Datum, @IDObedu,SUSER_SNAME())
END;
GO

