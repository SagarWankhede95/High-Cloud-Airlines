SELECT * FROM airlines_project.maindata;
-- Load factor based on year
SELECT Year,
       CASE WHEN SUM(Available_Seats) = 0 THEN 0
            ELSE SUM(Transported_Passengers) / SUM(Available_Seats) * 100
       END AS Load_Factor
FROM maindata
GROUP BY Year;

-- load factor on monthly
SELECT 
    MONTH(`Month (#)`),
    (SUM(Transported_Passengers) / SUM(Available_Seats)) * 100 AS Load_Factor
FROM 
    maindata
WHERE (`Month (#)`) = 12
GROUP BY `Month (#)`;

-- Load Factor percentage on a Carrier Name basis
SELECT Carrier_Name,
       CASE WHEN SUM(Available_Seats) = 0 THEN 0
            ELSE SUM(Transported_Passengers) / SUM(Available_Seats) * 100
       END AS Load_Factor
FROM maindata
GROUP BY Carrier_Name;

-- Top 10 Carrier Names based passengers preference
SELECT
    Carrier_Name,
    COUNT(*) AS PassengerCount
FROM
    maindata
GROUP BY
    Carrier_Name
ORDER BY
    PassengerCount DESC
LIMIT 10;

-- Top Routes ( from-to City) based on Number of Flights
SELECT
    CONCAT(Origin_City, ' - ', Destination_City) AS Route,
    COUNT(*) AS FlightCount
FROM
    maindata
GROUP BY
    Origin_City, Destination_City
ORDER BY
    FlightCount DESC
LIMIT 10;

--
ALTER TABLE maindata
ADD COLUMN full_date DATE;

UPDATE maindata
SET full_date = STR_TO_DATE(CONCAT(year, '-', `Month (#)`, '-', day), '%Y-%m-%d');

ALTER TABLE maindata
ADD COLUMN day_type VARCHAR(10);

UPDATE maindata
SET day_type = CASE 
    WHEN WEEKDAY(full_date) BETWEEN 0 AND 4 THEN 'Weekday'
    ELSE 'Weekend' 
END;

--  Load factor is occupied on Weekend vs Weekdays
SELECT
    day_type,
    COUNT(*) AS total_records,
    (COUNT(*) / (SELECT COUNT(*) FROM maindata)) * 100 AS load_factor_percentage
FROM
    maindata
GROUP BY
    day_type;

-- filter to provide a search capability to find the flights between Source Country, Source State, Source City to Destination Country , Destination State, Destination City 
SELECT *
FROM maindata
WHERE
    Origin_Country = 'United States'
    AND Origin_State = 'Illinois'
    AND destination_country = 'India'
    AND destination_city = 'Delhi, India';

--
SELECT
    CASE
        WHEN distance <= 1000 THEN 'Short Haul'
        WHEN distance BETWEEN 1001 AND 2500 THEN 'Medium Haul'
        ELSE 'Long Haul'
    END AS distance_group,
    COUNT(*) AS number_of_flights
FROM
    flights
GROUP BY
    distance_group;

--
SELECT
    m.Distance_Group_ID,
    COUNT(m.Distance_Group_ID) AS number_of_flights
FROM
    maindata m
JOIN
    distancegroup dg ON m.Distance_Group_ID = dg.distance_group_id 
GROUP BY
    m.Distance_Group_ID;
    
SELECT
    dg.distance_interval,
    COUNT(m.Distance_Group_ID) AS number_of_flights
FROM
    maindata m
JOIN
    distancegroup dg ON m.Distance_Group_ID = dg.Distance_Group_ID
GROUP BY
    dg.distance_interval;
alter table distancegroup rename column `Distance Interval` to Distance_Interval;