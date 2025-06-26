USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_create_communication_matrix]    Script Date: 26.06.2025 12:58:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_create_communication_matrix] @Vzor INT
AS
--dohledání ID označené organizace
DECLARE @IDHlavicka INT, @CisOrg INT;
SELECT TOP 1 @IDHlavicka = CAST(Cislo as INT) FROM #TabExtKomPar WHERE Popis='STVlastID'
SELECT @CisOrg=CisloOrg
FROM TabCisOrg
WHERE ID=@IDHlavicka

INSERT INTO Tabx_RS_CommunicationMatrix(CisOrg,Vzor,IDResponsibility,IDEscalRS,IDDeputyRS,IDResponsibleRS)
SELECT @CisOrg,Vzor,IDResponsibility,IDEscalRS,IDDeputyRS,IDResponsibleRS
FROM Tabx_RS_CommunicationMatrix
WHERE Vzor=@Vzor AND CisOrg=0
GO

