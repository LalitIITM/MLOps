#!/bin/bash

set -e  # Exit on any error

echo "=============================================="
echo "🛠️  Step 1: Create working directory"
echo "=============================================="
mkdir -p ~/dvc_demo && cd ~/dvc_demo

echo "=============================================="
echo "📥 Step 2: Clone your Git repository"
echo "=============================================="
git clone https://github.com/LalitIITM/MLOps.git repo
cd repo

echo "=============================================="
echo "🐍 Step 3: Create and activate virtual environment"
echo "=============================================="
python3 -m venv .venv
source .venv/bin/activate

echo "=============================================="
echo "📦 Step 4: Install requirements and DVC"
echo "=============================================="
pip install --upgrade pip
pip install -r requirements.txt
pip install dvc

echo "=============================================="
echo "🔁 Step 5: Initialize DVC"
echo "=============================================="
dvc init
git add .dvc .dvcignore
git commit -m "Initialize DVC"

echo "=============================================="
echo "📂 Step 6: Track dataset (V1)"
echo "=============================================="
dvc add data/iris.csv
git add data/iris.csv.dvc data/.gitignore
git commit -m "Add iris.csv as V1"
git tag V1

echo "=============================================="
echo "🤖 Step 7: Train model and save it (V1)"
echo "=============================================="
python main.py

echo "📦 Saving model as pickle"
mkdir -p models
cp models/decision_tree_model.pkl models/decision_tree_model_v1.pkl 2>/dev/null || true
dvc add models/decision_tree_model.pkl
git add models/decision_tree_model.pkl.dvc models/.gitignore
git commit -m "Train and save model for V1"

echo "=============================================="
echo "✂️  Step 8: Modify dataset to create V2"
echo "=============================================="
head -n -100 data/iris.csv > data/iris_v2.csv
mv data/iris_v2.csv data/iris.csv

echo "🔁 Re-track modified data"
dvc add data/iris.csv
git add data/iris.csv.dvc
git commit -m "Update iris.csv to V2 (remove 100 rows)"

echo "=============================================="
echo "🤖 Step 9: Train model and save it (V2)"
echo "=============================================="
python main.py

echo "📦 Saving model as pickle (V2)"
cp models/decision_tree_model.pkl models/decision_tree_model_v2.pkl 2>/dev/null || true
dvc add models/decision_tree_model.pkl
git add models/decision_tree_model.pkl.dvc
git commit -m "Train and save model for V2"
git tag V2

echo "=============================================="
echo "🔍 Step 10: Compare versions"
echo "=============================================="

# Checkout V1
echo "🔄 Checking out V1..."
git checkout V1
dvc checkout
echo "V1 Data Size:"
wc -l data/iris.csv

# Checkout V2
echo "🔄 Checking out V2..."
git checkout V2
dvc checkout
echo "V2 Data Size:"
wc -l data/iris.csv

echo "=============================================="
echo "✅ Demo completed: Data and model versioning with DVC"
echo "=============================================="
