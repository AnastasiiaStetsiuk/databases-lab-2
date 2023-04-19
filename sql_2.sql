use airport;

-- 1
SELECT id, board_number, model, worked_hours, seats, capacity 
FROM planes
WHERE model='Airbus A320' OR model='Boeing 787'
ORDER BY worked_hours DESC;

-- 2
SELECT f.id AS flight_id, p.board_number, f.departure_point, f.destination_point, f.departure_time, f.landing_time, (p.seats - f.sold_tickets_number) AS free_seats
FROM flights f
JOIN planes p ON f.plane_id = p.id;

-- 3
SELECT f.departure_point, f.destination_point, f.departure_time, f.landing_time, f.sold_tickets_number
FROM flights f
JOIN planes p ON f.plane_id = p.id
WHERE p.model = 'Boeing 737' AND (f.sold_tickets_number < 100 OR f.departure_time > '2023-03-21 00:00:00')
ORDER BY f.departure_time;

-- 4
SELECT flights.*, planes.model, pilots.last_name
FROM flights
INNER JOIN planes ON flights.plane_id = planes.id
LEFT OUTER JOIN pilots ON planes.id = pilots.crew_member_id;

-- 5
SELECT * FROM planes WHERE model LIKE 'Boeing%';

SELECT * FROM flights WHERE departure_time BETWEEN '2023-03-22' AND '2023-03-24';

SELECT * FROM flights WHERE plane_id IN (1, 3, 5);

SELECT * FROM planes WHERE EXISTS (SELECT * FROM flights WHERE planes.id = flights.plane_id);

SELECT * FROM pilots WHERE allowed_planes = (SELECT GROUP_CONCAT(model SEPARATOR ', ') FROM planes) AND last_flight_date IS NOT NULL;

-- 6
SELECT planes.model, COUNT(flights.id) AS number_of_flights
FROM planes
JOIN flights ON planes.id = flights.plane_id
GROUP BY planes.model;

-- 7
SELECT * 
FROM flights 
WHERE plane_id IN (
    SELECT id 
    FROM planes 
    WHERE worked_hours > 8000
);

-- 8
SELECT f.*
FROM flights f
WHERE f.plane_id IN (
    SELECT p.id 
    FROM planes p
    WHERE p.model = 'Boeing 737'
);

-- 9
WITH RECURSIVE pilot_hierarchy AS (
  SELECT id, crew_member_id, allowed_planes, CAST(last_name AS CHAR(200)) AS name, 0 AS level
  FROM pilots
  JOIN crew_members ON pilots.crew_member_id = crew_members.id
  UNION ALL
  SELECT p.id, p.crew_member_id, p.allowed_planes, CONCAT(ph.name, ' > ', CAST(cm.last_name AS CHAR(200))) AS name, level + 1
  FROM pilots p
  JOIN crew_members cm ON p.crew_member_id = cm.id
  JOIN pilot_hierarchy ph ON p.crew_member_id = ph.crew_member_id
)
SELECT id, name, allowed_planes, level
FROM pilot_hierarchy
ORDER BY id, level;

-- 10
SELECT plane_id,
       SUM(CASE WHEN id = 1 THEN sold_tickets_number ELSE 0 END) AS flight_1,
       SUM(CASE WHEN id = 2 THEN sold_tickets_number ELSE 0 END) AS flight_2,
       SUM(CASE WHEN id = 3 THEN sold_tickets_number ELSE 0 END) AS flight_3,
       SUM(CASE WHEN id = 4 THEN sold_tickets_number ELSE 0 END) AS flight_4,
       SUM(CASE WHEN id = 5 THEN sold_tickets_number ELSE 0 END) AS flight_5
FROM flights
GROUP BY plane_id;

-- 11
UPDATE planes 
SET worked_hours = worked_hours + 1000 
WHERE id = 1;

-- 12
UPDATE planes
JOIN pilots ON planes.id = pilots.crew_member_id
SET planes.worked_hours = 13000,
    pilots.allowed_planes = CONCAT(pilots.allowed_planes, ', Boeing 777')
WHERE planes.board_number = 'AA101';

-- 13
INSERT INTO planes (board_number, model, worked_hours, seats, capacity)
VALUES ('AA109', 'Boeing 777', 4000, 200, 7000);

-- 14
INSERT INTO planes (board_number, model, worked_hours, seats, capacity) 
SELECT board_number, model, worked_hours, seats, capacity 
FROM planes 
WHERE worked_hours < 5000;

INSERT INTO flights (departure_point, destination_point, departure_time, landing_time, plane_id, sold_tickets_number) 
SELECT 'Kyiv', 'Paris', '2023-04-01 15:00:00', '2023-04-01 18:00:00', id, 0 
FROM planes 
WHERE model = 'Airbus A320';

INSERT INTO crew_members (last_name, birth_date, address) 
SELECT last_name, birth_date, address 
FROM crew_members 
WHERE id IN (1, 3);

INSERT INTO pilots (crew_member_id, allowed_planes, last_flight_date) 
SELECT crew_member_id, allowed_planes, last_flight_date 
FROM pilots 
WHERE crew_member_id = 2;

-- 15
DELETE FROM planes;
DELETE FROM flights;
DELETE FROM crew_members;
DELETE FROM pilots;
DELETE FROM flight_crew;