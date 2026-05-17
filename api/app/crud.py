"""
CRUD operations
Create, Read, Update, Delete functions for database models
"""

from sqlalchemy.orm import Session
from typing import List, Optional

from .models import CDNU, Resource, CDNUCreate, CDNUUpdate, ResourceCreate

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CDNU OPERATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def get_cdnu(db: Session, cdnu_id: int) -> Optional[CDNU]:
    """
    Get a CDNU by ID
    """
    return db.query(CDNU).filter(CDNU.id == cdnu_id).first()

def get_cdnu_by_name(db: Session, name: str) -> Optional[CDNU]:
    """
    Get a CDNU by name
    """
    return db.query(CDNU).filter(CDNU.name == name).first()

def get_cdnus(db: Session, skip: int = 0, limit: int = 100) -> List[CDNU]:
    """
    Get all CDNUs with pagination
    """
    return db.query(CDNU).offset(skip).limit(limit).all()

def create_cdnu(db: Session, cdnu: CDNUCreate) -> CDNU:
    """
    Create a new CDNU
    """
    db_cdnu = CDNU(
        name=cdnu.name,
        city=cdnu.city,
        region=cdnu.region,
        vpc_cidr=cdnu.vpc_cidr,
        status="active"
    )
    db.add(db_cdnu)
    db.commit()
    db.refresh(db_cdnu)
    return db_cdnu

def update_cdnu(db: Session, cdnu_id: int, cdnu_update: CDNUUpdate) -> CDNU:
    """
    Update a CDNU
    """
    db_cdnu = db.query(CDNU).filter(CDNU.id == cdnu_id).first()
    
    if db_cdnu:
        update_data = cdnu_update.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_cdnu, key, value)
        
        db.commit()
        db.refresh(db_cdnu)
    
    return db_cdnu

def delete_cdnu(db: Session, cdnu_id: int) -> bool:
    """
    Delete a CDNU
    """
    db_cdnu = db.query(CDNU).filter(CDNU.id == cdnu_id).first()
    
    if db_cdnu:
        db.delete(db_cdnu)
        db.commit()
        return True
    
    return False

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RESOURCE OPERATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def get_resource(db: Session, resource_id: int) -> Optional[Resource]:
    """
    Get a Resource by ID
    """
    return db.query(Resource).filter(Resource.id == resource_id).first()

def get_resources_by_cdnu(db: Session, cdnu_id: int) -> List[Resource]:
    """
    Get all Resources for a specific CDNU
    """
    return db.query(Resource).filter(Resource.cdnu_id == cdnu_id).all()

def get_resources_by_type(db: Session, resource_type: str) -> List[Resource]:
    """
    Get all Resources of a specific type
    """
    return db.query(Resource).filter(Resource.resource_type == resource_type).all()

def create_resource(db: Session, cdnu_id: int, resource: ResourceCreate) -> Resource:
    """
    Create a new Resource
    """
    db_resource = Resource(
        cdnu_id=cdnu_id,
        resource_type=resource.resource_type,
        resource_id=resource.resource_id,
        resource_arn=resource.resource_arn,
        status=resource.status,
        metadata=resource.metadata
    )
    db.add(db_resource)
    db.commit()
    db.refresh(db_resource)
    return db_resource

def update_resource(db: Session, resource_id: int, status: str) -> Resource:
    """
    Update a Resource status
    """
    db_resource = db.query(Resource).filter(Resource.id == resource_id).first()
    
    if db_resource:
        db_resource.status = status
        db.commit()
        db.refresh(db_resource)
    
    return db_resource

def delete_resource(db: Session, resource_id: int) -> bool:
    """
    Delete a Resource
    """
    db_resource = db.query(Resource).filter(Resource.id == resource_id).first()
    
    if db_resource:
        db.delete(db_resource)
        db.commit()
        return True
    
    return False
