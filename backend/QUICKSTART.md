# Quick Start - Backend

## How to Run the Backend

### Option 1: Using the batch file (Windows - Easiest)

1. Double-click `start_server.bat` in the backend folder
2. Wait for dependencies to install (first time only)
3. The server will start automatically

### Option 2: Using Python command

Open a terminal/command prompt in the backend folder and run:

```bash
python run.py
```

### Option 3: Using uvicorn directly

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Option 4: Using Python module

```bash
python -m app.main
```

## What You Need Before Starting

1. **Python 3.9 or higher** installed
2. **Dependencies installed** (run `pip install -r requirements.txt`)
3. **.env file configured** with your API keys

## Configuration

Copy `.env.example` to `.env` and add your API keys:

```bash
cp .env.example .env
```

Then edit `.env` and add:
- `HF_API_TOKEN` - Get from https://huggingface.co/settings/tokens
- `USDA_API_KEY` - Get from https://api.nal.usda.gov/
- LM Studio settings (if using local processing)

## Verify It's Working

Once started, visit:
- **API**: http://localhost:8000
- **Docs**: http://localhost:8000/docs
- **Status**: http://localhost:8000/api/status

## Troubleshooting

### "Module not found" error
Make sure you're in the backend directory:
```bash
cd backend
python run.py
```

### "No module named 'fastapi'"
Install dependencies:
```bash
pip install -r requirements.txt
```

### Port already in use
Change the port in `run.py` or stop the process using port 8000:
```bash
# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:8000 | xargs kill -9
```

### LM Studio not available
- Make sure LM Studio is running
- Check the server is started in LM Studio settings
- Verify port matches in `.env` (default: 1234)
