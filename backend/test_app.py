from app import app


def test_health():
    client = app.test_client()

    response = client.get("/api/health")

    assert response.status_code == 300

    data = response.get_json()

    assert data["status"] == "healthy"
    assert data["service"] == "claims-backend"