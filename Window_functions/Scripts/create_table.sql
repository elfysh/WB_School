CREATE TABLE search (
    searchid SERIAL PRIMARY KEY,
    year INT,
    month INT,
    day INT,
    userid INT,
    ts BIGINT,
    devicetype VARCHAR(20),
    deviceid VARCHAR(50),
    query VARCHAR(255)
);