#!/usr/bin/python3
import os
import json
import yaml
from pathlib import Path

def main(): 
    # Load compliance manifest yaml
    compliance_manifest_yaml_path = Path("compliance_manifest.yaml")
    if compliance_manifest_yaml_path.exists():
        with open("compliance_manifest.yaml", 'r') as stream:
            try:
                content = yaml.safe_load(stream)
            except yaml.YAMLError as exc:
                print(exc)
    else:
        print("Could not find hardening manifest file in repository root directory")

    process_manifest(content)

def process_manifest(content):
    # Add git environment information to content dict
    git_sha = os.getenv('GITHUB_SHA')
    content["gitSha"] = git_sha
    content["fullImageTag"] = content["imageName"] + git_sha
    # Create JSON manifest file for reports stage
    with open("artifacts/compliance-manifest.json", "w") as file:
        json.dump(content, file)
    
if __name__ == "__main__":
    main()