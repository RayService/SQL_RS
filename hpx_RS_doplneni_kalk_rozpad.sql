USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_RS_doplneni_kalk_rozpad]    Script Date: 26.06.2025 11:08:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[hpx_RS_doplneni_kalk_rozpad] @IDPohyb INT
AS
--DECLARE @IDPohyb INT=5309826 
DECLARE @IDVCK INT
DECLARE @mat NUMERIC(19,6),@matA NUMERIC(19,6),@matB NUMERIC(19,6),@matC NUMERIC(19,6),@MatRezie NUMERIC(19,6),@koop NUMERIC(19,6),@mzda NUMERIC(19,6),@rezieS NUMERIC(19,6)
,@rezieP NUMERIC(19,6),@ReziePrac NUMERIC(19,6),@NakladyPrac NUMERIC(19,6),@OPN NUMERIC(19,6),@VedProdukt NUMERIC(19,6),@naradi NUMERIC(19,6)
DECLARE @MnozstviNew NUMERIC(19,6);
--příjemka kam natáhnout
SET @IDVCK=(SELECT VCK.ID 
FROM TabVyrCP WITH(NOLOCK)
LEFT OUTER JOIN TabVyrCS VCS WITH(NOLOCK) ON TabVyrCP.IDVyrCis=VCS.ID
LEFT OUTER JOIN TabVyrCK VCK ON VCK.ID=VCS.IDVyrCK
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=TabVyrCP.IDPolozkaDokladu
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabPohybyZbKalkRoz KalRoz WITH(NOLOCK) ON KalRoz.IDPohyb=tpz.ID
WHERE tpz.ID=@IDPohyb)
SET @MnozstviNew=(SELECT Mnozstvi FROM TabPohybyZbozi tpz WHERE tpz.ID=@IDPohyb)
--jaké údaje vzít
SELECT @mat=KalRoz.mat/tpz.Mnozstvi, @matA=KalRoz.matA/tpz.Mnozstvi, @matB=KalRoz.matB/tpz.Mnozstvi, @matC=KalRoz.matC/tpz.Mnozstvi,@matRezie=KalRoz.MatRezie/tpz.Mnozstvi,
@koop=KalRoz.koop/tpz.Mnozstvi,@mzda=KalRoz.mzda/tpz.Mnozstvi,@rezieS=KalRoz.rezieS/tpz.Mnozstvi,@rezieP=KalRoz.rezieP/tpz.Mnozstvi,
@ReziePrac=KalRoz.ReziePrac/tpz.Mnozstvi,@NakladyPrac=KalRoz.NakladyPrac/tpz.Mnozstvi,@OPN=KalRoz.OPN/tpz.Mnozstvi,@VedProdukt=KalRoz.VedProdukt/tpz.Mnozstvi,@Naradi=KalRoz.naradi/tpz.Mnozstvi
FROM TabVyrCP WITH(NOLOCK)
LEFT OUTER JOIN TabVyrCS VCS WITH(NOLOCK) ON TabVyrCP.IDVyrCis=VCS.ID
LEFT OUTER JOIN TabVyrCK VCK ON VCK.ID=VCS.IDVyrCK
LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=TabVyrCP.IDPolozkaDokladu
LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID=tpz.IDDoklad
LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tpz.IDZboSklad=tss.ID
LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
LEFT OUTER JOIN TabPohybyZbKalkRoz KalRoz WITH(NOLOCK) ON KalRoz.IDPohyb=tpz.ID
WHERE (tpz.TypVyrobnihoDokladu=0)AND(tdz.Realizovano=1)AND(tss.IDSklad='200')AND(VCK.ID=@IDVCK)
ORDER BY tdz.DatRealizace DESC
--kontrola na neexistenci šarže odkud vzít
IF NOT EXISTS (SELECT tpz.ID
	FROM TabVyrCP WITH(NOLOCK)
	LEFT OUTER JOIN TabVyrCS VCS WITH(NOLOCK) ON TabVyrCP.IDVyrCis=VCS.ID
	LEFT OUTER JOIN TabVyrCK VCK ON VCK.ID=VCS.IDVyrCK
	LEFT OUTER JOIN TabPohybyZbozi tpz WITH(NOLOCK) ON tpz.ID=TabVyrCP.IDPolozkaDokladu
	LEFT OUTER JOIN TabDokladyZbozi tdz WITH(NOLOCK) ON tdz.ID=tpz.IDDoklad
	LEFT OUTER JOIN TabStavSkladu tss WITH(NOLOCK) ON tpz.IDZboSklad=tss.ID
	LEFT OUTER JOIN TabKmenZbozi tkz WITH(NOLOCK) ON tkz.ID=(SELECT TabStavSkladu.IDKmenZbozi FROM TabStavSkladu WHERE TabStavSkladu.ID=tpz.IDZboSklad)
	LEFT OUTER JOIN TabPohybyZbKalkRoz KalRoz WITH(NOLOCK) ON KalRoz.IDPohyb=tpz.ID
	WHERE (tpz.TypVyrobnihoDokladu=0)AND(tdz.Realizovano=1)AND(tss.IDSklad='200')AND(VCK.ID=@IDVCK))
	BEGIN
	RAISERROR ('Nenalezen poslední příjem v VP pro danou šarži.',16,1);
	RETURN;
	END;
--vkládání
--pokud neexistuje kalk.rozpad - insert
IF NOT EXISTS(SELECT * FROM TabPohybyZbKalkRoz WHERE IDPohyb=@IDPohyb)
INSERT INTO TabPohybyZbKalkRoz(IDPohyb,mat,matA,matB,matC,MatRezie,koop,mzda,rezieS,rezieP,ReziePrac,NakladyPrac,OPN,VedProdukt,naradi)
SELECT @IDPohyb,@mat*@MnozstviNew,@matA*@MnozstviNew,@matB*@MnozstviNew,@matC*@MnozstviNew,@MatRezie*@MnozstviNew,@koop*@MnozstviNew,@mzda*@MnozstviNew,@rezieS*@MnozstviNew,@rezieP*@MnozstviNew,@ReziePrac*@MnozstviNew,@NakladyPrac*@MnozstviNew,@OPN*@MnozstviNew,@VedProdukt*@MnozstviNew,@naradi*@MnozstviNew
--pokud existuje kalk.rozpad - update
ELSE
UPDATE TabPohybyZbKalkRoz 
SET mat=@mat*@MnozstviNew,matA=@matA*@MnozstviNew,matB=@matB*@MnozstviNew,matC=@matC*@MnozstviNew,matRezie=@MatRezie*@MnozstviNew,koop=@koop*@MnozstviNew,mzda=@mzda*@MnozstviNew,rezieS=@rezieS*@MnozstviNew,
rezieP=@rezieP*@MnozstviNew,ReziePrac=@ReziePrac*@MnozstviNew,NakladyPrac=@NakladyPrac*@MnozstviNew,OPN=@OPN*@MnozstviNew,VedProdukt=@VedProdukt*@MnozstviNew,Naradi=@naradi*@MnozstviNew
WHERE TabPohybyZbKalkRoz.IDPohyb=@IDPohyb
GO

