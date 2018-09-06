-- ---------------------------------- --
-- Hrabovsky Marián, 4th of June 2015 --
-- ---------------------------------- --

-- ##BEGIN_VIEW##

FI___BANK_DATA;Bankstammdaten;Bank Master Data;1

-- ##TRANSACTION_CODE##

FI03

-- ##OPTIMIZE##

LEVEL_1;MANDT;1

-- ##LANGUAGES##

de;en

-- ##DICTIONARY##

BANKS;Bankland;Country;1
BANKS_TXT;Bankland Name;Country Name;1
BANKL;Bankschlüssel;Bank Key;1
BANKA;Geldinstitut;Bank Name;1
PROVZ;Region;Region;1
PROVZ_TXT;Region Name;Region Name;1
STRAS;Strasse;Street;1
ORT01;Ort;City;1
BRNCH;Zweigstelle;Branch;1
SWIFT;SWIFT-Code;SWIFT Code;1
BGRUP;Bankengruppe;Bank Group;1
XPGRO;Postbank-GiroKz;Postbank Giro Code;1
BNKLZ;Bankleitzahl;Bank Code;1
ERDAT;Angelegt am;Created Date;1
ERNAM;Angelegt von;Created by;1
VERS;Format Bankdaten;Bank Data Format;1
LANG_KEY;Sprachschlüssel;Language Key;0
MANDT;Mandant;Client;0
BANKL_TXT;Bankschlüssel (Wertehilfe);Bank Key (Input Help);0
      
-- ##KEYS##

CREATE INDEX _mandt_land1_spras on database_final.T005T (MANDT, LAND1, SPRAS);
CREATE INDEX _mandt_land1_bland_spras on database_final.T005U (MANDT, LAND1, BLAND, SPRAS);

-- ##REPORT_PARAMETERS##

in_banks;STRING;Bankland;Country
in_bankl;STRING;Bankschlüssel;Bank Key

-- ##REPORT_PARAMETER_REFERENCES##

in_banks;;FI___BANK_DATA;BANKS;1;0;0;0;BANKS;BANKS_TXT
in_bankl;;FI___BANK_DATA;BANKL;1;0;0;0;BANKL;BANKL_TXT

-- ##REPORT_PARAMETER_FILTER##

in_banks = BANKS AND in_bankl = BANKL

-- ##VIEW##

  -- ---------------------- --
  -- Table of language keys --
  -- ---------------------- --
DROP TABLE IF EXISTS LANGUAGE_KEYS;
CREATE TABLE LANGUAGE_KEYS
ENGINE = MyISAM
  SELECT BINARY('E') AS LANG_KEY
  UNION
  SELECT BINARY('D') AS LANG_KEY;

  -- ---------- --
  -- Main table --
  -- ---------- --
DROP TABLE IF EXISTS FI___BANK_DATA;
CREATE TABLE FI___BANK_DATA
(
	INDEX (MANDT, BANKS, BANKL),
	INDEX (BANKS, BANKL)
) ENGINE = MyISAM
  SELECT
	  BNKA.BANKS																																													AS BANKS,
	  T005T.LANDX 																																													AS BANKS_TXT,
	  BNKA.BANKL																																													AS BANKL,
	  BNKA.BANKA																																													AS BANKA,
	  BNKA.PROVZ																																													AS PROVZ,
	  T005U.BEZEI 																																													AS PROVZ_TXT,
	  BNKA.STRAS																																													AS STRAS,
	  BNKA.ORT01																																													AS ORT01,
	  BNKA.BRNCH																																													AS BRNCH,
	  BNKA.SWIFT																																													AS SWIFT,
	  BNKA.BGRUP																																													AS BGRUP,
	  CASE LANG.LANG_KEY																															
	    WHEN 'D' THEN IF(IFNULL(BNKA.XPGRO, '') = 'X', 'Ja', 'Nein')																															
		WHEN 'E' THEN IF(IFNULL(BNKA.XPGRO, '') = 'X', 'Yes', 'No')																															
	  END 																																															AS XPGRO,
	  BNKA.BNKLZ																																													AS BNKLZ,
	  IF(DATE(BNKA.ERDAT) != 0, DATE(BNKA.ERDAT), NULL) 																																			AS ERDAT,
	  BNKA.ERNAM																																													AS ERNAM,
	  BNKA.VERS																																														AS VERS,
	  LANG.LANG_KEY																																													AS LANG_KEY,
	  BNKA.MANDT																																													AS MANDT,
	  CONCAT_WS(' ', RPAD(BNKA.BANKS, 7, ' '), RPAD(BNKA.BANKA, 65, ' '), RPAD(BNKA.STRAS, 40, ' '), RPAD(BNKA.ORT01, 40, ' '), RPAD(BNKA.BRNCH, 45, ' '), RPAD(BNKA.BNKLZ, 20, ' '), BNKA.SWIFT)	AS BANKL_TXT
	FROM 
	  database_final.BNKA 				AS BNKA
	  LEFT JOIN LANGUAGE_KEYS			AS LANG 	ON TRUE
	  LEFT JOIN database_final.T005T	AS T005T	ON (T005T.MANDT = BNKA.MANDT AND T005T.LAND1 = BNKA.BANKS AND T005T.SPRAS = LANG.LANG_KEY)
	  LEFT JOIN database_final.T005U	AS T005U 	ON (T005U.MANDT = BNKA.MANDT AND T005U.LAND1 =  BNKA.BANKS AND T005U.BLAND = BNKA.PROVZ AND T005U.SPRAS = LANG.LANG_KEY);

-- ##END_VIEW##