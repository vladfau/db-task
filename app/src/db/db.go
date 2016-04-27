package db

import "fmt"
import _ "github.com/denisenkom/go-mssqldb"
import "database/sql"
import "strconv"

const DB_SERVER string = "localhost"
const DB_USER string = "sa"
const DB_PASS string = "c00lP5ss"
const DB_PORT string = "1433"
const DB_NAME string = "serviceCenterMain"

func getConn() *sql.DB {
	dbString := fmt.Sprintf("server=%s;user id=%s;password=%s;port=%s;databaseName=%s", DB_SERVER, DB_USER, DB_PASS, DB_PORT, DB_NAME)
	db, err := sql.Open("mssql", dbString)
	if err != nil {
		fmt.Println("Open connection failed %s:", err.Error())
	}
	return db
}

func doLogin(db *sql.DB, isEmp bool, login string) (*sql.Rows, error) {
	var q string
	if isEmp {
		q = fmt.Sprintf("SELECT id, password FROM %s.dbo.Employee WHERE email LIKE '%s'", DB_NAME, login)
	} else {
		q = fmt.Sprintf("SELECT id, password FROM %s.dbo.Client WHERE email LIKE '%s'", DB_NAME, login)
	}
	return db.Query(q)
}

func LoginEmployee(login string, password string) (string, bool, int) {
	db := getConn()
	defer db.Close()

	rows, err := doLogin(db, true, login)
	defer rows.Close()
	if err != nil {
		return err.Error(), false, -1
	} else {
		rows.Next()
		var db_password string
		var id int
		rows.Scan(&id, &db_password)
		if db_password != password {
			return "Wrong password or no such user", false, -1
		} else {
			return "All good", true, id
		}
	}
}

func LoginClient(login string, password string) (string, bool, int) {
	db := getConn()
	defer db.Close()

	rows, err := doLogin(db, false, login)
	defer rows.Close()
	if err != nil {
		return err.Error(), false, -1
	}
	if !rows.Next() {
		return "No such client", false, -1
	} else {
		var db_password string
		var id int
		rows.Scan(&id, &db_password)
		fmt.Println(db_password)
		if db_password != password {
			return "Wrong password", false, -1
		} else {
			return "All good", true, id
		}
	}
}

func GetEmployeeDepartment(uid int) (string, bool) {
	db := getConn()
	defer db.Close()

	q := fmt.Sprintf(`SELECT DISTINCT t.name
FROM %s.dbo.Employee as e
JOIN %s.dbo.OrgUnit as ou
ON e.id = ou.employee_id
JOIN %s.dbo.Team as t
ON ou.team_id = t.id
WHERE e.id = ?`, DB_NAME, DB_NAME, DB_NAME)
	rows, err := db.Query(q, uid)
	defer rows.Close()
	if err != nil {
		return err.Error(), false
	}
	if !rows.Next() {
		return "No such employee", false
	} else {
		var team string
		rows.Scan(&team)
		return team, true
	}

}

func GetDeviceTypes() ([]string, bool) {
	db := getConn()
	defer db.Close()

	res := make([]string, 0)
	q := fmt.Sprintf(`SELECT name FROM %s.dbo.DeviceType ORDER by id`, DB_NAME)
	rows, err := db.Query(q)
	defer rows.Close()
	if err != nil {
		return nil, false
	}
	for rows.Next() {
		var t string
		rows.Scan(&t)
		res = append(res, t)
	}

	return res, true
}

func RegisterUser(email string, fname string, lname string, password string, phone string) (string, bool) {
	db := getConn()
	defer db.Close()
	q := fmt.Sprintf("insert into %s.dbo.Client (first_name, last_name, phone, email, password) values (?, ?, ?, ?, ?)", DB_NAME)
	stmt, err := db.Prepare(q)
	defer stmt.Close()
	_, err = stmt.Exec(fname, lname, phone, email, password)
	if err != nil {
		return err.Error(), false
	} else {
		return "OK", true
	}
}

func CreateOrderItem(device string, iswar int, serial string, issue string, dtype int) (int64, bool) {
	db := getConn()
	defer db.Close()
	q := fmt.Sprintf("insert into %s.dbo.OrderItem (name, device_type_id, issue, is_warranty, serial) values (?, ?, ?, ?, ?)", DB_NAME)
	stmt, err := db.Prepare(q)
	defer stmt.Close()
	res, err := stmt.Exec(device, dtype, issue, iswar, serial)
	if err != nil {
		fmt.Println(err.Error())
		return -1, false
	} else {
		// this will be ProgressId
		lastId, err := res.LastInsertId()

		q = fmt.Sprintf("SELECT id FROM %s.dbo.OrderItem WHERE progress_id = ?", DB_NAME)
		rows, err := db.Query(q, lastId)
		defer rows.Close()
		if err != nil {
			return -1, false
		} else {
			rows.Next()
			var id int64
			rows.Scan(&id)
			return id, true
		}

	}
}

func CreateServiceOrder(client string, orderid int64) (int64, bool) {
	db := getConn()
	defer db.Close()
	q := fmt.Sprintf("SELECT id FROM %s.dbo.Client WHERE email = ?", DB_NAME)
	rows, err := db.Query(q, client)
	defer rows.Close()
	var id int64
	if err != nil {
		return -1, false
	} else {
		rows.Next()
		rows.Scan(&id)
	}
	q = fmt.Sprintf("insert into %s.dbo.ServiceOrder (client_id, orderitem_id) values (?, ?)", DB_NAME)
	stmt, err := db.Prepare(q)
	defer stmt.Close()
	res, err := stmt.Exec(id, orderid)
	if err != nil {
		fmt.Println(err.Error())
		return -1, false
	} else {
		lastId, _ := res.LastInsertId()
		return lastId, true
	}
}

func GetMyTasks(uid string) [][]string {
	db := getConn()
	defer db.Close()
	q := fmt.Sprintf(`
SELECT so.id, oi.id, oi.name, oi.issue, so.open_date, cl.first_name, cl.last_name, s.name
FROM %s.dbo.ServiceOrder as so
JOIN %s.dbo.OrderItem as oi
on so.orderitem_id = oi.id
JOIN %s.dbo.Client as cl
ON so.client_id = cl.id
JOIN %s.dbo.Progress as p
ON oi.progress_id = p.id
JOIN %s.dbo.Status as s
ON p.status = s.id
WHERE p.assignee = ?`, DB_NAME, DB_NAME, DB_NAME, DB_NAME, DB_NAME)
	rows, err := db.Query(q, uid)
	defer rows.Close()
	var so_id, oi_id int64
	var dname, issue, date, client_fname, client_lname, status string
	if err != nil {
		fmt.Println(err)
		return nil
	} else {
		res := make([][]string, 0)
		for rows.Next() {
			rows.Scan(&so_id, &oi_id,
				&dname, &issue, &date,
				&client_fname, &client_lname, &status)
			__soid := strconv.FormatInt(so_id, 10)
			__oiid := strconv.FormatInt(oi_id, 10)
			__row := []string{__soid, __oiid, dname, issue, date, client_fname, client_lname, status}
			res = append(res, __row)
		}
		return res
	}

}

func GetTasksForClient(uid string) [][]string {
	db := getConn()
	defer db.Close()
	q := fmt.Sprintf(`
SELECT so.id, oi.name, oi.issue, so.open_date, s.name
FROM %s.dbo.ServiceOrder as so
JOIN %s.dbo.OrderItem as oi
on so.orderitem_id = oi.id
JOIN %s.dbo.Client as cl
ON so.client_id = cl.id
JOIN %s.dbo.Progress as p
ON oi.progress_id = p.id
JOIN %s.dbo.Status as s
ON p.status = s.id
WHERE cl.id = ?`, DB_NAME, DB_NAME, DB_NAME, DB_NAME, DB_NAME)
	rows, err := db.Query(q, uid)
	defer rows.Close()
	var so_id int64
	var dname, issue, date, status string
	if err != nil {
		fmt.Println(err)
		return nil
	} else {
		res := make([][]string, 0)
		for rows.Next() {
			rows.Scan(&so_id,
				&dname, &issue, &date,
				&status)
			__soid := strconv.FormatInt(so_id, 10)
			__row := []string{__soid, dname, issue, date, status}
			res = append(res, __row)
		}
		return res
	}

}

func GetStatuses() []string {
	db := getConn()
	defer db.Close()
	q := fmt.Sprintf("select name from %s.dbo.Status order by id", DB_NAME)
	rows, err := db.Query(q)
	defer rows.Close()
	var name string
	if err != nil {
		fmt.Println(err)
		return nil
	} else {
		res := make([]string, 0)
		for rows.Next() {
			rows.Scan(&name)
			res = append(res, name)
		}
		return res
	}
}

func UpdateStatus(oiid string, newstatus string) {
	db := getConn()
	defer db.Close()
	q := fmt.Sprintf(`UPDATE %s.dbo.Progress SET status = (SELECT id FROM %s.dbo.Status WHERE name = ?) WHERE id = (SELECT progress_id FROM %s.dbo.OrderItem AS oi WHERE oi.id = ?)`, DB_NAME, DB_NAME, DB_NAME)
	stmt, _ := db.Prepare(q)
	defer stmt.Close()
	_, err := stmt.Exec(newstatus, oiid)
	if err != nil {
		fmt.Println(err.Error())
	}
}

func qInv(db *sql.DB, q string) [][]string {
	rows, err := db.Query(q)
	defer rows.Close()
	var name string
	var quantity string
	if err != nil {
		fmt.Println(err)
		return nil
	} else {
		res := make([][]string, 0)
		for rows.Next() {
			rows.Scan(&name, &quantity)
			res = append(res, []string{name, quantity})
		}
		return res
	}

}

func GetAllInventory() [][]string {
	db := getConn()
	defer db.Close()
	q := fmt.Sprintf("select name, quantity from %s.dbo.Inventory order by id", DB_NAME)
	return qInv(db, q)
}

func GetFilteredInventory(name string, fop string, gt string, sop string, lt string) [][]string {
	db := getConn()
	q := fmt.Sprintf("select name, quantity from %s.dbo.Inventory", DB_NAME)
	defer db.Close()
	clause := ""
	if name != "" {
		clause += "name like '%" + name + "%' "
	}
	if gt != "" {
		if name != "" {
			clause += fop + " "
		}
		clause += " quantity > " + gt
	}
	if lt != "" {
		if name != "" || gt != "" {
			clause += " " + sop + " "
		}
		clause += " quantity < " + lt
	}
	q += " WHERE " + clause
	fmt.Println(q)
	return qInv(db, q)
}
