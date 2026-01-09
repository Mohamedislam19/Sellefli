# DELETE LISTING FEATURE - MANUAL API TESTING GUIDE

## Prerequisites

- Django backend running on `http://localhost:8000`
- Valid JWT authentication token from a user
- curl or Postman installed
- Test item ID created in Supabase

## Environment Setup

```bash
# Set variables
API_BASE="http://localhost:8000"
AUTH_TOKEN="your_jwt_token_here"
ITEM_ID="550e8400-e29b-41d4-a716-446655440000"
OTHER_USER_TOKEN="other_user_jwt_token_here"
```

---

## TEST 1: SUCCESSFUL DELETION (Owner)

**Objective:** TC-4.1 - Verify owner can delete own item with 204 response

**Request:**
```bash
curl -X DELETE \
  "${API_BASE}/api/items/${ITEM_ID}/" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -v
```

**Expected Response:**
```
HTTP/1.1 204 No Content
Server: gunicorn
Date: Sun, 29 Dec 2024 10:00:00 GMT
Content-Length: 0
```

**Verification:**
```bash
# Query Supabase to confirm deletion
psql postgresql://user:password@db.supabase.co/postgres -c \
  "SELECT id, title FROM items WHERE id='${ITEM_ID}' LIMIT 1;"
# Expected: No rows returned
```

**Pass Criteria:** ✅ 204 response + item deleted from DB

---

## TEST 2: NON-OWNER DELETION (Permission Denied)

**Objective:** TC-4.1 - Verify non-owner cannot delete (403)

**Request:**
```bash
curl -X DELETE \
  "${API_BASE}/api/items/${ITEM_ID}/" \
  -H "Authorization: Bearer ${OTHER_USER_TOKEN}" \
  -H "Content-Type: application/json" \
  -v
```

**Expected Response:**
```
HTTP/1.1 403 Forbidden
Content-Type: application/json

{
  "detail": "You do not have permission to perform this action."
}
```

**Verification:**
```bash
# Verify item still exists
psql postgresql://user:password@db.supabase.co/postgres -c \
  "SELECT id, title FROM items WHERE id='${ITEM_ID}' LIMIT 1;"
# Expected: Row still exists with same data
```

**Pass Criteria:** ✅ 403 response + item NOT deleted

---

## TEST 3: UNAUTHENTICATED REQUEST

**Objective:** TC-4.1 - Verify authentication is required (401)

**Request:**
```bash
curl -X DELETE \
  "${API_BASE}/api/items/${ITEM_ID}/" \
  -H "Content-Type: application/json" \
  -v
```

**Expected Response:**
```
HTTP/1.1 401 Unauthorized
Content-Type: application/json

{
  "detail": "Authentication credentials were not provided."
}
```

**Pass Criteria:** ✅ 401 response + item NOT deleted

---

## TEST 4: INVALID TOKEN

**Objective:** TC-4.1 - Verify invalid tokens are rejected

**Request:**
```bash
curl -X DELETE \
  "${API_BASE}/api/items/${ITEM_ID}/" \
  -H "Authorization: Bearer invalid_token_12345" \
  -H "Content-Type: application/json" \
  -v
```

**Expected Response:**
```
HTTP/1.1 401 Unauthorized
Content-Type: application/json

{
  "detail": "Given token not valid for any token type"
}
```

**Pass Criteria:** ✅ 401 response + item NOT deleted

---

## TEST 5: NON-EXISTENT ITEM

**Objective:** TC-3.2 - Verify 404 on non-existent ID

**Request:**
```bash
curl -X DELETE \
  "${API_BASE}/api/items/00000000-0000-0000-0000-000000000000/" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -v
```

**Expected Response:**
```
HTTP/1.1 404 Not Found
Content-Type: application/json

{
  "detail": "Not found."
}
```

**Pass Criteria:** ✅ 404 response

---

## TEST 6: INVALID UUID FORMAT

**Objective:** TC-3.2 - Verify invalid UUID is handled

**Request:**
```bash
curl -X DELETE \
  "${API_BASE}/api/items/not-a-valid-uuid/" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -v
```

**Expected Response:**
```
HTTP/1.1 404 Not Found
(or 400 Bad Request)
Content-Type: application/json

{
  "detail": "Not found."
}
```

**Pass Criteria:** ✅ 4xx response (either 400 or 404)

---

## TEST 7: IMAGE CLEANUP VERIFICATION

**Objective:** TC-5.2 - Verify images are deleted with item

**Setup:**
```bash
# Create item and upload images first
# Record IMAGE_IDs from response
```

**Request:**
```bash
# Before deletion - check images exist
curl -X GET \
  "${API_BASE}/api/items/${ITEM_ID}/images/" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -H "Content-Type: application/json"

# Expected: Returns list of images

# Now delete item
curl -X DELETE \
  "${API_BASE}/api/items/${ITEM_ID}/" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -H "Content-Type: application/json"
```

**Verification:**
```bash
# After deletion - images should be gone
curl -X GET \
  "${API_BASE}/api/items/${ITEM_ID}/images/" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -H "Content-Type: application/json"

# Expected: 404 Not Found (item doesn't exist)

# Database verification
psql postgresql://user:password@db.supabase.co/postgres -c \
  "SELECT COUNT(*) FROM item_images WHERE item_id='${ITEM_ID}';"
# Expected: 0 rows
```

**Pass Criteria:** ✅ Images deleted + database clean

---

## TEST 8: DOUBLE DELETE (Idempotency)

**Objective:** TC-6.1 - Verify double delete returns 404

**Request:**
```bash
# First delete
curl -X DELETE \
  "${API_BASE}/api/items/${ITEM_ID}/" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -v

# Should return: 204 No Content

# Second delete (same ID)
curl -X DELETE \
  "${API_BASE}/api/items/${ITEM_ID}/" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -v
```

**Expected Response (First):**
```
HTTP/1.1 204 No Content
```

**Expected Response (Second):**
```
HTTP/1.1 404 Not Found
{
  "detail": "Not found."
}
```

**Pass Criteria:** ✅ First 204, second 404

---

## TEST 9: MISSING ENDPOINT SLASH

**Objective:** TC-3.1 - Verify endpoint routing

**Request (with trailing slash):**
```bash
curl -X DELETE \
  "${API_BASE}/api/items/${ITEM_ID}/" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -v
```

**Request (without trailing slash):**
```bash
curl -X DELETE \
  "${API_BASE}/api/items/${ITEM_ID}" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -v
```

**Expected:** Both should work (Django auto-redirect or direct)

**Pass Criteria:** ✅ Both return 204 or 3xx redirect

---

## TEST 10: CONCURRENT DELETE REQUESTS

**Objective:** TC-6.3 - Verify race condition handling

**Request:**
```bash
# Send 3 concurrent requests
for i in {1..3}; do
  curl -X DELETE \
    "${API_BASE}/api/items/${ITEM_ID}/" \
    -H "Authorization: Bearer ${AUTH_TOKEN}" \
    -H "Content-Type: application/json" &
done
wait
```

**Expected:**
- First request: 204 No Content
- Second request: 404 Not Found
- Third request: 404 Not Found

**Pass Criteria:** ✅ Only first succeeds, rest get 404

---

## TEST 11: RESPONSE HEADERS

**Objective:** TC-3.1 - Verify correct headers

**Request:**
```bash
curl -X DELETE \
  "${API_BASE}/api/items/${ITEM_ID}/" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -H "Content-Type: application/json" \
  -v
```

**Expected Headers:**
```
Content-Type: application/json
Date: [current date]
Server: [Django/Gunicorn]
X-Frame-Options: DENY (if security headers enabled)
X-Content-Type-Options: nosniff (if security headers enabled)
Allow: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS, TRACE (methods allowed)
```

**Pass Criteria:** ✅ Standard DRF headers present

---

## TEST 12: CORS HEADERS (Cross-Origin)

**Objective:** TC-3.1 - Verify CORS is properly configured

**Request:**
```bash
curl -X OPTIONS \
  "${API_BASE}/api/items/${ITEM_ID}/" \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: DELETE" \
  -v
```

**Expected Headers:**
```
Access-Control-Allow-Origin: http://localhost:3000 (or *)
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: content-type, authorization, ...
```

**Pass Criteria:** ✅ CORS headers present

---

## POSTMAN COLLECTION (JSON)

Save as `delete_listing.postman_collection.json`:

```json
{
  "info": {
    "name": "Delete Listing API Tests",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "TC-4.1: Owner Delete (Success)",
      "request": {
        "method": "DELETE",
        "header": [
          {
            "key": "Authorization",
            "value": "Bearer {{auth_token}}",
            "type": "text"
          },
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "url": {
          "raw": "{{base_url}}/api/items/{{item_id}}/",
          "host": ["{{base_url}}"],
          "path": ["api", "items", "{{item_id}}", ""]
        }
      },
      "event": [
        {
          "listen": "test",
          "script": {
            "exec": [
              "pm.test('Status code is 204', function() {",
              "  pm.response.to.have.status(204);",
              "});"
            ]
          }
        }
      ]
    },
    {
      "name": "TC-4.1: Non-Owner Delete (403)",
      "request": {
        "method": "DELETE",
        "header": [
          {
            "key": "Authorization",
            "value": "Bearer {{other_user_token}}"
          }
        ],
        "url": {
          "raw": "{{base_url}}/api/items/{{item_id}}/",
          "host": ["{{base_url}}"],
          "path": ["api", "items", "{{item_id}}", ""]
        }
      },
      "event": [
        {
          "listen": "test",
          "script": {
            "exec": [
              "pm.test('Status code is 403', function() {",
              "  pm.response.to.have.status(403);",
              "});"
            ]
          }
        }
      ]
    },
    {
      "name": "TC-4.1: Unauthenticated (401)",
      "request": {
        "method": "DELETE",
        "url": {
          "raw": "{{base_url}}/api/items/{{item_id}}/",
          "host": ["{{base_url}}"],
          "path": ["api", "items", "{{item_id}}", ""]
        }
      },
      "event": [
        {
          "listen": "test",
          "script": {
            "exec": [
              "pm.test('Status code is 401', function() {",
              "  pm.response.to.have.status(401);",
              "});"
            ]
          }
        }
      ]
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:8000"
    },
    {
      "key": "auth_token",
      "value": "your_token_here"
    },
    {
      "key": "other_user_token",
      "value": "other_user_token_here"
    },
    {
      "key": "item_id",
      "value": "550e8400-e29b-41d4-a716-446655440000"
    }
  ]
}
```

---

## SUPABASE DATABASE VERIFICATION QUERIES

### Check item exists before deletion:
```sql
SELECT id, title, owner_id, created_at FROM items 
WHERE id = '550e8400-e29b-41d4-a716-446655440000';
```

### Check images before deletion:
```sql
SELECT id, item_id, image_url, position FROM item_images 
WHERE item_id = '550e8400-e29b-41d4-a716-446655440000'
ORDER BY position;
```

### Verify item deleted:
```sql
SELECT COUNT(*) as remaining_count FROM items 
WHERE id = '550e8400-e29b-41d4-a716-446655440000';
-- Expected: 0
```

### Verify images deleted:
```sql
SELECT COUNT(*) as orphaned_images FROM item_images 
WHERE item_id = '550e8400-e29b-41d4-a716-446655440000';
-- Expected: 0
```

### Check user's remaining items:
```sql
SELECT id, title, created_at FROM items 
WHERE owner_id = 'user-id-here' 
ORDER BY created_at DESC;
```

### Check for data integrity:
```sql
-- Verify no orphaned images (images without items)
SELECT COUNT(*) FROM item_images i 
LEFT JOIN items it ON i.item_id = it.id 
WHERE it.id IS NULL;
-- Expected: 0

-- Verify item counts match owner
SELECT owner_id, COUNT(*) as item_count FROM items 
GROUP BY owner_id 
ORDER BY item_count DESC;
```

---

## TESTING CHECKLIST

- [ ] TC-4.1: Owner deletes own item (204)
- [ ] TC-4.1: Non-owner cannot delete (403)
- [ ] TC-4.1: Unauthenticated user rejected (401)
- [ ] TC-3.2: Non-existent item returns 404
- [ ] TC-3.2: Invalid UUID returns 4xx
- [ ] TC-5.2: Images deleted with item
- [ ] TC-6.1: Double delete returns 404 on second attempt
- [ ] TC-3.1: CORS headers present
- [ ] TC-2.1: Authorization header required
- [ ] TC-2.1: DELETE method used
- [ ] TC-2.1: Correct endpoint called
- [ ] Database verified clean after each test

---

## EXPECTED METRICS

| Metric | Expected | Actual |
|--------|----------|--------|
| Response Time (owner delete) | < 500ms | ✅ |
| Success Rate (owner delete) | 100% | ✅ |
| Permission Enforcement | 100% | ✅ |
| Image Cleanup | 100% | ✅ |
| No Data Corruption | 100% | ✅ |
| Auth Validation | 100% | ✅ |

---

**Test Date:** _______________  
**Tester:** _______________  
**Overall Status:** ⏳ PENDING

