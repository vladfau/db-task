USE serviceCenterMain;

-- basic statuses of orders
INSERT INTO Status
VALUES('New'), ('Open'), ('In analysis'), ('In progress'), ('In verification'), ('Done'), ('Closed');

-- main departments
INSERT INTO Team
VALUES ('Administration'), ('Engineering'), ('Reception');


-- all default employees
INSERT INTO Employee
VALUES ('Vlad', 'Slepukhin', 'vslepukhin@sc.ru', '3000', 'B4FQINM3IX', 'TRUE');

INSERT INTO Employee
VALUES ('Joe', 'Portier', 'jportier@sc.ru', '1000', 'B4FQINM3IX', 'FALSE');

INSERT INTO Employee
VALUES ('Core', 'Fixer', 'cfixer@sc.ru', '2001', 'P5C5MZKUDW', 'TRUE');

insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Helen', 'Mccoy', 'hmccoy@sc.ru', 2492, 0, '0jbWD0');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Janice', 'Evans', 'jevans@sc.ru', 2366, 0, 'm5V20YIYpBoj');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Maria', 'Gonzales', 'mgonzales@sc.ru', 2395, 0, 'hhIyyP');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Ashley', 'Hawkins', 'ahawkins@sc.ru', 2193, 0, 'c9VTL2A');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Paul', 'Willis', 'pwillis@sc.ru', 2742, 0, 'HRLDHxq0');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Mark', 'Scott', 'mscott@sc.ru', 2127, 0, '6Jgm5aHci4vP');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Justin', 'Lee', 'jlee@sc.ru', 2854, 0, '6nlfAU1cbQ');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Carlos', 'Harris', 'charris@sc.ru', 2553, 0, 'EP4qXoK0B');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Melissa', 'Olson', 'molson@sc.ru', 2152, 0, '24tl2kR');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Joe', 'Hansen', 'jhansen@sc.ru', 2142, 0, 'Ly4wtzq');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Heather', 'Ford', 'hford@sc.ru', 2272, 0, 'WiebxMT');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Craig', 'Gibson', 'cgibson@sc.ru', 2123, 0, 'kA8tfBjAH');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Juan', 'Larson', 'jlarson@sc.ru', 2019, 0, '3f9L0y6NNCQx');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Patricia', 'Duncan', 'pduncan@sc.ru', 2568, 0, '9TizHVRsbInr');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Linda', 'Bowman', 'lbowman@sc.ru', 2436, 0, 'q7kR5B');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Donna', 'Welch', 'dwelch@sc.ru', 2931, 0, 'drtyp90VYG');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Evelyn', 'Mccoy', 'emccoy@sc.ru', 2349, 0, 'rkjwt6wsQC');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Evelyn', 'Burton', 'eburton@sc.ru', 2334, 0, 'Pz8lzX');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Johnny', 'Black', 'jblack@sc.ru', 2052, 0, 'Zp54jGZEQuq');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Tammy', 'Bowman', 'tbowman@sc.ru', 2623, 0, 'kmnAqrtUCcxd');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Alan', 'Scott', 'ascott@sc.ru', 2496, 0, 'oLMEb1KA');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Gregory', 'Wilson', 'gwilson@sc.ru', 2871, 0, 'NFTpjpC0f30');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Ashley', 'Mcdonald', 'amcdonald@sc.ru', 2343, 0, '8AJE1t2HhE');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Andrew', 'Hudson', 'ahudson@sc.ru', 2604, 0, 'TRPW2CdiD6u');
insert into Employee (first_name, last_name, email, phone, is_manager, password) values ('Stephanie', 'Mendoza', 'smendoza@sc.ru', 2645, 0, 'zz3shWf4NW');

INSERT INTO Employee
VALUES ('Helen', 'Overwelcomed', 'hoverwelcomed@sc.ru', '1001', 'UVWBU6Q87J', 'FALSE');

INSERT INTO Employee
VALUES ('Chirsten', 'Accountable', 'caccountable@sc.ru', '3050', 'ZJYDJYZ3D1', 'FALSE');

INSERT INTO Employee
VALUES ('Chip', 'Bit', 'cbit@sc.ru', '2051', 'NHAFIPATHK', 'FALSE');

INSERT INTO Employee
VALUES ('Don', 'Garage', 'dgarage@sc.ru', '3001', '7TNPCKMVCV', 'FALSE');

INSERT INTO Employee
VALUES ('Corgi', 'Recept', 'crecept@sc.ru', '1050', 'B4BMINOPD2', 'TRUE');

-- team and employee connctetion
INSERT INTO OrgUnit
( team_id,
  employee_id
)
SELECT (SELECT id FROM Team where name = 'Reception'), e.id
FROM Employee AS e
WHERE e.phone LIKE '1%';

INSERT INTO OrgUnit
( team_id,
  employee_id
)
SELECT (SELECT id FROM Team where name = 'Engineering'), e.id
FROM Employee AS e
WHERE e.phone LIKE '2%';

INSERT INTO OrgUnit
( team_id,
  employee_id
)
SELECT (SELECT id FROM Team where name = 'Administration'), e.id
FROM Employee AS e
WHERE e.phone LIKE '3%';


-- some test inventory
INSERT INTO Inventory
VALUES ('iPhone_5c_Screen', 8);

INSERT INTO Inventory
VALUES ('iPhone_6_Screen', 1);

INSERT INTO Inventory
VALUES ('Nexus_5_Battery', 5);

INSERT INTO Inventory
VALUES ('Nexus_6p_Cellular_Module', 9);

INSERT INTO Inventory
VALUES ('Nexus_6p_Battery', 1);

INSERT INTO Inventory
VALUES ('iPhone_4_Charge_Module', 1);

INSERT INTO Inventory
VALUES ('iPhone_6Plus_Buttons', 2);


-- some device types
INSERT INTO DeviceType
VALUES ('Phone')
INSERT INTO DeviceType
VALUES ('Tablet')
INSERT INTO DeviceType
VALUES ('PC')
INSERT INTO DeviceType
VALUES ('Laptop')
INSERT INTO DeviceType
VALUES ('Mac/MacBook')
INSERT INTO DeviceType
VALUES ('Other')
