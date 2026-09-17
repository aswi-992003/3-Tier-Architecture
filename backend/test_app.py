from app import app


def test_health():
    """Test that the backend health endpoint is working."""

    client = app.test_client()

    response = client.get("/api/health")

    assert response.status_code == 200

    data = response.get_json()

    assert data["status"] == "healthy"
    assert data["service"] == "claims-backend"