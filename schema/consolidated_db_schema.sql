-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: consolidated_db
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `patient_isanteplus`
--

DROP TABLE IF EXISTS `patient_isanteplus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_isanteplus` (
  `identifier` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `st_id` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `national_id` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `isante_id` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `patient_id` int NOT NULL,
  `location_id` int DEFAULT NULL,
  `site_code` text COLLATE utf8mb3_unicode_ci,
  `given_name` longtext COLLATE utf8mb3_unicode_ci,
  `family_name` longtext COLLATE utf8mb3_unicode_ci,
  `gender` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `telephone` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `last_address` longtext COLLATE utf8mb3_unicode_ci,
  `degree` longtext COLLATE utf8mb3_unicode_ci,
  `vih_status` int DEFAULT '0',
  `arv_status` int DEFAULT NULL,
  `mother_name` longtext COLLATE utf8mb3_unicode_ci,
  `contact_name` text COLLATE utf8mb3_unicode_ci,
  `occupation` int DEFAULT NULL,
  `maritalStatus` int DEFAULT NULL,
  `place_of_birth` longtext COLLATE utf8mb3_unicode_ci,
  `creator` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_created` date NOT NULL,
  `death_date` date DEFAULT NULL,
  `cause_of_death` longtext COLLATE utf8mb3_unicode_ci,
  `first_visit_date` datetime DEFAULT NULL,
  `last_visit_date` datetime DEFAULT NULL,
  `date_started_arv` datetime DEFAULT NULL,
  `next_visit_date` date DEFAULT NULL,
  `last_inserted_date` datetime NOT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `transferred_in` int DEFAULT NULL,
  `date_transferred_in` datetime DEFAULT NULL,
  `date_started_arv_other_site` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `uuid` varchar(250) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`patient_id`,`mspp_code`,`date_created`),
  KEY `idx_isanteplus_mspp_inserted` (`mspp_code`,`date_created`),
  KEY `idx_isanteplus_mspp_birth` (`mspp_code`,`birthdate`),
  KEY `idx_isanteplus_mspp_gender` (`mspp_code`,`gender`),
  KEY `idx_isanteplus_mspp_status` (`mspp_code`,`vih_status`),
  KEY `idx_isanteplus_location_inserted` (`location_id`,`date_created`),
  KEY `idx_patient_arv_status` (`arv_status`,`voided`),
  KEY `idx_patient_arv_voided` (`arv_status`,`voided`),
  KEY `idx_patient_mspp_arv` (`mspp_code`,`arv_status`,`voided`),
  KEY `idx_patient_id_mspp` (`patient_id`,`mspp_code`,`voided`),
  KEY `idx_voided_mspp` (`voided`,`mspp_code`),
  KEY `idx_patient_location_date_new` (`location_id`,`last_inserted_date`),
  KEY `idx_patient_mspp_created_new` (`mspp_code`,`date_created`),
  KEY `idx_patient_mspp_gender_new` (`mspp_code`,`gender`),
  KEY `idx_patient_mspp_birth_new` (`mspp_code`,`birthdate`),
  KEY `idx_patient_mspp_death_new` (`mspp_code`,`death_date`),
  KEY `idx_date_inserted_new` (`last_inserted_date`),
  KEY `idx_date_updated_new` (`last_updated_date`),
  KEY `idx_patient_sync_status_new` (`synced`,`last_updated_date`),
  KEY `idx_overview_status` (`voided`,`vih_status`),
  KEY `idx_overview_trend` (`voided`,`date_created`,`vih_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`date_created`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_visit`
--

DROP TABLE IF EXISTS `patient_visit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_visit` (
  `visit_date` date DEFAULT NULL,
  `visit_id` int DEFAULT NULL,
  `encounter_id` int NOT NULL DEFAULT '0',
  `location_id` int NOT NULL DEFAULT '0',
  `patient_id` int NOT NULL DEFAULT '0',
  `start_date` date DEFAULT NULL,
  `stop_date` date DEFAULT NULL,
  `creator` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `encounter_type` int DEFAULT NULL,
  `form_id` int DEFAULT NULL,
  `next_visit_date` date DEFAULT NULL,
  `last_insert_date` date DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`encounter_id`,`location_id`,`mspp_code`),
  KEY `location_id` (`location_id`),
  KEY `form_id` (`form_id`),
  KEY `patient_id` (`patient_id`),
  KEY `visit_id` (`visit_id`),
  KEY `date_updated_ix` (`date_updated`),
  KEY `idx_visit_sync_status` (`synced`,`date_updated`),
  KEY `idx_visit_mspp_date` (`mspp_code`,`date_updated`),
  KEY `idx_voided_mspp` (`voided`,`mspp_code`),
  KEY `idx_pv_voided_visit_date` (`voided`,`visit_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `visit`
--

DROP TABLE IF EXISTS `visit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visit` (
  `encounter_id` int NOT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `patient_id` int NOT NULL,
  `location_id` int DEFAULT NULL,
  `location_value` varchar(250) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `encounter_type` varchar(250) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `visit_date` datetime NOT NULL,
  `encounter_date` datetime NOT NULL,
  `date_changed` datetime DEFAULT NULL,
  `date_inserted` datetime NOT NULL,
  `date_updated` datetime DEFAULT NULL,
  `visit_id` int NOT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  PRIMARY KEY (`encounter_id`,`mspp_code`,`visit_date`),
  KEY `idx_date_inserted` (`date_inserted`),
  KEY `idx_date_updated` (`date_updated`),
  KEY `idx_visit_mspp_visit_date` (`mspp_code`,`visit_date`),
  KEY `idx_visit_mspp_encounter_date` (`mspp_code`,`encounter_date`),
  KEY `idx_visit_mspp_patient` (`mspp_code`,`patient_id`),
  KEY `idx_visit_mspp_type` (`mspp_code`,`encounter_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`visit_date`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_dispensing`
--

DROP TABLE IF EXISTS `patient_dispensing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_dispensing` (
  `patient_id` int NOT NULL,
  `visit_id` int DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `obs_id` int DEFAULT NULL,
  `obs_group_id` int DEFAULT NULL,
  `visit_date` datetime NOT NULL,
  `encounter_id` int NOT NULL,
  `provider_id` int DEFAULT NULL,
  `drug_id` int NOT NULL,
  `dose_day` double DEFAULT NULL,
  `pills_amount` double DEFAULT NULL,
  `dispensation_date` date DEFAULT NULL,
  `next_dispensation_date` date DEFAULT NULL,
  `dispensation_location` int DEFAULT '0',
  `ddp` int DEFAULT '0',
  `arv_drug` int DEFAULT '1066',
  `rx_or_prophy` int DEFAULT NULL,
  `treatment_regime_lines` text COLLATE utf8mb3_unicode_ci,
  `last_updated_date` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`encounter_id`,`drug_id`,`mspp_code`,`visit_date`),
  KEY `idx_visit_date` (`visit_date`),
  KEY `idx_encounter_id` (`encounter_id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_last_updated_date` (`date_updated`),
  KEY `idx_patient_dispensing_mspp_dispensation_date` (`mspp_code`,`dispensation_date`),
  KEY `idx_patient_dispensing_mspp_next_dispensation` (`mspp_code`,`next_dispensation_date`),
  KEY `idx_patient_dispensing_mspp_drug_id` (`mspp_code`,`drug_id`),
  KEY `idx_patient_dispensing_mspp_patient` (`mspp_code`,`patient_id`),
  KEY `idx_voided_mspp` (`voided`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`visit_date`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_laboratory_isanteplus`
--

DROP TABLE IF EXISTS `patient_laboratory_isanteplus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_laboratory_isanteplus` (
  `patient_id` int NOT NULL,
  `visit_id` int DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `visit_date` datetime DEFAULT NULL,
  `encounter_id` int NOT NULL,
  `provider_id` int DEFAULT NULL,
  `test_id` int NOT NULL,
  `test_done` int DEFAULT '0',
  `test_result` text COLLATE utf8mb4_unicode_ci,
  `date_test_done` date DEFAULT NULL,
  `comment_test_done` text COLLATE utf8mb4_unicode_ci,
  `viral_load_target_or_routine` int DEFAULT NULL,
  `order_destination` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `test_name` text COLLATE utf8mb4_unicode_ci,
  `last_updated_date` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `creation_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`encounter_id`,`test_id`,`mspp_code`),
  KEY `visit_date` (`visit_date`),
  KEY `encounter_id` (`encounter_id`),
  KEY `patient_id` (`patient_id`),
  KEY `date_updated_ix` (`date_updated`),
  KEY `idx_labisanteplus_sync_status` (`synced`,`date_updated`),
  KEY `idx_labisanteplus_mspp_date` (`mspp_code`,`date_updated`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_immunization`
--

DROP TABLE IF EXISTS `patient_immunization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_immunization` (
  `patient_id` int NOT NULL,
  `location_id` int NOT NULL,
  `encounter_id` int NOT NULL,
  `vaccine_obs_group_id` int NOT NULL DEFAULT '0',
  `vaccine_concept_id` int NOT NULL,
  `dose` double DEFAULT NULL,
  `vaccine_date` datetime DEFAULT NULL,
  `encounter_date` datetime NOT NULL,
  `lot_number` text COLLATE utf8mb3_unicode_ci,
  `manufacturer` text COLLATE utf8mb3_unicode_ci,
  `vaccine_uuid` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`vaccine_obs_group_id`,`vaccine_concept_id`,`mspp_code`,`encounter_date`),
  KEY `idx_immunization_mspp_date` (`mspp_code`,`encounter_date`),
  KEY `idx_immunization_location` (`location_id`,`mspp_code`),
  KEY `idx_immunization_encounter` (`encounter_id`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`encounter_date`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_tb`
--

DROP TABLE IF EXISTS `patient_tb`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_tb` (
  `encounter_id` int NOT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `patient_id` int NOT NULL,
  `location_id` int DEFAULT NULL,
  `visit_date` datetime NOT NULL,
  `encounter_date` datetime NOT NULL,
  `date_changed` datetime DEFAULT NULL,
  `date_inserted` datetime NOT NULL,
  `date_updated` datetime DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `date_voided` datetime DEFAULT NULL,
  `visit_id` int NOT NULL,
  `encounter_type` int DEFAULT NULL,
  `provider_id` int DEFAULT NULL,
  `provider_name` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tb_diag` int DEFAULT NULL,
  `mdr_tb_diag` int DEFAULT NULL,
  `tb_new_diag` int DEFAULT NULL,
  `tb_class_pulmonary` tinyint(1) DEFAULT NULL,
  `tb_class_extrapulmonary` tinyint(1) DEFAULT NULL,
  `tb_extra_meningitis` tinyint(1) DEFAULT NULL,
  `tb_extra_genital` tinyint(1) DEFAULT NULL,
  `tb_extra_pleural` tinyint(1) DEFAULT NULL,
  `tb_extra_miliary` tinyint(1) DEFAULT NULL,
  `tb_extra_gangliponic` tinyint(1) DEFAULT NULL,
  `tb_extra_intestinal` tinyint(1) DEFAULT NULL,
  `tb_extra_other` tinyint(1) DEFAULT NULL,
  `tb_follow_up_diag` int DEFAULT NULL,
  `cough_for_2wks_or_more` int DEFAULT NULL,
  `dyspnea` tinyint(1) DEFAULT NULL,
  `tb_diag_sputum` tinyint(1) DEFAULT NULL,
  `tb_diag_xray` tinyint(1) DEFAULT NULL,
  `tb_test_result_mon_0` int DEFAULT NULL,
  `tb_test_result_mon_2` int DEFAULT NULL,
  `tb_test_result_mon_3` int DEFAULT NULL,
  `tb_test_result_mon_5` int DEFAULT NULL,
  `tb_test_result_end` int DEFAULT NULL,
  `age_at_visit_years` int DEFAULT NULL,
  `age_at_visit_months` int DEFAULT NULL,
  `tb_pulmonaire` int DEFAULT NULL,
  `tb_multiresistante` int DEFAULT NULL,
  `tb_extrapul_ou_diss` int DEFAULT NULL,
  `tb_treatment_start_date` date DEFAULT NULL,
  `tb_started_treatment` tinyint(1) DEFAULT NULL,
  `tb_medication_provided` tinyint(1) DEFAULT NULL,
  `status_tb_treatment` int DEFAULT NULL,
  `tb_hiv_test_result` tinyint(1) DEFAULT NULL,
  `tb_prophy_cotrimoxazole` tinyint(1) DEFAULT NULL,
  `on_arv` tinyint(1) DEFAULT NULL,
  `tb_treatment_stop_date` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  PRIMARY KEY (`encounter_id`,`patient_id`,`mspp_code`,`visit_date`),
  KEY `idx_date_inserted` (`date_inserted`),
  KEY `idx_date_updated` (`date_updated`),
  KEY `idx_patient_tb_mspp_tb_diag` (`mspp_code`,`tb_diag`),
  KEY `idx_patient_tb_mspp_treatment_start` (`mspp_code`,`tb_treatment_start_date`),
  KEY `idx_patient_tb_mspp_patient` (`mspp_code`,`patient_id`),
  KEY `idx_patient_tb_mspp_visit_date` (`mspp_code`,`visit_date`),
  KEY `idx_patient_tb_mspp_diag_date` (`mspp_code`,`tb_diag`,`encounter_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`visit_date`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_tb_diagnosis`
--

DROP TABLE IF EXISTS `patient_tb_diagnosis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_tb_diagnosis` (
  `patient_id` int NOT NULL,
  `provider_id` int DEFAULT NULL,
  `location_id` int NOT NULL DEFAULT '0',
  `visit_id` int DEFAULT NULL,
  `visit_date` datetime NOT NULL,
  `encounter_type_id` int DEFAULT NULL,
  `encounter_id` int NOT NULL,
  `tb_diag` int DEFAULT NULL,
  `mdr_tb_diag` int DEFAULT NULL,
  `tb_new_diag` int DEFAULT NULL,
  `tb_class_pulmonary` tinyint(1) DEFAULT NULL,
  `tb_class_extrapulmonary` tinyint(1) DEFAULT NULL,
  `tb_extra_meningitis` tinyint(1) DEFAULT NULL,
  `tb_extra_genital` tinyint(1) DEFAULT NULL,
  `tb_extra_pleural` tinyint(1) DEFAULT NULL,
  `tb_extra_miliary` tinyint(1) DEFAULT NULL,
  `tb_extra_gangliponic` tinyint(1) DEFAULT NULL,
  `tb_extra_intestinal` tinyint(1) DEFAULT NULL,
  `tb_extra_other` tinyint(1) DEFAULT NULL,
  `tb_follow_up_diag` int DEFAULT NULL,
  `cough_for_2wks_or_more` int DEFAULT NULL,
  `dyspnea` tinyint(1) DEFAULT NULL,
  `tb_diag_sputum` tinyint(1) DEFAULT NULL,
  `tb_diag_xray` tinyint(1) DEFAULT NULL,
  `tb_test_result_mon_0` int DEFAULT NULL,
  `tb_test_result_mon_2` int DEFAULT NULL,
  `tb_test_result_mon_3` int DEFAULT NULL,
  `tb_test_result_mon_5` int DEFAULT NULL,
  `tb_test_result_end` int DEFAULT NULL,
  `age_at_visit_years` int DEFAULT NULL,
  `age_at_visit_months` int DEFAULT NULL,
  `tb_pulmonaire` int DEFAULT NULL,
  `tb_multiresistante` int DEFAULT NULL,
  `tb_extrapul_ou_diss` int DEFAULT NULL,
  `tb_treatment_start_date` date DEFAULT NULL,
  `tb_started_treatment` tinyint(1) DEFAULT NULL,
  `tb_medication_provided` tinyint(1) DEFAULT NULL,
  `status_tb_treatment` int DEFAULT '0',
  `tb_hiv_test_result` tinyint(1) DEFAULT NULL,
  `tb_prophy_cotrimoxazole` tinyint(1) DEFAULT NULL,
  `on_arv` tinyint(1) DEFAULT NULL,
  `tb_treatment_stop_date` date DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`encounter_id`,`location_id`,`mspp_code`,`visit_date`),
  KEY `idx_tbdiag_mspp_date` (`mspp_code`,`visit_date`),
  KEY `idx_tbdiag_patient` (`patient_id`,`mspp_code`),
  KEY `idx_tbdiag_visit` (`visit_id`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`visit_date`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_pregnancy`
--

DROP TABLE IF EXISTS `patient_pregnancy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_pregnancy` (
  `patient_id` int NOT NULL DEFAULT '0',
  `encounter_id` int NOT NULL DEFAULT '0',
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`encounter_id`,`mspp_code`,`start_date`),
  KEY `idx_pregnancy_mspp_start` (`start_date`),
  KEY `idx_pregnancy_mspp_end` (`end_date`),
  KEY `idx_pregnancy_patient` (`patient_id`,`mspp_code`),
  KEY `idx_pregnancy_patient_start` (`patient_id`,`start_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`start_date`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vaccination`
--

DROP TABLE IF EXISTS `vaccination`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vaccination` (
  `patient_id` int NOT NULL DEFAULT '0',
  `encounter_id` int NOT NULL DEFAULT '0',
  `encounter_date` date DEFAULT NULL,
  `location_id` int NOT NULL DEFAULT '0',
  `age_range` int DEFAULT NULL,
  `vaccination_done` tinyint(1) DEFAULT '0',
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`encounter_id`,`location_id`,`mspp_code`),
  KEY `date_updated_ix` (`date_updated`),
  KEY `idx_vacc_sync_status` (`synced`,`date_updated`),
  KEY `idx_vacc_mspp_date` (`mspp_code`,`date_updated`),
  KEY `idx_voided_mspp` (`voided`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_diagnosis`
--

DROP TABLE IF EXISTS `patient_diagnosis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_diagnosis` (
  `patient_id` int DEFAULT NULL,
  `encounter_id` int NOT NULL DEFAULT '0',
  `location_id` int NOT NULL DEFAULT '0',
  `encounter_date` datetime NOT NULL,
  `concept_group` int NOT NULL DEFAULT '0',
  `obs_group_id` int DEFAULT NULL,
  `concept_id` int NOT NULL DEFAULT '0',
  `answer_concept_id` int NOT NULL DEFAULT '0',
  `suspected_confirmed` int DEFAULT NULL,
  `primary_secondary` int DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`encounter_id`,`location_id`,`concept_group`,`concept_id`,`answer_concept_id`,`mspp_code`,`encounter_date`),
  KEY `idx_diag_mspp_date` (`mspp_code`,`encounter_date`),
  KEY `idx_diag_patient` (`patient_id`,`mspp_code`),
  KEY `idx_diag_last_updated` (`last_updated_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`encounter_date`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_prescription`
--

DROP TABLE IF EXISTS `patient_prescription`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_prescription` (
  `patient_id` int NOT NULL,
  `visit_id` int DEFAULT NULL,
  `location_id` int NOT NULL DEFAULT '0',
  `obs_id` int DEFAULT NULL,
  `obs_group_id` int DEFAULT NULL,
  `visit_date` datetime DEFAULT NULL,
  `encounter_id` int NOT NULL,
  `provider_id` int DEFAULT NULL,
  `drug_id` int NOT NULL,
  `dispensation_date` date DEFAULT NULL,
  `next_dispensation_date` date DEFAULT NULL,
  `dispensation_location` int DEFAULT '0',
  `arv_drug` int DEFAULT '1066',
  `dispense` int DEFAULT NULL,
  `rx_or_prophy` int DEFAULT NULL,
  `posology` text COLLATE utf8mb3_unicode_ci,
  `posology_alt` text COLLATE utf8mb3_unicode_ci,
  `posology_alt_disp` text COLLATE utf8mb3_unicode_ci,
  `number_day` double DEFAULT NULL,
  `number_day_dispense` double DEFAULT NULL,
  `pills_amount_dispense` double DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`encounter_id`,`location_id`,`drug_id`,`mspp_code`),
  KEY `visit_date` (`visit_date`),
  KEY `encounter_id` (`encounter_id`),
  KEY `patient_id` (`patient_id`),
  KEY `date_updated_ix` (`date_updated`),
  KEY `idx_presc_sync_status` (`synced`,`date_updated`),
  KEY `idx_presc_mspp_date` (`mspp_code`,`date_updated`),
  KEY `idx_voided_mspp` (`voided`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_on_art`
--

DROP TABLE IF EXISTS `patient_on_art`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_on_art` (
  `patient_id` int NOT NULL DEFAULT '0',
  `date_completed_preventive_tb_treatment` datetime DEFAULT NULL,
  `enrolled_on_art` int DEFAULT NULL,
  `gender` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `key_population` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tested_hiv_postive` int DEFAULT NULL,
  `date_tested_hiv_postive` datetime DEFAULT NULL,
  `reason_non_enrollment` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_non_enrollment` datetime DEFAULT NULL,
  `date_enrolled_on_tb_treatment` datetime DEFAULT NULL,
  `transferred` int DEFAULT NULL,
  `tb_screened` int DEFAULT NULL,
  `date_tb_screened` datetime DEFAULT NULL,
  `tb_status` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tb_genexpert_test` int DEFAULT NULL,
  `tb_other_test` int DEFAULT NULL,
  `tb_crachat_test` int DEFAULT NULL,
  `date_sample_sent_for_diagnositic_tb` datetime DEFAULT NULL,
  `started_anti_tb_treatment` int DEFAULT NULL,
  `date_started_anti_tb_treatment` datetime DEFAULT NULL,
  `tb_bacteriological_test_status` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `lost` int DEFAULT NULL,
  `date_inactive` datetime DEFAULT NULL,
  `inactive_reason` varchar(20) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `inactive` int DEFAULT NULL,
  `deceased` int DEFAULT NULL,
  `receive_arv` int DEFAULT NULL,
  `date_started_arv` datetime DEFAULT NULL,
  `date_started_receiving_arv` datetime DEFAULT NULL,
  `receive_clinical_followup` int DEFAULT NULL,
  `treatment_regime_lines` text COLLATE utf8mb3_unicode_ci,
  `date_started_regime_treatment` datetime DEFAULT NULL,
  `lost_reason` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_lost` datetime DEFAULT NULL,
  `period_lost` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cause_of_death_for_lost` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `viral_load_targeted` int DEFAULT NULL,
  `viral_load_targeted_result` int DEFAULT NULL,
  `resumed_arv_after_lost` int DEFAULT NULL,
  `recomended_family_planning` int DEFAULT NULL,
  `accepted_family_planning_method` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_accepted_family_planning_method` datetime DEFAULT NULL,
  `using_family_planning_method` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_using_family_planning_method` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `first_vist_date` datetime DEFAULT NULL,
  `second_last_folowup_vist_date` datetime DEFAULT NULL,
  `last_folowup_vist_date` datetime DEFAULT NULL,
  `date_started_arv_for_transfered` datetime DEFAULT NULL,
  `screened_cervical_cancer` int DEFAULT NULL,
  `date_screened_cervical_cancer` datetime DEFAULT NULL,
  `cervical_cancer_status` varchar(10) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_started_cervical_cancer_status` datetime DEFAULT NULL,
  `cervical_cancer_treatment` text COLLATE utf8mb3_unicode_ci,
  `date_cervical_cancer_treatment` datetime DEFAULT NULL,
  `breast_feeding` int DEFAULT NULL,
  `date_breast_feeding` datetime DEFAULT NULL,
  `date_started_breast_feeding` datetime DEFAULT NULL,
  `date_full_6_months_of_inh_has_px` datetime DEFAULT NULL,
  `migrated` int DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `date_updated` datetime DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`mspp_code`),
  KEY `idx_last_updated_date` (`date_updated`),
  KEY `idx_patient_on_art_mspp_enrolled` (`mspp_code`,`enrolled_on_art`),
  KEY `idx_patient_on_art_mspp_started_arv` (`mspp_code`,`date_started_arv`),
  KEY `idx_patient_on_art_mspp_tb_treatment` (`mspp_code`,`date_started_anti_tb_treatment`),
  KEY `idx_patient_on_art_mspp_lost` (`mspp_code`,`date_lost`),
  KEY `idx_patient_on_art_mspp_deceased` (`mspp_code`,`deceased`),
  KEY `idx_patient_on_art_mspp_viral_load` (`mspp_code`,`viral_load_targeted_result`),
  KEY `idx_voided_mspp` (`voided`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_on_arv`
--

DROP TABLE IF EXISTS `patient_on_arv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_on_arv` (
  `patient_id` int NOT NULL DEFAULT '0',
  `visit_id` int DEFAULT NULL,
  `visit_date` date DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`mspp_code`),
  KEY `date_updated_ix` (`date_updated`),
  KEY `idx_onarv_sync_status` (`synced`,`date_updated`),
  KEY `idx_onarv_mspp_date` (`mspp_code`,`date_updated`),
  KEY `idx_voided_mspp` (`voided`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `isanteplus_patient_arv`
--

DROP TABLE IF EXISTS `isanteplus_patient_arv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `isanteplus_patient_arv` (
  `patient_id` int NOT NULL,
  `arv_status` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `arv_regimen` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_started_arv` date DEFAULT NULL,
  `next_visit_date` date DEFAULT NULL,
  `date_created` datetime NOT NULL,
  `date_changed` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`mspp_code`,`date_created`),
  KEY `idx_location` (`location_id`),
  KEY `idx_date_started_arv` (`date_started_arv`),
  KEY `idx_next_visit` (`next_visit_date`),
  KEY `idx_synced` (`synced`,`date_created`),
  KEY `idx_mspp_code` (`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_ob_gyn`
--

DROP TABLE IF EXISTS `patient_ob_gyn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_ob_gyn` (
  `patient_id` int NOT NULL,
  `location_id` int NOT NULL,
  `visit_id` int DEFAULT NULL,
  `visit_date` date NOT NULL,
  `encounter_id` int NOT NULL,
  `encounter_type_id` int NOT NULL,
  `muac` int DEFAULT NULL,
  `pregnant` tinyint(1) DEFAULT NULL,
  `next_visit_date` date DEFAULT NULL,
  `edd` date DEFAULT NULL,
  `birth_plan` tinyint(1) DEFAULT NULL,
  `high_risk` tinyint(1) DEFAULT NULL,
  `gestation_greater_than_12_wks` tinyint(1) DEFAULT NULL,
  `iron_supplement` tinyint(1) DEFAULT NULL,
  `folic_acid_supplement` tinyint(1) DEFAULT NULL,
  `tetanus_toxoid_vaccine` tinyint(1) DEFAULT NULL,
  `iron_defiency_anemia` tinyint(1) DEFAULT NULL,
  `prescribed_iron` tinyint(1) DEFAULT NULL,
  `prescribed_folic_acid` tinyint(1) DEFAULT NULL,
  `elevated_blood_pressure` tinyint(1) DEFAULT NULL,
  `toxemia_signs` tinyint(1) DEFAULT NULL,
  `over_20_weeks_pregnancy` tinyint(1) DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`encounter_id`,`location_id`,`visit_date`,`mspp_code`),
  KEY `idx_visit_date` (`visit_date`),
  KEY `idx_encounter_id` (`encounter_id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_last_updated_date` (`date_updated`),
  KEY `idx_patient_ob_gyn_mspp_visit_date` (`mspp_code`,`visit_date`),
  KEY `idx_patient_ob_gyn_mspp_pregnant` (`mspp_code`,`pregnant`),
  KEY `idx_patient_ob_gyn_mspp_edd` (`mspp_code`,`edd`),
  KEY `idx_patient_ob_gyn_mspp_patient` (`mspp_code`,`patient_id`),
  KEY `idx_voided_mspp` (`voided`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`visit_date`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_nutrition`
--

DROP TABLE IF EXISTS `patient_nutrition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_nutrition` (
  `patient_id` int NOT NULL,
  `location_id` int NOT NULL DEFAULT '0',
  `visit_id` int DEFAULT NULL,
  `visit_date` date DEFAULT NULL,
  `encounter_id` int NOT NULL,
  `encounter_type_id` int NOT NULL,
  `age_at_visit_years` int DEFAULT NULL,
  `age_at_visit_months` int DEFAULT NULL,
  `weight` double DEFAULT NULL,
  `height` double DEFAULT NULL,
  `bmi` double DEFAULT NULL,
  `bmi_for_age` int DEFAULT NULL,
  `weight_for_height` int DEFAULT NULL,
  `edema` tinyint(1) DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`encounter_id`,`location_id`,`mspp_code`),
  KEY `visit_date` (`visit_date`),
  KEY `encounter_id` (`encounter_id`),
  KEY `patient_id` (`patient_id`),
  KEY `date_updated_ix` (`date_updated`),
  KEY `idx_nutrition_sync_status` (`synced`,`date_updated`),
  KEY `idx_nutrition_mspp_date` (`mspp_code`,`date_updated`),
  KEY `idx_voided_mspp` (`voided`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_malaria`
--

DROP TABLE IF EXISTS `patient_malaria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_malaria` (
  `patient_id` int NOT NULL,
  `location_id` int NOT NULL,
  `visit_id` int NOT NULL,
  `visit_date` date NOT NULL,
  `encounter_id` int NOT NULL,
  `encounter_type_id` int NOT NULL,
  `fever_for_less_than_2wks` tinyint(1) DEFAULT NULL,
  `suspected_malaria` tinyint(1) DEFAULT NULL,
  `treated_with_chloroquine` tinyint(1) DEFAULT NULL,
  `treated_with_primaquine` tinyint(1) DEFAULT NULL,
  `treated_with_quinine` tinyint(1) DEFAULT NULL,
  `microscopic_test` tinyint(1) DEFAULT NULL,
  `positive_microscopic_test_result` tinyint(1) DEFAULT NULL,
  `negative_microscopic_test_result` tinyint(1) DEFAULT NULL,
  `positive_plasmodium_falciparum_test_result` tinyint(1) DEFAULT NULL,
  `mixed_positive_test_result` tinyint(1) DEFAULT NULL,
  `positive_plasmodium_vivax_test_result` tinyint(1) DEFAULT NULL,
  `rapid_test` tinyint(1) DEFAULT NULL,
  `positve_rapid_test_result` tinyint(1) DEFAULT NULL,
  `severe_malaria` tinyint(1) DEFAULT NULL,
  `hospitallized` tinyint(1) DEFAULT NULL,
  `confirmed_malaria_preganancy` tinyint(1) DEFAULT NULL,
  `confirmed_malaria` tinyint(1) DEFAULT NULL,
  `last_updated_date` date NOT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`visit_date`,`mspp_code`),
  KEY `date_updated_ix` (`date_updated`),
  KEY `idx_malaria_sync_status` (`synced`,`date_updated`),
  KEY `idx_malaria_mspp_date` (`mspp_code`,`date_updated`),
  KEY `idx_voided_mspp` (`voided`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`visit_date`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_pcr`
--

DROP TABLE IF EXISTS `patient_pcr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_pcr` (
  `patient_id` int NOT NULL DEFAULT '0',
  `encounter_id` int NOT NULL DEFAULT '0',
  `location_id` int DEFAULT NULL,
  `visit_date` date NOT NULL,
  `pcr_result` int DEFAULT NULL,
  `test_date` date NOT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`encounter_id`,`visit_date`,`test_date`,`mspp_code`),
  KEY `idx_pcr_mspp_date` (`mspp_code`,`visit_date`),
  KEY `idx_pcr_location` (`location_id`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`visit_date`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exposed_infants`
--

DROP TABLE IF EXISTS `exposed_infants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exposed_infants` (
  `patient_id` int NOT NULL DEFAULT '0',
  `location_id` int DEFAULT '0',
  `encounter_id` int NOT NULL DEFAULT '0',
  `visit_date` date DEFAULT NULL,
  `condition_exposee` int DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`encounter_id`,`mspp_code`),
  KEY `date_updated_ix` (`date_updated`),
  KEY `idx_exposed_sync_status` (`synced`,`date_updated`),
  KEY `idx_exposed_mspp_date` (`mspp_code`,`date_updated`),
  KEY `idx_voided_mspp` (`voided`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `family_planning`
--

DROP TABLE IF EXISTS `family_planning`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `family_planning` (
  `patient_id` int NOT NULL DEFAULT '0',
  `encounter_id` int NOT NULL DEFAULT '0',
  `location_id` int DEFAULT NULL,
  `planning` int NOT NULL DEFAULT '0',
  `encounter_date` datetime DEFAULT NULL,
  `family_planning_method_name` text COLLATE utf8mb3_unicode_ci,
  `accepting_or_using_fp` int DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `last_updated_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`encounter_id`,`planning`,`voided`,`mspp_code`),
  KEY `date_updated_ix` (`date_updated`),
  KEY `idx_fp_sync_status` (`synced`,`date_updated`),
  KEY `idx_fp_mspp_date` (`mspp_code`,`date_updated`),
  KEY `idx_voided_mspp` (`voided`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_menstruation`
--

DROP TABLE IF EXISTS `patient_menstruation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_menstruation` (
  `patient_id` int NOT NULL DEFAULT '0',
  `encounter_id` int NOT NULL DEFAULT '0',
  `location_id` int NOT NULL DEFAULT '0',
  `duree_regle` int DEFAULT NULL,
  `duree_cycle` int DEFAULT NULL,
  `encounter_date` date NOT NULL,
  `ddr` date DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`encounter_id`,`location_id`,`mspp_code`,`encounter_date`),
  KEY `idx_menstruation_mspp_date` (`mspp_code`,`encounter_date`),
  KEY `idx_menstruation_location` (`location_id`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`encounter_date`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pediatric_hiv_visit`
--

DROP TABLE IF EXISTS `pediatric_hiv_visit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pediatric_hiv_visit` (
  `patient_id` int NOT NULL DEFAULT '0',
  `encounter_id` int NOT NULL DEFAULT '0',
  `location_id` int NOT NULL DEFAULT '0',
  `ptme` int DEFAULT NULL,
  `prophylaxie72h` int DEFAULT NULL,
  `actual_vih_status` int DEFAULT NULL,
  `encounter_date` date NOT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`encounter_id`,`location_id`,`mspp_code`,`encounter_date`),
  KEY `idx_pedhiv_mspp_date` (`mspp_code`,`encounter_date`),
  KEY `idx_pedhiv_location` (`location_id`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`encounter_date`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `health_qual_patient_visit`
--

DROP TABLE IF EXISTS `health_qual_patient_visit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `health_qual_patient_visit` (
  `patient_id` int NOT NULL DEFAULT '0',
  `encounter_id` int NOT NULL DEFAULT '0',
  `visit_date` date DEFAULT NULL,
  `visit_id` int DEFAULT NULL,
  `location_id` int NOT NULL DEFAULT '0',
  `encounter_type` int DEFAULT NULL,
  `patient_bmi` double DEFAULT NULL,
  `adherence_evaluation` int DEFAULT NULL,
  `family_planning_method_used` tinyint(1) DEFAULT '0',
  `evaluated_of_tb` tinyint(1) DEFAULT '0',
  `nutritional_assessment_completed` tinyint(1) DEFAULT '0',
  `is_active_tb` tinyint(1) DEFAULT '0',
  `age_in_years` int DEFAULT NULL,
  `last_insert_date` date DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`encounter_id`,`location_id`,`mspp_code`),
  KEY `date_updated_ix` (`date_updated`),
  KEY `idx_hq_sync_status` (`synced`,`date_updated`),
  KEY `idx_hq_mspp_date` (`mspp_code`,`date_updated`),
  KEY `idx_voided_mspp` (`voided`,`mspp_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_imagerie`
--

DROP TABLE IF EXISTS `patient_imagerie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_imagerie` (
  `patient_id` int NOT NULL,
  `location_id` int NOT NULL DEFAULT '0',
  `visit_id` int NOT NULL,
  `encounter_id` int NOT NULL,
  `visit_date` datetime NOT NULL,
  `radiographie_pul` int DEFAULT '0',
  `radiographie_autre` int DEFAULT NULL,
  `crachat_barr` int DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  `voided` tinyint(1) DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`location_id`,`encounter_id`,`mspp_code`,`visit_date`),
  KEY `idx_imagerie_patient` (`patient_id`,`mspp_code`),
  KEY `idx_imagerie_visit` (`visit_id`,`mspp_code`),
  KEY `idx_imagerie_mspp_date` (`mspp_code`,`visit_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`visit_date`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `allergy_openmrs`
--

DROP TABLE IF EXISTS `allergy_openmrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `allergy_openmrs` (
  `allergy_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int NOT NULL,
  `severity_concept_id` int DEFAULT NULL,
  `coded_allergen` int NOT NULL,
  `non_coded_allergen` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `allergen_type` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `comment` varchar(1024) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `creator` int NOT NULL,
  `date_created` datetime NOT NULL,
  `changed_by` int DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '1',
  `voided_by` int DEFAULT NULL,
  `date_voided` datetime DEFAULT NULL,
  `void_reason` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `uuid` char(38) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`allergy_id`,`mspp_code`,`date_created`),
  KEY `idx_allergy_id` (`allergy_id`),
  KEY `idx_allergy_patient_id` (`patient_id`),
  KEY `idx_allergy_coded_allergen` (`coded_allergen`),
  KEY `idx_allergy_severity_concept_id` (`severity_concept_id`),
  KEY `idx_allergy_creator` (`creator`),
  KEY `idx_allergy_changed_by` (`changed_by`),
  KEY `idx_allergy_voided_by` (`voided_by`),
  KEY `idx_uuid_allergy` (`uuid`),
  KEY `idx_allergy_mspp_patient` (`mspp_code`,`patient_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`date_created`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `allergy_reaction_openmrs`
--

DROP TABLE IF EXISTS `allergy_reaction_openmrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `allergy_reaction_openmrs` (
  `allergy_reaction_id` int NOT NULL AUTO_INCREMENT,
  `allergy_id` int NOT NULL,
  `reaction_concept_id` int NOT NULL,
  `reaction_non_coded` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `uuid` char(38) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`allergy_reaction_id`,`mspp_code`),
  KEY `idx_allergy_reaction_id` (`allergy_reaction_id`,`date_updated`),
  KEY `idx_allergy_reaction_allergy_id` (`allergy_id`),
  KEY `idx_allergy_reaction_reaction_concept_id` (`reaction_concept_id`),
  KEY `idx_uuid_allergy_reaction` (`uuid`),
  KEY `idx_allergy_reaction_mspp_allergy` (`mspp_code`,`allergy_id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_openmrs`
--

DROP TABLE IF EXISTS `patient_openmrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_openmrs` (
  `patient_id` int NOT NULL,
  `creator` int NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL,
  `changed_by` int DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `voided_by` int DEFAULT NULL,
  `date_voided` datetime DEFAULT NULL,
  `void_reason` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `allergy_status` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'Unknown',
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_id`,`mspp_code`,`date_created`),
  KEY `idx_user_who_changed_pat` (`changed_by`),
  KEY `idx_user_who_created_patient` (`creator`),
  KEY `idx_user_who_voided_patient` (`voided_by`),
  KEY `idx_patient_mspp_created` (`mspp_code`,`date_created`),
  KEY `idx_patient_sync_status` (`synced`,`date_created`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`date_created`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_identifier_openmrs`
--

DROP TABLE IF EXISTS `patient_identifier_openmrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_identifier_openmrs` (
  `patient_identifier_id` int NOT NULL,
  `patient_id` int NOT NULL,
  `identifier` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `identifier_type` int NOT NULL,
  `location_id` int DEFAULT NULL,
  `preferred` tinyint(1) NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL,
  `date_changed` datetime DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `voided_by` int DEFAULT NULL,
  `date_voided` datetime DEFAULT NULL,
  `void_reason` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `creator` int NOT NULL DEFAULT '0',
  `uuid` char(38) COLLATE utf8mb3_unicode_ci NOT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_identifier_id`,`mspp_code`,`date_created`),
  KEY `idx_uuid_patient_identifier` (`uuid`),
  KEY `idx_identifier_patient_identifier` (`identifier`),
  KEY `idx_patient_identifier_patient` (`patient_id`),
  KEY `idx_patient_identifier_type` (`identifier_type`),
  KEY `idx_patient_identifier_location` (`location_id`),
  KEY `idx_user_who_voided_patient_identifier` (`voided_by`),
  KEY `idx_user_who_created_patient_identifier` (`creator`),
  KEY `idx_pi_identifier_type` (`identifier`,`identifier_type`),
  KEY `idx_pi_patient_location` (`patient_id`,`location_id`),
  KEY `idx_pi_date_created_synced` (`date_created`,`synced`),
  KEY `idx_pi_mspp_identifier` (`mspp_code`,`identifier`),
  KEY `idx_pi_mspp_patient` (`mspp_code`,`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`date_created`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person_openmrs`
--

DROP TABLE IF EXISTS `person_openmrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `person_openmrs` (
  `person_id` int NOT NULL,
  `gender` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT '',
  `birthdate` date DEFAULT NULL,
  `birthdate_estimated` tinyint(1) NOT NULL DEFAULT '0',
  `dead` tinyint(1) NOT NULL DEFAULT '0',
  `death_date` datetime DEFAULT NULL,
  `cause_of_death` int DEFAULT NULL,
  `creator` int DEFAULT NULL,
  `date_created` datetime NOT NULL,
  `changed_by` int DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `voided_by` int DEFAULT NULL,
  `date_voided` datetime DEFAULT NULL,
  `void_reason` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `uuid` char(38) COLLATE utf8mb3_unicode_ci NOT NULL,
  `deathdate_estimated` tinyint(1) NOT NULL DEFAULT '0',
  `birthtime` time DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`person_id`,`mspp_code`,`date_created`),
  KEY `idx_uuid_person` (`uuid`),
  KEY `idx_person_birthdate` (`birthdate`),
  KEY `idx_person_death_date` (`death_date`),
  KEY `idx_person_cause_of_death` (`cause_of_death`),
  KEY `idx_person_changed_by` (`changed_by`),
  KEY `idx_person_creator` (`creator`),
  KEY `idx_person_voided_by` (`voided_by`),
  KEY `idx_person_mspp_birth` (`mspp_code`,`birthdate`),
  KEY `idx_person_mspp_death` (`mspp_code`,`death_date`),
  KEY `idx_person_sync_status` (`synced`,`date_created`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`date_created`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person_name_openmrs`
--

DROP TABLE IF EXISTS `person_name_openmrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `person_name_openmrs` (
  `person_name_id` int NOT NULL,
  `preferred` tinyint(1) NOT NULL DEFAULT '0',
  `person_id` int NOT NULL,
  `prefix` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `given_name` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `middle_name` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `family_name_prefix` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `family_name` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `family_name2` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `family_name_suffix` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `degree` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `creator` int NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `voided_by` int DEFAULT NULL,
  `date_voided` datetime DEFAULT NULL,
  `void_reason` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `changed_by` int DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `uuid` char(38) COLLATE utf8mb3_unicode_ci NOT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`person_name_id`,`mspp_code`,`date_created`),
  KEY `idx_person_name_uuid` (`uuid`),
  KEY `idx_first_name` (`given_name`),
  KEY `idx_last_name` (`family_name`),
  KEY `idx_middle_name` (`middle_name`),
  KEY `idx_family_name2` (`family_name2`),
  KEY `idx_user_who_made_name` (`creator`),
  KEY `idx_name_for_person` (`person_id`),
  KEY `idx_user_who_voided_name` (`voided_by`),
  KEY `idx_person_name_mspp_person` (`mspp_code`,`person_id`),
  KEY `idx_person_name_mspp_family` (`mspp_code`,`family_name`),
  KEY `idx_person_name_person_preferred_consolidated` (`person_id`,`preferred`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`date_created`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person_address_openmrs`
--

DROP TABLE IF EXISTS `person_address_openmrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `person_address_openmrs` (
  `person_address_id` int NOT NULL,
  `person_id` int DEFAULT NULL,
  `preferred` tinyint(1) NOT NULL DEFAULT '0',
  `address1` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address2` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `city_village` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `state_province` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `postal_code` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `country` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `latitude` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `longitude` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `creator` int NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `voided_by` int DEFAULT NULL,
  `date_voided` datetime DEFAULT NULL,
  `void_reason` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `county_district` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address3` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address4` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address5` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address6` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `changed_by` int DEFAULT NULL,
  `uuid` char(38) COLLATE utf8mb3_unicode_ci NOT NULL,
  `address7` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address8` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address9` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address10` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address11` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address12` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address13` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address14` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `address15` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`person_address_id`,`mspp_code`,`date_created`),
  KEY `idx_person_address_uuid` (`uuid`),
  KEY `idx_patient_address_creator` (`creator`),
  KEY `idx_address_for_person` (`person_id`),
  KEY `idx_patient_address_void` (`voided_by`),
  KEY `idx_person_address_changed_by` (`changed_by`),
  KEY `idx_person_address_mspp_person` (`mspp_code`,`person_id`),
  KEY `idx_person_address_mspp_city` (`mspp_code`,`city_village`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`date_created`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person_attribute_openmrs`
--

DROP TABLE IF EXISTS `person_attribute_openmrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `person_attribute_openmrs` (
  `person_attribute_id` int NOT NULL,
  `person_id` int NOT NULL DEFAULT '0',
  `value` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `person_attribute_type_id` int NOT NULL DEFAULT '0',
  `creator` int NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL,
  `changed_by` int DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `voided_by` int DEFAULT NULL,
  `date_voided` datetime DEFAULT NULL,
  `void_reason` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `uuid` char(38) COLLATE utf8mb3_unicode_ci NOT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`person_attribute_id`,`mspp_code`,`date_created`),
  KEY `idx_person_attribute_uuid` (`uuid`),
  KEY `idx_attribute_changer` (`changed_by`),
  KEY `idx_attribute_creator` (`creator`),
  KEY `idx_defines_attribute_type` (`person_attribute_type_id`),
  KEY `idx_identifies_person` (`person_id`),
  KEY `idx_attribute_voider` (`voided_by`),
  KEY `idx_person_attribute_mspp_person` (`mspp_code`,`person_id`),
  KEY `idx_person_attribute_mspp_type` (`mspp_code`,`person_attribute_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`date_created`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `encounter_openmrs`
--

DROP TABLE IF EXISTS `encounter_openmrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `encounter_openmrs` (
  `encounter_id` int NOT NULL,
  `encounter_type` int NOT NULL,
  `patient_id` int NOT NULL DEFAULT '0',
  `location_id` int DEFAULT NULL,
  `form_id` int DEFAULT NULL,
  `encounter_datetime` datetime NOT NULL,
  `creator` int NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `voided_by` int DEFAULT NULL,
  `date_voided` datetime DEFAULT NULL,
  `void_reason` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `changed_by` int DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `visit_id` int DEFAULT NULL,
  `uuid` char(38) COLLATE utf8mb3_unicode_ci NOT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`encounter_id`,`mspp_code`,`encounter_datetime`),
  KEY `idx_uuid_encounter` (`uuid`),
  KEY `idx_encounter_patient_id` (`patient_id`),
  KEY `idx_encounter_datetime` (`encounter_datetime`),
  KEY `idx_encounter_creator` (`creator`),
  KEY `idx_encounter_type` (`encounter_type`),
  KEY `idx_encounter_form` (`form_id`),
  KEY `idx_encounter_location` (`location_id`),
  KEY `idx_encounter_voided_by` (`voided_by`),
  KEY `idx_encounter_changed_by` (`changed_by`),
  KEY `idx_encounter_visit` (`visit_id`),
  KEY `idx_mspp_code` (`mspp_code`),
  KEY `idx_encounter_date_created_synced` (`date_created`,`synced`),
  KEY `idx_encounter_patient_date` (`patient_id`,`encounter_datetime`),
  KEY `idx_encounter_type_location` (`encounter_type`,`location_id`),
  KEY `idx_encounter_sync_status` (`synced`,`date_created`),
  KEY `idx_encounter_mspp_patient` (`mspp_code`,`patient_id`),
  KEY `idx_encounter_mspp_datetime` (`mspp_code`,`encounter_datetime`),
  KEY `idx_encounter_mspp_type` (`mspp_code`,`encounter_type`),
  KEY `idx_encounter_mspp_patient_type_date` (`mspp_code`,`patient_id`,`encounter_type`,`encounter_datetime`),
  KEY `idx_encounter_mspp_location_date` (`mspp_code`,`location_id`,`encounter_datetime`),
  KEY `idx_encounter_openmrs_updated` (`date_updated`,`date_changed`,`date_created`),
  KEY `idx_ssp_covering` (`encounter_type`,`encounter_datetime`,`patient_id`,`voided`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`encounter_datetime`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `encounter_provider_openmrs`
--

DROP TABLE IF EXISTS `encounter_provider_openmrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `encounter_provider_openmrs` (
  `encounter_provider_id` int NOT NULL,
  `encounter_id` int NOT NULL,
  `provider_id` int NOT NULL,
  `encounter_role_id` int NOT NULL,
  `creator` int NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL,
  `changed_by` int DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `date_voided` datetime DEFAULT NULL,
  `voided_by` int DEFAULT NULL,
  `void_reason` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `uuid` char(38) COLLATE utf8mb3_unicode_ci NOT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`encounter_provider_id`,`mspp_code`,`date_created`),
  KEY `idx_encounter_provider_uuid` (`uuid`),
  KEY `idx_encounter_id_fk` (`encounter_id`),
  KEY `idx_provider_id_fk` (`provider_id`),
  KEY `idx_encounter_role_id_fk` (`encounter_role_id`),
  KEY `idx_encounter_provider_creator` (`creator`),
  KEY `idx_encounter_provider_changed_by` (`changed_by`),
  KEY `idx_encounter_provider_voided_by` (`voided_by`),
  KEY `idx_encounter_provider_mspp_encounter` (`mspp_code`,`encounter_id`),
  KEY `idx_encounter_provider_mspp_provider` (`mspp_code`,`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`date_created`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `obs_openmrs`
--

DROP TABLE IF EXISTS `obs_openmrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `obs_openmrs` (
  `obs_id` int NOT NULL,
  `person_id` int NOT NULL,
  `concept_id` int NOT NULL DEFAULT '0',
  `encounter_id` int DEFAULT NULL,
  `order_id` int DEFAULT NULL,
  `obs_datetime` datetime NOT NULL,
  `location_id` int DEFAULT NULL,
  `obs_group_id` int DEFAULT NULL,
  `accession_number` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `value_group_id` int DEFAULT NULL,
  `value_coded` int DEFAULT NULL,
  `value_coded_name_id` int DEFAULT NULL,
  `value_drug` int DEFAULT NULL,
  `value_datetime` datetime DEFAULT NULL,
  `value_numeric` double DEFAULT NULL,
  `value_modifier` varchar(2) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `value_text` text COLLATE utf8mb3_unicode_ci,
  `value_complex` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `comments` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `creator` int NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `voided_by` int DEFAULT NULL,
  `date_voided` datetime DEFAULT NULL,
  `void_reason` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `uuid` char(38) COLLATE utf8mb3_unicode_ci NOT NULL,
  `previous_version` int DEFAULT NULL,
  `form_namespace_and_path` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`obs_id`,`mspp_code`,`obs_datetime`),
  KEY `idx_uuid_obs` (`uuid`),
  KEY `idx_obs_datetime` (`obs_datetime`),
  KEY `idx_obs_concept` (`concept_id`),
  KEY `idx_obs_person` (`person_id`),
  KEY `idx_obs_encounter` (`encounter_id`),
  KEY `idx_obs_mspp_concept` (`mspp_code`,`concept_id`),
  KEY `idx_obs_mspp_person` (`mspp_code`,`person_id`),
  KEY `idx_obs_date_created_synced` (`date_created`,`synced`),
  KEY `idx_obs_mspp_person_concept_date` (`mspp_code`,`person_id`,`concept_id`,`obs_datetime`),
  KEY `idx_obs_mspp_encounter_concept` (`mspp_code`,`encounter_id`,`concept_id`),
  KEY `idx_obs_mspp_value_coded` (`mspp_code`,`value_coded`,`obs_datetime`),
  KEY `idx_obs_concept_value_date_person` (`concept_id`,`value_coded`,`obs_datetime`,`person_id`),
  KEY `idx_obs_concept_value_date_person_consolidated` (`concept_id`,`value_coded`,`obs_datetime`,`person_id`),
  KEY `idx_obs_concept_date_person_encounter_consolidated` (`concept_id`,`obs_datetime`,`person_id`,`encounter_id`),
  KEY `idx_obs_mspp_date_updated` (`mspp_code`,`date_updated`),
  KEY `idx_obs_mspp_voided` (`mspp_code`,`voided`),
  KEY `idx_obs_purge` (`mspp_code`,`obs_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`obs_datetime`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `visit_openmrs`
--

DROP TABLE IF EXISTS `visit_openmrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `visit_openmrs` (
  `visit_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int NOT NULL,
  `visit_type_id` int NOT NULL,
  `date_started` datetime NOT NULL,
  `date_stopped` datetime DEFAULT NULL,
  `indication_concept_id` int DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `creator` int NOT NULL,
  `date_created` datetime NOT NULL,
  `changed_by` int DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `voided_by` int DEFAULT NULL,
  `date_voided` datetime DEFAULT NULL,
  `void_reason` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `uuid` char(38) COLLATE utf8mb3_unicode_ci NOT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `date_updated` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`visit_id`,`mspp_code`,`date_started`),
  KEY `idx_uuid_visit` (`uuid`),
  KEY `idx_visit_patient_index` (`patient_id`),
  KEY `idx_visit_type_fk` (`visit_type_id`),
  KEY `idx_visit_location_fk` (`location_id`),
  KEY `idx_visit_creator_fk` (`creator`),
  KEY `idx_visit_voided_by_fk` (`voided_by`),
  KEY `idx_visit_changed_by_fk` (`changed_by`),
  KEY `idx_visit_indication_concept_fk` (`indication_concept_id`),
  KEY `idx_visit_mspp_patient` (`mspp_code`,`patient_id`),
  KEY `idx_visit_mspp_started` (`mspp_code`,`date_started`),
  KEY `idx_visit_openmrs_id_mspp` (`visit_id`,`mspp_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1309339 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci
/*!50100 PARTITION BY RANGE (year(`date_started`))
SUBPARTITION BY KEY (mspp_code)
SUBPARTITIONS 8
(PARTITION p2010 VALUES LESS THAN (2011) ENGINE = InnoDB,
 PARTITION p2011 VALUES LESS THAN (2012) ENGINE = InnoDB,
 PARTITION p2012 VALUES LESS THAN (2013) ENGINE = InnoDB,
 PARTITION p2013 VALUES LESS THAN (2014) ENGINE = InnoDB,
 PARTITION p2014 VALUES LESS THAN (2015) ENGINE = InnoDB,
 PARTITION p2015 VALUES LESS THAN (2016) ENGINE = InnoDB,
 PARTITION p2016 VALUES LESS THAN (2017) ENGINE = InnoDB,
 PARTITION p2017 VALUES LESS THAN (2018) ENGINE = InnoDB,
 PARTITION p2018 VALUES LESS THAN (2019) ENGINE = InnoDB,
 PARTITION p2019 VALUES LESS THAN (2020) ENGINE = InnoDB,
 PARTITION p2020 VALUES LESS THAN (2021) ENGINE = InnoDB,
 PARTITION p2021 VALUES LESS THAN (2022) ENGINE = InnoDB,
 PARTITION p2022 VALUES LESS THAN (2023) ENGINE = InnoDB,
 PARTITION p2023 VALUES LESS THAN (2024) ENGINE = InnoDB,
 PARTITION p2024 VALUES LESS THAN (2025) ENGINE = InnoDB,
 PARTITION p2025 VALUES LESS THAN (2026) ENGINE = InnoDB,
 PARTITION p2026 VALUES LESS THAN (2027) ENGINE = InnoDB,
 PARTITION pmax VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_identifier_type`
--

DROP TABLE IF EXISTS `patient_identifier_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_identifier_type` (
  `patient_identifier_type_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `description` text COLLATE utf8mb4_unicode_ci,
  `format` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `check_digit` tinyint(1) NOT NULL DEFAULT '0',
  `creator` int NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL,
  `required` tinyint(1) NOT NULL DEFAULT '0',
  `format_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `validator` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location_behavior` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `retired` tinyint(1) NOT NULL DEFAULT '0',
  `retired_by` int DEFAULT NULL,
  `date_retired` datetime DEFAULT NULL,
  `retire_reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uuid` char(38) COLLATE utf8mb4_unicode_ci NOT NULL,
  `uniqueness_behavior` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`patient_identifier_type_id`,`mspp_code`),
  UNIQUE KEY `pit_uuid_mspp` (`uuid`,`mspp_code`),
  KEY `patient_identifier_type_retired_status` (`retired`),
  KEY `type_creator` (`creator`),
  KEY `user_who_retired_patient_identifier_type` (`retired_by`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person_attribute_type`
--

DROP TABLE IF EXISTS `person_attribute_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `person_attribute_type` (
  `person_attribute_type_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `description` text COLLATE utf8mb4_unicode_ci,
  `format` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `foreign_key` int DEFAULT NULL,
  `searchable` tinyint(1) NOT NULL DEFAULT '0',
  `creator` int NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL,
  `changed_by` int DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `retired` tinyint(1) NOT NULL DEFAULT '0',
  `retired_by` int DEFAULT NULL,
  `date_retired` datetime DEFAULT NULL,
  `retire_reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `edit_privilege` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_weight` double DEFAULT NULL,
  `uuid` char(38) COLLATE utf8mb4_unicode_ci NOT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`person_attribute_type_id`,`mspp_code`),
  UNIQUE KEY `pat_uuid_mspp` (`uuid`,`mspp_code`),
  KEY `attribute_is_searchable` (`searchable`),
  KEY `name_of_attribute` (`name`),
  KEY `person_attribute_type_retired_status` (`retired`),
  KEY `attribute_type_changer` (`changed_by`),
  KEY `attribute_type_creator` (`creator`),
  KEY `user_who_retired_person_attribute_type` (`retired_by`),
  KEY `privilege_which_can_edit` (`edit_privilege`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `encounter_type`
--

DROP TABLE IF EXISTS `encounter_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `encounter_type` (
  `encounter_type_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `description` text COLLATE utf8mb4_unicode_ci,
  `creator` int NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL,
  `retired` tinyint(1) NOT NULL DEFAULT '0',
  `retired_by` int DEFAULT NULL,
  `date_retired` datetime DEFAULT NULL,
  `retire_reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uuid` char(38) COLLATE utf8mb4_unicode_ci NOT NULL,
  `edit_privilege` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `view_privilege` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `changed_by` int DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `synced` tinyint(1) NOT NULL DEFAULT '0',
  `synced_date` datetime DEFAULT NULL,
  `mspp_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`encounter_type_id`,`mspp_code`),
  UNIQUE KEY `encounter_type_unique_name_mspp` (`name`,`mspp_code`),
  UNIQUE KEY `encounter_type_uuid_mspp` (`uuid`,`mspp_code`),
  KEY `encounter_type_retired_status` (`retired`),
  KEY `user_who_created_type` (`creator`),
  KEY `user_who_retired_encounter_type` (`retired_by`),
  KEY `privilege_which_can_view_encounter_type` (`view_privilege`),
  KEY `privilege_which_can_edit_encounter_type` (`edit_privilege`),
  KEY `encounter_type_changed_by` (`changed_by`),
  KEY `idx_encounter_type_id_mspp` (`encounter_type_id`,`mspp_code`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
/*!50100 PARTITION BY KEY (mspp_code)
PARTITIONS 20 */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site`
--

DROP TABLE IF EXISTS `site`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `site` (
  `mspp_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `commune` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location_id` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `section_communale` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_category` bigint DEFAULT NULL,
  `id_network` bigint DEFAULT NULL,
  `active` bit(1) NOT NULL DEFAULT b'0',
  `active_ssp` bit(1) NOT NULL,
  `active_vih` bit(1) NOT NULL,
  PRIMARY KEY (`mspp_code`),
  KEY `FKafl6v25vi2csu2d56stqnqthr` (`id_category`),
  KEY `FKgqs0l0mgp01b8j2jpestek5ok` (`id_network`)
) ENGINE=MyISAM AUTO_INCREMENT=95699 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locations` (
  `location_id` int DEFAULT NULL,
  `name` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `value_reference` varchar(10) COLLATE utf8mb3_unicode_ci NOT NULL,
  `address3` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `city_village` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `state_province` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`value_reference`),
  KEY `idx_active` (`active`),
  KEY `idx_mspp_name` (`value_reference`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `concept`
--

DROP TABLE IF EXISTS `concept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `concept` (
  `concept_id` int NOT NULL AUTO_INCREMENT,
  `retired` tinyint(1) NOT NULL DEFAULT '0',
  `short_name` varchar(255) DEFAULT NULL,
  `description` text,
  `form_text` text,
  `datatype_id` int NOT NULL DEFAULT '0',
  `class_id` int NOT NULL DEFAULT '0',
  `is_set` tinyint(1) NOT NULL DEFAULT '0',
  `creator` int NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `version` varchar(50) DEFAULT NULL,
  `changed_by` int DEFAULT NULL,
  `date_changed` datetime DEFAULT NULL,
  `retired_by` int DEFAULT NULL,
  `date_retired` datetime DEFAULT NULL,
  `retire_reason` varchar(255) DEFAULT NULL,
  `uuid` char(38) NOT NULL,
  PRIMARY KEY (`concept_id`),
  UNIQUE KEY `concept_uuid_index` (`uuid`),
  KEY `concept_classes` (`class_id`),
  KEY `concept_creator` (`creator`),
  KEY `concept_datatypes` (`datatype_id`),
  KEY `user_who_changed_concept` (`changed_by`),
  KEY `concept_code` (`version`),
  KEY `concept_ndx` (`version`),
  KEY `user_who_retired_concept` (`retired_by`),
  CONSTRAINT `concept_classes` FOREIGN KEY (`class_id`) REFERENCES `concept_class` (`concept_class_id`),
  CONSTRAINT `concept_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `concept_datatypes` FOREIGN KEY (`datatype_id`) REFERENCES `concept_datatype` (`concept_datatype_id`),
  CONSTRAINT `user_who_changed_concept` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_retired_concept` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=509166603 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `concept_name`
--

DROP TABLE IF EXISTS `concept_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `concept_name` (
  `concept_id` int DEFAULT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `locale` varchar(50) NOT NULL DEFAULT '',
  `creator` int NOT NULL DEFAULT '0',
  `date_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `concept_name_id` int NOT NULL AUTO_INCREMENT,
  `voided` tinyint(1) NOT NULL DEFAULT '0',
  `voided_by` int DEFAULT NULL,
  `date_voided` datetime DEFAULT NULL,
  `void_reason` varchar(255) DEFAULT NULL,
  `uuid` char(38) NOT NULL,
  `concept_name_type` varchar(50) DEFAULT NULL,
  `locale_preferred` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`concept_name_id`),
  UNIQUE KEY `concept_name_id` (`concept_name_id`),
  UNIQUE KEY `concept_name_uuid_index` (`uuid`),
  KEY `user_who_created_name` (`creator`),
  KEY `name_of_concept` (`name`),
  KEY `concept_id` (`concept_id`),
  KEY `unique_concept_name_id` (`concept_id`),
  KEY `user_who_voided_name` (`voided_by`),
  CONSTRAINT `name_for_concept` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `user_who_created_name` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_voided_this_name` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=153055 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-11 15:06:21
