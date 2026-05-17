"""
API CDNU Cloud
FastAPI application for CDNU management
"""

from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from typing import List
import logging
import os

from .database import engine, get_db, Base
from .models import (
    CDNUCreate, CDNUResponse, CDNUUpdate,
    ResourceCreate, ResourceResponse,
    HealthResponse
)
from . import crud

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Environment variables
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APPLICATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

app = FastAPI(
    title="CDNU Cloud API",
    description="API pour la gestion des Centres de Développement du Numérique Universitaire",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json"
)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MIDDLEWARE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # À restreindre en production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STARTUP/SHUTDOWN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@app.on_event("startup")
async def startup_event():
    """Initialize database on startup"""
    logger.info(f"Starting CDNU Cloud API - Environment: {ENVIRONMENT}")
    
    # Create tables
    Base.metadata.create_all(bind=engine)
    logger.info("Database tables created")

@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown"""
    logger.info("Shutting down CDNU Cloud API")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EXCEPTION HANDLERS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Global exception handler"""
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Internal server error"}
    )

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECKS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@app.get("/health", response_model=HealthResponse, tags=["Health"])
async def health_check():
    """
    Health check endpoint for load balancer
    Returns 200 if service is healthy
    """
    return {
        "status": "healthy",
        "environment": ENVIRONMENT,
        "version": "1.0.0"
    }

@app.get("/api/v1/health", response_model=HealthResponse, tags=["Health"])
async def api_health_check(db: Session = Depends(get_db)):
    """
    Detailed health check including database connectivity
    """
    try:
        # Test database connection
        db.execute("SELECT 1")
        db_status = "connected"
    except Exception as e:
        logger.error(f"Database health check failed: {e}")
        db_status = "disconnected"
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database unavailable"
        )
    
    return {
        "status": "healthy",
        "environment": ENVIRONMENT,
        "version": "1.0.0",
        "database": db_status
    }

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CDNU ENDPOINTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@app.post("/api/v1/cdnu", response_model=CDNUResponse, status_code=status.HTTP_201_CREATED, tags=["CDNU"])
async def create_cdnu(cdnu: CDNUCreate, db: Session = Depends(get_db)):
    """
    Create a new CDNU
    """
    logger.info(f"Creating CDNU: {cdnu.name}")
    
    # Check if CDNU already exists
    existing_cdnu = crud.get_cdnu_by_name(db, cdnu.name)
    if existing_cdnu:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"CDNU '{cdnu.name}' already exists"
        )
    
    db_cdnu = crud.create_cdnu(db, cdnu)
    logger.info(f"CDNU created: {db_cdnu.id}")
    
    return db_cdnu

@app.get("/api/v1/cdnu", response_model=List[CDNUResponse], tags=["CDNU"])
async def list_cdnu(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """
    List all CDNUs
    """
    logger.info(f"Listing CDNUs (skip={skip}, limit={limit})")
    cdnus = crud.get_cdnus(db, skip=skip, limit=limit)
    return cdnus

@app.get("/api/v1/cdnu/{cdnu_id}", response_model=CDNUResponse, tags=["CDNU"])
async def get_cdnu(cdnu_id: int, db: Session = Depends(get_db)):
    """
    Get a specific CDNU by ID
    """
    logger.info(f"Getting CDNU: {cdnu_id}")
    cdnu = crud.get_cdnu(db, cdnu_id)
    
    if not cdnu:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"CDNU {cdnu_id} not found"
        )
    
    return cdnu

@app.put("/api/v1/cdnu/{cdnu_id}", response_model=CDNUResponse, tags=["CDNU"])
async def update_cdnu(
    cdnu_id: int,
    cdnu_update: CDNUUpdate,
    db: Session = Depends(get_db)
):
    """
    Update a CDNU
    """
    logger.info(f"Updating CDNU: {cdnu_id}")
    
    cdnu = crud.get_cdnu(db, cdnu_id)
    if not cdnu:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"CDNU {cdnu_id} not found"
        )
    
    updated_cdnu = crud.update_cdnu(db, cdnu_id, cdnu_update)
    logger.info(f"CDNU updated: {cdnu_id}")
    
    return updated_cdnu

@app.delete("/api/v1/cdnu/{cdnu_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["CDNU"])
async def delete_cdnu(cdnu_id: int, db: Session = Depends(get_db)):
    """
    Delete a CDNU
    """
    logger.info(f"Deleting CDNU: {cdnu_id}")
    
    cdnu = crud.get_cdnu(db, cdnu_id)
    if not cdnu:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"CDNU {cdnu_id} not found"
        )
    
    crud.delete_cdnu(db, cdnu_id)
    logger.info(f"CDNU deleted: {cdnu_id}")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RESOURCE ENDPOINTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@app.post("/api/v1/cdnu/{cdnu_id}/resources", response_model=ResourceResponse, status_code=status.HTTP_201_CREATED, tags=["Resources"])
async def create_resource(
    cdnu_id: int,
    resource: ResourceCreate,
    db: Session = Depends(get_db)
):
    """
    Create a new resource for a CDNU
    """
    logger.info(f"Creating resource for CDNU {cdnu_id}: {resource.resource_type}")
    
    # Check if CDNU exists
    cdnu = crud.get_cdnu(db, cdnu_id)
    if not cdnu:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"CDNU {cdnu_id} not found"
        )
    
    db_resource = crud.create_resource(db, cdnu_id, resource)
    logger.info(f"Resource created: {db_resource.id}")
    
    return db_resource

@app.get("/api/v1/cdnu/{cdnu_id}/resources", response_model=List[ResourceResponse], tags=["Resources"])
async def list_resources(
    cdnu_id: int,
    db: Session = Depends(get_db)
):
    """
    List all resources for a CDNU
    """
    logger.info(f"Listing resources for CDNU: {cdnu_id}")
    
    # Check if CDNU exists
    cdnu = crud.get_cdnu(db, cdnu_id)
    if not cdnu:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"CDNU {cdnu_id} not found"
        )
    
    resources = crud.get_resources_by_cdnu(db, cdnu_id)
    return resources

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ROOT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@app.get("/", tags=["Root"])
async def root():
    """
    Root endpoint
    """
    return {
        "message": "CDNU Cloud API",
        "version": "1.0.0",
        "docs": "/api/docs"
    }
