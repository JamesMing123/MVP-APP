from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.response import ok
from app.dependencies import get_current_user
from app.models.community import Comment, Like, Post
from app.models.user import User
from app.schemas.community import CommentCreate, CommentOut, PostCreate, PostOut

router = APIRouter()


@router.get("/posts")
def list_posts(match_id: int | None = None, team_id: int | None = None, db: Session = Depends(get_db)):
    query = db.query(Post).filter(Post.status == "published")
    if match_id:
        query = query.filter(Post.match_id == match_id)
    if team_id:
        query = query.filter(Post.team_id == team_id)
    posts = query.order_by(Post.created_at.desc()).limit(50).all()
    return ok([PostOut.model_validate(item).model_dump(mode="json") for item in posts])


@router.post("/posts")
def create_post(payload: PostCreate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    post = Post(user_id=user.id, **payload.model_dump())
    db.add(post)
    db.commit()
    db.refresh(post)
    return ok(PostOut.model_validate(post).model_dump(mode="json"))


@router.get("/posts/{post_id}")
def get_post(post_id: int, db: Session = Depends(get_db)):
    post = db.get(Post, post_id)
    if post is None or post.status != "published":
        raise HTTPException(status_code=404, detail="Post not found")
    return ok(PostOut.model_validate(post).model_dump(mode="json"))


@router.post("/posts/{post_id}/comments")
def create_comment(post_id: int, payload: CommentCreate, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    post = db.get(Post, post_id)
    if post is None or post.status != "published":
        raise HTTPException(status_code=404, detail="Post not found")
    comment = Comment(post_id=post_id, user_id=user.id, **payload.model_dump())
    post.comment_count += 1
    db.add(comment)
    db.commit()
    db.refresh(comment)
    return ok(CommentOut.model_validate(comment).model_dump(mode="json"))


@router.get("/posts/{post_id}/comments")
def list_comments(post_id: int, db: Session = Depends(get_db)):
    comments = db.query(Comment).filter(Comment.post_id == post_id, Comment.status == "published").order_by(Comment.created_at.asc()).limit(100).all()
    return ok([CommentOut.model_validate(item).model_dump(mode="json") for item in comments])


@router.post("/posts/{post_id}/like")
def like_post(post_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    post = db.get(Post, post_id)
    if post is None or post.status != "published":
        raise HTTPException(status_code=404, detail="Post not found")
    like = Like(user_id=user.id, target_type="post", target_id=post_id)
    db.add(like)
    try:
        post.like_count += 1
        db.commit()
    except IntegrityError:
        db.rollback()
    return ok({"liked": True, "like_count": post.like_count})
