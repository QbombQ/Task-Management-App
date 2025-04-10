# Task Management Application

A full-stack task management application built with Flutter and Golang, featuring a modern UI and RESTful API.

## Features

- **Task Management**
  - Create, read, update, and delete tasks
  - Mark tasks as complete/incomplete
  - View task details
  - Responsive design for all screen sizes

- **Modern UI**
  - Clean and intuitive interface
  - Swipe actions for quick task management
  - Loading states and error handling
  - Dark mode support

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Golang
- **State Management**: Provider
- **HTTP Client**: http package
- **UI Components**: Material Design 3

## Project Structure

```
task_manager/
├── backend/                 # Golang backend
│   ├── main.go             # Entry point
│   ├── handlers/           # HTTP handlers
│   ├── models/             # Data models
│   └── storage/            # In-memory storage
│
└── frontend/               # Flutter frontend
    ├── lib/
    │   ├── models/         # Data models
    │   ├── providers/      # State management
    │   ├── screens/        # UI screens
    │   └── widgets/        # Reusable components
    └── pubspec.yaml        # Dependencies
```

## Setup Instructions

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   go mod download
   ```

3. Run the server:
   ```bash
   go run main.go
   ```

The backend server will start on `http://localhost:8080`

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/tasks` | Retrieve all tasks |
| GET | `/tasks/{id}` | Retrieve a specific task |
| POST | `/tasks` | Create a new task |
| PUT | `/tasks/{id}` | Update an existing task |
| DELETE | `/tasks/{id}` | Delete a task |

## Architecture

### Backend Architecture

The backend follows a clean architecture pattern:
- **Handlers**: Handle HTTP requests and responses
- **Models**: Define data structures
- **Storage**: Manages in-memory data persistence
- **Middleware**: Handles cross-cutting concerns

### Frontend Architecture

The frontend uses the Provider pattern for state management:
- **Models**: Define data structures
- **Providers**: Manage application state
- **Screens**: Implement UI components
- **Widgets**: Reusable UI components

## Error Handling

- **Backend**: Proper HTTP status codes and error messages
- **Frontend**: User-friendly error messages with SnackBar notifications
- **Network**: Proper handling of connection issues and timeouts

## UI/UX Features

- **Responsive Design**: Adapts to different screen sizes
- **Modern UI**: Material Design 3 components
- **Swipe Actions**: Quick task management
- **Loading States**: Visual feedback during operations
- **Error Handling**: User-friendly error messages

## Screenshots

   [Watch the demo](./video.mp4)



## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 