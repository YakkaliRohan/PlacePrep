#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"
source venv/bin/activate
echo "🚀 Starting PlacePrep API server on http://127.0.0.1:8000"
echo "📖 Swagger API Docs available at http://127.0.0.1:8000/api/docs"
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
