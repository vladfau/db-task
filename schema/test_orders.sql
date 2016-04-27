INSERT INTO Client
VALUES ('Some', 'Dude', '8800110', 'sdude@comp.org', 'IJNJFR');


INSERT INTO Progress
VALUES (1, SYSDATETIME(), NULL);

INSERT INTO Progress
VALUES (4, SYSDATETIME(), 3);

INSERT INTO Progress
VALUES (3, DATETIME2FROMPARTS(2016, 03, 17, 12, 54, 10, 0, 0), 4);

INSERT INTO OrderItem
VALUES ('iphone',
        1,
        'broken screen',
        1,
        'TRUE',
        'FNGKEOE23')


INSERT INTO OrderItem
VALUES ('iphone',
        1,
        'cannot turn on',
        1,
        'TRUE',
        'FNGHRKEOE23')

INSERT INTO OrderItem
VALUES ('mac24',
        5,
        'hd fails',
        2,
        'FALSE',
        'FNGJKEJ21')

INSERT INTO ServiceOrder
VALUES (1, SYSDATETIME(), 1), (1, DATETIME2FROMPARTS(2016, 03, 12, 12, 50, 10, 0, 0),  3), (1, SYSDATETIME(), 2)
