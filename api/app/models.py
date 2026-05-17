"""
Data models
Pydantic schemas for validation and SQLAlchemy models for database
"""

from pydantic import BaseModel, Field, validator
from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from typing import Optional, List
from datetime import datetime

from .database import Base

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SQLALCHEMY MODELS (Database Tables)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class CDNU(Base):
    """CDNU table"""
    __tablename__ = "cdnu"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True, nullable=False)
    city = Column(String, nullable=False)
    region = Column(String, nullable=False)
    vpc_cidr = Column(String, nullable=False)
    instance_id = Column(String, nullable=True)
    public_ip = Column(String, nullable=True)
    status = Column(String, default="active")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    resources = relationship("Resource", back_populates="cdnu", cascade="all, delete-orphan")

class Resource(Base):
    """Resource table"""
    __tablename__ = "resource"
    
    id = Column(Integer, primary_key=True, index=True)
    cdnu_id = Column(Integer, ForeignKey("cdnu.id"), nullable=False)
    resource_type = Column(String, nullable=False)  # ec2, rds, s3, etc.
    resource_id = Column(String, nullable=False)
    resource_arn = Column(String, nullable=True)
    status = Column(String, default="running")
    metadata = Column(String, nullable=True)  # JSON string
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    cdnu = relationship("CDNU", back_populates="resources")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PYDANTIC SCHEMAS (API Request/Response)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Health Check
class HealthResponse(BaseModel):
    status: str
    environment: str
    version: str
    database: Optional[str] = None

# CDNU Schemas
class CDNUBase(BaseModel):
    """Base CDNU schema"""
    name: str = Field(..., min_length=3, max_length=50)
    city: str = Field(..., min_length=3, max_length=100)
    region: str = Field(..., min_length=3, max_length=50)
    vpc_cidr: str = Field(..., regex=r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}$')
    
    @validator('name')
    def name_alphanumeric(cls, v):
        """Validate name is alphanumeric"""
        if not v.replace('-', '').replace('_', '').isalnum():
            raise ValueError('Name must be alphanumeric (hyphens and underscores allowed)')
        return v.lower()

class CDNUCreate(CDNUBase):
    """Schema for creating a CDNU"""
    pass

class CDNUUpdate(BaseModel):
    """Schema for updating a CDNU"""
    city: Optional[str] = None
    region: Optional[str] = None
    instance_id: Optional[str] = None
    public_ip: Optional[str] = None
    status: Optional[str] = None

class CDNUResponse(CDNUBase):
    """Schema for CDNU response"""
    id: int
    instance_id: Optional[str]
    public_ip: Optional[str]
    status: str
    created_at: datetime
    updated_at: Optional[datetime]
    
    class Config:
        orm_mode = True

# Resource Schemas
class ResourceBase(BaseModel):
    """Base Resource schema"""
    resource_type: str = Field(..., min_length=2, max_length=50)
    resource_id: str = Field(..., min_length=3, max_length=200)
    resource_arn: Optional[str] = None
    status: Optional[str] = "running"
    metadata: Optional[str] = None

class ResourceCreate(ResourceBase):
    """Schema for creating a Resource"""
    pass

class ResourceResponse(ResourceBase):
    """Schema for Resource response"""
    id: int
    cdnu_id: int
    created_at: datetime
    updated_at: Optional[datetime]
    
    class Config:
        orm_mode = True
