CREATE TABLE MESSAGE
(
    MESSAGE_HASH VARCHAR  NOT NULL,
    CLASSIFICATION_MARKING VARCHAR  NOT NULL,
    SENSOR_NUMBER BIGINT,
    TOTAL_OBSERVATION_COUNT BIGINT NOT NULL,
    DUPLICATE_OBSERVATION_COUNT SMALLINT NOT NULL,
    ERROR_OBSERVATION_COUNT SMALLINT NOT NULL,
    MESSAGE_TIME TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    SOURCE VARCHAR(10)  NOT NULL,
    SOURCE_METADATA VARCHAR(256)  NOT NULL,
    UPDATE_DATE TIMESTAMP WITHOUT TIME ZONE,
    UPDATE_ORIGIN VARCHAR(64) ,
    CREATE_DATE TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CREATE_ORIGIN VARCHAR(64)  NOT NULL,
    VERSION BIGINT DEFAULT 0    
);