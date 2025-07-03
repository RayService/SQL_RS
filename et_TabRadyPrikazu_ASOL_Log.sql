USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabRadyPrikazu_ASOL_Log]    Script Date: 03.07.2025 8:03:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  TRIGGER [dbo].[et_TabRadyPrikazu_ASOL_Log] ON [dbo].[TabRadyPrikazu]FOR INSERT, UPDATEASIF @@ROWCOUNT = 0 RETURNDECLARE @Akce CHARDECLARE @Ins INTDECLARE @Del INTDECLARE @IDZurnal INTDECLARE @Filtr BIT = 0SET NOCOUNT ONIF OBJECT_ID(N'tempdb..#TabRadyPrikazu_ASOL_NoLog') IS NOT NULLBEGINIF (SELECT COUNT(*) FROM #TabRadyPrikazu_ASOL_NoLog) = 0RETURNELSESET @Filtr = 1ENDELSECREATE TABLE #TabRadyPrikazu_ASOL_NoLog(ID INT)SELECT @Ins = COUNT(1) FROM INSERTEDSELECT @Del = COUNT(1) FROM DELETEDIF @Ins > 0 AND @Del = 0 SET @Akce = N'I'IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'IF @Akce IN (N'I', N'D') OR UPDATE(AktualizacePrikazuP_PriPredzpr) OR UPDATE(AktualizacePrikazuP_PriZadani) OR UPDATE(AktualizacePrikazuPriZadani) OR UPDATE(GenerOdvVedProdVMJEvid) OR UPDATE(GenerOdvVyrobkuVMJEvid) OR UPDATE(GenerPrijemZmetkuVMJEvid) OR UPDATE(GenerVratkyVMJEvid) OR UPDATE(GenerVydejVMJEvid) OR UPDATE(IDKalkVzorPlanOcen) OR UPDATE(IDKalkVzorSkutOcen) OR UPDATE(IDKalkVzorSkutOcenVedProd) OR UPDATE(KontrCenuVyrPrijemPriReal) OR UPDATE(KontrMaxMnozVyrCisVyrPrik) OR UPDATE(KontrMnozOdebNaVyrCisPrKV) OR UPDATE(KontrOdvedMnozVyrCisVyrPrik) OR UPDATE(KontrOdvZmetNaSkladNesPriUzav) OR UPDATE(KontrolavatPokryMatProPrvOper) OR UPDATE(KontrolavatUkonceniPredchOper) OR UPDATE(KontrolaZadaniUcetnihoKodu) OR UPDATE(KontrolMnozEvidVyrCisUMezd) OR UPDATE(KontrolovatExistKosovniku) OR UPDATE(KontrolovatExistTechnolPos) OR UPDATE(KontrolovatOdvedVedProdPriOdv) OR UPDATE(KontrolovatOdvedVyrOperPriOdv) OR UPDATE(KontrolovatRozpracPriUzav) OR UPDATE(KontrolovatStavPracPomeruZam) OR UPDATE(KontrolovatVydMatPolNaOper) OR UPDATE(KontrolovatVydMatPolPriOdv) OR UPDATE(KontrolPrevodOprZmetPriUzav) OR UPDATE(KontrStavBlokaceDat) OR UPDATE(KontrZadaniKmenStred) OR UPDATE(KontrZadaniZakazky) OR UPDATE(NekontrolMnozEvidKoopMezd) OR UPDATE(NekontrolMnozEvidMezd) OR UPDATE(NekontrolMnozOdvedFinal) OR UPDATE(NekontrolMnozOdvedVedProd) OR UPDATE(NekontrolovatMnozMatPol) OR UPDATE(PredvyplnitVyrCisPriGenRezExp) OR UPDATE(PredvyplnitVyrCisPriGenVrat) OR UPDATE(PredvyplnitVyrCisPriPrijmuZmetku) OR UPDATE(PredvyplnitVyrCisPriVydeji) OR UPDATE(RespekDatumPripPriVypocCeny) OR UPDATE(RespekDatumPripPriVypocCenyVP) OR UPDATE(TypOdvedeni) OR UPDATE(TypOdvedeni_PrimyPrev) OR UPDATE(ZahrnoutRezOperMeziOdvadeci) OR UPDATE(ZdrojNakladStrediska) OR UPDATE(ZdrojNakladStredProPrijem) OR UPDATE(ZdrojNakladStredProPrijemVedPr) OR UPDATE(ZdrojNakladStredProPrijZmetku) OR UPDATE(ZdrojNakladStredProVydej)BEGINEXEC hp_VratZurnalID @IDZurnal OUT

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'AktualizacePrikazuP_PriPredzpr',  @Akce , CONVERT(NVARCHAR(255), D.AktualizacePrikazuP_PriPredzpr), CONVERT(NVARCHAR(255), I.AktualizacePrikazuP_PriPredzpr) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AktualizacePrikazuP_PriPredzpr <> I.AktualizacePrikazuP_PriPredzpr) OR (D.AktualizacePrikazuP_PriPredzpr IS NULL AND I.AktualizacePrikazuP_PriPredzpr IS NOT NULL ) OR (D.AktualizacePrikazuP_PriPredzpr IS NOT NULL AND I.AktualizacePrikazuP_PriPredzpr IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'AktualizacePrikazuP_PriZadani',  @Akce , CONVERT(NVARCHAR(255), D.AktualizacePrikazuP_PriZadani), CONVERT(NVARCHAR(255), I.AktualizacePrikazuP_PriZadani) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AktualizacePrikazuP_PriZadani <> I.AktualizacePrikazuP_PriZadani) OR (D.AktualizacePrikazuP_PriZadani IS NULL AND I.AktualizacePrikazuP_PriZadani IS NOT NULL ) OR (D.AktualizacePrikazuP_PriZadani IS NOT NULL AND I.AktualizacePrikazuP_PriZadani IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'AktualizacePrikazuPriZadani',  @Akce , CONVERT(NVARCHAR(255), D.AktualizacePrikazuPriZadani), CONVERT(NVARCHAR(255), I.AktualizacePrikazuPriZadani) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.AktualizacePrikazuPriZadani <> I.AktualizacePrikazuPriZadani) OR (D.AktualizacePrikazuPriZadani IS NULL AND I.AktualizacePrikazuPriZadani IS NOT NULL ) OR (D.AktualizacePrikazuPriZadani IS NOT NULL AND I.AktualizacePrikazuPriZadani IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'GenerOdvVedProdVMJEvid',  @Akce , CONVERT(NVARCHAR(255), D.GenerOdvVedProdVMJEvid), CONVERT(NVARCHAR(255), I.GenerOdvVedProdVMJEvid) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.GenerOdvVedProdVMJEvid <> I.GenerOdvVedProdVMJEvid) OR (D.GenerOdvVedProdVMJEvid IS NULL AND I.GenerOdvVedProdVMJEvid IS NOT NULL ) OR (D.GenerOdvVedProdVMJEvid IS NOT NULL AND I.GenerOdvVedProdVMJEvid IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'GenerOdvVyrobkuVMJEvid',  @Akce , CONVERT(NVARCHAR(255), D.GenerOdvVyrobkuVMJEvid), CONVERT(NVARCHAR(255), I.GenerOdvVyrobkuVMJEvid) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.GenerOdvVyrobkuVMJEvid <> I.GenerOdvVyrobkuVMJEvid) OR (D.GenerOdvVyrobkuVMJEvid IS NULL AND I.GenerOdvVyrobkuVMJEvid IS NOT NULL ) OR (D.GenerOdvVyrobkuVMJEvid IS NOT NULL AND I.GenerOdvVyrobkuVMJEvid IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'GenerPrijemZmetkuVMJEvid',  @Akce , CONVERT(NVARCHAR(255), D.GenerPrijemZmetkuVMJEvid), CONVERT(NVARCHAR(255), I.GenerPrijemZmetkuVMJEvid) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.GenerPrijemZmetkuVMJEvid <> I.GenerPrijemZmetkuVMJEvid) OR (D.GenerPrijemZmetkuVMJEvid IS NULL AND I.GenerPrijemZmetkuVMJEvid IS NOT NULL ) OR (D.GenerPrijemZmetkuVMJEvid IS NOT NULL AND I.GenerPrijemZmetkuVMJEvid IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'GenerVratkyVMJEvid',  @Akce , CONVERT(NVARCHAR(255), D.GenerVratkyVMJEvid), CONVERT(NVARCHAR(255), I.GenerVratkyVMJEvid) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.GenerVratkyVMJEvid <> I.GenerVratkyVMJEvid) OR (D.GenerVratkyVMJEvid IS NULL AND I.GenerVratkyVMJEvid IS NOT NULL ) OR (D.GenerVratkyVMJEvid IS NOT NULL AND I.GenerVratkyVMJEvid IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'GenerVydejVMJEvid',  @Akce , CONVERT(NVARCHAR(255), D.GenerVydejVMJEvid), CONVERT(NVARCHAR(255), I.GenerVydejVMJEvid) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.GenerVydejVMJEvid <> I.GenerVydejVMJEvid) OR (D.GenerVydejVMJEvid IS NULL AND I.GenerVydejVMJEvid IS NOT NULL ) OR (D.GenerVydejVMJEvid IS NOT NULL AND I.GenerVydejVMJEvid IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'IDKalkVzorPlanOcen',  @Akce , CONVERT(NVARCHAR(255), D.IDKalkVzorPlanOcen), CONVERT(NVARCHAR(255), I.IDKalkVzorPlanOcen) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.IDKalkVzorPlanOcen <> I.IDKalkVzorPlanOcen) OR (D.IDKalkVzorPlanOcen IS NULL AND I.IDKalkVzorPlanOcen IS NOT NULL ) OR (D.IDKalkVzorPlanOcen IS NOT NULL AND I.IDKalkVzorPlanOcen IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'IDKalkVzorSkutOcen',  @Akce , CONVERT(NVARCHAR(255), D.IDKalkVzorSkutOcen), CONVERT(NVARCHAR(255), I.IDKalkVzorSkutOcen) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.IDKalkVzorSkutOcen <> I.IDKalkVzorSkutOcen) OR (D.IDKalkVzorSkutOcen IS NULL AND I.IDKalkVzorSkutOcen IS NOT NULL ) OR (D.IDKalkVzorSkutOcen IS NOT NULL AND I.IDKalkVzorSkutOcen IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'IDKalkVzorSkutOcenVedProd',  @Akce , CONVERT(NVARCHAR(255), D.IDKalkVzorSkutOcenVedProd), CONVERT(NVARCHAR(255), I.IDKalkVzorSkutOcenVedProd) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.IDKalkVzorSkutOcenVedProd <> I.IDKalkVzorSkutOcenVedProd) OR (D.IDKalkVzorSkutOcenVedProd IS NULL AND I.IDKalkVzorSkutOcenVedProd IS NOT NULL ) OR (D.IDKalkVzorSkutOcenVedProd IS NOT NULL AND I.IDKalkVzorSkutOcenVedProd IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrCenuVyrPrijemPriReal',  @Akce , CONVERT(NVARCHAR(255), D.KontrCenuVyrPrijemPriReal), CONVERT(NVARCHAR(255), I.KontrCenuVyrPrijemPriReal) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrCenuVyrPrijemPriReal <> I.KontrCenuVyrPrijemPriReal) OR (D.KontrCenuVyrPrijemPriReal IS NULL AND I.KontrCenuVyrPrijemPriReal IS NOT NULL ) OR (D.KontrCenuVyrPrijemPriReal IS NOT NULL AND I.KontrCenuVyrPrijemPriReal IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrMaxMnozVyrCisVyrPrik',  @Akce , CONVERT(NVARCHAR(255), D.KontrMaxMnozVyrCisVyrPrik), CONVERT(NVARCHAR(255), I.KontrMaxMnozVyrCisVyrPrik) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrMaxMnozVyrCisVyrPrik <> I.KontrMaxMnozVyrCisVyrPrik) OR (D.KontrMaxMnozVyrCisVyrPrik IS NULL AND I.KontrMaxMnozVyrCisVyrPrik IS NOT NULL ) OR (D.KontrMaxMnozVyrCisVyrPrik IS NOT NULL AND I.KontrMaxMnozVyrCisVyrPrik IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrMnozOdebNaVyrCisPrKV',  @Akce , CONVERT(NVARCHAR(255), D.KontrMnozOdebNaVyrCisPrKV), CONVERT(NVARCHAR(255), I.KontrMnozOdebNaVyrCisPrKV) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrMnozOdebNaVyrCisPrKV <> I.KontrMnozOdebNaVyrCisPrKV) OR (D.KontrMnozOdebNaVyrCisPrKV IS NULL AND I.KontrMnozOdebNaVyrCisPrKV IS NOT NULL ) OR (D.KontrMnozOdebNaVyrCisPrKV IS NOT NULL AND I.KontrMnozOdebNaVyrCisPrKV IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrOdvedMnozVyrCisVyrPrik',  @Akce , CONVERT(NVARCHAR(255), D.KontrOdvedMnozVyrCisVyrPrik), CONVERT(NVARCHAR(255), I.KontrOdvedMnozVyrCisVyrPrik) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrOdvedMnozVyrCisVyrPrik <> I.KontrOdvedMnozVyrCisVyrPrik) OR (D.KontrOdvedMnozVyrCisVyrPrik IS NULL AND I.KontrOdvedMnozVyrCisVyrPrik IS NOT NULL ) OR (D.KontrOdvedMnozVyrCisVyrPrik IS NOT NULL AND I.KontrOdvedMnozVyrCisVyrPrik IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrOdvZmetNaSkladNesPriUzav',  @Akce , CONVERT(NVARCHAR(255), D.KontrOdvZmetNaSkladNesPriUzav), CONVERT(NVARCHAR(255), I.KontrOdvZmetNaSkladNesPriUzav) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrOdvZmetNaSkladNesPriUzav <> I.KontrOdvZmetNaSkladNesPriUzav) OR (D.KontrOdvZmetNaSkladNesPriUzav IS NULL AND I.KontrOdvZmetNaSkladNesPriUzav IS NOT NULL ) OR (D.KontrOdvZmetNaSkladNesPriUzav IS NOT NULL AND I.KontrOdvZmetNaSkladNesPriUzav IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrolavatPokryMatProPrvOper',  @Akce , CONVERT(NVARCHAR(255), D.KontrolavatPokryMatProPrvOper), CONVERT(NVARCHAR(255), I.KontrolavatPokryMatProPrvOper) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrolavatPokryMatProPrvOper <> I.KontrolavatPokryMatProPrvOper) OR (D.KontrolavatPokryMatProPrvOper IS NULL AND I.KontrolavatPokryMatProPrvOper IS NOT NULL ) OR (D.KontrolavatPokryMatProPrvOper IS NOT NULL AND I.KontrolavatPokryMatProPrvOper IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrolavatUkonceniPredchOper',  @Akce , CONVERT(NVARCHAR(255), D.KontrolavatUkonceniPredchOper), CONVERT(NVARCHAR(255), I.KontrolavatUkonceniPredchOper) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrolavatUkonceniPredchOper <> I.KontrolavatUkonceniPredchOper) OR (D.KontrolavatUkonceniPredchOper IS NULL AND I.KontrolavatUkonceniPredchOper IS NOT NULL ) OR (D.KontrolavatUkonceniPredchOper IS NOT NULL AND I.KontrolavatUkonceniPredchOper IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrolaZadaniUcetnihoKodu',  @Akce , CONVERT(NVARCHAR(255), D.KontrolaZadaniUcetnihoKodu), CONVERT(NVARCHAR(255), I.KontrolaZadaniUcetnihoKodu) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrolaZadaniUcetnihoKodu <> I.KontrolaZadaniUcetnihoKodu) OR (D.KontrolaZadaniUcetnihoKodu IS NULL AND I.KontrolaZadaniUcetnihoKodu IS NOT NULL ) OR (D.KontrolaZadaniUcetnihoKodu IS NOT NULL AND I.KontrolaZadaniUcetnihoKodu IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrolMnozEvidVyrCisUMezd',  @Akce , CONVERT(NVARCHAR(255), D.KontrolMnozEvidVyrCisUMezd), CONVERT(NVARCHAR(255), I.KontrolMnozEvidVyrCisUMezd) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrolMnozEvidVyrCisUMezd <> I.KontrolMnozEvidVyrCisUMezd) OR (D.KontrolMnozEvidVyrCisUMezd IS NULL AND I.KontrolMnozEvidVyrCisUMezd IS NOT NULL ) OR (D.KontrolMnozEvidVyrCisUMezd IS NOT NULL AND I.KontrolMnozEvidVyrCisUMezd IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrolovatExistKosovniku',  @Akce , CONVERT(NVARCHAR(255), D.KontrolovatExistKosovniku), CONVERT(NVARCHAR(255), I.KontrolovatExistKosovniku) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrolovatExistKosovniku <> I.KontrolovatExistKosovniku) OR (D.KontrolovatExistKosovniku IS NULL AND I.KontrolovatExistKosovniku IS NOT NULL ) OR (D.KontrolovatExistKosovniku IS NOT NULL AND I.KontrolovatExistKosovniku IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrolovatExistTechnolPos',  @Akce , CONVERT(NVARCHAR(255), D.KontrolovatExistTechnolPos), CONVERT(NVARCHAR(255), I.KontrolovatExistTechnolPos) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrolovatExistTechnolPos <> I.KontrolovatExistTechnolPos) OR (D.KontrolovatExistTechnolPos IS NULL AND I.KontrolovatExistTechnolPos IS NOT NULL ) OR (D.KontrolovatExistTechnolPos IS NOT NULL AND I.KontrolovatExistTechnolPos IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrolovatOdvedVedProdPriOdv',  @Akce , CONVERT(NVARCHAR(255), D.KontrolovatOdvedVedProdPriOdv), CONVERT(NVARCHAR(255), I.KontrolovatOdvedVedProdPriOdv) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrolovatOdvedVedProdPriOdv <> I.KontrolovatOdvedVedProdPriOdv) OR (D.KontrolovatOdvedVedProdPriOdv IS NULL AND I.KontrolovatOdvedVedProdPriOdv IS NOT NULL ) OR (D.KontrolovatOdvedVedProdPriOdv IS NOT NULL AND I.KontrolovatOdvedVedProdPriOdv IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrolovatOdvedVyrOperPriOdv',  @Akce , CONVERT(NVARCHAR(255), D.KontrolovatOdvedVyrOperPriOdv), CONVERT(NVARCHAR(255), I.KontrolovatOdvedVyrOperPriOdv) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrolovatOdvedVyrOperPriOdv <> I.KontrolovatOdvedVyrOperPriOdv) OR (D.KontrolovatOdvedVyrOperPriOdv IS NULL AND I.KontrolovatOdvedVyrOperPriOdv IS NOT NULL ) OR (D.KontrolovatOdvedVyrOperPriOdv IS NOT NULL AND I.KontrolovatOdvedVyrOperPriOdv IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrolovatRozpracPriUzav',  @Akce , CONVERT(NVARCHAR(255), D.KontrolovatRozpracPriUzav), CONVERT(NVARCHAR(255), I.KontrolovatRozpracPriUzav) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrolovatRozpracPriUzav <> I.KontrolovatRozpracPriUzav) OR (D.KontrolovatRozpracPriUzav IS NULL AND I.KontrolovatRozpracPriUzav IS NOT NULL ) OR (D.KontrolovatRozpracPriUzav IS NOT NULL AND I.KontrolovatRozpracPriUzav IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrolovatStavPracPomeruZam',  @Akce , CONVERT(NVARCHAR(255), D.KontrolovatStavPracPomeruZam), CONVERT(NVARCHAR(255), I.KontrolovatStavPracPomeruZam) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrolovatStavPracPomeruZam <> I.KontrolovatStavPracPomeruZam) OR (D.KontrolovatStavPracPomeruZam IS NULL AND I.KontrolovatStavPracPomeruZam IS NOT NULL ) OR (D.KontrolovatStavPracPomeruZam IS NOT NULL AND I.KontrolovatStavPracPomeruZam IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrolovatVydMatPolNaOper',  @Akce , CONVERT(NVARCHAR(255), D.KontrolovatVydMatPolNaOper), CONVERT(NVARCHAR(255), I.KontrolovatVydMatPolNaOper) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrolovatVydMatPolNaOper <> I.KontrolovatVydMatPolNaOper) OR (D.KontrolovatVydMatPolNaOper IS NULL AND I.KontrolovatVydMatPolNaOper IS NOT NULL ) OR (D.KontrolovatVydMatPolNaOper IS NOT NULL AND I.KontrolovatVydMatPolNaOper IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrolovatVydMatPolPriOdv',  @Akce , CONVERT(NVARCHAR(255), D.KontrolovatVydMatPolPriOdv), CONVERT(NVARCHAR(255), I.KontrolovatVydMatPolPriOdv) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrolovatVydMatPolPriOdv <> I.KontrolovatVydMatPolPriOdv) OR (D.KontrolovatVydMatPolPriOdv IS NULL AND I.KontrolovatVydMatPolPriOdv IS NOT NULL ) OR (D.KontrolovatVydMatPolPriOdv IS NOT NULL AND I.KontrolovatVydMatPolPriOdv IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrolPrevodOprZmetPriUzav',  @Akce , CONVERT(NVARCHAR(255), D.KontrolPrevodOprZmetPriUzav), CONVERT(NVARCHAR(255), I.KontrolPrevodOprZmetPriUzav) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrolPrevodOprZmetPriUzav <> I.KontrolPrevodOprZmetPriUzav) OR (D.KontrolPrevodOprZmetPriUzav IS NULL AND I.KontrolPrevodOprZmetPriUzav IS NOT NULL ) OR (D.KontrolPrevodOprZmetPriUzav IS NOT NULL AND I.KontrolPrevodOprZmetPriUzav IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrStavBlokaceDat',  @Akce , CONVERT(NVARCHAR(255), D.KontrStavBlokaceDat), CONVERT(NVARCHAR(255), I.KontrStavBlokaceDat) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrStavBlokaceDat <> I.KontrStavBlokaceDat) OR (D.KontrStavBlokaceDat IS NULL AND I.KontrStavBlokaceDat IS NOT NULL ) OR (D.KontrStavBlokaceDat IS NOT NULL AND I.KontrStavBlokaceDat IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrZadaniKmenStred',  @Akce , CONVERT(NVARCHAR(255), D.KontrZadaniKmenStred), CONVERT(NVARCHAR(255), I.KontrZadaniKmenStred) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrZadaniKmenStred <> I.KontrZadaniKmenStred) OR (D.KontrZadaniKmenStred IS NULL AND I.KontrZadaniKmenStred IS NOT NULL ) OR (D.KontrZadaniKmenStred IS NOT NULL AND I.KontrZadaniKmenStred IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'KontrZadaniZakazky',  @Akce , CONVERT(NVARCHAR(255), D.KontrZadaniZakazky), CONVERT(NVARCHAR(255), I.KontrZadaniZakazky) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.KontrZadaniZakazky <> I.KontrZadaniZakazky) OR (D.KontrZadaniZakazky IS NULL AND I.KontrZadaniZakazky IS NOT NULL ) OR (D.KontrZadaniZakazky IS NOT NULL AND I.KontrZadaniZakazky IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'NekontrolMnozEvidKoopMezd',  @Akce , CONVERT(NVARCHAR(255), D.NekontrolMnozEvidKoopMezd), CONVERT(NVARCHAR(255), I.NekontrolMnozEvidKoopMezd) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.NekontrolMnozEvidKoopMezd <> I.NekontrolMnozEvidKoopMezd) OR (D.NekontrolMnozEvidKoopMezd IS NULL AND I.NekontrolMnozEvidKoopMezd IS NOT NULL ) OR (D.NekontrolMnozEvidKoopMezd IS NOT NULL AND I.NekontrolMnozEvidKoopMezd IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'NekontrolMnozEvidMezd',  @Akce , CONVERT(NVARCHAR(255), D.NekontrolMnozEvidMezd), CONVERT(NVARCHAR(255), I.NekontrolMnozEvidMezd) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.NekontrolMnozEvidMezd <> I.NekontrolMnozEvidMezd) OR (D.NekontrolMnozEvidMezd IS NULL AND I.NekontrolMnozEvidMezd IS NOT NULL ) OR (D.NekontrolMnozEvidMezd IS NOT NULL AND I.NekontrolMnozEvidMezd IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'NekontrolMnozOdvedFinal',  @Akce , CONVERT(NVARCHAR(255), D.NekontrolMnozOdvedFinal), CONVERT(NVARCHAR(255), I.NekontrolMnozOdvedFinal) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.NekontrolMnozOdvedFinal <> I.NekontrolMnozOdvedFinal) OR (D.NekontrolMnozOdvedFinal IS NULL AND I.NekontrolMnozOdvedFinal IS NOT NULL ) OR (D.NekontrolMnozOdvedFinal IS NOT NULL AND I.NekontrolMnozOdvedFinal IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'NekontrolMnozOdvedVedProd',  @Akce , CONVERT(NVARCHAR(255), D.NekontrolMnozOdvedVedProd), CONVERT(NVARCHAR(255), I.NekontrolMnozOdvedVedProd) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.NekontrolMnozOdvedVedProd <> I.NekontrolMnozOdvedVedProd) OR (D.NekontrolMnozOdvedVedProd IS NULL AND I.NekontrolMnozOdvedVedProd IS NOT NULL ) OR (D.NekontrolMnozOdvedVedProd IS NOT NULL AND I.NekontrolMnozOdvedVedProd IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'NekontrolovatMnozMatPol',  @Akce , CONVERT(NVARCHAR(255), D.NekontrolovatMnozMatPol), CONVERT(NVARCHAR(255), I.NekontrolovatMnozMatPol) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.NekontrolovatMnozMatPol <> I.NekontrolovatMnozMatPol) OR (D.NekontrolovatMnozMatPol IS NULL AND I.NekontrolovatMnozMatPol IS NOT NULL ) OR (D.NekontrolovatMnozMatPol IS NOT NULL AND I.NekontrolovatMnozMatPol IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'PredvyplnitVyrCisPriGenRezExp',  @Akce , CONVERT(NVARCHAR(255), D.PredvyplnitVyrCisPriGenRezExp), CONVERT(NVARCHAR(255), I.PredvyplnitVyrCisPriGenRezExp) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.PredvyplnitVyrCisPriGenRezExp <> I.PredvyplnitVyrCisPriGenRezExp) OR (D.PredvyplnitVyrCisPriGenRezExp IS NULL AND I.PredvyplnitVyrCisPriGenRezExp IS NOT NULL ) OR (D.PredvyplnitVyrCisPriGenRezExp IS NOT NULL AND I.PredvyplnitVyrCisPriGenRezExp IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'PredvyplnitVyrCisPriGenVrat',  @Akce , CONVERT(NVARCHAR(255), D.PredvyplnitVyrCisPriGenVrat), CONVERT(NVARCHAR(255), I.PredvyplnitVyrCisPriGenVrat) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.PredvyplnitVyrCisPriGenVrat <> I.PredvyplnitVyrCisPriGenVrat) OR (D.PredvyplnitVyrCisPriGenVrat IS NULL AND I.PredvyplnitVyrCisPriGenVrat IS NOT NULL ) OR (D.PredvyplnitVyrCisPriGenVrat IS NOT NULL AND I.PredvyplnitVyrCisPriGenVrat IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'PredvyplnitVyrCisPriPrijmuZmetku',  @Akce , CONVERT(NVARCHAR(255), D.PredvyplnitVyrCisPriPrijmuZmetku), CONVERT(NVARCHAR(255), I.PredvyplnitVyrCisPriPrijmuZmetku) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.PredvyplnitVyrCisPriPrijmuZmetku <> I.PredvyplnitVyrCisPriPrijmuZmetku) OR (D.PredvyplnitVyrCisPriPrijmuZmetku IS NULL AND I.PredvyplnitVyrCisPriPrijmuZmetku IS NOT NULL ) OR (D.PredvyplnitVyrCisPriPrijmuZmetku IS NOT NULL AND I.PredvyplnitVyrCisPriPrijmuZmetku IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'PredvyplnitVyrCisPriVydeji',  @Akce , CONVERT(NVARCHAR(255), D.PredvyplnitVyrCisPriVydeji), CONVERT(NVARCHAR(255), I.PredvyplnitVyrCisPriVydeji) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.PredvyplnitVyrCisPriVydeji <> I.PredvyplnitVyrCisPriVydeji) OR (D.PredvyplnitVyrCisPriVydeji IS NULL AND I.PredvyplnitVyrCisPriVydeji IS NOT NULL ) OR (D.PredvyplnitVyrCisPriVydeji IS NOT NULL AND I.PredvyplnitVyrCisPriVydeji IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'RespekDatumPripPriVypocCeny',  @Akce , CONVERT(NVARCHAR(255), D.RespekDatumPripPriVypocCeny), CONVERT(NVARCHAR(255), I.RespekDatumPripPriVypocCeny) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.RespekDatumPripPriVypocCeny <> I.RespekDatumPripPriVypocCeny) OR (D.RespekDatumPripPriVypocCeny IS NULL AND I.RespekDatumPripPriVypocCeny IS NOT NULL ) OR (D.RespekDatumPripPriVypocCeny IS NOT NULL AND I.RespekDatumPripPriVypocCeny IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'RespekDatumPripPriVypocCenyVP',  @Akce , CONVERT(NVARCHAR(255), D.RespekDatumPripPriVypocCenyVP), CONVERT(NVARCHAR(255), I.RespekDatumPripPriVypocCenyVP) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.RespekDatumPripPriVypocCenyVP <> I.RespekDatumPripPriVypocCenyVP) OR (D.RespekDatumPripPriVypocCenyVP IS NULL AND I.RespekDatumPripPriVypocCenyVP IS NOT NULL ) OR (D.RespekDatumPripPriVypocCenyVP IS NOT NULL AND I.RespekDatumPripPriVypocCenyVP IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'TypOdvedeni',  @Akce , CONVERT(NVARCHAR(255), D.TypOdvedeni), CONVERT(NVARCHAR(255), I.TypOdvedeni) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.TypOdvedeni <> I.TypOdvedeni) OR (D.TypOdvedeni IS NULL AND I.TypOdvedeni IS NOT NULL ) OR (D.TypOdvedeni IS NOT NULL AND I.TypOdvedeni IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'TypOdvedeni_PrimyPrev',  @Akce , CONVERT(NVARCHAR(255), D.TypOdvedeni_PrimyPrev), CONVERT(NVARCHAR(255), I.TypOdvedeni_PrimyPrev) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.TypOdvedeni_PrimyPrev <> I.TypOdvedeni_PrimyPrev) OR (D.TypOdvedeni_PrimyPrev IS NULL AND I.TypOdvedeni_PrimyPrev IS NOT NULL ) OR (D.TypOdvedeni_PrimyPrev IS NOT NULL AND I.TypOdvedeni_PrimyPrev IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'ZahrnoutRezOperMeziOdvadeci',  @Akce , CONVERT(NVARCHAR(255), D.ZahrnoutRezOperMeziOdvadeci), CONVERT(NVARCHAR(255), I.ZahrnoutRezOperMeziOdvadeci) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.ZahrnoutRezOperMeziOdvadeci <> I.ZahrnoutRezOperMeziOdvadeci) OR (D.ZahrnoutRezOperMeziOdvadeci IS NULL AND I.ZahrnoutRezOperMeziOdvadeci IS NOT NULL ) OR (D.ZahrnoutRezOperMeziOdvadeci IS NOT NULL AND I.ZahrnoutRezOperMeziOdvadeci IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'ZdrojNakladStrediska',  @Akce , CONVERT(NVARCHAR(255), D.ZdrojNakladStrediska), CONVERT(NVARCHAR(255), I.ZdrojNakladStrediska) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.ZdrojNakladStrediska <> I.ZdrojNakladStrediska) OR (D.ZdrojNakladStrediska IS NULL AND I.ZdrojNakladStrediska IS NOT NULL ) OR (D.ZdrojNakladStrediska IS NOT NULL AND I.ZdrojNakladStrediska IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'ZdrojNakladStredProPrijem',  @Akce , CONVERT(NVARCHAR(255), D.ZdrojNakladStredProPrijem), CONVERT(NVARCHAR(255), I.ZdrojNakladStredProPrijem) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.ZdrojNakladStredProPrijem <> I.ZdrojNakladStredProPrijem) OR (D.ZdrojNakladStredProPrijem IS NULL AND I.ZdrojNakladStredProPrijem IS NOT NULL ) OR (D.ZdrojNakladStredProPrijem IS NOT NULL AND I.ZdrojNakladStredProPrijem IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'ZdrojNakladStredProPrijemVedPr',  @Akce , CONVERT(NVARCHAR(255), D.ZdrojNakladStredProPrijemVedPr), CONVERT(NVARCHAR(255), I.ZdrojNakladStredProPrijemVedPr) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.ZdrojNakladStredProPrijemVedPr <> I.ZdrojNakladStredProPrijemVedPr) OR (D.ZdrojNakladStredProPrijemVedPr IS NULL AND I.ZdrojNakladStredProPrijemVedPr IS NOT NULL ) OR (D.ZdrojNakladStredProPrijemVedPr IS NOT NULL AND I.ZdrojNakladStredProPrijemVedPr IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'ZdrojNakladStredProPrijZmetku',  @Akce , CONVERT(NVARCHAR(255), D.ZdrojNakladStredProPrijZmetku), CONVERT(NVARCHAR(255), I.ZdrojNakladStredProPrijZmetku) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.ZdrojNakladStredProPrijZmetku <> I.ZdrojNakladStredProPrijZmetku) OR (D.ZdrojNakladStredProPrijZmetku IS NULL AND I.ZdrojNakladStredProPrijZmetku IS NOT NULL ) OR (D.ZdrojNakladStredProPrijZmetku IS NOT NULL AND I.ZdrojNakladStredProPrijZmetku IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))

IF @Akce IN (N'X',N'U')
INSERT INTO TabZmenovyLOG(Tabulka, IDvTab, Sloupec, LogAkce, Old, New, IDZurnal) 
SELECT N'TabRadyPrikazu', ISNULL(D.ID, I.ID), N'ZdrojNakladStredProVydej',  @Akce , CONVERT(NVARCHAR(255), D.ZdrojNakladStredProVydej), CONVERT(NVARCHAR(255), I.ZdrojNakladStredProVydej) , @IDZurnal
FROM DELETED AS D FULL JOIN INSERTED AS I ON D.ID = I.ID
WHERE ((D.ZdrojNakladStredProVydej <> I.ZdrojNakladStredProVydej) OR (D.ZdrojNakladStredProVydej IS NULL AND I.ZdrojNakladStredProVydej IS NOT NULL ) OR (D.ZdrojNakladStredProVydej IS NOT NULL AND I.ZdrojNakladStredProVydej IS NULL ) OR @Akce = N'I')AND (@Filtr = 0 OR I.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog) OR D.ID IN (SELECT ID FROM #TabRadyPrikazu_ASOL_NoLog))IF @Filtr = 0 AND OBJECT_ID(N'tempdb..#TabRadyPrikazu_ASOL_NoLog') IS NOT NULLDROP TABLE #TabRadyPrikazu_ASOL_NoLogEND
GO

ALTER TABLE [dbo].[TabRadyPrikazu] ENABLE TRIGGER [et_TabRadyPrikazu_ASOL_Log]
GO

