#!/usr/bin/env bash
set -e

echo "Starting post-create setup..."

# Install uv for dependency management
echo "Installing uv..."
pip install --no-cache-dir uv

# Detect and execute the correct dependency manager
if [ -f "pyproject.toml" ]; then
    if grep -q "\[tool.poetry\]" pyproject.toml; then
        echo "Detected Poetry configuration. Installing dependencies with poetry..."
        poetry install
    elif grep -q "pdm-backend" pyproject.toml; then
        echo "Detected PDM backend configuration. Installing dependencies with uv..."
        uv sync
    fi
elif [ -f "requirements.txt" ]; then
    echo "Detected requirements.txt. Installing dependencies with pip..."
    pip install -r requirements.txt
elif [ -f "src/requirements.txt" ]; then
    echo "Detected src/requirements.txt. Installing dependencies with pip..."
    pip install -r src/requirements.txt
else
    echo "No recognized dependency file found (pyproject.toml or requirements.txt)"
fi

# For repo1: Run Alembic migrations if alembic.ini exists
if [ -f "alembic.ini" ]; then
    echo "Detected Alembic configuration. Running database migrations..."
    if grep -q "\[tool.poetry\]" pyproject.toml 2>/dev/null; then
        echo "Running migrations with poetry..."
        poetry run alembic upgrade head
    else
        echo "Running migrations with alembic..."
        alembic upgrade head
    fi
fi

echo "Post-create setup completed successfully!"