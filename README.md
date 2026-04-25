# Medical Expert System

A symptom-based disease diagnosis system powered by a Prolog knowledge base (SWI-Prolog), a FastAPI backend, and a Next.js frontend.

## Prerequisites

- [SWI-Prolog](https://www.swi-prolog.org/Download.html) — must be installed and available on your PATH
- Python 3.12+
- Node.js 18+

## Project Structure

```
.
├── client/       # Next.js frontend
├── server/       # FastAPI backend
│   └── engine/   # Prolog knowledge base (.pl files)
└── requirements.txt
```

## Running the Server

The server uses FastAPI and communicates with SWI-Prolog via `pyswip`. SWI-Prolog must be installed before running the server.

### 1. Create and activate a virtual environment

```bash
python -m venv venv
source venv/bin/activate        # Linux/macOS
# venv\Scripts\activate         # Windows
```

### 2. Install Python dependencies

```bash
pip install -r requirements.txt
```

### 3. Start the server

```bash
cd server
fastapi dev main.py
```

The API will be available at `http://localhost:8000`.  
Interactive API docs: `http://localhost:8000/docs`

## Running the Client

The client is a Next.js application.

### 1. Install dependencies

```bash
cd client
npm install
```

### 2. Start the development server

```bash
npm run dev
```

The app will be available at `http://localhost:3000`.
