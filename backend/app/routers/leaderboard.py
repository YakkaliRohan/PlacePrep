from typing import Optional
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import desc
from app.database import get_db
from app.models.entities import User
from app.schemas.schemas import LeaderboardResponse, LeaderboardUser
from app.services.auth import get_optional_user

router = APIRouter(prefix="/leaderboard", tags=["Leaderboard"])

@router.get("", response_model=LeaderboardResponse)
def get_leaderboard(
    current_user: Optional[User] = Depends(get_optional_user),
    db: Session = Depends(get_db)
):
    # Query non-guest users with at least 1 test or questions solved
    users = db.query(User).filter(
        User.is_guest == False
    ).order_by(
        desc(User.questions_solved),
        desc(User.total_accuracy),
        desc(User.tests_taken)
    ).limit(100).all()

    top_performers = []
    user_rank_obj = None

    for idx, u in enumerate(users):
        rank = idx + 1
        l_user = LeaderboardUser(
            rank=rank,
            user_id=u.id,
            name=u.name,
            avatar=u.avatar or "avatar-default",
            tests_taken=u.tests_taken or 0,
            questions_solved=u.questions_solved or 0,
            streak=u.streak or 0,
            accuracy=round(u.total_accuracy or 0.0, 1)
        )
        if rank <= 50:
            top_performers.append(l_user)
        if current_user and u.id == current_user.id:
            user_rank_obj = l_user

    # If current user wasn't in top 100, calculate their approximate rank
    if current_user and not user_rank_obj and not current_user.is_guest:
        better_count = db.query(User).filter(
            User.is_guest == False,
            User.questions_solved > current_user.questions_solved
        ).count()
        user_rank_obj = LeaderboardUser(
            rank=better_count + 1,
            user_id=current_user.id,
            name=current_user.name,
            avatar=current_user.avatar or "avatar-default",
            tests_taken=current_user.tests_taken or 0,
            questions_solved=current_user.questions_solved or 0,
            streak=current_user.streak or 0,
            accuracy=round(current_user.total_accuracy or 0.0, 1)
        )

    total_count = db.query(User).filter(User.is_guest == False).count()

    return LeaderboardResponse(
        total_participants=total_count,
        top_performers=top_performers,
        user_rank=user_rank_obj
    )
