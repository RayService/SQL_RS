USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabVyrCP_Gatema_PohybUmisteni_Insert_Update]    Script Date: 03.07.2025 8:40:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*PlugGatemaSDMaterial.plgSDMater*/CREATE TRIGGER [dbo].[et_TabVyrCP_Gatema_PohybUmisteni_Insert_Update] ON [dbo].[TabVyrCP] FOR INSERT, UPDATE
AS
SET NOCOUNT ON
DECLARE @Autor nvarchar(128) 
SELECT TOP 1 @Autor=Autor FROM INSERTED WHERE Autor='Terminal'
IF NOT UPDATE(Mnozstvi) OR @Autor='Terminal' RETURN
DECLARE @AutoGenerPohUm_Strom bit, @AutoGenerPohUm_Rada bit, @IDPZ int, @IDVyrCis int, @IDUm int, @IDSS int, @IDKZ int, @Mnozstvi numeric(19, 6),
        @TypDokladu int, @SignMn int, @DruhPohUmist int, @IDUmStav int
DECLARE crVlozeno CURSOR FAST_FORWARD LOCAL FOR
  SELECT ISNULL(S_E._AutoGenerPohUm, 0), ISNULL(DDZ_E._AutoGenerPohUm, 0), PZ.ID, I.IDVyrCis, U.ID, SS.ID, SS.IDKmenZbozi, I.Mnozstvi, DZ.DruhPohybuZbo
  FROM INSERTED I
    INNER JOIN TabPohybyZbozi PZ ON PZ.ID=I.IDPolozkaDokladu
    INNER JOIN TabStavSkladu SS ON SS.ID=PZ.IDZboSklad
    INNER JOIN TabStrom S ON S.Cislo=SS.IDSklad
    LEFT OUTER JOIN TabStrom_EXT S_E ON S_E.ID=S.ID
    INNER JOIN TabDokladyZbozi DZ ON DZ.ID=PZ.IDDoklad
	  INNER JOIN TabDruhDokZbo DDZ ON DDZ.RadaDokladu=DZ.RadaDokladu AND DDZ.DruhPohybuZbo=DZ.DruhPohybuZbo
    LEFT OUTER JOIN TabDruhDokZbo_EXT DDZ_E ON DDZ_E.ID=DDZ.ID
    LEFT OUTER JOIN TabKmenZbozi_EXT KZ_E ON KZ_E.ID=SS.IDKmenZbozi
    LEFT OUTER JOIN TabUmisteni U ON U.IDSklad=S.Cislo AND U.Kod=ISNULL(KZ_E._Sklad, '')+ISNULL(KZ_E._Sklad_Regal, '')+ISNULL(KZ_E._Sklad_Misto,'')
OPEN crVlozeno
FETCH NEXT FROM crVlozeno INTO @AutoGenerPohUm_Strom, @AutoGenerPohUm_Rada, @IDPZ, @IDVyrCis, @IDUm, @IDSS, @IDKZ, @Mnozstvi, @TypDokladu
WHILE @@fetch_status=0
BEGIN
IF @TypDokladu IN (0, 3) SET @DruhPohUmist = 1
ELSE
  IF @TypDokladu IN (1, 2, 4) SET @DruhPohUmist = 2
  IF @AutoGenerPohUm_Strom=1 AND @AutoGenerPohUm_Rada=1 AND @TypDokladu<=4
  BEGIN
    IF @TypDokladu IN (0, 3) 
    Begin --4.10.2019 úprava ZK z důvodůgenerování umístění při výdeji na logistický sklad (z konfigurace), umístění se doplní realizační vsuvkou 
    SET @SignMn = 1 --ELSE SET @SignMn = -1 --4.10.2019 úprava ZK 
    DELETE Gatema_PohybUmisteni WHERE IDPohZbo=@IDPZ AND IDVyrCis=@IDVyrCis
    IF @IDUm IS NULL OR @IDUm<=0
      SELECT @IDUm=ISNULL(U.Id, 0) 
        FROM Tab_SDMater_Konfig K 
        Left Outer Join TabUmisteni Um ON K.IDUmisteni=Um.Id 
        Left Outer Join TabStavSkladu SS ON SS.ID=@IDSS 
        Left Outer Join TabUmisteni U ON U.Kod=Um.Kod AND U.IDSklad=SS.IDSklad 
    IF @IDUm IS NOT NULL AND @IDUm>0 
     BEGIN
      INSERT INTO Gatema_PohybUmisteni (IDStavSkladu, IDKmenZbozi, IDVyrCis, IDUmisteni, Mnozstvi, Autor, DatPorizeni, IDPohZbo, DruhPohybu) 
              VALUES (@IDSS, @IDKZ, @IDVyrCis, @IDUm, @SignMn*@Mnozstvi, SUSER_SNAME(), GETDATE(), @IDPZ, @DruhPohUmist)
        DELETE Gatema_PohybUmisteni WHERE IDPohZbo = @IDPZ AND IDVyrCis IS NULL
     END
     End --4.10.2019 úprava ZK 
    IF @TypDokladu IN (1,2,4) 
      Begin --28.11.2019 úprava ZK z důvodů generování umístění při výdeji na logistický sklad (z konfigurace), umístění se doplní ještě před realizační vsuvkou 
        IF NOT Exists(Select * From Gatema_SDScanData Where IDPohZbo_New = @IDPZ ) 
          Begin 
            SET @SignMn = -1 
            DELETE Gatema_PohybUmisteni WHERE IDPohZbo=@IDPZ AND IDVyrCis=@IDVyrCis
            INSERT INTO Gatema_PohybUmisteni (IDStavSkladu, IDKmenZbozi, IDVyrCis, IDUmisteni, Mnozstvi, Autor, DatPorizeni, IDPohZbo, DruhPohybu) 
                                (Select @IDSS, @IDKZ, @IDVyrCis, X.IDUmisteni, @SignMn*(X.Mnozstvi), SUSER_SNAME(), GETDATE(), @IDPZ, @DruhPohUmist 
                                    From (SELECT IDUmisteni, Mnozstvi= 
                                                 IIF( (SUM(Mnozstvi) OVER (ORDER BY mnozstvi asc, ID asc))<@Mnozstvi,  
                                                      Mnozstvi, 
                                                      @Mnozstvi-ISNULL((SUM(Mnozstvi) OVER (ORDER BY mnozstvi asc, ID asc ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)), 0.0) 
                                                     ) 
                                            FROM Gatema_StavUmisteni 
                                            WHERE IDStavSkladu=@IDSS AND IDVyrCis=@IDVyrCis AND Mnozstvi>0)X 
                                    Where X.Mnozstvi>0.0 
                                 ) 
            DELETE Gatema_PohybUmisteni WHERE IDPohZbo = @IDPZ AND IDVyrCis IS NULL
          End 
      End --28.11.2019 úprava ZK 
  END
  FETCH NEXT FROM crVlozeno INTO @AutoGenerPohUm_Strom, @AutoGenerPohUm_Rada, @IDPZ, @IDVyrCis, @IDUm, @IDSS, @IDKZ, @Mnozstvi, @TypDokladu
END
GO

ALTER TABLE [dbo].[TabVyrCP] ENABLE TRIGGER [et_TabVyrCP_Gatema_PohybUmisteni_Insert_Update]
GO

