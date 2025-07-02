USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabKmenZbozi_EXT_Predplneni]    Script Date: 02.07.2025 15:14:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--MŽ, 11.3.2019 rozšířeno o předplnění _Cofc_en10204=1 pro karty ve skupině karet do 700 včetně.
--MŽ, 4.11.2019 zrušeno plnění TabKmenZbozi_EXT._zprava_prv_kus
--MŽ, 17.1.2020 rozšířeno o předplnění _Expirace_  pro karty ve skupině karet začínají na 15X nebo 17X včetně.

CREATE TRIGGER [dbo].[et_TabKmenZbozi_EXT_Predplneni] ON [dbo].[TabKmenZbozi_EXT] FOR INSERT AS
IF @@ROWCOUNT = 0 RETURN
SET NOCOUNT ON

UPDATE KE SET KE._Cofc_en10204=1, /*KE._zprava_prv_kus=1, */KE._RayService_GenVC_RespPosledni=1
 FROM TabKmenZbozi_EXT KE INNER JOIN TabKmenZbozi K ON KE.ID=K.ID INNER JOIN inserted I ON K.ID=I.ID WHERE K.Dilec=1

UPDATE KE SET KE._Cofc_en10204=1
 FROM TabKmenZbozi_EXT KE INNER JOIN TabKmenZbozi K ON KE.ID=K.ID INNER JOIN inserted I ON K.ID=I.ID WHERE K.SkupZbo<=700 AND K.Dilec <> 1

UPDATE KE SET KE._Expirace_=1
 FROM TabKmenZbozi_EXT KE INNER JOIN TabKmenZbozi K ON KE.ID=K.ID INNER JOIN inserted I ON K.ID=I.ID WHERE ((K.SkupZbo >= 150 AND K.SkupZbo <= 159) OR (K.SkupZbo >= 170 AND K.SkupZbo <= 179))

-- MŽ 10.12.2020 - rozšířeno o předplnění _RayService_GenVC_Maska = '#R-#5P'
UPDATE KE SET KE._RayService_GenVC_Maska = '#R-#5P'
 FROM TabkmenZbozi_EXT KE INNER JOIN TabKmenZbozi K ON KE.ID=K.ID INNER JOIN inserted I ON K.ID=I.ID WHERE K.Dilec=1

-- MŤ 31.10.2022 - rozšířeno o předplnění _EXT_RS_inkjet
UPDATE KE SET KE._EXT_RS_inkjet='Laser/InkJet'
 FROM TabKmenZbozi_EXT KE INNER JOIN TabKmenZbozi K ON KE.ID=K.ID INNER JOIN inserted I ON K.ID=I.ID WHERE (K.SkupZbo NOT LIKE N'8%' AND K.SkupZbo NOT LIKE N'4%')
GO

ALTER TABLE [dbo].[TabKmenZbozi_EXT] ENABLE TRIGGER [et_TabKmenZbozi_EXT_Predplneni]
GO

