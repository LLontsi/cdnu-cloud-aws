"""
Unit tests for CDNU Cloud API
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.database import Base, get_db
from app.models import CDNUCreate

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEST DATABASE SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FIXTURES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@pytest.fixture(scope="module")
def client():
    """Test client fixture"""
    # Create tables
    Base.metadata.create_all(bind=engine)
    
    # Create client
    with TestClient(app) as c:
        yield c
    
    # Drop tables
    Base.metadata.drop_all(bind=engine)

@pytest.fixture
def sample_cdnu():
    """Sample CDNU data"""
    return {
        "name": "yaounde",
        "city": "Yaoundé",
        "region": "Centre",
        "vpc_cidr": "10.0.0.0/16"
    }

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK TESTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def test_health_check(client):
    """Test basic health check"""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "version" in data

def test_api_health_check(client):
    """Test detailed health check"""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["database"] == "connected"

def test_root(client):
    """Test root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "version" in data

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CDNU CRUD TESTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def test_create_cdnu(client, sample_cdnu):
    """Test creating a CDNU"""
    response = client.post("/api/v1/cdnu", json=sample_cdnu)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == sample_cdnu["name"]
    assert data["city"] == sample_cdnu["city"]
    assert data["status"] == "active"
    assert "id" in data

def test_create_duplicate_cdnu(client, sample_cdnu):
    """Test creating duplicate CDNU (should fail)"""
    # First creation
    client.post("/api/v1/cdnu", json=sample_cdnu)
    
    # Duplicate creation
    response = client.post("/api/v1/cdnu", json=sample_cdnu)
    assert response.status_code == 400
    assert "already exists" in response.json()["detail"]

def test_list_cdnu(client, sample_cdnu):
    """Test listing CDNUs"""
    # Create a CDNU
    client.post("/api/v1/cdnu", json=sample_cdnu)
    
    # List CDNUs
    response = client.get("/api/v1/cdnu")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1

def test_get_cdnu(client, sample_cdnu):
    """Test getting a specific CDNU"""
    # Create a CDNU
    create_response = client.post("/api/v1/cdnu", json=sample_cdnu)
    cdnu_id = create_response.json()["id"]
    
    # Get the CDNU
    response = client.get(f"/api/v1/cdnu/{cdnu_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == cdnu_id
    assert data["name"] == sample_cdnu["name"]

def test_get_nonexistent_cdnu(client):
    """Test getting non-existent CDNU"""
    response = client.get("/api/v1/cdnu/99999")
    assert response.status_code == 404

def test_update_cdnu(client, sample_cdnu):
    """Test updating a CDNU"""
    # Create a CDNU
    create_response = client.post("/api/v1/cdnu", json=sample_cdnu)
    cdnu_id = create_response.json()["id"]
    
    # Update the CDNU
    update_data = {"city": "Yaoundé Updated", "status": "inactive"}
    response = client.put(f"/api/v1/cdnu/{cdnu_id}", json=update_data)
    assert response.status_code == 200
    data = response.json()
    assert data["city"] == "Yaoundé Updated"
    assert data["status"] == "inactive"

def test_delete_cdnu(client, sample_cdnu):
    """Test deleting a CDNU"""
    # Create a CDNU
    create_response = client.post("/api/v1/cdnu", json=sample_cdnu)
    cdnu_id = create_response.json()["id"]
    
    # Delete the CDNU
    response = client.delete(f"/api/v1/cdnu/{cdnu_id}")
    assert response.status_code == 204
    
    # Verify deletion
    get_response = client.get(f"/api/v1/cdnu/{cdnu_id}")
    assert get_response.status_code == 404

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RESOURCE TESTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def test_create_resource(client, sample_cdnu):
    """Test creating a resource for a CDNU"""
    # Create a CDNU
    cdnu_response = client.post("/api/v1/cdnu", json=sample_cdnu)
    cdnu_id = cdnu_response.json()["id"]
    
    # Create a resource
    resource_data = {
        "resource_type": "ec2",
        "resource_id": "i-1234567890abcdef0",
        "resource_arn": "arn:aws:ec2:eu-central-1:123456789012:instance/i-1234567890abcdef0",
        "status": "running"
    }
    response = client.post(f"/api/v1/cdnu/{cdnu_id}/resources", json=resource_data)
    assert response.status_code == 201
    data = response.json()
    assert data["resource_type"] == "ec2"
    assert data["cdnu_id"] == cdnu_id

def test_list_resources(client, sample_cdnu):
    """Test listing resources for a CDNU"""
    # Create a CDNU
    cdnu_response = client.post("/api/v1/cdnu", json=sample_cdnu)
    cdnu_id = cdnu_response.json()["id"]
    
    # Create a resource
    resource_data = {
        "resource_type": "s3",
        "resource_id": "cdnu-bucket-12345"
    }
    client.post(f"/api/v1/cdnu/{cdnu_id}/resources", json=resource_data)
    
    # List resources
    response = client.get(f"/api/v1/cdnu/{cdnu_id}/resources")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1

def test_create_resource_for_nonexistent_cdnu(client):
    """Test creating resource for non-existent CDNU"""
    resource_data = {
        "resource_type": "ec2",
        "resource_id": "i-test"
    }
    response = client.post("/api/v1/cdnu/99999/resources", json=resource_data)
    assert response.status_code == 404

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VALIDATION TESTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def test_invalid_vpc_cidr(client):
    """Test creating CDNU with invalid VPC CIDR"""
    invalid_cdnu = {
        "name": "test",
        "city": "Test City",
        "region": "Test Region",
        "vpc_cidr": "invalid_cidr"
    }
    response = client.post("/api/v1/cdnu", json=invalid_cdnu)
    assert response.status_code == 422

def test_short_name(client):
    """Test creating CDNU with too short name"""
    invalid_cdnu = {
        "name": "ab",
        "city": "Test City",
        "region": "Test Region",
        "vpc_cidr": "10.0.0.0/16"
    }
    response = client.post("/api/v1/cdnu", json=invalid_cdnu)
    assert response.status_code == 422
