USE [HCvicna]
GO

/****** Object:  Trigger [dbo].[et_TabPlanPrikaz_Plan_zahajeni]    Script Date: 02.07.2025 15:50:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[et_TabPlanPrikaz_Plan_zahajeni] ON [dbo].[TabPlanPrikaz]
FOR INSERT, UPDATE
AS
IF @@ROWCOUNT = 0 RETURN
DECLARE @Akce CHAR
DECLARE @Ins INT
DECLARE @Del INT
DECLARE @IDPlan INT
DECLARE @_EXT_RS_DMR200Orig DATETIME
SET NOCOUNT ON

SELECT @Ins = COUNT(1) FROM INSERTED
SELECT @Del = COUNT(1) FROM DELETED
IF @Ins > 0 AND @Del = 0 SET @Akce = N'I'
IF @Ins = 0 AND @Del > 0 SET @Akce = N'D'
IF @Ins > 0 AND @Del > 0 SET @Akce = N'U'

IF @Akce IN (N'I',N'X')
BEGIN
SET @IDPlan=(SELECT TOP 1 tp.ID FROM TabPlan tp LEFT OUTER JOIN TabPlanPrikaz tpp ON tpp.IDPlan=tp.ID WHERE tpp.ID IN (SELECT I.ID FROM INSERTED I))
SET @_EXT_RS_DMR200Orig=(SELECT TOP 1 tplp.Plan_zadani_X FROM TabPlanPrikaz tplp WITH (NOLOCK) LEFT OUTER JOIN TabPlan tp WITH (NOLOCK) ON tp.ID=tplp.IDPlan WHERE tp.ID=@IDPlan ORDER BY tplp.Plan_zadani_X DESC
)-13
IF (SELECT tpe.ID  FROM TabPlan_EXT as tpe WHERE tpe.ID = @IDPlan) IS NULL
 BEGIN
    INSERT INTO TabPlan_EXT (ID,_EXT_RS_DMR200Orig)
    VALUES (@IDPlan,@_EXT_RS_DMR200Orig)
 END
ELSE
UPDATE tpe SET tpe._EXT_RS_DMR200Orig = @_EXT_RS_DMR200Orig
FROM TabPlan P WITH(NOLOCK)
LEFT OUTER JOIN  TabPlan_EXT tpe WITH(NOLOCK) ON tpe.ID=P.ID
WHERE tpe._EXT_RS_DMR200Orig IS NULL AND P.ID=@IDPlan AND P.Rada IN ('P_GEN','Plan_fix','Plan_quick')
END
GO

ALTER TABLE [dbo].[TabPlanPrikaz] ENABLE TRIGGER [et_TabPlanPrikaz_Plan_zahajeni]
GO

