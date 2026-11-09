from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import Question, TestAttempt, User
from app.schemas.schemas import TestSubmission, TestResultResponse, DetailedAnswerResult, TestAttemptHistoryResponse
from app.services.auth import get_current_user

router = APIRouter(prefix="/tests", tags=["Tests & Submissions"])

@router.post("/submit", response_model=TestResultResponse)
def submit_test(
    submission: TestSubmission,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if not submission.answers:
        raise HTTPException(status_code=400, detail="Submission contains no answers")

    question_ids = [a.question_id for a in submission.answers]
    questions = db.query(Question).filter(Question.id.in_(question_ids)).all()
    q_map = {q.id: q for q in questions}

    correct_count = 0
    incorrect_count = 0
    unattempted_count = 0
    detailed_results = []
    section_stats = {} # topic -> {total, correct}

    for ans in submission.answers:
        q = q_map.get(ans.question_id)
        if not q:
            continue

        topic = q.topic
        if topic not in section_stats:
            section_stats[topic] = {"total": 0, "correct": 0}
        section_stats[topic]["total"] += 1

        is_correct = False
        if ans.selected_option is None or ans.selected_option < 0:
            unattempted_count += 1
        elif ans.selected_option == q.correct_answer:
            correct_count += 1
            is_correct = True
            section_stats[topic]["correct"] += 1
        else:
            incorrect_count += 1

        detailed_results.append(DetailedAnswerResult(
            question_id=q.id,
            question_text=q.question_text,
            options=q.options,
            selected_option=ans.selected_option,
            correct_answer=q.correct_answer,
            is_correct=is_correct,
            explanation=q.explanation,
            concept=q.concept,
            difficulty=q.difficulty
        ))

    total_q = len(detailed_results)
    score = float(correct_count)
    accuracy = round((correct_count / total_q * 100.0), 1) if total_q > 0 else 0.0

    # Calculate section percentages
    section_breakdown = {}
    for top, s in section_stats.items():
        pct = round((s["correct"] / s["total"] * 100.0), 1) if s["total"] > 0 else 0.0
        section_breakdown[top] = {
            "total": s["total"],
            "correct": s["correct"],
            "accuracy": pct
        }

    # Save TestAttempt
    attempt = TestAttempt(
        user_id=current_user.id,
        test_title=submission.test_title,
        test_type=submission.test_type,
        score=score,
        total_questions=total_q,
        correct_count=correct_count,
        incorrect_count=incorrect_count,
        unattempted_count=unattempted_count,
        accuracy=accuracy,
        time_taken_seconds=submission.total_time_seconds,
    )
    attempt.section_breakdown = section_breakdown
    attempt.answers_summary = [d.dict() for d in detailed_results]

    db.add(attempt)

    # Update User Profile Statistics
    current_user.tests_taken += 1
    current_user.questions_solved += correct_count
    # Update running total accuracy
    if current_user.tests_taken == 1:
        current_user.total_accuracy = accuracy
    else:
        # Exponential or simple moving average
        current_user.total_accuracy = round(
            (current_user.total_accuracy * (current_user.tests_taken - 1) + accuracy) / current_user.tests_taken, 1
        )
    current_user.streak = (current_user.streak or 0) + 1

    db.commit()
    db.refresh(attempt)

    return TestResultResponse(
        attempt_id=attempt.id,
        test_title=attempt.test_title,
        test_type=attempt.test_type,
        total_questions=total_q,
        correct_count=correct_count,
        incorrect_count=incorrect_count,
        unattempted_count=unattempted_count,
        score=score,
        accuracy=accuracy,
        time_taken_seconds=attempt.time_taken_seconds,
        section_breakdown=section_breakdown,
        answers_summary=detailed_results,
        created_at=attempt.created_at
    )

@router.get("/history", response_model=List[TestAttemptHistoryResponse])
def get_history(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    attempts = db.query(TestAttempt).filter(
        TestAttempt.user_id == current_user.id
    ).order_by(TestAttempt.created_at.desc()).limit(30).all()
    return attempts

@router.get("/{attempt_id}", response_model=TestResultResponse)
def get_attempt_detail(
    attempt_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    attempt = db.query(TestAttempt).filter(TestAttempt.id == attempt_id).first()
    if not attempt:
        raise HTTPException(status_code=404, detail="Test attempt not found")
        
    # User can only view their own attempts unless admin
    if attempt.user_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized")

    raw_summary = attempt.answers_summary
    detailed_results = [DetailedAnswerResult(**r) for r in raw_summary]

    return TestResultResponse(
        attempt_id=attempt.id,
        test_title=attempt.test_title,
        test_type=attempt.test_type,
        total_questions=attempt.total_questions,
        correct_count=attempt.correct_count,
        incorrect_count=attempt.incorrect_count,
        unattempted_count=attempt.unattempted_count,
        score=attempt.score,
        accuracy=attempt.accuracy,
        time_taken_seconds=attempt.time_taken_seconds,
        section_breakdown=attempt.section_breakdown,
        answers_summary=detailed_results,
        created_at=attempt.created_at
    )
