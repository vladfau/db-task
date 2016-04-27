CREATE TABLE Client (
	id INT IDENTITY(1,1) PRIMARY KEY,
	first_name varchar(60) NOT NULL,
	last_name varchar(60) NOT NULL,
	phone varchar(20) NOT NULL,
	email varchar(60),
	password varchar(400) NOT NULL
);

CREATE TABLE Team (
	id INT IDENTITY(1,1) PRIMARY KEY,
	name varchar(60) NOT NULL UNIQUE
);

CREATE TABLE Employee (
	id INT IDENTITY(1,1) PRIMARY KEY,
	first_name varchar(60) NOT NULL,
	last_name varchar(60) NOT NULL,
	email varchar(60) NOT NULL,
	phone varchar(10) NOT NULL,
	password varchar(400) NOT NULL,
    is_manager BIT NOT NULL
);

CREATE TABLE OrgUnit (
	id INT IDENTITY(1,1) PRIMARY KEY,
    team_id INT NOT NULL,
    employee_id INT NOT NULL,
    CONSTRAINT fk_team_id FOREIGN KEY (team_id) REFERENCES Team(id),
    CONSTRAINT fk_employee_id FOREIGN KEY (employee_id) REFERENCES Employee(id)
);

CREATE TABLE Status (
	id INT IDENTITY(1,1) PRIMARY KEY,
	name varchar(20) NOT NULL UNIQUE
);

CREATE TABLE Progress (
	id INT IDENTITY(1,1) PRIMARY KEY,
	status INT,
	update_date DATETIME,
	assignee INT,
    CONSTRAINT fk_assignee_id FOREIGN KEY (assignee) REFERENCES Employee(id),
    CONSTRAINT fk_status_id FOREIGN KEY (status) REFERENCES Status(id)
);

CREATE TABLE DeviceType (
	id INT IDENTITY(1,1) PRIMARY KEY,
	name varchar(60) NOT NULL
);

CREATE TABLE OrderItem (
	id INT IDENTITY(1,1) PRIMARY KEY,
	name varchar(80) NOT NULL,
	device_type_id INT NOT NULL,
	issue varchar(1000) NOT NULL,
	progress_id INT,
	is_warranty BIT NOT NULL,
	serial varchar(60) NOT NULL,
    CONSTRAINT fk_progress_id FOREIGN KEY (progress_id) REFERENCES Progress(id),
    CONSTRAINT fk_type_id FOREIGN KEY (device_type_id) REFERENCES DeviceType(id)
);

CREATE TABLE ServiceOrder (
	id INT IDENTITY(1,1) PRIMARY KEY,
	client_id INT NOT NULL,
	open_date DATETIME NOT NULL,
	orderitem_id INT NOT NULL,
    CONSTRAINT fk_client_id FOREIGN KEY (client_id) REFERENCES Client(id),
    CONSTRAINT fk_orderitem_id FOREIGN KEY (orderitem_id) REFERENCES OrderItem(id) ON DELETE CASCADE
);


CREATE TABLE Inventory (
	id INT IDENTITY(1,1) PRIMARY KEY,
	name varchar(60) NOT NULL,
	quantity INT NOT NULL
);

CREATE TABLE Part (
	id INT IDENTITY(1,1) PRIMARY KEY,
	orderitem_id INT NOT NULL,
	inventory_id INT NOT NULL,
    CONSTRAINT fk_parts_orderitem_id FOREIGN KEY (orderitem_id) REFERENCES OrderItem(id),
    CONSTRAINT fk_parts_inventory_id FOREIGN KEY (inventory_id) REFERENCES Inventory(id)
);
