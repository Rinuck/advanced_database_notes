# Lesson 03 Exercises - SQLAlchemy ORM + Alembic

## Exercise 1 & 2: Comment Model and Migration

```python
from sqlalchemy import Column, Integer, String, ForeignKey, Text, DateTime, func, CheckConstraint
from sqlalchemy.orm import relationship

class Comment(Base):
    __tablename__ = "comments"
    id = Column(Integer, primary_key=True)
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, server_default=func.current_timestamp())
    task_id = Column(Integer, ForeignKey("tasks.id", ondelete="CASCADE"))
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    task = relationship("Task", back_populates="comments")
    user = relationship("User", back_populates="comments")
    __table_args__ = (CheckConstraint("LENGTH(content) > 0", name="check_content_not_empty"),)

Task.comments = relationship("Comment", back_populates="task", cascade="all, delete-orphan")
User.comments = relationship("Comment", back_populates="user")

from alembic import command
import glob, os

for f in glob.glob('/content/alembic/versions/*.py'):
    os.remove(f)

command.revision(alembic_cfg, autogenerate=True, message="add comments table")

migration_files = sorted(glob.glob('/content/alembic/versions/*.py'))
with open(migration_files[-1]) as f:
    print(f.read())

command.upgrade(alembic_cfg, 'head')
print("Migration applied")
```

**Answers:**
1. `upgrade()` applies schema changes to the database
2. `downgrade()` reverts the migration
3. Downgrading drops the comments table and all its data

## Exercise 3: CRUD Challenge

```python
from sqlalchemy import func
from datetime import datetime

with Session(engine) as session:
    devops_team = Team(name="DevOps", description="Infrastructure team")
    session.add(devops_team)
    session.flush()
    
    diana = User(username="diana_ops", email="diana@example.com", full_name="Diana Ops", team_id=devops_team.id)
    session.add(diana)
    session.flush()
    
    tasks = [
        Task(title="Fix CI pipeline", description="Priority: high", status="open", assigned_to=diana.id),
        Task(title="Update config", description="Priority: medium", status="in_progress", assigned_to=diana.id),
        Task(title="Optimize builds", description="Priority: low", status="open", assigned_to=diana.id)
    ]
    for task in tasks:
        session.add(task)
    session.commit()
    
    task_count = session.query(Task).filter(Task.assigned_to == diana.id).count()
    print(f"Task count: {task_count}")
    
    tasks[0].status = "closed"
    
    low_task = session.query(Task).filter(Task.assigned_to == diana.id, Task.description == "Priority: low").first()
    if low_task:
        session.delete(low_task)
    session.commit()
    
    remaining = session.query(Task).filter(Task.assigned_to == diana.id).all()
    print(f"Remaining tasks: {len(remaining)}")
```

## Exercise 4: Migration Rollback

```python
class Team(Base):
    __tablename__ = "teams"
    id = Column(Integer, primary_key=True)
    name = Column(String(50), nullable=False, unique=True)
    description = Column(String(200))
    created_at = Column(DateTime, server_default=func.current_timestamp())
    users = relationship("User", back_populates="team")
    priority = Column(String(20), default='medium')
    due_date = Column(DateTime)
    tags = Column(String(500))
    estimated_hours = Column(Integer, default=0)

command.revision(alembic_cfg, autogenerate=True, message="add estimated_hours column")
command.upgrade(alembic_cfg, 'head')
print("Column added")

command.downgrade(alembic_cfg, "-1")
print("Rollback complete - column removed")
```

**Answers:**
1. The column is removed from the schema
2. All data in that column is permanently lost

## Exercise 5: Concept Check

**Answers:**

1. ORM allows working with Python objects instead of writing raw SQL, providing cleaner code, easier maintenance, and automatic relationship handling.

2. Migrations manage schema changes safely with version control, rollback capability, and team synchronization.

3. Rollback when a migration contains errors or a deployment fails.

4. `add()` prepares objects in the session memory. `commit()` permanently saves to the database.

5. Relationships allow navigation between related objects without writing manual JOIN statements.
```