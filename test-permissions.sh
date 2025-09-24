#!/bin/bash

# Test script to validate GitHub token permissions and repository dispatch capability

echo "🔍 Testing GitHub Token Permissions and Repository Dispatch"
echo "=================================================="

# Test 1: Check GITHUB_TOKEN permissions
echo "1. Testing GITHUB_TOKEN repository info access..."
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github+json" \
     https://api.github.com/repos/$GITHUB_REPOSITORY \
     | jq -r '.permissions // "No permissions found"'

echo ""

# Test 2: Test repository dispatch with GITHUB_TOKEN
echo "2. Testing repository dispatch with GITHUB_TOKEN..."
dispatch_response=$(curl -s -w "HTTP_STATUS:%{http_code}" \
     -X POST \
     -H "Accept: application/vnd.github+json" \
     -H "Authorization: Bearer $GITHUB_TOKEN" \
     -H "X-GitHub-Api-Version: 2022-11-28" \
     https://api.github.com/repos/$GITHUB_REPOSITORY/dispatches \
     -d '{"event_type":"test-permissions","client_payload":{"test":"validation"}}')

http_status=$(echo "$dispatch_response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
response_body=$(echo "$dispatch_response" | sed 's/HTTP_STATUS:[0-9]*$//')

echo "HTTP Status: $http_status"
echo "Response: $response_body"

echo ""

# Test 3: Check what permissions GITHUB_TOKEN actually has
echo "3. Testing GITHUB_TOKEN scope/permissions..."
curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github+json" \
     https://api.github.com/user \
     | jq -r '.login // "Token info not accessible"'

echo ""

# Test 4: Test simplified dispatch payload
echo "4. Testing minimal dispatch payload..."
minimal_response=$(curl -s -w "HTTP_STATUS:%{http_code}" \
     -X POST \
     -H "Authorization: Bearer $GITHUB_TOKEN" \
     https://api.github.com/repos/$GITHUB_REPOSITORY/dispatches \
     -d '{"event_type":"minimal-test"}')

minimal_status=$(echo "$minimal_response" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
minimal_body=$(echo "$minimal_response" | sed 's/HTTP_STATUS:[0-9]*$//')

echo "Minimal HTTP Status: $minimal_status"
echo "Minimal Response: $minimal_body"

echo ""
echo "🎯 Summary:"
echo "- Status 204: Success"
echo "- Status 403: Permission denied"  
echo "- Status 404: Not found"
echo "- Status 422: Validation failed"
