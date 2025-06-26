USE [RayService]
GO

/****** Object:  StoredProcedure [dbo].[hpx_Balikobot_CreateJSONRequestForADD]    Script Date: 26.06.2025 14:28:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*rpBalikobot.Export*/CREATE PROC [dbo].[hpx_Balikobot_CreateJSONRequestForADD]
@IdZasilky INT
AS
-- ###################################################################
-- #### !! UPOZORNĚNÍ !!
-- #### Od verze 2.0.2022.0203 se pro generování datové věty nadále
-- #### NEPOUŽÍVÁ procedura hpx_Balikobot_CreateJSONRequestForADD.
-- #### Součástí zdrojových kódů zůstává už jen historicky kvůli
-- #### případné zpětné kompatibilitě a může být v budoucích verzích
-- #### pluginu zcela odstraněna.
-- ###################################################################
SET NOCOUNT ON
DECLARE @KodDopravce NVARCHAR(20)
SET @KodDopravce=(SELECT KodDopravce FROM Tabx_BalikobotZasilky WHERE ID=@IdZasilky)
IF @KodDopravce='cp'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, Z.branch_id AS branch_id
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
, B.weight AS [weight]
, B.width AS [width]
, B.length AS [length]
, B.height AS [height]
, B.services AS [services]
, B.note AS note
, B.reference AS [reference]
, B.ID AS [IdBaliku]
, CAST(CASE WHEN B.require_full_age>=1 THEN 1 ELSE 0 END AS BIT) AS [require_full_age]
, ISNULL(CAST(full_age_data AS NVARCHAR), '') AS full_age_data
, B.ins_currency AS ins_currency
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='dpd'
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
, B.width AS [width]
, B.length AS [length]
, B.height AS [height]
, B.credit_card AS credit_card
, B.sms_notification AS sms_notification
, B.note AS note
, B.reference AS [reference]
, CASE WHEN B.swap>=1 THEN 1 ELSE 0 END AS [swap]
, B.ID AS [IdBaliku]
, CAST(CASE WHEN B.require_full_age>=1 THEN 1 ELSE 0 END AS BIT) AS [require_full_age]
, B.ins_currency AS ins_currency
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='geis'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, Z.branch_id AS branch_id
, B.price AS price
, B.del_insurance AS del_insurance
, CAST(CASE WHEN B.del_exworks>=1 THEN 1 ELSE 0 END AS BIT) AS [del_exworks]
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
, B.credit_card AS credit_card
, B.ID AS [IdBaliku]
, B.note AS note
, B.phone_notification AS phone_notification
, B.b2c_notification AS b2c_notification
, B.note_driver AS note_driver
, B.note_recipient AS note_recipient
, B.reference AS reference
, B.sms_notification AS sms_notification
, B.vdl_service AS vdl_service
, B.volume AS [volume]
, B.width AS [width]
, B.length AS [length]
, B.height AS [height]
, B.mu_type AS mu_type
, B.pieces_count AS pieces_count
, B.email_notification AS email_notification
, B.ins_currency AS ins_currency
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='ppl'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, Z.branch_id AS branch_id
, B.price AS price
, B.del_insurance AS del_insurance
, B.del_evening AS del_evening
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
, Z.bank_code AS bank_code
, B.weight AS [weight]
, B.width AS [width]
, B.length AS [length]
, B.height AS [height]
, B.ID AS [IdBaliku]
, B.mu_type AS mu_type
, B.pieces_count AS pieces_count
, CAST(CASE WHEN B.del_exworks>=1 THEN 1 ELSE 0 END AS BIT) AS [del_exworks]
, B.comfort_service AS comfort_service
, B.app_disp AS app_disp
, B.note AS note
, B.wrap_back_count AS wrap_back_count
, B.reference AS [reference]
, B.ins_currency AS ins_currency
, CAST(CASE WHEN EXISTS(SELECT * FROM Tabx_BalikobotVBalikyADRKody WHERE IdBalik=(SELECT ID FROM Tabx_BalikobotBaliky WHERE OrderNumber=1 AND IdZasilky=@IdZasilky))
       THEN 1
       ELSE B.adr_service
       END AS BIT)
  AS adr_service
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='zasilkovna'
SELECT SUBSTRING(B.GUIDText, 1, 24) AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.branch_id AS branch_id
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
, Z.rec_region AS rec_region
, B.weight AS [weight]
, B.reference AS [reference]
, CASE WHEN B.swap>=1 THEN 1 ELSE 0 END AS [swap]
, B.ID AS [IdBaliku]
, CAST(CASE WHEN B.require_full_age>=1 THEN 1 ELSE 0 END AS BIT) AS [require_full_age]
, B.ins_currency AS ins_currency
, B.note AS note
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
, B.phone_delivery_notification AS phone_delivery_notification
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='gls'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, Z.branch_id AS branch_id
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
, B.weight AS [weight]
, B.note AS note
, B.reference AS [reference]
, CASE WHEN B.swap>=1 THEN 1 ELSE 0 END AS [swap]
, B.sm1_service AS sm1_service
, B.sm1_text AS sm1_text
, B.sm2_service AS sm2_service
, B.ins_currency AS ins_currency
, B.sms_notification AS sms_notification
, B.ID AS [IdBaliku]
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='ulozenka'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, CASE WHEN Z.service_type='7' THEN O.branch_zip ELSE Z.branch_id END  AS branch_id
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
, B.weight AS [weight]
, B.ID AS [IdBaliku]
, B.credit_card AS credit_card
, B.password AS password
, B.note AS note
, B.reference AS [reference]
, CAST(CASE WHEN B.require_full_age>=1 THEN 1 ELSE 0 END AS BIT) AS [require_full_age]
, B.ins_currency AS ins_currency
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
LEFT OUTER JOIN Tabx_BalikobotOdbernaMista O ON O.KodDopravce=Z.KodDopravce AND O.service_type=Z.service_type AND O.branch_id=Z.branch_id
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
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='pbh'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, B.price AS price
, B.del_insurance AS del_insurance
, B.cod_price AS cod_price
, B.cod_currency AS cod_currency
, B.vs AS vs
, B.weight AS [weight]
, Z.rec_name AS rec_name
, Z.rec_firm AS rec_firm
, Z.rec_street AS rec_street
, Z.rec_city AS rec_city
, Z.rec_zip AS rec_zip
, Z.rec_country AS rec_country
, Z.rec_region AS rec_region
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, B.reference AS [reference]
, Z.rec_id AS [rec_id]
, B.ID AS [IdBaliku]
, B.ins_currency AS ins_currency
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='dhl'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, B.price AS price
, B.del_insurance AS del_insurance
, CAST(CASE WHEN B.del_exworks>=1 THEN 1 ELSE 0 END AS BIT) AS [del_exworks]
, B.cod_currency AS cod_currency
, Z.rec_name AS rec_name
, Z.rec_firm AS rec_firm
, Z.rec_street AS rec_street
, Z.rec_city AS rec_city
, Z.rec_zip AS rec_zip
, Z.rec_country AS rec_country
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, B.weight AS [weight]
, B.services AS [services]
, B.width AS [width]
, B.length AS [length]
, B.height AS [height]
, CASE WHEN B.swap>=1 THEN 1 ELSE 0 END AS [swap]
, B.swap_option AS swap_option
, (SELECT COUNT(*) FROM Tabx_BalikobotBaliky WHERE IdZasilky=Z.ID) AS pieces_count
, B.content AS content
, B.terms_of_trade AS terms_of_trade
, B.invoice_pdf AS invoice_pdf
, B.reference AS [reference]
, B.ID AS [IdBaliku]
, B.ins_currency AS ins_currency
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID AND B.OrderNumber=1
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='ups'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, Z.AccessPointUPS AS branch_id
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
, Z.rec_region AS rec_region
, Z.rec_country AS rec_country
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, Z.neutralize
, Z.neutralize_account_number
, Z.neutralize_name
, Z.neutralize_firm
, Z.neutralize_phone
, Z.neutralize_email
, Z.neutralize_street
, Z.neutralize_city
, Z.neutralize_zip
, Z.neutralize_region
, Z.neutralize_country
, B.weight AS [weight]
, B.width AS [width]
, B.length AS [length]
, B.height AS [height]
, B.reference AS reference
, CASE
    WHEN B.swap=0 THEN 0
    WHEN B.swap=1 THEN 0
    WHEN B.swap=2 THEN 0
    WHEN B.swap=3 THEN 1
    WHEN B.swap=4 THEN 2
    ELSE 1
  END AS [swap]
, B.content AS content
, B.note AS note
, B.email_notification AS email_notification
, B.ID AS [IdBaliku]
, CASE
    WHEN B.require_full_age=0 THEN NULL
    WHEN B.require_full_age=1 THEN 1
    WHEN B.require_full_age=2 THEN 1
    WHEN B.require_full_age=3 THEN 2
    WHEN B.require_full_age=4 THEN 3
    ELSE NULL
  END AS [require_full_age]
, CASE
    WHEN B.del_exworks=0 THEN 0
    WHEN B.del_exworks=1 THEN 0
    WHEN B.del_exworks=2 THEN 0
    WHEN B.del_exworks=3 THEN 1
    WHEN B.del_exworks=4 THEN 2
    WHEN B.del_exworks=5 THEN 3
    ELSE 0
  END AS [del_exworks]
, B.del_exworks_account_number AS [del_exworks_account_number]
, B.del_exworks_zip AS [del_exworks_zip]
, B.ins_currency AS ins_currency
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='sp'
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
, B.services AS [services]
, B.note AS note
, B.reference AS [reference]
, B.ID AS [IdBaliku]
, B.ins_currency AS ins_currency
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='tnt'
SELECT SUBSTRING(B.GUIDText, 1, 20) AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
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
, Z.rec_region AS rec_region
, Z.rec_country AS rec_country
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, B.weight AS [weight]
, B.width AS [width]
, B.length AS [length]
, B.height AS [height]
, B.note AS note
, CASE WHEN B.swap>=1 THEN 1 ELSE 0 END AS [swap]
, B.volume AS [volume]
, B.services AS [services]
, B.del_exworks_account_number AS [del_exworks_account_number]
, FORMAT(B.pickup_date, 'yyyy-MM-dd', 'cs-cz') AS [pickup_date]
, B.reference AS [reference]
, B.ID AS [IdBaliku]
, B.ins_currency AS ins_currency
, B.content AS content
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='DHLSK'
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
, B.reference AS [reference]
, B.ins_currency AS ins_currency
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='SPS'
SELECT SUBSTRING(B.GUIDText, 1, 20) AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, Z.branch_id AS branch_id
, B.price AS price
, B.del_insurance AS del_insurance
, CAST(CASE WHEN B.del_exworks>=1 THEN 1 ELSE 0 END AS BIT) AS [del_exworks]
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
, B.credit_card AS credit_card
, B.sms_notification AS sms_notification
, (SELECT COUNT(*) FROM Tabx_BalikobotBaliky WHERE IdZasilky=Z.ID) AS pieces_count
, B.email_notification AS email_notification
, B.phone_notification AS phone_notification
, B.reference AS [reference]
, B.ID AS [IdBaliku]
, B.ins_currency AS ins_currency
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID AND B.OrderNumber=1
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='gw'
SELECT SUBSTRING(B.GUIDText, 1, 20) AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, B.price AS price
, B.del_insurance AS del_insurance
, B.ins_currency AS ins_currency
, B.del_exworks AS del_exworks
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
, B.reference AS reference
, B.sms_notification AS sms_notification
, B.volume AS [volume]
, B.mu_type AS mu_type
, B.pieces_count AS pieces_count
, B.content AS content
, B.services AS [services]
, B.terms_of_trade AS terms_of_trade
, B.get_piece_numbers as get_piece_numbers
, B.delivery_date AS delivery_date
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='fofr'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, B.price AS price
, B.ins_currency AS ins_currency
, B.del_exworks AS del_exworks
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
, Z.bank_code AS bank_code
, B.weight AS [weight]
, B.width AS [width]
, B.length AS [length]
, B.height AS [height]
, B.ID AS [IdBaliku]
, B.note AS note
, B.note_driver AS note_driver
, B.reference AS reference
, B.sms_notification AS sms_notification
, B.volume AS [volume]
, B.mu_type AS mu_type
, B.pieces_count AS pieces_count
, B.services AS [services]
, B.delivery_date AS delivery_date
, FORMAT(B.pickup_date, 'yyyy-MM-dd', 'cs-cz') AS [pickup_date]
, B.payer AS [payer]
, B.content AS content
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='raben'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, Z.branch_id AS branch_id
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
, B.weight AS [weight]
, B.width AS [width]
, B.length AS [length]
, B.loading_length_pallets AS [loading_length_pallets]
, B.height AS [height]
, B.ID AS [IdBaliku]
, B.note AS note
, B.reference AS reference
, B.sms_notification AS sms_notification
, B.email_notification AS email_notification
, B.phone_notification AS phone_notification
, B.volume AS [volume]
, B.mu_type AS mu_type
, B.pieces_count AS pieces_count
, B.content AS content
, B.services AS [services]
, B.wrap_back_count AS wrap_back_count
, B.delivery_date AS delivery_date
, FORMAT(B.delivery_time_from, 'HH:mm', 'cs-cz') AS [delivery_time_from]
, FORMAT(B.delivery_time_to, 'HH:mm', 'cs-cz') AS [delivery_time_to]
, FORMAT(B.pickup_date, 'yyyy-MM-dd', 'cs-cz') AS [pickup_date]
, FORMAT(B.pickup_time_from, 'HH:mm', 'cs-cz') AS [pickup_time_from]
, FORMAT(B.pickup_time_to, 'HH:mm', 'cs-cz') AS [pickup_time_to]
, B.terms_of_trade AS terms_of_trade
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='dachser'
SELECT B.GUIDText AS eid
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, Z.service_type AS service_type
, B.price AS price
, Z.rec_name AS rec_name
, Z.rec_firm AS rec_firm
, Z.rec_street AS rec_street
, Z.rec_street_append AS rec_street_append
, Z.rec_city AS rec_city
, Z.rec_zip AS rec_zip
, Z.rec_country AS rec_country
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, B.weight AS [weight]
, B.width AS [width]
, B.length AS [length]
, B.height AS [height]
, B.ID AS [IdBaliku]
, B.note AS note
, B.reference AS reference
, B.sms_notification AS sms_notification
, B.email_notification AS email_notification
, B.phone_delivery_notification AS phone_delivery_notification
, B.volume AS [volume]
, B.mu_type AS mu_type
, B.pieces_count AS pieces_count
, B.content AS content
, B.services AS [services]
, B.delivery_date AS delivery_date
, B.terms_of_trade AS terms_of_trade
, B.ins_currency AS ins_currency
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='kurier'
SELECT B.GUIDText AS eid
, Z.service_type AS service_type
, Z.rec_name AS rec_name
, Z.rec_firm AS rec_firm
, Z.rec_street AS rec_street
, Z.rec_city AS rec_city
, Z.rec_zip AS rec_zip
, Z.rec_country AS rec_country
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, B.price AS price
, B.cod_price AS cod_price
, B.cod_currency AS cod_currency
, B.vs AS vs
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, B.reference AS reference
, B.weight AS [weight]
, B.phone_notification AS phone_notification
, B.sms_notification AS sms_notification
, B.del_insurance AS del_insurance
, Z.bank_account_number AS bank_account_number
, B.ID AS [IdBaliku]
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='dsv'
SELECT B.GUIDText AS eid
, Z.service_type AS service_type
, Z.rec_name AS rec_name
, Z.rec_firm AS rec_firm
, Z.rec_street AS rec_street
, Z.rec_city AS rec_city
, Z.rec_zip AS rec_zip
, Z.rec_country AS rec_country
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, B.terms_of_trade AS terms_of_trade
, B.terms_of_trade_location AS terms_of_trade_location
, B.price AS price
, B.ins_currency AS ins_currency
, B.ins_category AS ins_category
, B.cod_price AS cod_price
, B.cod_currency AS cod_currency
, B.vs AS vs
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, B.reference AS reference
, B.weight AS [weight]
, B.width AS [width]
, B.length AS [length]
, B.height AS [height]
, B.loading_length AS [loading_length]
, B.note AS note
, B.note_driver AS note_driver
, B.sms_notification AS sms_notification
, B.email_notification AS email_notification
, B.phone_notification AS phone_notification
, FORMAT(B.pickup_date, 'yyyy-MM-dd', 'cs-cz') AS [pickup_date]
, FORMAT(B.pickup_time_from, 'HH:mm', 'cs-cz') AS [pickup_time_from]
, FORMAT(B.pickup_time_to, 'HH:mm', 'cs-cz') AS [pickup_time_to]
, B.delivery_date AS delivery_date
, FORMAT(B.delivery_time_from, 'HH:mm', 'cs-cz') AS [delivery_time_from]
, FORMAT(B.delivery_time_to, 'HH:mm', 'cs-cz') AS [delivery_time_to]
, B.mu_type AS mu_type
, B.pieces_count AS pieces_count
, B.content AS content
, B.services AS [services]
, B.wrap_back_count AS wrap_back_count
, B.ID AS [IdBaliku]
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
IF @KodDopravce='dhlfreightec'
SELECT B.GUIDText AS eid
, Z.service_type AS service_type
, Z.rec_name AS rec_name
, Z.rec_firm AS rec_firm
, Z.rec_street AS rec_street
, Z.rec_city AS rec_city
, Z.rec_zip AS rec_zip
, Z.rec_country AS rec_country
, Z.rec_email AS rec_email
, Z.rec_phone AS rec_phone
, B.terms_of_trade AS terms_of_trade
, B.price AS price
, B.ins_currency AS ins_currency
, B.cod_price AS cod_price
, B.cod_currency AS cod_currency
, B.vs AS vs
, B.OrderNumber AS order_number
, B.real_order_id AS real_order_id
, B.reference AS reference
, B.weight AS [weight]
, B.width AS [width]
, B.length AS [length]
, B.height AS [height]
, B.volume AS [volume]
, B.note AS note
, B.mu_type AS mu_type
, B.pieces_count AS pieces_count
, CAST(CASE WHEN B.del_exworks>=1 THEN 1 ELSE 0 END AS BIT) AS [del_exworks]
, B.wrap_back_count AS wrap_back_count
, Z.branch_id AS branch_id
, B.app_disp AS app_disp
, B.comfort_service AS comfort_service
, B.pickup_manipulation_cart AS pickup_manipulation_cart
, B.pickup_manipulation_lift AS pickup_manipulation_lift
, B.delivery_manipulation_cart AS delivery_manipulation_cart
, B.delivery_manipulation_lift AS delivery_manipulation_lift
, B.ID AS [IdBaliku]
FROM Tabx_BalikobotZasilky Z
LEFT OUTER JOIN Tabx_BalikobotBaliky B ON B.IdZasilky=Z.ID
WHERE Z.ID=@IdZasilky
ORDER BY B.OrderNumber ASC
GO

