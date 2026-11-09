import random
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy.sql.expression import func
from app.database import get_db
from app.models.entities import Question
from app.schemas.schemas import QuestionResponse

router = APIRouter(prefix="/questions", tags=["Questions & Test Generation"])

TOPIC_INFO = {
    "aptitude": {"name": "Aptitude", "icon": "🧮", "color": "#FFB020"},
    "logical": {"name": "Logical Reasoning", "icon": "🧩", "color": "#8B5CF6"},
    "verbal": {"name": "Verbal Ability", "icon": "📝", "color": "#00D68F"},
    "coding": {"name": "Coding & Technical", "icon": "💻", "color": "#FF4C6A"},
    "data_interp": {"name": "Data Interpretation", "icon": "📈", "color": "#E040FB"},
}

COMPANY_PATTERNS = {
    "TCS": {"aptitude": 8, "logical": 7, "verbal": 5, "coding": 5, "data_interp": 5, "time_minutes": 30},
    "Infosys": {"aptitude": 10, "logical": 10, "verbal": 5, "coding": 5, "data_interp": 0, "time_minutes": 30},
    "Wipro": {"aptitude": 8, "logical": 8, "verbal": 8, "coding": 6, "data_interp": 0, "time_minutes": 30},
    "Cognizant": {"aptitude": 10, "logical": 8, "verbal": 7, "coding": 5, "data_interp": 0, "time_minutes": 30},
    "Accenture": {"aptitude": 8, "logical": 8, "verbal": 8, "coding": 6, "data_interp": 0, "time_minutes": 30},
    "Amazon": {"aptitude": 5, "logical": 5, "verbal": 0, "coding": 15, "data_interp": 5, "time_minutes": 35},
    "Google": {"aptitude": 5, "logical": 7, "verbal": 0, "coding": 15, "data_interp": 3, "time_minutes": 40},
    "Microsoft": {"aptitude": 5, "logical": 5, "verbal": 0, "coding": 15, "data_interp": 5, "time_minutes": 35},
    "Deloitte": {"aptitude": 10, "logical": 10, "verbal": 10, "coding": 0, "data_interp": 0, "time_minutes": 30},
    "Goldman Sachs": {"aptitude": 10, "logical": 10, "verbal": 0, "coding": 10, "data_interp": 0, "time_minutes": 35},
}

def question_to_response(q: Question, include_answer: bool = False) -> QuestionResponse:
    return QuestionResponse(
        id=q.id,
        topic=q.topic,
        question_text=q.question_text,
        options=q.options,
        correct_answer=q.correct_answer if include_answer else None,
        explanation=q.explanation if include_answer else None,
        concept=q.concept,
        difficulty=q.difficulty,
        tags=q.tags,
        company_tags=q.company_tags
    )

@router.get("/topics")
def get_topics(db: Session = Depends(get_db)):
    result = []
    for key, info in TOPIC_INFO.items():
        count = db.query(Question).filter(Question.topic == key).count()
        # Get unique concepts
        concepts = [c[0] for c in db.query(Question.concept).filter(Question.topic == key).distinct().all() if c[0]]
        result.append({
            "key": key,
            "name": info["name"],
            "icon": info["icon"],
            "color": info["color"],
            "question_count": count,
            "subtopics": concepts
        })
    return result

@router.get("/topic/{topic}", response_model=List[QuestionResponse])
def get_topic_questions(
    topic: str,
    difficulty: Optional[str] = None,
    concept: Optional[str] = None,
    limit: int = Query(default=15, le=50),
    db: Session = Depends(get_db)
):
    query = db.query(Question).filter(Question.topic == topic)
    if difficulty:
        query = query.filter(Question.difficulty == difficulty)
    if concept:
        query = query.filter(Question.concept == concept)
        
    questions = query.order_by(func.random()).limit(limit).all()
    return [question_to_response(q, include_answer=False) for q in questions]

@router.get("/company/{company}")
def get_company_test(company: str, db: Session = Depends(get_db)):
    pattern = COMPANY_PATTERNS.get(company)
    if not pattern:
        # Default fallback
        pattern = {"aptitude": 8, "logical": 8, "verbal": 6, "coding": 5, "data_interp": 3, "time_minutes": 30}
        
    selected_questions = []
    for topic, count in pattern.items():
        if topic == "time_minutes" or count <= 0:
            continue
        qs = db.query(Question).filter(Question.topic == topic).order_by(func.random()).limit(count).all()
        selected_questions.extend(qs)
        
    random.shuffle(selected_questions)
    return {
        "company": company,
        "time_minutes": pattern.get("time_minutes", 30),
        "total_questions": len(selected_questions),
        "questions": [question_to_response(q, include_answer=False) for q in selected_questions]
    }

@router.get("/quick-test/{mode}")
def get_quick_test(mode: str, db: Session = Depends(get_db)):
    mode = mode.lower()
    config = {
        "sprint": {"count": 10, "time_minutes": 10, "title": "⚡ Speed Sprint"},
        "daily": {"count": 15, "time_minutes": 15, "title": "📅 Daily Challenge"},
        "drill": {"count": 20, "time_minutes": 20, "title": "🎯 Mixed Drill"},
        "marathon": {"count": 50, "time_minutes": 60, "title": "🏃 Marathon Mock"},
    }.get(mode, {"count": 15, "time_minutes": 15, "title": "Practice Test"})

    questions = db.query(Question).order_by(func.random()).limit(config["count"]).all()
    return {
        "mode": mode,
        "title": config["title"],
        "time_minutes": config["time_minutes"],
        "total_questions": len(questions),
        "questions": [question_to_response(q, include_answer=False) for q in questions]
    }
