package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"sync"
)

type Task struct {
	ID          int    `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Completed   bool   `json:"completed"`
}

var (
	tasks = make(map[int]Task)
	mutex = &sync.Mutex{}
	id    = 1
)

func main() {
	// Enable CORS
	http.HandleFunc("/tasks", corsMiddleware(handleTasks))
	http.HandleFunc("/tasks/", corsMiddleware(handleTask))

	port := ":8080"
	fmt.Printf("Server starting on port %s...\n", port)
	log.Fatal(http.ListenAndServe(port, nil))
}

func corsMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Set CORS headers
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, Authorization")
		w.Header().Set("Access-Control-Max-Age", "3600")

		// Handle preflight requests
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		// Set content type for all responses
		w.Header().Set("Content-Type", "application/json")

		next(w, r)
	}
}

func handleTasks(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		getAllTasks(w, r)
	case http.MethodPost:
		createTask(w, r)
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func handleTask(w http.ResponseWriter, r *http.Request) {
	idStr := r.URL.Path[len("/tasks/"):]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid task ID", http.StatusBadRequest)
		return
	}

	switch r.Method {
	case http.MethodGet:
		getTask(w, r, id)
	case http.MethodPut:
		updateTask(w, r, id)
	case http.MethodDelete:
		deleteTask(w, r, id)
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func getAllTasks(w http.ResponseWriter, r *http.Request) {
	mutex.Lock()
	defer mutex.Unlock()

	taskList := make([]Task, 0, len(tasks))
	for _, task := range tasks {
		taskList = append(taskList, task)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(taskList)
}

func getTask(w http.ResponseWriter, r *http.Request, id int) {
	mutex.Lock()
	defer mutex.Unlock()

	task, exists := tasks[id]
	if !exists {
		http.Error(w, "Task not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(task)
}

func createTask(w http.ResponseWriter, r *http.Request) {
	var task Task
	if err := json.NewDecoder(r.Body).Decode(&task); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if task.Title == "" {
		http.Error(w, "Title is required", http.StatusBadRequest)
		return
	}

	mutex.Lock()
	defer mutex.Unlock()

	task.ID = id
	id++
	tasks[task.ID] = task

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(task)
}

func updateTask(w http.ResponseWriter, r *http.Request, id int) {
	var task Task
	if err := json.NewDecoder(r.Body).Decode(&task); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if task.Title == "" {
		http.Error(w, "Title is required", http.StatusBadRequest)
		return
	}

	mutex.Lock()
	defer mutex.Unlock()

	_, exists := tasks[id]
	if !exists {
		http.Error(w, "Task not found", http.StatusNotFound)
		return
	}

	task.ID = id
	tasks[id] = task

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(task)
}

func deleteTask(w http.ResponseWriter, r *http.Request, id int) {
	mutex.Lock()
	defer mutex.Unlock()

	_, exists := tasks[id]
	if !exists {
		http.Error(w, "Task not found", http.StatusNotFound)
		return
	}

	delete(tasks, id)
	w.WriteHeader(http.StatusNoContent)
}
