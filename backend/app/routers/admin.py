from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.database import get_db
from app.models.entities import User, Question, TestAttempt, Feedback
from app.schemas.schemas import AdminStatsResponse, UserResponse, FeedbackCreate, FeedbackResponse
from app.services.auth import get_current_admin, get_optional_user

router = APIRouter(prefix="/admin", tags=["Admin Operations"])

@router.get("/stats", response_model=AdminStatsResponse)
def get_admin_stats(
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    total_users = db.query(User).filter(User.is_guest == False).count()
    total_tests = db.query(TestAttempt).count()
    total_questions = db.query(Question).count()
    
    avg_acc = db.query(func.avg(TestAttempt.accuracy)).scalar() or 0.0

    # Topic distribution
    topic_counts = dict(db.query(Question.topic, func.count(Question.id)).group_by(Question.topic).all())
    
    # Difficulty distribution
    diff_counts = dict(db.query(Question.difficulty, func.count(Question.id)).group_by(Question.difficulty).all())

    return AdminStatsResponse(
        total_users=total_users,
        total_tests_taken=total_tests,
        total_questions_in_bank=total_questions,
        average_accuracy=round(float(avg_acc), 1),
        topic_distribution=topic_counts,
        difficulty_distribution=diff_counts
    )

@router.get("/users", response_model=List[UserResponse])
def get_all_users(
    limit: int = 100,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    users = db.query(User).filter(User.is_guest == False).order_by(User.created_at.desc()).limit(limit).all()
    return [UserResponse.from_orm(u) for u in users]

@router.get("/feedback", response_model=List[FeedbackResponse])
def get_feedbacks(
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    return db.query(Feedback).order_by(Feedback.created_at.desc()).limit(100).all()

# Public feedback submission
feedback_router = APIRouter(prefix="/feedback", tags=["Feedback"])

@feedback_router.post("", response_model=FeedbackResponse)
def submit_feedback(
    data: FeedbackCreate,
    current_user: User = Depends(get_optional_user),
    db: Session = Depends(get_db)
):
    fb = Feedback(
        user_id=current_user.id if current_user else None,
        name=data.name or (current_user.name if current_user else "Anonymous"),
        email=data.email or (current_user.email if current_user else ""),
        rating=data.rating,
        category=data.category,
        message=data.message.strip()
    )
    db.add(fb)
    db.commit()
    db.refresh(fb)
    return fb
