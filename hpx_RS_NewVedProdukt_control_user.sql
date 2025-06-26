USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_NewVedProdukt_control_user]    Script Date: 26.06.2025 15:33:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_NewVedProdukt_control_user]
  @PrvniPruchod BIT
AS
IF (SELECT BrowseID FROM #TempDefFormInfo)=11177 AND (SELECT TabName FROM #TempDefFormInfo)='TabKmenZbozi' AND (SELECT Autor FROM #TempDefForm_NovaVeta) NOT IN
('parenica',
'bachan',
'steigerova',
'buresova',
'pospisilovak',
'pochyly',
'chlachula',
'vaculam',
'dolezel',
'Kolarova',
'mankova',
'paurikova',
'sanakova',
'sachova',
'zajdlikova',
'simek',
'fchlachula',
'husek',
'minks',
'radoch',
'valentar',
'veselsky',
'lopata',
'vanekj',
'pesl',
'hranka',
'skvarilova',
'bartozel',
'brigadnik2',
'sa',
'tomankova',
'jancova',
'krocilova',
'blahova',
'patz',
'miklicek'
)
BEGIN
RAISERROR('Nemáte oprávnění založit kmenovou kartu.',16,1)
RETURN
END;

GO

