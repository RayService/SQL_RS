USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_CreateJSONRequestForB2A]    Script Date: 26.06.2025 14:33:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_CreateJSONRequestForB2A]
@IdZasilky INT
AS
SET NOCOUNT ON
DECLARE @KodDopravce NVARCHAR(20)
SET @KodDopravce=(SELECT KodDopravce FROM Tabx_BalikobotZasilky WHERE ID=@IdZasilky)
IF @KodDopravce='ppl'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.ID AS [IdBaliku]
, Z.service_type AS service_type
, Z.rec_name AS rec_name
, Z.rec_firm AS rec_firm
, Z.rec_street AS rec_street
, Z.rec_city AS rec_city
, Z.rec_zip AS rec_zip
, Z.rec_country AS rec_country
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, B.real_order_id AS real_order_id
, B.pieces_count AS pieces_count
, FORMAT(B.pickup_date, 'yyyy-MM-dd', 'cs-cz') AS [pickup_date]
, FORMAT(B.pickup_time_from, 'HH:mm', 'cs-cz') AS [pickup_time_from]
, FORMAT(B.pickup_time_to, 'HH:mm', 'cs-cz') AS [pickup_time_to]
, B.note AS note
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='geis'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.ID AS [IdBaliku]
, Z.service_type AS service_type
, Z.rec_name AS rec_name
, Z.rec_firm AS rec_firm
, Z.rec_street AS rec_street
, Z.rec_city AS rec_city
, Z.rec_zip AS rec_zip
, Z.rec_country AS rec_country
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, Z.branch_id AS branch_id
, B.cod_price AS cod_price
, B.cod_currency AS cod_currency
, Z.bank_account_number AS bank_account_number
, B.real_order_id AS real_order_id
, B.pieces_count AS pieces_count
, B.weight AS [weight]
, B.note_driver AS note_driver
, B.note_recipient AS note_recipient
, FORMAT(B.pickup_date, 'yyyy-MM-dd', 'cs-cz') AS [pickup_date]
, B.reference AS [reference]
, B.mu_type AS mu_type
, B.volume AS [volume]
, B.price AS price
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='dpd'
SELECT SUBSTRING(B.GUIDText, 1, 35) AS eid
, B.OrderNumber AS order_number
, B.ID AS [IdBaliku]
, Z.service_type AS service_type
, Z.rec_name AS rec_name
, Z.rec_firm AS rec_firm
, Z.rec_street AS rec_street
, Z.rec_city AS rec_city
, Z.rec_zip AS rec_zip
, Z.rec_country AS rec_country
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, B.real_order_id AS real_order_id
, B.weight AS [weight]
, B.note AS note
, FORMAT(B.pickup_date, 'yyyy-MM-dd', 'cs-cz') AS [pickup_date]
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='gls'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.ID AS [IdBaliku]
, Z.rec_name AS rec_name
, Z.rec_firm AS rec_firm
, Z.rec_street AS rec_street
, Z.rec_city AS rec_city
, Z.rec_zip AS rec_zip
, Z.rec_country AS rec_country
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, B.price AS price
, B.ins_currency AS ins_currency
, B.vs AS vs
, B.real_order_id AS real_order_id
, B.weight AS [weight]
, B.note AS note
, B.del_insurance AS del_insurance
, B.reference AS [reference]
, B.sm1_service AS sm1_service
, B.sm1_text AS sm1_text
, B.sm2_service AS sm2_service
, FORMAT(B.pickup_date, 'yyyy-MM-dd', 'cs-cz') AS [pickup_date]
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='toptrans'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, B.price AS price
, B.cod_price AS cod_price
, B.cod_currency AS cod_currency
, B.vs AS vs
, Z.rec_name AS rec_name
, Z.rec_firm AS rec_firm
, Z.rec_street AS rec_street
, Z.rec_city AS rec_city
, Z.rec_zip AS rec_zip
, Z.rec_country AS rec_country
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, Z.bank_account_number AS bank_account_number
, B.weight AS [weight]
, B.mu_type AS mu_type
, B.pieces_count AS pieces_count
, B.volume AS [volume]
, B.note AS note
, B.comfort_service AS comfort_service
, B.comfort_plus_service AS comfort_plus_service
, CASE WHEN B.swap>2 THEN 0 ELSE B.swap END AS [swap]
, B.wrap_back_count AS wrap_back_count
, B.wrap_back_note AS wrap_back_note
, B.vdl_service AS vdl_service
, B.over_dimension AS over_dimension
, B.delivery_date AS delivery_date
, CAST(CASE WHEN EXISTS(SELECT * FROM Tabx_BalikobotVBalikyADRKody WHERE IdBalik=(SELECT ID FROM Tabx_BalikobotBaliky WHERE OrderNumber=1 AND IdZasilky=@IdZasilky))
       THEN 1
       ELSE B.adr_service
       END AS BIT)
  AS adr_service
, B.bank_account_number AS bank_account_number
, B.reference AS [reference]
, B.ID AS [IdBaliku]
, B.ins_currency AS ins_currency
, FORMAT(B.pickup_date, 'yyyy-MM-dd', 'cs-cz') AS [pickup_date]
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='intime'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, Z.branch_id AS branch_id
, B.price AS price
, B.del_insurance AS del_insurance
, B.cod_price AS cod_price
, B.cod_currency AS cod_currency
, B.vs AS vs
, Z.rec_name AS rec_name
, Z.rec_firm AS rec_firm
, Z.rec_street AS rec_street
, Z.rec_city AS rec_city
, Z.rec_zip AS rec_zip
, Z.rec_country AS rec_country
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, B.weight AS [weight]
, B.ID AS [IdBaliku]
, B.note AS note
, B.phone_notification AS phone_notification
, B.b2c_notification AS b2c_notification
, B.note_driver AS note_driver
, B.note_recipient AS note_recipient
, B.reference AS reference
, B.sms_notification AS sms_notification
, CAST(CASE WHEN B.require_full_age>=1 THEN 1 ELSE 0 END AS BIT) AS [require_full_age]
, B.ins_currency AS ins_currency
, FORMAT(B.pickup_date, 'yyyy-MM-dd', 'cs-cz') AS [pickup_date]
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
GO

