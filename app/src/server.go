package main

import (
	"db"
	"fmt"
	"html/template"
	"io"
	"log"
	"net/http"
	"strconv"
	"time"
)

const STATIC_URL string = "/static/"
const STATIC_ROOT string = "static/"

type Context struct {
	Title       string
	Data        map[string]string
	MData       map[string][]string
	Tasks       [][]string
	AccountType string
	Static      string
}

func Home(w http.ResponseWriter, req *http.Request) {
	context := Context{Title: "Welcome!"}
	render(w, "index", context)
}

func Inventory(w http.ResponseWriter, req *http.Request) {
	items := make([][]string, 0)
	if req.Method == "POST" {
		name := req.FormValue("name")
		first_op := req.Form.Get("first_op")
		gt := req.FormValue("gt")
		second_op := req.Form.Get("second_op")
		lt := req.FormValue("lt")
		items = db.GetFilteredInventory(name, first_op, gt, second_op, lt)
	} else {
		items = db.GetAllInventory()
	}
	context := Context{Title: "Search example!", Tasks: items}
	render(w, "inventory", context)
}

func Account(w http.ResponseWriter, req *http.Request) {
	uid, _ := req.Cookie("user_id")
	at, _ := req.Cookie("account_type")
	if uid == nil || at == nil {
		http.Redirect(w, req, "/login", http.StatusFound)
	} else {
		data := map[string]string{"Id": uid.Value}
		tasks := db.GetTasksForClient(uid.Value)
		context := Context{Title: "Logged in", AccountType: at.Value, Data: data, Tasks: tasks}
		render(w, "account", context)
	}
}

func CreateOrder(w http.ResponseWriter, req *http.Request) {
	uid, _ := req.Cookie("user_id")
	at, _ := req.Cookie("account_type")
	mdata := make(map[string][]string, 0)
	dtypes, _ := db.GetDeviceTypes()
	mdata["DeviceTypes"] = dtypes
	if uid == nil || at == nil || at.Value != "Reception" {
		http.Redirect(w, req, "/login", http.StatusFound)
	} else {
		if req.Method == "GET" {
			context := Context{Title: "Create new order",
				MData: mdata}
			render(w, "createorder", context)
		} else {
			data := make(map[string]string, 0)
			req.ParseForm()
			formvals := map[string]string{"newclient": "",
				"email":      "",
				"fname":      "",
				"lname":      "",
				"pwd":        "",
				"phone":      "",
				"device":     "",
				"serial":     "",
				"issuedescr": "",
				"iswar":      ""}
			for k, _ := range formvals {
				formvals[k] = req.FormValue(k)
			}
			var dtype int
			for i, k := range dtypes {
				if k == req.Form.Get("dtype") {
					dtype = i + 1
					break
				}
			}
			if formvals["newclient"] == "on" {
				msg, _ := db.RegisterUser(formvals["email"],
					formvals["fname"],
					formvals["lname"],
					formvals["pwd"],
					formvals["phone"])
				data["New User Created"] = msg
			}
			b_iswar := 1
			if formvals["iswar"] == "" {
				b_iswar = 0
			}
			oid, _ := db.CreateOrderItem(formvals["device"],
				b_iswar,
				formvals["serial"],
				formvals["issuedescr"],
				dtype)
			data["OrderItem id"] = strconv.FormatInt(oid, 10)

			soid, _ := db.CreateServiceOrder(formvals["email"], oid)

			data["ServiceOrder id"] = strconv.FormatInt(soid, 10)
			context := Context{Title: "Create new order", Data: data}

			render(w, "neworder", context)
		}
	}
}

func Login(w http.ResponseWriter, req *http.Request) {
	if req.Method == "GET" {
		context := Context{Title: "Login!"}
		render(w, "login", context)
	} else {
		req.ParseForm()
		u := req.FormValue("lg_username")
		p := req.FormValue("lg_password")
		e := req.FormValue("lg_employee")
		var resp string
		var st bool
		var uid int
		if e == "on" {
			resp, st, uid = db.LoginEmployee(u, p)
			team, good := db.GetEmployeeDepartment(uid)
			fmt.Println(resp)
			if good == true {
				e = team
			} else {
				data := map[string]string{"Reason": team}
				context := Context{Title: "Failure",
					Data: data}
				render(w, "fail", context)
				return
			}
		} else {
			resp, st, uid = db.LoginClient(u, p)
			e = "Client"
		}
		if st {
			expiration := time.Now().Add(365 * 24 * time.Hour)
			cookie := http.Cookie{Name: "user_id", Value: strconv.Itoa(uid), Expires: expiration}
			http.SetCookie(w, &cookie)
			cookie = http.Cookie{Name: "account_type", Value: e, Expires: expiration}
			http.SetCookie(w, &cookie)
			http.Redirect(w, req, "/account", http.StatusFound)
		} else {
			data := map[string]string{"Reason": resp}
			context := Context{Title: "Failure",
				Data: data}
			render(w, "fail", context)
		}
	}
}

func MyTasks(w http.ResponseWriter, req *http.Request) {
	uid, _ := req.Cookie("user_id")
	at, _ := req.Cookie("account_type")
	if uid == nil || at == nil || at.Value == "Client" {
		http.Redirect(w, req, "/account", http.StatusFound)
	} else {
		if req.Method == "POST" {
			oiid := req.FormValue("oiid")
			newst := req.Form.Get("newst")
			db.UpdateStatus(oiid, newst)
		}
		tasks := db.GetMyTasks(uid.Value)
		mdata := make(map[string][]string)
		mdata["Status"] = db.GetStatuses()
		context := Context{Title: "Your tasks", Tasks: tasks, MData: mdata}

		render(w, "tasks", context)

	}
}
func render(w http.ResponseWriter, tmpl string, context Context) {
	context.Static = STATIC_URL
	tmpl_list := []string{"templates/base.html",
		fmt.Sprintf("templates/%s.html", tmpl)}
	t, err := template.ParseFiles(tmpl_list...)
	if err != nil {
		log.Print("template parsing error: ", err)
	}
	err = t.Execute(w, context)
	if err != nil {
		log.Print("template executing error: ", err)
	}
}

func StaticHandler(w http.ResponseWriter, req *http.Request) {
	static_file := req.URL.Path[len(STATIC_URL):]
	if len(static_file) != 0 {
		f, err := http.Dir(STATIC_ROOT).Open(static_file)
		if err == nil {
			content := io.ReadSeeker(f)
			http.ServeContent(w, req, static_file, time.Now(), content)
			return
		}
	}
	http.NotFound(w, req)
}

func main() {
	http.HandleFunc("/tasks", MyTasks)
	http.HandleFunc("/", Home)
	http.HandleFunc("/account", Account)
	http.HandleFunc("/login", Login)
	http.HandleFunc("/createorder", CreateOrder)
	http.HandleFunc("/inventory", Inventory)
	http.HandleFunc(STATIC_URL, StaticHandler)
	err := http.ListenAndServe(":8000", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
